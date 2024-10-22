extends Node2D

## resource class instances
var save: QuickScripts 
var config: Config
var script_theme: Script_theme

## Configuration settings
var auto_reload_save: bool
var auto_save_interval: int
var autosave_on_exit: bool
var enable_dev_tools: bool
var auto_script_timer: Timer
var script_theme_name: String

## semaphore to indicate pre-quit actions completed
var quit_requested: bool

func _ready() -> void:
	quit_requested = false
	get_tree().set_auto_accept_quit(false)
	Auto.load_quick_script.connect(load_quick_script)
	Auto.save_quick_script.connect(save_quick_script)
	Auto.updated_quick_save.connect(updated_quick_save)
	
	##Load/Set configuration values
	if Config.config_exists():
		config = Config.load_config()
		%PreserveGlobals.set_pressed_no_signal(config.preserve_globals)
		%MSController.preserve_globals(config.preserve_globals)
		auto_reload_save = config.auto_reload_save
		auto_save_interval = config.auto_save_interval
		autosave_on_exit = config.autosave_on_exit
		enable_dev_tools = config.enable_dev_tools
		script_theme_name = config.script_theme_name
	else:
		%PreserveGlobals.set_pressed_no_signal(false)
		%MSController.preserve_globals(false)
		auto_reload_save = false
		auto_save_interval = 0
		autosave_on_exit = false
		enable_dev_tools = false
		script_theme_name = "default"


## Load default script theme
	if Script_theme.script_theme_exists(script_theme_name):
		script_theme = Script_theme.load_script_theme(script_theme_name)
	else:
		script_theme = Script_theme.new()
		script_theme.save_script_theme(script_theme_name)
		
	Auto.emit_signal("change_script_theme", script_theme.values)

	if auto_reload_save:
		create_or_load_save()
		
	if auto_save_interval > 0:
		auto_script_timer = Timer.new()
		add_child(auto_script_timer)
		auto_script_timer.wait_time = auto_save_interval * 60
		auto_script_timer.start()
		auto_script_timer.timeout.connect(auto_script_timer_timeout)
	# TODO: Process config params if not already processed


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST: ## Trap application close so we can save script being edited
		quit_requested = true
		%MSController.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)


## Below is specific to just auto saving script on exit. A more generic close handler may be required
func updated_quick_save(operation: String, save_id: String): #quicksave operation complete
	if quit_requested and operation == "save" and save_id == "auto":
		get_tree().quit()


func auto_script_timer_timeout()->void:
	save_quick_script("auto")
	Auto.slog("autosave complete",Auto.log_level.INFO)
	print("autosave complete")


## Handle loading/save of auto script and quick scripts
func create_or_load_save():
	if QuickScripts.save_exists('auto'):
		load_quick_script('auto')
	else:
		save_quick_script('auto')


func save_quick_script(id: String):
	# new SaveGame resource
	save = QuickScripts.new()
	
	## Save Script
	save.quick_script = %MiniScriptCode.text;
	save.this_save_date = Time.get_datetime_string_from_system()
	save.save_quick_script(id)
	
	# Game updates after save done
	Auto.update_save_dates()
	Auto.emit_signal('updated_quick_save',"save",id)


func load_quick_script(id: String):
	# Checks if save doesn't exist, 
	if QuickScripts.save_exists(id) == false: return
	
	#Check if current script is modified before loading
	#If so, auto back it up
	if Auto.script_modified:
		print("backing up existing code before loading script")
		save_quick_script("auto")
		Auto.script_modified = false #Coupled code, should really be sending signal instead
		
	# loads save
	save = QuickScripts.load_quick_script(id) as QuickScripts
	%MiniScriptCode.text = save.quick_script
	
	# Game updates after load done
	Auto.update_save_dates()
	Auto.emit_signal('updated_quick_save',"load",id)
