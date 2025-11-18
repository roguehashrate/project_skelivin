extends CanvasLayer

var number_textures = [
	preload("res://assets/Rocky Roads/UI/0.png"),
	preload("res://assets/Rocky Roads/UI/1.png"),
	preload("res://assets/Rocky Roads/UI/2.png"),
	preload("res://assets/Rocky Roads/UI/3.png"),
	preload("res://assets/Rocky Roads/UI/4.png"),
	preload("res://assets/Rocky Roads/UI/5.png"),
	preload("res://assets/Rocky Roads/UI/6.png"),
	preload("res://assets/Rocky Roads/UI/7.png"),
	preload("res://assets/Rocky Roads/UI/8.png"),
	preload("res://assets/Rocky Roads/UI/9.png")
]

@onready var digits = [$Digit1, $Digit2]

var player: Node = null

func _ready():
	call_deferred("_find_player")

func _find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		call_deferred("_find_player")
		return
	player = players[0]

func _process(delta):
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		return
	player = players[0]
	update_coins(player.coins)


func update_coins(coin_count: int):
	coin_count = clamp(coin_count, 0, 99)
	var str_count = "%02d" % coin_count
	for i in range(2):
		var digit = int(str_count[i])
		digits[i].texture = number_textures[digit]
