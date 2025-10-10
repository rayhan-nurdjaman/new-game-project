class_name ButtonResizeComponent

extends Node

@onready var button: Button = get_parent()


func _ready() -> void:
	# Set node to always process
	process_mode = Node.PROCESS_MODE_ALWAYS
	button.process_mode = Node.PROCESS_MODE_ALWAYS

	button.mouse_entered.connect(_on_button_mouse_entered)
	button.mouse_exited.connect(_on_button_mouse_exited)
	button.pivot_offset = button.size / 2.0


func _on_button_mouse_entered():
	if not button.disabled:
		var tween = create_tween()
		tween.set_ignore_time_scale(true)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_ELASTIC)
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.2)


func _on_button_mouse_exited():
	if not button.disabled:
		var tween = create_tween()
		tween.set_ignore_time_scale(true)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_SPRING)
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)
