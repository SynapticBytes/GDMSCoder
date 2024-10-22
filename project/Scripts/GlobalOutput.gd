extends Label

##This is a test node & script only	
func _on_ms_controller_gdms_global_received(global_variable: String, value: Variant):
	if (value == null):
		text = "NULL RETURNED" #something went wrong
		return
		
	if (global_variable == "test_var"):
		text = var_to_str(value)
	else:
		text = "WRONG VAR:" + global_variable		
