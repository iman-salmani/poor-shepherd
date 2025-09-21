class_name Menu
extends Control

const MODES: Dictionary = {
	"init": {
		"guide": "Gotta keepup the\nlight until sunrises\nand protect my sheep.",
		"start_button": "Start"
	},
	"win": {
		"guide": "Yay! I did it.",
		"start_button": "Again"
	},
	"lose-sheep": {
		"guide": "Nooo!\nMy beautiful sheep!",
		"start_button": "Restart"
	},
	"lose-player": {
		"guide": "Nooo!",
		"start_button": "Restart"
	},
	"pause": {
		"guide": "Gotta keepup the\nlight until sunrises\nand protect my sheep.",
		"start_button": "Resume"
	},
}

@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var sheep_sound: AudioStreamPlayer = $SheepSound
@onready var player_die_sound: AudioStreamPlayer = $PlayerDieSound
@onready var guide: Label = %Guide
@onready var start_label: Label = %StartLabel

func _ready() -> void:
	refresh()

func refresh():
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	guide.text = MODES[GameManager.mode]["guide"]
	start_label.text = MODES[GameManager.mode]["start_button"]
	if GameManager.mode == "win" or GameManager.mode == "lose-sheep":
		sheep_sound.play()
	if GameManager.mode == "lose-player":
		player_die_sound.play()
	elif GameManager.mode == "pause":
		click_sound.play()

func _on_exit_button_pressed() -> void:
	click_sound.play()
	get_tree().quit()


func _on_start_button_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	visible = false
	get_tree().paused = false
	click_sound.play()
