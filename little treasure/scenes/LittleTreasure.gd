extends Node


#The songs to play
export(AudioStream) var song_1
export(AudioStream) var song_2
export(AudioStream) var song_3
onready var songs = [song_1, song_2, song_3]
var _current_song_index = -1

#The events to handle
export(String, FILE) var events_1
export(String, FILE) var events_2
export(String, FILE) var events_3
onready var events = [events_1, events_2, events_3]

onready var _music_node = $Music

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	#TODO: Have the full into and everything figured out?
	#Play the first song
	_play_next_song()
	
	#For debug
	set_process_unhandled_key_input(true)
	
	pass

func _play_next_song():
	#Increase the index
	_current_song_index += 1
	
	#Make sure we can get the song
	if _current_song_index >= songs.size():
		#We can't play any more songs
		return false
	
	#We can play it
	var next_song = songs[_current_song_index]
	
	#Setup the node
	_music_node.stream = next_song
	_music_node.playing = true
	
	#Also get the json events
	var events_json_path = events[_current_song_index]
	$EventHandler.prepare_events(events_json_path)
	
	#We're all set
	return true


func _on_Music_finished():
	
	#Set up the next set of events
	
	#Also play the next song
	var has_song = _play_next_song()
	
	#Are we out of songs?
	if not has_song:
		#Do we even care? The events should have led us to the end... maybe we just quit?
		get_tree().quit()
		
func _unhandled_key_input(event):
	
	#Was this a skip
	if event.is_action_pressed('skip'):
		_play_next_song()


func _on_Album_pressed():
	#Open it up
	OS.shell_open("https://soundcloud.com/casilofi")

func _on_DannyTaylor_pressed():
	OS.shell_open("http://chilidog.faith")

func _on_DevinPentecost_pressed():
	OS.shell_open("https://devinpentecost.info/")
