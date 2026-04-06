shader_type canvas_item;

uniform vec4 inner_color : source_color;
uniform vec4 outer_color : source_color;
uniform float inner_threshold = 0.36;
uniform float outer_threshold = 0.1;
uniform float soft_edge = 0.0;
uniform sampler2D noise_texture : repeat_enable;
uniform sampler2D gradient_texture : repeat_enable;
uniform float multiplier = 1.0;
uniform vec2 stretch = vec2(1.0, 1.0);

const vec4 transparent = vec4(1.0, 1.0, 1.0, 0.0);

void fragment() {
	vec4 sum_color;
	float mod_time = mod(TIME, 600.0);
	vec2 coord = UV * stretch;
	float noise_value = texture(noise_texture, coord + vec2(0, mod_time)).x;
	float course_noise_value = texture(noise_texture, coord + vec2(0, mod_time) / 2.0).x;
	float gradient_value = texture(gradient_texture, UV.yx).x;

	float combined = noise_value * course_noise_value * gradient_value * multiplier;

	float outer_soft_edge_step = step(outer_threshold - soft_edge, combined);
	float outer_step = step(outer_threshold, combined);
	float inner_soft_edge_step = step(inner_threshold - soft_edge, combined);
	float inner_step = step(inner_threshold, combined);
	float outer_soft_edge_ratio = (combined - (outer_threshold - soft_edge)) / max(soft_edge, 0.0001);
	float inner_soft_edge_ratio = (combined - (inner_threshold - soft_edge)) / max(soft_edge, 0.0001);

	sum_color = transparent;
	sum_color = mix(sum_color, outer_color, outer_soft_edge_step * outer_soft_edge_ratio);
	sum_color = mix(sum_color, outer_color, outer_step);
	sum_color = mix(sum_color, inner_color, inner_soft_edge_step * inner_soft_edge_ratio);
	sum_color = mix(sum_color, inner_color, inner_step);
	sum_color.a *= texture(TEXTURE, UV).a;
	
	COLOR = sum_color;
}