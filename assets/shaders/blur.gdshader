shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;

uniform float blur_radius : hint_range(0.0, 50.0) = 1.5;
uniform vec4 tint : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    vec2 texel = SCREEN_PIXEL_SIZE * blur_radius;

    vec4 color = vec4(0.0);

    for (int x = -4; x <= 4; x++) {
        for (int y = -4; y <= 4; y++) {
            color += texture(screen_tex, SCREEN_UV + texel * vec2(float(x), float(y)));
        }
    }

    color /= 81.0;

    // Preserve alpha from the blurred texture
    vec3 tinted_rgb = mix(color.rgb, tint.rgb, tint.a);

    COLOR = vec4(tinted_rgb, color.a);
}