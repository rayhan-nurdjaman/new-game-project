class_name Portal

extends Node3D

@export var width: float = 2.0
@export var height: float = 3.0

@export var depth_offset: float = 1.0
@export var linked_portal: Portal


@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var portal_camera: Camera3D = $SubViewport/Camera3D


# TODO: show editor debug on which portals are linked together
func _ready() -> void:
	$SubViewport.size = get_viewport().size / 2.0
	$Cube.scale.x = width - 0.01
	$Cube.scale.y = height - 0.01
	$Cube.scale.z = depth_offset - 0.01
	#$Cube.transform.origin.z = depth_offset
	mesh.transform.origin.z = -depth_offset / 2.0 + 0.01


func update_portal_and_camera():
	var portal_mesh1 = self
	var portal_mesh2 = linked_portal
	var portal1_camera = portal_camera
	
	var camera: Camera3D = get_viewport().get_camera_3d()
	var portal1_transform = portal_mesh1.global_transform
	#portal1_transform = portal1_transform.translated(portal1_transform.basis.z * depth_offset)
	var portal2_transform = portal_mesh2.global_transform
	#portal2_transform = portal2_transform.translated(portal2_transform.basis.z * depth_offset)
	
	var relative_transform = portal1_transform.rotated_local(portal1_transform.basis.y, PI).inverse() * camera.global_transform
	var pos_delta1 = portal1_transform.origin - camera.global_transform.origin
	var extent_x1 = abs(portal1_transform.basis.x.dot(camera.global_transform.basis.z)) * 1.0
	var extent_y1 = abs(portal1_transform.basis.y.dot(camera.global_transform.basis.z)) * 1.5
	var extent_z1 = abs(portal1_transform.basis.z.dot(camera.global_transform.basis.z)) * depth_offset
	var extent1 = extent_x1 + extent_y1 + extent_z1
	portal1_camera.global_transform = portal2_transform * relative_transform
	portal1_camera.near = max(pos_delta1.dot(-camera.global_transform.basis.z) - extent1, 0.05)


func check_and_solve_teleport():
	var portal1 = self
	var portal2 = linked_portal
	
	var player_transform = GameState.player.global_transform
	player_transform.basis = GameState.player.pivot.global_transform.basis
	player_transform.origin += player_transform.basis.y * 1.0 # Player center of origin position correction
	
	var delta = player_transform.origin - portal1.global_transform.origin
	var longitudinal_distance = delta.dot(portal1.global_transform.basis.z)
	var transversal_distance = delta.dot(portal1.global_transform.basis.x)
	var vertical_distance = delta.dot(portal1.global_transform.basis.y)
	
	if longitudinal_distance < 0.0 and longitudinal_distance > -depth_offset / 2.0 and abs(transversal_distance) < width / 2.0 and abs(vertical_distance) < height / 2.0:
		var relative_transform = portal1.global_transform.rotated_local(portal1.global_transform.basis.y, PI).inverse() * player_transform
		var new_transform = portal2.global_transform * relative_transform
		#GameState.player.global_transform.origin = new_transform.origin + portal2.global_transform.basis.z * (depth_offset * 2.0)
		GameState.player.global_transform.origin = new_transform.origin - player_transform.basis.y * 1.0
		GameState.player.linear_velocity = new_transform.basis * GameState.player.pivot.global_transform.basis.inverse() * GameState.player.linear_velocity
		#GameState.player.pivot.global_transform.basis = new_transform.basis
		GameState.player.controller.camera_azimuth = Vector3.BACK.signed_angle_to(new_transform.basis.z, Vector3.UP)


func _physics_process(_delta: float) -> void:
	if GameState.player:
		check_and_solve_teleport()


func _process(_delta: float) -> void:
	update_portal_and_camera()
