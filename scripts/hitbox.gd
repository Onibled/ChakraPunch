extends Area2D

@onready var hit_sound: AudioStreamPlayer2D = $HitSound

@export var damage := 10
@export var knockback := Vector2.ZERO

# 🔥 NUOVO: dati completi dell’attacco
var attack_data := {}

func _ready():
	#area_entered.connect(_on_area_entered)
	return

func start_hit():
	monitoring = true

func stop_hit():
	monitoring = false

func _on_area_entered(area):
	var target = area.get_parent()
	
	if not target.has_method("apply_knockback"):
		return
	
	# -------------------------------------------------
	# 🎯 DIREZIONE (calcolata al momento dell’impatto)
	# -------------------------------------------------
	
	var dir

	if owner.has_method("facing_direction"):
		dir = owner.facing_direction
	else:
		dir = Utility.get_direction(owner.global_position, target.global_position)
		
	# -------------------------------------------------
	# 💥 KNOCKBACK (DATA DRIVEN)
	# -------------------------------------------------
	
	var kb = knockback
	kb.x *= dir
	
	# 🎲 micro variazione direzione
	kb = kb.rotated(randf_range(-0.1, 0.1))
	
	# -------------------------------------------------
	# 🎈 JUGGLE ADJUST
	# -------------------------------------------------
	
	if target.has_method("is_airborne") and target.is_airborne:
		kb.y *= attack_data.get("air_scale", 0.7)
	
	# -------------------------------------------------
	# 🎯 APPLY HIT
	# -------------------------------------------------
	
	target.apply_knockback(damage, kb, attack_data)
	
	# -------------------------------------------------
	# 🎯 CALLBACK OWNER (player / enemy / ecc.)
	# -------------------------------------------------
	
	if owner.has_method("set_combo_target"):
		owner.set_combo_target(target)
	
	if owner.has_method("register_hit"):
		owner.register_hit()
	
	# -------------------------------------------------
	# 💥 FEEDBACK
	# -------------------------------------------------
	
	Utility.hit_impact(owner, damage, kb)
	#Utility.camera_zoom(owner)
	if hit_sound.stream:
			var snd = hit_sound.duplicate()
			get_tree().current_scene.add_child(snd)
			snd.global_position = global_position
			snd.play()
	
	Utility.spawn_hit_spark_advanced(
		owner,
		area.global_position,
		kb
	)
