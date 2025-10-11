class_name Player

extends RigidBody3D

#TODO: Apply opposite force to the player
#TODO: Have proper force thing when jumping off of rigidbodies
#TODO: Have stair movement using test_move

# Physical movement constants
const ACCEL_GROUND: float = 20.0
const ACCEL_AIR: float = 10.0
const SPEED_GROUND: float = 4.0
const SPEED_AIR: float = 1.0
const FRICTION: float = 1.0
const JUMP_HEIGHT: float = 1.2

# Object pickup constants
const PICKUP_DISTANCE: float = 2.0
# PID constants for object pickup
const PICKUP_TRANSLATE_KP: float = 1000.0
const PICKUP_TRANSLATE_KI: float = 0.0
const PICKUP_TRANSLATE_KD: float = 100.0
# PID constants for object pickup
const PICKUP_ROTATE_KP: float = 200.0
const PICKUP_ROTATE_KI: float = 0.0
const PICKUP_ROTATE_KD: float = 10.0

# Throw constants
const THROW_CHARGE_RATE: float = 2.0  # How fast the throw charges
const THROW_MIN_FORCE: float = 0.0  # Minimum throw force
const THROW_MAX_FORCE: float = 10.0  # Maximum throw force

# Node references
@export var camera: Camera3D
@export var raycast: RayCast3D
@export var viewmodel_controller: Node3D

# Object pickup variables
var held_object: RigidBody3D = null
var pickup_translation_integral: Vector3 = Vector3.ZERO
var pickup_angular_integral: Vector3 = Vector3.ZERO
var apply_reaction_force: bool = false

# Throw state
var throw_charging: bool = false
var throw_charge: float = 0.0

var looking_at_object: Node3D

var held_object_original_layer: int = 0
var held_object_original_mask: int = 0
var held_object_original_orientation: Quaternion = Quaternion.IDENTITY

# Physics variables
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready
var gravity_vector: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
@onready var jump_impulse: float = sqrt(2.0 * JUMP_HEIGHT * gravity)
#@onready var jump_energy: float = mass * gravity * JUMP_HEIGHT

var move_direction: Vector3 = Vector3.ZERO

func px_to_rad(pixels: float) -> float:
	const SENS: float = 20.8 / 2.0
	const DPI: float = 1000
	return pixels / (DPI / 2.54) / SENS * PI * 2.0


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("interact_secondary"):
			var new_basis := Basis.IDENTITY
			new_basis = new_basis.rotated(camera.transform.basis.x, px_to_rad(event.relative.y))
			new_basis = new_basis.rotated(camera.transform.basis.y, px_to_rad(event.relative.x))
			held_object_original_orientation = new_basis.get_rotation_quaternion() * held_object_original_orientation
		else:
			var vertical_input = -px_to_rad(event.relative.y)
			var current_rotation = asin(camera.transform.basis.y.z)
			var new_rotation = clamp(current_rotation + vertical_input, -PI / 2, PI / 2)
			var delta_rot = new_rotation - current_rotation
			camera.rotate(camera.transform.basis.x, delta_rot)

			$Node3D.rotate(Vector3.UP, -px_to_rad(event.relative.x))

			viewmodel_controller.offset += (Vector2(-event.relative.x, event.relative.y) / 8192.0)

	if event.is_action_pressed("interact_use"):
		if held_object:
			throw_charging = true
		elif raycast.is_colliding():
			var collider = raycast.get_collider()
			if collider is RigidBody3D:
				pickup_object(raycast.get_collider() as RigidBody3D)
			#elif collider is InteractTrigger:
				#collider.interact(self)

	elif event.is_action_released("interact_use"):
		if throw_charging:
			throw_object()
			throw_charging = false
			throw_charge = 0.0


func pickup_object(object: RigidBody3D) -> void:
	held_object = object

	held_object_original_layer = held_object.collision_layer
	held_object_original_mask = held_object.collision_mask
	held_object_original_orientation = camera.global_transform.basis.inverse().get_rotation_quaternion() * object.global_transform.basis.get_rotation_quaternion()

	#var held_layer = 10
	#var player_layer = 2

	## Put held object on its own layer (not 1 or 3, which player watches)
	#held_object.collision_layer = 1 << (held_layer - 1)

	## Collide with everything EXCEPT player, and at least include held_layer
	#held_object.collision_mask &= ~(1 << (player_layer - 1))

	pickup_translation_integral = Vector3.ZERO
	pickup_angular_integral = Vector3.ZERO


# TODO: Add initial deadzone so the object isnt thrown
func throw_object() -> void:
	if held_object:
		held_object.collision_layer = held_object_original_layer
		held_object.collision_mask = held_object_original_mask
		var throw_force: float = lerp(THROW_MIN_FORCE, THROW_MAX_FORCE, throw_charge)
		var throw_direction: Vector3 = -camera.global_transform.basis.z
		held_object.apply_central_impulse(throw_direction * throw_force)
		held_object = null
		
		pickup_translation_integral = Vector3.ZERO
		pickup_angular_integral = Vector3.ZERO


func get_move_direction() -> Vector3:
	var basis_z: Vector3 = -$Node3D.get_transform().basis.z  # Negative Z axis is forward
	var basis_x: Vector3 = $Node3D.get_transform().basis.x
	var input_forward: float = (
		Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	)
	var input_right: float = (
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	)

	var move_direction: Vector3 = basis_z * input_forward + basis_x * input_right

	return move_direction.normalized()


#func move(move_direction: Vector3, delta: float) -> void:
	#if is_on_floor():
		#var accel_friction: Vector3 = (
			#gravity * FRICTION * Plane.PLANE_XZ.project(-velocity.normalized())
		#)
		#velocity += (
			#accel_friction.normalized() * min(accel_friction.length() * delta, velocity.length())
		#)
#
	#var speed: float
	#var accel: float
	#if is_on_floor():
		#speed = SPEED_GROUND
		#accel = ACCEL_GROUND
	#else:
		#speed = SPEED_AIR
		#accel = ACCEL_AIR
#
	#var accel_move: Vector3 = accel * move_direction
	#var speed_target: float = move_direction.length() * speed
	#var speed_projection: float = velocity.dot(accel_move.normalized())
#
	#velocity += (
		#accel_move.normalized()
		#* min(accel_move.length() * delta, max(speed_target - speed_projection, 0.0))
	#)
#
	#if not is_on_floor():
		#velocity += gravity * gravity_vector * delta
	#elif Input.is_action_just_pressed("move_jump"):  # Is on floor
		#velocity += -gravity_vector * jump_impulse


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var is_on_floor: bool = false
	var count: int = state.get_contact_count()
	var max_cosine: float = cos(PI/4.0)
	var rigidbody_floor: RigidBody3D = null
	var normal: Vector3 = Vector3.ZERO
	
	print(state.linear_velocity.length())
	
	for contact_id in range(count):
		normal = state.get_contact_local_normal(contact_id)
		if normal.dot(Vector3.UP) >= max_cosine:
			is_on_floor = true
			var collider: Object = state.get_contact_collider_object(contact_id)
			if collider is RigidBody3D:
				rigidbody_floor = collider
			break
	
	if is_on_floor:
		var accel_friction: Vector3 = (
			gravity * FRICTION * Plane.PLANE_XZ.project(-(linear_velocity - max(linear_velocity.dot(move_direction), 0.0) * move_direction.normalized()).normalized())
		)
		# Negate friction in direction of movement
		state.apply_central_force(
			mass * accel_friction.normalized() * min(accel_friction.length(), linear_velocity.length() / state.step)
		)
	
	var speed: float
	var accel: float
	if is_on_floor:
		speed = SPEED_GROUND
		accel = ACCEL_GROUND
	else:
		speed = SPEED_AIR
		accel = ACCEL_AIR
	
	var rotation_axis: Vector3 = normal.cross(Vector3.UP)
	var angle: float = normal.signed_angle_to(Vector3.UP, rotation_axis.normalized())
	var rotated_move_direction: Vector3
	
	if is_zero_approx(angle) or rotation_axis.is_zero_approx():
		rotated_move_direction = move_direction
	else: # On slope
		rotated_move_direction = move_direction.rotated(rotation_axis.normalized(), -angle)
		#TODO: Second conditional might not be needed
		if is_on_floor and not is_zero_approx(normal.dot(Vector3.UP)):
			var slope_compensation_force: Vector3 = -normal
			#TODO: Only works during steady state, doesn't push back hard enough during impacted falls
			var scale_factor = mass * gravity / normal.dot(Vector3.UP)
			slope_compensation_force *= scale_factor
			# Negate vertical component
			slope_compensation_force -= slope_compensation_force.dot(Vector3.UP) * Vector3.UP
			state.apply_force(slope_compensation_force)
	
	var accel_move: Vector3 = accel * rotated_move_direction
	var speed_target: float = rotated_move_direction.length() * speed
	var speed_projection: float = linear_velocity.dot(rotated_move_direction)
	
	state.apply_central_force(accel_move.normalized() * mass * min(accel_move.length(), max(speed_target - speed_projection, 0.0) / state.step))

	#TODO: Custom integrator, implicit euler for now

	#TODO:
	if is_on_floor and Input.is_action_pressed("move_jump"):
		var epsilon = 0.05
		state.apply_central_impulse(-gravity_vector * mass * jump_impulse)
		state.transform.origin.y += epsilon

func update_held_object(delta: float) -> void:
	if held_object:
		held_object.freeze = false
		# Calculate target position in front of camera
		var clamped_camera_basis: Basis = Basis.IDENTITY
		clamped_camera_basis = clamped_camera_basis.rotated(Vector3.RIGHT, clamp(camera.rotation.x, -PI/2.0 + 60.0/180.0*PI, PI/2.0))
		clamped_camera_basis = $Node3D.global_transform.basis * clamped_camera_basis
		var target_pos: Vector3 = (
			camera.global_position - clamped_camera_basis.z * PICKUP_DISTANCE
		)
		
		# Translation PID
		var translation_error: Vector3 = target_pos - held_object.global_position
		pickup_translation_integral += translation_error * delta
		var translation_derivative: Vector3 = -held_object.linear_velocity

		var force: Vector3 = (
			translation_error * PICKUP_TRANSLATE_KP + pickup_translation_integral * PICKUP_TRANSLATE_KI + translation_derivative * PICKUP_TRANSLATE_KD
		)

		held_object.apply_central_force(force)
		apply_central_force(-force)
		
		# Angular PID
		var current_quat: Quaternion = held_object.global_transform.basis.get_rotation_quaternion()
		var target_quat: Quaternion = clamped_camera_basis.get_rotation_quaternion() * held_object_original_orientation

		var error_quat: Quaternion = target_quat * current_quat.inverse()
		error_quat = error_quat.normalized()
		if error_quat.w < 0:
			error_quat = -error_quat
		var angle = error_quat.get_angle()
		var error_angle_axis: Vector3 = error_quat.get_axis() * angle
		pickup_angular_integral += error_angle_axis * delta
		var derivative_angular: Vector3 = -held_object.angular_velocity

		var torque: Vector3 = (
			error_angle_axis * PICKUP_ROTATE_KP + pickup_angular_integral * PICKUP_ROTATE_KI + derivative_angular * PICKUP_ROTATE_KD
		)
		
		held_object.apply_torque(torque)


func _physics_process(delta: float) -> void:
	move_direction = get_move_direction()
	update_held_object(delta)
	
	var new_basis := Basis.IDENTITY
	var angle = float(Input.is_action_just_released("scroll_down")) - float(Input.is_action_just_released("scroll_up"))
	angle = 0.2 * angle
	new_basis = new_basis.rotated(camera.transform.basis.z, angle)
	held_object_original_orientation = new_basis.get_rotation_quaternion() * held_object_original_orientation

	looking_at_object = held_object if held_object else raycast.get_collider()

	# Update throw charge
	if throw_charging:
		throw_charge = min(throw_charge + THROW_CHARGE_RATE * delta, 1.0)

#void GodotBody3D::integrate_forces(real_t p_step) {
#
#void GodotBody3D::integrate_velocities(real_t p_step) {
