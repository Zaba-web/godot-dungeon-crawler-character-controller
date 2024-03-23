extends AbstractModule

## Node that will be shaked during the movement
@export var visuals: Node3D

## Head movement parameters
@export var bop_freq: float = 2.0
## Head movement parameters
@export var bop_amp: float = 0.08

var t_bop: float = 0

# Create headbop effect
func __physics_process(_delta: float, player: AbstractCharacter) -> void:
	_handle_bop(_delta, player)

# Apply effect
func _handle_bop(delta: float, player: AbstractCharacter):
	t_bop += delta * player.velocity.length() * float(player.is_on_floor())
	visuals.transform.origin = _headbop(t_bop)

# Calculate current value
func _headbop(time: float):
	var pos = Vector3.ZERO
	pos.y = (sin(time * bop_freq) * bop_amp)
	return pos
