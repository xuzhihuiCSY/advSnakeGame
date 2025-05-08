extends Node2D

var block_size := 40
var food_position := Vector2()

func spawn_food(snake_positions, grid_width, grid_height):
	var found := false
	while not found:
		var new_position := Vector2(
			randi() % (grid_width - 2) + 1,
			randi() % (grid_height - 2) + 1
		)
		if new_position not in snake_positions:
			found = true
			food_position = new_position
			$FoodBlock.position = food_position * block_size
