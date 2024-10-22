extends Resource
class_name UserScript

## Save path
#const SCRIPT_PATH := "user://save/" #Base path for saving user scripts

## Things to save
@export var user_script  : String
@export var this_save_date: String
@export var user_script_path: String

## Script file management functions
#func save_user_script(script_name: String) -> void:
	#var script_path = str(SCRIPT_PATH + script_name + '.tres')
	#ResourceSaver.save(self, script_path)
#
#static func user_script_exists(script_name: String) -> bool:
	#var script_path = str(SCRIPT_PATH + script_name + '.tres')
	#return ResourceLoader.exists(script_path)
#
#static func load_user_script(script_name: String) -> Resource:
	#var script_path = str(SCRIPT_PATH + script_name + '.tres')
	#return ResourceLoader.load(script_path, "",ResourceLoader.CACHE_MODE_REPLACE)
