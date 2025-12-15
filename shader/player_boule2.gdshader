shader_type canvas_item;
uniform sampler2D albedo;
uniform sampler2D normal_map;
uniform float light_strength = 1.0;
uniform float normal_strength : hint_range(0.0, 4.0) = 1.0;

void fragment() {
    vec4 color = texture(albedo, UV);
    //NORMAL_MAP = texture(normal_map, UV).rgb;
	
	vec3 n = texture(normal_map, UV).rgb;
    n = n * 2.0 - 1.0;      // [0..1] → [-1..1]

    n.xy *= normal_strength;

    NORMAL_MAP = n;
	
	
    COLOR = color;
}
