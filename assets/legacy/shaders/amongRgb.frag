#pragma header

uniform vec3 red;
uniform vec3 green;
uniform vec3 blue;
uniform float visor;

vec3 rgb2hsv(vec3 color) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(color.b, color.g, K.w, K.z), vec4(color.g, color.b, K.x, K.y), step(color.b, color.g));
	vec4 q = mix(vec4(p.x, p.y, p.w, color.r), vec4(color.r, p.y, p.z, p.x), step(p.x, color.r));
	float d = q.x - min(q.w, q.y);
	float e = 0.00001;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

void main() {
	vec4 texColor = texture2D(bitmap, openfl_TextureCoordv);
	
	if (texColor.a == 0.)
	{
		gl_FragColor = vec4(0.);
	}
	else
	{
		bool transform = (openfl_HasColorTransform || hasColorTransform);
		
		texColor.rgb /= texColor.a;
		
		vec3 hsv = rgb2hsv(vec3(texColor.r, texColor.g, texColor.b));
		
		vec4 rgbColor = vec4((texColor.r * red + texColor.g * green + texColor.b * blue) * hsv.y + (1. - hsv.y) * hsv.z, texColor.a);
		if (texColor.g > 0.) rgbColor.b += (visor * ((1 - texColor.g) * (1 - texColor.r) * (1 - texColor.b)) * hsv.z);
		rgbColor = clamp(rgbColor, 0., 1.);
		
		if (transform) rgbColor = (rgbColor * vec4(openfl_ColorMultiplierv.rgb, 1.) + openfl_ColorOffsetv);
		
		gl_FragColor = vec4(rgbColor.rgb * rgbColor.a * openfl_Alphav, rgbColor.a * openfl_Alphav);
	}
}
