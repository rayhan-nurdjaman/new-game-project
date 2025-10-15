shader_type spatial;
render_mode unshaded, blend_mix;

uniform sampler2D viewport_texture: source_color;
uniform vec4 clip_plane = vec4(0, 1, 0, 0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 albedo_tex = texture(viewport_texture, SCREEN_UV);
	ALBEDO = albedo_tex.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
