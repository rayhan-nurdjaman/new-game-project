extends UIScreen


func _ready() -> void:
	$MarginContainer/VBoxContainer/VBoxContainer/Resume.pressed.connect(_on_resume_pressed)
	$MarginContainer/VBoxContainer/VBoxContainer/MainMenu.pressed.connect(_on_main_menu_pressed)
	$MarginContainer.position = Vector2(-1920.0, 0.0)


func _on_resume_pressed():
	GameState.change_state_to(GameState.State.IN_GAME)


func _on_main_menu_pressed():
	SceneLoader.load_scene("main_menu")


func fade_in():
	var pause_menu_position: Vector2 = Vector2.ZERO
	var pause_menu_tween = create_tween()
	pause_menu_tween.set_ignore_time_scale(true)
	pause_menu_tween.set_ease(Tween.EASE_IN_OUT)
	pause_menu_tween.set_trans(Tween.TRANS_CUBIC)
	pause_menu_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	pause_menu_tween.set_parallel()
	pause_menu_tween.tween_property($ColorRect, "color", Color(0.0, 0.0, 0.0, 0.5), 0.5)
	pause_menu_tween.tween_property($MarginContainer, "position", pause_menu_position, 0.5)


func fade_out():
	var pause_menu_position: Vector2 = Vector2(-1920.0, 0.0)
	var pause_menu_tween = create_tween()
	pause_menu_tween.set_ignore_time_scale(true)
	pause_menu_tween.set_ease(Tween.EASE_IN_OUT)
	pause_menu_tween.set_trans(Tween.TRANS_CUBIC)
	pause_menu_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	pause_menu_tween.set_parallel()
	pause_menu_tween.tween_property($MarginContainer, "position", pause_menu_position, 0.5)
	pause_menu_tween.tween_property($ColorRect, "color", Color(0.0, 0.0, 0.0, 0.0), 0.5)
