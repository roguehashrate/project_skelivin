extends Area2D

# Optional respawn delay (in seconds)
@export var respawn_delay: float = 0.5

@onready var timer: Timer = $Timer

func _ready():
	timer.wait_time = respawn_delay
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Player died")
		# Call the player's _die() function which resets coins, health, and handles death animation
		if body.has_method("_die"):
			body._die()
			# Start the respawn timer to reload the scene after a short delay
			timer.start()

func _on_timer_timeout() -> void:
	# Scene reload happens in player's _die(), so this is optional if you want a separate delay
	# Otherwise, could leave this empty or use for effects (screen fade, sound, etc.)
	pass
