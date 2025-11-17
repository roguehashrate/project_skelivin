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
@onready var hearts = [$Heart1, $Heart2, $Heart3, $Heart4]
@onready var digits = [$Digit1, $Digit2]  # tens, ones

# --- Player reference ---
var player: Node = null

func _ready() -> void:
	# Connect to player after scene is ready
	call_deferred("_connect_to_player")

func _connect_to_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		return
	player = players[0]

	if not player.is_connected("health_changed", Callable(self, "_on_health_changed")):
		player.connect("health_changed", Callable(self, "_on_health_changed"))
	if not player.is_connected("coins_changed", Callable(self, "_on_coins_changed")):
		player.connect("coins_changed", Callable(self, "_on_coins_changed"))

	# Initialize HUD from current player values
	_on_health_changed(player.health, player.max_health)
	_on_coins_changed(player.coins)

# --- Signal handlers ---
func _on_health_changed(new_health: int, max_health: int) -> void:
	update_hearts(new_health, max_health)

func _on_coins_changed(new_total_coins: int) -> void:
	update_coins(new_total_coins)

# --- Update functions ---
func update_hearts(current_health: int, max_health: int) -> void:
	for i in range(hearts.size()):
		var heart = hearts[hearts.size() - 1 - i]  # reverse order
		if i < current_health:
			heart.texture = little_full
		else:
			heart.texture = empty_heart


func update_coins(coin_count: int) -> void:
	coin_count = clamp(coin_count, 0, 99)
	var str_count = "%02d" % coin_count
	for i in range(2):
		var digit = int(str_count[i])
		digits[i].texture = number_textures[digit]
