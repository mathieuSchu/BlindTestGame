extends Node2D
func _ready() -> void:
	$player_boule.add_force(10.0,0.0)
	$player_boule2.add_force(0.0,10.0)
