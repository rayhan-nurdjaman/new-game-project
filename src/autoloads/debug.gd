extends Node

var debug_console_output: PackedStringArray = [
	'Debug console for "%s"' % ProjectSettings.get_setting("application/config/name", "Unnamed Project"),
	'Game started at: %s' % Time.get_datetime_string_from_system()
]


func add_log(message: String):
	var entry: String = "[" + Time.get_time_string_from_system() + "]"
	entry += " ~ "
	entry += message
	debug_console_output.append(entry)


func parse_command(input: String):
	var argv: PackedStringArray = input.split(" ", false)
	var argc: int = argv.size()
	if argc != 0:
		match argv[0].to_lower():
			"timescale":
				if argc >= 2:
					Engine.set_time_scale(float(argv[1]))
					add_log("Engine timescale set to %s" % argv[1])
				else:
					add_log("Not enough parameters!")
			"quit":
				get_tree().quit()
			"say":
				if argc >= 1:
					var test_dialog: Dialog = Dialog.new()
					#test_dialog.audio_stream = ResourceLoader.load("res://res/sounds/test_narration.wav")
					test_dialog.subtitle = " ".join(argv.slice(1))

					DialogServer.play_dialog(test_dialog)
				else:
					add_log("Not enough parameters!")
			"fullbright":
				var viewport = get_viewport()
				if viewport.debug_draw != Viewport.DEBUG_DRAW_UNSHADED:
					viewport.debug_draw = Viewport.DEBUG_DRAW_UNSHADED
				else:
					viewport.debug_draw = Viewport.DEBUG_DRAW_DISABLED
			"offcam":
				GameState.player.detach_cam()
			_:
				add_log("Unknown command \"%s\"" % argv[0])
