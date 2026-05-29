extends UIScreen


var dialog_boxes: Dictionary
var dialog_queue: Array


func _ready() -> void:
	DialogServer.dialog_played.connect(_on_dialog_played)
	DialogServer.dialog_ended.connect(_on_dialog_ended)
	hide()


func _process(_delta: float) -> void:
	if GameState.player:
		var is_looking_at_interact_trigger: bool = GameState.player.looking_at_object is InteractTrigger or GameState.player.looking_at_object is RigidBody3D
		$MarginContainer/CenterContainer/TextureRect.visible = !GameState.player.hide_crosshair and not is_looking_at_interact_trigger
		$MarginContainer/CenterContainer/TextureRect2.visible = !GameState.player.hide_crosshair and is_looking_at_interact_trigger


func _on_dialog_played(dialog: Dialog):
	var dialog_box_scene: PackedScene = ResourceLoader.load("res://src/dialog_box.tscn")
	var dialog_box: Control = dialog_box_scene.instantiate()
	dialog_box.set_text(dialog.subtitle)
	$DialogBoxContainer.add_child(dialog_box)
	dialog_box.fade_in()
	dialog_boxes[dialog.get_instance_id()] = dialog_box


func _on_dialog_ended(dialog: Dialog):
	if not dialog_boxes.has(dialog.get_instance_id()):
		return
	var dialog_box = dialog_boxes[dialog.get_instance_id()]

	print(dialog.subtitle)
	print(dialog_boxes.erase(dialog.get_instance_id()))
	dialog_box.fade_out()


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
