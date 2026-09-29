class_name MapRoom
extends Area2D

# Signals to notify when a room is clicked or selected
signal clicked(room: Room)
signal selected(room: Room)

# Define icons for each room type with color and scale settings
const ICONS := {
	Room.Type.NOT_ASSIGNED: [Color.WHITE, Vector2.ONE],  # Default: White color, normal scale
	Room.Type.MONSTER: [Color.DARK_BLUE, Vector2.ONE],   # Monster rooms: Pink color, normal scale
	Room.Type.TREASURE: [Color.YELLOW, Vector2.ONE],     # Treasure rooms: Yellow color, normal scale
	Room.Type.CAMPFIRE: [Color.ORANGE_RED, Vector2(0.6, 0.6)],  # Campfire rooms: Orange-red, smaller scale
	Room.Type.SHOP: [Color.BLUE, Vector2(0.6, 0.6)],     # Shop rooms: Blue color, smaller scale
	Room.Type.BOSS: [Color.RED, Vector2(1.25, 1.25)],    # Boss rooms: Red color, larger scale
}

# On-ready variables that are initialized when the scene is ready
@onready var sprite_2d: MeshInstance2D = $Visuals/MeshInstance2D  # Reference to the visual sprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer  # Reference to the animation player

# Available flag that indicates if the room can be interacted with
var available := false : set = set_available

# The room data associated with this map room
var room: Room : set = set_room


# Function to set the availability of the room
func set_available(new_value: bool) -> void:
	available = new_value
	
	# If the room is available, play the highlight animation
	if available:
		animation_player.play("highlight")
	# If the room is not available and it's not selected, reset its animation
	elif not room.selected:
		animation_player.play("Normal")



# Function to set the room data and update its visual appearance
func set_room(new_data: Room) -> void:
	room = new_data
	position = room.position  # Position the room according to its data
	# Set the visual appearance of the room based on its type using the ICONS dictionary
	$Visuals/MeshInstance2D.modulate = ICONS[room.type][0]
	#$Visuals/MeshInstance2D.scale = ICONS[room.type][1]


# Placeholder function that could be used to handle selected state visuals
func show_selected() -> void:
	# This could be used to further modify the visual appearance when a room is selected
	#line_2d.modulate = Color.WHITE
	pass


# This function is triggered when the user clicks on the room (via the mouse event)
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# If the room is not available or the left mouse button is not pressed, do nothing
	if not available or not event.is_action_pressed("MouseLeft"):
		return

	# Mark the room as selected and emit the clicked signal
	room.selected = true
	clicked.emit(room)

	# Play the select animation when the room is clicked
	animation_player.play("select")


# This function is called when the "select" animation finishes
func _on_map_room_selected() -> void:
	# Emit the selected signal when the animation is finished
	selected.emit(room)


# This function listens for finished animations in the AnimationPlayer
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	# If the animation that finished is "select", emit the selected signal
	if anim_name == "select":
		selected.emit(room)
