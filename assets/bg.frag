extern float r;


// https://medium.com/the-bkpt/dithered-shading-tutorial-29f57d06ac39
const int bayer_n = 4;

mat4 bayer_matrix_4x4 = mat4(
-0.5,0,-0.375,0.125,
0.25,-0.25,0.375,-0.125,
-0.3125,0.1875,-0.4375,0.0625,
0.4375,-0.0625,0.3125,-0.1875);

const int bayer_r = 80;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc) {

  float bayer_value = bayer_matrix_4x4[int(mod(tc.y * 180, bayer_n))][int(mod(tc.x * 320, bayer_n))];

  float res = (1.0-tc.x) * bayer_r * r * 0.6 + 1.2 * bayer_r * bayer_value;

  if (res < bayer_r * 0.5) {
    return vec4(0.0);
  } else {
    return vec4(0.0, 0.0, 0.0, 1.0);
  }

//  vec2 size = vec2(320, 180);
//  vec2 xy = floor(tc*size);
//  return vec4(0.0, 0.0, 0.0, mod(xy.x + xy.y, 2.0));
}
