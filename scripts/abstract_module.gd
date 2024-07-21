extends Node
class_name AbstractModule

# List of character states from which module should be active 
var allowed_state: Array

func _ready():
	pass

# Called every physics frame by parent character
func __physics_process(_delta: float, player: AbstractCharacter) -> void:
	pass
