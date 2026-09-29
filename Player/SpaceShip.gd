extends CharacterBody2D


@export var bullet_count: int = 3  # Number of bullets to fire
@export var angle_spread: float = 30.0  # Maximum angle spread between bullets

signal bullet_fired(position: Vector2, angle: float)

var move_speed = 10  # Speed at which the character moves horizontally
@export var wait_time = 1.0  # The time to wait before the timer starts
var move_perm = false  # Boolean flag to control movement permission

# Called when the node is ready
func _ready() -> void:
	$AnimationPlayer.play("move")
	$Timer.wait_time = wait_time  # Sets the timer's wait time
	await get_tree().create_timer(3).timeout  # Wait for 3 seconds
	$Timer.start()  # Start the timer

# Called every physics frame
func _physics_process(delta: float) -> void:
	if move_perm:  # Check if movement is allowed
		if Input.is_action_pressed("MouseLeft"):  # If the left mouse button is pressed
			var target_pos = get_global_mouse_position()  # Get the position of the mouse in global coordinates
			position.x = lerp(position.x, target_pos.x, delta * move_speed)  # Smoothly move towards the mouse position on the X-axis

# Function to add a bullet to the scene
func add_bullet():
	var base_angle = rotation  # Get the player's current rotation
	var start_angle = base_angle - deg_to_rad(angle_spread) / 2  # Starting angle for the first bullet
	var step = deg_to_rad(angle_spread) / max(1, bullet_count - 1)  # Angle step between each bullet

	for i in range(bullet_count):
		var angle = start_angle + (i * step)  # Calculate the angle for each bullet
		bullet_fired.emit(global_position, angle)  # Emit signal to create a bullet with the calculated angle


# Called when the timer times out
func _on_timer_timeout() -> void:
	add_bullet()  # Add a new bullet when the timer reaches the timeout
