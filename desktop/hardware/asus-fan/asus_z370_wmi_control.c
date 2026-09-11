// SPDX-License-Identifier: GPL-2.0-only
/*
 * ASUS PRIME Z370-P policy-profile controller.
 *
 * The module is intentionally inert when loaded. Reading status performs only
 * GFAN getter calls. A write to debugfs/apply_profile is the explicit action
 * boundary and is board-gated, read-back verified, and rollback-protected.
 */
#include <linux/acpi.h>
#include <linux/debugfs.h>
#include <linux/dmi.h>
#include <linux/fs.h>
#include <linux/kernel.h>
#include <linux/mutex.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/stdarg.h>
#include <linux/uaccess.h>

#include "protocol.h"

#define ASUS_WMI_MGMT_GUID "97845ED0-4E6D-11DE-8A39-0800200C9A66"
#define AZ370_FAN_COUNT 2

struct az370_state {
	struct mutex lock;
	struct dentry *root;
	struct az370_policy snapshot[AZ370_FAN_COUNT];
	bool snapshot_valid;
	char last_result[384];
	char last_detail[256];
};

static struct az370_state az370;


static __printf(1, 2) void az370_set_detail(const char *fmt, ...)
{
	va_list args;

	va_start(args, fmt);
	vscnprintf(az370.last_detail, sizeof(az370.last_detail), fmt, args);
	va_end(args);
}

static bool az370_board_matches(void)
{
	const char *vendor = dmi_get_system_info(DMI_BOARD_VENDOR);
	const char *name = dmi_get_system_info(DMI_BOARD_NAME);

	return vendor && name && strcmp(vendor, "ASUSTeK COMPUTER INC.") == 0 &&
	       strcmp(name, "PRIME Z370-P") == 0;
}

static int az370_call(u32 method, const void *input, size_t input_length,
			      u8 **data, size_t *data_length, char *detail,
			      size_t detail_length)
{
	struct acpi_buffer in = { input_length, (void *)input };
	struct acpi_buffer out = { ACPI_ALLOCATE_BUFFER, NULL };
	union acpi_object *obj;
	acpi_status status;

	status = wmi_evaluate_method(ASUS_WMI_MGMT_GUID, 0, method, &in, &out);
	if (ACPI_FAILURE(status)) {
		scnprintf(detail, detail_length,
			   "method=0x%08x ACPI status=0x%08x", method, status);
		return -EIO;
	}
	obj = out.pointer;
	if (!obj) {
		scnprintf(detail, detail_length,
			   "method=0x%08x returned no object", method);
		return -ENODATA;
	}
	if (obj->type == ACPI_TYPE_BUFFER) {
		*data_length = obj->buffer.length;
		*data = kmemdup(obj->buffer.pointer, obj->buffer.length,
				GFP_KERNEL);
		kfree(obj);
		if (!*data) {
			scnprintf(detail, detail_length,
				   "method=0x%08x response allocation failed", method);
			return -ENOMEM;
		}
		return 0;
	}
	if (obj->type == ACPI_TYPE_INTEGER) {
		u32 value = obj->integer.value;
		u8 *scalar = kmalloc(sizeof(value), GFP_KERNEL);

		if (scalar)
			az370_put32(scalar, value);
		kfree(obj);
		if (!scalar) {
			scnprintf(detail, detail_length,
				   "method=0x%08x scalar=%u allocation failed",
				   method, value);
			return -ENOMEM;
		}
		*data = scalar;
		*data_length = sizeof(value);
		scnprintf(detail, detail_length,
			   "method=0x%08x returned scalar=%u", method, value);
		return 0;
	}
	{
		u32 obj_type = obj->type;

		kfree(obj);
		scnprintf(detail, detail_length,
			   "method=0x%08x returned ACPI type=%u", method, obj_type);
	}
	return -EPROTO;
}

static int az370_get_policy(u8 fan_type, struct az370_policy *policy)
{
	u32 args[3] = { fan_type, 0, 0 };
	u8 *data = NULL;
	size_t length = 0;
	char call_detail[128];
	int ret;

	ret = az370_call(AZ370_GFAN, args, sizeof(args), &data, &length,
			 call_detail, sizeof(call_detail));
	if (ret) {
		az370_set_detail("GFAN fan=%u failed: %s", fan_type, call_detail);
		return ret;
	}
	ret = az370_parse_policy(data, length, policy);
	if (ret) {
		if (length >= sizeof(u32) && az370_get32(data) != 0)
			az370_set_detail("GFAN fan=%u firmware_error=%u", fan_type,
					az370_get32(data));
		else
			az370_set_detail("GFAN fan=%u response parse failed: %d",
					fan_type, ret);
	}
	kfree(data);
	return ret;
}

static int az370_set_policy(u8 fan_type, const struct az370_policy *policy)
{
	u8 input[AZ370_MAX_DFAN_INPUT];
	u8 *data = NULL;
	size_t input_length = 0;
	size_t output_length = 0;
	char call_detail[128];
	int ret;

	ret = az370_pack_dfan(input, sizeof(input), fan_type, policy->mode,
				     policy->low_limit, policy->profile, &input_length);
	if (ret) {
		az370_set_detail("DFAN fan=%u request packing failed: %d", fan_type,
				ret);
		return ret;
	}
	ret = az370_call(AZ370_DFAN, input, input_length, &data,
				 &output_length, call_detail, sizeof(call_detail));
	if (ret) {
		az370_set_detail("DFAN fan=%u failed: %s", fan_type, call_detail);
		return ret;
	}
	if (output_length < sizeof(u32)) {
		az370_set_detail("DFAN fan=%u response too short: %zu bytes",
				fan_type, output_length);
		ret = -EIO;
	} else if (az370_get32(data) != 0) {
		az370_set_detail("DFAN fan=%u firmware_error=%u", fan_type,
				az370_get32(data));
		ret = -EIO;
	}
	kfree(data);
	return ret;
}

static int az370_read_snapshot(struct az370_policy *policies)
{
	int ret;

	ret = az370_get_policy(0, &policies[0]);
	if (ret)
		return ret;
	return az370_get_policy(1, &policies[1]);
}

static bool az370_supported_originals(const struct az370_policy *policies)
{
	int i;

	for (i = 0; i < AZ370_FAN_COUNT; ++i) {
		if (strcmp(policies[i].mode, "AUTO") != 0)
			return false;
		if (strcmp(policies[i].profile, "STANDARD") != 0 &&
		    strcmp(policies[i].profile, "SILENT") != 0)
			return false;
	}
	return true;
}

static int az370_apply_profile(const char *profile)
{
	struct az370_policy original[AZ370_FAN_COUNT];
	struct az370_policy requested[AZ370_FAN_COUNT];
	bool touched[AZ370_FAN_COUNT] = { false, false };
	bool rollback_ok = true;
	char failure_detail[256] = "unknown failure";
	int ret;
	int i;

	if (!az370_board_matches())
		return -ENODEV;
	if (strcmp(profile, "SILENT") != 0 && strcmp(profile, "STANDARD") != 0)
		return -EINVAL;
	ret = az370_read_snapshot(original);
	if (ret || !az370_supported_originals(original))
		return ret ? ret : -EOPNOTSUPP;
	for (i = 0; i < AZ370_FAN_COUNT; ++i) {
		requested[i] = original[i];
		strscpy(requested[i].profile, profile,
			ARRAY_SIZE(requested[i].profile));
	}
	for (i = 0; i < AZ370_FAN_COUNT; ++i) {
		if (az370_policy_equal(&original[i], &requested[i]))
			continue;
		touched[i] = true;
		ret = az370_set_policy(i, &requested[i]);
		if (ret) {
			strscpy(failure_detail, az370.last_detail,
				ARRAY_SIZE(failure_detail));
			goto rollback;
		}
	}
	for (i = 0; i < AZ370_FAN_COUNT; ++i) {
		struct az370_policy observed;

		ret = az370_get_policy(i, &observed);
		if (ret) {
			strscpy(failure_detail, az370.last_detail,
				ARRAY_SIZE(failure_detail));
			goto rollback;
		}
		if (!az370_policy_equal(&observed, &requested[i])) {
			az370_set_detail("readback mismatch fan=%d expected mode=%s "
					 "low_limit=%u profile=%s observed mode=%s "
					 "low_limit=%u profile=%s", i, requested[i].mode,
					 requested[i].low_limit, requested[i].profile,
					 observed.mode, observed.low_limit, observed.profile);
			strscpy(failure_detail, az370.last_detail,
				ARRAY_SIZE(failure_detail));
			ret = ret ? ret : -EIO;
			goto rollback;
		}
	}
	memcpy(az370.snapshot, requested, sizeof(requested));
	az370.snapshot_valid = true;
	snprintf(az370.last_result, sizeof(az370.last_result),
		 "applied %s to changed fan types; readback verified\n", profile);
	return 0;

rollback:
	for (i = 0; i < AZ370_FAN_COUNT; ++i) {
		if (!touched[i])
			continue;
		if (az370_set_policy(i, &original[i]))
			rollback_ok = false;
	}
	/* Read every group after all restores: firmware may update another
	 * group asynchronously while processing a policy request. */
	for (i = 0; i < AZ370_FAN_COUNT; ++i) {
		struct az370_policy observed;
		if (az370_get_policy(i, &observed) ||
		    !az370_policy_equal(&observed, &original[i]))
			rollback_ok = false;
	}
	memcpy(az370.snapshot, original, sizeof(original));
	az370.snapshot_valid = rollback_ok;
	snprintf(az370.last_result, sizeof(az370.last_result),
		 "apply failed (%d); rollback %s; failure=%s\n", ret,
		 rollback_ok ? "verified" : "FAILED", failure_detail);
	return rollback_ok ? ret : -EUCLEAN;
}

static ssize_t az370_status_read(struct file *file, char __user *user,
				 size_t count, loff_t *ppos)
{
	char output[512];
	struct az370_policy policies[AZ370_FAN_COUNT];
	int length;
	int ret;

	if (*ppos)
		return 0;
	mutex_lock(&az370.lock);
	ret = az370_read_snapshot(policies);
	if (!ret) {
		memcpy(az370.snapshot, policies, sizeof(policies));
		az370.snapshot_valid = true;
		length = scnprintf(output, sizeof(output),
			"fan0 mode=%s low_limit=%u profile=%s\n"
			"fan1 mode=%s low_limit=%u profile=%s\n",
			policies[0].mode, policies[0].low_limit, policies[0].profile,
			policies[1].mode, policies[1].low_limit, policies[1].profile);
	} else {
		length = scnprintf(output, sizeof(output), "read failed: %d\n", ret);
	}
	mutex_unlock(&az370.lock);
	return simple_read_from_buffer(user, count, ppos, output, length);
}

static ssize_t az370_snapshot_read(struct file *file, char __user *user,
				   size_t count, loff_t *ppos)
{
	char output[512];
	int length;

	if (*ppos)
		return 0;
	mutex_lock(&az370.lock);
	if (!az370.snapshot_valid)
		length = scnprintf(output, sizeof(output), "no snapshot\n");
	else
		length = scnprintf(output, sizeof(output),
			"fan0 mode=%s low_limit=%u profile=%s\n"
			"fan1 mode=%s low_limit=%u profile=%s\n",
			az370.snapshot[0].mode, az370.snapshot[0].low_limit,
			az370.snapshot[0].profile, az370.snapshot[1].mode,
			az370.snapshot[1].low_limit, az370.snapshot[1].profile);
	mutex_unlock(&az370.lock);
	return simple_read_from_buffer(user, count, ppos, output, length);
}

static ssize_t az370_result_read(struct file *file, char __user *user,
				 size_t count, loff_t *ppos)
{
	ssize_t ret;

	mutex_lock(&az370.lock);
	ret = simple_read_from_buffer(user, count, ppos, az370.last_result,
				      strlen(az370.last_result));
	mutex_unlock(&az370.lock);
	return ret;
}

static ssize_t az370_apply_write(struct file *file, const char __user *user,
				 size_t count, loff_t *ppos)
{
	char command[16] = { 0 };
	int ret;

	if (!count || count >= sizeof(command))
		return -EINVAL;
	if (copy_from_user(command, user, count))
		return -EFAULT;
	command[strcspn(command, "\n\r \t")] = '\0';
	if (strcmp(command, "READ") == 0) {
		struct az370_policy policies[AZ370_FAN_COUNT];
		mutex_lock(&az370.lock);
		ret = az370_read_snapshot(policies);
		if (!ret) {
			memcpy(az370.snapshot, policies, sizeof(policies));
			az370.snapshot_valid = true;
			strscpy(az370.last_result, "read snapshot captured\n",
				ARRAY_SIZE(az370.last_result));
		}
		mutex_unlock(&az370.lock);
		return ret ? ret : count;
	}
	mutex_lock(&az370.lock);
	ret = az370_apply_profile(command);
	mutex_unlock(&az370.lock);
	return ret ? ret : count;
}

static const struct file_operations az370_status_fops = {
	.owner = THIS_MODULE,
	.read = az370_status_read,
	.llseek = default_llseek,
};

static const struct file_operations az370_snapshot_fops = {
	.owner = THIS_MODULE,
	.read = az370_snapshot_read,
	.llseek = default_llseek,
};

static const struct file_operations az370_result_fops = {
	.owner = THIS_MODULE,
	.read = az370_result_read,
	.llseek = default_llseek,
};

static const struct file_operations az370_apply_fops = {
	.owner = THIS_MODULE,
	.read = az370_result_read,
	.write = az370_apply_write,
	.llseek = default_llseek,
};

static int __init az370_init(void)
{
	mutex_init(&az370.lock);
	strscpy(az370.last_result,
		"loaded; no profile change performed\n",
		ARRAY_SIZE(az370.last_result));
	if (!az370_board_matches())
		return -ENODEV;
	az370.root = debugfs_create_dir("asus-z370-wmi-control", NULL);
	if (IS_ERR_OR_NULL(az370.root))
		return az370.root ? PTR_ERR(az370.root) : -ENOMEM;
	debugfs_create_file("status", 0444, az370.root, NULL,
			   &az370_status_fops);
	debugfs_create_file("snapshot", 0444, az370.root, NULL,
			   &az370_snapshot_fops);
	debugfs_create_file("last_result", 0444, az370.root, NULL,
			   &az370_result_fops);
	debugfs_create_file("apply_profile", 0600, az370.root, NULL,
			   &az370_apply_fops);
	return 0;
}

static void __exit az370_exit(void)
{
	debugfs_remove_recursive(az370.root);
}

module_init(az370_init);
module_exit(az370_exit);

MODULE_AUTHOR("Codex");
MODULE_DESCRIPTION("Board-gated ASUS PRIME Z370-P WMI profile controller");
MODULE_LICENSE("GPL");
