extends CanvasItem
tool

var shader = preload("res://lib/godot-practice-shaders/3d/lowres/lowres.shader")
var softnoise = preload("res://lib/softnoise/softnoise.gd").SoftNoise.new()

export(int) var start_scale = 1;
export(int) var end_scale = 10;
export(float) var speed = 0.5;

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	#Make a new material
	material = ShaderMaterial.new()
	material.set_shader(shader)
	material.set_shader_param("resolution_scale", 2)
	
	set_process(true)

func _process(delta):
	#Just get a new value
	var new_scale = softnoise.simple_noise1d(OS.get_ticks_msec()*speed)
	new_scale *= lerp(start_scale, end_scale, new_scale);
	material.set_shader_param("resolution_scale", new_scale)
	
