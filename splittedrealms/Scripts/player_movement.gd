extends CharacterBody2D

const SPEED = 160.0
const JUMP_VELOCITY = -500.0

const REALM1_MASK = 1
const REALM2_MASK = 2

@onready var tilemap1 = get_parent().get_node("TileMaps 1/TileMap") as TileMap
@onready var tilemap2 = get_parent().get_node("TileMaps 2/TileMap") as TileMap
@onready var background1 = get_parent().get_node("Backgrounds 1")
@onready var background2 = get_parent().get_node("Backgrounds 2")

@export var projectile_scene: PackedScene

var in_realm_1 := true

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

	# Movement
		var direction := Input.get_axis("Left", "Right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		animation_handler(direction)
		
		if Input.is_action_just_pressed("Shoot"):
			if PlayerStatus.haveOrb == true:
				shoot()
				
		if Input.is_action_just_pressed("Escape"):
			get_tree().change_scene_to_file("res://Scene/Game_Over.tscn")
	
	if PlayerStatus.HP <= 0 :
		$Animation.play("Death")
		queue_free()
		get_tree().change_scene_to_file("res://Scene/main_menu.tscn")
		
	move_and_slide()

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
	
	if (PlayerStatus.MP < 5):
		MPRestore()
		
	if (PlayerStatus.HP < 5):
		HPRestore()

func shoot():
	$Animation.play("Attack")
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.rotation = (get_global_mouse_position() - global_position).angle()
	get_tree().current_scene.add_child(projectile)
	PlayerStatus.MP -= 1

func animation_handler(direction):
	if $Animation.animation != "Death" :
		if direction == 1:
			$Animation.flip_h = false
			velocity.x = direction * SPEED
		elif direction == -1:
			$Animation.flip_h = true
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	#Animasi
		if velocity.y < 0:
			$Animation.play("Jump")
		elif velocity.y == 0 && velocity.x != 0 :
			$Animation.play("Walk")
		else :
			$Animation.play("Idle")

func MPRestore():
	PlayerStatus.MP += 0.01

func HPRestore():
	PlayerStatus.HP += 0.01

func _on_hit_zone_body_entered(body: Node2D) -> void:
	if (body.name == "Armor" || body.name == "Slime" || body.name == "Arrow" || body.name == "Skeleton"):
		$Animation.play("Hit")
	pass # Replace with function body.
