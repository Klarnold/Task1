extends CharacterBody2D
class_name Enemy


@onready var state: Globals.EnemyStateMachine = Globals.EnemyStateMachine.MOVE
@onready var direction: int = 1 
@onready var health: float = Globals.ENEMY_MAX_HEALTH
@onready var chase: bool = false
@onready var cooldown: bool = false 
@onready var is_attacking: bool = false

var edge_checker_ray_cast: RayCast2D
var animated_sprite_2d: AnimatedSprite2D
var animation_player: AnimationPlayer
var damage_box: Node2D
var hurt_box_area: Area2D
var chase_area: Area2D
var cooldown_timer: Timer

func _ready() -> void:
	# this all required for catching errors because of the composition issues
	if check_node("AnimatedSprite2D"):
		return
	animated_sprite_2d = $AnimatedSprite2D
	
	if check_node("AnimationPlayer"):
		return
	animation_player = $AnimationPlayer
	
	if check_node("AnimatedSprite2D"):
		return
	damage_box = $DamageBox
	
	if check_node("DamageBox/EdgeCheckerRayCast"):
		return
	edge_checker_ray_cast = $DamageBox/EdgeCheckerRayCast
	
	if check_node("DamageBox/HurtBoxArea"):
		return
	hurt_box_area = $DamageBox/HurtBoxArea
	
	if check_node("ChaseArea"):
		return
	chase_area = $ChaseArea
	
	if check_node("CooldownTimer"):
		return
	cooldown_timer = $CooldownTimer


func _physics_process(delta: float) -> void:
	match state:
		Globals.EnemyStateMachine.MOVE:
			move_state(delta)
		Globals.EnemyStateMachine.ATTACK:
			attack_state()
		Globals.EnemyStateMachine.DAMAGED:
			damaged_state()
		Globals.EnemyStateMachine.DEATH:
			death_state()
	
	if !is_on_floor():
		velocity.y += clamp(Globals.gravity*delta, Globals.VELOCITY_Y_MIN, \
											Globals.VELOCITY_Y_MAX)
	
	move_and_slide()


func move_state(delta: float):
	if !edge_checker_ray_cast.is_colliding() and is_on_floor():
		set_direction(-direction)
	animation_player.play("move")
	if chase and Globals.player:
		if abs(Globals.player.position.x - position.x) > 30:
			set_direction(-Globals.get_direction(Globals.player.position, position))
			velocity.x = lerp(velocity.x + Globals.ENEMY_SPEED*delta*direction, \
		 	Globals.ENEMY_MAX_SPEED*direction*Globals.CHASE_SPEED_MODIFIER, 0.8)
	else:
		velocity.x = lerp(velocity.x + Globals.ENEMY_SPEED*delta*direction, \
	 	Globals.ENEMY_MAX_SPEED*direction, 0.8)


func attack_state():
	if !is_attacking:
		is_attacking = true
		velocity.x = 0
		cooldown = true
		animation_player.play("attack")
		await animation_player.animation_finished
		if has_node("CooldownTimer"):
			cooldown_timer.start()
		is_attacking = false
		state = Globals.EnemyStateMachine.MOVE


func damaged_state():
	velocity.x = 0
	animation_player.play("damaged")
	await animation_player.animation_finished
	state = Globals.EnemyStateMachine.MOVE


func death_state():
	set_physics_process(false) # stops state management
	velocity.x = 0
	animation_player.play("death")
	Signals.emit_signal("enemy_is_dead")
	Globals.disable_all(self)
	await animation_player.animation_finished
	queue_free()


#func take_damage():
	#health -= 1
	#if health <= 0:
		#health = 0
		#state = Globals.EnemyStateMachine.DEATH
	#else:
		#state = Globals.EnemyStateMachine.DAMAGED


func check_node(node_path: String):
	if has_node(node_path):
		return false
	printerr("%s has no %s, this node was freed" % [name, node_path])
	queue_free()
	set_physics_process(false)
	return true


func set_direction(_direction: int):
	direction = _direction
	# this piece of code is required because of chance for scales be not equal
	# exactly 1 or -1, which is direction, so that's it
	animated_sprite_2d.scale.x = abs(animated_sprite_2d.scale.x)*direction
	damage_box.scale.x = abs(damage_box.scale.x)*direction
	edge_checker_ray_cast.scale.x = abs(edge_checker_ray_cast.scale.x)*direction


func _exit_tree() -> void:
	# required to escape queue_free() issues when signals are connected to
	# the null instance
	pass
