# Music.gd
extends Node

# Make sure the node exists in this scene
@onready var player: AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	# Move this node to the root so it persists
	get_tree().get_root().add_child(self)
	self.owner = null  # detach from scene so it doesn't get freed

	# Only play if not already playing
	if player and not player.playing:
		player.play()
