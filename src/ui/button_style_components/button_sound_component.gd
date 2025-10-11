class_name ButtonSoundComponent

extends Node

@onready var hover_audio_player = AudioStreamPlayer.new()
@onready var press_audio_player = AudioStreamPlayer.new()
@onready var button: Button = get_parent()


func _ready() -> void:
	hover_audio_player.stream = ResourceLoader.load("res://res/sounds/ui/select.wav")
	hover_audio_player.volume_db = -20.0
	hover_audio_player.bus = "UI"
	add_child(hover_audio_player)
	press_audio_player.stream = ResourceLoader.load("res://res/sounds/ui/chrono.wav")
	press_audio_player.volume_db = -20.0
	press_audio_player.bus = "UI"
	add_child(press_audio_player)
	button.mouse_entered.connect(_on_button_mouse_entered)
	button.pressed.connect(_on_button_pressed)


func _on_button_mouse_entered():
	if not button.disabled:
		hover_audio_player.play()


func _on_button_pressed():
	if not button.disabled:
		press_audio_player.play()
