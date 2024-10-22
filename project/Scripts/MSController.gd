extends GDMiniScript

## Called when the node enters the scene tree for the first time.
func _ready():
	##Next line is a test line only
	#var call_aliases = 'pop = function(message, duration = 0)\n' \
	#+ '	return gdms.call("my_popup",{"msg":message, "wait_time":duration},0)\n' \
	#+ 'end function\n'
	#Actual aliass load
	print ("Loading Aliases")
	var aliases : UserScript
	var call_aliases : String
	aliases = ResourceLoader.load("res://Resources/aliases.tres", "UserScript", ResourceLoader.CACHE_MODE_REPLACE)
	if aliases == null:
		call_aliases = ""
		print("Warning: No aliases exist.")
	else:
		call_aliases = aliases.user_script
		print ("Loaded: ", call_aliases)

	%MSController.load_aliases(call_aliases)


### NOTE: This _process() must must remain here to allow the _notification() event
### to trigger in the gdextension library, as of Godot 4.2 beta anyway.
func _process(_delta)->void:
	pass


##Test Code
#func my_popup(parameters: Variant, return_variable: Variant):
func my_popup(call_id, parameters: Variant):
	print ("Popup: ", call_id, " ", parameters)
	if not typeof(parameters) == TYPE_DICTIONARY:
		print ("my_popup: parameters must be a dictionary")
		%MSController.return_result(call_id, "my_popup: parameters must be a dictionary",2) # 2 - completed but with issues
		return false
	#if not typeof(return_variable) == TYPE_STRING:
		#print ("my_popup: return_variable must be a string")
		#%MSController.set_var(return_variable, "my_popup: return_variable must be a string")
		#return false
		
	var popup_value: String
	var duration: float
	if parameters.has("message"):
		popup_value = parameters["message"]
	else:
		popup_value = "NO MESSAGE"
		
	if parameters.has("display_time"):
		duration = parameters["display_time"]
	else: 
		duration = 1
		
	#print("Popup Value: ", popup_value)
	#print("Duration: ", duration)
	%Popup.text = "[center]" + str(popup_value) + "[/center]"
	displayFor(call_id,duration) #Async call, code here continues immediately so return value below is passed back
	#await displayFor(call_id,duration) #Non-async, blocks here until displayFor finishes.
	#%MSController.return_result(call_id,"popup awaited return")
	# Note call value is returned immediately however, so return value below is not processed before call return
	return "Immediate result returned"

#func displayFor(seconds: float, return_variable):
func displayFor(call_id,seconds: float):
	%Popup.visible = true
	await get_tree().create_timer(seconds).timeout
	%Popup.visible = false
	%MSController.return_result(call_id,"popup immediately returned without waiting") # 1 is a status valeu to indicate normal return
	#%MSController.set_var(return_variable, "popup returned")
	#%MSController.return_result("popup returned")
