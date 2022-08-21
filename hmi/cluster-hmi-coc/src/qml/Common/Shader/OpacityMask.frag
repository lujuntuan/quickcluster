varying highp vec2 coord;
uniform highp float qt_Opacity;
uniform lowp sampler2D source;
uniform lowp sampler2D maskSource;
uniform lowp int invert;
void main(void) {
    if (invert == 1) {
        gl_FragColor = texture2D(source, coord) * (1.0 - texture2D(maskSource, coord).a) * qt_Opacity;
    } else {
        gl_FragColor = texture2D(source, coord) * (texture2D(maskSource, coord).a) * qt_Opacity;
    }
}
