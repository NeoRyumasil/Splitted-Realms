extends CharacterBody2D

# Atribut Objek
var SPEED = 80
var health = 4
var is_dead := false

# Attribut Knockback
var knockback_force = Vector2.ZERO
var knockback_duration = 0.2
var knockback_timer = 0.0

# Nodes
var player
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Booleans
var chase = false
var in_attack_range = false
var can_shoot = true
var is_hit := false

# Packed Scene
@export var arrow_scene: PackedScene 

func _ready():
	# Set Animasi dan Player
	$Animation.play("Idle")
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta):
	# Kalau Mati Gak bakal dijalanin
	if is_dead:
		return  
	
	# Set Gravitasi
	velocity.y += gravity * delta
	
	# Animasi Bolak-Balik
	if player != null:
		if player.global_position.x > global_position.x:
			if $Animation.animation not in ["Death", "Hit"]:
				$Animation.flip_h = true
		else:
			$Animation.flip_h = false
	
	# Kondisi Mati
	if health <= 0:
		death()
		return
	
	# Mekanik Knockback
	if knockback_timer > 0:
		velocity = knockback_force
		knockback_timer -= delta
	# Mekanik Serang
	else :
		if in_attack_range:
			velocity.x = 0
			if not is_hit and $Animation.animation not in ["Death", "Hit", "Attack"]:
				if can_shoot:
					shoot_arrow()
		else:
			if not is_hit and $Animation.animation != "Death":
				$Animation.play("Idle")

	move_and_slide()

# Mekanik kena damage
func _on_hit_zone_area_entered(area: Area2D) -> void:
	if area.name == "Projectile":
		health -= 3
		is_hit = true
		can_shoot = false
		$Animation.play("Hit")
		
		# Mekanik Knockback
		var direction = (global_position - area.global_position).normalized()
		knockback_force = direction * 300
		knockback_timer = knockback_duration
		
		# Cooldown
		await get_tree().create_timer(0.4).timeout
		is_hit = false
		can_shoot = true
		
		if not is_dead:
			$Animation.play("Idle")

# Meninggal
func death():
	if is_dead:
		return
		
	is_dead = true
	velocity = Vector2.ZERO
	$Animation.play("Death")
	await get_tree().create_timer(0.6).timeout
	queue_free()

# Mekanik nembak
func shoot_arrow():
	# Deteksi Player
	if player == null:
		player = get_parent().get_node("Player")
	
	# Animasi Nembak
	can_shoot = false
	$Animation.play("Attack")
	await get_tree().create_timer(0.4).timeout
	
	# Spawn Arrow
	var arrow = arrow_scene.instantiate()
	get_parent().add_child(arrow)
	arrow.global_position = global_position
	
	# Arah dan Rotasi Arrow
	var dir = (player.global_position - global_position).normalized()
	arrow.direction = dir
	arrow.rotation = dir.angle()
	
	# Cooldown
	await get_tree().create_timer(1.5).timeout
	can_shoot = true
	if not is_dead and not is_hit:
		$Animation.play("Idle")

# Deteksi Player yang masuk ke area serang
func _on_player_detector_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		in_attack_range = true

# Deteksi Player yang keluar dari area serang
func _on_player_detector_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		in_attack_range = false
