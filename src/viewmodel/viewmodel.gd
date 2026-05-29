extends Node3D

const BOB_AMPLITUDE_Y: float = 0.010
const BOB_AMPLITUDE_X: float = 0.010
const KP: float = 8.0
const KI: float = 0.0
const KD: float = 0.5

var offset: Vector2 = Vector2.ZERO
var integral: Vector2 = Vector2.ZERO
var prev_error: Vector2 = Vector2.ZERO

@export var player: Player

var viewmodel_bob_phase: float = 0.0

@onready var model = $PSX_First_Person_Arms
@onready var viewmodel_initial_transform: Transform3D = model.transform
@onready var viewmodel_height = viewmodel_initial_transform.origin.y

var left_punch: bool = false
var right_punch: bool = false
var step_size: float = 0.5

func _physics_process(delta: float) -> void:
	# Calculate current offset from looking
	# This helps to reduce the "floaty" feeling when looking around
	# Makes the gun look like it weighs
	var error: Vector2 = -offset
	integral += error * delta
	var derivative
	if is_zero_approx(delta):
		derivative = Vector2.ZERO
	else:
		derivative = (error - prev_error) / delta
	prev_error = error

	# TODO: Offset sometimes becomes nan, figure out why
	offset += (KP * error + KI * integral + KD * derivative) * delta

	# Bob the viewmodel while moving
	var player_projected_velocity = Plane.PLANE_XZ.project(player.linear_velocity).length()
	var prev_phase = viewmodel_bob_phase

	if player.is_on_floor:
		viewmodel_bob_phase += player_projected_velocity / step_size * delta * PI 
		var crossed_threshold = floor(viewmodel_bob_phase / PI) > floor(prev_phase / PI)
		if crossed_threshold:
			$"../../../AudioStreamPlayer3D".pitch_scale = randf_range(0.8, 1.2)
			$"../../../AudioStreamPlayer3D".play()

	var sine: float = sin(viewmodel_bob_phase)
	var cosine: float = cos(viewmodel_bob_phase)
	model.transform.origin.y = (
		viewmodel_height + BOB_AMPLITUDE_Y * sine * cosine + offset.y
	)
	model.transform.origin.x = (
		viewmodel_initial_transform.origin.x + BOB_AMPLITUDE_X * sine + offset.x
	)
	
	var state_machine = $AnimationTree["parameters/playback"]
	if Input.is_action_just_pressed("interact_primary"):
		state_machine.travel("Combat_punch_left")
	if Input.is_action_just_pressed("interact_secondary"):
		state_machine.travel("Combat_punch_right")
	#if Input.is_action_just_pressed("interact_use"):
		#state_machine.travel("Collect_something")
