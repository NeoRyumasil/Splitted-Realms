extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

const REALM1_MASK = 1
const REALM2_MASK = 2

@onready var tilemap1 = get_parent().get_node("TileMaps 1/TileMap") as TileMap
@onready var tilemap2 = get_parent().get_node("TileMaps 2/TileMap") as TileMap
@onready var background1 = get_parent().get_node("Backgrounds 1")
@onready var background2 = get_parent().get_node("Backgrounds 2")

var in_realm_1 := true

func _ready():
	# Matikan tampilan realm 2 di awal
	tilemap2.visible = false
	background2.visible = false

	# Player hanya deteksi realm 1 (layer 1)
	self.collision_mask = REALM1_MASK

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta

	# Jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Realm switch
	if Input.is_action_just_pressed("Shift Realms"):
		switch_realm()

	# Movement
	var direction := Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

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
