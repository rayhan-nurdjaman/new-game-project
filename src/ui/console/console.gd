extends PopupPanel


func _ready() -> void:
	$VBoxContainer/HBoxContainer/Command.text_submitted.connect(_on_command_text_submitted)
	$VBoxContainer/HBoxContainer/Submit.pressed.connect(_on_submit_pressed)
	visibility_changed.connect(_on_visibility_change)


func _on_visibility_change():
	if visible:
		$VBoxContainer/HBoxContainer/Command.grab_focus()
	else:
		$VBoxContainer/HBoxContainer/Command.release_focus()


func _process(_delta):
	$VBoxContainer/CommandHistory.text = "\n".join(Debug.debug_console_output)


func _on_command_text_submitted(new_text):
	Debug.parse_command(new_text)
	$VBoxContainer/HBoxContainer/Command.text = ""


func _on_submit_pressed():
	Debug.parse_command($VBoxContainer/HBoxContainer/Command.text)
	$VBoxContainer/HBoxContainer/Command.text = ""
