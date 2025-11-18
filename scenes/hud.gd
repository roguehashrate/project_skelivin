# HUD.gd
extends CanvasLayer

# --- Preloads ---
var little_full = preload("res://assets/Rocky Roads/UI/little_heart.png")
var empty_heart = preload("res://assets/Rocky Roads/UI/empty_heart.png")

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

# --- Nodes ---
@onready var hearts = [$Heart1, $Heart2, $Heart3, $Heart4]
@onready var digits = [$Digit1, $Digit2]

var player: Node = null

func _ready():
	call_deferred("_connect_to_player")

func _connect_to_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		call_deferred("_connect_to_player")
		return

	player = players[0]

	if not player.is_connected("health_changed", Callable(self, "_on_health_changed")):
		player.connect("health_changed", Callable(self, "_on_health_changed"))
	if not player.is_connected("coins_changed", Callable(self, "_on_coins_changed")):
		player.connect("coins_changed", Callable(self, "_on_coins_changed"))

	# Initialize UI
	_on_health_changed(player.health, player.max_health)
	_on_coins_changed(player.coins)

func _on_health_changed(new_health: int, max_health: int):
	update_hearts(new_health, max_health)

func _on_coins_changed(new_total_coins: int):
	update_coins(new_total_coins)

func update_hearts(current_health: int, max_health: int):
	for i in range(hearts.size()):
		if i < current_health:
			hearts[i].texture = little_full
		else:
			hearts[i].texture = empty_heart

func update_coins(coin_count: int):
	coin_count = clamp(coin_count, 0, 99)
	var str_count = "%02d" % coin_count
	for i in range(2):
		var digit = int(str_count[i])
		digits[i].texture = number_textures[digit]
