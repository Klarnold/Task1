extends CanvasLayer


@onready var health_container: HBoxContainer = $Control/MarginContainer/VBoxContainer/HBoxContainer/HealthContainer
@onready var enemy_counter: Label = $Control/MarginContainer/VBoxContainer/HBoxContainer/EnemyCounter
@onready var health_cell_ps: PackedScene = preload("res://elements/UI/health_cell.tscn")

@onready var enemies_dead: int = 0


func _ready() -> void:
	Signals.enemy_is_dead.connect(_on_enemy_is_dead)
	Signals.player_is_ready.connect(_on_player_is_ready)
	Signals.player_is_damaged.connect(_on_player_is_damaged)
	
	enemy_counter.text = "%o enemies killed" % enemies_dead


func set_health(health_ammount: int) -> void:
	for health in health_ammount:
		health_container.add_child(health_cell_ps.instantiate())


func _on_enemy_is_dead() -> void:
	enemies_dead += 1
	if enemies_dead == 1:
		enemy_counter.text = "%o enemy killed" % enemies_dead
	else:
		enemy_counter.text = "%o enemies killed" % enemies_dead


func _on_player_is_damaged(damage: float):
	for health_cell in floor(damage):
		health_container.get_child(-1).queue_free()


func _on_player_is_ready() -> void:
	set_health(Globals.player.health)


func _exit_tree() -> void:
	Signals.enemy_is_dead.disconnect(_on_enemy_is_dead)
	Signals.player_is_ready.disconnect(_on_player_is_ready)
	Signals.player_is_damaged.disconnect(_on_player_is_damaged)
