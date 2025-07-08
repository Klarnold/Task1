extends Control


@export var restarted_scene: PackedScene = preload("res://scenes/game.tscn")


@onready var game_over_label: Label = $MarginContainer/VBoxContainer/GameOverLabel
@onready var restart_button: Button = $MarginContainer/VBoxContainer/RestartButton


func _ready() -> void:
	restart_button.pressed.connect(_on_restart_button_pressed)
	
	game_over_anim()


func game_over_anim():
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(game_over_label, "self_modulate:a", 0, 1)
	tween.tween_property(game_over_label, "self_modulate:a", 1, 1)
	tween.bind_node(self)
	tween.set_loops()


func _on_restart_button_pressed():
	get_tree().change_scene_to_packed(restarted_scene)
	queue_free()


func _exit_tree() -> void:
	restart_button.pressed.disconnect(_on_restart_button_pressed)
