shader_type canvas_item;

uniform vec4 chroma_key : source_color = vec4(0.6039, 0.2275, 0.4157, 1.0);
uniform float tolerance : hint_range(0.0, 1.0) = 0.15;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    // Calculate distance in RGB space to our chroma key color
    if (distance(tex_color.rgb, chroma_key.rgb) < tolerance) {
        // Discard the pixel (make it transparent)
        discard;
    }
}
