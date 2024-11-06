extends Node
class_name Server

#######################
var server = ENetMultiplayerPeer.new()
var request_handler = RequestHandler.new()
var my_auth_manager: MyAuthManager
var lobby_manager: LobbyManager
var game_manager: GameManager


func _ready() -> void:
	create_server()
	request_handler.register("Server", self)
	
	my_auth_manager = MyAuthManager.new(self)
	lobby_manager = LobbyManager.new(self)
	game_manager = GameManager.new(self)
	request_handler.register("Auth", my_auth_manager)
	request_handler.register("Lobby", lobby_manager)
	request_handler.register("Game", game_manager)
	
	
func create_server():
	var result = server.create_server(12345)
	if result != OK:
		print("Ошибка при создании сервера:", result)
		return
		
	print("Сервер запущен")
	multiplayer.multiplayer_peer = server
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)


@rpc("any_peer")
func handle_request(request_dict: Dictionary):
	var request = Request.from_dict(request_dict)
	request_handler.handle_request(request)

#######################

func _on_player_connected(peer_id):
	print_debug("Игрок подключился с ID:", peer_id)


func _on_player_disconnected(peer_id):
	var key = my_auth_manager.get_login_by_peer_id(peer_id)
	my_auth_manager.player_discconect(peer_id)
	print_debug("Игрок отключился с ID:", peer_id)


func rpc_on_client(id, request: Request):
	rpc_id(id, "handle_request", request.to_dict())


func pong(id, request_time, _class_name, _func_name):
	var request = Request.new(_class_name, _func_name, [request_time])
	rpc_on_client(id, request)
