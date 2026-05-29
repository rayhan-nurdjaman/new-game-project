extends Node


func _ready() -> void:
	GameState.state_changed.connect(_on_game_state_changed)
	
	SceneLoader.request_transition.connect(_on_request_transition)
	SceneLoader.level_loaded.connect(_on_level_loaded)
	
	$LoadingScreen.finished_fade_in.connect(SceneLoader._on_finished_fade_in)
	#$MainMenu.offset = Vector2(-1920.0, 0.0)
	#$PauseMenu.offset = Vector2(-1920.0, 0.0)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("console"):
		if GameState.state == GameState.State.IN_GAME:
			GameState.change_state_to(GameState.State.PAUSED)
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
	if new_state == GameState.State.MAIN_MENU:
		$MainMenu.fade_in()
	else:
		$MainMenu.fade_out()
	
	if new_state == GameState.State.PAUSED:
		$PauseMenu.fade_in()
	else:
		$PauseMenu.fade_out()
	
	if new_state == GameState.State.IN_GAME:
		$HUD.fade_in()
	else:
		$HUD.fade_out()
	
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
