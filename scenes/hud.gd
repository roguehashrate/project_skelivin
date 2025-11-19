extends CanvasLayer

# --- Preloads ---
var little_full = preload("res://assets/Rocky Roads/UI/little_heart.png")
var big_full = preload("res://assets/Rocky Roads/UI/big_heart.png")
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
@onready var hearts = [$Heart1, $Heart2, $Heart3, $Heart4]  # left-to-right
@onready var digits = [$Digit1, $Digit2]  # tens, ones

var player: Node = null

func _ready():
	call_deferred("_find_player")

func _find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		call_deferred("_find_player")
		return

	player = players[0]

	# Connect player signals
	if player.has_signal("coins_changed"):
		player.connect("coins_changed", Callable(self, "_on_coins_changed"))
	if player.has_signal("health_changed"):
		player.connect("health_changed", Callable(self, "_on_health_changed"))

	# Initialize UI
	_on_coins_changed(player.coins)
	_on_health_changed(player.health, player.max_health)

# --- Signal callbacks ---
func _on_coins_changed(new_coins: int):
	update_coins(new_coins)

func _on_health_changed(current_health: int, max_health: int):
	update_hearts(current_health, max_health)

# Optional: keep _process if you want smooth heart updates per frame
func _process(delta):
	if player:
		update_hearts(player.health, player.max_health)

# --- Update functions ---
func update_hearts(current_health: int, max_health: int):
	for i in range(hearts.size()):
		var heart = hearts[hearts.size() - 1 - i]  # reverse for right-to-left depletion
		if i < current_health:
			heart.texture = little_full
		else:
			heart.texture = empty_heart

func update_coins(coin_count: int):
	coin_count = clamp(coin_count, 0, 99)
	var str_count = "%02d" % coin_count
	for i in range(2):
		var digit = int(str_count[i])
		digits[i].texture = number_textures[digit]
