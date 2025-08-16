extends CharacterBody2D

# Atribut Player
const SPEED = 160.0
const JUMP_VELOCITY = -500.0

# Attribut Knockback
var knockback_force = Vector2.ZERO
var knockback_duration = 0.2
var knockback_timer = 0.0

# Realm Mask
const REALM1_MASK = 1
const REALM2_MASK = 2

# Nodes
@onready var tilemap1 = get_parent().get_node("TileMaps 1/TileMap") as TileMap
@onready var tilemap2 = get_parent().get_node("TileMaps 2/TileMap") as TileMap
@onready var background1 = get_parent().get_node("Backgrounds 1")
@onready var background2 = get_parent().get_node("Backgrounds 2")

# Packed Scenes
@export var projectile_scene: PackedScene

# Booleans
var in_realm_1 := true
var is_hit := false
var is_attack := false

func _ready():
	# Matikan tampilan realm 2 di awal
	tilemap2.visible = false
	background2.visible = false
	$Animation.play("Idle")
	add_to_group("player")

	# Player hanya deteksi realm 1 (layer 1)
	self.collision_mask = REALM1_MASK

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta

	# Jump
	if !PlayerStatus.onCutscene:
		if Input.is_action_just_pressed("Jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

	# Realm switch
		if Input.is_action_just_pressed("Shift Realms"):
			if PlayerStatus.haveOrb == true:
				switch_realm()

	# Mekanik Knockback
	if knockback_timer > 0:
		velocity = knockback_force
		knockback_timer -= delta
	# Movement
	else :
	# Movement
		var direction := Input.get_axis("Left", "Right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		animation_handler(direction)
		
		# Mekanik Nembak
		if Input.is_action_just_pressed("Shoot"):
			if PlayerStatus.haveOrb == true:
				shoot()
		
		# Escape
		if Input.is_action_just_pressed("Escape"):
			get_tree().change_scene_to_file("res://Scene/Game_Over.tscn")
	
	# Dead
	if PlayerStatus.HP <= 0 :
		$Animation.play("Death")
		queue_free()
		get_tree().change_scene_to_file("res://Scene/main_menu.tscn")
	
	# Restore MP
	if (PlayerStatus.MP < 5):
		MPRestore()
	
	# Restore HP
	if (PlayerStatus.HP < 5):
		HPRestore()
		
	move_and_slide()

# Buat Swithc Realm
func switch_realm():
	if in_realm_1:
		# Switch to Realm 2
		tilemap1.visible = false
		background1.visible = false

		tilemap2.visible = true
		background2.visible = true

		self.collision_mask = REALM2_MASK
		in_realm_1 = false
		print("Switched to Realm 2")
	else:
		# Switch back to Realm 1
		tilemap2.visible = false
		background2.visible = false

		tilemap1.visible = true
		background1.visible = true

		self.collision_mask = REALM1_MASK
		in_realm_1 = true
		print("Switched to Realm 1")

# Buat Nembak Projektil
func shoot():
	if !is_attack:
		# Animasi Nembal
		is_attack = true
		$Animation.play("Attack")
		
		# Spawn Projectile
		var projectile = projectile_scene.instantiate()
		projectile.global_position = global_position
		projectile.rotation = (get_global_mouse_position() - global_position).angle()
		get_tree().current_scene.add_child(projectile)
		
		# Cooldown
		await $Animation.animation_finished
		PlayerStatus.MP -= 1
		$Animation.play("Idle")
		is_attack = false

# Handling Animasi
func animation_handler(direction):
	# Kalau lagi nyerang return
	if is_hit or is_attack: return
	
	# Handling Animasi
	if $Animation.animation not in ["Death", "Hit", "Attack"]:
		# Bolak-Balik
		if direction == 1:
			$Animation.flip_h = false
			velocity.x = direction * SPEED
		elif direction == -1:
			$Animation.flip_h = true
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		# Loncat dan Jalan
		if velocity.y < 0:
			$Animation.play("Jump")
		elif velocity.y == 0 and velocity.x != 0:
			$Animation.play("Walk")
		else:
			$Animation.play("Idle")

# Restore MP
func MPRestore():
	PlayerStatus.MP += 0.01

# Restore HP
func HPRestore():
	PlayerStatus.HP += 0.01

# Kalau kena musuh
func _on_hit_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and not is_hit:
		is_hit = true
		$Animation.play("Hit")
		
		# Knockback
		var direction = (global_position - body.global_position).normalized()
		knockback_force = direction * 300
		knockback_timer = knockback_duration
		
		# Cooldown
		await $Animation.animation_finished
		$Animation.play("Idle")
		is_hit = false

# Kalau kena projectile
func _on_hit_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") and not is_hit:
		is_hit = true
		$Animation.play("Hit")
		
		# Knockback
		var direction = (global_position - area.global_position).normalized()
		knockback_force = direction * 300
		knockback_timer = knockback_duration
		
		# Cooldown
		await $Animation.animation_finished
		$Animation.play("Idle")
		is_hit = false
