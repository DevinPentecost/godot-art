extends Node2D

var start_point = Vector2(0, 0)
var end_point = Vector2(0, 0)
var color = Color(1, 1, 1)

var fade_delay = 0.5
var fade_time = 1
var line_thickness = 1

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	update()
	
	#Tween away
	var final_color = Color(color.to_rgba32())
	final_color.a = 0.25
	$Tween.interpolate_property(self, "modulate", color, final_color, fade_time, Tween.TRANS_LINEAR, Tween.EASE_IN, fade_delay)
	$Tween.start()

func _draw():
	#Draw a line segment
	draw_line(start_point, end_point, color, line_thickness, true)
