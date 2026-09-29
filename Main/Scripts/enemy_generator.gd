class_name EnemyGenerator
extends Node

# Levels are calculated according to the index.
# Each array in 'param_for_levels' contains two values: row count and column count for the enemies in that level.
var param_for_levels = [[5,1],[5,2],[5,3],[5,4],[5,5],[5,6],[5,7],[5,8]] 

@export var enemy_row = 5  # The number of rows for enemies on the map.
@export var enemy_collumn = 7  # The number of columns for enemies on the map.
@export var enemy_distance = 96  # The space (distance) between enemies, used for positioning.
@export var wait_time = 1.0  # The wait time before enemies start their movements.

# Calculate the initial offset for positioning enemies. 
# This centers the enemy grid horizontally and sets a fixed vertical offset.
var enemy_offset = Vector2(((648 - (enemy_row * enemy_distance)) / 2.0) + enemy_distance / 2.0, 64)

# Preload the enemy scene (to instantiate enemies later).
var enemy = preload("res://Enemy/Tscn/enemy.tscn")


# Set the level configuration by index (this controls the number of rows and columns for enemies).
# This function generates enemies on the grid based on 'enemy_row' and 'enemy_collumn'.
func generate_enemy(enemy_parent,value):
	enemy_row = param_for_levels[value][0]  # Get the row count for the selected level.
	enemy_collumn = param_for_levels[value][1]  # Get the column count for the selected level.
	# Loop through the rows and columns to place enemies on the grid.
	for i in range(enemy_row):  # Iterate over each row.
		for j in range(enemy_collumn):  # Iterate over each column.
			var new_enemy = enemy.instantiate()  # Instantiate a new enemy from the preloaded scene.
			# Add the new enemy as a child to the "Enemies" node (assumed to exist in the parent).
			enemy_parent.add_child(new_enemy)
			# Position the new enemy on the grid.
			new_enemy.position = Vector2(i * enemy_distance, j * enemy_distance)
			# Add the offset values to adjust the position.
			new_enemy.position.y += enemy_offset.y
			new_enemy.position.x += enemy_offset.x
			# Set the wait time for the new enemy (perhaps for its movement or behavior).
			new_enemy.wait_time = wait_time
			# Start the movement trigger for the enemy, assuming it has a "mover_trigger" node.
			new_enemy.get_node("mover_trigger").start()
