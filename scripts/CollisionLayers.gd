class_name CollisionLayers

# LAYER (bit index)
const WORLD      = 1
const PLAYER     = 2
const ENEMY      = 3
const PROJECTILE = 4
const HITBOX     = 5
const HURTBOX    = 6

# MASK (bitmask già pronti)
const PLAYER_HIT_MASK = (1 << ENEMY) | (1 << WORLD)
const ENEMY_HIT_MASK  = (1 << PLAYER) | (1 << WORLD)
const PROJECTILE_MASK = (1 << ENEMY) | (1 << WORLD)
