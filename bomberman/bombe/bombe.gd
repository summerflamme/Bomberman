extends StaticBody3D
@onready var gridmap: GridMap = get_tree().current_scene.get_node("GridMap")

@onready var bombe_sprite : Node3D = $Bomb2
@export var explosion_scene: PackedScene
@export var range_explosion := 1
@export var cell_size := 2.0


func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	bombe_sprite.scale *= 1.5
	await get_tree().create_timer(1.0).timeout
	bombe_sprite.scale *= 1.5 
	await get_tree().create_timer(1.0).timeout
	

	explode()
	
func snap_to_grid(pos: Vector3) -> Vector3:
	return Vector3(
		floor(pos.x / cell_size) * cell_size + cell_size / 2,
		pos.y,
		floor(pos.z / cell_size) * cell_size + cell_size / 2
	)


func explode() -> void:
	_damage_at_position(snap_to_grid(global_transform.origin))

	_explode_direction(Vector3.RIGHT)
	_explode_direction(Vector3.LEFT)
	_explode_direction(Vector3.FORWARD)
	_explode_direction(Vector3.BACK)

	queue_free()

func _explode_direction(dir: Vector3) -> void:
	for i in range(1, range_explosion + 1):
		var pos := global_transform.origin + dir * cell_size * i
		pos = snap_to_grid(pos)

		if _damage_at_position(pos):
			break

func _damage_at_position(pos: Vector3) -> bool:
	var cell := _get_grid_cell_from_world(pos)
	var item_id := gridmap.get_cell_item(cell)
	if item_id == 1:
		return true
	if item_id == 0:
		gridmap.set_cell_item(cell, -1)
		return true

	var space := get_world_3d().direct_space_state	
	var shape := BoxShape3D.new()
	shape.size = Vector3(cell_size, 2.0, cell_size)

	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = shape
	params.transform.origin = pos
	params.collision_mask = 1

	var result := space.intersect_shape(params)

	_spawn_explosion_visual(pos)

	for hit in result:
		var body: Node = hit["collider"]
		if body.has_method("_lose_life") and not body.invincible:
			body._lose_life()

	return false

func _spawn_explosion_visual(pos: Vector3) -> void:
	var explosion = explosion_scene.instantiate()
	explosion.global_transform.origin = pos
	get_parent().add_child(explosion)
	
func _get_grid_cell_from_world(pos: Vector3) -> Vector3i:
	var local_pos = gridmap.to_local(pos)
	return gridmap.local_to_map(local_pos)
