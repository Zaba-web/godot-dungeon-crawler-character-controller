class_name Command
extends Node

# Dictionary with contextual data needef for command
var context = null

# Set context
func set_context(context) -> void:
	self.context = context

# Execute the command
func execute(char: AbstractCharacter) -> void:
	pass
