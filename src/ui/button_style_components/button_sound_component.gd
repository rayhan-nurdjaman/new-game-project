class_name ButtonSoundComponent

extends Node

@onready var hover_audio_player = AudioStreamPlayer.new()
@onready var press_audio_player = AudioStreamPlayer.new()
@onready var button: Button = get_parent()


func _ready() -> void:
	hover_audio_player.stream = ResourceLoader.load("res://assets/audio/Closed_High_Hat.mp3")
	hover_audio_player.volume_db = -30.0
	add_child(hover_audio_player)
	press_audio_player.stream = ResourceLoader.load("res://assets/audio/Brass Bell.mp3")
	press_audio_player.volume_db = -30.0
	add_child(press_audio_player)
	button.mouse_entered.connect(_on_button_mouse_entered)
	button.pressed.connect(_on_button_pressed)


func _on_button_mouse_entered():
	if not button.disabled:
		hover_audio_player.play()


func _on_button_pressed():
	if not button.disabled:
		press_audio_player.play()
