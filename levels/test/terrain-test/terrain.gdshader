shader_type canvas_item;
render_mode blend_mix;

uniform vec3 outline_color : source_color = vec3(255.0, 255.0, 255.0);

void fragment() {
	vec2 tex_uv = UV + vec2(cos(UV.x), sin(UV.y * 1.5)) * 0.2;
	COLOR = texture(TEXTURE, tex_uv);
	if (COLOR.a > 0.0)
	{
		
	}
}
