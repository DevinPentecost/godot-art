extends "res://dust/LowResulizor.gd"

#What it looks like
#export(Texture) var dune_textures
var dune_textures = [preload("res://dust/assets/dune_1.png"), preload("res://dust/assets/dune_2.png"), preload("res://dust/assets/dune_3.png")]
export(Color, RGB) var dune_color_start
export(Color, RGB) var dune_color_end
export(float) var dune_scale_start
export(float) var dune_scale_end

#How does it move
export(float) var dune_velocity_start
export(float) var dune_velocity_end

#Where does it start
export(float) var dune_spawn_start
export(float) var dune_spawn_end

#How long should they live for (because I'm too lazy to detect when they are off screen)
#TODO: Don't be lazy
export(float) var dune_max_lifetime

#How many to start with
export(int) var dune_prep_count

#Script to apply for dunes
var dune_script = preload("res://dust/DuneController.gd")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	#Spawn initial dunes
	var simulated_spawn_time = 0
	for initial_dune in range(dune_prep_count):
		#We need to create it and move it forward
		var new_dune = build_dune()
		
		#Move it forward
		new_dune.position.x = new_dune.velocity * simulated_spawn_time
		new_dune.lifetime = simulated_spawn_time
		
		#Update the time
		simulated_spawn_time += lerp(dune_spawn_start, dune_spawn_end, randf())
		
	#Spawn the first dune
	reset_timer()
	
func spawn_dune():
	#Spawn a new dune
	build_dune()
	reset_timer()
	
func reset_timer():
	#How long until we build the new one?
	$SpawnTimer.wait_time = lerp(dune_spawn_start, dune_spawn_end, randf())
	$SpawnTimer.start()

func build_dune():
	#We need to make a new dune sprite
	var new_dune = Sprite.new()
	
	#Do all of the visual setup
	new_dune.texture = dune_textures[randi()%len(dune_textures)];
	new_dune.modulate = dune_color_start.linear_interpolate(dune_color_end, randf())
	var new_scale = lerp(dune_scale_start, dune_scale_end, randf())
	new_dune.scale = Vector2(new_scale, new_scale)
	new_dune.flip_h = bool(round(randf()))
	
	#Do all the positional setup
	new_dune.position.y = lerp(dune_spawn_start, dune_spawn_end, randf())
	
	#Give it a velocity
	var dune_velocity = lerp(dune_velocity_start, dune_velocity_end, randf())
	
	#Make the dune
	new_dune.set_script(dune_script)
	new_dune.velocity = dune_velocity
	new_dune.lifetime = 0
	new_dune.max_lifetime = dune_max_lifetime
	add_child(new_dune)
	return new_dune
	
func _on_SpawnTimer_timeout():
	#We need to spawn a new one
	spawn_dune()