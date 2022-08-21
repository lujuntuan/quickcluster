varying highp vec2 coord;
uniform highp float qt_Opacity;

uniform lowp float width;
uniform lowp float height;
uniform lowp vec2 centerPoint;
uniform lowp float startAngle;
uniform lowp float stopAngle;
uniform lowp float smoothRadius;
uniform lowp sampler2D image;

void main() {
    lowp vec4 tex = vec4(0.0,0.0,0.0,0.0);
    lowp float coordAngle=-degrees(atan(-(coord.y*height-centerPoint.y)/(coord.x*width-centerPoint.x)));
    if(coord.x*width<centerPoint.x){
        coordAngle+=180.0;
    }else if(coord.y*height<centerPoint.y){
        coordAngle+=360.0;
    }
    lowp float startOffset=coordAngle-startAngle;
    lowp float stopOffset=stopAngle-coordAngle;
    if(stopOffset>360.0){
        startOffset=stopOffset-360.0;
    }
    if(startOffset>360.0){
        stopOffset=startOffset-360.0;
    }
    if(startOffset>=0.0&&stopOffset>=0.0){
        if(startOffset<=smoothRadius){
            tex=texture2D(image, coord)*startOffset/smoothRadius;
        }else if(stopOffset<=smoothRadius){
            tex=texture2D(image, coord)*stopOffset/smoothRadius;
        }else{
            tex=texture2D(image, coord);
        }
    }
    gl_FragColor = tex*qt_Opacity;
}
