extends Node2D
var questions = []
var question
var answers
var count_q = -1
var list_q = []
var id_answers=[]
var MAX_QUESTION = 3
enum State { WAIT, QUESTION,QUESTION2, ANSWER,ANSWER2, END }
var current_state: State
	
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
			if count_q == MAX_QUESTION-1:
				new_state=State.END
			else:
				new_state=State.QUESTION
		State.END:
			new_state=current_state
	set_state(new_state)

#-------------------------------------------------------------------------------
#-----------			Fonction 	and triger		 ---------------------------
#-------------------------------------------------------------------------------
func _ready() -> void:
	set_state(State.WAIT)
	
func on_enter_wait():
	load_questions("res://Question/test2.json")
	list_q=generate_unique_numbers(questions.questions.size(),questions.questions.size())
	print("Wait")
func on_enter_question():
	count_q+=1
	add_question()
	print("Question")
func on_enter_question2():
	var id = list_q[count_q]
	question.set_image_v(false)
	add_answers()
	print("Question2")
func on_enter_answer():
	true_answers()
	print("Answer")
func on_enter_answer2():
	delete_question()
	delete_answers()
	
	print("Answer")
func on_enter_end():
	print("End")
	
func load_questions(path_manche)->void:
	var file = FileAccess.open(path_manche, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		questions = JSON.parse_string(text)
		
		if typeof(questions) == TYPE_DICTIONARY:
			print("Chargement OK ! Questions :", questions.questions.size())
		else:
			push_error("JSON invalide !")
			
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
	for i in 4:
		var text = q[id_answers[i]].answer
		answers.set_text(i,text)
	answers.set_visiblity(4,true)
	answers.update_pos()
	
func true_answers()->void:
	var id_true_answer=list_q[0]
	for i in id_answers.size():
		var id = id_answers[i]
		if id == id_true_answer:
			answers.set_style(i,1)
		else:
			answers.set_style(i,0)
	

func delete_question()->void:
	question.queue_free()
	list_q.remove_at(0)
	list_q.shuffle()
func delete_answers()->void:
	answers.queue_free()
func _on_btn_next_pressed() -> void:
	update_state()
	
	
