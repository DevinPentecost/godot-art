extends Node

#The active scene loader
var loader

#Intro fading
const intro_fade_in_time = 2
const click_fade_in_time = 1
const intro_fade_out_time = 10

#Max time to block the main thread 
var time_max = 10 #Milliseconds

#The scene to load
export var main_scene_path = "res://scenes/LittleTreasure.tscn"
var main_scene = null


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	load_main_scene()
	
	set_process(true)
	pass

func load_main_scene():
	#Start loading!
	loader = ResourceLoader.load_interactive(main_scene_path)
	
	#Hide the clicker
	$Intro/Click.modulate = Color(0, 0, 0, 1)
	
	#Also fade in the screen
	var tween = $Tween
	tween.interpolate_property($Intro, "modulate", Color(0, 0, 0, 1), Color(1, 1, 1, 1), intro_fade_in_time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	
func add_main_scene():
	#Fade away the intro splash
	var tween = $Tween
	tween.interpolate_property($Intro, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), intro_fade_out_time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	
	#Add the scene
	get_node("/root").add_child(main_scene.instance())

func _process(delta):
	#Are we done loading?
	if loader == null:
		set_process(false)
		return
	
	#How long has it been
	var start_time = OS.get_ticks_msec()
	
	#Burn some time loading
	while OS.get_ticks_msec() < start_time + time_max:
		#Tell the loader to load some more
		var status = loader.poll()
		
		#Did it finish?
		if status == ERR_FILE_EOF:
			#We are done loading
			main_scene = loader.get_resource()
			
			#Kill the loader
			loader = null
			
			#Also fade in the screen
			var tween = $Tween
			tween.interpolate_property($Intro/Click, "modulate", Color(0, 0, 0, 1), Color(1, 1, 1, 1), click_fade_in_time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			tween.start()
			
			#Listen for some input
			set_process_unhandled_input(true)
			
			#We're done
			break
		
		#Do we keep waiting?
		elif status == OK:
			#We just wait
			pass
		else:
			#We got some error. Give up
			loader = null
			break
			
func _unhandled_input(event):
	
	#Was it a click?
	if event is InputEventMouseButton:
		#We can load now
		add_main_scene()
		
		#Stop listening
		set_process_unhandled_input(false)
