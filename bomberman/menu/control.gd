extends Control


func _on_main_menu_btn_button_down() -> void:
	get_tree().change_scene_to_file("res://menu/MainMenu.tscn")
