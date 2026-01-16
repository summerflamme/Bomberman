extends CharacterBody3D

@onready var loseMenu = preload("res://menu/loseMenu.tscn")

@export var vitesse:= 5
@export var gravity:= 9.8

var life: int = 3
var invincible:= false
var start_position: Vector3
var can_moove:= false

signal life_changed(new_life: int)

func _ready() -> void:
	start_position = global_transform.origin
	
func _physics_process(delta: float) -> void:
	
	if not can_moove:
		velocity.x = 0
		velocity.z = 0
		if not is_on_floor():
			velocity.y -= gravity * delta
			can_moove = false
		else:
			velocity.y = 0
			can_moove = true

		move_and_slide()
		return 
		
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		can_moove = false
	else:
		velocity.y = 0
		can_moove = true

	var direction := Vector3.ZERO

	if Input.is_action_pressed("p1_right"):
		direction.x += 1
	if Input.is_action_pressed("p1_left"):
		direction.x -= 1
	if Input.is_action_pressed("p1_up"):
		direction.z -= 1
	if Input.is_action_pressed("p1_down"):
		direction.z += 1

	direction = direction.normalized()
	velocity.x = direction.x * vitesse
	velocity.z = direction.z * vitesse

	move_and_slide()
	_check_collisions()
	
	if life == -1: 
		get_tree().change_scene_to_packed(loseMenu)
		
	
func _check_collisions():
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var body := collision.get_collider()

		if body is Enemy and not invincible:
			_lose_life()
			
func _lose_life():
	life -= 1
	invincible = true
	can_moove = false
	print("Vie restante :", life)
	emit_signal("life_changed", life)
	
	global_transform.origin = start_position
	velocity = Vector3.ZERO

	await get_tree().create_timer(0.7).timeout
	invincible = false	
	can_moove = true	
