extends Node2D
@onready var boule_scene = $boule_scene
func _ready() -> void:
	pass


func _on_startgame_pressed() -> void:
	boule_scene.add_boule()
