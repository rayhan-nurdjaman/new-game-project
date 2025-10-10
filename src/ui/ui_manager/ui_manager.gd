extends Node


func _ready() -> void:
	GameState.state_changed.connect(_on_game_state_changed)
	
	SceneLoader.request_transition.connect(_on_request_transition)
	SceneLoader.level_loaded.connect(_on_level_loaded)
	
	$LoadingScreen.finished_fade_in.connect(SceneLoader._on_finished_fade_in)
	$MainMenu.offset = Vector2(-1920.0, 0.0)
	$PauseMenu.offset = Vector2(-1920.0, 0.0)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("console"):
		if $Console.visible:
			$Console.hide()
		else:
			$Console.popup()
	if Input.is_action_just_pressed("ui_cancel"):
		if GameState.state == GameState.State.IN_GAME:
			GameState.change_state_to(GameState.State.PAUSED)
		elif GameState.state == GameState.State.PAUSED:
			GameState.change_state_to(GameState.State.IN_GAME)

func _on_game_state_changed(old_state, new_state):
	var main_menu_position: Vector2
	if new_state == GameState.State.MAIN_MENU:
		main_menu_position = Vector2.ZERO
	else:
		main_menu_position = Vector2(-1920.0, 0.0)
	var main_menu_tween = create_tween()
	main_menu_tween.set_ignore_time_scale(true)
	main_menu_tween.set_ease(Tween.EASE_IN_OUT)
	main_menu_tween.set_trans(Tween.TRANS_CUBIC)
	main_menu_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	main_menu_tween.tween_property($MainMenu, "offset", main_menu_position, 0.5)
	
	var pause_menu_position: Vector2
	if new_state == GameState.State.PAUSED:
		pause_menu_position = Vector2.ZERO
	else:
		pause_menu_position = Vector2(-1920.0, 0.0)
	var pause_menu_tween = create_tween()
	pause_menu_tween.set_ignore_time_scale(true)
	pause_menu_tween.set_ease(Tween.EASE_IN_OUT)
	pause_menu_tween.set_trans(Tween.TRANS_CUBIC)
	pause_menu_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	pause_menu_tween.tween_property($PauseMenu, "offset", pause_menu_position, 0.5)
	
	#$PauseMenu.visible = new_state == GameState.State.PAUSED
	$HUD.visible = new_state == GameState.State.IN_GAME
	
	$LoadingScreen.visible = (
		new_state == GameState.State.LOADING or old_state == GameState.State.LOADING
	)


func _on_request_transition(no_fade_in):
	if no_fade_in:
		$LoadingScreen.reset()
	else:
		$LoadingScreen.fade_in()


func _on_level_loaded(_level_name: String):
	$LoadingScreen.fade_out()
