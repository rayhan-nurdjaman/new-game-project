extends CanvasLayer


func _ready() -> void:
	$TextureRect/MarginContainer/VBoxContainer/VBoxContainer/Resume.pressed.connect(_on_resume_pressed)
	$TextureRect/MarginContainer/VBoxContainer/VBoxContainer/MainMenu.pressed.connect(_on_main_menu_pressed)


func _on_resume_pressed():
	GameState.change_state_to(GameState.State.IN_GAME)


func _on_main_menu_pressed():
	SceneLoader.load_scene("main_menu")
