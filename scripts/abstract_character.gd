extends CharacterBody3D
class_name AbstractCharacter

# Node that contains all modules represented as child nodes
@export var modules_container: Node

# List of all included modules
@export var used_modules: Array[Node]

# Current character state, iddle by default
var current_state: State.List = State.List.IDDLE

# Set of state transition rules
var state_transition_table: Dictionary

# Character Y rotation value in rad 
var rotation_target: float

# Rotation speed
var rotation_speed: float

# Called when the node enters the scene tree for the first time
func _ready():
	used_modules = modules_container.get_children()

# Default physics process
func _physics_process(delta):	
	for module in used_modules:
		if not module.has_method("__physics_process"):
			push_warning("Invalid module detected")
		else:
			module.__physics_process(delta, self)
	
	move_and_slide()

# Set new state for character
func set_state(new_state: State.List) -> void:
	if _can_transition(new_state):
		current_state = new_state

# Get current character state
func get_state() -> State.List:
	return current_state;

# Check if character can make a transition from current state to desired
func _can_transition(to_state: State.List) -> bool:
	return state_transition_table[current_state].has(to_state)

# Process rotation
func _process_rotation() -> bool:
	var new_rotation_position = _lerp_angle(rotation.y, rotation_target, rotation_speed)
	
	if not is_equal_approx(new_rotation_position, rotation.y):
		global_rotation.y = new_rotation_position
		return true
	else:
		return false

# Helper function to lerp rotation
func _lerp_angle(from, to, weight):
	return from + _short_angle_dist(from, to) * weight

# Helper function with rotation lerp calculation
func _short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference
