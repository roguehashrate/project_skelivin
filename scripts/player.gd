extends CharacterBody2D

# --- Constants ---
const SPEED: float = 130.0
const JUMP_VELOCITY: float = -300.0
const HIT_FRAME: int = 7
const ATTACK_TURN_FRAMES: int = 3

# --- Health ---
var max_health: int = 4
var health: int = max_health

# --- Coins ---
var coins: int = 0

# --- Movement tuning ---
var accel: float = 6000.0
var decel: float = 5000.0
var air_control: float = 0.85
var attack_move_mult: float = 0.45
var landing_boost_mult: float = 1.1

# --- Gravity ---
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var fall_multiplier: float = 2.0
var low_jump_multiplier: float = 1.3

# --- Apex hang ---
var apex_threshold: float = 25.0
var apex_damping: float = 0.95

# --- Coyote time / jump buffer ---
var coyote_time: float = 0.12
var coyote_timer: float = 0.0
var jump_buffer_time: float = 0.12
var jump_buffer_timer: float = 0.0

# --- Nodes ---
@onready var idle_sprite: AnimatedSprite2D = $idle
@onready var walk_sprite: AnimatedSprite2D = $walk
@onready var attack_sprite: AnimatedSprite2D = $attack
@onready var death_sprite: AnimatedSprite2D = $death
@onready var player_trigger: Area2D = $player_trigger
@onready var damage_box: Area2D = $damage_box

# --- Player state ---
var is_attacking: bool = false
var attack_range: float = 22.0
var hit_done: bool = false
var is_dead: bool = false
var facing_right: bool = true
var last_input_direction: float = 1.0

# --- Helpers ---
var was_on_floor: bool = false
var facing_locked: bool = false
var locked_direction: bool = false

func _ready():
	player_trigger.add_to_group("player_trigger")
	# Reset coins and health on respawn
	coins = 0
	health = max_health
	print("Player respawned. Coins:", coins, "Health:", health)

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		return

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		last_input_direction = direction

	# Jump / gravity
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)

	if jump_buffer_timer > 0 and coyote_timer > 0 and not is_attacking:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0
		coyote_timer = 0

	if velocity.y < 0 and not Input.is_action_pressed("jump"):
		velocity.y += gravity * low_jump_multiplier * delta
	elif velocity.y > 0:
		velocity.y += gravity * fall_multiplier * delta
	else:
		velocity.y += gravity * delta

	if abs(velocity.y) < apex_threshold:
		velocity.y *= apex_damping

	# Landing boost
	if (not was_on_floor) and is_on_floor():
		velocity.x *= landing_boost_mult

	# Horizontal movement
	var desired_speed = direction * SPEED * (1.0 if is_on_floor() else air_control)
	var move_mult = attack_move_mult if is_attacking else 1.0
	var target_x = desired_speed * move_mult
	var max_delta = accel * delta if abs(target_x) > abs(velocity.x) else decel * delta
	if abs(target_x - velocity.x) <= max_delta:
		velocity.x = target_x
	else:
		velocity.x += sign(target_x - velocity.x) * max_delta

	# Facing
	if is_attacking:
		if attack_sprite.frame <= ATTACK_TURN_FRAMES:
			_set_facing(last_input_direction < 0)
			locked_direction = last_input_direction < 0
		else:
			if not facing_locked:
				facing_locked = true
				_set_facing(locked_direction)
	else:
		facing_locked = false
		_set_facing(last_input_direction < 0)

	move_and_slide()
	was_on_floor = is_on_floor()

	# Animation
	if is_attacking:
		_show_only(attack_sprite)
	elif direction != 0:
		_show_only(walk_sprite)
	else:
		_show_only(idle_sprite)

	# Attack
	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()

	if is_attacking and attack_sprite.frame == HIT_FRAME and not hit_done:
		hit_done = true
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if enemy and not enemy.is_dead and enemy.has_method("take_damage"):
				var to_enemy = enemy.global_position - global_position
				if (facing_right and to_enemy.x > 0) or (not facing_right and to_enemy.x < 0):
					if to_enemy.length() <= attack_range:
						enemy.take_damage(1)

# --- Attack ---
func start_attack():
	is_attacking = true
	hit_done = false
	_show_only(attack_sprite)
	attack_sprite.play("attack")
	attack_sprite.animation_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)

func _on_attack_finished():
	is_attacking = false
	_show_only(idle_sprite)

# --- Damage / Health ---
func take_damage(amount: int):
	if is_dead:
		return
	health -= amount
	health = clamp(health, 0, max_health)
	if health <= 0:
		_die()

func _die():
	is_dead = true
	_show_only(death_sprite)
	death_sprite.play("death")
	death_sprite.animation_finished.connect(_on_death_finished, CONNECT_ONE_SHOT)

func _on_death_finished():
	# Immediately show 0 health on HUD
	health = 0
	if has_node("/root/HUD"):  # assuming your HUD node is autoloaded or at root
		var hud = get_node("/root/HUD")
		if hud.has_method("update_hearts"):
			hud.update_hearts(health, max_health)
	
	# Reset coins
	coins = 0
	
	# Reset health for next spawn
	health = max_health
	is_dead = false

	# Reload the scene
	get_tree().reload_current_scene()


# --- Coins ---
func add_coin():
	if is_dead:
		return
	coins += 1
	print("Player picked up coin, total now:", coins)

# --- Helpers ---
func _set_facing(flip_h: bool) -> void:
	walk_sprite.flip_h = flip_h
	idle_sprite.flip_h = flip_h
	attack_sprite.flip_h = flip_h
	death_sprite.flip_h = flip_h
	player_trigger.position.x = -abs(player_trigger.position.x) if flip_h else abs(player_trigger.position.x)
	damage_box.position.x = -abs(damage_box.position.x) if flip_h else abs(damage_box.position.x)
	facing_right = not flip_h

func _show_only(sprite_to_show: AnimatedSprite2D) -> void:
	idle_sprite.visible = false
	walk_sprite.visible = false
	attack_sprite.visible = false
	death_sprite.visible = false
	sprite_to_show.visible = true
	sprite_to_show.play(sprite_to_show.animation)
