class_name MoveBackCommand
extends MoveCommand

# Execute the command
func execute(char: AbstractCharacter) -> void:
	var direction = Vector3(0, 0, context['cell_size'])
	self.context['direction'] = direction.rotated(Vector3(0, 1, 0), char.rotation.y)
	super(char)
