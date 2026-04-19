extends Area2D
class_name SceneTransition

@export var target_scene: PackedScene

func _ready():
	body_entered.connect(_on_body_entered)
	return

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return

	if body.has_method("save_state"):
		body.save_state()

	get_tree().change_scene_to_packed(target_scene)
	return
