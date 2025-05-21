static const char norm_fg[] = "#c3c3ca";
static const char norm_bg[] = "#0F122D";
static const char norm_border[] = "#616277";

static const char sel_fg[] = "#c3c3ca";
static const char sel_bg[] = "#2d324e";
static const char sel_border[] = "#c3c3ca";

static const char *colors[][3]      = {
    /*               fg           bg         border                         */
    [SchemeNorm] = { norm_fg,     norm_bg,   norm_border }, // unfocused wins
    [SchemeSel]  = { sel_fg,      sel_bg,    sel_border },  // the focused win
};
