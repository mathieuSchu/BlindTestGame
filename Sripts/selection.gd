extends Node2D
var question
var answers
var choose
var id_answers=[]
enum State { WAIT, SELECTION,CHOOSE,END}
var current_state: State

	
#-------------------------------------------------------------------------------
#-----							Machie d'état						------------
#-------------------------------------------------------------------------------
func set_state(new_state: State,arg=[]):
	current_state = new_state
	match current_state:
		State.WAIT:
			on_enter_wait()
		State.SELECTION:
			on_enter_selection()
		State.CHOOSE:
			on_enter_choose(arg)
		State.END:
			on_enter_end()
			
func update_state(arg=[]):
	var new_state
	match current_state:
		State.WAIT:
			new_state=State.SELECTION	
		State.SELECTION:
			new_state=State.CHOOSE
		State.CHOOSE:
			new_state=State.END
		State.END:
			new_state=current_state
	set_state(new_state,arg)

#-------------------------------------------------------------------------------
#-----------			Fonction 	and triger		 ---------------------------
#-------------------------------------------------------------------------------
func _ready() -> void:
	set_state(State.WAIT)
	SignalInt.signal_answer_s.connect(_recive_selection)
	
func on_enter_wait():
	print("Sel Wait")
func on_enter_selection():
	start_selection()
	print(" Sel Selection")
func on_enter_choose(value):
	true_answers(value)
	$Btn_next.visible = true;
	print("Sel Choose")
func on_enter_end():
	SignalInt.emite("end_select",1,choose)
	print("Sel End")
	
func start_selection()->void:
	var question_scene=load("res://Scene/question_type.tscn")
	question = question_scene.instantiate()
	add_child(question)
	var n_player = Global.list_player.size()
	var keys=Global.list_player.keys()
	var i= randi_range(0,n_player-1)
	var key=keys[i]
	var text = "Selection du theme : " + Global.list_player[key].name
	question.set_text(text)
	var nb_answer=add_answers()
	SignalInt.emite("selection",2,key,nb_answer)
func add_answers()->int:
	var answer_scene=load("res://Scene/Answer_type.tscn")
	answers = answer_scene.instantiate()
	add_child(answers)
	var nb_lite_manche = Global.list_manche.size()
	id_answers = generate_unique_numbers(3,nb_lite_manche)
	if nb_lite_manche == 0:
		Global.ENDGAME = true
		SignalInt.emite("end_select",1,0)
	elif nb_lite_manche == 1:
		answers.set_text(0,"???????? ")
		answers.set_visiblity(1,true)
		answers.update_pos()
	elif nb_lite_manche == 2:
		answers.set_text(0,Global.list_manche[id_answers[0]])
		answers.set_text(1,"???????? ")
		answers.set_visiblity(2,true)
		answers.update_pos()
	else:
		answers.set_text(0,Global.list_manche[id_answers[0]])
		answers.set_text(1,Global.list_manche[id_answers[1]])
		answers.set_text(2,"???????? ")
		answers.set_visiblity(3,true)
		answers.update_pos()
	return min(nb_lite_manche,3)
func true_answers(id)->void:
	var nb_lite_manche = Global.list_manche.size()
	var id_max = min(nb_lite_manche,3)
	answers.set_text(id_max-1,Global.list_manche[id_answers[id_max-1]])
	choose=id_answers[id]
	for i in id_max:
		if i == id:
			answers.set_style(i,1)
		else:
			answers.set_style(i,0)
	SignalInt.emite("wait",0)
		
func generate_unique_numbers(count: int, max_value: int) -> Array:
	var numbers = []
	var pool = []
	if max_value<count:
		count=max_value
	# créer la liste 0..max_value-1
	for i in range(max_value):
		pool.append(i)
	pool.shuffle()  # mélanger
	# prendre les count premiers
	return pool.slice(0, count)
func _recive_selection(value : int)->void:
	update_state(value);
	

func _on_btn_next_pressed() -> void:
	update_state();
