"""
Model Class for defining a ring of the circle
"""

const Segment = preload("res://objects/Segment.gd")

var _debug = false

#Position and size
var base_radius #In pixels
var radius

var base_height #In pixels, centered
var height

#Sizing of the segments in radians (Vector2(min, max)), centered
var segment_widths

#How far to space each segement in radians (Vector2(min, max))
var segment_spacing

#The 'base' color of this
var base_color
var color

#The rotation of this ring, radians
var angle = 0
var angular_velocity = 0 #Radians per second

#All of the segments
var segments = []

func _init(_radius, _height, _widths, _spacing, _color, _angle=0, _velocity=0):
	#Set the model
	base_radius = _radius
	base_height = _height
	segment_widths = _widths
	segment_spacing = _spacing
	base_color = _color
	angle = _angle
	angular_velocity = _velocity
	
	apply_base()
	
func apply_base():
	
	radius = base_radius
	height = base_height
	color = base_color
	
func create_segments():
	#Start making segments till we run out of space
	var current_angle = -PI
	while current_angle <= PI:
		
		#Pick a random size for this segment
		var segment_width = rand_range(segment_widths.x, segment_widths.y)
		var space_width = rand_range(segment_spacing.x, segment_spacing.y)
		
		#Will this not leave enough room?
		var remaining_angle = PI - current_angle + (segment_width + space_width)
		if remaining_angle < (segment_widths.x + segment_spacing.x):
			#We don't have enough space for the smalles one, Grow until we fit
			segment_width += remaining_angle
		
		#Move to the new spot
		current_angle += segment_width
		
		#Get the new center
		var segment_angle = current_angle - segment_width/2
		var new_segment = Segment.new(segment_angle, segment_width, height, color)
		segments.append(new_segment)
		
		if _debug and segments.size() == 1:
			new_segment._debug = true
		
		#Add the spacing
		current_angle += space_width

func update(delta):
	update_angle(delta)
	
	#Update all segments
	update_segments(delta)

func update_angle(delta):
	angle += angular_velocity * delta
	if _debug:
		print("New ring angle ", angle)

func update_segments(delta):
	for segment in segments:
		segment.update(delta)

func get_polygons():
	
	if _debug:
		print("Getting polygons")
	
	#For each segment
	var polygons = []
	for segment in segments:
		#Get it's polygons
		var segment_polygon = segment.get_polygon(radius, angle)
		polygons.append(segment_polygon)
		
	#Return it
	return polygons