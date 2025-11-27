extends Node2D

@onready var ans_a :Node2D= $AnswerA
@onready var ans_b :Node2D= $AnswerB
@onready var ans_c :Node2D= $AnswerC
@onready var ans_d :Node2D= $AnswerD

@onready var ans_a_l :Label= $AnswerA/Answer
@onready var ans_b_l :Label= $AnswerB/Answer
@onready var ans_c_l :Label= $AnswerC/Answer
@onready var ans_d_l :Label= $AnswerD/Answer


func set_style(ans,type):
	var style
	if type == 0:
		style = load("res://Style/question_box_false.tres")
	elif  type ==1:
		style = load("res://Style/question_box_true.tres")
	else:
		style = load("res://Style/question_box.tres")
	if ans == 0:
		ans_a_l.add_theme_stylebox_override("normal", style)
	elif ans == 1:
		ans_b_l.add_theme_stylebox_override("normal", style)
	elif ans == 2:
		ans_c_l.add_theme_stylebox_override("normal", style)
	elif ans == 3:
		ans_d_l.add_theme_stylebox_override("normal", style) 
	
func set_text(ans,text):
	if ans==0:
		ans_a_l.text=text
	elif ans==1:
		ans_b_l.text=text
	elif ans==2:
		ans_c_l.text=text
	elif ans==3:
		ans_d_l.text=text
func update_pos():
	var w_size = Global.window_size
	var a_size = ans_a_l.size
	var b_size = ans_b_l.size
	var c_size = ans_c_l.size
	var d_size = ans_d_l.size
	var y_up=(w_size.y/20)*5
	var y_down=(w_size.y/20)*15
	var x_left = (w_size.x/4)
	var x_right= (w_size.x/4)*3
	ans_a.position=Vector2(x_left-a_size.x/2,y_up)
	ans_b.position=Vector2(x_right-b_size.x/2,y_up)
	ans_c.position=Vector2(x_left-c_size.x/2,y_down)
	ans_d.position=Vector2(x_right-d_size.x/2,y_down)
	
func set_visiblity(ans,visi):
	ans_a.visible=visi
	if ans >= 2:
		ans_b.visible=visi
	if ans >= 3:
		ans_c.visible=visi
	if ans >= 4:
		ans_d.visible=visi
