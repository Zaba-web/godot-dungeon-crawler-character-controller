class_name TurnLeftCommand
extends Command

# Turn character left
func execute(char: AbstractCharacter) -> void:
	var movement_speed = context['movement_speed']
	var callback = context['callback']
	
	var tween = char.get_tree().create_tween()
	tween.tween_property(char, "rotation:y", deg_to_rad(90), movement_speed / 2).as_relative().finished.connect(callback)
