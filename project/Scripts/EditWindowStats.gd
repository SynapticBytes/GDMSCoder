extends Label

var row
var column
	
func _on_mini_script_code_caret_activated(caret_row, caret_column):
	text = ""
	if Auto.script_modified:
			text = "*"
	text = text + "Line: " + str(caret_row + 1) +  " | Pos: " + str(caret_column)
	
