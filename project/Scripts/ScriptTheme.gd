extends Resource
class_name Script_theme

## Configuration values
### Miniscript Syntax Hightlighting Theme colours
@export var values: Dictionary = {
	"NAME": "default",
	"FONT": 0xC6AEC7FF, #Wisteria Purple
	"NUMBER": 0xFFE87CFF, #Sun Yellow
	"FUNCTION": 0x5865F2FF, #Blurple
	"SYMBOL": 0x5865F2FF, #Blurple
	"COMMENT": 0x778899FF, #Light_Slate_Grey
	"STRING": 0xD2691EFF, #Chocolate
	"CONTROL": 0xB3446CFF, #Respberry Purple
	"MEMBER_VARIABLE": 0x5865F2FF, #Blurple
	"KEYWORD_NUMERIC": 0x5865F2FF, #Blurple
	"KEYWORD_STRING": 0x5865F2FF, #Blurple
	"KEYWORD_LISTMAP": 0x5865F2FF, #Blurple
	"KEYWORD_OTHER": 0x3EB489FF, #Mint
	"KEYWORD_SPECIAL": 0x3EB489FF #Mint
}

const THEME_PATH := "res://Script_Themes/"

#func _init(p_values = {"NAME": "default","FONT": 0xFFFFFFFF}):
	#values = p_values

## Functions to writing to & load from file
func save_script_theme(script_theme_name) -> void:
	ResourceSaver.save(self, THEME_PATH + script_theme_name + ".tres")


static func script_theme_exists(script_theme_name) -> bool:
	return ResourceLoader.exists(THEME_PATH + script_theme_name + ".tres")


static func load_script_theme(script_theme_name) -> Resource:
	return ResourceLoader.load(THEME_PATH + script_theme_name + ".tres", "",ResourceLoader.CACHE_MODE_REPLACE)
