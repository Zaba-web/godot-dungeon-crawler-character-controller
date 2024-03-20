extends AbstractModule

const DIRECTION_FORWARD = -1
const DIRECTION_BACK = 1

# Grid cell size
@export var cell_size: float = 2

# Movement speed
@export var movement_speed: float = 5

# Maximum commands that can be queued
@export var max_queued_commands: int = 2

# Turn speed
@export var turn_speed: float = .3

# Action names definition in advance
@export var move_forward_action_name: String = "move_forward"
@export var move_back_action_name: String = "move_back"
@export var turn_left_action_name: String = "turn_left"
@export var turn_right_action_name: String = "turn_right"

# Queue of movement commands
var commands_queue: Array

# Player destination position
var movement_target: Vector3

# Rotation destination value
var rotation_target: float = 0

# Determinates direction of player movement
var movement_direction: int = 0;

# List of movement commands
enum Commands {
	MOVE_FORWARD,
	MOVE_BACK,
	TURN_LEFT,
	TURN_RIGHT,
	STRAFE_LEFT,
	STRAFE_RIGHT
}

func _ready():
	super()
	allowed_state = [State.List.IDDLE, State.List.MOVING, State.List.TURNING]

# Handle player movement
func __physics_process(delta: float, player: AbstractCharacter) -> void:
	if movement_target == Vector3.ZERO:
		movement_target = player.position
	
	if player.rotation_speed == 0:
		player.rotation_speed = turn_speed
	
	if not _is_current_state_allowed(player.get_state()):
		return

	if Input.is_action_just_pressed(move_forward_action_name):
		_add_command(Commands.MOVE_FORWARD)
		
	if Input.is_action_just_pressed(move_back_action_name):
		_add_command(Commands.MOVE_BACK)
		
	if Input.is_action_just_pressed(turn_right_action_name):
		_add_command(Commands.TURN_RIGHT)
		
	if Input.is_action_just_pressed(turn_left_action_name):
		_add_command(Commands.TURN_LEFT)
		
	_process_movement(delta, player)
	
# Process movement
func _process_movement(delta: float, player: AbstractCharacter) -> void:
	
	# Set of movement actions for target position/rotation transformation
	var movement_actions = {
		Commands.MOVE_FORWARD: _move_forward,
		Commands.MOVE_BACK: _move_back,
		Commands.TURN_LEFT: _turn_left,
		Commands.TURN_RIGHT: _turn_right
	}
	
	# Get next command from queqe after previous is completed
	if player.get_state() == State.List.IDDLE && commands_queue.size() > 0:
		var command = commands_queue.pop_front()
		movement_actions[command].call(player)


# Add command in queue
func _add_command(command: Commands) -> void:
	if commands_queue.size() > max_queued_commands:
		return
	
	commands_queue.push_back(command)

# Handle move forward command
func _move_forward(player: AbstractCharacter) -> void:
	movement_direction = DIRECTION_FORWARD
	_set_movement_target(player)
	print(movement_target)

# Handle move back commandw
func _move_back(player: AbstractCharacter) -> void:
	movement_direction = DIRECTION_BACK
	_set_movement_target(player)

# Handle turn left command
func _turn_left(player: AbstractCharacter) -> void: 
	rotation_target += 1
	player.rotation_target = deg_to_rad(rotation_target * 90)

# Handle turn right command
func _turn_right(player: AbstractCharacter) -> void:
	rotation_target -= 1
	player.rotation_target = deg_to_rad(rotation_target * 90)

# Set player movement target 
func _set_movement_target(player: AbstractCharacter) -> void:
	pass #to implement
