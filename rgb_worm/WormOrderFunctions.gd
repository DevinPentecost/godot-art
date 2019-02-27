

static func test_1(worm_results):
	
	#For each worm...
	#The new order of worms to use
	var final_results = []
	for worm_result in worm_results:
		#It had a suggested order of new worms
		var worm = worm_result[0]
		var new_worms = worm_result[1]
		
		#We need to assign them to the results
		for new_worm in new_worms:
			final_results.push_front(new_worm)
	
	#Return it
	return final_results