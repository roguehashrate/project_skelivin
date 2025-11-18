extends Area2D

@export var respawn_delay: float = 0.5

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.wait_time = respawn_delay
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Player died (KillZone)")
		if body.has_method("_die"):
			body._die()

		timer.start()

func _on_timer_timeout() -> void:
	# Optional — player already reloads the scene in _die()
	pass
