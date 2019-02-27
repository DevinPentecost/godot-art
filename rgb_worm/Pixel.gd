
var x = 0
var y = 0
var r = 255
var g = 255
var b = 255

#Simple Data class for a pixel
func _init(_x, _y, _r, _g, _b):
	x = _x
	y = _y
	r = _r
	g = _g
	b = _b

func to_color():
	
	#Create the new color
	var color = Color(r/255.0, g/255.0, b/255.0)
	return color