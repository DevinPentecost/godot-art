"""
Model Class for defining a segment of the circle
"""
var _debug = false

#Position and size
var base_offset #In radians, centered
var offset

var base_width #In radians, centered
var width

var base_height #In pixels, centered
var height

#The 'base' color of this
var base_color
var color

func _init(_offset, _width, _height, _color):
	#Set the model
	base_offset = _offset
	base_width = _width
	base_height = _height
	base_color = _color
	
	apply_base()
	
func apply_base():
	offset = base_offset
	width = base_width
	height = base_height
	color = base_color
	
func update(delta):
	pass
	
func get_polygon(radius, angle):
	
	if _debug:
		print("Get polygon ", angle)
	
	#The points of the polygon
	var points = PoolVector2Array()
	var colors = PoolColorArray([color])
	
	#Calculate the angle points
	var center_angle = angle + offset
	var left_angle = center_angle + width/2
	var right_angle = center_angle - width/2
	
	#Calculate radius
	var inner_radius = radius - height/2.0
	var outer_radius = radius + height/2.0
	
	#The center point
	var center_point = Vector2(cos(center_angle), sin(center_angle))
	
	#How high of a point count to use
	var point_count = 4 #TODO: Make this dynamic?
	var point_steps = range(point_count + 1)
	for point in point_steps:
		#How far along are we?
		var step_percentage = point / float(point_count)
		var point_angle = (left_angle + (step_percentage * width))
		
		#Create the point and extend for the outer radius
		var new_point = center_point + Vector2(cos(point_angle), sin(point_angle))
		new_point *= outer_radius
		points.push_back(new_point)
	
	#Now come backwards on those points
	point_steps.invert()
	for point in point_steps:
		#How far along are we?
		var step_percentage = (point) / float(point_count)
		var point_angle = (left_angle + (step_percentage * width))
		
		#Create the point and extend to the inner radius
		var new_point = center_point + Vector2(cos(point_angle), sin(point_angle))
		new_point *= inner_radius
		points.push_back(new_point)
	
	#Return all the points
	return [points, colors]
	