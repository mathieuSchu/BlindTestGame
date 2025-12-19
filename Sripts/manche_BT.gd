extends Node2D

@onready var time:Timer= $Timer

var questions = []
var question
var answers
var count_q = -1
var list_q = []
var id_answers=[]
var MAX_QUESTION = 3
enum State { WAIT, QUESTION,QUESTION2, ANSWER,ANSWER2,RES,END }
var current_state: State
var good_answer

var nb_player
var nb_answer_recived
	
#-------------------------------------------------------------------------------
#-----							Machie d'état						------------
#-------------------------------------------------------------------------------
func set_state(new_state: State):
	current_state = new_state
	match current_state:
		State.WAIT:
			on_enter_wait()
		State.QUESTION:
			on_enter_question()
		State.QUESTION2:
			on_enter_question2()
		State.ANSWER:
			on_enter_answer()
		State.ANSWER2:
			on_enter_answer2()
		State.RES:
			on_enter_res()
		State.END:
			on_enter_end()
			
func update_state():
	var new_state
	match current_state:
		State.WAIT:
			new_state=State.QUESTION	
		State.QUESTION:
			new_state=State.QUESTION2
		State.QUESTION2:
			new_state=State.ANSWER
		State.ANSWER:
			new_state=State.ANSWER2
		State.ANSWER2:
			if count_q == MAX_QUESTION-1 or Global.ENDMANCHE==true:
				new_state=State.RES
			else:
				new_state=State.QUESTION
		State.RES:
			new_state=State.END
		State.END:
			new_state=current_state
	set_state(new_state)

#-------------------------------------------------------------------------------
#-----------			Fonction 	and triger		 ---------------------------
#-------------------------------------------------------------------------------
func _ready() -> void:
	SignalInt.update_size.connect(update_size)
	SignalInt.signal_answer_q.connect(_recived_answer)
	update_size()
	clean_local_player_score()
	set_state(State.WAIT)
	
func on_enter_wait():
	$ProgressBar.visible = false
	print("Manche Wait")
	nb_player=Global.list_player.size()
	$Timer.wait_time = Global.timeout
func on_enter_question():
	$Btn_next.visible=true
	count_q+=1
	add_question()
	print("Manche Question")
func on_enter_question2():
	$ProgressBar.visible = true
	$Btn_next.visible=false
	question.set_image_v(false)
	nb_answer_recived=0
	add_answers()
	time.start()
	print("Manche Question2")
func on_enter_answer():
	$Btn_next.visible=true
	true_answers()
	print("Manche Answer")
func on_enter_answer2():
	$ProgressBar.visible = false
	delete_question()
	delete_answers()
	print("Manche Answer")
func on_enter_res():	
	print("Manche RES")
	load_res()
func on_enter_end():
	print("Manche End")
	Global.ENDMANCHE=false
	SignalInt.emite("end_manche",0)
	
func load_questions(path_manche)->void:
	var file = FileAccess.open(path_manche, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		questions = JSON.parse_string(text)
		
		if typeof(questions) == TYPE_DICTIONARY:
			print("Chargement OK ! Questions :", questions.questions.size())
		else:
			push_error("JSON invalide !")
	list_q=generate_unique_numbers(questions.questions.size(),questions.questions.size())
	MAX_QUESTION=min(Global.nb_question,list_q.size()-4)
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

func generate_list_answer(questions) -> Array:
	var list=[]
	var q = questions.questions
	for i in q.size():
		list.append(q[i])
	return []

func add_question()->void:
	var id = list_q[0]
	var q = questions.questions[id]
	var question_scene=load("res://Scene/question_type.tscn")
	question = question_scene.instantiate()
	add_child(question)
	question.set_text(q.question.text)
	var path="res://Question/audio/"+q.question.audio
	question.set_audio(path)
	
	
func add_answers()->void:
	var q = questions.questions
	var answer_scene=load("res://Scene/Answer_type.tscn")
	answers = answer_scene.instantiate()
	add_child(answers)
	id_answers = list_q.slice(0,4)
	id_answers.shuffle()
	var id_true_answer=list_q[0]
	for i in 4:
		if id_answers[i] == id_true_answer:
			good_answer = i
		var text = q[id_answers[i]].answer
		answers.set_text(i,text)
	answers.set_visiblity(4,true)
	answers.update_pos()
	SignalInt.emite("send_question",1,4)
	
func true_answers()->void:
	for i in id_answers.size():
		if i == good_answer:
			answers.set_style(i,1)
		else:
			answers.set_style(i,0)
	

func delete_question()->void:
	question.queue_free()
	list_q.remove_at(0)
	list_q.shuffle()
func delete_answers()->void:
	answers.queue_free()
	
	
func _recived_answer(player_id,answer)->void:
	nb_answer_recived+=1
	if answer == good_answer:
		var point=int(((Global.timeout-time.time_left)/Global.timeout)*2000.0)+1000
		Global.list_player[player_id].local_score+=point
		Global.list_player[player_id].global_score+=point
	if nb_answer_recived == nb_player:
		if not time.is_stopped():
			time.stop()
		SignalInt.emite("wait",0)
		update_state()
	
func clean_local_player_score()->void:
	for key in Global.list_player.keys():
		Global.list_player[key].local_score=0
		
		
func update_size()->void:
	var w_size=Global.window_size
	var scale=Vector2(w_size.x/1152.0,w_size.y/648.0)
	var w_p=w_size.x
	var l_p=w_size.y/20
	$ProgressBar.max_value=time.wait_time
	$ProgressBar.size=Vector2(w_p,l_p)
	$ProgressBar.position=Vector2(0,0)
	
	$Btn_next.scale=scale
	$Btn_next.position=Vector2(1052,560)*scale
	
	
	
	
func load_res()->void:
	var res_sene = load("res://Scene/list_res.tscn")
	var res = res_sene.instantiate()
	add_child(res)
	
func _on_btn_next_pressed() -> void:
	update_state()
	

func _on_timer_timeout() -> void:
	if not nb_answer_recived == nb_player:
		SignalInt.emite("wait",0)
		update_state()
		
func _process(delta: float) -> void:
	if not time.is_stopped():
		$ProgressBar.value=time.time_left
