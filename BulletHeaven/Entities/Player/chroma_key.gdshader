shader_type canvas_item;

uniform vec4 chroma_key : source_color = vec4(0.6039, 0.2275, 0.4157, 1.0);
uniform float tolerance : hint_range(0.0, 1.0) = 0.15;
uniform float edge_softness : hint_range(0.0, 0.2) = 0.05;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float dist = distance(tex_color.rgb, chroma_key.rgb);
    if (dist < tolerance) {
        discard;
    } else if (dist < tolerance + edge_softness) {
        // Smooth alpha falloff at chroma boundary to kill fringe pixels
        float alpha = smoothstep(tolerance, tolerance + edge_softness, dist);
        COLOR = vec4(tex_color.rgb, tex_color.a * alpha);
    } else {
        COLOR = tex_color;
    }
}
