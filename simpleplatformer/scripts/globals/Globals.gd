extends Node

# CONSTS_ST
# ...for all
const VELOCITY_Y_MIN: float = -500
const VELOCITY_Y_MAX: float = 500

# ...for enemies

enum EnemyStateMachine{
	MOVE,
	ATACK,
	DAMAGED,
	DEATH
}

const CHASE_SPEED_MODIFIER: float = 2
const CHASE_TIME: float = 1.0
const ENEMY_KNOCKBACK_SPEED: float = 100.0
const ENEMY_SPEED: float = 4000
const ENEMY_MAX_SPEED: float = 50
# CONSTS_END

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: CharacterBody2D


# GLOBAL_FUNCS_ST
# returns 1 if given Vector2 is on the left side of this CharacterBody2D and
# returns -1 if given Vector2 is on the right side of this CharacterBody2D
func get_direction(pos: Vector2, called_pos: Vector2):
	return -1 if (pos.x - called_pos.x) > 0 else 1

# GLOBAL_FUNCS_END
