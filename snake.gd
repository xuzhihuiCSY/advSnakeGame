extends Node2D
var food
var is_game_over := false
var move_timer := 0.0
var move_interval := 0.2
var grid_width := 0
var grid_height := 0
var score := 0
var score_label
var game_over_label
var direction_index := 0
var directions := [
	Vector2.RIGHT,          # (1, 0)
	Vector2(1, 1),          # DOWN-RIGHT (1, 1)
	Vector2.DOWN,           # (0, 1)
	Vector2(-1, 1),         # DOWN-LEFT (-1, 1)
	Vector2.LEFT,           # (-1, 0)
	Vector2(-1, -1),        # UP-LEFT (-1, -1)
	Vector2.UP,             # (0, -1)
	Vector2(1, -1)          # UP-RIGHT (1, -1)
]
var move_in_direction_steps := 0
var steps_per_direction := 1
var snake_positions := []
var block_size := 40

var clockwise := true

func _ready():
	var screen_size := get_viewport().get_visible_rect().size
	grid_width = int(screen_size.x / block_size)
	grid_height = int(screen_size.y / block_size)
	score_label = get_parent().get_node("UI/ScoreLabel")
	game_over_label = get_parent().get_node("UI/GameOverLabel")
	snake_positions.append(Vector2(int(grid_width / 2), int(grid_height / 2)))
	food = get_parent().get_node("Food")
	food.spawn_food(snake_positions, grid_width, grid_height) # <<< NOW is correct
	update_snake()


func _process(delta):
	if is_game_over:
		return  # Do nothing if game over

	move_timer += delta
	if move_timer >= move_interval:
		move_timer = 0
		move_snake()


func move_snake():
	# Handle step counting
	move_in_direction_steps += 1
	if move_in_direction_steps >= steps_per_direction:
		move_in_direction_steps = 0
		if clockwise:
			direction_index = (direction_index + 1) % directions.size()
		else:
			direction_index = (direction_index - 1 + directions.size()) % directions.size()

	var direction = directions[direction_index]

	var new_head = snake_positions[0] + direction

	# Check wall collision
	if new_head.x < 0 or new_head.x >= grid_width or new_head.y < 0 or new_head.y >= grid_height:
		game_over()
		return

	# Check self collision
	if new_head in snake_positions:
		game_over()
		return

	snake_positions.insert(0, new_head)

	if new_head == food.food_position:
		food.spawn_food(snake_positions, grid_width, grid_height)
		score += 1
		score_label.text = "Score: " + str(score)
	else:
		snake_positions.pop_back()

	update_snake()



func update_snake():
	# Clear previous snake blocks
	for child in get_children():
		child.queue_free()

	# Draw snake blocks
	for pos in snake_positions:
		var block = ColorRect.new()
		block.color = Color.GREEN
		block.size = Vector2(block_size, block_size)
		block.position = pos * block_size
		add_child(block)

func game_over():
	is_game_over = true
	game_over_label.visible = true

func _unhandled_input(event):
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if is_game_over:
			get_tree().reload_current_scene()
		else:
			clockwise = not event.pressed
