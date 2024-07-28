extends AbstractModule

## Grid cell size
@export var cell_size: float = 2

## Movement speed
@export var movement_speed: float = .3

## Maximum commands that can be queued
@export var max_queued_commands: int = 2

## Turn speed
@export var turn_speed: float = .2

## During this time span input will be disabled before next command could be processed
@export var input_cd_timeout_s: float = .3

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

# Map actions to comman classes
var movement_action_list = {
	move_forward_action_name: MoveForwardCommand,
	move_back_action_name: MoveBackCommand,
	turn_left_action_name: TurnLeftCommand,
	turn_right_action_name: TurnRightCommand,
	strafe_left_action_name: MoveLeftCommand,
	strafe_right_action_name: MoveRightCommand
}

# Queue of movement commands
var commands_queue: Array

# Determinates direction of player movement
var movement_direction: Vector3 = Vector3.ZERO;

# Is movement module busy
var busy = false

# Is input currently disabled
var input_blocked = false

# Default
func _ready():
	super()

# Handle player movement
func __physics_process(_delta: float, player: AbstractCharacter) -> void:
	_process_input(player)
	_process_movement(player)

# Handle all inputs from player and schedule commands base on that
func _process_input(player: AbstractCharacter) -> void:
	var command = _get_movement_command();
		
	if command != null && commands_queue.size() < max_queued_commands:
		command.set_context({"cell_size": cell_size, "movement_speed": movement_speed, "callback": _action_finished})
		commands_queue.push_back(command)

# Execute commands
func _process_movement(player) -> void:
	if commands_queue.size() == 0:
		return
	
	if !busy:
		var command = commands_queue.pop_front()
		busy = true
		command.execute(player)

# Mark movement action as finished to be ready process next command
func _action_finished() -> void:
	busy = false

# Get command based on input
func _get_movement_command() -> Command:
	var keys = movement_action_list.keys()
	
	if input_blocked:
		return null
	
	for key in keys:
		if Input.is_action_pressed(key):
			_handle_input_delay()
			return movement_action_list[key].new()
			
	return null

# Set lock on input to create delay
func _handle_input_delay():
	input_blocked = true
	get_tree().create_timer(input_cd_timeout_s).timeout.connect(_unblock_input)

# Release lock on input
func _unblock_input():
	input_blocked = false
