extends Node2D


#Which colors have already been used?
var current_image = Image.new()
var consumed_colors = {}
var consumed_pixels = {}
var active_worms = []

#Some setup variables

#Some math
const color_steps = 256 #256 color resolution
const aspect_ratio = 1.78 #Ratio of width to height

#How fast to go
export(float) var speed = .001 #How many s to wait
var timer = 0
export(int) var max_worms = 4 #How many worms alive at a time

#The starting color
export(Color) var starting_color = Color(1, 1, 1)
export(bool) var random_starting_color = true
export(Vector2) var starting_position = Vector2(-1, -1) #Negative 1 is center, Negative greater than 1 is random
export(Color) var background_color = Color(0, 0, 0, 0) #Hidden maybe?

#Color ranges, from 0 to 1 (i.e. 0 -> 255)
export(Vector2) var red_range = Vector2(0, 1)
var red_colors
export(Vector2) var green_range = Vector2(0, 1)
var green_colors
export(Vector2) var blue_range = Vector2(0, 1)
var blue_colors

#Canvas size
export(Vector2) var custom_size = Vector2(-1, -1) #Negative number means autosize!
var canvas_size

#How far to jump if needed (if no colors can be found and we are 'stuck')
#Negative number would be infinite I suppose
export(int) var max_color_jump_range = 3

class Worm:
	#Where is the worm
	var x
	var y
	
	#What color is the worm
	var r
	var g
	var b
	
	#How many jump attempts has the worm made
	var j = 0

func _setup_colors():
	#Figure out the actual color values (in steps) to use
	red_colors = [int(red_range.x * color_steps), int(red_range.y * color_steps)]
	green_colors = [int(green_range.x * color_steps), int(green_range.y * color_steps)]
	blue_colors = [int(blue_range.x * color_steps), int(blue_range.y * color_steps)]

func _setup_canvas():
	#Is the canvas size predefined?
	if custom_size.x < 0 or custom_size.y < 0:
		#We need to calculate the optimum size
		var total_red = red_colors[1] - red_colors[0]
		var total_green = green_colors[1] - green_colors[0]
		var total_blue = blue_colors[1] - blue_colors[0]
		var total_colors = total_red * total_green * total_blue
		
		#Now what's the resolution for this?
		var width = int(sqrt(aspect_ratio * total_colors))
		var height = int(width / aspect_ratio)
		
		#That's the canvas we're using
		canvas_size = [width, height]
	else:
		#We just use that
		canvas_size = [int(custom_size.x), int(custom_size.y)]
		
	#Now draw the empty pixels and set up the variables
	current_image.create(canvas_size[0], canvas_size[1], false, 5)
	current_image.fill(background_color)

func _setup_timer():
	#Dead simple
	timer = 0
	
func _setup_starting_position():
	#TODO: Handle starting with several at once?
	#Was the center picked?
	if starting_position.x == -1 or starting_position.y == -1:
		#Set it to the middle
		starting_position = [int(canvas_size[0] / 2), int(canvas_size[1] / 2)]
	elif starting_position.x < -1 or starting_position.y < -1:
		#Pick a random spot
		#TODO: Actually do this
		starting_position = [0, 0]
	else:
		#Just make sure the user input integers
		starting_position = [int(starting_position.x), int(starting_position.y)]
		
func _setup_starting_color():
	#Is it random?
	if random_starting_color:
		#TODO: Implement this
		pass
	
	#Convert the color to integer value
	starting_color = [int(starting_color.r * color_steps), int(starting_color.g * color_steps), int(starting_color.b * color_steps)]

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	#Set up a bunch of things in the correct order
	_setup_colors()
	_setup_canvas()
	_setup_timer()
	_setup_starting_position()
	_setup_starting_color()
	
	#Launch the first worm
	active_worms.append(_create_worm(starting_position[0], starting_position[1], starting_color[0], starting_color[1], starting_color[2]))
	
	#Process this node
	set_process(true)

func _consume(x, y, red, green, blue):
	#We want to consume this pixel
	var pixel_used = _consume_pixel(x, y)
	var color_used = _consume_color(red, green, blue)
	
	var color = Color(float(red)/color_steps, float(green)/color_steps, float(blue)/color_steps)
	
	#Update the image
	current_image.lock()
	current_image.set_pixel(x, y, color)
	current_image.unlock()
	
func _is_color_consumed(red, green, blue):
	#Do we have this red?
	if consumed_colors.has(red):
		#Do we have this green?
		if consumed_colors[red].has(green):
			#Do we have this blue?
			if blue in consumed_colors[red][green]:
				return true
	
	#We don't have it
	return false
	
func _consume_color(red, green, blue):
	#Consume a color, return if it was already used
	if not consumed_colors.has(red):
		consumed_colors[red] = {}
	if not consumed_colors[red].has(green):
		consumed_colors[red][green] = {}
	if not consumed_colors[red][green].has(blue):
		consumed_colors[red][green][blue] = true
		return true
	
	#The color was already there for some reason
	return false
	
func _is_pixel_consumed(x, y):
	#Check if this spot is available
	if consumed_pixels.has(x):
		if consumed_pixels[x].has(y):
			return true
	
	#Not there
	return false

func _consume_pixel(x, y):
	#Consume the pixel, return if it was already there
	if not consumed_pixels.has(x):
		consumed_pixels[x] = {}
	if not consumed_pixels[x].has(y):
		consumed_pixels[x][y] = true
		return true
	
	#It was already there!
	return false

func _process(delta):
	#Are we done?
	if len(active_worms) < 1:
		#We don't do anything
		return
	
	#Has it been enough time?
	timer += delta
	if timer < speed:
		#Do nothing
		return
	
	#Reset the timer
	timer = timer - speed
	
	#Update all the worms
	_process_worms()
	
	#Draw the image
	update()
	
func _get_next_pixel(worm):
	#Check each neighbor of this worm's position
	for position in [[-1, 0],[0, -1],[1, 0],[0, 1]]:
		
		#Is this spot available?
		var adjacent_pixel = [worm.x + position[0], worm.y + position[1]]
		
		#Is this off the canvas?
		if adjacent_pixel[0] < 0 or adjacent_pixel[1] < 0 or adjacent_pixel[0] > canvas_size[0] or adjacent_pixel[1] > canvas_size[1]:
			continue
		
		if not _is_pixel_consumed(adjacent_pixel[0], adjacent_pixel[1]):
			return adjacent_pixel
			
	#Couldn't find one
	return null

func _get_next_color(worm):
	#Check each possible color
	for adjacent_r in [-1, 0, 1]:
		for adjacent_g in [-1, 0, 1]:
			for adjacent_b in [-1, 0, 1]:
				
				#Are we checking ourself?
				if adjacent_r == 0 and adjacent_g == 0 and adjacent_b == 0:
					continue
				
				#Check that color (and add the jump if it's checked multiple times
				var adjacent_color = [worm.r + adjacent_r + worm.j, worm.g + adjacent_g + worm.j, worm.b + adjacent_b + worm.j]
				
				#Is this a valid color?
				if adjacent_color[0] < red_colors[0] or adjacent_color[0] > red_colors[1] or adjacent_color[1] < green_colors[0] or adjacent_color[1] > green_colors[1] or adjacent_color[2] < blue_colors[0] or adjacent_color[2] > blue_colors[1]:
					#Nope
					continue
				
				if not _is_color_consumed(adjacent_color[0], adjacent_color[1], adjacent_color[2]):
					#We can use this color
					return adjacent_color
	
	#Couldn't find one
	return null

func _create_worm(x, y, r, g, b):
	var new_worm = Worm.new()
	
	#Set it's position
	new_worm.x = x
	new_worm.y = y
	
	#Set it's color
	new_worm.r = r
	new_worm.g = g
	new_worm.b = b
	return new_worm

func _update_worm(worm):
	#Return either a new worm, or boolean if it survives another round
	#Do we have anywhere to go?
	var next_position = _get_next_pixel(worm)
	if next_position != null:
		#Are there any colors for us?
		var next_color = _get_next_color(worm)
		if next_color != null:
			#We have a position and a color!
			#We were successful
			worm.j = 0
			
			#Consume this color and pixel
			_consume(next_position[0], next_position[1], next_color[0], next_color[1], next_color[2])
			
			#We can use this color.
			#Should we make a new worm instead?
			if len(active_worms) < max_worms:
				#Sure let's make a new one
				var new_worm = _create_worm(next_position[0], next_position[1], next_color[0], next_color[1], next_color[2])
				return new_worm
				
			else:
				#We should move this one
				worm.x = next_position[0]
				worm.y = next_position[1]
				
				#We should update it's color
				worm.r = next_color[0]
				worm.g = next_color[1]
				worm.b = next_color[2]
	
	#We couldn't find a pixel and a color
	#We need to increase the jump
	worm.j += 1
	
func _process_worms():
	
	#Any updates to worms?
	var new_worms = []
	var dead_worms = []
	
	#Go through each worm
	for worm in active_worms:
		var new_worm = _update_worm(worm)
		if new_worm != null:
			#It must be a new worm
			new_worms.append(new_worm)
		
		#Should we kill it?
		if worm.j > max_color_jump_range:
			dead_worms.append(worm)
		
	#Cull and grow
	for dead_worm in dead_worms:
		active_worms.erase(dead_worm)
	for new_worm in new_worms:
		active_worms.append(new_worm)
		
	
func _draw():
	
	#The worms should have independantly updated themselves
	
	current_image.save_png("res://test.png")
	
	#Therefore we just draw the image
	var image_texture = ImageTexture.new()
	image_texture.create_from_image(current_image, 0)
	draw_texture(image_texture, Vector2())
	
	#All done I suppose