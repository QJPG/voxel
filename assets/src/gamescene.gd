extends Spatial

var level = load("res://assets/src/Level/Level.gd").new()
var Chunk = load("res://assets/src/Level/Chunk.gd")

#onready var curCube = LoadScript.gfx.getMeshCube(level.Block.BLOCK_SIZE, level.Block.BLOCK_SIZE, level.Block.BLOCK_SIZE)

var VoxelLevelScript = preload("res://assets/src/Level/VoxelLevel.gd").new()

var worldGenTr = Thread.new()

signal builded

var buildingWorld = false

func onWorldGen():
	buildingWorld = true
	
	VoxelLevelScript.GenerateVoxelLevel(7, 7, 7)
	
	emit_signal("builded")
	
	buildingWorld = false
	
	print(LoadScript.Player)

func _ready():
	
	add_child(VoxelLevelScript)
	
	worldGenTr.start(self, "onWorldGen")
	
	connect("builded", self, "onWorldBuilded")
	
	
	$CursorMesh.mesh = ArrayMesh.new()
	
	var cube = CubeMesh.new()
	cube.size = Vector3(0.3, 0.3, 0.3)
	
	$CursorMesh.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINE_STRIP, cube.get_mesh_arrays())
	
	$CursorMesh.material_override = SpatialMaterial.new()
	$CursorMesh.material_override.vertex_color_use_as_albedo = true
	$CursorMesh.material_override.flags_unshaded = true
	
	#$MeshInstance.material_override.flags_transparent = true
	#$MeshInstance.material_override.albedo_texture = preload("res://icon.png")
	#$MeshInstance.material_override.params_cull_mode  =SpatialMaterial.CULL_BACK

func onWorldBuilded():
	for chunk in VoxelLevelScript.Chunks:
		add_child(chunk)
		chunk.global_transform.origin = Vector3(chunk.WorldX, chunk.WorldY, chunk.WorldZ) * (Vector3(chunk.Width, chunk.Height, chunk.Depth) * VoxelLevelScript.VOXEL_SIZE)
	
	print("chunks added")
	
	LoadScript.Player.set_process(true)

func _process(delta):
	LoadScript.Render.DrawTextFont("%s" % [Engine.get_frames_per_second()], Vector2(0, OS.window_size.y - 0))
	
	if buildingWorld:
		LoadScript.Render.DrawTextFont("buinding...", Vector2((OS.window_size.x - (11 * 16)) / 2 , OS.window_size.y / 2))

func _exit_tree():
	worldGenTr.wait_to_finish()
