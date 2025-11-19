extends Area2D

@onready var sprite = $Sprite
@onready var collision = $CollisionShape2D
@onready var audio_player = $gem_pickup

var picked_up: bool = false  # Track if gem has been collected

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if picked_up:
		return  # already collected, ignore
	if body.has_method("add_gem"):
		body.add_gem()
		picked_up = true
		hide()
		collision.disabled = true
		if audio_player:
			audio_player.play()

func reset_gem():
	picked_up = false
	show()
	collision.disabled = false
