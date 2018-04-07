extends "res://dust/DuneMaker.gd"

#What it looks like
#export(Texture) var dune_textures

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	dune_textures = [preload("res://dust/assets/pillar_1.png"), preload("res://dust/assets/pillar_2.png"), preload("res://dust/assets/pillar_3.png")]

	
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