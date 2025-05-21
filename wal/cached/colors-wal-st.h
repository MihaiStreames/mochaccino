const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#0F122D", /* black   */
  [1] = "#2d324e", /* red     */
  [2] = "#393755", /* green   */
  [3] = "#6f4a57", /* yellow  */
  [4] = "#492373", /* blue    */
  [5] = "#392f84", /* magenta */
  [6] = "#3f3b71", /* cyan    */
  [7] = "#94959e", /* white   */

  /* 8 bright colors */
  [8]  = "#616277",  /* black   */
  [9]  = "#3C4368",  /* red     */
  [10] = "#4D4A72", /* green   */
  [11] = "#956375", /* yellow  */
  [12] = "#622F9A", /* blue    */
  [13] = "#4D3FB1", /* magenta */
  [14] = "#554F97", /* cyan    */
  [15] = "#c3c3ca", /* white   */

  /* special colors */
  [256] = "#0F122D", /* background */
  [257] = "#c3c3ca", /* foreground */
  [258] = "#c3c3ca",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
