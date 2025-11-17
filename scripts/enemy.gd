extends CharacterBody2D

# --- Constants ---
const ATTACK_RANGE = 20
const HIT_FRAME = 6
const PATROL_SPEED = 70
const CHASE_SPEED = 90
const DETECTION_RANGE = 70
const STOP_DISTANCE = 20
const GRAVITY = 800

# --- Nodes ---
@onready var idle_sprite: AnimatedSprite2D = $enemy_idle
@onready var attack_sprite: AnimatedSprite2D = $enemy_attack
@onready var death_sprite: AnimatedSprite2D = $enemy_death
@onready var walk_sprite: AnimatedSprite2D = $enemy_walk
@onready var damage_box: Node2D = $damage_box

# --- Variables ---
var is_attacking: bool = false
var hit_done: bool = false
var is_dead: bool = false
var health: int = 2
var patrol_direction: int = 1
var velocity_x: float = 0
var facing_right: bool = true

# --- Ready ---
func _ready():
	add_to_group("enemies")
	_show_only(idle_sprite)
	idle_sprite.play("idle")
	damage_box.visible = true

# --- Physics ---
func _physics_process(delta):
	if is_dead:
		return

	velocity.y += GRAVITY * delta

	var player = get_tree().get_first_node_in_group("player")
	var facing_player = false

	if player:
		var dist_to_player = global_position.distance_to(player.global_position)

		# --- Attack ---
		if dist_to_player < ATTACK_RANGE and not is_attacking:
			start_attack()
			facing_player = true
			return

		# Deal damage on hit frame
		if is_attacking and attack_sprite.frame == HIT_FRAME and not hit_done:
			_deal_damage_to_player(player)
			hit_done = true

		# --- Chase ---
		if dist_to_player < DETECTION_RANGE:
			facing_player = true
			var direction = sign(player.global_position.x - global_position.x)
			if dist_to_player > STOP_DISTANCE:
				velocity_x = direction * CHASE_SPEED
			else:
				velocity_x = 0
			velocity.x = velocity_x
			move_and_slide()
			_update_animation()
			_flip_sprites(direction > 0)
			return

	# --- Patrol ---
	_patrol(delta)

	if not facing_player:
		_flip_sprites(velocity_x > 0)

# --- Patrol ---
func _patrol(delta):
	velocity_x = patrol_direction * PATROL_SPEED
	velocity.x = velocity_x
	move_and_slide()
	if is_on_wall() or not is_on_floor():
		patrol_direction *= -1
	_update_animation()

# --- Animation ---
func _update_animation():
	if is_attacking:
		_show_only(attack_sprite)
		attack_sprite.play("attack")
	elif abs(velocity.x) > 0:
		_show_only(walk_sprite)
		walk_sprite.play("walk")
	else:
		_show_only(idle_sprite)
		idle_sprite.play("idle")

# --- Flip ---
func _flip_sprites(flip: bool):
	facing_right = flip
	idle_sprite.flip_h = not flip
	attack_sprite.flip_h = not flip
	walk_sprite.flip_h = not flip
	damage_box.position.x = -abs(damage_box.position.x) if not flip else abs(damage_box.position.x)

# --- Attack ---
func start_attack():
	is_attacking = true
	hit_done = false
	_show_only(attack_sprite)
	attack_sprite.play("attack")
	await attack_sprite.animation_finished
	if is_dead:
		return
	is_attacking = false
	_show_only(idle_sprite)
	idle_sprite.play("idle")

# --- Damage to player ---
func _deal_damage_to_player(player):
	if player == null or is_dead:
		return
	var to_player = player.global_position - global_position
	if (facing_right and to_player.x > 0) or (not facing_right and to_player.x < 0):
		if to_player.length() <= ATTACK_RANGE:
			if player.has_method("take_damage"):
				player.take_damage(1)  # Calls the player's method, updates HUD automatically

# --- Take damage ---
func take_damage(amount: int):
	if is_dead:
		return
	health -= amount
	if health <= 0:
		is_dead = true
		is_attacking = false
		collision_layer = 0
		collision_mask = 0
		z_index = -1
		_show_only(death_sprite)
		death_sprite.play("death")
		await death_sprite.animation_finished
		die()

func die():
	queue_free()

# --- Show only one animation ---
func _show_only(sprite_to_show: AnimatedSprite2D):
	idle_sprite.visible = false
	walk_sprite.visible = false
	attack_sprite.visible = false
	death_sprite.visible = false
	sprite_to_show.visible = true
