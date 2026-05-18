// Original by KingToot (https://godotshaders.com/author/kingtoot/)

shader_type canvas_item;

// --- Uniforms --- //
uniform bool enabled = true;
uniform bool weighted = true;

void fragment() {
	COLOR.rgb = mix(COLOR.rgb, mix(vec3((COLOR.r + COLOR.g + COLOR.b) / 3.0),  vec3(0.299 * COLOR.r + 0.587 * COLOR.g + 0.114 * COLOR.b), float(weighted)), float(enabled));;
}