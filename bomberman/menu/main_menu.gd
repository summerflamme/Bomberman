extends Control
@onready var playerMenu = preload("res://menu/playerMenu.tscn")
@onready var creditMenu = preload("res://menu/credit_menu.tscn")
@onready var controlMenu = preload("res://menu/control.tscn")

func _on_play_btn_button_down() -> void:
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_packed(playerMenu)
	
func _on_button_button_down() -> void:
	get_tree().change_scene_to_packed(creditMenu)

func _on_control_btn_button_down() -> void:
	get_tree().change_scene_to_packed(controlMenu)
	
func _on_quit_btn_button_down() -> void:
	get_tree().quit()
