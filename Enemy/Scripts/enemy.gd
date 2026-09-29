extends Area2D  # This script extends Area2D, making it suitable for nodes that have a position but don't interact directly with physics bodies like characters do.

signal check_enemies


@export var move_distance: int = 32   # The distance the object will move with each step.
@export var move_speed: float = 1.0   # The speed of movement (though it's not used directly in the current code).
@export var wait_time: float = 5.0    # The time to wait between each move before the next move is triggered.

var move_index = 0  # The current step in the movement sequence (tracks which direction to move next).
var move_directions = [Vector2.RIGHT, Vector2.RIGHT,Vector2.LEFT,Vector2.LEFT,Vector2.LEFT, Vector2.LEFT,Vector2.DOWN,Vector2.RIGHT, Vector2.RIGHT]  # The predefined movement sequence.
var move_perm = false  # A flag that indicates whether the movement trigger should start.

# This function is called when the node (Area2D) is added to the scene and fully initialized.
func _ready() -> void:
	# Set the wait time for the mover trigger.
	$mover_trigger.wait_time = wait_time
	# Start the animation for movement.
	$AnimationPlayer.play("move")
	# If move_perm is true, start the movement trigger.
	if move_perm:
		$mover_trigger.start()

# This function is triggered when the mover's timeout occurs (after the wait_time has passed).
func _on_mover_trigger_timeout() -> void:
	# If we've reached the end of the movement directions list, reset to the beginning.
	if move_index > move_directions.size() - 1:
		move_index = 0
	else:
		# Calculate the target position based on the current direction and move distance.
		var target_position = position + (move_directions[move_index] * move_distance)
		# Move the object to the target position.
		position = target_position
		# Increment the move_index to continue to the next direction.
		move_index += 1

# This function is triggered when a area enters the area (collision detection).
func _on_area_entered(area: Area2D) -> void:
		# If the body that entered the area is in the "Bullet" group (typically for projectiles).
		if area.is_in_group("Bullet"):
			# Call the parent node's check_enemy_count method (presumably to update the count of enemies).
			check_enemies.emit()
			# Queue the bullet for deletion.
			area.move_perm = false
			area.explode()
		
			# Queue the current object (the enemy) for deletion.
			queue_free()
