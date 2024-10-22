extends Resource
class_name QuickScripts

#func _ready()->void:
	#pass
	#
#func _process(_delta)->void:
	#pass
	
## Save path
const QUICKSCRIPT_PATH := "user://save/quick_script_" # id will be added on when saved, i.e /save_1.tres

## Things to save
@export var quick_script  : String
@export var this_save_date: String

## Script file management functions
func save_quick_script(id: String) -> void:
	var script_path = str(QUICKSCRIPT_PATH + id + '.tres')
	ResourceSaver.save(self, script_path)


static func save_exists(id: String) -> bool:
	var script_path = str(QUICKSCRIPT_PATH + id + '.tres')
	return ResourceLoader.exists(script_path)

static func load_quick_script(id: String) -> Resource:
	var script_path = str(QUICKSCRIPT_PATH + id + '.tres')
	return ResourceLoader.load(script_path, "",ResourceLoader.CACHE_MODE_REPLACE)
