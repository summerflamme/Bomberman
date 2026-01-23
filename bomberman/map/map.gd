extends Node3D

@onready var player_camera := get_node_or_null("player/playerCamera")
@onready var top_camera := get_node_or_null("topCamera") 

var using_player_camera := false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_camera"):
		switch_camera()
		
func switch_camera():
	using_player_camera = !using_player_camera
	
	player_camera.current = using_player_camera
	top_camera.current = !using_player_camera
	
