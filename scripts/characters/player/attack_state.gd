extends StatePlayer

var attack_time: float = 0.0
var attack_duration: float = 0.25

var can_cancel: bool = false
var attack_name: String = ""
var current_attack_data := {}

# 🎯 finestra di confirm (PRO)
var confirm_window_start: float = 0.08
var confirm_window_end: float = 0.22

func enter():
	attack_time = 0.0
	can_cancel = true
	
	player.velocity.x = 0
	player.hitbox.monitoring = true
	player.has_hit = false
	
	# -------------------------------------------------
	# 🎯 SELEZIONE ATTACCO (DATA DRIVEN)
	# -------------------------------------------------
	
	if player.attack_type == "launcher":
		current_attack_data = player.combo_data["launcher"]
	elif player.attack_type == "heavy":
		current_attack_data = player.combo_data["heavy"]
	else:
		current_attack_data = player.combo_data[player.current_attack]
	
	attack_name = current_attack_data["anim"]
	
	# -------------------------------------------------
	# 💥 SET HITBOX
	# -------------------------------------------------
	
	player.hitbox.damage = current_attack_data["damage"]
	player.hitbox.knockback = current_attack_data["kb"]
	player.hitbox.attack_data = current_attack_data
	
	# confirm window data-driven
	confirm_window_start = current_attack_data.get("confirm_start", 0.08)
	confirm_window_end = current_attack_data.get("confirm_end", 0.22)
	
	# -------------------------------------------------
	# 🎬 PLAY ANIM
	# -------------------------------------------------
	
	player.anim.play(attack_name)
	return

func exit():
	player.hitbox.monitoring = false
	return

func update(delta):
	attack_time += delta
	
	# -------------------------------------------------
	# 🎮 AIR CONTROL
	# -------------------------------------------------
	
	if not player.is_on_floor():
		player.handle_air_control(delta)
		player.velocity.y *= 0.8  # air stall
	
	# -------------------------------------------------
	# 🎯 MOVIMENTO ATTACCO
	# -------------------------------------------------
	
	player.velocity.x = player.facing_direction * 50
	
	# -------------------------------------------------
	# 🎯 CONFIRM WINDOW (STEP 6)
	# solo in questa finestra puoi fare combo
	# -------------------------------------------------
	
	var can_confirm: bool = attack_time >= confirm_window_start and attack_time <= confirm_window_end
	
	# -------------------------------------------------
	# 🔗 COMBO SYSTEM (HIT CONFIRM + WINDOW)
	# -------------------------------------------------
	
	if can_cancel:
		# -------------------------------------------------
		# ⚡ STATE CANCEL (PRIORITÀ ALTA)
		# -------------------------------------------------
		
		if player.try_dash_cancel():
			if current_attack_data.get("dash_cancel", true) and player.has_hit:
				state_machine.change_state("DashState")
				return
				
		if Input.is_action_pressed("meditate") and player.is_on_floor():
			#if current_attack_data.get("dash_cancel", true) and player.has_hit:
			if player.has_hit:
				state_machine.change_state("MeditateState")
				return
		
		# -------------------------------------------------
		# 🔗 COMBO
		# -------------------------------------------------
		
		if not player.has_hit:
			return
		
		var next_attacks = current_attack_data.get("next", [])
		
		#if player.input_buffer.consume("light"):
			#if "light_2" in next_attacks:
				#player.current_attack = "light_2"
				#player.has_hit = false
				#state_machine.change_state("AttackState")
				#return
		
		if player.input_buffer.consume("heavy"):
			if "heavy" in next_attacks:
				player.current_attack = "heavy"
				player.has_hit = false
				state_machine.change_state("AttackState")
				return
	
	# -------------------------------------------------
	# 🔥 AIR COMBO CONTROL SYSTEM
	# -------------------------------------------------
	
	if player.combo_target != null:
		player.handle_combo_follow(delta)
		player.handle_air_combo_control(delta)
		
	# -------------------------------------------------
	# ⏱️ FINE ATTACCO
	# -------------------------------------------------
	
	if attack_time >= attack_duration:
		player.clear_combo_target()
		
		if player.is_on_floor():
			state_machine.change_state("MoveState")
		else:
			state_machine.change_state("FallState")
		return
	return
