shader_type canvas_item;

uniform vec4 dark_tint : source_color = vec4(0.18, 0.32, 0.30, 1.0);
uniform vec4 light_tint : source_color = vec4(0.97, 0.93, 0.72, 1.0);

uniform float tint_strength : hint_range(0.0, 1.0) = 1.0;
uniform float contrast : hint_range(0.2, 3.0) = 1.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    float lum = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
    float t = pow(clamp(lum, 0.0, 1.0), contrast);

    vec3 tint = mix(dark_tint.rgb, light_tint.rgb, t);

    // Preserve the original brightness
    float original_brightness = max(max(tex.r, tex.g), tex.b);
    tint *= original_brightness / max(max(tint.r, tint.g), max(tint.b, 0.001));

    vec3 final_color = mix(tex.rgb, tint, tint_strength);

    COLOR = vec4(final_color, tex.a);
}