extends CharacterBody2D

# Attribut Objek
var SPEED = 60
var health = 15

# Attribut Knockback
var knockback_force = Vector2.ZERO
var knockback_duration = 0.2
var knockback_timer = 0.0

# Nodes
var player
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Booleans
var is_hit = false
var is_attack = false
var chase = false

func _ready():
	# Set Player dan Animasi
	$Animation.play("Idle")
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

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
		if is_hit or is_attack:
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

func _on_player_detector_body_entered(body):
	if body.name == "Player":
		chase = true
	pass # Replace with function body.

func _on_player_detector_body_exited(body):
	if body.name == "Player":
		chase = false
	pass # Replace with function body.

func _on_hit_zone_area_entered(area: Area2D) -> void:
	# Mekanik Kena Projectile
	if area.name == "Projectile":
		$Animation.play("Hit")
		health -= 3
		is_hit = true
		
		# Mekanik Knockback
		var direction = (global_position - area.global_position).normalized()
		knockback_force = direction * 300
		knockback_timer = knockback_duration

		await $Animation.animation_finished
		is_hit = false

# Meninggal
func death():
	velocity.x = 0
	$Animation.play("Death")
	await $Animation.animation_finished
	self.queue_free()

# Serang
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("Hit")
		PlayerStatus.HP -= 2
		is_attack = true
		$Animation.play("Attack")
		
		await $Animation.animation_finished
		is_attack = false
	pass # Replace with function body.

# Player keluar dari area serang
func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		is_attack = false
	pass # Replace with function body.
