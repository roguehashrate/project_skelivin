extends Area2D

#const FILE_BEGIN = "res://levels/lv_"
#
#func _on_body_entered(body: Node) -> void:
#	if body.is_in_group("player"):
#		print("I see the player")
#		var current_scene_file = get_tree().current_scene_file_path
#		var next_lv_num = current_scene_file.to_int() + 1
#		var next_lv_path = FILE_BEGIN + str(next_lv_num) + ".tscn"
#		print(next_lv_path)
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		print("PLAYER GOES TO NEXT LEVEL")
		
		# Reset coins and gems on the player before changing the level
		if body.has_method("start_level"):
			body.start_level()

		# Change to the next level
		get_tree().change_scene_to_file("res://scenes/levels/lv_2.tscn")
