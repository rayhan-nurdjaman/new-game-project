extends Item


var light: SpotLight3D


func _init() -> void:
	light = SpotLight3D.new()


func process():
	pass


func primary(player, space_state, delta):
	var cam_origin = player.camera.global_transform.origin
	var cam_dir = player.camera.global_transform.basis.z
	player.camera.add_child(light)


func secondary(player, space_state, delta):
	pass
