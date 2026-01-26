extends CharacterBody3D
class_name Enemy

@export var vitesse := 5.0
@export var gravity := 9.8

@onready var anim: AnimationPlayer = $Character/AnimationPlayer
@onready var sprite: Node3D = $Character
@onready var bomb_scene = preload("res://bombe/bombe.tscn")
@onready var wall_detection: RayCast3D = $WallDetection
@onready var gridmap: GridMap = get_parent().get_node("GridMap")

signal enemy_dead 

const TILE_SIZE := 2.0
const MOVE_DURATION := 0.2
var life := 10
var invincible := false
var can_move := true
var can_place_bomb := true
var is_hitting := false
var is_dead := false
var is_placing_bomb := false
var is_moving := false
var nb_bomb := 1
var direction := Vector3.ZERO
var facing_dir := Vector3.FORWARD
var grid_position: Vector3
var start_position: Vector3

func _ready() -> void:
	grid_position = snap_to_grid(global_position)
	global_position = grid_position
	start_position = global_transform.origin
	randomize()
	anim.play("Idle")
	await get_tree().create_timer(1.0).timeout
	_choose_random_direction()

	var timer := Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(_choose_random_direction)
	add_child(timer)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if can_place_bomb == false:
		return
		
	_apply_gravity(delta)

	if is_hitting or not can_move:
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		return

	if not is_placing_bomb:
		_update_wall_ray()
		_check_wall_and_bomb()

	move_and_slide()

	if life <= 0:
		_lose_game()
		
func try_move(dir: Vector3) -> void:
	if is_moving:
		return

	is_moving = true
	facing_dir = dir

	var target := grid_position + dir * TILE_SIZE

	if not _is_cell_walkable(target):
		is_moving = false
		anim.play("Idle")
		return

	sprite.look_at(global_position - dir, Vector3.UP)
	play_walk()

	var tween := create_tween()
	tween.tween_property(self, "global_position", target, MOVE_DURATION)
	await tween.finished

	grid_position = target
	global_position = grid_position
	is_moving = false
	if not is_hitting:
		anim.play("Idle")


func play_walk() -> void:
	if is_hitting:
		return
	if anim.current_animation != "Walk":
		anim.speed_scale = 1.5
		anim.play("Walk")


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
		can_move = false
	else:
		velocity.y = -0.1
		can_move = true

func _is_cell_walkable(world_pos: Vector3) -> bool:
	var local_pos = gridmap.to_local(world_pos)
	var cell = gridmap.local_to_map(local_pos)
	return gridmap.get_cell_item(cell) == -1

func _choose_random_direction() -> void:
	if is_dead or is_moving or is_placing_bomb or is_hitting:
		return
		
	_check_wall_and_bomb()
	
	var directions = [
		Vector3.FORWARD,
		Vector3.BACK,
		Vector3.LEFT,
		Vector3.RIGHT
	]
	directions.shuffle()
	for dir in directions:
		var target_pos = grid_position + dir * TILE_SIZE
		if _is_cell_walkable(target_pos):
			try_move(dir)
			return
	if not is_hitting:
		anim.play("Idle")
		
		
func _update_wall_ray() -> void:
	wall_detection.target_position = facing_dir * TILE_SIZE
	
	
func _get_cell_in_front() -> Vector3i:
	var front_pos = global_transform.origin + facing_dir * TILE_SIZE
	var local_pos = gridmap.to_local(front_pos)
	return gridmap.local_to_map(local_pos)
		
func _check_wall_and_bomb() -> void:
	if is_placing_bomb:
		return

	var cell = _get_cell_in_front()
	var item_id = gridmap.get_cell_item(cell)
	
	if item_id == 0:  
		_place_bomb()

func _lose_life() -> void:
	life -= 1
	invincible = true
	can_move = false
	is_hitting = true

	anim.stop()
	anim.play("HitReact")
	await anim.animation_finished

	if life > 0:
		global_position = start_position
		grid_position = snap_to_grid(start_position)
		velocity = Vector3.ZERO
		facing_dir = Vector3.FORWARD

	await get_tree().create_timer(0.7).timeout

	invincible = false
	is_hitting = false
	can_move = true


func _lose_game() -> void:
	if is_dead:
		return

	is_dead = true
	can_move = false

	anim.stop()
	anim.play("Death")
	await anim.animation_finished
	emit_signal("enemy_dead")
	queue_free()

func _place_bomb() -> void:
	if nb_bomb <= 0 or is_placing_bomb:
		return

	is_placing_bomb = true
	nb_bomb -= 1

	var bomb = bomb_scene.instantiate()
	var target_pos = snap_to_grid(global_transform.origin)
	bomb.global_transform.origin = target_pos
	get_parent().add_child(bomb)

	bomb.tree_exited.connect(_on_bomb_destroyed)

	await get_tree().create_timer(1.0).timeout
	is_placing_bomb = false

func _on_bomb_destroyed() -> void:
	nb_bomb += 1

func snap_to_grid(pos: Vector3) -> Vector3:
	return Vector3(
		floor(pos.x / TILE_SIZE) * TILE_SIZE + TILE_SIZE / 2,
		pos.y,
		floor(pos.z / TILE_SIZE) * TILE_SIZE + TILE_SIZE / 2
	)
