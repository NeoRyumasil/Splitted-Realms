extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://Scene/Game_Over.tscn")
	pass # Replace with function body.


func _on_restart_pressed():
	PlayerStatus.HP = 5
	PlayerStatus.MP = 5
	get_tree().change_scene_to_file("res://Scene/opening.tscn")
	pass # Replace with function body.
