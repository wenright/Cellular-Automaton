extern number r;
extern number h;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc) {
	color = vec4(0);
	vec2 s;

	for (float y = -r; y <= r; y++) {
		s.xy = vec2(0, y / h);
		color += Texel(tex, tc + s);
	}
	return color / (2.0 * r + 1.0);
}