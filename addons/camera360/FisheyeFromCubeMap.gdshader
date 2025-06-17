shader_type canvas_item;

uniform sampler2D ForwardTexture;
uniform sampler2D LeftTexture;
uniform sampler2D BackTexture;
uniform sampler2D RightTexture;
uniform sampler2D TopTexture;
uniform sampler2D BottomTexture;

// Important : Fisheye expects incoming textures to be SQUARE.

void fragment() {
	vec3 dir = vec3(0.0);
	float dx = UV.x - 0.5;
	float dy = (1.0 - UV.y) - 0.5;
	float d = sqrt((dx * dx) + (dy * dy));

	if (d > 0.5) {
		discard;
	}

	// we sample 90 deg angle (rot_z = [0, PI/2]) all around (rot_y = [0, 2PI]
	float rot_y = (atan(dy, dx)) + PI;
	float rot_z = (PI * (0.5 - d)) - PI / 2.0;

	dir.x = sin(rot_z) * sin(rot_y);
	dir.y = cos(rot_z);
	dir.z = sin(rot_z) * cos(rot_y);

vec3 abs_dir = abs(dir);
	if ((abs_dir.x > abs_dir.y) && (abs_dir.x > abs_dir.z)) {
		// X is biggest, use forward
		float ma = 0.5 / abs_dir.x;
		vec2 uv = -dir.zy * ma + 0.5;
		if (dir.x >= 0.0) {
			COLOR = texture(BackTexture, uv);
		} else {
			COLOR = texture(ForwardTexture, vec2(1.0 - uv.x, uv.y));
		}
	} else if (abs_dir.y > abs_dir.z) {
		// Y is biggest
		float ma = 0.5 / abs_dir.y * -1.0;
		vec2 uv = dir.xz * ma + 0.5;
		if (dir.y >= 0.0) {
			COLOR = texture(TopTexture, uv);
		} else {
			COLOR = texture(BottomTexture, vec2(1.0 - uv.x, uv.y));
		}
	} else {
		// Z is biggest
		float ma = 0.5 / abs_dir.z * -1.0;
		vec2 uv = dir.xy * ma + 0.5;
		if (dir.z >= 0.0) {
			COLOR = texture(RightTexture, vec2(1.0 - uv.x, uv.y));
		} else {
			COLOR = texture(LeftTexture, uv);
		}
	}

	// Debug checks
	// COLOR = vec4(1.0, 0.0, 0.0, 1.0) * (rot_y / (2.0 * PI));
	// COLOR = vec4(0.0, 1.0 - UV.y, 0.0, 1.0);
}
