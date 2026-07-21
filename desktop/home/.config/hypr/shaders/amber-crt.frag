// CRT post-process for Hyprland's decoration:screen_shader.
// Pairs with kitty/retro-crt.conf: amber phosphor, visible scanlines,
// soft bloom, aperture grille, phosphor grain, and vignette.
#version 300 es

precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
uniform vec2 fullSize;

layout(location = 0) out vec4 fragColor;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    vec2 size = max(fullSize, vec2(1.0));
    vec2 px = v_texcoord * size;
    vec2 pixel = 1.0 / size;

    vec4 pix = texture(tex, v_texcoord);

    // Small horizontal phosphor smear. Bright cells bloom, dark cells stay dark.
    vec3 bloom = (
        texture(tex, v_texcoord + vec2(pixel.x * 1.25, 0.0)).rgb +
        texture(tex, v_texcoord - vec2(pixel.x * 1.25, 0.0)).rgb +
        texture(tex, v_texcoord + vec2(pixel.x * 2.50, 0.0)).rgb +
        texture(tex, v_texcoord - vec2(pixel.x * 2.50, 0.0)).rgb
    ) * 0.25;
    float luma = dot(pix.rgb, vec3(0.299, 0.587, 0.114));
    vec3 color = mix(pix.rgb, max(pix.rgb, bloom), 0.11 * smoothstep(0.18, 0.85, luma));

    // 2-pixel raster: one darker phosphor row, one brighter row.
    float scanPhase = fract(px.y * 0.5);
    float scanline = mix(0.58, 1.08, smoothstep(0.16, 0.56, scanPhase));

    // Very light triad variation; enough to feel like glass, not enough to ruin UI.
    float grille = 0.955 + 0.045 * step(0.45, fract(px.x / 3.0));

    // Static phosphor grain. Animated flicker needs Hyprland damage tracking
    // disabled, which is too expensive for a daily desktop shader.
    float grain = (hash(floor(px * 0.75)) - 0.5) * 0.018;
    float vignette = 1.0 - smoothstep(0.35, 0.82, distance(v_texcoord, vec2(0.5))) * 0.18;

    // Slight amber glass bias that complements the Kitty monochrome palette.
    color *= vec3(1.035, 1.0, 0.92);
    color *= scanline * grille * vignette;
    color += grain;

    fragColor = vec4(clamp(color, 0.0, 1.0), pix.a);
}
