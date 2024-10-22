extends Node

## REVIEW: May be more efficient way to process this code. 

# save buttons
var quick_save_1
var quick_save_2
var quick_save_3
#load buttons
var quick_load_1
var quick_load_2
var quick_load_3
# Label that tells player if saving or loading
var load_save_label 

## Button pressed functions ##
# All save buttons emit a Global Signal of what to do
	
func _on_quick_save_1_pressed():
	Auto.emit_signal('save_quick_script', '1')

func _on_quick_save_2_pressed():
	Auto.emit_signal('save_quick_script', '2')

func _on_quick_save_3_pressed():
	Auto.emit_signal('save_quick_script', '3')

func _on_quick_load_1_pressed():
	Auto.emit_signal('load_quick_script', '1')

func _on_quick_load_2_pressed():
	Auto.emit_signal('load_quick_script', '2')

func _on_quick_load_3_pressed():
	Auto.emit_signal('load_quick_script', '3')
