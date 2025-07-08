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
@onready var hit_box_shape: CollisionPolygon2D = $DamageBox/HitBoxArea/HitBoxShape

# onready variables
@onready var state: PlayerStateMachine = PlayerStateMachine.MOVE
@onready var health: float = Globals.MAX_HEALTH
@onready var invisible: bool = false

# variables
var direction: float = 0
var final_direction: int = 1 # for player's look direction
var jump_allowed: bool = true
var attacked_pos: Vector2


func _ready() -> void:
	# connecting global signals
	Signals.connect("player_is_hitted", _on_player_is_hitted)
	
	# connecting "local" signals
	coyot_jump_timer.timeout.connect(_on_coyot_jump_timer_timeout)
	hit_box_area.area_entered.connect(_on_hit_box_area_area_entered)
	
	# setting variables
	Globals.player = self
	
	#setting local tree nodes
	hit_box_shape.disabled = true


func _input(_event: InputEvent) -> void:
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
			damaged_state(delta)
		PlayerStateMachine.DEATH:
			death_state()
	
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
		final_direction = -1 if direction < 0 else 1 # in case if "direction"
													 # is exaclty equal 1 or -1
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
	 0.2).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	animation_player.play("attack")
	await animation_player.animation_finished
	state = PlayerStateMachine.MOVE


func damaged_state(delta):
	animation_player.play("damaged")
	invisible_anim(Globals.PLAYER_INV_TIME)
	velocity = Globals.PLAYER_DAMAGED_VELOCITY * delta
	if attacked_pos.x - position.x > 0: 
		velocity.x *= -1
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "velocity:x", 0, 0.4)
	await animation_player.animation_finished
	state = PlayerStateMachine.MOVE


func death_state():
	set_physics_process(false)
	Globals.disable_all(self)
	animation_player.play("death")
	await animation_player.animation_finished
	queue_free()


func set_look(_direction):
	animated_sprite_2d.scale.x = _direction
	damage_box.scale.x = _direction


func take_damage(enemy_pos: Vector2, enemy_damage: float):
	print("damaged")
	if invisible:
		return
	attacked_pos = enemy_pos
	if health - enemy_damage <= 0:
		health = 0
		state = PlayerStateMachine.DEATH
	else:
		health -= enemy_damage
		state = PlayerStateMachine.DAMAGED


func invisible_anim(time: float):
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(animated_sprite_2d, "self_modulate:a", 0, 0.3)
	tween.tween_property(animated_sprite_2d, "self_modulate:a", 1, 0.3)
	tween.set_loops()
	await get_tree().create_timer(time).timeout
	animated_sprite_2d.self_modulate.a = 1
	invisible = false
	tween.kill()


func _on_player_is_hitted(enemy_pos, enemy_damage):
	take_damage(enemy_pos, enemy_damage)


func _on_hit_box_area_area_entered(object_area: Area2D):
	Signals.emit_signal("enemy_is_hitted", object_area, position, 1)


func _on_coyot_jump_timer_timeout():
	jump_allowed = is_on_floor()


func _exit_tree() -> void:
	coyot_jump_timer.timeout.disconnect(_on_coyot_jump_timer_timeout)
	hit_box_area.area_entered.disconnect(_on_hit_box_area_area_entered)
