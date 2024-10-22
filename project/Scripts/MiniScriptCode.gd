extends CodeEdit

signal caret_activated(caret_row, caret_column)

enum code_type {SCRIPT, ALIAS, EXPAND, CONFIG, THEME, AUTO}
var loaded_code_type: code_type
static var current_script_name: String
static var not_alphanumeric: RegEx


func _ready() -> void:
	Auto.change_script_theme.connect(change_script_theme)
	text_changed.connect(_on_code_changed)
	text_changed.connect(_on_text_changed) # Shortcut expansion
	not_alphanumeric = RegEx.new()
	not_alphanumeric.compile("\\W")  #Not alpha numeric regular expression check
	# Enable handling of unhandled input events.
	set_process_unhandled_input(true)
	grab_focus() # set active immediately. Change this for an active game development


func _on_code_changed():
	Auto.script_modified = true
	

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Auto-save if set
		var config: Config
		config = Config.load_config()
		if config.autosave_on_exit:
			Auto.emit_signal('save_quick_script', 'auto')


func _on_run_button_pressed():
	var run_script = true
	var _loaded : bool = %MSController.load_script(text, run_script)


func _on_compile_button_pressed():
	var run_script = false
	var _loaded : bool = %MSController.load_script(text, run_script)


func _on_Reset_pressed():
	%MSController.stop_script(true) #stop and reset environment
	set_text("")
	grab_focus()
	caret_activated.emit(get_caret_line(), get_caret_column())
	#print("caret line" + str(get_caret_line()))


func _on_stop_pressed():
	%MSController.stop_script(false) #just stop, don't reset


func _on_clear_code_pressed():
	set_text("")
	grab_focus()
	caret_activated.emit(get_caret_line(), get_caret_column())
	#print("caret line" + str(get_caret_line()))


func _on_focus_entered():
	caret_activated.emit(get_caret_line(), get_caret_column())
	#print("caret line" + str(get_caret_line()))


func _input(event):
	if event is InputEventKey:
		caret_activated.emit(get_caret_line(), get_caret_column())
		#print("caret line" + str(get_caret_line()))


func _on_test_globals_pressed():
	set_gdms_global("test_var", "Test Global Value")
	var global_value = get_gdms_global("test_var")
	#print ("Global value returned: ", global_value)
	##test passing other types
	#var test_array = ["one",2,"three",4]
	#print(test_array)
	#set_gdms_global("test_array",test_array)
	#var test_dict =  {"White": 50, "Yellow": 75.75, "Orange": 100, "test_array": test_array}
	#set_gdms_global("test_dict", test_dict)
	#var test_bool = false
	#set_gdms_global("test_bool", test_bool)
	%MSController.gdms_global_received.emit("test_var", global_value)


func get_gdms_global(gdms_global):
	return %MSController.get_global(gdms_global)


func set_gdms_global(gdms_global, value):
	return %MSController.set_global(gdms_global, value, true)


func _on_preserve_globals_toggled(button_pressed):
	print("Pressed value: ", button_pressed)
	%MSController.preserve_globals(button_pressed)

func change_script_theme(new_script_theme: Dictionary) -> void:
	%MiniScriptCode.set("theme_override_colors/font_color",new_script_theme.FONT)
	%MiniScriptCode.syntax_highlighter.number_color = new_script_theme.NUMBER
	%MiniScriptCode.syntax_highlighter.symbol_color = new_script_theme.SYMBOL
	%MiniScriptCode.syntax_highlighter.function_color = new_script_theme.FUNCTION
	#%MiniScriptCode.syntax_highlighter.member_keyword_colors = {}
	%MiniScriptCode.syntax_highlighter.member_variable_color = new_script_theme.MEMBER_VARIABLE
	
	%MiniScriptCode.syntax_highlighter.add_color_region("//","", new_script_theme.COMMENT, true) # Comment lines
	%MiniScriptCode.syntax_highlighter.add_color_region('"','"', new_script_theme.STRING, false) # Strings
		
		
	### NOTE: Any function that has parameters (i.e. has a ( after the function name)
	### is overridden by the Godot function syntax highlighting.
	### So below is in the hopes that this can be overridden somehow
	var control_keywords = ["end", "for", "while", "if", "then", "else", "in", "break", "continue", "not"]
	for keyword in control_keywords:
		%MiniScriptCode.syntax_highlighter.add_keyword_color(keyword, new_script_theme.CONTROL)
	
	var intrinsic_numeric_keywords = ["abs", "acos", "asin", "atan", "ceil", "char", "cos",\
	"floor", "log", "round", "rnd", "pi", "sign", "sin", "sqrt", "str", "tan"]
	for keyword in intrinsic_numeric_keywords:
		%MiniScriptCode.syntax_highlighter.add_keyword_color(keyword, new_script_theme.KEYWORD_NUMERIC)
		
	var intrinsic_string_keywords = [".indexOf", ".insert", ".len", ".val", ".code",\
	".remove", ".lower", ".upper", ".replace", ".split"]
	for keyword in intrinsic_string_keywords:
		%MiniScriptCode.syntax_highlighter.add_keyword_color(keyword, new_script_theme.KEYWORD_STRING)
			
	var intrinsic_list_map_keywords = [".hasIndex", ".insert", ".join", ".push", ".pop",\
	".pull", ".indexes", ".values", ".sum", ".sort", ".shuffle", ".remove","range"]
	for keyword in intrinsic_list_map_keywords:
		%MiniScriptCode.syntax_highlighter.add_keyword_color(keyword, new_script_theme.KEYWORD_LISTMAP)
			
	var other_keywords = ["print", "time", "wait", "locals", "outer", "globals", "yield"]
	for keyword in other_keywords:
		%MiniScriptCode.syntax_highlighter.add_keyword_color(keyword, new_script_theme.KEYWORD_OTHER)
	
	var special_keywords = ["function", "end function", "gdms"]
	for keyword in special_keywords:
		%MiniScriptCode.syntax_highlighter.add_keyword_color(keyword, new_script_theme.KEYWORD_SPECIAL)

##
## User script save/load dialog
##

const SCRIPT_PATH := "user://scripts/" #Base path for saving user scripts
const ALIAS_PATH := "res://resources/aliases.tres" #Base path for saving user scripts
enum menu {FILE, THEME, DEVTOOLS}
enum file_menu {LOAD, SAVE, SAVEAS, IMPORT, RELOAD_AUTO}
enum theme_menu {LOAD, SAVE, SAVEAS, EDIT}
enum dev_tools_menu {LOAD_CONFIG, OPEN_WATCH, LOAD_ALIAS, SAVE_ALIAS, LOAD_EXPANDERS}
var menu_dialog_mode: int
var menu_dialog : FileDialog
static var active_menu: menu
var user_script: UserScript


func _on_file_id_pressed(id: int) -> void:
	active_menu = menu.FILE
	menu_dialog_mode = id
	if (menu_dialog_mode == file_menu.LOAD) and Auto.script_modified:
		popup_dialog() # check if changes to existing script are to be discarded by loading
		return # pass off save until result from dialog question in know, in signal response
	
	if (menu_dialog_mode == file_menu.SAVE) and not Auto.script_modified: #no change, no need to save
		return
		
	setup_menu_dialog(active_menu) # only run if there is some saving or loading to do here


func _on_dev_tools_id_pressed(id: int) -> void:
	active_menu = menu.DEVTOOLS
	menu_dialog_mode = id
	if (menu_dialog_mode == dev_tools_menu.LOAD_ALIAS) and Auto.script_modified:
		popup_dialog() # check if changes to existing script are to be discarded by loading
		return # pass off save until result from dialog question in know, in signaal response
	
	if (menu_dialog_mode == dev_tools_menu.SAVE_ALIAS) and not Auto.script_modified: #no change, no need to save
		return
		
	setup_menu_dialog(active_menu) # only run if there is some saving or loading to do here

func setup_menu_dialog(selected_menu: menu) -> void:
	print ("setup_menu_dialog: ", selected_menu )
	if selected_menu == menu.FILE:
		# Initialize the FileDialog node
		menu_dialog = FileDialog.new()
		menu_dialog.min_size = Vector2i(400,400)
		# Add the FileDialog node to the current scene
		self.add_child(menu_dialog)
		# Connect the "file_selected" signal to the "_on_FileDialog_file_selected" method
		menu_dialog.file_selected.connect(_on_FileDialog_file_selected)
		
		#Setup dialogue theme
		#menu_dialog.set("theme_override_colors/background_color", Color.PALE_VIOLET_RED)
		menu_dialog.add_theme_color_override("background_colour", Color.PALE_VIOLET_RED)
		#setup dialog layout
		menu_dialog.access = FileDialog.ACCESS_USERDATA
		menu_dialog.root_subfolder = SCRIPT_PATH
		menu_dialog.current_dir = SCRIPT_PATH
		menu_dialog.add_filter("*.tres","Scripts")
		
		match menu_dialog_mode:
			# Set the FileDialog mode to open files
			file_menu.LOAD:
				menu_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
				menu_dialog.title = "Open Script"
			file_menu.SAVE:
				menu_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
				process_file(current_script_name)
				return
			file_menu.SAVEAS:
				menu_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
				menu_dialog.title = "Save Script As"
			file_menu.IMPORT:
				return
			file_menu.RELOAD_AUTO:
				Auto.emit_signal('load_quick_script', 'auto')
				return
		# Popup the FileDialog
		menu_dialog.popup_centered()

	if selected_menu == menu.DEVTOOLS:
		match menu_dialog_mode:
			# Set the FileDialog mode to open files
			dev_tools_menu.LOAD_ALIAS:
		# Load the selected resource file
				user_script = ResourceLoader.load(ALIAS_PATH, "UserScript", ResourceLoader.CACHE_MODE_REPLACE)
				if not user_script == null:
					set_text(user_script.user_script)
					emit_signal("caret_activated",0,0)
					current_script_name = user_script.user_script_path
					Auto.script_modified = false
					loaded_code_type = code_type.ALIAS
				else:
					print("Error: aliases not loaded successfully")
					
			dev_tools_menu.SAVE_ALIAS:
				var run_script = false
				var valid_script = %MSController.load_script_and_run(text, run_script)
				if valid_script:
					var aliases = UserScript.new()
					aliases.user_script = text
					aliases.this_save_date = Time.get_datetime_string_from_system()
					aliases.user_script_path = ALIAS_PATH
					ResourceSaver.save(aliases, ALIAS_PATH)
					current_script_name = ALIAS_PATH
					Auto.script_modified = false
					%MSController.load_aliases(text)
					%MSController.load_script("", false) #dummy run to reload updated aliases
					var saved:String = "[color=green]Aliases saved successfully[/color]"
					print (saved)
					%MSController.emit_signal("gdms_log", saved, "\n")
					%MSController.emit_signal("gdms_log", "colour test", "\n")
					
				else:
					var fail_message:String = "[color=red]Alias Script invalid, not saved[/color]"
					print (fail_message)
					%MSController.emit_signal("gdms_log", fail_message, "\n")


func file_menu_dialog() -> void:
	pass

func _on_FileDialog_file_selected(path: String):
	process_file(path)

func process_file(path: String):
	match menu_dialog_mode:
		# Set the FileDialog mode to open files
		file_menu.LOAD:
		# Load the selected resource file
			user_script = ResourceLoader.load(path, "UserScript", ResourceLoader.CACHE_MODE_REPLACE)
			if not user_script == null:
				set_text(user_script.user_script)
				emit_signal("caret_activated",0,0)
				current_script_name = user_script.user_script_path
				Auto.script_modified = false
				loaded_code_type = code_type.SCRIPT
			else:
				print("Error: script not loaded successfully")

		file_menu.SAVE, file_menu.SAVEAS :
			var save_script = UserScript.new()
			save_script.user_script = text
			save_script.this_save_date = Time.get_datetime_string_from_system()
			save_script.user_script_path = path
			ResourceSaver.save(save_script, path)
			current_script_name = path
			Auto.script_modified = false
			show_save_confirmation_popup()
			
	menu_dialog.queue_free()	

func show_save_confirmation_popup():

	var label = Label.new()
	var label_settings = LabelSettings.new()
	label.label_settings = label_settings
	#label.min_size = Vector2i(200,100)
	label.text = "File saved successfully!"
	
	label.label_settings.font_color = Color.YELLOW
	
	add_child(label)
	label.position = (get_viewport_rect().size - label.get_rect().size) / 2

	var m: Color = label.modulate
	m.a = 0  # Make it completely transparent
	get_tree().create_tween().tween_property(label, "modulate", m, 3)

func popup_dialog():
	var dialog = ConfirmationDialog.new() # Create a new ConfirmationDialog
	dialog.dialog_text = "Current script has been changed. Do you want to discard changes?" # Set the dialog text
	dialog.ok_button_text = "Yes, Discard Changes" # Change the OK button text to "Continue"
	dialog.cancel_button_text = "No, Cancel Load" # Change the Cancel button text to "Cancel"
	add_child(dialog) # Add the dialog to the current scene
	dialog.confirmed.connect(_on_ConfirmationDialog_confirmed)
	#dialog.confirmed.connect(_selected_menu)
	dialog.canceled.connect(_on_ConfirmationDialog_cancelled)
	dialog.popup_centered() # Show the dialog

# Connect the "confirmed" signal to a function to do something when "Continue" is pressed
func _on_ConfirmationDialog_confirmed():
	setup_menu_dialog(active_menu) # continuing with action after confirmation is received

# Connect the "cancelled" signal to a function to do something when "Cancel" is pressed
func _on_ConfirmationDialog_cancelled():
	pass # aborting previous action request

#### Shortcut text expansion

# Assuming your CodeEdit node is named 'code_editor'
#var code_editor : CodeEdit

# Dictionary to store your shortcut mappings
# TODO: Move into a resource file with user editing
var expander = "~"
var new_caret_marker = "~"
var shortcut_mappings = {
	"f": "for i in range(1,10)\n	~\nend for\n",
	"pg": "print globals",
	"fun": "= function(~)\n	\nend function\n",
	"i": "if ~ then\n	\nend if"
	# Add more shortcuts as needed
}

func _on_text_changed():
	# Get the current line and column of the cursor
	var line: int = get_caret_line()
	var column: int = get_caret_column()
	# Get the text from the beginning of the line up to the current cursor position
	var line_text: String = get_line(line)
	var current_word: String = ""
	
	#Check if the last character typed is the expansion indicator
	var last_char: String = line_text.substr(column - 1, 1)
	#print("last_char = " + last_char)
	if last_char != expander:
		return

	## Expansion possibly requested
	# Iterate from the cursor position to the left until a space or beginning of the line is found
	var match_start = column
	for i in range(column - 2, -1, -1):
		var search_char = line_text[i]

		#if search_char == " ": #CHECK: May also need to test for TAB character
		if not_alphanumeric.search(search_char):
			print("Non-alphanumeric found: " + search_char)
			break
		else:
			current_word = search_char + current_word
			match_start = i

# Check if the current word is a shortcut
	print ("Word: " + current_word)
	if shortcut_mappings.has(current_word):
		print ("Matched word: " + current_word)
		var expansion_string: String = shortcut_mappings[current_word]
		var final_caret_position: Vector2i = Vector2i(0,0) # fail over value

		if not expansion_string.contains(new_caret_marker):
			#Stuff in a fake positioner at end of expansion
			expansion_string = expansion_string + new_caret_marker
		
		# Replace the current word with the corresponding template
		line_text = line_text.substr(0, match_start) + expansion_string + line_text.substr(column)

		# Set the modified text back to the CodeEdit node
		set_line(line, line_text)
		
		# Move the caret to the expansion flag point if set
		# move to end of the substitution if no flag point set		
		final_caret_position = search_forward_from_caret(expansion_string.length(), new_caret_marker)
		print(final_caret_position)

		set_caret_line(final_caret_position.x)
		set_caret_column(final_caret_position.y)

func search_forward_from_caret(num_characters: int, character_to_search: String) -> Vector2i:
	var current_line: int = get_caret_line()
	var current_column: int = get_caret_column()
	var total_lines: int = get_line_count()
	var characters_checked: int = 0

	for i in range(current_line, total_lines):
		var line: String = get_line(i)
		var start_column: int = current_column if i == current_line else 0
		var end_column: int = min(start_column + num_characters - characters_checked, line.length())

		var substring: String = line.substr(start_column, end_column - start_column)
		var index: int = substring.find(character_to_search)
		if index != -1:
			set_caret_line(i)
			set_caret_column(start_column + index)
			var clean_line: String = get_line(get_caret_line()).erase(get_caret_column(), 1)
			set_line(i, clean_line)
			return Vector2i(get_caret_line(), get_caret_column())

		characters_checked += end_column - start_column
		print(characters_checked)
		print(num_characters)

# The following condition should never be true as long as 
# a caret marker string is being stuffed at the end of the expansion. Leave here for safety
		if characters_checked >= num_characters: 
			set_caret_line(i)
			set_caret_column(get_line(i).length())
			break
	return Vector2i(get_caret_line(), get_caret_column()) ## Safety, should not execute

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			#print(OS.get_keycode_string(event.get_keycode_with_modifiers()))
			match event.keycode:
				KEY_X:
					#if event.is_command_or_control_pressed() and event.alt_pressed:
					if event.alt_pressed: #ALT-X
					# Insert the expander text at the cursor position.
						insert_text_at_caret(expander)
