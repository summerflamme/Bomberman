extends CharacterBody3D

class_name Enemy

@export var vitesse:= 5
@export var gravity:=9.8
@onready var rayCast: RayCast3D = $FloorDetector


var direction:= Vector3.ZERO

func _ready():
	randomize()
	await get_tree().create_timer(1).timeout
	_chooose_random_direction()
	await get_tree().physics_frame
	
	var timer := Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(_chooose_random_direction)
	add_child(timer)
	_chooose_random_direction()	

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = -0.1

	if is_on_floor():
		if not rayCast.is_colliding():
			_chooose_random_direction()

	velocity.x = direction.x * vitesse
	velocity.z = direction.z * vitesse

	move_and_slide()

func _chooose_random_direction():
	var x := randi_range(-1, 1)
	var z := randi_range(-1, 1)
	if x == 0 and z == 0:
		x = 1
	direction = Vector3(x, 0, z).normalized()
