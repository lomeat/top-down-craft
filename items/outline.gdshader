shader_type canvas_item;

uniform float outline_width : hint_range(0, 10) = 2.0;
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec2 pixel_size = TEXTURE_PIXEL_SIZE;
    vec4 tex_color = texture(TEXTURE, UV);
    
    if (tex_color.a < 0.5) {
        float max_alpha = 0.0;
        
        for (float x = -outline_width; x <= outline_width; x += 1.0) {
            for (float y = -outline_width; y <= outline_width; y += 1.0) {
                if (x != 0.0 || y != 0.0) {
                    vec2 offset = vec2(x, y) * pixel_size;
                    float alpha = texture(TEXTURE, UV + offset).a;
                    if (alpha > max_alpha) max_alpha = alpha;
                }
            }
        }
        
        if (max_alpha > 0.5) {
            COLOR = outline_color;
        } else {
            COLOR = tex_color;
        }
    } else {
        COLOR = tex_color;
    }
}