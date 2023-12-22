shader_type spatial;
render_mode specular_schlick_ggx, async_visible;

uniform sampler2D TextureType : hint_albedo;


// TRIPLANAR FUNCTION GLOBAL CODE
	vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
		vec4 samp = vec4(0.0);
		samp += texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
		samp += texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
		samp += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0)) * p_weights.x;
		return samp;
	}

	const vec3 triplanar_scale = vec3(0.0001, 0.0001, 0.0001);
	uniform vec3 triplanar_offset;
	uniform float triplanar_sharpness = 0.5;

	varying vec3 triplanar_power_normal;
	varying vec3 triplanar_pos;

void vertex() {
// Output:0

	// TRIPLANAR FUNCTION VERTEX CODE
		triplanar_power_normal = pow(abs(NORMAL), vec3(triplanar_sharpness));
		triplanar_power_normal /= dot(triplanar_power_normal, vec3(1.0));
		triplanar_pos = VERTEX * triplanar_scale + triplanar_offset;
		triplanar_pos *= vec3(1.0, -1.0, 1.0);
}

void fragment() {
// TextureUniformTriplanar:6
	vec3 n_out6p0;
	float n_out6p1;
	{
		vec4 n_tex_read = triplanar_texture( TextureType, triplanar_power_normal, triplanar_pos );
		n_out6p0 = n_tex_read.rgb;
		n_out6p1 = n_tex_read.a;
	}

// Output:0
	ALBEDO = n_out6p0;

}

void light() {
// Output:0

}
