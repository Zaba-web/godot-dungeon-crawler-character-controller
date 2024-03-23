extends AbstractModule

const DIRECTION_FORWARD = -1
const DIRECTION_BACK = 1

## Grid cell size
@export var cell_size: float = 2

## Movement speed
@export var movement_speed: float = 8

## Maximum commands that can be queued
@export var max_queued_commands: int = 2

## Turn speed
@export var turn_speed: float = .2

## During this time span input will be disabled before next command could be processed
@export var input_cd_timeout_s: float = .2

## Action names definition (move forward)
@export var move_forward_action_name: String = "move_forward"
## Action names definition (move back)
@export var move_back_action_name: String = "move_back"
## Action names definition (turn left)
@export var turn_left_action_name: String = "turn_left"
## Action names definition (turn right)
@export var turn_right_action_name: String = "turn_right"
## Action names definition (stafe left)
@export var strafe_left_action_name: String = "strafe_left"
## Action names definition (starfe right)
@export var strafe_right_action_name: String = "strafe_right"

## Size of player collider, needed for movement possibility check
@export var player_collider_size = .4

# Queue of movement commands
var commands_queue: Array

# Player destination position
var movement_target: Vector3

# Rotation destination value
var rotation_target: float = 0

# Determinates direction of player movement
var movement_direction: Vector3 = Vector3.ZERO;

var cd_active = false

# List of movement commands
enum Commands {
	MOVE_FORWARD,
	MOVE_BACK,
	TURN_LEFT,
	TURN_RIGHT,
	STRAFE_LEFT,
	STRAFE_RIGHT
}

# List of movement directions
enum Directions {
	FORWARD,
	LEFT,
	BACK,
	RIGHT
}

# Map look direction to the move direction
var look_direction_to_move_direction = {
	"0":  Directions.FORWARD,
	"1":  Directions.LEFT,
	"2":  Directions.BACK,
	"-1": Directions.RIGHT,
	"-2": Directions.BACK,
	"3":  Directions.RIGHT,
	"-3": Directions.LEFT
}

# Timer that is used for input cooldown
var commands_cd_timer: Timer

func _ready():
	super()
	commands_cd_timer = Timer.new()
	commands_cd_timer.wait_time = input_cd_timeout_s
	add_child.call_deferred(commands_cd_timer)
	allowed_state = [State.List.IDDLE, State.List.MOVING, State.List.TURNING]
	commands_cd_timer.timeout.connect(_reset_cd_timer)

# Handle player movement
func __physics_process(_delta: float, player: AbstractCharacter) -> void:

	if movement_target == Vector3.ZERO:
		movement_target = player.position
	
	if player.rotation_speed == 0:
		player.rotation_speed = turn_speed
	
	if not _is_current_state_allowed(player.get_state()):
		return

	_process_hold_input()
		
	_process_movement(player)
	
# Process movement
func _process_movement(player: AbstractCharacter) -> void:
	# Set of movement actions for target position/rotation transformation
	var movement_actions = {
		Commands.MOVE_FORWARD: _move_forward,
		Commands.MOVE_BACK: _move_back,
		Commands.TURN_LEFT: _turn_left,
		Commands.TURN_RIGHT: _turn_right,
		Commands.STRAFE_RIGHT: _strafe_right,
		Commands.STRAFE_LEFT: _strafe_left
	}
	
	# Get next command from queqe after previous is completed
	if player.get_state() == State.List.IDDLE && commands_queue.size() > 0:
		var command = commands_queue.pop_front()
		movement_actions[command].call(player)
	
	if _is_arrived(player):
		movement_direction = Vector3.ZERO

	player.velocity = movement_direction

# Add command in queue
func _add_command(command: Commands) -> void:
	if commands_queue.size() > max_queued_commands:
		return
	
	commands_queue.push_back(command)

# Handle move forward command
func _move_forward(player: AbstractCharacter) -> void:
	_set_movement_target(player, 1)

# Handle move back commandw
func _move_back(player: AbstractCharacter) -> void:
	_set_movement_target(player, -1)

# Handle movement in left side
func _strafe_left(player: AbstractCharacter) -> void:
	# Here we calculate in which absolute direction player should move to make a strafe
	var strafe_direction = look_direction_to_move_direction[str(rotation_target)] + 1
	# Direction overflow logic
	if strafe_direction > Directions.RIGHT:
		strafe_direction = Directions.FORWARD
	
	_set_movement_target(player, 1, strafe_direction)

# Handle movement in right side
func _strafe_right(player: AbstractCharacter) -> void:
	# Here we calculate in which absolute direction player should move to make a strafe
	var strafe_direction = look_direction_to_move_direction[str(rotation_target)] - 1
	# Direction overflow logic
	if strafe_direction < Directions.FORWARD:
		strafe_direction = Directions.RIGHT
	
	_set_movement_target(player, 1, strafe_direction)

# Handle turn left command
func _turn_left(player: AbstractCharacter) -> void: 
	rotation_target += 1
	if rotation_target == 4 : rotation_target = 0
	player.rotation_target = deg_to_rad(rotation_target * 90)

# Handle turn right command
func _turn_right(player: AbstractCharacter) -> void:
	rotation_target -= 1
	if rotation_target == -4 : rotation_target = 0
	player.rotation_target = deg_to_rad(rotation_target * 90)

# Set player movement target 
func _set_movement_target(player: AbstractCharacter, direction_mul: int, direction = null) -> void:
	if direction == null:
		direction = look_direction_to_move_direction[str(rotation_target)]
	
	var potential_target = movement_target
	
	match direction:
		Directions.FORWARD:
			potential_target.z -= cell_size * direction_mul
			if not _can_move(player, potential_target):
				return
			
			movement_target.z -= cell_size * direction_mul
			movement_direction = Vector3(0, 0, -movement_speed * direction_mul)
		Directions.BACK:
			potential_target.z += cell_size * direction_mul
			if not _can_move(player, potential_target):
				return
			
			movement_target.z += cell_size * direction_mul
			movement_direction = Vector3(0, 0, movement_speed * direction_mul)
		Directions.LEFT:
			potential_target.x -= cell_size * direction_mul
			if not _can_move(player, potential_target):
				return
			
			movement_target.x -= cell_size * direction_mul
			movement_direction = Vector3(-movement_speed * direction_mul, 0, 0)
		Directions.RIGHT:
			potential_target.x += cell_size * direction_mul
			if not _can_move(player, potential_target):
				return
			
			movement_target.x += cell_size * direction_mul
			movement_direction = Vector3(movement_speed * direction_mul, 0, 0)

# Check if played reached destination
func _is_arrived(player: AbstractCharacter) -> bool:
	return abs(player.global_position.x - movement_target.x) <= 0.001 && abs(player.global_position.z - movement_target.z) <= 0.001

# Check if can move in the direction
func _can_move(player: AbstractCharacter, movement_target: Vector3) -> bool:
	var from = player.global_position
	
	var query = PhysicsRayQueryParameters3D.create(from, movement_target)
	var space_state = player.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)

	if result.has("collider"):
		return false

	return true

# Process hold input
func _process_hold_input() -> void:
	# Need this to be able queqe commands
	
	if Input.is_action_just_pressed(turn_right_action_name):
		_add_command(Commands.TURN_RIGHT)
		_set_input_cd(Commands.TURN_RIGHT)
		
	if Input.is_action_just_pressed(turn_left_action_name):
		_add_command(Commands.TURN_LEFT)
		_set_input_cd(Commands.TURN_LEFT)
	
	if Input.is_action_just_pressed(move_forward_action_name):
		_add_command(Commands.MOVE_FORWARD)
		_set_input_cd()
		
	if Input.is_action_just_pressed(move_back_action_name):
		_add_command(Commands.MOVE_BACK)
		_set_input_cd()
	
	if Input.is_action_just_pressed(strafe_left_action_name):
		_add_command(Commands.STRAFE_LEFT)
		_set_input_cd()
		
	if Input.is_action_just_pressed(strafe_right_action_name):
		_add_command(Commands.STRAFE_RIGHT)
		_set_input_cd()
	
	if cd_active || commands_queue.size() > 0:
		return
	
	if Input.is_action_pressed(move_forward_action_name):
		_add_command(Commands.MOVE_FORWARD)
		_set_input_cd()
		
	if Input.is_action_pressed(move_back_action_name):
		_add_command(Commands.MOVE_BACK)
		_set_input_cd()
		
	if Input.is_action_pressed(turn_right_action_name):
		_add_command(Commands.TURN_RIGHT)
		_set_input_cd(Commands.TURN_RIGHT)
		
	if Input.is_action_pressed(turn_left_action_name):
		_add_command(Commands.TURN_LEFT)
		_set_input_cd(Commands.TURN_LEFT)
		
	if Input.is_action_pressed(strafe_left_action_name):
		_add_command(Commands.STRAFE_LEFT)
		_set_input_cd()
		
	if Input.is_action_pressed(strafe_right_action_name):
		_add_command(Commands.STRAFE_RIGHT)
		_set_input_cd()

# Set input cooldown
func _set_input_cd(command: Variant = null) -> void:
	var timeout_real_value = input_cd_timeout_s
	
	# Timeout should be higher for turning (for gamepads)
	if command != null && (command == Commands.TURN_RIGHT || command == Commands.TURN_LEFT):
		timeout_real_value *= 2.5
	
	commands_cd_timer.stop()
	commands_cd_timer.wait_time = timeout_real_value
	commands_cd_timer.start()
	cd_active = true

# Reset input cooldown timer
func _reset_cd_timer() -> void:
	commands_cd_timer.stop()
	cd_active = false
