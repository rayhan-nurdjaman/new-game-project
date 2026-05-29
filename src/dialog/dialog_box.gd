extends Marker3D


func set_text(text: String):
	#scale = Vector2(1.0, 0.0)
	$PanelContainer/MarginContainer/RichTextLabel.text = text


func _process(_delta: float) -> void:
	var viewport_size = get_viewport().size
	var camera = get_viewport().get_camera_3d()
	
	var world_pos = global_transform.origin
	var view_space_pos = camera.global_transform.inverse() * world_pos
	
	var distance_to_camera = view_space_pos.length()
	var screen_scale = 2.0 / sqrt(distance_to_camera)
	#var screen_scale = 2.0 / distance_to_camera
	$PanelContainer.scale = Vector2(screen_scale, screen_scale)
	var dialog_box_size = $PanelContainer.size * $PanelContainer.scale
	
	var margin = Vector2(32.0, 32.0)
	
	# Start angle limiting
	# TODO: Add deadzone so speech bubbles dont snap around
	var rotation_axis = Vector3.FORWARD.cross(view_space_pos).normalized()
	var angle = Vector3.FORWARD.signed_angle_to(view_space_pos, rotation_axis)
	
	var alpha = Vector3.UP.signed_angle_to(rotation_axis, Vector3.FORWARD)
	var l = min(abs((viewport_size.x - dialog_box_size.x - margin.x) / 2.0 / cos(alpha)), abs((viewport_size.y - dialog_box_size.y - margin.y) / 2.0 / sin(alpha)))
	
	var d = viewport_size.y / 2.0 / tan(deg_to_rad(camera.fov / 2.0))
	
	var theta = atan(l / d)
	angle = min(angle, theta)
	var new_screen_pos = Vector3.FORWARD.rotated(rotation_axis, angle)
	# End angle limiting
	
	var screen_pos = camera.unproject_position(camera.global_transform * new_screen_pos)
	var center_pos = screen_pos - (dialog_box_size) / 2.0
	$PanelContainer.position = center_pos
	
	var fade_distance = 8.5
	var visible_distance = 7.5

	var _alpha := 1.0
	if distance_to_camera > visible_distance:
		_alpha = clamp(
			(fade_distance - distance_to_camera) / (fade_distance - visible_distance), 0.0, 1.0
		)
	$PanelContainer.modulate = Color(1.0, 1.0, 1.0, _alpha)


func fade_in():
	#scale = Vector2(1.0, 0.0)
	self.modulate = Color.TRANSPARENT
	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($PanelContainer, "modulate", Color.WHITE, 0.1)


func fade_out():
	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_interval(0.2)
	tween.tween_property($PanelContainer, "modulate", Color.TRANSPARENT, 0.1)
	tween.tween_callback(queue_free)
