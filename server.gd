extends Node

############# НЕ ТРОГАТЬ
var server = ENetMultiplayerPeer.new()

@rpc("any_peer")
func handle_request(_class_name: String, function_name: String, args: Array):
	NetworkManager.handle_request(_class_name, function_name, args)

#############

func _ready() -> void:
	create_server()
	NetworkManager.registere("Server", self)
	

func create_server():
	var result = server.create_server(12345)
	if result != OK:
		print("Ошибка при создании сервера:", result)
		return
		
	multiplayer.multiplayer_peer = server
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)

	
func _on_player_connected(peer_id):
	print_debug("Игрок подключился с ID:", peer_id)


func _on_player_disconnected(peer_id):
	print_debug("Игрок отключился с ID:", peer_id)


func client_chat_callback(sender_id: int, message: String):
	var msg = "Сообщение от клиента " + str(sender_id) + " : " + message
	rpc("handle_request", "Lobby", "write_in_chat", [msg])


func login(id, login, password):
	print("Логин: " + str(id) + " - " + str(login))
	# TODO("add login logic")
	rpc_id(id, "handle_request", "Auth", "server_here", [])


func register(id, login, password):
	print("Регистрация: " + str(id) + " - " + str(login))
	# TODO("add register logic")
	rpc_id(id, "handle_request", "Auth", "server_here", [])



	
	
