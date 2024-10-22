extends Resource
class_name Config

## Configuration values
@export var preserve_globals: bool
@export var auto_save_interval: int
@export var auto_reload_save: bool
@export var autosave_on_exit: bool
@export var enable_dev_tools: bool
@export var script_theme_name: String

const CONFIG_PATH := "res://custom/config.tres"

func _init(p_preserve_globals = true, p_auto_save_interval = 0,\
p_auto_reload_save = false, p_autosave_on_exit = false,\
p_enable_dev_tools = false, p_script_theme_name = "default"):
	preserve_globals = p_preserve_globals
	auto_save_interval = p_auto_save_interval
	auto_reload_save = p_auto_reload_save
	autosave_on_exit = p_autosave_on_exit
	enable_dev_tools = p_enable_dev_tools
	script_theme_name = p_script_theme_name


## Functions to writing to & load from file
func save_config() -> void:
	ResourceSaver.save(self, CONFIG_PATH)


static func config_exists() -> bool:
	return ResourceLoader.exists(CONFIG_PATH)


static func load_config() -> Resource:
	return ResourceLoader.load(CONFIG_PATH, "",ResourceLoader.CACHE_MODE_REPLACE)
