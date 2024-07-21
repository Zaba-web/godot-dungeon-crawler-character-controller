extends CharacterBody3D
class_name AbstractCharacter

# Node that contains all modules represented as child nodes
@export var modules_container: Node

# List of all included modules
@export var used_modules: Array[Node]

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
