// Subtle CRT post-process for Hyprland's decoration:screen_shader.
// Pairs with kitty/retro-crt.conf: amber phosphor, scanlines, faint flicker.
#version 300 es

precision mediump float;

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

uniform sampler2D tex;
uniform float time;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void main() {
    vec4 pix = texture(tex, v_texcoord);
    vec2 texel = 1.0 / vec2(textureSize(tex, 0));

    vec3 glow = (
        texture(tex, v_texcoord + vec2(texel.x * 1.5, 0.0)).rgb +
        texture(tex, v_texcoord - vec2(texel.x * 1.5, 0.0)).rgb +
        texture(tex, v_texcoord + vec2(0.0, texel.y * 1.5)).rgb +
        texture(tex, v_texcoord - vec2(0.0, texel.y * 1.5)).rgb
    ) * 0.25;

    vec3 color = mix(pix.rgb, max(pix.rgb, glow), 0.045);

    float y = gl_FragCoord.y;
    float scan = 0.93 + 0.07 * smoothstep(0.18, 0.72, fract(y * 0.5));
    float grille = 0.965 + 0.035 * step(0.5, fract(gl_FragCoord.x / 3.0));

    float flicker = 1.0 +
        0.010 * sin(time * 18.0) +
        0.006 * sin(time * 43.0);

    float grain = (hash(gl_FragCoord.xy + vec2(time * 60.0, time * 17.0)) - 0.5) * 0.014;
    float vignette = 1.0 - smoothstep(0.35, 0.82, distance(v_texcoord, vec2(0.5))) * 0.18;

    color *= scan * grille * flicker * vignette;
    color += grain;

    fragColor = vec4(clamp(color, 0.0, 1.0), pix.a);
}
