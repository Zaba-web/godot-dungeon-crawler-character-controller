extends AbstractInteractableObject

# Called when player interacts with object
func interact() -> void:
	print("interact")

# Called when cursor is on object
func mouse_enter() -> void:
	print("enter")
	
# Called when cursor left object
func mouse_leave() -> void:
	print("left")
