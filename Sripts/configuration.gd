extends Node2D
@onready var box = $ScrollContainer/VBoxContainer



func show_list_manche(list_manche:Array)->void:
	for i in list_manche.size() :
		var name = list_manche[i]
		var check_bnt = CheckBox.new()
		check_bnt.name = "cb"+str(i)
		var l_name = Label.new()
		l_name.text = name
		l_name.name = "l"
		check_bnt.add_child(l_name)
		l_name.position=Vector2(25,0)
		box.add_child(check_bnt)
		
func set_list_manche(list_manche:Array)->void:
	for i in list_manche.size() :
		var name = list_manche[i]
		var bnt = $ScrollContainer/VBoxContainer.get_child(i)
		if bnt.button_pressed:
			Global.list_manche.append(name)


func _on_sb_nb_manche_value_changed(value: float) -> void:
	Global.nb_manche=int(value)


func _on_sb_nb_question_value_changed(value: float) -> void:
	Global.nb_question=int(value)


func _on_sb_nb_time_value_changed(value: float) -> void:
	Global.timeout=int(value)
