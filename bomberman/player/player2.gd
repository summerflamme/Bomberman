extends CharacterBody3D

@onready var loseMenu = preload("res://menu/loseMenu.tscn")
@onready var anim: AnimationPlayer = $Character/AnimationPlayer
@onready var sprite: Node3D = $Character

@export var vitesse:= 10
@export var gravity:= 9.8

var life: int = 3
var invincible:= false
var start_position: Vector3
var can_moove:= false
var is_moove:= false
var is_death:= false 


signal life_changed(new_life: int)

func _ready() -> void:
	start_position = global_transform.origin
	anim.play("Idle")
func _physics_process(delta: float) -> void:
	
	if is_death == false:
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

		var x_input := int(Input.is_action_pressed("p2_right")) - int(Input.is_action_pressed("p2_left"))
		var z_input := int(Input.is_action_pressed("p2_down")) - int(Input.is_action_pressed("p2_up"))

		if x_input != 0:
			direction.x = x_input
		elif z_input != 0:
			direction.z = z_input

		is_moove = direction != Vector3.ZERO
				
		if is_moove:
			anim.play("Walk")
		else :
			anim.play("Idle")

		direction = direction.normalized()
		velocity.x = direction.x * vitesse
		velocity.z = direction.z * vitesse
		is_moove = false
		if direction != Vector3.ZERO:
			sprite.look_at(global_position - direction, Vector3.UP)
		move_and_slide()
		_check_collisions()
		
		if life == 0: 
			_lose_game()
		
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
	
	if life > 0:
		global_transform.origin = start_position
		velocity = Vector3.ZERO

	await get_tree().create_timer(0.7).timeout
	invincible = false	
	can_moove = true	
	
func _lose_game():
	is_death = true
	anim.play("Death")	
	can_moove = false
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_packed(loseMenu)
