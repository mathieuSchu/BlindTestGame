extends Node

var ws := WebSocketPeer.new()

func _ready():
	var url = "ws://localhost:3000"
	var err = ws.connect_to_url(url)
	if err != OK:
		push_error("❌ Erreur connexion WebSocket : %s" % err)
	else:
		print("🔌 Connexion en cours à", url)

func _process(_delta):
	ws.poll()
	# Vérifie si on est connecté
	if ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		# Lire tous les paquets reçus
		while ws.get_available_packet_count() > 0:
			var raw = ws.get_packet()  # PackedByteArray
			var msg = raw.get_string_from_utf8()
			print("📩 Message reçu:", msg)
		# Exemple: décoder le JSON
			var data = JSON.parse_string(msg)
			if typeof(data) == TYPE_DICTIONARY:
				var player = data["player"]
				var answer = data["answer"]
				print("🕹 Joueur %s → %s" % [player, answer])
				# TODO: mettre à jour scoreboard ici


func set_master():
	if ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var val: PackedByteArray = PackedByteArray([0,0])
		ws.send(val,WebSocketPeer.WRITE_MODE_BINARY)
		print("📤 Informer que je suis le maitre")


func _on_pressed() -> void:
	pass
