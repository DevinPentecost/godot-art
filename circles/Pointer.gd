extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var color = ColorN("White", 0.5)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	set_process(true)

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	update()
	
func _draw():
	
	var window_size = OS.get_real_window_size()
	
	#Vertical line
	var from = Vector2(0, -global_position.y)
	var to = Vector2(0, window_size.y)
	draw_line(from, to, color)
	
	#Horizontal
	from = Vector2(-global_position.x, 0)
	to = Vector2(window_size.x, 0)
	draw_line(from, to, color)
