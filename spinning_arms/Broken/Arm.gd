extends Node2D

const TrailSegment = preload("res://Broken/TrailSegment.tscn")

#This arm's stuff
export(float) var angle = 0
export(Color) var color = Color(1, 1, 1)
export(float, 0, 6) var speed = 0.5 #Radians per second
export(float, 0, 1000) var size = 100
export(int, 0, 10) var arm_thickness = 5

#Variables for how it's drawn
var parent_arm = null
var arm_color = null

#Line segments for the trail
var previous_trail_segment = null

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	#Do we track a parent?
	var parent = get_parent()
	var parent_class = parent.get_class()
	if parent_class == "Node2D":
		parent_arm = parent
		
	#Generate colors
	arm_color = Color(color.to_rgba32())
	arm_color.a /= 8
	
	set_process(true)

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	
	
	#Set the origin to match the parent's
	if parent_arm:
		position = parent_arm.get_arm_end_point()
	
	#Rotate the arm
	angle = (angle + delta*speed)
	if angle > 2*PI:
		angle = 0
	
	update()

func get_arm_end_point():
	
	#Return a vector with the points
	var point = Vector2(0, 0)
	
	#Extend out by the rotation
	point.x += cos(angle)*size
	point.y += sin(angle)*size
	
	return point

func _draw():
	
	#Draw a line
	var end_point = get_arm_end_point()
	if not arm_color:
		print("HERE")
		arm_color = Color(color.to_rgba32())
		arm_color.a /= 8
		print(arm_color)
	draw_line(Vector2(0, 0), end_point, arm_color, arm_thickness, true)
	
	#Do we have a previous segment to draw from?
	var start_point = global_position + end_point
	if previous_trail_segment:
		#Use the previous segment's position
		start_point = previous_trail_segment.end_point
	
	#Make a new segment
	var global_start = start_point
	var global_end = global_position + end_point
	
	var new_trail_segment = TrailSegment.instance()
	new_trail_segment.start_point = global_start
	new_trail_segment.end_point = global_end
	new_trail_segment.color = color
	new_trail_segment.line_thickness = arm_thickness
	get_viewport().add_child(new_trail_segment)
	previous_trail_segment = new_trail_segment
	
