extends Node

func _ready() -> void:
	create_server()


func create_server():
	var server = ENetMultiplayerPeer.new()
	server.create_server(12345)
	multiplayer.multiplayer_peer = server
	print("server created")
	
	
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)


func _on_player_connected(peer_id):
	print("Игрок подключился с ID:", peer_id)
	# Добавь логику для инициализации данных для нового игрока

func _on_player_disconnected(peer_id):
	print("Игрок отключился с ID:", peer_id)
	# Убери игрока из игры или обработай его отключение
	
