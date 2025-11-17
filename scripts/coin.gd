extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# Ensure coin is enabled when the scene starts
	collision_shape.disabled = false

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		# Add coin to player safely
		if body.has_method("add_coin"):
			body.add_coin()  # Emits coins_changed signal for HUD

		# Play pickup animation
		if animation_player.has_animation("pickup_animation"):
			animation_player.play("pickup_animation")

		# Disable collision so it can't be collected multiple times during the animation
		collision_shape.disabled = true

		# Re-enable collision after animation finishes
		if animation_player.has_animation("pickup_animation"):
			animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "pickup_animation":
		collision_shape.disabled = false
