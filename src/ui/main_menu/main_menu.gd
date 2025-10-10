extends CanvasLayer


func _ready() -> void:
	$MarginContainer/VBoxContainer/VBoxContainer/Start.pressed.connect(_on_start_pressed)
	$MarginContainer/VBoxContainer/VBoxContainer/Quit.pressed.connect(_on_quit_pressed)


func _on_start_pressed():
	SceneLoader.load_scene("test_level")


func _on_quit_pressed():
	get_tree().quit()
