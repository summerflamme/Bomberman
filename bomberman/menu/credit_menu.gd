extends Control



func _on_main_menu_btn_button_down() -> void:
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://menu/MainMenu.tscn")
