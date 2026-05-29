extends Node3D


enum {
	PINK,
	MAGENTA,
	CYAN,
	BLUE
}


@export var breaker_box: BreakerBox


var sequence: Array = []

# TODO: Make buttons light up instead of indicator lights for debug codes

func check_sequence():
	var debug_sequence = [PINK, MAGENTA, CYAN, BLUE]
	
	if debug_sequence.size() > sequence.size():
		return
	
	var to_compare = sequence.slice(-debug_sequence.size())
	
	if to_compare == debug_sequence:
		print("Match")
		sequence.clear()


func custom_tween() -> Tween:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	return tween


func _on_pink_interacted(_player: Player) -> void:
	sequence.append(PINK)
	
	var tween = custom_tween()
	tween.tween_property($ButtonArray/Pink, "position:y", -0.05, 0.2)
	tween.tween_property($ButtonArray/Pink, "position:y", 0.0, 0.2)
	check_sequence()


func _on_magenta_interacted(_player: Player) -> void:
	sequence.append(MAGENTA)
	
	var tween = custom_tween()
	tween.tween_property($ButtonArray/Magenta, "position:y", -0.05, 0.2)
	tween.tween_property($ButtonArray/Magenta, "position:y", 0.0, 0.2)
	check_sequence()


func _on_cyan_interacted(_player: Player) -> void:
	sequence.append(CYAN)
	
	var tween = custom_tween()
	tween.tween_property($ButtonArray/Cyan, "position:y", -0.05, 0.2)
	tween.tween_property($ButtonArray/Cyan, "position:y", 0.0, 0.2)
	check_sequence()


func _on_blue_interacted(_player: Player) -> void:
	sequence.append(BLUE)
	
	var tween = custom_tween()
	tween.tween_property($ButtonArray/Blue, "position:y", -0.05, 0.2)
	tween.tween_property($ButtonArray/Blue, "position:y", 0.0, 0.2)
	check_sequence()


func _on_power_interacted(_player: Player) -> void:
	var tween = custom_tween()
	tween.tween_property($Power, "position:z", 0.85, 0.2)
	tween.tween_property($Power, "position:z", 0.9, 0.2)
