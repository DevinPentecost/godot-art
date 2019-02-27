
static func shuffle(array):
	
	#We will shuffle this array
	var shuffled = []
	var indices = range(array.size())
	for index in range(array.size()):
		
		#Get a new element
		var random_index = abs(SeededRandomSingleton.sequence.next())%indices.size()
		shuffled.append(array[random_index])
		indices.remove(random_index)
		
	return shuffled
