/* Taken from https://github.com/djpohly/dwl/issues/466 */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }

static const float rootcolor[]             = COLOR(0x0F122Dff);
static uint32_t colors[][3]                = {
	/*               fg          bg          border    */
	[SchemeNorm] = { 0xc3c3caff, 0x0F122Dff, 0x616277ff },
	[SchemeSel]  = { 0xc3c3caff, 0x393755ff, 0x2d324eff },
	[SchemeUrg]  = { 0xc3c3caff, 0x2d324eff, 0x393755ff },
};
