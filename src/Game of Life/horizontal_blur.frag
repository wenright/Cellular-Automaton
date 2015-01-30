extern number r;
extern number w;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc) {
	color = vec4(0);
	vec2 s;

	for (float x = -r; x <= r; x++) {
		s.xy = vec2(x / w, 0);
		color += Texel(tex, tc + s);
	}
	return color / (2.0 * r + 1.0);
}