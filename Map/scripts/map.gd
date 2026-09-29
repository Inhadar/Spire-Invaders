class_name Map
extends Node2D

const SCROLL_SPEED := 15  # Speed at which the camera scrolls
const MAP_ROOM = preload("res://Map/MapRoom/tscn/point.tscn")  # Room scene
const MAP_LINE = preload("res://Map/MapRoom/tscn/map_line.tscn")  # Line scene to connect rooms

@onready var map_generator: MapGenerator = $MapGenerator  # Reference to the map generator node
@onready var lines: Node2D = %Lines  # Node for storing map lines
@onready var rooms: Node2D = %Rooms  # Node for storing rooms
@onready var visuals: Node2D = $Visuals  # Node handling map visuals
@onready var camera_2d: Camera2D = $Camera2D  # Camera reference

var map_data: Array[Array]  # Stores the generated map data
var floors_climbed: int  # Tracks the number of floors climbed
var last_room: Room  # Stores the last selected room
var camera_edge_y: float  # Maximum Y position for the camera

func _ready() -> void:
	print(Globals.climbed_floor)
	print(Globals.last_room)
	print(Globals.map_data)
	camera_edge_y = MapGenerator.Y_DIST * (MapGenerator.FLOORS - 1)  # Calculate camera boundary
	generate_new_map()
	unlock_floor(0)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("R"):
		Globals.map_data = null
		Globals.climbed_floor = 0
		get_tree().reload_current_scene()  # Reload scene on key press
	if not visible:
		return
	
	# Handle camera scrolling
	if event.is_action_pressed("scroll_up"):
		camera_2d.position.y -= SCROLL_SPEED
	elif event.is_action_pressed("scroll_down"):
		camera_2d.position.y += SCROLL_SPEED

	# Clamp the camera movement within boundaries
	camera_2d.position.y = clamp(camera_2d.position.y, -camera_edge_y, 0)

func generate_new_map() -> void:
	if Globals.map_data == null:
		floors_climbed = 0  # Reset floor count if no previous data exists
		map_data = map_generator.generate_map()  # Generate a new map
		Globals.map_data = map_data  # Store map globally
	else:
		floors_climbed = Globals.climbed_floor  # Load climbed floors
		map_data = Globals.map_data  # Load previous map data
		last_room = Globals.last_room  # Load last selected room
		
		if floors_climbed > 0:
			unlock_next_rooms()  # Unlock next available rooms if any
		else:
			unlock_floor()  # Otherwise, unlock the current floor
	
	create_map()  # Create the map

func create_map() -> void:
	for current_floor: Array in map_data:
		for room: Room in current_floor:
			if room.next_rooms.size() > 0:
				_spawn_room(room)  # Spawn all rooms that have connections
	
	# Spawn the boss room, which has no next room but must exist
	var middle := floori(MapGenerator.MAP_WIDTH * 0.5)
	_spawn_room(map_data[MapGenerator.FLOORS-1][middle])

	# Center the visuals in the viewport
	var map_width_pixels := MapGenerator.X_DIST * (MapGenerator.MAP_WIDTH - 1)
	visuals.position.x = (get_viewport_rect().size.x - map_width_pixels) / 2
	visuals.position.y = (get_viewport_rect().size.y / 2) + 256

func show_map() -> void:
	show()
	camera_2d.enabled = true  # Enable the camera when showing the map

func hide_map() -> void:
	hide()
	camera_2d.enabled = false  # Disable the camera when hiding the map

func _spawn_room(room: Room) -> void:
	var new_map_room := MAP_ROOM.instantiate() as MapRoom  # Create a new room instance
	rooms.add_child(new_map_room)  # Add the new room to the scene
	new_map_room.room = room  # Assign room data
	new_map_room.clicked.connect(_on_map_room_clicked)  # Connect click event
	new_map_room.selected.connect(_on_map_room_selected)  # Connect selection event
	_connect_lines(room)  # Connect the room to its adjacent rooms
	
	# If the room is selected and belongs to a previously climbed floor, show it as selected
	if room.selected and room.row < floors_climbed:
		new_map_room.show_selected()

func _connect_lines(room: Room) -> void:
	if room.next_rooms.is_empty():
		return  # If the room has no next rooms, do nothing
	
	for next: Room in room.next_rooms:
		var new_map_line := MAP_LINE.instantiate() as Line2D  # Create a new line instance
		new_map_line.add_point(room.position)  # Start line at current room
		new_map_line.add_point(next.position)  # End line at next room
		lines.add_child(new_map_line)  # Add the line to the scene

func unlock_floor(which_floor: int = floors_climbed) -> void:
	# First, lock previous rooms.
	for map_room: MapRoom in rooms.get_children():
		if map_room.room.row == which_floor:
			# Unlock this room.
			map_room.available = true
		else:
			# Lock these rooms because they belong to previous floors.
			map_room.available = false

func unlock_next_rooms() -> void:
	# First, lock previous rooms and rooms that are not connected to `last_room`.
	for map_room: MapRoom in rooms.get_children():
		if not last_room.next_rooms.has(map_room.room):
			# Lock rooms that are not connected to `last_room`.
			map_room.available = false
		else:
			# Unlock rooms that are connected to `last_room`.
			map_room.available = true

func _on_map_room_clicked(room: Room) -> void:
	# Before locking the selected room, close previous rooms.
	for map_room: MapRoom in rooms.get_children():
		if map_room.room.row == room.row:
			# Close rooms on the same floor.
			map_room.available = false
		
	if room.type == Room.Type.BOSS:
		if floors_climbed == 6:
			$GameArea.show_boss_label("FINAL BOSS")
			$Visuals.hide()
		else:
			$GameArea.show_boss_label("BOSS")
			$Visuals.hide()  
	else:
		$GameArea.start_action()  
		$Visuals.hide() 

func _on_map_room_selected(room: Room) -> void:
	last_room = room  # Store the selected room as last_room
	floors_climbed += 1  # Increase floor count
	Globals.last_room = room  # Update global last_room reference
	Globals.climbed_floor += 1  # Update global climbed floor count

func _on_game_area_win() -> void:
	if floors_climbed < 7:
		$GameArea.stop_action()  # Stop the game area logic after winning
		$Visuals.show()  # Show visuals again
		unlock_next_rooms()  # Unlock next available rooms
	#create_map()  # Rebuild the map to reflect changes
