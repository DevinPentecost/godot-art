extends Node


#The songs to play
export(AudioStream) var song_1
export(AudioStream) var song_2
export(AudioStream) var song_3
onready var songs = [song_1, song_2, song_3]
var _current_song_index = -1

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
	
	#We're all set
	return true

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


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
