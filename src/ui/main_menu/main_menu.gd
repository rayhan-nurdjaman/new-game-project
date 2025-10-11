extends UIScreen


func _ready() -> void:
	$MarginContainer/VBoxContainer/VBoxContainer/Start.pressed.connect(_on_start_pressed)
	$MarginContainer/VBoxContainer/VBoxContainer/Quit.pressed.connect(_on_quit_pressed)
	offset = Vector2(-1920.0, 0.0)


func _on_start_pressed():
	SceneLoader.load_scene("test_level")


func _on_quit_pressed():
	get_tree().quit()


func fade_in():
	var main_menu_position: Vector2 = Vector2.ZERO
	var main_menu_tween = create_tween()
	main_menu_tween.set_ignore_time_scale(true)
	main_menu_tween.set_ease(Tween.EASE_IN_OUT)
	main_menu_tween.set_trans(Tween.TRANS_CUBIC)
	main_menu_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	main_menu_tween.tween_property(self, "offset", main_menu_position, 0.5)


func fade_out():
	var main_menu_position: Vector2 = Vector2(-1920.0, 0.0)
	var main_menu_tween = create_tween()
	main_menu_tween.set_ignore_time_scale(true)
	main_menu_tween.set_ease(Tween.EASE_IN_OUT)
	main_menu_tween.set_trans(Tween.TRANS_CUBIC)
	main_menu_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	main_menu_tween.tween_property(self, "offset", main_menu_position, 0.5)
