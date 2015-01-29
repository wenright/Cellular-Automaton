extern number radius;
extern number width;
extern number height;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc) {
	color = vec4(0);
	vec2 s;

	for (float x = -radius; x <= radius; x++) {
		for (float y = -radius; y <= radius; y++) {
			s.xy = vec2(x / width, y / height);
			color += Texel(tex, tc + s);
		}
	}
	return color / ((2.0 * radius + 1.0) * (2.0 * radius + 1.0));
}