extends CharacterBody2D
class_name Player


enum PlayerStateMachine{
	MOVE,
	JUMP,
	ATTACK,
	DAMAGED,
	DEATH
}


const VELOCITY_Y_MIN: float = -500
const VELOCITY_Y_MAX: float = 500
const SPEED: float = 15000.0
const JUMP_SPEED: float = -25000.0


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coyot_jump_timer: Timer = $CoyotJumpTimer


@onready var state: PlayerStateMachine = PlayerStateMachine.MOVE
@onready var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


var direction: float = 0
var jump_allowed: bool = true


func _ready() -> void:
	coyot_jump_timer.timeout.connect(_on_coyot_jump_timer_timeout)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
			state = PlayerStateMachine.JUMP


func _physics_process(delta: float) -> void:
	match state:
		PlayerStateMachine.MOVE:
			move_state(delta)
		PlayerStateMachine.JUMP:
			jump_state(delta)
		PlayerStateMachine.ATTACK:
			pass
		PlayerStateMachine.DAMAGED:
			pass
		PlayerStateMachine.DEATH:
			pass
	
	if !is_on_floor():
		if coyot_jump_timer.time_left == 0:
			coyot_jump_timer.start()
		velocity.y += clamp(gravity*delta, VELOCITY_Y_MIN, \
											VELOCITY_Y_MAX)
	
	move_and_slide()


func move_state(delta: float):
	direction = Input.get_axis("left", "right")
	
	if direction != 0:
		set_look(direction)
		if is_on_floor():
			animation_player.play("move")
			jump_allowed = true
		velocity.x = lerp(velocity.x, SPEED*delta*direction, 0.8)
	else:
		if is_on_floor():
			animation_player.play("idle")
			jump_allowed = true
		velocity.x = lerp(velocity.x, 0.0, 0.4)


func jump_state(delta: float):
	jump_allowed = false
	velocity.y = JUMP_SPEED*delta
	animation_player.play("jump")
	state = PlayerStateMachine.MOVE


func set_look(_direction):
	animated_sprite_2d.scale.x = _direction


func _on_coyot_jump_timer_timeout():
	jump_allowed = is_on_floor()
