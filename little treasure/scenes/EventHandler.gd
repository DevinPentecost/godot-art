extends Node

class EVENTS:
	const TIME = "time"
	const ANIMATION = "animation"
	
#How long we've been processing this set of events
var _events_duration
var _active_events

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func prepare_events(events_json_path):
	
	#Set the time
	_events_duration = 0
	
	#Read in the JSON
	var json_file = File.new()
	json_file.open(events_json_path, File.READ)
	var json = json_file.get_as_text()
	_active_events = JSON.parse(json).result

func handle_event(event):
	#What does this event want to do?
	if event.has(EVENTS.ANIMATION):
		handle_animation(event[EVENTS.ANIMATION])

func handle_animation(animation_name):
	#Play the animation
	var animation_player = get_node("../AnimationPlayer")
	animation_player.play(animation_name)

func _process(delta):
	
	#Do we have some active events?
	if not _active_events:
		return
	
	#Increment the time
	_events_duration += delta
	
	#Did we trigger the next event?
	if _active_events.front()[EVENTS.TIME] < _events_duration:
		#We can consume this event
		var event = _active_events.pop_front()
		handle_event(event)
