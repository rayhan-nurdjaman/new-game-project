extends Node3D


var width: float = 2.0
var height: float = 3.0

var depth_offset: float = 0.5

func _ready() -> void:
	$AnimationPlayer.play("new_animation")


func update_portal_and_camera(portal_mesh1: MeshInstance3D, portal_mesh2: MeshInstance3D, portal1_camera: Camera3D):
	var camera: Camera3D = get_viewport().get_camera_3d()
	var portal1_transform = portal_mesh1.global_transform
	portal1_transform = portal1_transform.translated(portal1_transform.basis.z * depth_offset)
	var portal2_transform = portal_mesh2.global_transform
	portal2_transform = portal2_transform.translated(portal2_transform.basis.z * depth_offset)
	
	var relative_transform = portal1_transform.rotated_local(portal1_transform.basis.y, PI).inverse() * camera.global_transform
	var pos_delta1 = portal1_transform.origin - camera.global_transform.origin
	var extent_x1 = abs(portal1_transform.basis.x.dot(camera.global_transform.basis.z)) * 1.0
	var extent_y1 = abs(portal1_transform.basis.y.dot(camera.global_transform.basis.z)) * 1.5
	var extent1 = extent_x1 + extent_y1
	portal1_camera.global_transform = portal2_transform * relative_transform
	portal1_camera.near = max(pos_delta1.dot(-camera.global_transform.basis.z) - extent1, 0.05)


func update_camera():
	update_portal_and_camera($PortalMesh1, $PortalMesh2, $SubViewport1/Camera3D)
	update_portal_and_camera($PortalMesh2, $PortalMesh1, $SubViewport2/Camera3D)


#func _process(delta: float) -> void:
	#update_camera()


func check_and_solve_teleport(portal1: MeshInstance3D, portal2: MeshInstance3D):
	var player_transform = GameState.player.global_transform
	player_transform.basis = GameState.player.pivot.global_transform.basis
	#var check_distance = 0.4
	
	var delta = player_transform.origin - portal1.global_transform.origin
	var longitudinal_distance = delta.dot(portal1.global_transform.basis.z)
	var transversal_distance = delta.dot(portal1.global_transform.basis.x)
	if abs(longitudinal_distance) < depth_offset / 2.0 and abs(transversal_distance) < 1.0:
		var relative_transform = portal1.global_transform.rotated_local(portal1.global_transform.basis.y, PI).inverse() * player_transform
		var new_transform = portal2.global_transform * relative_transform
		GameState.player.global_transform.origin = new_transform.origin + portal2.global_transform.basis.z * (depth_offset * 2.0)
		GameState.player.linear_velocity = new_transform.basis * GameState.player.pivot.global_transform.basis.inverse() * GameState.player.linear_velocity
		GameState.player.pivot.global_transform.basis = new_transform.basis

func _process(delta: float) -> void:
	if GameState.player:
		check_and_solve_teleport($PortalMesh1, $PortalMesh2)
		check_and_solve_teleport($PortalMesh2, $PortalMesh1)
	update_camera()
