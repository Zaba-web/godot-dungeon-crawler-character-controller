extends AbstractModule

## Main camera from which ray will be casted
@export var camera: Camera3D

## Max distance at which player is able to interact with objects 
@export var max_interaction_distance: float = 4

## Action name for interaction
@export var interact_action_name: String = "interact"

## Action names for gamepad cursor controls (left)
@export var cursor_left_action_name: String = "cursor_left"

## Action names for gamepad cursor controls (right)
@export var cursor_right_action_name: String = "cursor_right"

## Action names for gamepad cursor controls (up)
@export var cursor_up_action_name: String = "cursor_up"

## Action names for gamepad cursor controls (down)
@export var cursor_down_action_name: String = "cursor_down"

## Sensitivity of the gamepad cursor stick
@export var gamepad_cursor_stick_sens: float = 500

## Object that cursor currently is on 
var selected_object: Node3D = null

# Handle mouse interaction
func __physics_process(_delta: float, player: AbstractCharacter) -> void:
	var raycast_result = _cast_ray_from_cursor(player)
	_handle_gamepad_cursor_movement(_delta)
	
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		_handle_selected_object(raycast_result)
		_handle_object_interact()

# Shot ray from cursor 
func _cast_ray_from_cursor(player: AbstractCharacter) -> Dictionary:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = max_interaction_distance
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var space = camera.get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	
	ray_query.from = from
	ray_query.to = to
	ray_query.hit_from_inside = true
	ray_query.exclude = [player]
	
	return space.intersect_ray(ray_query)

# Handle interactable object selection
func _handle_selected_object(raycast_result: Dictionary) -> void:
	if raycast_result.has("collider") && raycast_result.collider is AbstractInteractableObject:
		if selected_object == null:
			selected_object = raycast_result.collider
			selected_object.mouse_enter()
	else:
		if selected_object != null:
			selected_object.mouse_leave()
		selected_object = null

# Interact with object
func _handle_object_interact() -> void:
	if Input.is_action_just_pressed(interact_action_name) && selected_object != null:
		selected_object.interact()

# Move cursor using gamepad stick
func _handle_gamepad_cursor_movement(delta) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var cursor_velocity = Vector2.ZERO
	cursor_velocity = Input.get_vector(cursor_left_action_name, cursor_right_action_name, cursor_up_action_name, cursor_down_action_name)
	Input.warp_mouse(mouse_pos + cursor_velocity * gamepad_cursor_stick_sens * delta)

