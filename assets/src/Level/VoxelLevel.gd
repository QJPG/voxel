#Se vc sair das chunks irá flutuar igual a gravidade e depois de alguns segundos "sem oxigenio" vai levar dano e morrer :


extends Node

const VOXEL_SIZE: float = 0.3
const CHUNK_SIZE: int = 10

var Chunks: Array = Array()

var ChunkScript = preload("res://assets/src/Level/VoxelChunk.gd")

var Width: int = 0
var Height: int = 0
var Depth: int = 0

var Gravity: float = -1

func GenerateVoxelLevel(_Width: int, _Height: int, _Depth: int):
	
	Width = _Width
	Height = _Height
	Depth = _Depth
	
	Chunks.resize(Width * Height * Depth)
	
	var Noise = OpenSimplexNoise.new()
	#Noise.seed = 4
	#Noise.octaves = 4
	#Noise.period = 20.2
	
	var SpawnPlayerChunkX = LoadScript.rng.randi_range(0, Width - 1)
	var SpawnPlayerChunkY = LoadScript.rng.randi_range(0, Height - 1)
	var SpawnPlayerChunkZ = LoadScript.rng.randi_range(0, Depth - 1)
	
	for x in range(Width):
		for y in range(Height):
			for z in range(Depth):
				var NewChunk = ChunkScript.new()
				
				NewChunk.name = "VoxelChunk"
				
				NewChunk.Width = CHUNK_SIZE
				NewChunk.Height = CHUNK_SIZE
				NewChunk.Depth = CHUNK_SIZE
				
				NewChunk.WorldX = x
				NewChunk.WorldY = y
				NewChunk.WorldZ = z
				
				NewChunk.Start()
				
				if (x == SpawnPlayerChunkX && y == SpawnPlayerChunkY && z == SpawnPlayerChunkZ):
					LoadScript.Player = preload("res://assets/src/Player.gd").new()
					LoadScript.Player.VoxelLevel = self
					LoadScript.Player.set_process(false)
					
					print("placed player")
				
				for cx in range(NewChunk.Width):
					for cy in range(NewChunk.Height):
						for cz in range(NewChunk.Depth):
							
							var col = Color.transparent
							
							#NewChunk.SetVoxel(cx, cy, cz, col)
							
							var height = int(Noise.get_noise_2d(cx + (x * NewChunk.Width), cz + (z * NewChunk.Depth)) * Height * (Height)) #((cx + (x * Width)), (cy + (y * Height)), (cz + (z * Depth)))
								
							if cy + (y * Height) <= height:
								var grayScale = rand_range(0.8, 1.0)
							
								col = Color(6, 1, 6) * grayScale
								col.a = 1
							else:
								if (LoadScript.Player && !LoadScript.Player.is_inside_tree()):
									get_parent().add_child(LoadScript.Player)
									
									LoadScript.Player.global_transform.origin = Vector3(cx + (x * (NewChunk.Width * VOXEL_SIZE)), cy + (y * (NewChunk.Height * VOXEL_SIZE)), cz + (z * (NewChunk.Depth * VOXEL_SIZE)))
							
							NewChunk.SetVoxel(cx, cy, cz, col)
				
				NewChunk.GenerateVoxelMesh(VOXEL_SIZE)
				
				Chunks[x + y * Width + z * Width * Height] = NewChunk

func GetChunk(x, y, z) -> MeshInstance:
	if (x < 0 || y < 0 || z < 0 || x >= Width || y >= Height || z >= Depth):
		return null
	
	return Chunks[x + y * Width + z * Width * Height]

func _init():
	pass

func _ready():
	pass

func _process(delta):
	pass
