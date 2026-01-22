extends CanvasLayer

func _ready():
	var player = get_parent().get_node("player")
	player.connect("life_changed", Callable(self, "_update_lives_label"))

func _update_lives_label(new_life):
	
	var atlas1 := %heart1.texture as AtlasTexture
	var atlas2 := %heart2.texture as AtlasTexture
	var atlas3 := %heart3.texture as AtlasTexture
	
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
