extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerStatus.HP = 5
	PlayerStatus.MP = 5
	PlayerStatus.haveKey = false
	PlayerStatus.haveOrb = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/Game_Over.tscn")
	pass # Replace with function body.
