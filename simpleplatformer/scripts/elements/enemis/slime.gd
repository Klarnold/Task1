extends Enemy

# position, from where slime was attacked
var attacked_pos: Vector2


func _ready() -> void:
	super._ready()
	Signals.enemy_is_hitted.connect(take_damage)
	


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
	velocity.x = Globals.ENEMY_KNOCKBACK_SPEED * get_direction(attacked_pos)
	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "velocity:x", 0, 0.5)
	await animation_player.animation_finished
	state = Globals.EnemyStateMachine.MOVE

# returns 1 if given Vector2 is on the left side of this CharacterBody2D and
# returns -1 if given Vector2 is on the right side of this CharacterBody2D
func get_direction(pos: Vector2):
	return -1 if (pos.x - position.x) > 0 else 1
