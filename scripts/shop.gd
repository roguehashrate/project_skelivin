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
	{"name": "Ghostskin", "cost_coins": 6, "cost_gems": 0, "id": "ghostskin", "desc": "Temporary invincibility (30 secs)", "duration": 30.0}
]

# --- INTERNALS ---
var player: Node = null

# --- UI NODES ---
@onready var popup := $ShopUI/PopupPanel
@onready var grid := $ShopUI/PopupPanel/MarginContainer/GridContainer
@onready var gem_display := $ShopUI/PopupPanel/MarginContainer/GemDisplay
@onready var gem_hbox := gem_display.get_node("HBoxContainer")
@onready var gem_label := gem_hbox.get_node("GemCountLabel")
@onready var gem_icon := gem_hbox.get_node("GemIcon")


# --- READY ---
func _ready():
	popup.hide()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_populate_shop()

	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

	# --- GEM DISPLAY POLISH ---
	if gem_icon:
		gem_icon.custom_minimum_size = Vector2(48, 48)
		gem_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	if gem_label:
		# Preferred: assign a DynamicFont in the inspector with size ~32
		gem_label.add_theme_font_size_override("font_size", 32)

	if gem_display:
		# Slightly move gem display for offset
		gem_display.position += Vector2(20, 5)

# --- ENTER/EXIT ---
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player = body
		popup.popup_centered()
		_update_gem_display()
		player.can_move = false

func _on_body_exited(body: Node) -> void:
	if body == player:
		popup.hide()
		player.can_move = true
		player = null

# --- UPDATE GEM LABEL ---
func _update_gem_display():
	if player and gem_label:
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
		btn.custom_minimum_size = Vector2(220, 62)
		btn.tooltip_text = "%s\nCost: %sC %sG" % [item.desc, item.cost_coins, item.cost_gems]
		btn.pressed.connect(_attempt_buy.bind(item))
		vbox.add_child(btn)

		# COST LABEL
		var label := Label.new()
		label.text = "%sC %sG" % [item.cost_coins, item.cost_gems]
		label.custom_minimum_size = Vector2(220, 50)
		label.horizontal_alignment = 1  # 1 = CENTER
		vbox.add_child(label)

		grid.add_child(vbox)

# --- BUY LOGIC ---
func _attempt_buy(item: Dictionary) -> void:
	if not player:
		return

	if player.coins >= item.cost_coins and player.gems >= item.cost_gems:
		player.coins -= item.cost_coins
		player.gems -= item.cost_gems
		_apply_effect(item)
	else:
		print("Not enough currency for %s" % item.name)

# --- APPLY EFFECTS ---
func _apply_effect(item: Dictionary) -> void:
	match item.id:
		"swig_of_life":
			player.hearts = player.max_hearts
		"ghostskin":
			player.start_invincibility(item.get("duration", 30.0))
		"dash":
			player.unlock_dash()
		"double_jump":
			player.unlock_double_jump()
		"double_damage":
			player.unlock_double_damage()
		"speed_up":
			player.speed_multiplier *= 1.2
		"shiny_swap":
			player.gems += 1
		"golden_drop":
			player.unlock_golden_drop()
