extends Node

var server := TCPServer.new()
var port := 8080

func _ready():
	if server.listen(port) == OK:
		print("✅ Serveur HTTP lancé sur http://127.0.0.1:%d" % port)
	else:
		push_error("❌ Impossible de lancer le serveur HTTP")

func _process(_delta):
	var test = server.is_connection_available()
	if server.is_connection_available():
		var client = server.take_connection()
		var request = client.get_utf8_string(client.get_available_bytes())
		print("📩 Requête reçue:\n", request)

		var response := ""

		# Cas 1 : page principale
		if request.begins_with("GET / "):
			var html = FileAccess.get_file_as_string("res://web/index.html")
			response = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n" + html

		# Cas 2 : réception POST (réponse joueur)
		elif request.begins_with("POST /answer"):
			# Extraire le corps du POST (après la ligne vide)
			var parts = request.split("\r\n\r\n")
			if parts.size() > 1:
				var body = parts[1]
				print("🕹 Réponse joueur :", body)
				# TODO : ici tu mets ton scoreboard

			response = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nOK"

		else:
			response = "HTTP/1.1 404 Not Found\r\nContent-Type: text/plain\r\n\r\nNot Found"

		# Envoi de la réponse
		client.put_utf8_string(response)
		client.flush()
		client.disconnect_from_host()
