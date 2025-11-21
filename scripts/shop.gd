extends Area2D

# --- SHOP ITEMS ---
@export var items: Array = [
	{"name": "Swig of Life", "cost_coins": 4, "cost_gems": 0, "id": "swig_of_life", "desc": "Restores all hearts"},
	{"name": "Golden Drop", "cost_coins": 5, "cost_gems": 0, "id": "golden_drop", "desc": "25% chance to double coins until death"},
	{"name": "Shiny Swap", "cost_coins": 5, "cost_gems": 0, "id": "shiny_swap", "desc": "Converts 5 coins into 1 gem"},
	{"name": "Skybound Boots", "cost_coins": 0, "cost_gems": 2, "id": "double_jump", "desc": "Grants double jump"},
	{"name": "Sharpened Blade", "cost_coins": 0, "cost_gems": 4, "id": "double_damage", "desc": "Double damage"},
	{"name": "Double Time", "cost_coins": 0, "cost_gems": 3, "id": "speed_up", "desc": "Slight permanent movement speed increase"},
	{"name": "Blink", "cost_coins": 0, "cost_gems": 4, "id": "dash", "desc": "Unlock a short dash ability"},
	{"name": "Ghostskin", "cost_coins": 6, "cost_gems": 0, "id": "ghostskin", "desc": "Temporary invincibility (30 secs)"}
]

# --- INTERNALS ---
var player: Node = null

@onready var popup := $ShopUI/PopupPanel
@onready var grid := $ShopUI/PopupPanel/MarginContainer/GridContainer
@onready var gem_label := $ShopUI/PopupPanel/MarginContainer/HBoxContainer/GemCountLabel

# --- READY ---
func _ready():
	popup.hide()
	grid.columns = 3
	_populate_shop()
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

# --- ENTER/EXIT ---
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player = body
		popup.popup_centered()
		_update_gem_display()
		if "can_move" in player:
			player.can_move = false

func _on_body_exited(body: Node) -> void:
	if body == player:
		popup.hide()
		if "can_move" in player:
			player.can_move = true
		player = null

# --- UPDATE GEM LABEL ---
func _update_gem_display():
	if player:
		gem_label.text = str(player.gems)

func _process(delta):
	if popup.visible and player:
		_update_gem_display()

# --- POPULATE SHOP ---
func _populate_shop() -> void:
	for c in grid.get_children():
		c.queue_free()

	for item in items:
		var vbox := VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

		# BUTTON
		var btn := Button.new()
		btn.text = item.name
		btn.custom_minimum_size = Vector2(140, 32)
		btn.tooltip_text = "%s\nCost: %sC %sG" % [item.desc, item.cost_coins, item.cost_gems]
		btn.pressed.connect(_attempt_buy.bind(item))
		vbox.add_child(btn)

		# COST LABEL
		var label := Label.new()
		label.text = "%sC %sG" % [item.cost_coins, item.cost_gems]
		label.custom_minimum_size = Vector2(140, 20)
		label.horizontal_alignment = 1  # CENTER numeric works in 4.5
		vbox.add_child(label)

		grid.add_child(vbox)

# --- BUY LOGIC ---
func _attempt_buy(item: Dictionary) -> void:
	if not player:
		return

	if player.coins >= item.cost_coins and player.gems >= item.cost_gems:
		player.coins -= item.cost_coins
		player.gems -= item.cost_gems
		_apply_effect(item.id)
	else:
		print("Not enough currency for %s" % item.name)

# --- APPLY EFFECTS ---
func _apply_effect(id: String) -> void:
	match id:
		"swig_of_life": player.hearts = player.max_hearts
		"ghostskin": player.start_invincibility(30.0)
		"dash": player.unlock_dash()
		"double_jump": player.unlock_double_jump()
		"double_damage": player.unlock_double_damage()
		"speed_up": player.speed_multiplier = 1.2
		"shiny_swap":
			if player.coins >= 5:
				player.coins -= 5
				player.gems += 1
		"golden_drop": player.unlock_golden_drop()
