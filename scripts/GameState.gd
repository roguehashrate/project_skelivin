# GameState.gd - Autoload Singleton (ONLY for Health)
extends Node

# --- Player health ---
var max_health: int = 4
var health: int = max_health

# --- Signals ---
signal health_changed(new_health, max_health)

# --- Initialization ---
func init_player_health():
	# On first load or after death
	if health <= 0:
		health = max_health
	emit_signal("health_changed", health, max_health)

# --- Damage / healing ---
func take_damage(amount: int):
	health -= amount
	if health < 0:
		health = 0
	emit_signal("health_changed", health, max_health)

func heal(amount: int):
	health += amount
	if health > max_health:
		health = max_health
	emit_signal("health_changed", health, max_health)

# --- Reset for death ---
func reset_for_death():
	# Now only handles health reset
	health = max_health
	emit_signal("health_changed", health, max_health)
