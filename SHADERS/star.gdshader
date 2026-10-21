shader_type canvas_item;

// Unlit + additive blending for glow stacking
render_mode unshaded, blend_add;

/* -------- Controls (no type hints) -------- */
uniform vec4 core_color   = vec4(1.00, 0.97, 0.85, 1.0); // bright white-yellow
uniform vec4 corona_color = vec4(1.00, 0.85, 0.35, 1.0); // warm halo

uniform float core_radius     = 0.22;  // inner bright disk, 0..1 (UV units)
uniform float corona_radius   = 0.90;  // outer halo extent
uniform float corona_softness = 1.00;  // halo falloff softness (>=0.1 recommended)

uniform float flare_strength  = 0.65;  // intensity of spikes
uniform float flare_sharpness = 14.0;  // higher = thinner spikes
uniform float flare_decay     = 10.0;  // radial fade of spikes

uniform float twinkle_amount  = 0.08;  // 0..0.5 typical
uniform float twinkle_speed   = 0.60;  // animation speed
uniform float noise_scale     = 60.0;  // spatial scale of noise

uniform bool use_texture_mask = true;  // use sprite alpha as a mask

/* -------- Helpers -------- */
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise2d(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
    vec4 base = texture(TEXTURE, UV);
    float alpha_mask = use_texture_mask ? base.a : 1.0;

    vec2 center = vec2(0.5);
    vec2 pos = UV - center;
    float r = length(pos);
    float angle = atan(pos.y, pos.x);

    // --- Core & Corona ---
    float core = 1.0 - smoothstep(core_radius, core_radius + 0.02, r);

    float corona = 1.0 - smoothstep(core_radius, corona_radius, r);
    corona = pow(max(corona, 0.0), max(corona_softness, 0.1));

    // --- Directional spikes (axes + diagonals) ---
    float axes      = pow(abs(cos(angle * 2.0)), max(flare_sharpness, 1.0));
    float diagonals = pow(abs(sin(angle * 2.0)), max(flare_sharpness, 1.0));
    float spikes    = (axes + 0.5 * diagonals) * flare_strength * exp(-r * flare_decay);

    // --- Twinkle ---
    float twinkle = 1.0 + twinkle_amount * (noise2d(UV * noise_scale + vec2(TIME * twinkle_speed)) - 0.5);

    // --- Compose ---
    vec3 base_star = mix(corona_color.rgb, core_color.rgb, core);
    float brightness = core + corona;
    vec3 color = base_star * brightness + spikes * corona_color.rgb;
    color *= twinkle;

    float alpha = clamp((brightness + spikes) * alpha_mask, 0.0, 1.0);
    COLOR = vec4(color, alpha);
}