class_name Controller

extends Node


signal crouch(value: bool)
signal interact(value: bool)
signal primary(value: bool)
signal secondary(value: bool)


const SENS: float = 20.8 / 2.0
const DPI: float = 1000


var move_direction: Vector3 = Vector3.ZERO
var request_jump: bool = false
var is_sprinting: bool = false
var is_crouching: bool = false
var crouching_changed: bool = false
var is_interacting: bool = false
var interacting_changed: bool = false
var interact_primary: bool = false
var primary_changed: bool = false
var interact_secondary: bool = false
var secondary_changed: bool = false

var camera_azimuth: float = 0.0
var camera_altitude: float = 0.0

var queued_rotation: Quaternion = Quaternion.IDENTITY


func px_to_rad(pixels: float) -> float:
	return pixels / (DPI / 2.54) / SENS * PI * 2.0



func _unhandled_input(event: InputEvent) -> void:
	if GameState.state == GameState.State.PAUSED:
		return

	if event is InputEventMouseMotion:
		#if Input.is_action_pressed("interact_secondary"):
			#var new_basis := Basis.IDENTITY
			##new_basis = new_basis.rotated(camera.transform.basis.x, px_to_rad(event.relative.y))
			##new_basis = new_basis.rotated(camera.transform.basis.y, px_to_rad(event.relative.x))
			##held_object_original_orientation = new_basis.get_rotation_quaternion() * held_object_original_orientation
		#else:
			var vertical_input = -px_to_rad(event.relative.y)
			var horizontal_input = -px_to_rad(event.relative.x)
			
			camera_altitude = clamp(camera_altitude + vertical_input, -PI / 2, PI / 2)
			camera_azimuth = fmod(camera_azimuth + horizontal_input, 2.0*PI)


# TODO: Maybe try to put everything inside unhandled input? idk if thats better;
func _physics_process(_delta: float) -> void:
	var input_forward: float = (
		Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	)
	var input_right: float = (
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	)
	
	move_direction = (
		Vector3.FORWARD * input_forward
		 + Vector3.RIGHT * input_right
	).normalized()

	is_sprinting = Input.is_action_pressed("move_sprint")
	
	if Input.is_action_just_pressed("move_jump"):
		request_jump = true
	elif Input.is_action_just_released("move_jump"):
		request_jump = false
	
	if Input.is_action_just_pressed("move_crouch"):
		crouch.emit(true)
	if Input.is_action_just_released("move_crouch"):
		crouch.emit(false)
	
	if Input.is_action_just_pressed("interact_use"):
		interact.emit(true)
	elif Input.is_action_just_released("interact_use"):
		interact.emit(false)
			
	if Input.is_action_just_pressed("interact_primary"):
		primary.emit(true)
	elif Input.is_action_just_released("interact_primary"):
		primary.emit(false)
	
	if Input.is_action_just_pressed("interact_secondary"):
		secondary.emit(true)
	elif Input.is_action_just_released("interact_secondary"):
		secondary.emit(false)
