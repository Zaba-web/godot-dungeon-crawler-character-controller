extends AbstractCharacter
class_name Player

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# List of player attributes
var attributes: Dictionary

# Default ready
func _ready():
	super()

# Default physics process
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	super(delta)

# Set attribute value
func set_attribute(name: String, value) -> Dictionary:
	attributes[name] = value
	return attributes
	
# Get attribute value
func get_attribute(name: String):
	if attributes.has(name):
		return attributes[name]
	
	return null
