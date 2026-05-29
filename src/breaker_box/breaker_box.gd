class_name BreakerBox

extends Node3D

signal state_changed(fixed: bool)

enum Tile{
	CAP,
	STRAIGHT,
	ELBOW
}

# Points up
const TILE_CAP_PACKED_SCENE = preload("res://src/breaker_box/pipe_cap.tscn")
# Vertical
const TILE_STRAIGHT_PACKED_SCENE = preload("res://src/breaker_box/pipe_straight.tscn")
# Points up and right
const TILE_ELBOW_PACKED_SCENE = preload("res://src/breaker_box/pipe_elbow.tscn")

const tile_size = 0.1

@export var size := Vector2i(5, 5)
var start: Vector2i
var end: Vector2i

var is_interacting: bool = false
var is_solved: bool = false

# Matrices with [x][y] access, [0][0] at bottom left and [size.x-1][size.y-1] at top right
# Numbers from 0 to 3 indicating how many 90 degree turns CCW the tile is rotated
var rotation_matrix: Array[Array] = []
# Contains references to each tile node. Used to tween rotating
var node_matrix: Array[Array] = []
# Contains information on which type (cap, straight, elbow) of tile
var element_matrix: Array[Array] = []

@onready var grid_center_offset_x = (float(size.x) - 1.0) / 2.0
@onready var grid_center_offset_y = (float(size.y) - 1.0) / 2.0


func _initialize_matrices():
	node_matrix.resize(size.x)
	element_matrix.resize(size.x)
	rotation_matrix.resize(size.x)
	for x in range(size.x):
		node_matrix[x] = []
		node_matrix[x].resize(size.y)
		element_matrix[x] = []
		element_matrix[x].resize(size.y)
		rotation_matrix[x] = []
		rotation_matrix[x].resize(size.y)
		rotation_matrix[x].fill(0)


func create_path() -> Array:
	var stack: Array = [start]
	var visited: Array = []
	var connected_from: Dictionary

	# Random DFS walk
	while stack:
		var head = stack.pop_back()
		if head in visited:
			continue
		visited.append(head)

		if head == end:
			break

		var neighbors: Array = []
		if head.x > 0:
			neighbors.append(head + Vector2i(-1, 0))
		if head.x < size.x - 1:
			neighbors.append(head + Vector2i(1, 0))
		if head.y > 0:
			neighbors.append(head + Vector2i(0, -1))
		if head.y < size.y - 1:
			neighbors.append(head + Vector2i(0, 1))

		for neighbor in neighbors:
			if neighbor not in visited:
				connected_from[neighbor] = head

		neighbors.shuffle()
		stack.append_array(neighbors)

	var path: Array
	var reverse_head = end
	while reverse_head != start:
		path.append(reverse_head)
		reverse_head = connected_from[reverse_head]
	path.append(start)

	return path


func _ready() -> void:
	start = Vector2i(0, 0)
	end = Vector2i(size.x - 1, size.y - 1)
	_initialize_matrices()

	var path: Array = create_path()

	# Instantiate tiles and randomize rotation
	for y in range(size.y):
		for x in range(size.x):
			var mesh_instance: Node3D
			var coordinate: Vector2i = Vector2i(x, y)
			# Is the current coordinate part of the path?
			if coordinate in path:
				# Is it the start or end points?
				if coordinate == start or coordinate == end:
					element_matrix[x][y] = Tile.CAP
					mesh_instance = TILE_CAP_PACKED_SCENE.instantiate()
				else:
					var index: int = path.find(coordinate)
					var before: Vector2i = path[index + 1]
					var after: Vector2i = path[index - 1]
					if before.x == after.x or before.y == after.y:
						element_matrix[x][y] = Tile.STRAIGHT
						mesh_instance = TILE_STRAIGHT_PACKED_SCENE.instantiate()
					else:
						element_matrix[x][y] = Tile.ELBOW
						mesh_instance = TILE_ELBOW_PACKED_SCENE.instantiate()
			else:
				# Fill randomly
				match randi() % 2:
					0:
						element_matrix[x][y] = Tile.STRAIGHT
						mesh_instance = TILE_STRAIGHT_PACKED_SCENE.instantiate()
					1:
						element_matrix[x][y] = Tile.ELBOW
						mesh_instance = TILE_ELBOW_PACKED_SCENE.instantiate()

			$Tiles.add_child(mesh_instance)

			node_matrix[x][y] = mesh_instance
			rotation_matrix[x][y] = randi() % 4

			# TODO: Support for even tiles
			mesh_instance.transform.origin.x = (float(x) - grid_center_offset_x) * tile_size
			mesh_instance.transform.origin.y = (float(y) - grid_center_offset_y) * tile_size
			mesh_instance.transform.origin.z = 0.1
			mesh_instance.rotation.z = rotation_matrix[x][y] * PI/2.0


func rotate_offset(offset: Vector2i, times: int) -> Vector2i:
	times = times % 4
	match times:
		0:
			return offset
		1:
			return Vector2i(-offset.y, offset.x)
		2:
			return -offset
		3:
			return Vector2i(offset.y, -offset.x)
		_:
			return offset


func check_solved():
	var head = start
	var prev_head = start

	var count: int = 0

	# TODO: Bug, if the path loops back to the start, the algorithm loops indefinitely
	# TODO: at the end, check if the end tile is rotated properly
	# Alternatively, lock the orientations of the start and end tiles
	while head != end:
		# Bounds check
		if (
			head.x < 0 or
			head.x > size.x - 1 or
			head.y < 0 or
			head.y > size.y - 1
		):
			print("Broke: Out of bounds")
			return false # Return false if out of bounds
		
		var element = element_matrix[head.x][head.y]
		var tile_rotation = rotation_matrix[head.x][head.y]
		var offsets

		match element:
			Tile.CAP:
				offsets = [Vector2i(0, 1)]
			Tile.STRAIGHT:
				offsets = [Vector2i(0, 1), Vector2i(0, -1)]
			Tile.ELBOW:
				offsets = [Vector2i(0, 1), Vector2i(1, 0)]
			_:
				print("Broke: Unknown tile type at (%d, %d)" % [head.x, head.y])
				return false

		var neighbors = []
		for offset in offsets:
			neighbors.append(head + rotate_offset(offset, tile_rotation))

		# Bug occurs here, usually taken care of by the second condition but the
		# Start exception causes it to loop back around
		# The start exception is needed because there is no prev_head in neighbors initially

		# Tile is not connected properly
		if head != start and prev_head not in neighbors:
			print("Broke: Tile not connected or dead end at (%d, %d)" % [head.x, head.y])
			return false # Return false if tile is not connected or dead end
		
		# Erase other end
		neighbors.erase(prev_head)
		
		# Make the other end the new head
		prev_head = head
		head = neighbors[0]
		
		$Cursor.transform.origin.x = (float(prev_head.x) - grid_center_offset_x) * tile_size
		$Cursor.transform.origin.y = (float(prev_head.y) - grid_center_offset_y) * tile_size
		$Cursor.transform.origin.z = 0.2
		
		count += 1
		if count > 100:
			print("Broke: Looped indefinitely or too long")
			return false # Return false if loop count exceeds limit
	
	print("Reached end successfully!")
	return true # Return true if the loop completes (head == end)


func _physics_process(_delta: float) -> void:
	# Only check when the player is interacting with the breaker
	if not is_interacting:
		return

	if Input.is_action_just_pressed("interact_primary"):
		# Get the cursor position in local world space relative to breaker
		var screen_point = get_viewport().get_mouse_position()
		var global_cursor_position = get_viewport().get_camera_3d().project_position(screen_point, 1.0 - 0.15)
		var local_cursor_position = global_transform.inverse() * global_cursor_position

		# Quantize cursor positions
		var x = roundi((local_cursor_position.x / tile_size) + grid_center_offset_x)
		var y = roundi((local_cursor_position.y / tile_size) + grid_center_offset_y)
		
		# Check if cursor is in bounds
		if x < 0 or x >= size.x or y < 0 or y >= size.y:
			return
		
		# Increment rotation
		rotation_matrix[x][y] += 1
		rotation_matrix[x][y] = rotation_matrix[x][y] % 4
		
		# Convert to radians
		var target_rotation = rotation_matrix[x][y] * PI/2.0
		
		# Tween tile
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_pause_mode(Tween.TWEEN_PAUSE_STOP)
		tween.tween_property(node_matrix[x][y], "rotation:z", target_rotation, 0.5)

		# Check solved
		is_solved = check_solved()
		state_changed.emit(is_solved)


func _on_interact_trigger_interacted(player: Player) -> void:
	is_interacting = !is_interacting
	if is_interacting:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		GameState.player.release_camera($Marker3D.global_transform, 45.0)
		#GameState.player.viewmodel_controller.set_holstered(true)
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		GameState.player.bind_camera()
		#GameState.player.viewmodel_controller.set_holstered(false)
