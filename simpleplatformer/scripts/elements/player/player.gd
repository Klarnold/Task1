extends CharacterBody2D
class_name Player


enum PlayerStateMachine{
	MOVE,
	JUMP,
	ATTACK,
	DAMAGED,
	DEATH
}

# constants
const SPEED: float = 15000.0
const JUMP_SPEED: float = -25000.0
const ATTACK_PUSH_SPEED: float = 14000

# onready nodes
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coyot_jump_timer: Timer = $CoyotJumpTimer
@onready var damage_box: Node2D = $DamageBox
@onready var hurt_box_area: Area2D = $DamageBox/HurtBoxArea
@onready var hit_box_area: Area2D = $DamageBox/HitBoxArea

# onready variables
@onready var state: PlayerStateMachine = PlayerStateMachine.MOVE

# variables
var direction: float = 0
var final_direction: int = 1 # for player's look direction
var jump_allowed: bool = true


func _ready() -> void:
	# connecting signals
	coyot_jump_timer.timeout.connect(_on_coyot_jump_timer_timeout)
	hit_box_area.area_entered.connect(_on_hit_box_area_area_entered)
	
	# setting variables
	Globals.player = self


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("jump") and jump_allowed: # check for jump
		state = PlayerStateMachine.JUMP
	# check if attack pressed
	elif Input.is_action_just_pressed("attack") \
		and state != PlayerStateMachine.ATTACK: # check if attacking
			state = PlayerStateMachine.ATTACK


func _physics_process(delta: float) -> void:
	match state: # managing current state
		PlayerStateMachine.MOVE:
			move_state(delta)
		PlayerStateMachine.JUMP:
			jump_state(delta)
		PlayerStateMachine.ATTACK:
			attack_state(delta)
		PlayerStateMachine.DAMAGED:
			pass
		PlayerStateMachine.DEATH:
			pass
	
	if !is_on_floor(): # basic gravity
		if coyot_jump_timer.time_left == 0: # coyot jumpt for better UE
			coyot_jump_timer.start()
		velocity.y += clamp(Globals.gravity*delta, Globals.VELOCITY_Y_MIN, \
											Globals.VELOCITY_Y_MAX)
	
	move_and_slide()

# move state
func move_state(delta: float): 
	direction = Input.get_axis("left", "right") # getting direction for velocity
												# and better animation
	
	if direction != 0: # if pressing move buttons (left/right)
		final_direction = direction
		set_look(final_direction) # set player's look direction
		if is_on_floor(): # check for animation and jump variable
			animation_player.play("move")
			jump_allowed = true
		velocity.x = lerp(velocity.x, SPEED*delta*direction, 0.8) # basic speed
																  # equation
	else: # if standing still
		if is_on_floor(): # check for animation and jump variable
			animation_player.play("idle")
			jump_allowed = true
		velocity.x = lerp(velocity.x, 0.0, 0.4) # basic speed nullifying equation

# jump state
func jump_state(delta: float):
	jump_allowed = false # no more jumps while jumping
	velocity.y = JUMP_SPEED*delta # basic y axis speed equation
	animation_player.play("jump")
	state = PlayerStateMachine.MOVE # returing back to MOVE state

# attack state
func attack_state(delta: float):
	velocity.x = ATTACK_PUSH_SPEED*delta*final_direction
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "velocity:x", 0,\
	 0.2).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	animation_player.play("attack")
	await animation_player.animation_finished
	state = PlayerStateMachine.MOVE


func set_look(_direction):
	animated_sprite_2d.scale.x = _direction
	damage_box.scale.x = _direction


func _on_hit_box_area_area_entered(object_area: Area2D):
	Signals.emit_signal("enemy_is_hitted", object_area, position, 1)


func _on_coyot_jump_timer_timeout():
	jump_allowed = is_on_floor()
