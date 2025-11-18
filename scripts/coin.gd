extends Area2D

@onready var sprite = $Sprite
@onready var collision = $CollisionShape2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.has_method("add_coin"):
		body.add_coin()
		queue_free()
