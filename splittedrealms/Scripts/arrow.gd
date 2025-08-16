extends Area2D

@export var speed: float = 500.0
@export var lifetime: float = 2.0  # waktu hidup sebelum auto-destroy

var velocity: Vector2 = Vector2.ZERO
var direction = Vector2.ZERO

func _physics_process(delta):
	position += direction * speed * delta

func _ready():
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	add_to_group("enemy")
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _on_body_entered(body):
	# Kalau kena objek, bisa dihancurkan
	if body.is_in_group("player"):
		PlayerStatus.HP -= 1
		print("Hit:", body.name)
		queue_free()
