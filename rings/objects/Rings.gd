extends Node2D
tool

#Imports
const Segment = preload("res://objects/Segment.gd")

#Size of it
export(int) var width setget _set_width
export(int) var height setget _set_height

#Size of rings
export(int, 1, 100) var ring_height = 5 setget _set_ring_height
export(float, 0, 10) var ring_spacing = 2 setget _set_ring_spacing

#Draw a debug square
export(bool) var debug = false setget _set_debug

#The color of this
#TODO: Allow for more interesting colors
export(Color) var base_color = Color(1, 0, 1) setget _set_base_color

#The center [radius, color]
export(float) var center_radius = 10 setget _set_center_radius

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _set_width(new_width):
	width = new_width
	update()

func _set_height(new_height):
	height = new_height
	update()

func _set_ring_height(new_height):
	ring_height = new_height
	update()

func _set_ring_spacing(new_spacing):
	ring_spacing = new_spacing
	update()
	
func _set_debug(new_debug):
	debug = new_debug
	update()

func _set_base_color(new_color):
	base_color = new_color
	update()

func _set_center_radius(new_radius):
	center_radius = new_radius
	update()

func _debug_draw(color=Color(1, 0, 1)):
	
	var top_left = Vector2(-width/2, -height/2)
	var size = Vector2(width, height)
	var rectangle = Rect2(top_left, size)
	draw_rect(rectangle, color)
	pass

func _draw_center():
	var position = Vector2(0, 0)
	draw_circle(position, center_radius, base_color)
	
func _draw_segment(radius, angle, segment):
	
	#Get the polygon for this segment
	var segment_pools = segment.get_polygon(radius, angle)
	var segment_polygon = segment_pools[0]
	var segment_colors = segment_pools[1]
	draw_polygon(segment_polygon, segment_colors)
	
	
	pass
	
func _draw():
	
	if debug:
		_debug_draw()
		
		
	#Draw the center circle
	#_draw_center()
	var __segment = Segment.new(0, PI/8, ring_height, base_color)
	_draw_segment(15, 0, __segment)
	
	pass