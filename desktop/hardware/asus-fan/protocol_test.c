#include <stdio.h>
#include "protocol.h"

static int expect(int condition, const char *message)
{
	if (!condition)
		fprintf(stderr, "FAIL: %s\n", message);
	return condition ? 0 : 1;
}

int main(void)
{
	AZ370_U8 buf[AZ370_MAX_DFAN_INPUT];
	struct az370_policy policy;
	size_t length = 0;
	int failures = 0;

	failures += expect(az370_pack_dfan(buf, sizeof(buf), 0, "AUTO", 200,
					   "SILENT", &length) == 0,
					"DFAN packing succeeds");
	/* Golden wire bytes: FanType, padding, counted AUTO\0, padding,
	 * LowLimit, counted SILENT\0. Both terminators belong to the counts. */
	const AZ370_U8 expected[] = {
		0,0,10,0,'A',0,'U',0,'T',0,'O',0,0,0,0,0,
		200,0,0,0,14,0,'S',0,'I',0,'L',0,'E',0,'N',0,'T',0,0,0
	};
	failures += expect(length == sizeof(expected) &&
		memcmp(buf, expected, sizeof(expected)) == 0,
		"DFAN matches counted-terminated WMI golden packet");

	/* Equivalent to the observed GFAN response: AUTO, 200, STANDARD. */
	memset(buf, 0, sizeof(buf));
	az370_put32(buf, 0);
	az370_put16(buf + 4, 8);
	memcpy(buf + 6, "A\0U\0T\0O\0", 8);
	az370_put16(buf + 14, 0);
	az370_put32(buf + 16, 200);
	az370_put16(buf + 20, 16);
	memcpy(buf + 22, "S\0T\0A\0N\0D\0A\0R\0D\0", 16);
	az370_put16(buf + 38, 0);
	failures += expect(az370_parse_policy(buf, 40, &policy) == 0,
					"GFAN response parses");
	failures += expect(strcmp(policy.mode, "AUTO") == 0 &&
				   policy.low_limit == 200 &&
				   strcmp(policy.profile, "STANDARD") == 0,
				   "GFAN fields decode correctly");
	az370_put32(buf + 16, 0);
	failures += expect(az370_parse_policy(buf, 40, &policy) == 0 &&
				   policy.low_limit == 0,
				   "zero low limit is retained");
	az370_put16(buf + 4, 0xffff);
	failures += expect(az370_parse_policy(buf, 40, &policy) == -EIO,
				   "malformed string length is rejected");
	az370_put16(buf + 4, 8);
	az370_put32(buf, 7);
	failures += expect(az370_parse_policy(buf, 40, &policy) == -EIO,
				   "firmware error code is rejected");
	return failures != 0;
}
