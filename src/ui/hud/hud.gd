extends UIScreen


func _ready() -> void:
	hide()


func fade_in():
	show()
	var main_menu_tween = create_tween()
	main_menu_tween.set_ignore_time_scale(true)
	main_menu_tween.set_ease(Tween.EASE_IN_OUT)
	main_menu_tween.set_trans(Tween.TRANS_CUBIC)
	main_menu_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	main_menu_tween.tween_property($CanvasModulate, "color", Color(1.0, 1.0, 1.0, 1.0), 0.5)


func fade_out():
	var main_menu_tween = create_tween()
	main_menu_tween.set_ignore_time_scale(true)
	main_menu_tween.set_ease(Tween.EASE_IN_OUT)
	main_menu_tween.set_trans(Tween.TRANS_CUBIC)
	main_menu_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	main_menu_tween.tween_property($CanvasModulate, "color", Color(1.0, 1.0, 1.0, 0.0), 0.5)
	#main_menu_tween.tween_callback(hide)
