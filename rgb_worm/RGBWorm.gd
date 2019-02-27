
const ArrayHelper = preload("res://ArrayHelper.gd")
const Pixel = preload("res://Pixel.gd")

#This is a worm object
var target_sprite = null
var pixel = null

func _init(target, _pixel):
	#Store everything
	target_sprite = target
	pixel = _pixel
	
func step():
	
	#We want to create new worms for every possible spot
	
	#Get all colors and shuffle
	var possible_colors = target_sprite.get_adjacent_colors(pixel.r, pixel.g, pixel.b)
	possible_colors = ArrayHelper.shuffle(possible_colors)
	
	#Get all coordinates and shuffle
	var possible_coordinates = target_sprite.get_adjacent_coordinates(pixel.x, pixel.y)
	possible_coordinates = ArrayHelper.shuffle(possible_coordinates)
	
	#For each adjacent pixel
	var new_worms = []
	for possible_coordinate in possible_coordinates:
		
		#Are we out of colors?
		if possible_colors.size():
			
			#Pop off the color
			var color = possible_colors.pop_back()
			
			#Suggest a new worm
			var new_worm = Pixel.new(possible_coordinate[0], possible_coordinate[1], color[0], color[1], color[2])
			new_worms.append(new_worm)
	
	#Return all of the new worms
	return new_worms
