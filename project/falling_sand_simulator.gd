extends Control

@onready var background: ColorRect = get_node("Background")
@onready var tilemap: TileMap = get_node("TileMap")
@onready var cell_container: Control = get_node("CellContainer")
@onready var stage = get_node(".")

var rng = RandomNumberGenerator.new()

var container_size: Vector2
var cell_size: Vector2 = Vector2(25, 25)
var cell_size_modifier: Vector2 = Vector2(0.8, 0.8)
var grid_size: Vector2

# 0 - 359
var color_code: float = 0.0
var color_dif: float = 0.7

# store "null" or "ColorRect (cell)"
var cells = []

func _ready():
	container_size = get_viewport_rect().size
	cell_size = Vector2(container_size.x / 80, container_size.x / 80)
	grid_size = container_size / cell_size

	tilemap.tile_set.tile_size = cell_size
	background.size = container_size
	
	for x in grid_size.x:
		var cells_col_temp = []
		
		for y in grid_size.y:
			cells_col_temp.append(null)
		
		cells.append(cells_col_temp)
	
func is_in_grid(cell_position: Vector2i) -> bool:
	return (
		(cell_position.x >= 0)
		&&
		(cell_position.x < grid_size.x)
		&&
		(cell_position.y >= 0)
		&&
		(cell_position.y < grid_size.y)
	)

func calc_cell_pos(x: float, y: float) -> Vector2:
	return tilemap.map_to_local(Vector2(x, y)) - ((cell_size * cell_size_modifier) / 2.0)

func add_cell(x: int, y: int):
	var cell: ColorRect = ColorRect.new()
	cell.size = cell_size * cell_size_modifier

	# the `h` parameter is between 0-1, so we divide!
	cell.color = Color.from_hsv(color_code / 359.0, 1, 1, 1)

	var global_pos = calc_cell_pos(x, y)
	cell.set_global_position(global_pos)

	cells[x][y] = cell

	cell_container.add_child(cell)

func handle_input():
	if (Input.is_action_pressed("clicked")):
		var cell_pos: Vector2i = tilemap.local_to_map(get_global_mouse_position())

		if (not is_in_grid(cell_pos)):
			return
		
		var clicked_cell = cells[cell_pos.x][cell_pos.y]

		if (clicked_cell == null):

			add_cell(cell_pos.x, cell_pos.y)
			
			color_code += color_dif
			if (color_code > 359):
				color_code = 0

func move_cells():
	var new_cells = cells.duplicate(true)

	for x in grid_size.x:
		for y in grid_size.y:
			if (y + 1 >= grid_size.y):
				# on ground
				continue

			var cell = cells[x][y]

			if (cell == null):
				# is null
				continue

			var bottom_cell = new_cells[x][y + 1]
			
			# first fill bottom:
			if (bottom_cell == null):
				# cells[x][y] = null
				new_cells[x][y] = null
				new_cells[x][y + 1] = cells[x][y]

				var new_pos = calc_cell_pos(x, y + 1)
				cell.set_global_position(new_pos)
				continue

			# second handle corners:
			
			if (x + 1 >= grid_size.x):
				var left_cell = new_cells[x - 1][y + 1]

				if (left_cell == null):
					# cells[x][y] = null
					new_cells[x][y] = null
					new_cells[x - 1][y + 1] = cells[x][y]

					var new_pos = calc_cell_pos(x - 1, y + 1)
					cell.set_global_position(new_pos)
					continue
				continue
			elif (x - 1 < 0):
				var right_cell = new_cells[x + 1][y + 1]

				if (right_cell == null):
					# cells[x][y] = null
					new_cells[x][y] = null
					new_cells[x + 1][y + 1] = cells[x][y]

					var new_pos = calc_cell_pos(x + 1, y + 1)
					cell.set_global_position(new_pos)
					continue
				continue
			
			# third handle both directions:

			var right_cell = new_cells[x + 1][y + 1]
			var left_cell = new_cells[x - 1][y + 1]
			var n = rng.randf()

			if (right_cell == null and left_cell != null):
				# cells[x][y] = null
				new_cells[x][y] = null
				new_cells[x + 1][y + 1] = cells[x][y]

				var new_pos = calc_cell_pos(x + 1, y + 1)
				cell.set_global_position(new_pos)
				continue
			elif (left_cell == null and right_cell != null):
				# cells[x][y] = null
				new_cells[x][y] = null
				new_cells[x - 1][y + 1] = cells[x][y]

				var new_pos = calc_cell_pos(x - 1, y + 1)
				cell.set_global_position(new_pos)
				continue
			elif (left_cell == null and right_cell == null):
				if (n < 0.5):
					# cells[x][y] = null
					new_cells[x][y] = null
					new_cells[x - 1][y + 1] = cells[x][y]

					var new_pos = calc_cell_pos(x - 1, y + 1)
					cell.set_global_position(new_pos)
					continue
				else:
					# cells[x][y] = null
					new_cells[x][y] = null
					new_cells[x + 1][y + 1] = cells[x][y]

					var new_pos = calc_cell_pos(x + 1, y + 1)
					cell.set_global_position(new_pos)
					continue
	
	cells = new_cells

func _process(_delta):
	handle_input()
	move_cells()
