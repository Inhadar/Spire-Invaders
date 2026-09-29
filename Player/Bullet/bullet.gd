extends Area2D

@export var speed: float = 500  # Bullet movement speed (default 500)
var direction = Vector2.UP  # Default direction is upward

var move_perm = true  # Controls whether the bullet can move

func _process(delta):
	if move_perm:
		position += direction * speed * delta  # Move the bullet in the specified direction

func explode():
	$AnimationPlayer.play("explode")  # Play the "explode" animation when the bullet explodes

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()  # Delete the bullet when it goes off-screen

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()  # Delete the bullet when the animation is finished
