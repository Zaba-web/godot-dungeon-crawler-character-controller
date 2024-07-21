class_name MoveCommand
extends Command

const MOVEMENT_ATTR = "movement"

# Execute the command
func execute(char: AbstractCharacter) -> void:
	var cell_size = context['cell_size']
	var movement_speed = context['movement_speed']
	var callback = context['callback']
	var direction = context['direction']
	
	if !_can_move(char, char.global_position + direction):
		callback.call()
		return
	
	context['char'] = char
	var tween = char.get_tree().create_tween()
	char.set_attribute(MOVEMENT_ATTR, true)
	tween.tween_property(char, "position", direction, movement_speed).as_relative().finished.connect(_callback)

# Check if character can move
func _can_move(char: AbstractCharacter, target: Vector3) -> bool:
	var from = char.global_position
	
	from.y = .5
	target.y = .5
	
	var query = PhysicsRayQueryParameters3D.create(from, target)
	var space_state = char.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)

	if result.has("collider"):
		return false

	return true

# Customize callback to set attribute value of character
func _callback() -> void:
	context['char'].set_attribute(MOVEMENT_ATTR, false)
	context['callback'].call()
