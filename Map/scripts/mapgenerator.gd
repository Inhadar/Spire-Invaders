class_name MapGenerator
extends Node

# Constants for map generation
const X_DIST := 96  # Horizontal distance between rooms
const Y_DIST := 96  # Vertical distance between rooms
const PLACEMENT_RANDOMNESS := 5  # Randomness factor for room placement
const FLOORS := 7  # Number of floors in the map
const MAP_WIDTH := 4  # Width of the map (number of rooms per floor)
const PATHS := 6  # Number of paths (connections)
const MONSTER_ROOM_WEIGHT := 12.0  # Weight for monster rooms
#const EVENT_ROOM_WEIGHT := 5.0  # Weight for event rooms (commented out)
const SHOP_ROOM_WEIGHT := 2.5  # Weight for shop rooms
const CAMPFIRE_ROOM_WEIGHT := 4.0  # Weight for campfire rooms

# Room type weights initialization
var random_room_type_weights = {
	Room.Type.MONSTER: 0.0,  # Initial weight for monster rooms
	Room.Type.CAMPFIRE: 0.0,  # Initial weight for campfire rooms
	Room.Type.SHOP: 0.0,  # Initial weight for shop rooms
}
var random_room_type_total_weight := 0  # Total weight of all room types
var map_data: Array[Array]  # Array to store generated map data


# Function to generate a new map
func generate_map() -> Array[Array]:
	# Initialize the grid for the map
	map_data = _generate_initial_grid()
	
	# Get random starting points for path connections
	var starting_points := _get_random_starting_points()
	
	# Generate connections between rooms based on the starting points
	for j in starting_points:
		var current_j := j
		for i in FLOORS - 1:
			current_j = _setup_connection(i, current_j)

	# Setup the boss room at the end
	_setup_boss_room()
	
	# Set up the random room weights based on the defined constants
	_setup_random_room_weights()
	
	# Assign random types to the rooms
	_setup_room_types()
	
	# Return the generated map data
	return map_data


# Function to generate the initial grid of rooms
func _generate_initial_grid() -> Array[Array]:
	var result: Array[Array] = []
	
	# Loop through each floor and create rooms
	for i in FLOORS:
		var adjacent_rooms: Array[Room] = []
		
		# Loop through each room in the current floor
		for j in MAP_WIDTH:
			var current_room := Room.new()
			# Add randomness to the room's position
			var offset := Vector2(randf(), randf()) * PLACEMENT_RANDOMNESS
			current_room.position = Vector2(j * X_DIST, i * -Y_DIST) + offset
			current_room.row = i
			current_room.column = j
			current_room.next_rooms = []
			
			# Set the position of the boss room (last floor)
			if i == FLOORS - 1:
				current_room.position.y = (i + 1) * -Y_DIST
			
			# Add the room to the list of adjacent rooms for the floor
			adjacent_rooms.append(current_room)
			
		# Add the list of rooms for this floor to the map
		result.append(adjacent_rooms)

	# Return the complete grid of rooms
	return result


# Function to get random starting points for the path connections
func _get_random_starting_points() -> Array[int]:
	var y_coordinates: Array[int]
	var unique_points: int = 0
	
	# Ensure we have two unique starting points
	while unique_points < 2:
		unique_points = 0
		y_coordinates = []

		# Select random starting points for the path connections
		for i in PATHS:
			var starting_point := randi_range(0, MAP_WIDTH - 1)
			if not y_coordinates.has(starting_point):
				unique_points += 1
			
			y_coordinates.append(starting_point)
	
	# Return the array of starting points
	return y_coordinates


# Function to setup the connection between rooms
func _setup_connection(i: int, j: int) -> int:
	var next_room: Room = null
	var current_room := map_data[i][j] as Room
	
	# Try to find a valid next room while ensuring no crossing paths
	while not next_room or _would_cross_existing_path(i, j, next_room):
		var random_j := clampi(randi_range(j - 1, j + 1), 0, MAP_WIDTH - 1)
		next_room = map_data[i + 1][random_j]
	
	# Add the next room to the current room's list of next rooms
	current_room.next_rooms.append(next_room)
	
	# Return the column of the next room
	return next_room.column


# Function to check if a path would cross an existing one
func _would_cross_existing_path(i: int, j: int, room: Room) -> bool:
	var left_neighbour: Room
	var right_neighbour: Room
	
	# Check left neighbour
	if j > 0:
		left_neighbour = map_data[i][j - 1]
	# Check right neighbour
	if j < MAP_WIDTH - 1:
		right_neighbour = map_data[i][j + 1]
	
	# Conditions for crossing paths
	if right_neighbour and room.column > j:
		for next_room: Room in right_neighbour.next_rooms:
			if next_room.column < room.column:
				return true
	
	if left_neighbour and room.column < j:
		for next_room: Room in left_neighbour.next_rooms:
			if next_room.column > room.column:
				return true
	
	# No crossing path
	return false


# Function to set up the boss room on the last floor
func _setup_boss_room() -> void:
	var middle := floori(MAP_WIDTH * 0.5)
	var boss_room := map_data[FLOORS - 1][middle] as Room
	
	# Remove any existing connections to the boss room
	for j in MAP_WIDTH:
		var current_room = map_data[FLOORS - 2][j] as Room
		if current_room.next_rooms:
			current_room.next_rooms = [] as Array[Room]
			current_room.next_rooms.append(boss_room)
			
	# Set the type of the boss room
	boss_room.type = Room.Type.BOSS
	#boss_room.battle_stats = battle_stats_pool.get_random_battle_for_tier(2)  # Commented out, for battle stats setup


# Function to set up the random room weights for room types
func _setup_random_room_weights() -> void:
	random_room_type_weights[Room.Type.MONSTER] = MONSTER_ROOM_WEIGHT
	random_room_type_weights[Room.Type.CAMPFIRE] = MONSTER_ROOM_WEIGHT + CAMPFIRE_ROOM_WEIGHT
	random_room_type_weights[Room.Type.SHOP] = MONSTER_ROOM_WEIGHT + CAMPFIRE_ROOM_WEIGHT + SHOP_ROOM_WEIGHT
	#random_room_type_weights[Room.Type.EVENT] = random_room_type_weights[Room.Type.SHOP] + EVENT_ROOM_WEIGHT  # Commented out


# Function to setup room types for each room
func _setup_room_types() -> void:
	# First floor is always a battle
	for room: Room in map_data[0]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.MONSTER
			#room.battle_stats = battle_stats_pool.get_random_battle_for_tier(0)  # Battle setup for tier 0

	# Setup room types for remaining floors
	for current_floor_number in map_data.size():
		#else:
		var current_floor = map_data[current_floor_number]
		for room: Room in current_floor:
			if current_floor_number ==3:
				room.type = Room.Type.BOSS
			
			for next_room: Room in room.next_rooms:
				if next_room.type == Room.Type.NOT_ASSIGNED:
					_set_room_randomly(next_room)


# Function to randomly assign a type to a room
func _set_room_randomly(room_to_set: Room) -> void:
	var campfire_below_4 := true
	var consecutive_campfire := true
	var consecutive_shop := true
	
	var type_candidate: Room.Type
	
	# Ensure the randomness doesn't violate certain conditions
	while campfire_below_4 or consecutive_campfire or consecutive_shop:
		type_candidate = _get_random_room_type_by_weight()
		
		# Check conditions for the campfire and shop room types
		var is_campfire := type_candidate == Room.Type.CAMPFIRE
		var has_campfire_parent := _room_has_parent_of_type(room_to_set, Room.Type.CAMPFIRE)
		var is_shop := type_candidate == Room.Type.SHOP
		var has_shop_parent := _room_has_parent_of_type(room_to_set, Room.Type.SHOP)
		
		campfire_below_4 = is_campfire and room_to_set.row < 3
		consecutive_campfire = is_campfire and has_campfire_parent
		consecutive_shop = is_shop and has_shop_parent
		
	room_to_set.type = type_candidate


# Function to check if a room has a parent of a specific type
func _room_has_parent_of_type(room: Room, type: Room.Type) -> bool:
	var parents: Array[Room] = []
	# Check left parent
	if room.column > 0 and room.row > 0:
		var parent_candidate := map_data[room.row - 1][room.column - 1] as Room
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	# Check parent below
	if room.row > 0:
		var parent_candidate := map_data[room.row - 1][room.column] as Room
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	# Check right parent
	if room.column < MAP_WIDTH-1 and room.row > 0:
		var parent_candidate := map_data[room.row - 1][room.column + 1] as Room
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	
	# Check if any parent has the specified type
	for parent: Room in parents:
		if parent.type == type:
			return true
	
	# No parent with the specified type
	return false


# Function to randomly select a room type based on weights
func _get_random_room_type_by_weight() -> Room.Type:
	var roll := randf_range(0.0, random_room_type_total_weight)
	
	# Roll to select a room type based on the weights
	for type: Room.Type in random_room_type_weights:
		if random_room_type_weights[type] > roll:
			return type
	
	# Default to monster room type
	return Room.Type.MONSTER
