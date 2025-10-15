extends UIScreen

enum SubScreen{
	MAIN_MENU,
	SETTINGS
}

var sub_screen: SubScreen = SubScreen.MAIN_MENU


func create_de_facto_tween() -> Tween:
	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	return tween


func _ready() -> void:
	$MainMenuSubScreen/VBoxContainer/VBoxContainer/Start.pressed.connect(_on_start_pressed)
	$MainMenuSubScreen/VBoxContainer/VBoxContainer/Quit.pressed.connect(_on_quit_pressed)
	$MainMenuSubScreen/VBoxContainer/VBoxContainer/Settings.pressed.connect(_on_settings_pressed)
	$SettingsSubMenu/VBoxContainer/Back.pressed.connect(_on_back_pressed)
	$MainMenuSubScreen.position = Vector2(-1920.0, 0.0)
	$SettingsSubMenu.position = Vector2(1920.0, 0.0)


func _on_start_pressed():
	SceneLoader.load_scene("test_level")


func _on_settings_pressed():
	sub_screen = SubScreen.SETTINGS
	update_subscreen()


func _on_quit_pressed():
	get_tree().quit()


func _on_back_pressed():
	sub_screen = SubScreen.MAIN_MENU
	update_subscreen()


func update_subscreen():
	if sub_screen == SubScreen.MAIN_MENU:
		fade_out_settings()
		fade_in_main_menu()
	elif sub_screen == SubScreen.SETTINGS:
		fade_out_main_menu()
		fade_in_settings()


func fade_in_main_menu():
	var position: Vector2 = Vector2.ZERO
	var tween = create_de_facto_tween()
	tween.tween_property($MainMenuSubScreen, "position", position, 0.5)


func fade_out_main_menu():
	var position: Vector2 = Vector2(-1920.0, 0.0)
	var tween = create_de_facto_tween()
	tween.tween_property($MainMenuSubScreen, "position", position, 0.5)


func fade_in_settings():
	var position: Vector2 = Vector2.ZERO
	var tween = create_de_facto_tween()
	tween.tween_property($SettingsSubMenu, "position", position, 0.5)


func fade_out_settings():
	var position: Vector2 = Vector2(1920.0, 0.0)
	var tween = create_de_facto_tween()
	tween.tween_property($SettingsSubMenu, "position", position, 0.5)


func fade_in():
	fade_in_main_menu()


func fade_out():
	fade_out_main_menu()
