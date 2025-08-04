extends Node2D

var canInteract = false
@export var dialogResource = DialogueResource
@export var target_scene_path: String = "res://Scenes/Castle.tscn" # ➕ Bisa diganti dari Inspector

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Interact") && canInteract:
		_interaction()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		canInteract = true
		$Tutorial.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		canInteract = false
		$Tutorial.visible = false

func _interaction():
	get_tree().change_scene_to_file(target_scene_path) # ➕ pakai path dari variable
