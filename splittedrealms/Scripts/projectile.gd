extends Area2D

@export var speed: float = 500.0
@export var lifetime: float = 2.0  # waktu hidup sebelum auto-destroy

var velocity: Vector2 = Vector2.ZERO

func _ready():
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += velocity * delta

func _on_body_entered(body):
	# Kalau kena objek, bisa dihancurkan
	if body.name != "Player":
		print("Hit:", body.name)
		queue_free()
