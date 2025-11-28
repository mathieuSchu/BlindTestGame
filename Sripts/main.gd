extends Node2D
@onready var boule_scene = $boule_scene

enum State { WAIT,INTRO,CONFIG,CONNECTION,SELECTE,MANCHE,RESULT,FRESULT,END}
var current_state: State
var dicso_player:Dictionary
var id_player_false = 0
var list_manche : Array


class Player :
	var Name
	var Score = 0
	var Icone
	func _init(name,id_icone) -> void:
		Name=name
		set_Icone(id_icone)
	func set_Icone(id):
		if id == 0:
			Icone=load("res://Asset/flocon.jpg")
		else:
			Icone=load("res://Asset/icon.svg")
	

var MAX_MANCHES
var MAX_QUESTIONS


func _ready() -> void:
	set_state(State.WAIT)
	


	
#-------------------------------------------------------------------------------
#-----							Machie d'état						------------
#-------------------------------------------------------------------------------
func set_state(new_state: State):
	current_state = new_state
	match current_state:
		State.WAIT:
			on_enter_wait()
		State.INTRO:
			on_enter_intro()
		State.CONFIG:
			on_enter_config()
		State.CONNECTION:
			on_enter_connection()
		State.SELECTE:
			on_enter_selecte()
		State.MANCHE:
			on_enter_manche()
		State.RESULT:
			on_enter_result()
		State.FRESULT:
			on_enter_fresult()
		State.END:
			on_enter_end()	
func update_state(id_event):
	var new_state
	match current_state:
		State.WAIT:
			new_state=State.INTRO
		State.INTRO:
			new_state=State.CONFIG
		State.CONFIG:
			new_state=State.CONNECTION
		State.CONNECTION:
			new_state=State.SELECTE
		State.SELECTE:
			new_state=State.MANCHE
		State.MANCHE:
			new_state=State.RESULT
		State.RESULT:
			if id_event == 0 :
				new_state=State.SELECTE
			else :
				new_state=State.FRESULT
		State.FRESULT:
			new_state=State.END
		State.END:
			new_state=State.END
	set_state(new_state)

#-------------------------------------------------------------------------------
#-----------			Fonction 	and triger		 ---------------------------
#-------------------------------------------------------------------------------
func on_enter_wait()->void:
	print("Main Wait")
	var win := get_window()
	win.size_changed.connect(_on_window_resized)
	Global.window_size=win.size
	list_manche =get_json_files(Global.path_queations)
	update_state(0)	
	
	
func on_enter_intro()->void:
	print(" Main Intro")
	update_state(0)
	
	
func on_enter_config()->void:
	print(" Main Config")
	$btm_next.visible=true
	$Configuration.show_list_manche(list_manche)
	$Configuration.visible=true
	
	
func on_enter_connection()->void:
	$Configuration.set_list_manche(list_manche)
	$Configuration.free()
	print(" Main Connection")
	$btm_add.visible=true
	$"Start-game".visible=true
	$boule_scene.visible=true
	
	
func on_enter_selecte()->void:
	print(" Main Selecte")
func on_enter_manche()->void:
	print(" Main Manche")
func on_enter_result()->void:
	print(" Main Result")
func on_enter_fresult()->void:
	print(" Main Final Result")
func on_enter_end()->void:
	print(" Main End")

#-------------------------------------------------------------------------------
#------------------------ Event-------------------------------------------------
#-------------------------------------------------------------------------------
func _on_btm_next_pressed() -> void:
	update_state(0)
func _on_btm_add_pressed() -> void:
	boule_scene.add_boule()
	var player = Player.new("Player",0)
	dicso_player.set(id_player_false,player)
	id_player_false+=1
	
func _on_window_resized()->void:
	Global.window_size=get_window().size
func _on_startgame_pressed() -> void:
	pass
	
	
	
#-------------------------------------------------------------------------------
#--------------------------  Function  -----------------------------------------
#-------------------------------------------------------------------------------
func get_json_files(path:String) -> Array:
	var result = []
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("Dossier introuvable : " + path)
		return result
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		if !dir.current_is_dir() and file.ends_with(".json"):
			result.append(file)
	return result
