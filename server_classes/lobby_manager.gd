extends Object
class_name LobbyManager

var games_list : Array 
var waiting_list: Array
var server: Server

func _init(_server) -> void:
	server = _server
	

func is_waiting(id):
	return (id in waiting_list)


func in_game(id):
	for game in games_list:
		if id in game:
			return true
	return false


func get_opponent(id):
	for game in games_list:
		if id in game:
			if game[0] == id:
				return game[1]
			else:
				return game[0]
	return null


func add_waiting_player(id):
	if id not in waiting_list:
		waiting_list.append(id)

	create_room()
		
		
func create_room():
	if len(waiting_list) < 2:
		return
	
	var p1 = waiting_list.pick_random()
	waiting_list.erase(p1)
	var p2 = waiting_list.pick_random()
	waiting_list.erase(p2)
	
	print("Игра запущена. \
	Игрок 1: " + server.my_auth_manager.get_login_by_peer_id(p1) + \
	" , Игрок 2: " + server.my_auth_manager.get_login_by_peer_id(p2))
	
	games_list.append([p1, p2])
	var r1 = Request.new("Lobby", "start_online_game", [p2])
	var r2 = Request.new("Lobby", "start_online_game", [p1])
	server.rpc_on_client(p1, r1)
	server.rpc_on_client(p2, r2)
