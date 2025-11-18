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
@onready var hearts = [$Heart1, $Heart2, $Heart3, $Heart4]

var player: Node = null

func _ready():
	call_deferred("_find_player")

func _find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	else:
		call_deferred("_find_player")

func _process(delta):
	if not player or not is_instance_valid(player):
		player = null
		call_deferred("_find_player")
	elif player:
		update_coins(player.coins)
		update_hearts(player.health, player.max_health)

func update_coins(coin_count: int):
	coin_count = clamp(coin_count, 0, 99)
	var str_count = "%02d" % coin_count
	for i in range(2):
		var digit = int(str_count[i])
		digits[i].texture = number_textures[digit]

func update_hearts(current_health: int, max_health: int):
	# Iterate from right to left
	for i in range(hearts.size()):
		var heart_index = hearts.size() - 1 - i  # reverse order
		if i < current_health:
			hearts[heart_index].texture = preload("res://assets/Rocky Roads/UI/little_heart.png")
		else:
			hearts[heart_index].texture = preload("res://assets/Rocky Roads/UI/empty_heart.png")
