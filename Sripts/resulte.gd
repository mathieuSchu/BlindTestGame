extends Node2D
@onready var p1 :ColorRect = $podium1
@onready var p2 :ColorRect= $podium2
@onready var p3 :ColorRect= $podium3

@onready var lb1 :Label =$podium1/Label
@onready var lb2 :Label= $podium2/Label
@onready var lb3 :Label= $podium3/Label

@onready var b_next :Button= $bnt_next


var players_array: Array = []
var scale_boule 
var potion_player_array = []
var state = 0
var nb_p = 0

func _ready() -> void:
	SignalInt.update_size.connect(update_size)
	update_ranking()
	update_size()
	create_boule()


func init_false()->void:
	Global.window_size=get_window().size
	Global.list_player = {
	"p1": { "name": "Alice", "global_score": 120,"icone" : 0 },
	"p2": { "name": "Bob",   "global_score": 80,"icone" : 1 },
	"p3": { "name": "Eve",   "global_score": 150,"icone" : 2 }
	}
		
func update_ranking()->void:
	for key in Global.list_player.keys():
		var p = Global.list_player[key]
		if p.has("global_score") and p.has("name"):
			players_array.append(p)
	players_array.sort_custom(func(a, b):
		return a["global_score"] > b["global_score"]
	)

func update_size()->void:
	var w_size=Global.window_size
	scale_boule = w_size.x/648.0
	
	



	p1.material.set_shader_parameter("repeat_multiplier",scale_boule)
	p2.material.set_shader_parameter("repeat_multiplier",scale_boule)
	p3.material.set_shader_parameter("repeat_multiplier",scale_boule)
	
	
	var l1=w_size.x/5;
	var l2=w_size.x/5+1;
	var l3=w_size.x/5;
	var wb=w_size.x/20;
	var h1=w_size.y/2;
	var h2=w_size.y*3/8;
	var h3=w_size.y/4;
	
	
	
	
	var x1=w_size.x*2/5;
	var x2=w_size.x/5;
	var x3=w_size.x*3/5;
	var xb=w_size.x*18/20;
	var y1=w_size.y*3/8;
	var y2=w_size.y/2;
	var y3=w_size.y*5/8;
	var yb=w_size.y*18/20;
	
	
	p1.size=Vector2(l1,h1)
	p1.position=Vector2(x1,y1)
	p2.size=Vector2(l2,h2)
	p2.position=Vector2(x2,y2)
	p3.size=Vector2(l3,h3)
	p3.position=Vector2(x3,y3)
	
	b_next.size=Vector2(wb,wb)
	b_next.position=Vector2(xb,yb)
	
	lb1.position=Vector2(l1/2-lb1.size.x/2,h1/2-lb1.size.y/2)
	lb2.position=Vector2(l2/2-lb2.size.x/2,h2/2-lb2.size.y/2)
	lb3.position=Vector2(l3/2-lb3.size.x/2,h3/2-lb3.size.y/2)
	
	potion_player_array.append(Vector2(x1+l1/2,y1-50*scale_boule))
	potion_player_array.append(Vector2(x2+l2/2,y2-50*scale_boule))
	potion_player_array.append(Vector2(x3+l2/2,y3-50*scale_boule))
	
func create_boule()->void:
	nb_p=players_array.size()
	for i in 3:
		if i < nb_p:
			var player=players_array[i]
			var boule_scene = load("res://Scene/player_boule.tscn")
			var boule = boule_scene.instantiate()
			boule.name = player.name
			boule.scale = Vector2(scale_boule,scale_boule)
			boule.position = potion_player_array[i]
			boule.visible=false
			add_child(boule)
			boule.add_name(player.name)
			boule.upadate_icone(player.icone)
			

func _on_bnt_next_pressed() -> void:
	var all_visible=true
	for i in nb_p:
		var name=players_array[nb_p-i-1].name
		for j in get_child_count():
			var c = get_child(j)
			if c.name == name:
				if c.visible == false and all_visible == true: 
					all_visible = false
					c.visible=true
	if all_visible == true: 
		for i in nb_p:
			var name=players_array[nb_p-i-1].name
			for j in get_child_count():
				var c = get_child(j)
				if c.name == name:
					c.free()
		p1.free()
		p2.free()
		p3.free()
		load_res()
		
func load_res()->void:
	b_next.visible=false
	for key in Global.list_player.keys():
		Global.list_player[key].local_score = Global.list_player[key].global_score
	var res_sene = load("res://Scene/list_res.tscn")
	var res = res_sene.instantiate()
	add_child(res)
		 
