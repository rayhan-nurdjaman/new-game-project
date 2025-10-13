extends UIScreen


enum SubScreen{
	PAUSE_MENU,
	SETTINGS
}


var sub_screen: SubScreen = SubScreen.PAUSE_MENU


func create_de_facto_tween() -> Tween:
	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	return tween


func _ready() -> void:
	$PauseMenuSubScreen/VBoxContainer/VBoxContainer/Resume.pressed.connect(_on_resume_pressed)
	$PauseMenuSubScreen/VBoxContainer/VBoxContainer/MainMenu.pressed.connect(_on_main_menu_pressed)
	$PauseMenuSubScreen/VBoxContainer/VBoxContainer/Settings.pressed.connect(_on_settings_pressed)
	$SettingsSubMenu/Back.pressed.connect(_on_back_pressed)
	$PauseMenuSubScreen.position = Vector2(-1920.0, 0.0)
	$SettingsSubMenu.position = Vector2(1920.0, 0.0)


func _on_resume_pressed():
	GameState.change_state_to(GameState.State.IN_GAME)


func _on_settings_pressed():
	sub_screen = SubScreen.SETTINGS
	update_subscreen()


func _on_main_menu_pressed():
	SceneLoader.load_scene("main_menu")


func _on_back_pressed():
	sub_screen = SubScreen.PAUSE_MENU
	update_subscreen()


func update_subscreen():
	if sub_screen == SubScreen.PAUSE_MENU:
		fade_out_settings()
		fade_in_pause_menu()
	elif sub_screen == SubScreen.SETTINGS:
		fade_out_pause_menu()
		fade_in_settings()


func fade_in_pause_menu():
	var position: Vector2 = Vector2.ZERO
	var tween = create_de_facto_tween()
	tween.tween_property($PauseMenuSubScreen, "position", position, 0.5)


func fade_out_pause_menu():
	var position: Vector2 = Vector2(-1920.0, 0.0)
	var tween = create_de_facto_tween()
	tween.tween_property($PauseMenuSubScreen, "position", position, 0.5)


func fade_in_settings():
	var position: Vector2 = Vector2.ZERO
	var tween = create_de_facto_tween()
	tween.tween_property($SettingsSubMenu, "position", position, 0.5)


func fade_out_settings():
	var position: Vector2 = Vector2(1920.0, 0.0)
	var tween = create_de_facto_tween()
	tween.tween_property($SettingsSubMenu, "position", position, 0.5)


func fade_in_bg_tint():
	var color: Color = Color(0.0, 0.0, 0.0, 0.5)
	var tween = create_de_facto_tween()
	tween.tween_property($BGTint, "color", color, 0.5)


func fade_out_bg_tint():
	var color: Color = Color(0.0, 0.0, 0.0, 0.0)
	var tween = create_de_facto_tween()
	tween.tween_property($BGTint, "color", color, 0.5)


func fade_in():
	sub_screen = SubScreen.PAUSE_MENU
	fade_in_bg_tint()
	update_subscreen()


func fade_out():
	fade_out_pause_menu()
	fade_out_settings()
	fade_out_bg_tint()
