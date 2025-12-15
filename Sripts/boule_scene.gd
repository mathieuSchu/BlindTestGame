extends Node2D
var player_count: int = 0

func add_boule(name,icone=0)->void:
	player_count += 1
	var boule_scene = load("res://Scene/player_boule.tscn")
	var boule = boule_scene.instantiate()
	boule.name = name
	var x=randi_range(100,700)
	var y=randi_range(100,200)
	boule.position = Vector2(x,y)
	add_child(boule)
	boule.add_name(name)
	boule.upadate_icone(icone)
	boule.add_force(randf_range(-10,10),randf_range(-10,10))
func delete_boule(name)->void:
	for i in get_child_count():
		var c = get_child(i)
		if c.name == name:
			c.free()
			return
