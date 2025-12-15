shader_type canvas_item;
uniform float radius = 64.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV - vec2(0.5);
    float dist = length(uv * radius * 2.0);
	if (dist > radius) {
        discard; // invisible
    }
    COLOR = texture(TEXTURE, UV-vec2(0));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
