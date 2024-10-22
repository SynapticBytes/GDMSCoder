extends RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	add_text("Ready\n")


func _on_Reset_pressed():
	clear()


func _on_ms_controller_gdms_print(print_string, delimiter):
	append_text(print_string)
	append_text(delimiter)
	scroll_to_line(get_line_count() - 1)


func _on_run_button_pressed():
	clear()
