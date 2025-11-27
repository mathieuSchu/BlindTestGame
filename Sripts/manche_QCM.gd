extends Node2D
var questions = []
var question
var answers
var id_answer
var count_q = -1
var list_q
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
	load_questions("res://Question/test.json")
	list_q=generate_unique_numbers(MAX_QUESTION,questions.questions.size())
	print("Wait")
func on_enter_question():
	count_q+=1
	var id = list_q[count_q]
	add_question(id)
	print("Question")
func on_enter_question2():
	var id = list_q[count_q]
	question.set_image_v(false)
	add_answers(id)
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
	
func load_questions(path_manche):
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


func add_question(id)->void:
	var q = questions.questions[id]
	var question_scene=load("res://Scene/question_type.tscn")
	question = question_scene.instantiate()
	add_child(question)
	question.set_text(q.question.text)
	if not q.question.image == "":
		var path="res://Question/image/"+q.question.image
		question.set_image(path)
	if not q.question.audio == "":
		var path="res://Question/audio/"+q.question.audio
		question.set_audio(path)
	
	
func add_answers(id)->void:
	var q = questions.questions[id]
	var answer_scene=load("res://Scene/Answer_type.tscn")
	answers = answer_scene.instantiate()
	add_child(answers)
	var size_answer = q.answer.size()
	id_answer = generate_unique_numbers(size_answer,size_answer)
	for i in size_answer:
		var text = q.answer[id_answer[i]]
		answers.set_text(i,text)
	answers.set_visiblity(size_answer,true)
	answers.update_pos()
	
func true_answers()->void:
	for i in id_answer.size():
		var id = id_answer[i]
		if id == 0:
			answers.set_style(i,1)
		else:
			answers.set_style(i,0)
func delete_question()->void:
	question.queue_free()
func delete_answers()->void:
	answers.queue_free()
func _on_btn_next_pressed() -> void:
	update_state()
	
	
