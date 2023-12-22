extends Node

const LOG_FILE_DIRECTORY = 'user://detailed_logs'

var logging_enabled := true



func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "OnSomeOneJoined")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	SyncManager.connect("sync_started", self, "_on_SyncManager_sync_started")
	SyncManager.connect("sync_stopped", self, "_on_SyncManager_sync_stopped")




func OnSomeOneJoined(peer_id: int):
	print("Registering to Sync manger")
	SyncManager.add_peer(peer_id)
	get_node("/root/L_Main/ServerPlayer").set_network_master(1)
	if get_tree().is_network_server():
		get_node("/root/L_Main/ServerPlayer2").set_network_master(peer_id)
	else:
		get_node("/root/L_Main/ServerPlayer2").set_network_master(get_tree().get_network_unique_id())

	if get_tree().is_network_server():
		# Give a little time to get ping data.
		yield(get_tree().create_timer(2.0), "timeout")
		SyncManager.start()

func _on_network_peer_disconnected(peer_id: int):
	SyncManager.remove_peer(peer_id)

func _on_server_disconnected() -> void:
	_on_network_peer_disconnected(1)


func HostGame() -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(int(9999), 1)
	get_tree().network_peer = peer
#	yield(get_tree().create_timer(2.0), "timeout")
#	get_node("/root/L_Main/ServerPlayer").set_network_master(1)
#	get_node("/root/L_Main/ServerPlayer2").set_network_master(2)
#	get_node("/root/L_Main/ServerPlayer3").set_network_master(3)
#	get_node("/root/L_Main/ServerPlayer4").set_network_master(4)
#	get_node("/root/L_Main/ServerPlayer5").set_network_master(5)
#	get_node("/root/L_Main/ServerPlayer6").set_network_master(6)
#	yield(get_tree().create_timer(2.0), "timeout")
#	SyncManager.start()
	
	yield(get_tree().create_timer(2.0), "timeout")
	for Wall in get_tree().get_nodes_in_group("StaticCollsions"):
		Wall.set_script(null)

func JoinGame() -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client("127.0.0.1", int(9999))
	get_tree().network_peer = peer



func _on_SyncManager_sync_started() -> void:
	if logging_enabled:
		var dir = Directory.new()
		if not dir.dir_exists(LOG_FILE_DIRECTORY):
			dir.make_dir(LOG_FILE_DIRECTORY)
		
		var datetime = OS.get_datetime(true)
		var log_file_name = "%04d%02d%02d-%02d%02d%02d-peer-%d.log" % [
			datetime['year'],
			datetime['month'],
			datetime['day'],
			datetime['hour'],
			datetime['minute'],
			datetime['second'],
			get_tree().get_network_unique_id(),
		]
		
		SyncManager.start_logging(LOG_FILE_DIRECTORY + '/' + log_file_name)



func _on_SyncManager_sync_stopped() -> void:
	if logging_enabled:
		SyncManager.stop_logging()
