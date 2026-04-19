extends CanvasLayer

# -------------------------------------------------
# ❤️ HEARTS
# -------------------------------------------------

@onready var hearts = $HeartsContainer.get_children()

# -------------------------------------------------
# 🔮 CHAKRA BAR (ProgressBar)
# -------------------------------------------------

@onready var section1: ProgressBar = $ChackraBar/Section1
@onready var section2: ProgressBar = $ChackraBar/Section2
@onready var section3: ProgressBar = $ChackraBar/Section3

var tween_duration := 0.2

var tweens := {}

var player = null

# -------------------------------------------------
# 🔄 READY
# -------------------------------------------------

func _ready():
	setup_sections()
	return

func setup_sections():
	for bar in [section1, section2, section3]:
		bar.min_value = 0
		bar.max_value = 100
		bar.value = 0

# -------------------------------------------------
# ❤️ UPDATE HEALTH
# -------------------------------------------------

func update_health(current_health: int):
	for i in range(hearts.size()):
		if i < current_health:
			hearts[i].texture = preload("res://sprites/square.png")
		else:
			hearts[i].texture = preload("res://sprites/square_mini.png")

# -------------------------------------------------
# 🔮 UPDATE CHAKRA
# -------------------------------------------------

func update_chakra(chakra: float):
	update_section(section1, chakra, 0)
	update_section(section2, chakra, 100)
	update_section(section3, chakra, 200)

# -------------------------------------------------
# 🔮 UPDATE SECTION (ProgressBar)
# -------------------------------------------------

func update_section(bar: ProgressBar, chakra: float, min_val: float):
	if bar == null:
		return

	var fill: float = clamp(chakra - min_val, 0, 100)

	# tween value
	if tweens.has(bar):
		tweens[bar].kill()

	var tween = create_tween()
	tweens[bar] = tween

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(bar, "value", fill, tween_duration)

	# ----------------------------------------
	# 🎨 COLORE (PER SEZIONE INDIPENDENTE)
	# ----------------------------------------

	var percent: float = fill / 100.0

	var target_color := Color(
		1.0 - percent,
		percent,
		0.2
	)

	# 👉 PRENDI lo style attuale
	var fill_style: StyleBoxFlat = bar.get_theme_stylebox("fill")

	# 👉 DUPLICA per evitare condivisione
	fill_style = fill_style.duplicate()

	# 👉 APPLICA colore solo a questa barra
	fill_style.bg_color = target_color

	# 👉 RIASSEGNA
	bar.add_theme_stylebox_override("fill", fill_style)

# -------------------------------------------------
# 🔗 PLAYER LINK
# -------------------------------------------------

func set_player(p):
	player = p
	player.chakra_changed.connect(update_chakra)
	# se hai health signal:
	update_health(player.health_component.health)
	player.health_changed.connect(update_health)
