extends Node
class_name AbstractModule

# List of character states from which module should be active 
var allowed_state: Array

func _ready():
	pass

# Called every physics frame by parent character
func __physics_process(delta: float, player: AbstractCharacter) -> void:
	pass

# Check if module should be active during current character state
func _is_current_state_allowed(current_state: State.List) -> bool:
	return allowed_state.has(current_state)
