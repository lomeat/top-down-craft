shader_type canvas_item;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	if (tex_color.a > 0) {
		COLOR = new vec4(1, 1, 1, tex_color.a);
	} else {
		COLOR = vec4(0, 0, 0, 0);
	}
}