extends CanvasLayer


func _ready() -> void:
	Signals.player_is_dead.connect(_on_player_is_dead)


func _on_player_is_dead():
	add_child(load("res://scenes/game_over_screen.tscn").instantiate())


func _exit_tree() -> void:
	Signals.player_is_dead.disconnect(_on_player_is_dead)
