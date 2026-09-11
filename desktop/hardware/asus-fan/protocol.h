/* SPDX-License-Identifier: GPL-2.0-only */
#ifndef ASUS_Z370_WMI_PROTOCOL_H
#define ASUS_Z370_WMI_PROTOCOL_H

#ifdef __KERNEL__
#include <linux/byteorder/generic.h>
#include <linux/errno.h>
#include <linux/kernel.h>
#include <linux/string.h>
#include <linux/types.h>
#define AZ370_U8 u8
#define AZ370_U16 u16
#define AZ370_U32 u32
#define AZ370_LE16 __le16
#define AZ370_LE32 __le32
#define AZ370_ERR(x) (-(x))
#else
#include <errno.h>
#include <stdint.h>
#include <string.h>
#define AZ370_U8 uint8_t
#define AZ370_U16 uint16_t
#define AZ370_U32 uint32_t
#define AZ370_LE16 uint16_t
#define AZ370_LE32 uint32_t
#define AZ370_ERR(x) (-(x))
#endif

#define AZ370_GFAN 0x4746414e /* GetFanPolicy */
#define AZ370_DFAN 0x4446414e /* SetFanPolicy */
#define AZ370_GFCV 0x47464356 /* GetManualFanCurve */
#define AZ370_DFCV 0x44464356 /* SetManualFanCurve */
#define AZ370_MAX_TEXT 16
#define AZ370_MAX_DFAN_INPUT 96

struct az370_policy {
	char mode[AZ370_MAX_TEXT];
	AZ370_U32 low_limit;
	char profile[AZ370_MAX_TEXT];
};

static inline size_t az370_align(size_t offset, size_t alignment)
{
	return (offset + alignment - 1) & ~(alignment - 1);
}

static inline void az370_put16(AZ370_U8 *p, AZ370_U16 value)
{
#ifdef __KERNEL__
	*(__le16 *)p = cpu_to_le16(value);
#else
	p[0] = value & 0xff;
	p[1] = value >> 8;
#endif
}

static inline AZ370_U16 az370_get16(const AZ370_U8 *p)
{
#ifdef __KERNEL__
	return le16_to_cpu(*(__le16 *)p);
#else
	return (AZ370_U16)p[0] | ((AZ370_U16)p[1] << 8);
#endif
}

static inline void az370_put32(AZ370_U8 *p, AZ370_U32 value)
{
#ifdef __KERNEL__
	*(__le32 *)p = cpu_to_le32(value);
#else
	p[0] = value & 0xff;
	p[1] = (value >> 8) & 0xff;
	p[2] = (value >> 16) & 0xff;
	p[3] = value >> 24;
#endif
}

static inline AZ370_U32 az370_get32(const AZ370_U8 *p)
{
#ifdef __KERNEL__
	return le32_to_cpu(*(__le32 *)p);
#else
	return (AZ370_U32)p[0] | ((AZ370_U32)p[1] << 8) |
	       ((AZ370_U32)p[2] << 16) | ((AZ370_U32)p[3] << 24);
#endif
}

/* WMI strings store byte length followed by counted UTF-16LE data.
 * Include the optional terminator IN the count for firmware C-string consumers. */
static inline int az370_put_string(AZ370_U8 *buf, size_t capacity,
				   size_t *offset, const char *value)
{
	size_t at = az370_align(*offset, 2);
	size_t chars = strlen(value);
	size_t bytes;
	size_t i;

	if (chars >= AZ370_MAX_TEXT)
		return AZ370_ERR(EINVAL);
	bytes = (chars + 1) * 2;
	if (bytes > 0xffff || at + 2 + bytes > capacity)
		return AZ370_ERR(ENOSPC);
	az370_put16(buf + at, bytes);
	for (i = 0; i < chars; ++i)
		az370_put16(buf + at + 2 + i * 2, (AZ370_U8)value[i]);
	az370_put16(buf + at + 2 + chars * 2, 0);
	*offset = az370_align(at + 2 + bytes, 2);
	return 0;
}

static inline int az370_get_string(const AZ370_U8 *buf, size_t length,
				   size_t *offset, char *value)
{
	size_t at = az370_align(*offset, 2);
	size_t bytes;
	size_t chars;
	size_t i;

	if (at + 2 > length)
		return AZ370_ERR(EIO);
	bytes = az370_get16(buf + at);
	if ((bytes & 1) || bytes > (AZ370_MAX_TEXT - 1) * 2 ||
	    at + 2 + bytes > length)
		return AZ370_ERR(EIO);
	chars = bytes / 2;
	for (i = 0; i < chars; ++i) {
		AZ370_U16 c = az370_get16(buf + at + 2 + i * 2);
		if (c > 0x7f)
			return AZ370_ERR(EILSEQ);
		value[i] = (char)c;
	}
	value[chars] = '\0';
	at += 2 + bytes;
	*offset = az370_align(at, 2);
	return 0;
}

static inline int az370_pack_dfan(AZ370_U8 *buf, size_t capacity,
				  AZ370_U8 fan_type, const char *mode,
				  AZ370_U32 low_limit, const char *profile,
				  size_t *length)
{
	size_t offset = 0;
	int ret;

	if (capacity < 2)
		return AZ370_ERR(ENOSPC);
	memset(buf, 0, capacity);
	buf[offset++] = fan_type;
	ret = az370_put_string(buf, capacity, &offset, mode);
	if (ret)
		return ret;
	offset = az370_align(offset, 4);
	if (offset + 4 > capacity)
		return AZ370_ERR(ENOSPC);
	az370_put32(buf + offset, low_limit);
	offset += 4;
	ret = az370_put_string(buf, capacity, &offset, profile);
	if (ret)
		return ret;
	*length = offset;
	return 0;
}

static inline int az370_parse_policy(const AZ370_U8 *buf, size_t length,
				     struct az370_policy *policy)
{
	size_t offset = 4;
	int ret;

	if (length < 4)
		return AZ370_ERR(EIO);
	if (az370_get32(buf) != 0)
		return AZ370_ERR(EIO);
	ret = az370_get_string(buf, length, &offset, policy->mode);
	if (ret)
		return ret;
	offset = az370_align(offset, 4);
	if (offset + 4 > length)
		return AZ370_ERR(EIO);
	policy->low_limit = az370_get32(buf + offset);
	offset += 4;
	return az370_get_string(buf, length, &offset, policy->profile);
}

static inline int az370_policy_equal(const struct az370_policy *a,
				     const struct az370_policy *b)
{
	return a->low_limit == b->low_limit &&
	       strcmp(a->mode, b->mode) == 0 &&
	       strcmp(a->profile, b->profile) == 0;
}

#endif
