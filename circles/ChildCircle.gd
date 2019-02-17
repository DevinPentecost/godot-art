extends "res://Circle.gd"

#Takes two 'parent' circles
export(NodePath) var x_parent_circle = null
export(NodePath) var y_parent_circle = null

func _ready():
	
	#Get the node paths
	if typeof(x_parent_circle) == TYPE_NODE_PATH:
		x_parent_circle = get_node(x_parent_circle)
		y_parent_circle = get_node(y_parent_circle)
	
	#Assign position based on the parents
	position.x = x_parent_circle.position.x
	position.y = y_parent_circle.position.y
	
	#Assign the color
	color = x_parent_circle.color.linear_interpolate(y_parent_circle.color, 0.5)
	
	#Process
	set_process(true)

func _process(delta):
	#Simply draw the next pixel
	draw_pixel()
	

func _get_coordinates():
	
	#Grab position from the parents
	var x_pos = x_parent_circle._get_coordinates().x
	var y_pos = y_parent_circle._get_coordinates().y
	
	#Return them as a tuple
	return Vector2(x_pos, y_pos)
