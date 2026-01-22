extends RigidBody3D

@export var explosion_scene: PackedScene
@export var range_explosion := 3
@export var cell_size := 2.0

func _ready() -> void:
	await get_tree().create_timer(3.0).timeout
	explode()

func explode() -> void:
	_explode_direction(Vector3.RIGHT)
	_explode_direction(Vector3.LEFT)
	_explode_direction(Vector3.FORWARD)
	_explode_direction(Vector3.BACK)

	queue_free()

func _explode_direction(dir: Vector3) -> void:
	for i in range(1, range_explosion + 1):
		var pos := global_transform.origin + dir * cell_size * i
		_damage_at_position(pos)

func _damage_at_position(pos: Vector3) -> void:
	_spawn_explosion_visual(pos)
	
	var space := get_world_3d().direct_space_state

	var shape := BoxShape3D.new()

	shape.size = Vector3(cell_size, 2.0, cell_size)

	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = shape
	params.transform.origin = pos
	params.collision_mask = 1  

	var result := space.intersect_shape(params)

	for hit in result:
		var body: Node = hit["collider"]
		if body.has_method("_lose_life"):
			body._lose_life()

func _spawn_explosion_visual(pos: Vector3) -> void:
	var explosion = explosion_scene.instantiate()
	explosion.global_transform.origin = pos
	get_parent().add_child(explosion)
