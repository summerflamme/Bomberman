extends Control

@onready var one_player_game = preload("res://main.tscn")
@onready var two_player_game = preload("res://main.tscn")

func _on_one_player_btn_button_down() -> void:
	get_tree().change_scene_to_packed(one_player_game)

func _on_two_player_btn_button_down() -> void:
	get_tree().change_scene_to_packed(two_player_game)

func _on_main_menu_button_button_down() -> void:
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://menu/MainMenu.tscn")
