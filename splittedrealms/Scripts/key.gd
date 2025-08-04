extends Node2D

var canInteract = false
@export var dialogResource = DialogueResource
@export var dialogStart : String = "Door"
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
	if PlayerStatus.haveKey == false:
		DialogueManager.show_example_dialogue_balloon(load("res://Dialogue/door_no_key.dialogue"), dialogStart)
	else:
		DialogueManager.show_example_dialogue_balloon(load("res://Dialogue/door_yes_key.dialogue"), dialogStart)
		PlayerStatus.haveKey = false
		
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file(target_scene_path) # ➕ pakai path dari variable
