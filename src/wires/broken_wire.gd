extends Node3D

var is_fixed: bool = false


func _on_interact_trigger_interacted(player: Player) -> void:
	is_fixed = true
	$BrokenWireMesh.hide()
	$HealthyWireMesh.show()
