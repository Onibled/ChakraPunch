extends StatePlayer

var cast_time := 0.25
var has_cast := false

func enter():
	player.velocity = Vector2.ZERO
	has_cast = false
	
	player.anim.play("cast")

func update(delta):
	cast_time -= delta
	
	# spawn a metà animazione (feeling migliore)
	if not has_cast and cast_time <= 0.15:
		spawn_projectile()
		has_cast = true
	
	if cast_time <= 0:
		state_machine.change_state("MoveState")

# -------------------------------------------------
# 🔮 SPAWN
# -------------------------------------------------

func spawn_projectile():
	var data = player.cast_data
	
	match data.get("type", ""):
		
		"projectile":
			var projectile = preload("res://scenes/projectile.tscn").instantiate()
			
			projectile.direction = Vector2(player.facing_direction, 0)
			projectile.global_position = player.global_position + Vector2(20 * player.facing_direction, 0)
			#projectile.owner = player
			
			# 👉 QUI puoi settare varianti
			projectile.use_boomerang = false
			projectile.use_zigzag = false
			projectile.multi_hit = false
			
			get_tree().current_scene.add_child(projectile)
