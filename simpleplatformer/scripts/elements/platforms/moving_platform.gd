extends Path2D


@export var loop: bool = true
@export var speed: float = 80.0
@export var speed_scale: float = 1.0


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var path_follow_2d: PathFollow2D = $PathFollow2D


func _ready() -> void:
	if loop:
		animation_player.play("move")
		animation_player.speed_scale = speed_scale
		set_physics_process(false)


func _physics_process(delta: float) -> void:
	path_follow_2d.progress += speed*delta
