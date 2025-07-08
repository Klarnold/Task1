extends Node

# signal emitted when the player hits an enemy
signal enemy_is_hitted(area: Area2D, pos: Vector2, damage: float)

# signal emitted when enemy/object hits the player
signal player_is_hitted(pos: Vector2 , damage: float)

# signal emitted when player LOST his health due to some ammount of damage
signal player_is_damaged(damage: float)

# signal emitted when player is dead
signal player_is_dead()

# signal emitted when enemy is dead
signal enemy_is_dead()

# emitted when player is finished it's _ready() function
signal player_is_ready()
