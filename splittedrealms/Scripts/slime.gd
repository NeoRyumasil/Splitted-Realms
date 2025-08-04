extends CharacterBody2D

var SPEED = 80
var player: Node2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var chase = false
var health = 4

func _ready():
	$Animation.play("Idle")
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta):
	velocity.y += gravity * delta

	if chase and player and $Animation.animation != "Death":
		$Animation.play("Walk")
		var direction = (player.global_position - global_position).normalized()

		if direction.x < 0:
			$Animation.flip_h = false
		else:
			$Animation.flip_h = true

		velocity.x = direction.x * SPEED
	else:
		if $Animation.animation != "Death":
			$Animation.play("Idle")
		velocity.x = 0

	if health <= 0:
		death()

	move_and_slide()

func _on_player_detector_body_entered(body):
	if body.name == "Player":
		chase = true

func _on_player_detector_body_exited(body):
	if body.name == "Player":
		chase = false

func _on_hit_zone_body_entered(body):
	if body.name == "Projectile":
		$Animation.play("Hit")
		health -= 3

func death():
	velocity.x = 0
	$Animation.play("Death")
	await $Animation.animation_finished
	queue_free()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$Animation.play("Attack")
		PlayerStatus.HP -= 1
