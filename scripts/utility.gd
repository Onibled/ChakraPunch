extends Node

# =========================================================
# 🎮 GAME UTILS
# Raccolta di funzioni statiche riutilizzabili
# Accessibile globalmente tramite Autoload (GameUtils)
# =========================================================


# ---------------------------------------------------------
# 📷 CAMERA
# ---------------------------------------------------------

## Restituisce la prima camera nel gruppo "camera"
## Utile per effetti globali (shake, zoom, ecc.)
static func get_camera(node: Node) -> Camera2D:
	return node.get_tree().get_first_node_in_group("camera")
	
## Applica camera shake globale
static func camera_shake(node: Node, strength := 5.0):
	var cam = get_camera(node)
	if cam and cam.has_method("shake"):
		cam.shake(strength)

# ---------------------------------------------------------
# 💥 HITSTOP (freeze frame)
# ---------------------------------------------------------

## Ferma temporaneamente il tempo di gioco
## duration = durata in secondi
## scale = quanto rallentare (0.05 = quasi fermo)
## Usato per dare "peso" ai colpi
static func hitstop(duration := 0.05, scale := 0.05) -> void:
	var previous = 1.0
	
	Engine.time_scale = scale
	await Engine.get_main_loop().create_timer(duration).timeout
	
	Engine.time_scale = previous
	
## Sistema completo di impatto (shake + hitstop)
static func hit_impact(node: Node, damage: float, kb: Vector2):
	
	# 🎯 forza basata su danno + knockback
	var force = kb.length() * 0.01 + damage * 0.2
	
	# 📷 CAMERA SHAKE
	#camera_shake(node, clamp(force, 0.01, 12))
	camera_shake(node, 1)
	
	# ⏱️ HITSTOP DINAMICO
	var hitstop_time = clamp(damage * 0.002, 0.001, 0.08)
	hitstop(hitstop_time, 0.1)
	
static func camera_zoom(node):
	var cam = get_camera(node)
	if cam and cam.has_method("impact_zoom"):
		cam.impact_zoom()
		
# ---------------------------------------------------------
# ➡️ DIREZIONE
# ---------------------------------------------------------

## Restituisce direzione input orizzontale (-1, 0, 1)
static func get_facing_input() -> int:
	return Input.get_axis("move_left", "move_right")


## Calcola direzione da un punto a un altro (solo asse X)
## Utile per AI, attacchi, knockback
static func get_direction(from: Vector2, to: Vector2) -> int:
	return sign(to.x - from.x)
	
# ---------------------------------------------------------
# 🧠 MOVEMENT HELPERS
# ---------------------------------------------------------

## Simile a move_toward ma più controllabile
## Avvicina "value" a "target" con una velocità "amount"
static func approach(value: float, target: float, amount: float) -> float:
	if value < target:
		return min(value + amount, target)
	else:
		return max(value - amount, target)


## Limita la lunghezza di un vettore
## Utile per velocità massima o knockback
static func clamp_vector(vec: Vector2, max_length: float) -> Vector2:
	if vec.length() > max_length:
		return vec.normalized() * max_length
	return vec
	
# ---------------------------------------------------------
# 💥 COMBAT HELPERS
# ---------------------------------------------------------

## Genera un knockback coerente
## direction = -1 o 1
## force = forza orizzontale
## lift = spinta verticale (negativa = verso l’alto)
static func calculate_knockback(direction: int, force: float, lift := -200) -> Vector2:
	return Vector2(direction * force, lift)
	
## Genera un knockback coerente
## direction = -1 o 1
## force = forza orizzontale
## lift = spinta verticale (negativa = verso l’alto)
static func calculate_knockback_by_kb(direction: int, kb: Vector2) -> Vector2:
	return Vector2(direction * kb.x, kb.y)

## Controlla se un input può continuare una combo
## current → dati combo corrente
## input → input ricevuto (es. "light")
## Ritorna true se è un input valido per chain
static func can_chain(current: Dictionary, input: String) -> bool:
	return input in current.get("next", [])

# ---------------------------------------------------------
# 🎲 RANDOM / EFFECTS
# ---------------------------------------------------------

## Aggiunge variazione casuale a una direzione
## angle_deg = deviazione massima in gradi
## Utile per effetti visivi (particelle, colpi)
static func random_spread(base: Vector2, angle_deg: float) -> Vector2:
	var angle = deg_to_rad(randf_range(-angle_deg, angle_deg))
	return base.rotated(angle)

# ---------------------------------------------------------
# 🔥 Input mapping
# ---------------------------------------------------------

## Ritorna input attacco semplificato
## "light" / "heavy" / ""
## Utile per sistemi combo centralizzati
static func get_attack_input() -> String:
	if Input.is_action_just_pressed("light_attack"):
		return "light"
	if Input.is_action_just_pressed("heavy_attack"):
		return "heavy"
	return ""


# ---------------------------------------------------------
# 💥 VFX EFFECTS
# ---------------------------------------------------------

static func spawn_hit_spark(node: Node, position: Vector2, direction: int, scale := 1.0):
	var spark = preload("res://scenes/HitSpark.tscn").instantiate()
	
	spark.global_position = position
	
	# orientamento
	spark.scale.x = direction * scale
	spark.scale.y = scale
	
	node.get_tree().current_scene.add_child(spark)
	
static func spawn_hit_spark_advanced(node: Node, position: Vector2, kb: Vector2):
	var spark = preload("res://scenes/HitSpark.tscn").instantiate()
	
	spark.global_position = position
	
	# ruota verso direzione knockback
	spark.rotation = kb.angle()
	
	# scala in base alla forza
	var scale = clamp(kb.length() * 0.005, 0.8, 1.5)
	spark.scale = Vector2.ONE * scale
	
	node.get_tree().current_scene.add_child(spark)
	
#static func spawn_hit_spark_by_type(node, pos, kb, type):
	#var path : String = ""
	#
	#match type:
		#"light":
			#path = "res://scenes/vfx/hit_light.tscn"
		#"heavy":
			#path = "res://scenes/vfx/hit_heavy.tscn"
		#"launcher":
			#path = "res://scenes/vfx/hit_launcher.tscn"
	#
	#var spark = preload(path).instantiate()
	#spark.global_position = pos
	#spark.rotation = kb.angle()
	#
	#node.get_tree().current_scene.add_child(spark)

static func screen_flash(node):
	var flash = node.get_tree().get_first_node_in_group("flash")
	if flash:
		flash.flash()

# ---------------------------------------------------------
# 🛠️ UTILS GENERICHE
# ---------------------------------------------------------

## Recupera un nodo in modo sicuro
## Evita crash se il nodo non esiste
static func safe_get(node: Node, path: NodePath) -> Node:
	if node.has_node(path):
		return node.get_node(path)
	return null


## Stampa solo in build di debug
## Evita spam in release
static func debug_print(text) -> void:
	if OS.is_debug_build():
		print(text)


# ---------------------------------------------------------
# 💥 Gestione del tempo
# ---------------------------------------------------------

static var current_time_scale := 1.0
static var target_time_scale := 1.0

## Rallenta il tempo di gioco
static func slow_time(scale := 0.3):
	target_time_scale = scale
	current_time_scale = scale
	Engine.time_scale = scale
	
static func slow_time_smooth(node: Node, scale := 0.85, duration := 0.2):
	var tween = node.create_tween()
	tween.tween_property(Engine, "time_scale", scale, duration)

## Rallenta il tempo di gioco
static func resume_time():
	target_time_scale = 1.0
	current_time_scale = 1.0
	Engine.time_scale = 1.00
	
static func resume_time_smooth(node: Node, duration := 0.1):
	var tween = node.create_tween()
	tween.tween_property(Engine, "time_scale", 1.0, duration)
	
static func toggle_pause(node: Node):
	var tree = node.get_tree()
	tree.paused = not tree.paused
