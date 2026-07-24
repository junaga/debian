#version 330 core

in vec2 v_uv;
out vec4 o_color;

uniform sampler2D u_input;
uniform vec2 u_resolution;

void main() {
    vec4 pixel = texture(u_input, v_uv);
    vec2 position = v_uv * u_resolution;

    float scanline = mix(0.82, 1.04, smoothstep(0.15, 0.55, fract(position.y * 0.5)));
    float grille = 0.98 + 0.02 * step(0.45, fract(position.x / 3.0));
    float vignette = 1.0 - smoothstep(0.45, 0.85, distance(v_uv, vec2(0.5))) * 0.10;

    pixel.rgb *= scanline * grille * vignette;
    o_color = pixel;
}
