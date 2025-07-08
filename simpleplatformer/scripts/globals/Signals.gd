extends Node

# signal emitted when the player hits an enemy
signal enemy_is_hitted(area, pos, damage)

# signal emitted when enemy/object hits the player
signal player_is_hitted(pos , damage)
