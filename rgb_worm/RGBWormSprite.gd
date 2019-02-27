extends Sprite

const Pixel = preload("res://Pixel.gd")
const RGBWorm = preload("res://RGBWorm.gd")
const WormOrderFunctions = preload("res://WormOrderFunctions.gd")

const used_colors = {} #3D dict, for R G and B
const used_coordinates = {} #2D dict, for X and Y
const worms = []

#The sprite image
var image = null
var image_texture = null

onready var worm_orderings = {
	"test_1": funcref(WormOrderFunctions, "test_1")
}
var active_worm_ordering = "test_1"

#Saving
onready var file_name = str(OS.get_unix_time())

#Seeding
export var _seed = 0

#How many at once
export(int, 1, 3) var max_active_worms = 1

#How big to use
export(int, 0, 4096) var image_width = 1920
export(int, 0, 2160) var image_height = 1080

#Color limits
export(int, 0, 255) var max_red = 255
export(int, 0, 255) var min_red = 0
export(int, 1, 10) var step_red = 5

export(int, 0, 255) var max_green = 255
export(int, 0, 255) var min_green = 0
export(int, 1, 10) var step_green = 5

export(int, 0, 255) var max_blue = 255
export(int, 0, 255) var min_blue = 0
export(int, 1, 10) var step_blue = 5

var step = 0


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	SeededRandomSingleton.sequence.reset(_seed)
	_reset_image()
	
	#Start a worm
	_reset_worms()
	
	#Process
	set_process(true)
	
	#Save the setup
	save_setup_json()
	
func _reset_image():
	#Initialize the image
	image = Image.new()
	image.create(image_width, image_height, false, Image.FORMAT_RGBA8)
	
	#Create the texture to use this image
	image_texture = ImageTexture.new()
	image_texture.flags = 0
	image_texture.create_from_image(image)
	texture = image_texture

func _reset_worms():
	
	#Just make a dummy worm that starts in the middle
	var pixel = Pixel.new(int(image_width/2), int(image_height/2), 255, 255, 255)
	mark_pixel_used(pixel)
	
	var worm = RGBWorm.new(self, pixel)
	worms.append(worm)

func save_setup_json():
	
	#Save the setup used to start the worm
	var data = {
		"seed": _seed,
		"size": [image_width, image_height],
		"max_worms": max_active_worms,
		"ordering": active_worm_ordering,
		"colors": {
			"red": {
				"min": min_red,
				"max": max_red,
				"step": step_red
			},
			"green": {
				"min": min_green,
				"max": max_green,
				"step": step_green
			},
			"blue": {
				"min": min_blue,
				"max": max_blue,
				"step": step_blue
			}
		}
	}
	var json_string = JSON.print(data, ' ')
	
	#Make the file path
	var dir = OS.get_user_data_dir()
	var file_path = dir + "/" + file_name + '.json'
	
	#Open and write the file
	var file = File.new()
	file.open(file_path, File.WRITE)
	file.store_string(json_string)
	file.close()

func _write_image_to_png():
	
	#Make the file path
	var dir = OS.get_user_data_dir()
	var file_path = dir + "/" + file_name + '.png'
	
	#Open and write the file
	image.save_png(file_path)
	print("PNG saved to: ", file_path)

func _process(delta):
	step += 1
	print("STEP ", step)
	
	#Step each worm
	var all_pixels = []
	var new_worms = []
	
	#How many worms to do at once?
	if not worms:
		print("Out of worms! All Done!")
		set_process(false)
		_write_image_to_png()
		return
	
	for count in range(max_active_worms):
		var worm = worms.pop_front()
		if not worm:
			#We're fresh out I guess
			print("Out of worms...")
			break
		
		#See if we should add new worms
		var suggested_worms = worm.step()
		new_worms.append([worm, suggested_worms])
		
		#Draw this worm
		all_pixels.append(worm.pixel)
	
	#Draw them all
	draw_pixels(all_pixels)
	
	#Add the new worms to the party
	var worm_sequence = determine_worm_sequence(new_worms)
	for worm in worm_sequence:
		mark_pixel_used(worm)
		var new_worm = RGBWorm.new(self, worm)
		worms.append(new_worm)

func determine_worm_sequence(worm_results):
	#Get the active sequence
	var active_handler = worm_orderings[active_worm_ordering]
	return active_handler.call_func(worm_results)

func draw_pixels(pixels):
	
	#Lock the image
	image.lock()
	for pixel in pixels:
		draw_pixel(pixel)
	
	#Unlock after altering
	image.unlock()
	
	#Redraw the sprite
	image_texture.set_data(image)
	

func draw_pixel(pixel):
	#We assume the image is locked and ready
	
	#Mark this pixel just in case
	mark_pixel_used(pixel)
	
	#Set the pixel in the image 
	var color = pixel.to_color()
	image.set_pixel(pixel.x, pixel.y, color)

func mark_pixel_used(pixel):
	#Get the coordinate and color marked
	mark_color_used(pixel.r, pixel.g, pixel.b)
	mark_coordinate_used(pixel.x, pixel.y)

func mark_color_used(r, g, b):
	
	#Mark it as used
	
	#Check R
	if not used_colors.has(r):
		used_colors[r] = {}
	var greens = used_colors[r]
	
	#Check G
	if not greens.has(g):
		greens[g] = {}
	var blues = greens[g]
	
	#Add B
	blues[b] = true

func check_color_used(r, g, b):
	#If we have it, return the status (usually true)
	if used_colors.has(r):
		if used_colors[r].has(g):
			if used_colors[r][g].has(b):
				return used_colors[r][g][b]
	return false

func get_adjacent_colors(r, g, b):
	
	#Attempt to find valid 'adjacent' colors
	
	#Just seek +- in the range, don't go beyond valid colors
	var colors = []
	for red in [max(r-step_red, min_red), min(r+step_red, max_red)]:
		for green in [max(g-step_green, min_green), min(g+step_green, max_green)]:
			for blue in [max(b-step_blue, min_blue), min(b+step_blue, max_blue)]:
				
				#Is it the given color?
				if r == red and g == green and b == blue:
					continue
				
				#Is it used already?
				var rgb = [red, green, blue]
				if check_color_used(red, green, blue):
					continue
				
				#This is a real, new color that hasn't been used yet.
				colors.append(rgb)
	
	#Return all the colors we found
	return colors
	
func mark_coordinate_used(x, y):

	#Mark it as used
	
	#Check X
	if not used_coordinates.has(x):
		used_coordinates[x] = {}
	
	#Add Y
	used_coordinates[x][y] = true

func check_coordinate_used(x, y):
	
	#If we have it, return the status (usually true)
	if used_coordinates.has(x):
		if used_coordinates[x].has(y):
			return used_coordinates[x][y]
	return false

func get_adjacent_coordinates(x, y):
	
	#Attempt to find valid 'adjacent' pixels
	
	#Just seek +- in the range, don't go beyond valid pixels
	var step = 1
	var pixels = []
	for _x in range(max(x-step, 0), min(x+step, image_width)+1):
		for _y in range(max(y-step, 0), min(y+step, image_height)+1):
				
			
			#Is it the given pixel?
			if x == _x and y == _y:
				continue
				
			#Is it used already?
			if check_coordinate_used(_x, _y):
				continue
				
			#This is a real, new pixel that hasn't been used yet.
			pixels.append([_x, _y])
	
	#Return all the pixels we found
	return pixels
