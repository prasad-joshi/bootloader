#include <stdio.h>
#include <stdint.h>
#include <string.h>

int hex_to_string(uint32_t h, char *hs, size_t sz)
{
	int      c;
	int      b;
	uint32_t t;

	t = h;
	c = 0;
	while (t) {
		t >>= 4;
		c++;
	}

	if (c >= sz) {
		return -1;
	}

	hs[c] = 0;
	c--;

	while (c >= 0 && h > 0x0) {
		b = h & 0xf;
		if (b >= 0 && b <= 0x9) {
			hs[c] = '0' + b;
		} else if (b >= 0xA && b <= 0xf) {
			hs[c] = 'A' + (b - 0xA);
		}
		h = h >> 4;
		c--;
	}

	return 0;
}

int main()
{
	uint32_t h = 0x56A;
	char     hs[9];

	hex_to_string(h, hs, sizeof(hs));

	printf("hex = %x\n", h);
	printf("str = %s\n", hs);

	return 0;
}
