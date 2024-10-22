extends Node

## This needs to be in a globals file (any auto-load file will do)
# Global signals + a function that get's all save_dates from each save on disc

## Saves & Loads signals, goes to main
signal load_quick_script
signal save_quick_script
signal updated_quick_save(operation: String, save_id: String)
signal auto_script_timer_timeout
signal change_script_theme(script_theme: Dictionary)
signal log_request

enum log_level {INFO, WARNING, ERROR}

@export var script_modified: bool

#func _ready()->void:
	#pass
		

## Holds a dictionary of the save_id with save_date
## access with save_dates[id]
## you don't need this, but can be useful to have all saves dates in the current save
@onready var save_dates: Dictionary
func update_save_dates():
	var save: QuickScripts
	if QuickScripts.save_exists('1'):
		save = QuickScripts.load_quick_script('1') as QuickScripts
		save_dates['1'] = save.this_save_date
	if QuickScripts.save_exists('2'):
		save = QuickScripts.load_quick_script('2') as QuickScripts
		save_dates['2'] = save.this_save_date
	if QuickScripts.save_exists('3'):
		save = QuickScripts.load_quick_script('3') as QuickScripts
		save_dates['3'] = save.this_save_date

func slog(log_string: String, status_level = 0):
	match status_level:
		log_level.INFO:
			emit_signal("log_request", "[color=turquoise]" + log_string + "[/color]\n")
			#%LogView.append_text("[color=turquoise]" + log_string + "[/color]")
		log_level.WARNING:
			emit_signal("log_request", "[color=yellow]" + log_string + "[/color]\n")
			#%LogView.append_text("[color=yellow]" + log_string + "[/color]")
		log_level.ERROR:
			emit_signal("log_request", "[color=red]" + log_string + "[/color]\n")
			#%LogView.append_text("[color=red]" + log_string + "[/color]")
	
