extends Node2D

var canInteract = false
@export var dialogResource = DialogueResource
@export var target_scene_path: String = "res://Scenes/puzzle1.tcsn" # ➕ Bisa diganti dari Inspector
@export var dialogStart : String = "door"

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
	if PlayerStatus.haveKey:
		get_tree().change_scene_to_file(target_scene_path)
		PlayerStatus.haveKey = false
	else :
		DialogueManager.show_example_dialogue_balloon(load("res://Dialogue/door.dialogue"), dialogStart)
		 # ➕ pakai path dari variable
