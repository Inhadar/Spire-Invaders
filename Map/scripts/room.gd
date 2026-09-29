class_name Room
extends Resource

# Enum to define different types of rooms that can be assigned
enum Type {NOT_ASSIGNED, MONSTER, TREASURE, CAMPFIRE, SHOP, BOSS}

# Exported variables for use in the Godot Editor
@export var type: Type  # The type of the room (e.g., MONSTER, TREASURE)
@export var row: int     # The row number of the room in the grid
@export var column: int  # The column number of the room in the grid
@export var position: Vector2  # The position of the room on the screen
@export var next_rooms: Array[Room]  # An array of possible rooms that can be accessed from this room
@export var selected := false  # Indicates if the room is selected (default is false)

# Optional: This would be used by MONSTER and BOSS rooms, but is commented out here.
#@export var battle_stats: BattleStats  # Battle statistics for the room's enemies
# Optional: This would be used by EVENT rooms (e.g., rooms triggering a specific scene/event), but is also commented out.
#@export var event_scene: PackedScene  # Packed scene for the event

# Method to return a string representation of the room (for debugging or display purposes)
func _to_string() -> String:
	# Returns a string with the column number and the room type (using the enum keys)
	return "%s (%s)" % [column, Type.keys()[type][0]]
