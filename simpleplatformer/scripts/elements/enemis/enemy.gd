extends CharacterBody2D
class_name Enemy

enum EnemyStateMachine{
	MOVE,
	ATACK,
	CHASE,
	DAMAGED,
	DEATH
}


@onready var state: EnemyStateMachine = EnemyStateMachine.MOVE
@onready var direction: int = 1 


var edge_checker_ray_cast: RayCast2D
var animated_sprite_2d: AnimatedSprite2D
var animation_player: AnimationPlayer
var damage_box: Node2D


func _ready() -> void:
	# this all required for catching errors because of the composition issues 
	if !has_node("AnimatedSprite2D"):
		printerr("%s has no %s, this node was freed" % [name, "AnimatedSprite2D"])
		queue_free()
	animated_sprite_2d = $AnimatedSprite2D
	if !has_node("AnimationPlayer"):
		printerr("%s has no %s, this node was freed" % [name, "AnimationPlayer"])
		queue_free()
	animation_player = $AnimationPlayer
	if !has_node("DamageBox"):
		printerr("%s has no %s, this node was freed" % [name, "DamageBox"])
		queue_free()
	damage_box = $DamageBox
	if  has_node("DamageBox/EdgeCheckerRayCast"):
		edge_checker_ray_cast = $DamageBox/EdgeCheckerRayCast


func _physics_process(delta: float) -> void:
	match state:
		EnemyStateMachine.MOVE:
			move_state(delta)
		EnemyStateMachine.ATACK:
			attack_state()
		EnemyStateMachine.CHASE:
			chase_state()
		EnemyStateMachine.DAMAGED:
			damaged_state()
		EnemyStateMachine.DEATH:
			death_state()
	
	if !is_on_floor():
		velocity.y += clamp(Globals.gravity*delta, Globals.VELOCITY_Y_MIN, \
											Globals.VELOCITY_Y_MAX)
	
	move_and_slide()


func move_state(delta: float):
	if !edge_checker_ray_cast.is_colliding() and is_on_floor():
		set_direction(-direction)
	animation_player.play("move")
	velocity.x = lerp(velocity.x + Globals.ENEMY_SPEED*delta*direction, \
	 Globals.ENEMY_MAX_SPEED*direction, 0.8)


func attack_state():
	pass


func chase_state():
	pass


func damaged_state():
	pass


func death_state():
	pass


func set_direction(_direction: int):
	direction = _direction
	# this piece of code is required because of chance for scales be not equal
	# exactly 1 or -1, which is direction, so that's it
	animated_sprite_2d.scale.x = abs(animated_sprite_2d.scale.x)*direction
	damage_box.scale.x = abs(damage_box.scale.x)*direction
	edge_checker_ray_cast.scale.x = abs(edge_checker_ray_cast.scale.x)*direction
