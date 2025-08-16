extends CharacterBody2D

# Attribut Slime
var SPEED = 80
var health = 4

# Attribut Knockback
var knockback_force = Vector2.ZERO
var knockback_duration = 0.2
var knockback_timer = 0.0

# Nodes
var player: Node2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Booleans
var chase = false
var is_hit = false

func _ready():
	# Set animasi dan player
	$Animation.play("Idle")
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	add_to_group("enemy")

func _physics_process(delta):
	# Set Gravity Physics
	velocity.y += gravity * delta
	
	# Death
	if health <= 0:
		death()
		return

	# Knockback Physics
	if knockback_timer > 0:
		velocity = knockback_force
		knockback_timer -= delta
	else:
		# Hit Physics
		if is_hit:
			velocity.x = 0
		elif chase and player:
			# Pergerakan
			var direction = (player.global_position - global_position).normalized()
			velocity.x = direction.x * SPEED

			# Flip animasi sesuai arah
			$Animation.flip_h = direction.x > 0

			# Animasi Jalan
			if abs(velocity.x) > 10:
				$Animation.play("Walk")
			else:
				$Animation.play("Idle")
		else:
			velocity.x = 0
			$Animation.play("Idle")

	move_and_slide()


func _on_hit_zone_area_entered(area: Area2D) -> void:
	# Mekanik kena projectile
	if area.name == "Projectile":
		health -= 3
		is_hit = true
		$Animation.play("Hit")
		
		# Mekanik Knockback
		var direction = (global_position - area.global_position).normalized()
		knockback_force = direction * 300
		knockback_timer = knockback_duration

		await $Animation.animation_finished
		is_hit = false

# Mekanik deteksi Player
func _on_player_detector_body_entered(body):
	if body.is_in_group("player"):
		chase = true

func _on_player_detector_body_exited(body):
	if body.is_in_group("player"):
		chase = false

# Meninggal
func death():
	velocity.x = 0
	$Animation.play("Death")
	await $Animation.animation_finished
	queue_free()
