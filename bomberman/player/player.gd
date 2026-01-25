extends CharacterBody3D

@onready var lose_menu = preload("res://menu/loseMenu.tscn")
@onready var win_menu = preload("res://menu/win_menu.tscn")
@onready var anim: AnimationPlayer = $Character/AnimationPlayer
@onready var sprite: Node3D = $Character
@onready var bomb_scene = preload("res://bombe/bombe.tscn")
@onready var gridmap: GridMap = get_parent().get_node("GridMap")

@export var vitesse := 10.0
@export var gravity := 9.8

const TILE_SIZE := 2.0
const MOVE_DURATION := 0.2

signal life_changed(new_life: int)

var life := 3
var invincible := false
var can_move := true
var is_dead := false
var is_hitting := false
var is_placing_bomb := false
var is_moving := false
var nb_bomb := 1
var facing_dir := Vector3.FORWARD
var start_position: Vector3
var grid_position: Vector3
var input_dir:= Vector3.ZERO

func _ready() -> void:
	grid_position = snap_to_grid(global_position)
	global_position = grid_position
	var enemy = get_parent().get_node("enemy")
	enemy.enemy_dead.connect(_on_enemy_enemy_dead)
	start_position = global_transform.origin
	anim.play("Idle")
func _physics_process(delta: float) -> void:
	if is_dead:
		return

	_apply_gravity(delta)

	if is_hitting or not can_move:
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		return

	_handle_input()
	move_and_slide()
	_check_collisions()
	
	if life <= 0:
		_lose_game()
		

func _handle_input() -> void:
	if is_moving:
		return
	
	if is_placing_bomb:
		return
	input_dir = Vector3.ZERO

	if Input.is_action_pressed("p1_right"):
		input_dir = Vector3.RIGHT
	elif Input.is_action_pressed("p1_left"):
		input_dir = Vector3.LEFT
	elif Input.is_action_pressed("p1_down"):
		input_dir = Vector3.BACK
	elif Input.is_action_pressed("p1_up"):
		input_dir = Vector3.FORWARD

	if input_dir != Vector3.ZERO:
		_try_move(input_dir)

	if Input.is_action_just_pressed("p1_bomb"):
		_place_bomb()

func is_direction_still_pressed(dir: Vector3) -> bool:
	if dir == Vector3.RIGHT:
		return Input.is_action_pressed("p1_right")
	if dir == Vector3.LEFT:
		return Input.is_action_pressed("p1_left")
	if dir == Vector3.FORWARD:
		return Input.is_action_pressed("p1_up")
	if dir == Vector3.BACK:
		return Input.is_action_pressed("p1_down")
	return false

func _is_cell_walkable(world_pos: Vector3) -> bool:
	var local_pos = gridmap.to_local(world_pos)
	var cell = gridmap.local_to_map(local_pos)
	return gridmap.get_cell_item(cell) == -1

func _try_move(dir: Vector3) -> void:
	if is_moving:
		return
	is_moving = true
	facing_dir = dir

	var target := grid_position + dir * TILE_SIZE
	
	if not _is_cell_walkable(target):
		anim.play("Idle")
		is_moving = false
		return
		
	sprite.look_at(global_position - dir, Vector3.UP)
	play_walk()
	var tween := create_tween()
	tween.tween_property(self, "global_position", target, MOVE_DURATION)
	await tween.finished

	grid_position = target
	global_position = grid_position
	is_moving = false
	if is_direction_still_pressed(dir):
		_try_move(dir)
	else:
		is_moving = false
		if not is_hitting:
			anim.speed_scale = 1.0
			anim.play("Idle")
		
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
		can_move = false
	else:
		velocity.y = 0
		can_move = true



func _check_collisions() -> void:
	for i in range(get_slide_collision_count()):
		var body := get_slide_collision(i).get_collider()
		if body is Enemy and not invincible:
			_lose_life()
			return

func _lose_life() -> void:
	if invincible or is_hitting:
		return
	life -= 1
	invincible = true
	can_move = false
	is_hitting = true

	anim.stop()
	anim.play("HitReact")
	await anim.animation_finished

	emit_signal("life_changed", life)

	if life > 0:
		global_position = start_position
		grid_position = snap_to_grid(start_position)
		velocity = Vector3.ZERO
		facing_dir = Vector3.FORWARD

	await get_tree().create_timer(0.7).timeout

	invincible = false
	is_hitting = false
	can_move = true

func _place_bomb() -> void:
	if nb_bomb <= 0 or is_placing_bomb:
		return

	is_placing_bomb = true
	nb_bomb -= 1

	anim.stop()
	anim.play("Punch")
	var bomb = bomb_scene.instantiate()
	var target_pos = snap_to_grid(global_transform.origin + facing_dir * TILE_SIZE)
	bomb.global_transform.origin = target_pos
	get_parent().add_child(bomb)

	bomb.tree_exited.connect(_on_bomb_destroyed)

	await get_tree().create_timer(1).timeout
	is_placing_bomb = false

func _on_bomb_destroyed() -> void:
	nb_bomb += 1


func _lose_game() -> void:
	if is_dead:
		return

	is_dead = true
	can_move = false

	anim.stop()
	anim.play("Death")
	await anim.animation_finished

	get_tree().change_scene_to_packed(lose_menu)

func snap_to_grid(pos: Vector3) -> Vector3:
	return Vector3(
		floor(pos.x / TILE_SIZE) * TILE_SIZE + TILE_SIZE / 2,
		pos.y,
		floor(pos.z / TILE_SIZE) * TILE_SIZE + TILE_SIZE / 2
	)

func _on_enemy_enemy_dead() -> void:
	get_tree().change_scene_to_packed(win_menu)


func play_walk() -> void:
	if is_hitting:
		return
	if anim.current_animation != "Walk":
		anim.speed_scale = 1.5
		anim.play("Walk")
