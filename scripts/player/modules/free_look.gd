extends AbstractModule

## Node that contains camera
@export var visuals: Node3D

## Main camera
@export var camera: Camera3D

## Camera sensitivity
@export var sensitivity: float = 0.005

## Action name for camera toggling
@export var free_look_toggle_action_name: String = "free_look_toggle"

## Free look limitation settings for look down
@export var vert_rotation_limit_bottom: float = -10

## Free look limitation settings for look up
@export var vert_rotation_limit_top: float = 30

## Free look limitation settings for look left
@export var hor_rotation_limit_left: float = -60

## Free look limitation settings for look right
@export var hor_rotation_limit_right: float = 60

## Enable camera rotation using controller stick
@export var enable_gamepad_camera: bool = true

## Action names for gamepad cursor controls (left)
@export var cursor_left_action_name: String = "cursor_left"

## Action names for gamepad cursor controls (right)
@export var cursor_right_action_name: String = "cursor_right"

## Action names for gamepad cursor controls (up)
@export var cursor_up_action_name: String = "cursor_up"

## Action names for gamepad cursor controls (down)
@export var cursor_down_action_name: String = "cursor_down"

# Implement free look
func __physics_process(_delta: float, player: AbstractCharacter) -> void:
	if Input.is_action_just_pressed(free_look_toggle_action_name):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	if Input.is_action_just_released(free_look_toggle_action_name):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_reset_rotation()
	
	if enable_gamepad_camera:
		_handle_controller_stick_camera()

# Handle mouse free look
func _unhandled_input(event):
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_rotate_camera(-event.relative.x, -event.relative.y)
		visuals.rotation.y = clamp(visuals.rotation.y, deg_to_rad(hor_rotation_limit_left), deg_to_rad(hor_rotation_limit_right))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(vert_rotation_limit_bottom), deg_to_rad(vert_rotation_limit_top))

# Camera rotation
func _rotate_camera(x: float, y: float) -> void:
	visuals.rotate_y(x * sensitivity)
	camera.rotate_x(y * sensitivity)	
	visuals.rotation.y = clamp(visuals.rotation.y, deg_to_rad(hor_rotation_limit_left), deg_to_rad(hor_rotation_limit_right))
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(vert_rotation_limit_bottom), deg_to_rad(vert_rotation_limit_top))

# Reset all rotations to snap camera to right angle
func _reset_rotation() -> void:
	visuals.rotation.y = 0
	camera.rotation.x = 0

# Handle camera movement with controller stick
func _handle_controller_stick_camera():
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var gamepad_input = Input.get_vector(cursor_left_action_name, cursor_right_action_name, cursor_up_action_name, cursor_down_action_name)
		_rotate_camera(-gamepad_input.x, -gamepad_input.y)
