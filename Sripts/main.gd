extends Node2D
@onready var boule_scene = $boule_scene
@onready var webSC= $WebSocketClient
@onready var b_next:Button= $btm_next
@onready var b_start:Button= $"Start-game"
@onready var bg = $background
@onready var conf = $Configuration
@onready var qr :QRCodeRect= $QRCodeRect





var dicso_player:Dictionary
var list_manche : Array
var selection
var manche
var n_manche = 1
var resulte

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
	set_state(Global.State.WAIT)
	


	
#-------------------------------------------------------------------------------
#-----							Machie d'état						------------
#-------------------------------------------------------------------------------
func set_state(new_state: Global.State):
	Global.current_state = new_state
	match Global.current_state:
		Global.State.WAIT:
			on_enter_wait()
		Global.State.INTRO:
			on_enter_intro()
		Global.State.CONFIG:
			on_enter_config()
		Global.State.CONNECTION_SERVE:
			on_enter_connection_serve()
		Global.State.CONNECTION_CLIENT:
			on_enter_connection_client()
		Global.State.SELECTE:
			on_enter_selecte()
		Global.State.MANCHE:
			on_enter_manche()
		Global.State.RESULT:
			on_enter_result()
		Global.State.END:
			on_enter_end()	
func update_state(id_event):
	var new_state
	match Global.current_state:
		Global.State.WAIT:
			new_state=Global.State.INTRO
		Global.State.INTRO:
			new_state=Global.State.CONFIG
		Global.State.CONFIG:
			new_state=Global.State.CONNECTION_SERVE
		Global.State.CONNECTION_SERVE:
			new_state=Global.State.CONNECTION_CLIENT
		Global.State.CONNECTION_CLIENT:
			new_state=Global.State.SELECTE
		Global.State.SELECTE:
			if Global.ENDGAME == true:
				new_state=Global.State.RESULT
			else :
				new_state=Global.State.MANCHE
		Global.State.MANCHE:
			if id_event == 0 :
				new_state=Global.State.SELECTE
			else :
				new_state=Global.State.RESULT
		Global.State.RESULT:
			new_state=Global.State.END
		Global.State.END:
			new_state=Global.State.END
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
	#update_state(0)	
func on_enter_intro()->void:
	print(" Main Intro")
	update_state(0)
	
	
func on_enter_config()->void:
	print(" Main Config")
	conf.show_list_manche(list_manche)
	conf.visible=true
	
	
func on_enter_connection_serve()->void:
	conf.set_list_manche(list_manche)
	conf.free()
	print(" Main Connection serve")
	webSC.start_server()
	SignalInt.signal_conn.connect(_recived_conn)
	SignalInt.signal_join.connect(_recived_join)
	SignalInt.signal_leave.connect(_recived_leave)
	SignalInt.end_select.connect(_recived_end_selection)
	SignalInt.end_manche.connect(_recived_end_manche)
	b_next.visible = false
	
func on_enter_connection_client()->void:
	print(" Main Connection client")
	var ip := get_local_ip()
	var url ="%s:3000" % ip
	var bytes := PackedByteArray() 
	for c in url.to_ascii_buffer():
		bytes.append(c)
	qr.set_data(url)
	qr.visible=true
	b_start.visible=true
	boule_scene.visible=true
	
	
func on_enter_selecte()->void:
	if boule_scene:
		boule_scene.free()
	if qr:
		qr.free()
		
	b_start.visible = false
	SignalInt.emite("state",1,"selection")
	print(" Main Selecte")
	start_selection()
	
func on_enter_manche()->void:
	SignalInt.emite("state",1,"manche")
	start_manche()
	print(" Main Manche")
func on_enter_result()->void:
	SignalInt.emite("state",1,"resultat")
	print(" Main Result")
	start_resulte()
func on_enter_end()->void:
	SignalInt.emite("state",1,"end")
	print(" Main End")

#-------------------------------------------------------------------------------
#------------------------ Event-------------------------------------------------
#-------------------------------------------------------------------------------
func _on_btm_next_pressed() -> void:
	update_state(0)
	
func _on_window_resized()->void:
	Global.window_size=get_window().size
	update_size()
func _on_startgame_pressed() -> void:
	update_state(0)
	
func _recived_conn()->void:
	update_state(0)
func _recived_join(id,player)->void:
	if not Global.list_player.has(id):
		boule_scene.add_boule(player.name,player.icone)
		player.global_score=0
		player.local_score=0
		Global.list_player.set(id,player)
		print("Add to liste player : ",id)
func _recived_leave(id)->void:
	if Global.list_player.has(id):
		boule_scene.delete_boule(Global.list_player[id].name)
		Global.list_player.erase(id)
		print("Add to liste player : ",id)
func _recived_end_selection(choose)->void:
	Global.curent_manche=choose
	end_selection()
	update_state(0)
func _recived_end_manche()->void:
	end_manche()
	if n_manche == Global.nb_manche: 
		update_state(1)
	else:
		n_manche+=1
		update_state(0)
	
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

func start_selection()->void:
	var selection_scene=load("res://Scene/selection.tscn")
	selection = selection_scene.instantiate()
	selection.name="selection"
	self.add_child(selection)
	selection.update_state()
	
func end_selection()->void:
	selection.call_deferred("queue_free")
	selection=[]

func start_manche()->void:
	var m = Global.list_manche[Global.curent_manche]
	m=Global.path_queations + m
	var manche_scene
	if qcmOrBt(m) == 0:
		manche_scene=load("res://Scene/manche_BT.tscn")
	elif qcmOrBt(m) == 1:
		manche_scene=load("res://Scene/manche_QCM.tscn")
	manche = manche_scene.instantiate()
	manche.name="manche"
	self.add_child(manche)
	manche.load_questions(m)
	manche.update_state()


func qcmOrBt(path_manche)->int:
	var file = FileAccess.open(path_manche, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		var questions = JSON.parse_string(text)
		if typeof(questions) == TYPE_DICTIONARY:
			if questions.type == "BT":
				return 0
			else :
				return 1
		else:
			push_error("JSON invalide !")
	return -1

func end_manche()->void:
	Global.list_manche.remove_at(Global.curent_manche)
	manche.call_deferred("queue_free")
	manche=[]
func start_resulte()->void:
	var reulte_scene=load("res://Scene/resulte.tscn")
	resulte = reulte_scene.instantiate()
	resulte.name="resulte"
	self.add_child(resulte)

func update_size()->void:
	SignalInt.emite("update_size",0)
	var w_size=Global.window_size
	var scale=Vector2(w_size.x/1152.0,w_size.y/648.0)
	bg.scale=scale
	
	b_next.scale=scale
	b_next.position=Vector2(20,580)*scale
	
	b_start.scale=scale
	b_start.position=Vector2(273,429)*scale
	if boule_scene:
		boule_scene.scale=scale
		boule_scene.position=Vector2(170,60)*scale
	if conf:
		conf.scale=scale
		conf.position=Vector2(550,389)*scale
	if qr:
		qr.scale=scale
		qr.position=Vector2(911,411)*scale
	
func get_local_ip() -> String:
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.") or ip.begins_with("10.") or ip.begins_with("172."):
			return ip
	return "10.0.0.25"
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("end_game"):
		Global.ENDGAME=true
	if event.is_action_pressed("end_manche"):
		Global.ENDMANCHE=true
