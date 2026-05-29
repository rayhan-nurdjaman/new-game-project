extends Node


const WIRE_PACKED_SCENE: PackedScene = preload("res://src/wires/wire.tscn")
const BROKEN_WIRE_PACKED_SCENE: PackedScene = preload("res://src/wires/broken_wire.tscn")
const WIRE_CORNER_PACKED_SCENE: PackedScene = preload("res://src/wires/wire_corner.tscn")

@export var wire_nodes: Array[Marker3D]



# Helper function for initialize_wires()
func orient_wires(start: Vector3, end: Vector3, wire_object: Node) -> void:
	var displacement = end - start
	wire_object.global_transform.origin = start + displacement / 2.0

	wire_object.global_transform.basis.y = displacement  #Stretches the unit length wire
	wire_object.global_transform.basis.x = displacement.cross(Vector3.UP).normalized()
	if wire_object.global_transform.basis.x.is_zero_approx():
		wire_object.global_transform.basis.x = Vector3.RIGHT
	wire_object.global_transform.basis.z = (
		wire_object
		. global_transform
		. basis
		. x
		. cross(wire_object.global_transform.basis.y)
		. normalized()
	)


func initialize_wires() -> void:
	var num_broken: int = 2
	var broken_wire_id: Array = Array(range(len(wire_nodes) - 1))
	broken_wire_id.shuffle()
	broken_wire_id = broken_wire_id.slice(0, num_broken)
	for i in range(len(wire_nodes) - 1):
		var wire
		if i in broken_wire_id:
			wire = BROKEN_WIRE_PACKED_SCENE.instantiate()
		else:
			wire = WIRE_PACKED_SCENE.instantiate()
		add_child(wire) 
		orient_wires(
			wire_nodes[i].global_position,
			wire_nodes[i+1].global_position,
			wire
		)
		var wire_corner = WIRE_CORNER_PACKED_SCENE.instantiate()
		add_child(wire_corner)
		wire_corner.global_position = wire_nodes[i].global_position


func _ready() -> void:
	initialize_wires()
