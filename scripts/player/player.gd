extends AbstractCharacter
class_name Player

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Default ready
func _ready():
	super()

# Default physics process
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	super(delta)
