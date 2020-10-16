shader_type canvas_item;

uniform vec4 transparent : hint_color;
uniform vec4 inner_color : hint_color;
uniform vec4 outer_color : hint_color;

uniform vec2 stretch = vec2(1.0, 1.0);
uniform float inner_threshold = 0.36;
uniform float outer_threshold = 0.1;
uniform float soft_edge = 0.08;

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

float get_moving_coarse_noise(vec2 coord, float time){
	float noise1 = noise(coord * 6.4 + vec2(time * 0.1, time * 1.0));
	float noise2 = noise(coord * 2. + vec2(time * 0.3, time * 3.0));
	return (noise1 + noise2) / 2.0;
}

float get_moving_fbm_noise(vec2 coord, float time){
	vec2 fbm_coord = coord * 1.6 + vec2(0.0, time * 1.0);
	float fbm_noise = fbm(fbm_coord, 6);
	return overlay(fbm_noise, coord.y);
	
}

void fragment() {
	vec4 sum_color;
	float mod_time = mod(TIME, 600.0);
	vec2 coord = UV * stretch;
	float coarse_noise = get_moving_coarse_noise(coord, mod_time);
	float fbm_noise = get_moving_fbm_noise(coord, mod_time);
	float combined = coarse_noise * fbm_noise;

	if (combined < outer_threshold){
		sum_color = transparent;
	} else if (combined < outer_threshold + soft_edge){
		sum_color = mix(transparent, outer_color, (combined - outer_threshold) / soft_edge);
	} else if (combined < inner_threshold){
		sum_color = outer_color;
	} else if (combined < inner_threshold + soft_edge){
		sum_color = mix(outer_color, inner_color, (combined - inner_threshold) / soft_edge);
	} else {
		sum_color = inner_color;
	}
	sum_color.a *= texture(TEXTURE, UV).a;
	
	COLOR = sum_color;
}