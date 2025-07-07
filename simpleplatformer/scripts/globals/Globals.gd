extends Node

# CONSTS_ST
# ...for all
const VELOCITY_Y_MIN: float = -500
const VELOCITY_Y_MAX: float = 500

# ...for enemis

enum EnemyStateMachine{
	MOVE,
	ATACK,
	DAMAGED,
	DEATH
}

const ENEMY_KNOCKBACK_SPEED: float = 100.0
const ENEMY_SPEED: float = 4000
const ENEMY_MAX_SPEED: float = 50
# CONSTS_END

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
