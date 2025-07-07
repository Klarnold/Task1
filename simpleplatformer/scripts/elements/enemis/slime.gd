extends Enemy


@onready var chase_timer: Timer = $ChaseTimer
@onready var player_seek_area: Area2D = $DamageBox/PlayerSeekArea
@onready var player_seek_shape: CollisionShape2D = $DamageBox/PlayerSeekArea/PlayerSeekShape
@onready var hit_box_area: Area2D = $DamageBox/HitBoxArea


# position, from where slime was attacked
var attacked_pos: Vector2


func _ready() -> void:
	super._ready()
	# connecting global signals
	Signals.enemy_is_hitted.connect(take_damage)
	
	#connecting "local" signals
	chase_area.area_entered.connect(_on_chase_area_area_entered)
	chase_area.area_exited.connect(_on_chase_area_area_exited)
	player_seek_area.area_entered.connect(_on_player_seek_area_area_entered)
	hit_box_area.area_entered.connect(_on_hit_box_area_area_entered)
	chase_timer.timeout.connect(_on_chase_timer_timeout)
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	
	# setting local tree nodes
	chase_timer.wait_time = Globals.CHASE_TIME
	cooldown_timer.wait_time = Globals.COOLDOWN_TIME


func damaged_state(delta: float):
	velocity.x = 0
	animation_player.play("damaged")
	velocity.x = Globals.ENEMY_KNOCKBACK_SPEED * Globals.get_direction(attacked_pos, position)
	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "velocity:x", 0, 0.5)
	await animation_player.animation_finished
	state = Globals.EnemyStateMachine.MOVE


func take_damage(area: Area2D, attack_pos: Vector2, damage: float):
	health -= 1
	if health <= 0:
		health = 0
		state = Globals.EnemyStateMachine.DEATH
	else:
		attacked_pos = attack_pos
		state = Globals.EnemyStateMachine.DAMAGED


func attack_dash_anim():
	print(velocity.x)
	velocity.x = Globals.ATTACK_DASH_SPEED*direction
	print(velocity.x)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "velocity:x", 0, 0.3)
	await tween.finished


func _on_hit_box_area_area_entered(player: Area2D):
	print("player")


func _on_cooldown_timer_timeout():
	cooldown = false
	player_seek_shape.disabled = true
	player_seek_shape.disabled = false


func _on_player_seek_area_area_entered(player: Area2D):
	if state != Globals.EnemyStateMachine.ATTACK and !cooldown:
		state = Globals.EnemyStateMachine.ATTACK


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
	player_seek_area.area_entered.disconnect(_on_player_seek_area_area_entered)
	hit_box_area.area_entered.disconnect(_on_hit_box_area_area_entered)
	chase_timer.timeout.disconnect(_on_chase_timer_timeout)
	cooldown_timer.timeout.disconnect(_on_cooldown_timer_timeout)
