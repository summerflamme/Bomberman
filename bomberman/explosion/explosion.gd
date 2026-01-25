extends RigidBody3D

@export var duration := 0.3

func _ready() -> void:
	await get_tree().create_timer(duration).timeout
	queue_free()
