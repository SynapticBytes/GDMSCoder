extends Button

## Test Script and node only

#func _ready():
	#pass
	#
#func _process(_delta)->void:
	#pass
	
func _on_pressed():
	var global_value = %MSController.get_global("test_var")
	text = str(global_value)
	
	%MSController.set_global("godot_variant",global_value, true)
