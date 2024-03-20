extends AbstractCharacter
class_name Player

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# On player state change
signal player_state_changed(current_state)

# Default ready
func _ready():
	super()
	
	state_transition_table = {
		State.List.FALLING: [State.List.IDDLE],
		State.List.IDDLE: [State.List.FALLING, State.List.MOVING, State.List.TURNING],
		State.List.MOVING: [State.List.IDDLE, State.List.FALLING],
		State.List.TURNING: [State.List.IDDLE]
	}

# Default physics process
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		set_state(State.List.FALLING)
	
	if velocity.length() == 0 && get_state() != State.List.TURNING:
		set_state(State.List.IDDLE)
	
	if velocity.x != 0 || velocity.z != 0:
		set_state(State.List.MOVING)
	
	if _process_rotation():
		set_state(State.List.TURNING)
	elif get_state() == State.List.TURNING:
		set_state(State.List.IDDLE)
	
	super(delta)

# Rewrite base set_state, signal emmision added 
func set_state(new_state: State.List) -> void:
	super(new_state)
	player_state_changed.emit(current_state)
