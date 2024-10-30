extends Node

############# НЕ ТРОГАТЬ
var server = ENetMultiplayerPeer.new()

@onready var auto_save_timer = $Timer

var auth_player : Dictionary = {
	"login" : "password"
}

var current_player_id : Dictionary = {
	"login" : "peer_id"
}

@rpc("any_peer")
func handle_request(_class_name: String, function_name: String, args: Array):
	NetworkManager.handle_request(_class_name, function_name, args)

#############

######################
func save_dic():
	var file = FileAccess.open("res://save.dat" , FileAccess.WRITE)
	var json_string = JSON.stringify(auth_player)
	file.store_line(json_string)
func load_dic():	
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
		auth_player = data
######################

func _ready() -> void:
	auto_save_timer.wait_time = 10
	auto_save_timer.one_shot = false
	auto_save_timer.start()
	create_server()
	load_dic()
	NetworkManager.registere("Server", self)
	
func autosave():
	print("saved")
	save_dic()



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
	var key = current_player_id.find_key(peer_id)
	current_player_id.erase(key)
	print_debug("Игрок отключился с ID:", peer_id)


func client_chat_callback(sender_id: int, message: String):
	var key = current_player_id.find_key(sender_id)
	var msg = "Сообщение от клиента " + str(key) + " : " + message
	rpc("handle_request", "Lobby", "write_in_chat", [msg])


func login(id, login, password):
	if(auth_player.has(login)):
		if(auth_player[login] == password)	:
			print("Succsesful login")
			current_player_id[login] = id
			rpc_id(id, "handle_request", "Auth", "server_here", [])
		else :
			rpc_id(id, "handle_request", "Auth", "uncorrect_data", [1])
	else:
		rpc_id(id, "handle_request", "Auth" , "uncorrect_data", [0])
		print("Uncorrect login")

func register(id, login, password):
	print("Регистрация: " + str(id) + " - " + str(login))
	auth_player[login] = password
	rpc_id(id, "handle_request", "Auth", "server_here", [])

func _on_timer_timeout() -> void:
	autosave()
