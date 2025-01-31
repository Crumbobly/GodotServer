extends Object
class_name MyAuthManager

var auth_players : Dictionary = {"login" : "password"}
var connected_players : Dictionary = {"login" : "peer_id"}
var server: Server

func _init(_server) -> void:
	server = _server
	load_accounts()

func login_is_exist(login: String):
	return auth_players.keys().find(login) != -1

func login_is_connected(login: String):
	return connected_players.keys().find(login) != -1

func get_login_by_peer_id(peer_id):
	return connected_players.find_key(peer_id)

func player_discconect(peer_id):
	connected_players.erase(get_login_by_peer_id(peer_id))

func add_new_account(login, password):
	var file = FileAccess.open("res://save.dat" , FileAccess.WRITE)
	var json_string = JSON.stringify(auth_players)
	file.store_line(json_string)

	
func load_accounts():

	if not(FileAccess.file_exists("res://save.dat")):
		print("none")
		return
	
	var file = FileAccess.open("res://save.dat", FileAccess.READ)
	while (file.get_position() < file.get_length()):
		
		var json_string = file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if not parse_result == OK:
			print("JSON parse Error ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
			
		var data = json.get_data()
		auth_players = data


func login(id, login, password):
	
	var error_msg = "Неверный логин или пароль"
	
	if(auth_players.has(login)):
		
		if connected_players.has(login):
			error_msg = "Вход в аккаунт уже был произведён"
		
		elif(auth_players[login] == password)	:
			connected_players[login] = id
			var request = Request.new("Auth", "server_here", [login])
			server.rpc_on_client(id, request)
			return
	
	var request = Request.new("Auth", "set_error_lbl_text", [error_msg])
	server.rpc_on_client(id, request)
	


func register(id, login, password):
	
	var error_msg = "Логин занят"
		
	if not auth_players.has(login):
		auth_players[login] = password
		connected_players[login] = id
		add_new_account(login, password)
		var request = Request.new("Auth", "server_here", [login])
		server.rpc_on_client(id, request)
		return
	
	var request = Request.new("Auth", "set_error_lbl_text", [error_msg])
	server.rpc_on_client(id, request)
	
	
