shader_type canvas_item;

uniform vec4 transparent : hint_color;
uniform vec4 inner_color : hint_color;
uniform vec4 outer_color : hint_color;

uniform float inner_threshold = 0.36;
uniform float outer_threshold = 0.1;
uniform float soft_edge = 0.08;

uniform vec2 center = vec2(0.5, 0.8);

float rand(vec2 coord){
	return fract(sin(dot(coord, vec2(12.9898, 78.233)))* 43758.5453123);
}

float noise(vec2 coord){
	vec2 i = floor(coord);
	vec2 f = fract(coord);

	// 4 corners of a rectangle surrounding our point
	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0));
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));

	vec2 cubic = f * f * (3.0 - 2.0 * f);

	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

float fbm(vec2 coord, int octaves){
	float value = 0.0;
	float scale = 0.5;

	for(int i = 0; i < octaves; i++){
		value += noise(coord) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	return value;
}

float overlay(float base, float top) {
	if (base < 0.5) {
		return 2.0 * base * top;
	} else {
		return 1.0 - 2.0 * (1.0 - base) * (1.0 - top);
	}
}

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
	float fire_s = egg_shape(coord, radius);
	fire_s += egg_shape(coord, radius/2.) / 10.;
	fire_s += egg_shape(coord, radius/4.) / 20.;
	return fire_s;
}

float get_moving_coarse_noise(vec2 coord, float time){
	float noise1 = noise(coord * 6.4 + vec2(time * 0.25, time * 4.0));
	float noise2 = noise(coord * 2. + vec2(time * 0.5, time * 7.0));
	return (noise1 + noise2) / 2.0;
}

float get_moving_fbm_noise(vec2 coord, float time){
	vec2 fbm_coord = coord * 1.6 + vec2(0.0, time * 3.0);
	float fbm_noise = fbm(fbm_coord, 6);
	return overlay(fbm_noise, coord.y);
	
}

void fragment() {

	float fire_shape = get_fire_shape(UV, 0.4);
	float coarse_noise = get_moving_coarse_noise(UV, TIME);
	float fbm_noise = get_moving_fbm_noise(UV, TIME);
	float combined = coarse_noise * fbm_noise * fire_shape;

	if (combined < outer_threshold){
		COLOR = transparent;
	} else if (combined < outer_threshold + soft_edge){
		COLOR = mix(transparent, outer_color, (combined - outer_threshold) / soft_edge);
	} else if (combined < inner_threshold){
		COLOR = outer_color;
	} else if (combined < inner_threshold + soft_edge){
		COLOR = mix(outer_color, inner_color, (combined - inner_threshold) / soft_edge);
	} else {
		COLOR = inner_color;
	}
}