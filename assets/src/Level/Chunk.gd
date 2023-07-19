extends MeshInstance

var blocks: Array = Array()

var width: int = 0
var height: int = 0
var depth: int = 0

var worldX: int = 0
var worldY: int = 0
var worldZ: int = 0

var surfaceTool: SurfaceTool = SurfaceTool.new()

var level = null

var hitboxes: Array = Array()

func _init():
	pass

func _ready():
	pass

func _process(delta):
	pass

func init(xc, yc, zc, biome = 0):
	blocks.resize(width * height * depth)
	
	worldX = xc
	worldY = yc
	worldZ = zc

func generateVertices():
	var meshTemp = ArrayMesh.new()
	
	hitboxes.clear()
	
	for i in range(level.vertices.size()):
		surfaceTool.clear()
		surfaceTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
		if level.vertices[i] == null:
			continue
		
		#level.vertices[i].clear()
		
		#surfaceTool.set_material(vertices[i].material)
		
		for x in range(width):
			for y in range(height):
				for z in range(depth):
						
						var block = getBlock(x, y, z)
						
						var data = block.generate(self, x, y, z)
						
						hitboxes.append(block.bounding(x + (worldX * width), y + (worldY * height), z + (worldZ * depth)))
						
						if i != block.id:
							continue
						
						if data.size() > 0:
							for i0 in range(data[0].size()):
								for j0 in range(data[0][i0].size()):
									
									surfaceTool.add_uv(data[1][j0])
									surfaceTool.add_normal(data[2][j0])
									surfaceTool.add_vertex(data[0][i0][j0])
		
		
		surfaceTool.generate_normals()
		
		var array = surfaceTool.commit_to_arrays()
		
		if array[ArrayMesh.ARRAY_VERTEX]:
			meshTemp.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array)
			meshTemp.surface_set_material(meshTemp.get_surface_count() - 1, level.vertices[i].material)
	
	return meshTemp

func generateMesh():
	
	var cacheMesh = generateVertices()
	
	"""
	for x in range(width):
		for y in range(height):
			for z in range(depth):
				
				var data = getBlock(x, y, z).generate(x, y, z)
				
				if data.size() > 0:
					for i in range(data[0].size()):
						for j in range(data[0][i].size()):
							surfaceTool.add_uv(data[1][j])
							surfaceTool.add_vertex(data[0][i][j])
	"""
	
	mesh = cacheMesh

func reload():
	generateMesh()

func isOutOfChunk(x, y, z) -> bool:
	return (x < 0 || y < 0 || z < 0 || x >= width || y >= height || z >= depth)

func setBlock(x, y, z, block: int):
	if (x < 0 || y < 0 || z < 0 || x >= width || y >= height || z >= depth):
		return
	
	blocks[x + y * width + z * width * height] = block
	
	if block != level.connectBlock.id:
		return
	
	LoadScript.Throw(level.getChunk(worldX - 1, worldY, worldZ), "reload")
	LoadScript.Throw(level.getChunk(worldX, worldY - 1, worldZ), "reload")
	LoadScript.Throw(level.getChunk(worldX , worldY, worldZ - 1), "reload")
	LoadScript.Throw(level.getChunk(worldX - 1, worldY - 1, worldZ - 1), "reload")
	
	LoadScript.Throw(level.getChunk(worldX + 1, worldY, worldZ), "reload")
	LoadScript.Throw(level.getChunk(worldX, worldY + 1, worldZ), "reload")
	LoadScript.Throw(level.getChunk(worldX, worldY, worldZ + 1), "reload")
	LoadScript.Throw(level.getChunk(worldX + 1, worldY + 1, worldZ + 1), "reload")

func getBlock(x, y, z):
	if (x < 0 || y < 0 || z < 0 || x >= width || y >= height || z >= depth):
		return level.airBlock
	
	return level.Block.blocks[blocks[x + y * width + z * width * height]]

func getBlockOrNextChunkBlock(x, y, z, dx, dy, dz):
	
	var xb = ((x + dx) + width * worldX) / width
	var yb = ((y + dy) + height * worldY) / height
	var zb = ((z + dz) + depth * worldZ) / depth
	
	var nextChunk = level.getChunk(xb, yb, zb)
	
	var x0 = x + dx
	var y0 = y + dy
	var z0 = z + dz
	
	if (x0 < 0): x0 = width - 1
	if (x0 >= width): x0 = 0
	
	if (y0 < 0): y0 = height - 1
	if (y0 >= height): y0 = 0
	
	if (z0 < 0): z0 = depth - 1
	if (z0 >= depth): z0 = 0
	
	if !nextChunk:
		return getBlock(x0, y0, z0)
	
	var block = nextChunk.getBlock(x0, y0, z0)
	
	return block
