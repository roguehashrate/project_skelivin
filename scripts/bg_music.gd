extends AudioStreamPlayer

func _ready():
	# Only one instance should exist
	var existing = get_tree().get_root().get_node_or_null("BGMusic")
	if existing and existing != self:
		queue_free()
		return

	# Move to root so it persists
	get_tree().get_root().add_child(self)
	self.name = "BGMusic"
	self.owner = null

	# Start playing if not already
	if not playing:
		play()
