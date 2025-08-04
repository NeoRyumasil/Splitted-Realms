extends CharacterBody2D

var SPEED = 80
var player
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var chase = false
var health = 15

func _ready():
	$Animation.play("Idle")

func _physics_process(delta):
	velocity.y += gravity * delta
	if chase == true :
		if $Animation.animation != "Death":
			$Animation.play("Walk")
			player = get_parent().get_node("Player")
			var direction = (player.position - self.position).normalized()
			if direction.x < 0:
				$Animation.flip_h = false
				velocity.x = direction.x * SPEED
			elif direction.x > 0 :
				$Animation.flip_h = true
				velocity.x = direction.x * SPEED
	else :
		if $Animation.animation != "Death":
			$Animation.play("Idle")
		velocity.x = 0
	
	if health <= 0 :
		death()
	move_and_slide()

func _on_player_detector_body_entered(body):
	if body.name == "Player":
		chase = true
	pass # Replace with function body.

func _on_player_detector_body_exited(body):
	if body.name == "Player":
		chase = false
	pass # Replace with function body.

func _on_hit_zone_body_entered(body):
	if body.name == "Projectile":
		$Animation.play("Hit")
		health -= 3;
	pass # Replace with function body.

func death():
	velocity.x = 0
	$Animation.play("Death")
	await $Animation.animation_finished
	self.queue_free()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$Animation.play("Attack")
		PlayerStatus.HP -= 2
	pass # Replace with function body.
