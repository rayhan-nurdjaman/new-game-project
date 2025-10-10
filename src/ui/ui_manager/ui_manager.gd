extends Node


func _ready() -> void:
	GameState.state_changed.connect(_on_game_state_changed)
	
	SceneLoader.request_transition.connect(_on_request_transition)
	SceneLoader.level_loaded.connect(_on_level_loaded)
	
	$LoadingScreen.finished_fade_in.connect(SceneLoader._on_finished_fade_in)
	$MainMenu.offset = Vector2(-1920.0, 0.0)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("console"):
		if $Console.visible:
			$Console.hide()
			#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			$Console.popup()
			#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_just_pressed("ui_cancel"):
		if GameState.state == GameState.State.IN_GAME:
			GameState.change_state_to(GameState.State.PAUSED)
		elif GameState.state == GameState.State.PAUSED:
			GameState.change_state_to(GameState.State.IN_GAME)

func _on_game_state_changed(old_state, new_state):
	#$HUD.visible = new_state == GameState.State.IN_GAME
	var main_menu_position: Vector2
	if new_state == GameState.State.MAIN_MENU:
		main_menu_position = Vector2.ZERO
	else:
		main_menu_position = Vector2(-1920.0, 0.0)
	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($MainMenu, "offset", main_menu_position, 1.0)
	
	$PauseMenu.visible = new_state == GameState.State.PAUSED
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
