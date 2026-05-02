extends StatePlayer

# -------------------------------------------------
# 🔣 SEQUENZA SEGNI
# -------------------------------------------------

var input_sequence := []
var max_sequence: int = 3

# mapping tasti → significato
var input_map = {
	"light_attack": preload("res://sprites/square_mini.png"), # "stability",   # □
	"heavy_attack": preload("res://sprites/triangle.png"), #"expansion",   # ○
	"interact": preload("res://sprites/circle.png"), #"impulse",  # △
	"jump": preload("res://sprites/cross.png") #"connection"           # ✖
}
@onready var symbol: Sprite2D = $"../../Symbol"

# -------------------------------------------------
# ⏱️ TIMING
# -------------------------------------------------

var meditate_time: float = 0.0
var absorb_delay: float = 0.2

var regen_delay := 1.0
var regen_time := 0.0

var regen_duration := 4.0
var regen_amount := 100.0

var regen_started := false

var regen_buffer := 0.0
var rate := 25.0

# -------------------------------------------------
# 🔄 ENTER / EXIT
# -------------------------------------------------

func enter():
	player.velocity.x = 0
	player.meditating = true
	
	Utility.slow_time_smooth(player, 0.6)
	
	input_sequence.clear()
	meditate_time = 0.0
	regen_time = 0.0
	
	symbol.texture = null
	
	player.anim.play("meditate")
	return

func exit():
	player.meditating = false
	player.can_move = true
	symbol.texture = null
	Utility.resume_time_smooth(player)

# -------------------------------------------------
# 🔄 UPDATE
# -------------------------------------------------

func update(delta):

	# ❌ USCITA
	if not Input.is_action_pressed("meditate") or not player.is_on_floor():
		state_machine.change_state("MoveState")
		return
	
	# ⚡ DASH CANCEL
	if player.input_buffer.consume("dash") and player.can_dash():
		state_machine.change_state("DashState")
		return
	
	# ⏱️ TIMER
	meditate_time += delta
	regen_time += delta
	
	# 🎮 INPUT SEGNI
	handle_inputs()
	
	player.handle_movement(delta)
	handle_regen(delta)
	return
	
# -------------------------------------------------
# 🎮 INPUT → SEGNI
# -------------------------------------------------

func handle_inputs():
	for action in input_map.keys():
		if player.input_buffer.consume(action):
			input_sequence.append(action)
			on_symbol_input(input_map[action])
	
	if input_sequence.size() >= max_sequence:
		resolve_sequence()
		input_sequence.clear()
	return

# -------------------------------------------------
# ✨ FEEDBACK IMMEDIATO (UI / FX)
# -------------------------------------------------

func on_symbol_input(symbol_action):
	symbol.texture = symbol_action
	return
	
# -------------------------------------------------
# ✨ RIGENERAZIONE CHAKRA
# -------------------------------------------------
func handle_regen(delta):
	if player.chakra < 100:
		# 1️⃣ delay iniziale
		if regen_time < regen_delay:
			return
		
		# 2️⃣ calcolo progressione
		var t = regen_time - regen_delay
		
		if t >= regen_duration:
			return
		
		regen_buffer += rate * delta
		while regen_buffer >= 1.0:
			player.add_chakra(1)
			regen_buffer -= 1.0
	return

# -------------------------------------------------
# 🧠 RISOLUZIONE SEQUENZE (CORE SYSTEM)
# -------------------------------------------------

func resolve_sequence():
	var result = interpret_sequence(input_sequence)
	
	if result == null:
		print("Sequenza non valida")
		return
	
	execute_ability(result)
	return

# -------------------------------------------------
# 🔍 INTERPRETAZIONE (LINGUAGGIO)
# -------------------------------------------------

func interpret_sequence(seq: Array):
	var last_3_seq = seq.slice(seq.size() - 3, seq.size())
	# 🔥 PROIETTILE
	if last_3_seq == ["light_attack", "heavy_attack", "interact"]:
		return "projectile"
	
	# 🌊 ONDA
	if last_3_seq == ["expansion", "impulse", "expansion"]:
		return "wave"
	
	# ⬆️ LAUNCHER
	if last_3_seq == ["stability", "impulse"]:
		return "launcher"
	
	# ⚡ DASH ATTACK
	if last_3_seq == ["connection", "impulse"]:
		return "dash_attack"
	
	return null

# -------------------------------------------------
# ⚔️ / 🧩 ESECUZIONE
# -------------------------------------------------

func execute_ability(ability: String):
	match ability:
		
		"projectile":
			if player.chakra >= 100:
				player.add_chakra(-100)
				
				# passa info allo stato
				player.cast_data = {
					"type": "projectile"
				}
				
				state_machine.change_state("CastState")
				input_sequence.clear()
		
		"wave":
			if player.chakra >= 80:
				player.chakra -= 80
				spawn_wave()
		
		"launcher":
			player.do_launcher_attack()
		
		"dash_attack":
			player.do_dash_attack()
	return

# -------------------------------------------------
# 💥 ABILITÀ (stub)
# -------------------------------------------------

func spawn_wave():
	print("🌊 Onda chakra")
	return
