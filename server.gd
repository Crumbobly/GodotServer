extends Node

#######################
var server = ENetMultiplayerPeer.new()

@rpc("any_peer")
func handle_request(request_dict: Dictionary):
	var request = Request.from_dict(request_dict)
	NetworkManager.handle_request(request)


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
	var request = Request.new("Lobby", "write_in_chat", [msg])
	rpc_on_client(peer_id, request)


func rpc_on_client(id, request: Request):
	rpc_id(id, "handle_request", request.to_dict())


func pong(id, request_time, _class_name, _func_name):
	var request = Request.new(_class_name, _func_name, [request_time])
	rpc_on_client(id, request)
