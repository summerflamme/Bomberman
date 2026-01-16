extends CanvasLayer

func _ready():
	var player = get_node("/root/main/player") 
	player.connect("life_changed", Callable(self, "_update_lives_label"))

func _update_lives_label(new_life):
	$HBoxContainer/LivesLabel.text ="Vies restantes : " +  "❤️ ".repeat(new_life)
