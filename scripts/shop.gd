extends Area2D

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

var player

func _ready():
	$ShopUI.visible = false
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	_populate_shop()

func _on_body_entered(body):
	print("Entered: ", body.name)
	if body.is_in_group("player"):
		player = body
		$ShopUI.visible = true
		player.can_move = false


func _on_body_exited(body):
	if body.is_in_group("player"):
		$ShopUI.visible = false
		if player:
			player.can_move = true  # unlocks movement
		player = null


func _populate_shop():
	var list = $ShopUI/Panel/ItemList

	for item in items:
		var button = Button.new()
		button.text = "%s — %sC %sG" % [
			item.name,
			item.cost_coins,
			item.cost_gems
		]
		button.pressed.connect(Callable(self, "_attempt_buy").bind(item))
		list.add_child(button)

func _attempt_buy(item):
	if player.coins >= item.cost_coins and player.gems >= item.cost_gems:
		player.coins -= item.cost_coins
		player.gems -= item.cost_gems
		_apply_effect(item.id)
	else:
		print("Not enough currency")

func _apply_effect(id):
	match id:
		"swig_of_life":
			player.hearts = player.max_hearts
		"ghostskin":
			player.start_invincibility(3.0)
		"blink":
			player.unlock_dash()
