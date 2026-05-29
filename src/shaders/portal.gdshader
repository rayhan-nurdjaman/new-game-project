shader_type spatial;
render_mode unshaded, blend_mix, cull_front;

uniform sampler2D viewport_texture: source_color;
uniform vec4 clip_plane = vec4(0, 1, 0, 0);

varying float depth;

void vertex() {
	depth = VERTEX.z;
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 albedo_tex = texture(viewport_texture, SCREEN_UV);
	ALBEDO = albedo_tex.rgb;
	//ALPHA = 1.0;
	ALPHA = clamp(1.0 - (depth + 0.5), 0.0, 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
