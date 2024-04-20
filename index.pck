GDPC                @                                                                      	   d   res://.godot/exported/133200997/export-d11ecae8051ee0fbdc2b7042b01e28a5-falling_sand_simulator.scn        �      �0ڔ�-g��ux7�3��    ,   res://.godot/global_script_class_cache.cfg  0%             ��Р�8���8~$}P�    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex      �      �Yz=������������       res://.godot/uid_cache.bin  )      K       ��W���;�������5        res://falling_sand_simulator.gd               2P������`��$y�    (   res://falling_sand_simulator.tscn.remap �$      s       �|ad�a��L��f       res://icon.svg  P%      �      C��=U���^Qu��U3       res://icon.svg.import   �#      �       	��_{S	;4�8w��       res://project.binary`)      �      �ǲ1>"ld.{��#%    extends Control

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
         RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name    tile_shape    tile_layout    tile_offset_axis 
   tile_size    uv_clipping    tile_proxies/source_level    tile_proxies/coords_level    tile_proxies/alternative_level    script 	   _bundled       Script     res://falling_sand_simulator.gd ��������      local://TileSet_jtl2q �         local://PackedScene_6jm8e          TileSet    
         PackedScene          	         names "         FallingSandSimulator    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    script    Control    Background    offset_right    offset_bottom    color 
   ColorRect    TileMap 	   tile_set    rendering_quadrant_size    collision_visibility_mode    navigation_visibility_mode    format    CellContainer    	   variants    
                    �?                            B                 �?                       node_count             nodes     B   ��������       ����                                                             	   ����         
                                    ����                                                   ����      	   
                      conn_count              conns               node_paths              editable_instances              version       
      RSRC          GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�$�n윦���z�x����դ�<����q����F��Z��?&,
ScI_L �;����In#Y��0�p~��Z��m[��N����R,��#"� )���d��mG�������ڶ�$�ʹ���۶�=���mϬm۶mc�9��z��T��7�m+�}�����v��ح����mow�*��f�&��Cp�ȑD_��ٮ}�)� C+���UE��tlp�V/<p��ҕ�ig���E�W�����Sթ�� ӗ�A~@2�E�G"���~ ��5tQ#�+�@.ݡ�i۳�3�5�l��^c��=�x�Н&rA��a�lN��TgK㼧�)݉J�N���I�9��R���$`��[���=i�QgK�4c��%�*�D#I-�<�)&a��J�� ���d+�-Ֆ
��Ζ���Ut��(Q�h:�K��xZ�-��b��ٞ%+�]�p�yFV�F'����kd�^���:[Z��/��ʡy�����EJo�񷰼s�ɿ�A���N�O��Y��D��8�c)���TZ6�7m�A��\oE�hZ�{YJ�)u\a{W��>�?�]���+T�<o�{dU�`��5�Hf1�ۗ�j�b�2�,%85�G.�A�J�"���i��e)!	�Z؊U�u�X��j�c�_�r�`֩A�O��X5��F+YNL��A��ƩƗp��ױب���>J�[a|	�J��;�ʴb���F�^�PT�s�)+Xe)qL^wS�`�)%��9�x��bZ��y
Y4�F����$G�$�Rz����[���lu�ie)qN��K�<)�:�,�=�ۼ�R����x��5�'+X�OV�<���F[�g=w[-�A�����v����$+��Ҳ�i����*���	�e͙�Y���:5FM{6�����d)锵Z�*ʹ�v�U+�9�\���������P�e-��Eb)j�y��RwJ�6��Mrd\�pyYJ���t�mMO�'a8�R4��̍ﾒX��R�Vsb|q�id)	�ݛ��GR��$p�����Y��$r�J��^hi�̃�ūu'2+��s�rp�&��U��Pf��+�7�:w��|��EUe�`����$G�C�q�ō&1ŎG�s� Dq�Q�{�p��x���|��S%��<
\�n���9�X�_�y���6]���մ�Ŝt�q�<�RW����A �y��ػ����������p�7�l���?�:������*.ո;i��5�	 Ύ�ș`D*�JZA����V^���%�~������1�#�a'a*�;Qa�y�b��[��'[�"a���H�$��4� ���	j�ô7�xS�@�W�@ ��DF"���X����4g��'4��F�@ ����ܿ� ���e�~�U�T#�x��)vr#�Q��?���2��]i�{8>9^[�� �4�2{�F'&����|���|�.�?��Ȩ"�� 3Tp��93/Dp>ϙ�@�B�\���E��#��YA 7 `�2"���%�c�YM: ��S���"�+ P�9=+D�%�i �3� �G�vs�D ?&"� !�3nEФ��?Q��@D �Z4�]�~D �������6�	q�\.[[7����!��P�=��J��H�*]_��q�s��s��V�=w�� ��9wr��(Z����)'�IH����t�'0��y�luG�9@��UDV�W ��0ݙe)i e��.�� ����<����	�}m֛�������L ,6�  �x����~Tg����&c�U��` ���iڛu����<���?" �-��s[�!}����W�_�J���f����+^*����n�;�SSyp��c��6��e�G���;3Z�A�3�t��i�9b�Pg�����^����t����x��)O��Q�My95�G���;w9�n��$�z[������<w�#�)+��"������" U~}����O��[��|��]q;�lzt�;��Ȱ:��7�������E��*��oh�z���N<_�>���>>��|O�׷_L��/������զ9̳���{���z~����Ŀ?� �.݌��?�N����|��ZgO�o�����9��!�
Ƽ�}S߫˓���:����q�;i��i�]�t� G��Q0�_î!�w��?-��0_�|��nk�S�0l�>=]�e9�G��v��J[=Y9b�3�mE�X�X�-A��fV�2K�jS0"��2!��7��؀�3���3�\�+2�Z`��T	�hI-��N�2���A��M�@�jl����	���5�a�Y�6-o���������x}�}t��Zgs>1)���mQ?����vbZR����m���C��C�{�3o��=}b"/�|���o��?_^�_�+��,���5�U��� 4��]>	@Cl5���w��_$�c��V��sr*5 5��I��9��
�hJV�!�jk�A�=ٞ7���9<T�gť�o�٣����������l��Y�:���}�G�R}Ο����������r!Nϊ�C�;m7�dg����Ez���S%��8��)2Kͪ�6̰�5�/Ӥ�ag�1���,9Pu�]o�Q��{��;�J?<�Yo^_��~��.�>�����]����>߿Y�_�,�U_��o�~��[?n�=��Wg����>���������}y��N�m	n���Kro�䨯rJ���.u�e���-K��䐖��Y�['��N��p������r�Εܪ�x]���j1=^�wʩ4�,���!�&;ج��j�e��EcL���b�_��E�ϕ�u�$�Y��Lj��*���٢Z�y�F��m�p�
�Rw�����,Y�/q��h�M!���,V� �g��Y�J��
.��e�h#�m�d���Y�h�������k�c�q��ǷN��6�z���kD�6�L;�N\���Y�����
�O�ʨ1*]a�SN�=	fH�JN�9%'�S<C:��:`�s��~��jKEU�#i����$�K�TQD���G0H�=�� �d�-Q�H�4�5��L�r?����}��B+��,Q�yO�H�jD�4d�����0*�]�	~�ӎ�.�"����%
��d$"5zxA:�U��H���H%jس{���kW��)�	8J��v�}�rK�F�@�t)FXu����G'.X�8�KH;���[          [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://5pjjum0r1nyb"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
 [remap]

path="res://.godot/exported/133200997/export-d11ecae8051ee0fbdc2b7042b01e28a5-falling_sand_simulator.scn"
             list=Array[Dictionary]([])
     <svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path fill="#478cbf" d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 813 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H447l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z"/><path d="M483 600c3 34 55 34 58 0v-86c-3-34-55-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
             �	QTweq!   res://falling_sand_simulator.tscn�=�#ר   res://icon.svg     ECFG      application/config/name          falling-sand-simulator     application/run/main_scene,      !   res://falling_sand_simulator.tscn      application/config/features(   "         4.2    GL Compatibility       application/config/icon         res://icon.svg  "   display/window/size/viewport_width      �  #   display/window/size/viewport_height      h     display/window/stretch/mode         viewport!   display/window/stretch/scale_mode         integer #   display/window/handheld/orientation            input/clicked�              deadzone      ?      events              InputEventMouseButton         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          button_mask           position              global_position               factor       �?   button_index         canceled          pressed           double_click          script      #   rendering/renderer/rendering_method         gl_compatibility*   rendering/renderer/rendering_method.mobile         gl_compatibility4   rendering/textures/vram_compression/import_etc2_astc                