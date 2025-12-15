extends Node

# The port we will listen to.
const PORT = 8081

# Our TCP Server instance.
var tcp_server = TCPServer.new()
var socket := WebSocketPeer.new()
# Our connected peers list.

var last_peer_id := 1

func _ready() -> void:
	SignalInt.selection.connect(_emit_selection)
	SignalInt.state.connect(_emit_global_stat)
	SignalInt.send_question.connect(_emit_question)
	SignalInt.wait.connect(_emit_wait)

func _process(_delta):
	while tcp_server.is_connection_available():
		print("Connection")
		var conn: StreamPeerTCP = tcp_server.take_connection()
		assert(conn != null)
		socket.accept_stream(conn)
		SignalInt.emite("signal_conn",0)
	# Iterate over all connected peers using "keys()" so we can erase in the loop
	
	socket.poll()

	var peer_state = socket.get_ready_state()
	if peer_state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var data = 	JSON.parse_string(socket.get_packet().get_string_from_ascii())
			message_recive(data)
func _exit_tree() -> void:
	socket.close()
	tcp_server.stop()
	

func _on_pressed() -> void:
	var dic={}
	dic["type"] = "setState"
	dic["state"] = "locked"
	send_massage(dic)

func send_massage(dic:Dictionary) -> void:
	var json_text = JSON.stringify(dic, "\t")
	socket.send_text(json_text)
func message_recive(data)->void:
	var type = data.type
	if type == "join":
		var name = data.player.name
		var id = data.id
		SignalInt.emite("signal_join",2,id,data.player)
		print("Join : ",name, " id : ",id)
	if type == "leave":
		var id = data.id
		SignalInt.emite("signal_leave",1,id)
		print("Leave : ",id)
	if type == "playerAnswer":
		var id = data.id
		var value = data.answer
		print("playerAnswer : ",id," ; ",value)
		if Global.current_state == Global.State.SELECTE:
			SignalInt.emite("signal_answer_s",1,value)
		elif Global.current_state == Global.State.MANCHE:
			SignalInt.emite("signal_answer_q",2,id,value)
		
		
		
func start_server():
	# Start listening on the given port.
	if tcp_server.listen(PORT) != OK:
		print("Unable to start server.")
		set_process(false)
		
func _emit_selection(id)->void:
	var data : Dictionary
	data.type = "selection"
	data.id = id
	data.numChoices = 3
	send_massage(data)
	
func _emit_global_stat(state)->void:
	var data : Dictionary
	data.type = "setState"
	data.state = state
	send_massage(data)
	
func _emit_question(nb_ans)->void:
	var data : Dictionary
	data.type = "question"
	data.numChoices = nb_ans
	send_massage(data)
	
func _emit_wait()->void:
	var data : Dictionary
	data.type = "wait"
	send_massage(data)
