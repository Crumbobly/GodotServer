extends Node

#######################
var server = ENetMultiplayerPeer.new()

@rpc("any_peer")
func handle_request(_class_name: String, function_name: String, args: Array):
	NetworkManager.handle_request(_class_name, function_name, args)

func create_server():
	var result = server.create_server(12345)
	if result != OK:
		print("Ошибка при создании сервера:", result)
		return
		
	print("Сервер запущен")
	multiplayer.multiplayer_peer = server
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)

func _ready() -> void:
	create_server()
	NetworkManager.register("Server", self)
#######################


func _on_player_connected(peer_id):
	print_debug("Игрок подключился с ID:", peer_id)


func _on_player_disconnected(peer_id):
	var key = MyAuthManager.get_login_by_peer_id(peer_id)
	MyAuthManager.player_discconect(peer_id)
	print_debug("Игрок отключился с ID:", peer_id)


func client_chat_callback(peer_id: int, message: String):
	var key = MyAuthManager.get_login_by_peer_id(peer_id)
	var msg = "Сообщение от клиента " + str(key) + " : " + message
	rpc("handle_request", "Lobby", "write_in_chat", [msg])



func server_here(id, login):
	rpc_id(id, "handle_request", "Auth", "server_here", [login])

func show_error(id):
	rpc_id(id, "handle_request", "Auth", "show_error", [])

	
