extends CharacterBody3D
class_name Enemy

@export var vitesse := 5
@export var gravity := 9.8

@onready var anim: AnimationPlayer = $Character/AnimationPlayer
@onready var sprite: Node3D = $Character

var direction := Vector3.ZERO
var is_move := false

func _ready():
	randomize()
	anim.play("Idle")

	await get_tree().create_timer(1).timeout
	_choose_random_direction()

	var timer := Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(_choose_random_direction)
	add_child(timer)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = -0.1


	velocity.x = direction.x * vitesse
	velocity.z = direction.z * vitesse

	is_move = direction != Vector3.ZERO

	if is_move:
		anim.play("Walk")
	else:
		anim.play("Idle")

	if direction != Vector3.ZERO:
		sprite.look_at(global_position - direction, Vector3.UP)

	move_and_slide()

func _choose_random_direction():
	var axis := randi_range(0, 1)

	if axis == 0:
		var x := randi_range(-1, 1)
		if x == 0:
			x = 1
		direction = Vector3(x, 0, 0)
	else:
		var z := randi_range(-1, 1)
		if z == 0:
			z = 1
		direction = Vector3(0, 0, z)
