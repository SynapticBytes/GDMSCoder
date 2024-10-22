extends RichTextLabel

#@onready var ms = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_text("System Initialised\n")
	Auto.log_request.connect(_on_log_request)

func _on_log_request(log_message: String):
	append_text(log_message)
	scroll_to_line(get_line_count() - 1)
	
func _on_Reset_pressed():
	clear()


func _on_clear_log_pressed():
	clear()


func _on_ms_controller_gdms_print(print_string, delimiter):
	#emit_signal("log_request", print_string + delimiter)
	append_text(print_string + delimiter)
	scroll_to_line(get_line_count() - 1)


func _on_run_button_pressed():
	set_text("")


func _on_ms_controller_gdms_log(log_string, delimiter):
	Auto.emit_signal("log_request", log_string + delimiter)
	#append_text(log_string)
	#append_text(delimiter)
		
	#scroll_to_line(get_line_count() - 1)
