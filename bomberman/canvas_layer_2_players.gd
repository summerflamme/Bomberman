extends CanvasLayer

func _ready():
	var player1 = get_parent().get_node("player1")
	player1.connect("P1_life_changed", Callable(self, "_update_lives_label_P1"))
	var player2 = get_parent().get_node("player2")
	player2.connect("P2_life_changed", Callable(self, "_update_lives_label_P2"))

func _update_lives_label_P1(new_life):
	
	var atlas1 := %P1_heart1.texture as AtlasTexture
	var atlas2 := %P1_heart2.texture as AtlasTexture
	var atlas3 := %P1_heart3.texture as AtlasTexture
	
	match new_life: 
		0: 	
			_set_empty_heart(atlas1)
			_set_empty_heart(atlas2)
			_set_empty_heart(atlas3)
		1: 
			_set_full_heart(atlas1)
			_set_empty_heart(atlas2)
			_set_empty_heart(atlas3)
		2 : 
			_set_full_heart(atlas1)
			_set_full_heart(atlas2)
			_set_empty_heart(atlas3)
		3 : 
			_set_full_heart(atlas1)
			_set_full_heart(atlas2)
			_set_full_heart(atlas3)
			
func _update_lives_label_P2(new_life):
	
	var atlas1 := %P2_heart1.texture as AtlasTexture
	var atlas2 := %P2_heart2.texture as AtlasTexture
	var atlas3 := %P2_heart3.texture as AtlasTexture
	
	match new_life: 
		0: 	
			_set_empty_heart(atlas1)
			_set_empty_heart(atlas2)
			_set_empty_heart(atlas3)
		1: 
			_set_full_heart(atlas1)
			_set_empty_heart(atlas2)
			_set_empty_heart(atlas3)
		2 : 
			_set_full_heart(atlas1)
			_set_full_heart(atlas2)
			_set_empty_heart(atlas3)
		3 : 
			_set_full_heart(atlas1)
			_set_full_heart(atlas2)
			_set_full_heart(atlas3)
			
func _set_full_heart(atlas: AtlasTexture):
	atlas.region = Rect2(Vector2(1.0, 1.0), Vector2(14.0, 13.0))
	
func _set_empty_heart(atlas: AtlasTexture):
	atlas.region =  Rect2(Vector2(17.0,1.0), Vector2(14.0,13.0))
