extends Node2D

# -------------------------------------------------
# ⚙️ CONFIG
# -------------------------------------------------

@export var damage := 1
@export var knockback := Vector2(120, -150)
@onready var hitbox: Area2D = $Hitbox

# evita spam danni
@export var hit_cooldown := 0.5

var hit_targets := {}

# -------------------------------------------------
# 🔗 READY
# -------------------------------------------------

func _ready():
	hitbox.body_entered.connect(_on_area_entered)

# -------------------------------------------------
# 💥 HIT
# -------------------------------------------------

func _on_area_entered(area):
	if not area.has_method("apply_knockback"):
		return
	
	# ----------------------------------------
	# ⏱️ COOLDOWN PER TARGET
	# ----------------------------------------
	
	if hit_targets.has(area):
		return
	
	hit_targets[area] = true
	
	# direzione knockback (spinge lontano dallo spike)
	var dir = sign(area.global_position.x - global_position.x)
	if dir == 0:
		dir = 1
	
	var final_kb = Vector2(knockback.x * dir, knockback.y)
	
	# ----------------------------------------
	# 🧠 ATTACK DATA → STUN
	# ----------------------------------------
	
	var attack_data = {
		"reaction": "stagger"  # 👈 colpo leggero
	}
	
	area.apply_knockback(damage, final_kb, attack_data)
	
	# ----------------------------------------
	# ⏳ RESET COOLDOWN
	# ----------------------------------------
	
	await get_tree().create_timer(hit_cooldown).timeout
	hit_targets.erase(area)
