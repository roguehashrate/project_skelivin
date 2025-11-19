extends Area2D

@onready var sprite = $Sprite
@onready var collision = $CollisionShape2D
@onready var audio_player = $coin_pickup

var picked_up: bool = false  # Track if already picked

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if picked_up:
		return  # already collected, ignore
	if body.has_method("add_coin"):
		body.add_coin()
		picked_up = true
		hide()
		collision.disabled = true
		if audio_player:
			audio_player.play()  # play pickup sound

func reset_coin():
	picked_up = false
	show()
	collision.disabled = false
