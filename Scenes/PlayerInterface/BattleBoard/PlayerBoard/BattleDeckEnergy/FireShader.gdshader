shader_type canvas_item;

uniform sampler2D noise_texture : repeat_enable;
uniform vec4 inner_color : source_color;
uniform vec4 outer_color : source_color;
uniform float multiplier = 1.0;

uniform vec2 stretch = vec2(1.0, 1.0);
uniform float inner_threshold = 0.36;
uniform float outer_threshold = 0.1;
uniform float soft_edge = 0.08;

uniform vec2 center = vec2(0.5, 0.8);

const vec4 transparent = vec4(1.0, 1.0, 1.0, 0.0);

float egg_shape(vec2 coord, float radius){
	vec2 diff = abs(coord - center);

	if (coord.y < center.y){
		diff.y /= 2.0;
	} else {
		diff.y *= 2.0;
	}

	float dist = sqrt(diff.x * diff.x + diff.y * diff.y) / radius;
	float value = sqrt(1.0 - dist * dist);
	return clamp(value, 0.0, 1.0);
}

float get_fire_shape(vec2 coord, float radius){
	float fire_s = egg_shape(coord, radius*0.5) * 0.75;
	fire_s += egg_shape(coord, radius*0.75) * 0.5;
	fire_s += egg_shape(coord, radius) * 0.25;
	return fire_s;
}
void fragment() {
	vec4 sum_color;
	float mod_time = mod(TIME, 600.0);
	vec2 coord = UV * stretch;
	float noise_value = texture(noise_texture, coord + vec2(0, mod_time)).x;
	float course_noise_value = texture(noise_texture, coord + vec2(0, mod_time) / 2.0).x;
	float shape_value = get_fire_shape(UV, 0.4);

	float combined = course_noise_value * noise_value * shape_value * multiplier;

	float outer_soft_edge_step = step(outer_threshold - soft_edge, combined);
	float outer_step = step(outer_threshold, combined);
	float inner_soft_edge_step = step(inner_threshold - soft_edge, combined);
	float inner_step = step(inner_threshold, combined);
	float outer_soft_edge_ratio = (combined - (outer_threshold - soft_edge)) / soft_edge;
	float inner_soft_edge_ratio = (combined - (inner_threshold - soft_edge)) / soft_edge;

	sum_color = transparent;
	sum_color = mix(sum_color, outer_color, outer_soft_edge_step * outer_soft_edge_ratio);
	sum_color = mix(sum_color, outer_color, outer_step);
	sum_color = mix(sum_color, inner_color, inner_soft_edge_step * inner_soft_edge_ratio);
	sum_color = mix(sum_color, inner_color, inner_step);
	//sum_color.a *= texture(TEXTURE, UV).a;
	
	COLOR = sum_color;
}