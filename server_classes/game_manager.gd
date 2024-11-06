extends Object
class_name GameManager

var server: Server

func _init(_server) -> void:
	server = _server


func write_in_chat(id, msg):
	var login = server.my_auth_manager.get_login_by_peer_id(id)
	var request = Request.new("Game2D", "print_msg", [login, msg])
	server.rpc_on_client(id, request)
