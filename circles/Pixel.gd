extends Node2D

var size = 2 #Pixels in size

#How long to stay as each color
var white_lifetime = 0.1
var color_lifetime = 0.25
var fade_duration = 0.25
var current_lifetime = 0

var white_color = ColorN("White")
var current_color = null
var color = null
var fade_color = null

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	#Calculate target colors
	current_color = white_color
	fade_color = Color(color.r, color.g, color.b, 0)
	
	#Kick off the tween sequence
	do_tween()
	
	#Also should process
	set_process(true)

func do_tween():
	#Start tweening everything
	var tween = $Tween
	
	#Start with white fading to the color from white
	tween.interpolate_property(self, "current_color", white_color, color, white_lifetime, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")
	
	#Hold the color for a little bit and then fade to black
	tween.interpolate_property(self, "current_color", color, fade_color, fade_duration, Tween.TRANS_LINEAR, Tween.EASE_OUT, color_lifetime)
	tween.start()
	yield(tween, "tween_completed")
	
	#It has completed it's job, go away
	queue_free()

func _process(delta):
	#Update the sprite
	update()
	
func _draw():
	#Very simple, draw a rectangle
	var rect = Rect2(0, 0, size, size)
	draw_rect(rect, current_color)
