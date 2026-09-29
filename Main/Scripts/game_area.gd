extends Node2D

# Signal declaration for when the player wins the game.
signal win


var bullet = preload("res://Player/Bullet/bullet.tscn")  # The bullet scene to be instanced
var level_generated = false
var enemy_generator = EnemyGenerator.new()
# Called when the node enters the scene tree.
func _ready() -> void:
	
	$SpaceShip.bullet_fired.connect(_on_bullet_fired)
	# Stop any ongoing actions when the game or level starts.
	stop_action()

# Check how many enemies are left. If only one enemy is left, the player wins.
func check_enemy_count():
	# Get the total number of enemies in the "Enemies" node.
	var enemies = $Enemies.get_children().size()
	print($Enemies.get_child_count())
	# If only one enemy is left, the player wins the level.
	if enemies == 1:
		if Globals.climbed_floor == 7:
			#show end mesage and restar datas
			$Label.text= "THE END"
			$AnimationPlayer.play("the_end")
			
		# Emit the "win" signal to notify other parts of the game.
		win.emit()
		level_generated = false

# Stop all ongoing actions (hides the game screen, stops movement, and removes bullets).
func stop_action():
	self.hide()  # Hide the current screen or gameplay area.
	$SpaceShip.move_perm = false  # Disable spaceship movement.
	$SpaceShip/Timer.stop()  # Stop the spaceship timer (presumably for movement or other timed actions).
	
	# Remove all existing bullets in the "Bullets" node.
	for b in $Bullets.get_children():
		b.queue_free()  # Queue the bullets for removal.

# Start all necessary actions (shows the game screen, enables movement, and restarts the timer).
func start_action():
	self.show()  # Show the gameplay area.
	$SpaceShip.move_perm = true  # Enable spaceship movement.
	$SpaceShip/Timer.start()  # Start the spaceship timer (presumably for movement or other timed actions).
	
	if level_generated==false:
		# Set the enemy level based on the current floor the player is on.
		enemy_generator.generate_enemy($Enemies,Globals.climbed_floor)
		#$EnemyGenerator.set_level(Globals.climbed_floor)
		for i in $Enemies.get_children():
			i.check_enemies.connect(check_enemy_count)
		
		level_generated = true
		
func show_boss_label(value):
	show()
	$Label.text = value
	$AnimationPlayer.play("boss")
	pass

func _on_bullet_fired(player_position: Vector2, angle: float):
	var new_bullet = bullet.instantiate()
	new_bullet.global_position = player_position
	new_bullet.rotation = angle  # Set the bullet's rotation
	new_bullet.direction = Vector2.UP.rotated(angle)  # Calculate movement direction based on angle
	add_child(new_bullet)  # Add the bullet to the game
	
	
	
	#new_bullet.shoot()  # Call the bullet's shoot method to make it move
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "boss":
		start_action()
	if anim_name == "the_end":
		Globals.map_data = null
		Globals.climbed_floor = 0
		get_tree().reload_current_scene()
