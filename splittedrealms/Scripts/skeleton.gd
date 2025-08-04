extends CharacterBody2D

var SPEED = 80
var player
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var chase = false
var in_attack_range = false
var can_shoot = true
var health = 4

@export var arrow_scene: PackedScene  # drag and drop scene panah dari inspector

func _ready():
	$Animation.play("Idle")
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta):
	velocity.y += gravity * delta

	if health <= 0:
		death()
		return
	
	# Tidak gerak jika dalam area serang (cuma nembak)
	if in_attack_range:
		velocity.x = 0
		if $Animation.animation != "Death":
			$Animation.play("Idle")  # Bisa diganti animasi aiming
			if can_shoot:
				shoot_arrow()
	else:
		if chase:
			if $Animation.animation != "Death":
				$Animation.play("Walk")
				var direction = (player.position - self.position).normalized()
				if direction.x < 0:
					$Animation.flip_h = false
					velocity.x = direction.x * SPEED
				elif direction.x > 0:
					$Animation.flip_h = true
					velocity.x = direction.x * SPEED
		else:
			if $Animation.animation != "Death":
				$Animation.play("Idle")
			velocity.x = 0

	move_and_slide()

func _on_hit_zone_body_entered(body):
	if body.name == "Projectile":
		$Animation.play("Hit")
		health -= 3

func death():
	velocity.x = 0
	$Animation.play("Death")
	await $Animation.animation_finished
	queue_free()
	
func shoot_arrow():
	if player == null:
		player = get_parent().get_node("Player")  # pastikan player tidak null

	can_shoot = false
	$Animation.play("Attack")
	#await $Animation.animation_finished
	
	var arrow = arrow_scene.instantiate()
	get_parent().add_child(arrow)
	arrow.global_position = global_position

	var dir = (player.global_position - global_position).normalized()
	arrow.direction = dir

	await get_tree().create_timer(1.5).timeout
	can_shoot = true	

func _on_player_detector_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		in_attack_range = true
	pass # Replace with function body.


func _on_player_detector_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		in_attack_range = true
		shoot_arrow()
	pass # Replace with function body.
