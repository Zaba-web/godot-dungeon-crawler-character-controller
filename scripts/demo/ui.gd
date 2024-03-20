extends Node

# Player node
@export var player: Player

# State label
@onready var state_label = $Control/StateLabel

# Only for debug purposes
var state_names = {
	State.List.IDDLE: "iddle",
	State.List.FALLING: "falling",
	State.List.MOVING: "moving",
	State.List.TURNING: "turning"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	player.player_state_changed.connect(_show_state)

# Display player state after change
func _show_state(state) -> void:
	state_label.text = state_names[state]
