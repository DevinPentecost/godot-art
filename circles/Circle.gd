extends Node2D

const Pixel = preload("res://Pixel.tscn")
const Pointer = preload("res://Pointer.tscn")

var rotation_speed = 0.5 #Rotations per second
onready var radians_per_second = rotation_speed * 2 * PI

export(float) var current_angle = 0

var radius = 25 #Pixels across

export(Color) var color = ColorN("Blue")

#Draw a pointer?
var pointer = null

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	#Set the area up
	$MouseArea/Shape.shape.extents = Vector2(radius, radius)
	
	set_process(true)
	
func _process(delta):
	
	#Depeding on the delta, rotate some amount
	var angle_change = delta * radians_per_second
	current_angle += angle_change
	
	#Draw a new spot on the circle
	draw_pixel()

func draw_pixel():
	
	#Make a new pixel object
	var new_pixel = Pixel.instance()
	
	#Position it
	var coordinates = _get_coordinates()
	new_pixel.position = coordinates
	
	#Set it's color
	new_pixel.color = color
	
	#Add to the scene
	add_child(new_pixel)
	
	#Update pointer position
	if pointer:
		pointer.position = coordinates
	
func _get_coordinates():
	
	#Compute the position
	var x_pos = sin(current_angle) * radius
	var y_pos = cos(current_angle) * radius
	
	#Return them as a tuple
	return Vector2(x_pos, y_pos)


func _on_MouseArea_mouse_entered():
	#Make a pointer
	pointer = Pointer.instance()
	var pointer_color = Color(color.to_html())
	pointer_color.a = 0.5
	pointer.color = pointer_color
	add_child(pointer)


func _on_MouseArea_mouse_exited():
	#Kill the pointer
	if pointer:
		pointer.queue_free()
		pointer = null
