extends Node2D

@onready var wheel : ColorRect = $Wheel

@export var num_sections: int = 6     # nombre de catégories
@export var radius: float = 200.0     # taille de la roue
@export var labels: Array = ["A", "B", "C", "D", "E", "F"] # noms des sections
@export var colors: Array = [] # couleurs (auto si vide)
@export var pointer_angle: float = -90.0      # Angle où pointe la flèche (0 = haut)

var angle_per_section: float
var angle_per_section_deg: float
var spinning: bool = false

func _ready():
	angle_per_section_deg = 360 / num_sections
	angle_per_section = 2 * PI / num_sections
	if colors.is_empty():
		colors = _generate_colors(num_sections)
	_draw_wheel()
	


func _draw_wheel():
	var childs_wheel=wheel.get_children()# on nettoie pour redessiner
	for child in childs_wheel:
		child.queue_free()
	for i in range(num_sections):
		var section = ColorRect.new()
		section.color = colors[i]
		section.material = null
		section.size = Vector2(radius, radius)
		section.position = Vector2.ZERO
		section.pivot_offset = section.size / 2
		section.rotation = i * angle_per_section

		var poly = Polygon2D.new()
		var start_angle = i * angle_per_section
		var end_angle = start_angle + angle_per_section
		var points = [Vector2.ZERO]
		var steps = 20
		for j in range(steps + 1):
			var t = lerp(start_angle, end_angle, float(j) / steps)
			points.append(Vector2(cos(t), sin(t)) * radius)
		poly.polygon = points
		poly.color = colors[i]
		wheel.add_child(poly)

		# Label
		var label = Label.new()
		label.text = labels[i] if i < labels.size() else "?"
		label.position = Vector2(cos(start_angle + angle_per_section/2),
								 sin(start_angle + angle_per_section/2)) * radius * 0.6
		label.rotation = start_angle + angle_per_section / 2
		label.add_theme_font_size_override("font_size", 18)
		wheel.add_child(label)


func _generate_colors(n: int) -> Array:
	var cols = []
	for i in range(n):
		cols.append(Color.from_hsv(float(i)/n, 0.8, 0.9))
	return cols


func spin():
	var tween = get_tree().create_tween()
	var target_rot = rotation + randf_range(5*PI, 10*PI)
	tween.tween_property(wheel, "rotation", target_rot, 3.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	
	
func spin2():
	if spinning:
		return
	spinning = true
	
	var tween = get_tree().create_tween()
	var extra_rot = randf_range(5 * PI, 10 * PI)
	var target_rot = wheel.rotation + extra_rot
	tween.tween_property(wheel, "rotation", target_rot, 3.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(_on_spin_finished)
	
func _on_spin_finished():
	spinning = false
	var final_angle = fmod(-wheel.rotation_degrees + pointer_angle, 360)
	if final_angle < 0:
		final_angle += 360
	var section_index = int(final_angle / angle_per_section_deg) % num_sections
	var winner_label = labels[section_index] if section_index < labels.size() else "?"
	print("🎯 Gagnant :", winner_label)
	print("🎯 angle :", wheel.rotation)
	emit_signal("spin_finished", winner_label)
