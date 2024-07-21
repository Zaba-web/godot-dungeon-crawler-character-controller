class_name MoveRightCommand
extends MoveCommand

# Execute the command
func execute(char: AbstractCharacter) -> void:
	var direction = Vector3(context['cell_size'], 0, 0)
	self.context['direction'] = direction.rotated(Vector3(0, 1, 0), char.rotation.y)
	super(char)
