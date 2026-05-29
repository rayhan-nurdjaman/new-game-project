extends Node3D

@export var breaker_box: BreakerBox

var is_on: bool = true
# Assuming breakers are always initially broken
var breaker_box_is_fixed: bool = false


func _ready() -> void:
	breaker_box.state_changed.connect(_on_breaker_box_state_changed)
	update_lights()


func update_lights():
	var children = get_children()
	for child in children:
		if child is Light3D:
			child.visible = is_on and breaker_box_is_fixed


func _on_breaker_box_state_changed(fixed: bool) -> void:
	breaker_box_is_fixed = fixed
	update_lights()


func _on_interact_trigger_interacted(_player: Player) -> void:
	is_on = !is_on
	update_lights()
