extends Sprite

#Some properties
var target_material = preload("res://dust/blurry_material.tres")
var velocity = -40
var lifetime = 0
var max_lifetime = 60

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	material = target_material
	set_process(true)
	

func _process(delta):
	#Update position
	position.x += velocity * delta
	
	#Should this die?
	lifetime += delta
	if lifetime > max_lifetime:
		queue_free()