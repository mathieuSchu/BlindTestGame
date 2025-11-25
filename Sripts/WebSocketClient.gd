extends Node

# The port we will listen to.
const PORT = 8081

# Our TCP Server instance.
var tcp_server = TCPServer.new()
var socket := WebSocketPeer.new()
# Our connected peers list.

var last_peer_id := 1


func _ready():
	# Start listening on the given port.
	if tcp_server.listen(PORT) != OK:
		print("Unable to start server.")
		set_process(false)


func _process(_delta):
	while tcp_server.is_connection_available():
		print("Connection")
		var conn: StreamPeerTCP = tcp_server.take_connection()
		assert(conn != null)
		socket.accept_stream(conn)
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
		print("Join : ",data.player.name, " id : ",data.id)
	if type == "leave":
		print("Leave : ",data.id)
		
