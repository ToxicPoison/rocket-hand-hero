shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float offset = 2.5;
uniform vec3 line_color : source_color = vec3(0.9, 0.9, 0.9);

void fragment() {
	
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);
	
	if (c.a > 0.0001) {
		c.rgb /= c.a;
	}

	COLOR *= c;
	if (COLOR.a > 0.0001) {
		vec4 c_offsetx = textureLod(screen_texture, SCREEN_UV + vec2(float(textureSize(screen_texture, 0).y), 0.0) * 0.0001 * offset * 0.01, 0.0);
		vec4 c_offsety = textureLod(screen_texture, SCREEN_UV + vec2(0.0, float(textureSize(screen_texture, 0).x)) * 0.0001 * offset * 0.01, 0.0);
		vec4 c_offsetnx = textureLod(screen_texture, SCREEN_UV + vec2(-float(textureSize(screen_texture, 0).y), 0.0) * 0.0001 * offset * 0.01, 0.0);
		vec4 c_offsetny = textureLod(screen_texture, SCREEN_UV + vec2(0.0, -float(textureSize(screen_texture, 0).x)) * 0.0001 * offset * 0.01, 0.0);
		float area = clamp(c_offsetx.a * c_offsety.a * c_offsetnx.a * c_offsetny.a, 0.0, 1.0);
		
		if (area < 0.9)
		{
			COLOR = vec4(line_color, 1.0);
		}
		
		vec4 c_light = textureLod(screen_texture, SCREEN_UV + vec2(0.0, -float(textureSize(screen_texture, 0).x)) * 0.00001, 0.0);
		if (c_light.a < 0.9)
		{
			COLOR += vec4(0.5, 0.5, 0.5, 0.0);
		}
		
	}
	
}
