extends Node

signal state_changed(old_state, new_state)

enum State {MAIN_MENU, LOADING, IN_GAME, PAUSED }

var state: State = State.LOADING

var player: Node = null:
	set(value):
		player = value
		#gui.player = player
var camera: Camera3D = null

var pause_tween: Tween = null
var in_game_mouse_state = Input.MOUSE_MODE_CAPTURED


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func change_state_to(new_state: State):
	var old_state: State = state
	_on_state_exit(state)
	state = new_state
	_on_state_enter(state)
	state_changed.emit(old_state, new_state)
	print_debug(State.keys()[state])

# TODO: Add a slow down effect for pausing
# TODO: This is a bit redundant with GUI.gd
func _on_state_exit(_state: State):
	match _state:
		State.MAIN_MENU:
			pass
		State.LOADING:
			pass
		State.IN_GAME:
			in_game_mouse_state = Input.mouse_mode
		State.PAUSED:
			unpause_game()


func _on_state_enter(_state: State):
	match _state:
		State.MAIN_MENU:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		State.LOADING:
			pass
		State.IN_GAME:
			Input.mouse_mode = in_game_mouse_state
		State.PAUSED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			pause_game()


func pause_game():
	if pause_tween:
		pause_tween.kill()
	pause_tween = create_tween()
	pause_tween.set_ignore_time_scale(true)
	pause_tween.set_ease(Tween.EASE_IN_OUT)
	pause_tween.set_trans(Tween.TRANS_CUBIC)
	pause_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	pause_tween.tween_property(Engine, "time_scale", 0.0, 0.5)
	pause_tween.tween_callback(get_tree().set_pause.bind(true))


func unpause_game():
	if pause_tween:
		pause_tween.kill()
	pause_tween = create_tween()
	pause_tween.set_ignore_time_scale(true)
	pause_tween.set_ease(Tween.EASE_IN_OUT)
	pause_tween.set_trans(Tween.TRANS_CUBIC)
	pause_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	get_tree().paused = false
	pause_tween.tween_property(Engine, "time_scale", 1.0, 0.5)
