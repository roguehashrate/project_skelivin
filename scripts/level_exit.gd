extends Area2D

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	print("PLAYER GOES TO NEXT LEVEL")

	# Reset player before changing level
	if body.has_method("start_level"):
		body.start_level()

	# Get current scene file name
	var current_scene_path = get_tree().current_scene.get_scene_file_path()  # full path
	var current_scene_name = current_scene_path.get_file()  # e.g., "lv_1.tscn"

	# Extract the level number using Godot 4 regex
	var regex = RegEx.new()
	regex.compile("lv_(\\d+)\\.tscn")
	var matches = regex.search(current_scene_name)  # returns RegExMatch or null
	if matches == null:
		print("Could not parse current level number from:", current_scene_name)
		return

	var current_lv_num = int(matches.get_string(1))
	var next_lv_num = current_lv_num + 1

	# Build next level path dynamically
	var next_lv_path = "res://scenes/levels/lv_%d.tscn" % next_lv_num
	print("Next level path:", next_lv_path)

	# Check if the file exists before changing scene
	if FileAccess.file_exists(next_lv_path):
		get_tree().change_scene_to_file(next_lv_path)
	else:
		print("No more levels! You finished the game!")
