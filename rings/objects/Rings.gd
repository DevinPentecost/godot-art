extends Node2D
tool

#Imports
const Ring = preload("res://objects/Ring.gd")
const Segment = preload("res://objects/Segment.gd")

var _ring_debug = false

#Size of it
export(int) var radius setget _set_radius

#Size of rings
export(int, 1, 100) var ring_height = 15 setget _set_ring_height
export(float, 0, 10) var ring_spacing = 5 setget _set_ring_spacing
var rings = []

#Segment information
export(Vector2) var segment_widths = Vector2(PI/16, PI/8) setget _set_segment_widths
export(Vector2) var segment_spacings = Vector2(PI/32, PI/16) setget _set_segment_spacings

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
	_rebuild_all()
	
	#Every frame
	set_process(true)
	
func _process(delta):
	#Update every ring
	for ring in rings:
		ring.update(delta)
		
	#Update the visual
	update()
	
func _rebuild_all():
	print("REBUILD")
	_build_rings()
	update()
	
func _build_rings():
	#Calculate how many rings to build
	var current_radius = center_radius
	var ring_count = _get_ring_count()
	for ring in range(ring_count):
		
		#Where does this ring go
		current_radius += ring_spacing
		current_radius += ring_height/2.0
		
		#What's the starting condition
		var angle_offset = rand_range(-PI, PI)
		var velocity = rand_range(0.1, 0.5)
		var new_ring = Ring.new(current_radius, ring_height, segment_widths, segment_spacings, base_color, angle_offset, velocity)
		
		if ring == 0 and _ring_debug:
			new_ring._debug = true
		
		#Build this ring's segments
		new_ring.create_segments()
		
		#Add the ring
		rings.append(new_ring)
		
		#Add the remaining height
		current_radius += ring_height/2.0

func _set_radius(new_radius):
	radius = new_radius
	
func _set_ring_height(new_height):
	ring_height = new_height
	
func _set_ring_spacing(new_spacing):
	ring_spacing = new_spacing
	
func _set_segment_widths(new_widths):
	segment_widths = new_widths
	
func _set_segment_spacings(new_spacings):
	segment_spacings = new_spacings
	
func _set_debug(new_debug):
	debug = new_debug
	
func _set_base_color(new_color):
	base_color = new_color
	
func _set_center_radius(new_radius):
	center_radius = new_radius
	
func _get_ring_count():
	#How many rings can we fit
	var remaining_radius = radius
	
	#Take the center out
	remaining_radius -= center_radius
	
	#Now keep taking out space till we run out of rings
	var ring_count = 0
	while remaining_radius >= 0:
		
		#Add a ring
		ring_count += 1
		
		#Remove space for this ring
		remaining_radius -= ring_height + ring_spacing
		
	#Return how many rings we got
	print('TOTAL RING COUNT ', ring_count)
	return ring_count

func _debug_draw(color=Color(1, 0, 1)):
	
	#Draw a square that takes the whole space
	var top_left = Vector2(-radius, -radius)
	var size = Vector2(radius*2, radius*2)
	var rectangle = Rect2(top_left, size)
	draw_rect(rectangle, color)
	

func _draw_center():
	var target_position = Vector2(0, 0)
	draw_circle(target_position, center_radius, base_color)
	
func _draw_rings():
	#Go over each ring
	print('DRAW RINGS')
	
	for ring in rings:
		var segments = ring.get_polygons()
		for segment in segments:
			#Draw the polygon
			var segment_polygon = segment[0]
			var segment_colors = segment[1]
			draw_polygon(segment_polygon, segment_colors)
	
func _draw():
	
	if debug:
		_debug_draw()
		
		
	#Draw the center circle
	_draw_center()
	
	#Draw all the rings
	_draw_rings()
	
	pass