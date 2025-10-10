extends Node3D

enum State { IDLE, SPEW_POSITIVE, SPEW_NEGATIVE }

const BOB_SPEED: float = 1.2
const BOB_AMPLITUDE_Y: float = 0.020
const BOB_AMPLITUDE_X: float = 0.020
const KP: float = 8.0
const KI: float = 4.0
const KD: float = 0.5
const POSITIVE_CHARGE_COLOR: Color = Color(1.0, 0.247, 0.0)
const NEGATIVE_CHARGE_COLOR: Color = Color(0.0, 0.749, 1.0)

@export var player: Player
@export var camera: Camera3D
@export var viewmodel: Node3D

var state: State = State.IDLE
var viewmodel_bob_phase: float = 0.0
var offset: Vector2 = Vector2.ZERO
var integral: Vector2 = Vector2.ZERO
var prev_error: Vector2 = Vector2.ZERO

@onready var viewmodel_initial_transform: Transform3D = viewmodel.transform


func _physics_process(delta: float) -> void:
	# Calculate current offset from looking
	# This helps to reduce the "floaty" feeling when looking around
	# Makes the gun look like it weighs
	var error: Vector2 = -offset
	integral += error * delta
	var derivative = (error - prev_error) / delta
	prev_error = error

	offset += (KP * error + KI * integral + KD * derivative) * delta

	# Bob the viewmodel while moving
	var player_projected_velocity = Plane.PLANE_XZ.project(player.velocity).length()
	viewmodel_bob_phase += player_projected_velocity * BOB_SPEED * delta

	var sine: float = sin(viewmodel_bob_phase)
	var cosine: float = cos(viewmodel_bob_phase)

	viewmodel.transform.origin.y = (
		viewmodel_initial_transform.origin.y + BOB_AMPLITUDE_Y * sine * cosine + offset.y
	)
	viewmodel.transform.origin.x = (
		viewmodel_initial_transform.origin.x + BOB_AMPLITUDE_X * sine + offset.x
	)
	
	get_parent().transform.origin.y = 1.5 + 0.1 * abs(sine) * abs(cosine)
