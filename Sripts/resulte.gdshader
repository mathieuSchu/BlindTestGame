shader_type canvas_item;

uniform sampler2D pattern_texture;      // brique / forme
uniform sampler2D normal_texture : hint_normal;
uniform float texture_scale = 200.0; // taille réelle du motif en pixels
uniform vec4 base_color : source_color = vec4(1.0);
uniform float contrast = 1.0;
uniform float multiplier = 1.0;

void fragment() {
	// Coordonnées monde (pixel-perfect)
    vec2 world_uv = FRAGCOORD.xy / (texture_scale*multiplier);
		world_uv = mod(world_uv, vec2(1.0));
    // Motif (utilisé comme masque)
    vec4 pattern = texture(pattern_texture, world_uv);
    vec3 final_color  = base_color.rgb * pattern.r * contrast;


    COLOR = vec4(final_color, base_color.a * pattern.a);

    // Normal map pour la lumière
    NORMAL_MAP = texture(normal_texture, world_uv).rgb;
}