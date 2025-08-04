extends Camera2D

@export var target_node_path: NodePath
 # batas kamera, bisa kamu atur di inspector

var target: Node2D

func _ready():
	if target_node_path != null:
		target = get_node(target_node_path)

func _process(delta):
	if target:
		var new_position = target.global_position
		global_position = new_position
