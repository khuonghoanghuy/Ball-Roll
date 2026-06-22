#pragma header

uniform vec2 enabled;
uniform vec2 mouseFocusPoint;

void main() {
  float redOffset   =  0.002;
  float greenOffset =  0.001;
  float blueOffset  = -0.001;

  vec2 texCoord = openfl_TextureCoordv;

  vec2 direction = texCoord - mouseFocusPoint;

  vec4 finalColor = flixel_texture2D(bitmap, texCoord);

  if (enabled.x != 1.0) { 
    gl_FragColor = finalColor;
    return; 
  }

  finalColor.r = flixel_texture2D(bitmap, texCoord + (direction * vec2(redOffset  ))).r;
  finalColor.g = flixel_texture2D(bitmap, texCoord + (direction * vec2(greenOffset))).g;
  finalColor.b = flixel_texture2D(bitmap, texCoord + (direction * vec2(blueOffset ))).b;

  gl_FragColor = finalColor;
}