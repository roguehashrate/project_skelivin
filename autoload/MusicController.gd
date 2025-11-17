extends Node

var bg_music = load("res://assets/audio/Underground Overground.wav")

func _ready():
	
	$Music.stream = bg_music
	$Music.play()
