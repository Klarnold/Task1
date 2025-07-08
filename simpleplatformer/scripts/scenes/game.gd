extends Node2D


func _ready() -> void:
	Signals.player_is_dead.connect(_on_player_is_dead)


func _on_player_is_dead():
	get_tree().change_scene_to_file("res://scenes/game.tscn")
