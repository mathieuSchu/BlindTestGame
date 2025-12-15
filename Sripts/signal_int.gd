extends Node


signal signal_conn()
signal signal_join(id,player)
signal signal_leave(id)
signal signal_answer_q(id,value)
signal signal_answer_s(value)

signal selection(id)
signal end_select(choose)
signal state(state)

signal send_question(num_ans)
signal wait()
signal end_manche()
signal update_size()

func emite(name_singal,nb_arg,arg1=[],arg2=[],arg3=[])->void:
	if nb_arg==0:
		emit_signal(name_singal)
	elif nb_arg==1:
		emit_signal(name_singal,arg1)
	elif nb_arg==2:
		emit_signal(name_singal,arg1,arg2)
	elif nb_arg==3:
		emit_signal(name_singal,arg1,arg2,arg3)
		
func recive()->void:
	pass
	
