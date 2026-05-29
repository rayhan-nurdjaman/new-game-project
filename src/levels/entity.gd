extends CharacterBody3D

var movement_speed: float = 1.0
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
var can_move: bool = true

var dev_lock: bool = true

func _ready() -> void:
	$VisibleOnScreenNotifier3D.screen_entered.connect(_on_visible_on_screen_notifier_3d_screen_entered)
	$VisibleOnScreenNotifier3D.screen_exited.connect(_on_visible_on_screen_notifier_3d_screen_exited)


func _physics_process(delta: float) -> void:
	if dev_lock:
		return
	
	var position_delta: Vector3 = GameState.player.global_transform.origin - global_transform.origin
	var distance_check: bool = position_delta.length() > 10.0
	print(distance_check)
	if (can_move or distance_check) and GameState.player:
		var movement_target_position = GameState.player.global_transform.origin
		navigation_agent.set_target_position(movement_target_position)
		if navigation_agent.is_navigation_finished():
			return
		var current_agent_position: Vector3 = global_transform.origin
		var next_path_position: Vector3 = navigation_agent.get_next_path_position()
		
		velocity = current_agent_position.direction_to(next_path_position) * movement_speed
		move_and_slide()


func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	can_move = false


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	can_move = true
