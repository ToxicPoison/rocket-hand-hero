shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float offset = 3.0;
uniform vec3 line_color : source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 light_color : source_color = vec3(1.0, 1.0, 1.0);
uniform vec2 light_dir = vec2(0.0, -1.0);

void fragment() {
	
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);
	
	if (c.a > 0.0001) {
		c.rgb /= c.a;
	}

	COLOR *= c;
	if (COLOR.a > 0.0001) {
		vec4 c_light = textureLod(screen_texture, SCREEN_UV + vec2(textureSize(screen_texture, 0).yx) * light_dir * 0.00005, 0.0);
		if (c_light.a < 0.9)
		{
			COLOR += vec4(light_color, 0.0);
		}
		
		
		float c_offsetx = textureLod(screen_texture, SCREEN_UV + vec2(float(textureSize(screen_texture, 0).y), 0.0) * 0.0001 * offset * 0.01, 0.0).a;
		float c_offsety = textureLod(screen_texture, SCREEN_UV + vec2(0.0, float(textureSize(screen_texture, 0).x)) * 0.0001 * offset * 0.01, 0.0).a;
		float c_offsetnx = textureLod(screen_texture, SCREEN_UV + vec2(-float(textureSize(screen_texture, 0).y), 0.0) * 0.0001 * offset * 0.01, 0.0).a;
		float c_offsetny = textureLod(screen_texture, SCREEN_UV + vec2(0.0, -float(textureSize(screen_texture, 0).x)) * 0.0001 * offset * 0.01, 0.0).a;
		float area = clamp(c_offsetx * c_offsety * c_offsetnx * c_offsetny, 0.0, 1.0);
		
		if (area < 0.9)
		{
			COLOR = vec4(line_color, 1.0);
		}
		
		
	}
	
}
