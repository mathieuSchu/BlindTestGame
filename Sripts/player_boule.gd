extends Node2D
@onready var boule  : RigidBody2D = $boule
@onready var mesh_instance = $boule/MeshInstance2D
@onready var name_player = $boule/Name

@onready var sprite = $boule/Sprite2D

func _ready() -> void:
	pass

func add_force(x: float,y:float):
	var vec=Vector2(x,y)
	vec=1000*vec
	boule.apply_force(vec)
	
func add_name(name_p)->void:
	name_player.text = name_p
	_update_label_size()
func add_color(r,g,b)->void:
	mesh_instance.modulate=Color(r,g,b)
	
func _update_label_size():
	# Récupère la taille du mesh (rayon)
	var radius = mesh_instance.mesh.radius if mesh_instance.mesh and mesh_instance.mesh.has_method("get_radius") else 50.0

	# Taille maximale que le label peut occuper (en pixels)
	var max_width = radius * 2.0

	# On ajuste la taille du label en fonction
	name_player.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_player.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_player.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	name_player.size = Vector2(radius * 2, radius * 2)
	name_player.position = Vector2(-radius, -radius)

	# Ajuste la police (FontSize) jusqu’à ce que le texte tienne dans la largeur
	var font = name_player.get_theme_font("font")
	if font:
		var max_size = 200
		var min_size = 1
		var best_size = min_size
		for size in range(min_size, max_size):
			var text_size = font.get_multiline_string_size(name_player.text, HORIZONTAL_ALIGNMENT_CENTER, name_player.size.x, size)
			if text_size.y > name_player.size.y:
				break
			if text_size.x > name_player.size.x:
				break
			best_size = size
		name_player.add_theme_font_size_override("font_size", best_size)
  # Centré sur la sphère
func upadate_icone(icone=0)->void:
	var path_icone
	if icone == 0:
		path_icone="res://Asset/flocon.png"
	elif  icone == 1:
		path_icone="res://Asset/icon.svg"
	elif icone == 2:
		path_icone="res://Asset/noel3.png"
	elif icone == 3:
		path_icone=""
	var tex : Texture = load(path_icone)
	sprite.texture=tex
	var size=tex.get_size()
	var radius = mesh_instance.mesh.radius if mesh_instance.mesh and mesh_instance.mesh.has_method("get_radius") else 50.0
	var scale_p=Vector2(radius*2/size.x,radius*2/size.y)
	sprite.scale=scale_p
	
	
