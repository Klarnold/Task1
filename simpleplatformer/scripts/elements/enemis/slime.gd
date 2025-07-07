extends Enemy


@onready var chase_timer: Timer = $ChaseTimer


# position, from where slime was attacked
var attacked_pos: Vector2


func _ready() -> void:
	super._ready()
	# connecting global signals
	Signals.enemy_is_hitted.connect(take_damage)
	
	#connecting "local" signals
	chase_area.area_entered.connect(_on_chase_area_area_entered)
	chase_area.area_exited.connect(_on_chase_area_area_exited)
	chase_timer.timeout.connect(_on_chase_timer_timeout)
	
	# setting local tree nodes
	chase_timer.wait_time = Globals.CHASE_TIME
	


func take_damage(area: Area2D, attack_pos: Vector2, damage: float):
	health -= 1
	if health <= 0:
		health = 0
		state = Globals.EnemyStateMachine.DEATH
	else:
		attacked_pos = attack_pos
		state = Globals.EnemyStateMachine.DAMAGED

func damaged_state(delta: float):
	velocity.x = 0
	animation_player.play("damaged")
	velocity.x = Globals.ENEMY_KNOCKBACK_SPEED * Globals.get_direction(attacked_pos, position)
	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "velocity:x", 0, 0.5)
	await animation_player.animation_finished
	state = Globals.EnemyStateMachine.MOVE


func _on_chase_area_area_entered(player: Area2D):
	chase = true


func _on_chase_area_area_exited(player: Area2D):
	chase_timer.start()


func _on_chase_timer_timeout():
	if chase_area.get_overlapping_areas().size() == 0:
		chase = false

# disconnecting signals is essential to escape queue_free() issues when 
# signals are connected to the null instance
func _exit_tree() -> void:
	super._exit_tree()
	# disconnecting global signals
	Signals.enemy_is_hitted.disconnect(take_damage)
	
	# disconnecting "local" signals
	chase_area.area_entered.disconnect(_on_chase_area_area_entered)
	chase_area.area_exited.disconnect(_on_chase_area_area_exited)
	chase_timer.timeout.disconnect(_on_chase_timer_timeout)
	
