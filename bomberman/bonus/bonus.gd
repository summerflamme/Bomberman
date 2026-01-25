extends Area3D

enum BonusType {
	RANGE,
	BOMB
}

var bonus_type: BonusType

@onready var fruit: Node3D = $Fruit
var mesh: MeshInstance3D = null


func _ready():
	randomize()

	bonus_type = randi() % 2

	for child in fruit.get_children():
		if child is MeshInstance3D:
			mesh = child
			break

	if mesh:
		_apply_color()
	else:
		push_error("ERREUR : aucun MeshInstance3D trouvé dans Fruit")

	body_entered.connect(_on_body_entered)

func _apply_color():
	var mat := StandardMaterial3D.new()

	match bonus_type:
		BonusType.RANGE:
			mat.albedo_color = Color(1.0, 0.2, 0.2)
		BonusType.BOMB:
			mat.albedo_color = Color(0.2, 0.2, 1.0)

	mesh.material_override = mat

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return

	match bonus_type:
		BonusType.RANGE:
			body.range_explosion += 1
		BonusType.BOMB:
			body.nb_bomb += 1

	queue_free()
