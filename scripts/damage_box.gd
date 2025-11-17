# damage_box.gd
extends Node2D

# Optional: just a visual for attack range
@export var visible_in_game: bool = true

func _ready():
	visible = visible_in_game
