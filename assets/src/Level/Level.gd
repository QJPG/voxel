extends Node

const CHUNK_SIZE = 6
const CHUNK_SIZE_W = CHUNK_SIZE
const CHUNK_SIZE_H = CHUNK_SIZE
const CHUNK_SIZE_D = CHUNK_SIZE

var sTool = SurfaceTool.new()

var chunks: Array = Array()
var blocks: Array = Array()
var chunkInstances: Array = Array()
var w = 0
var h = 0
var d = 0

var blockVertices = []
var blockUVs = []
var blockNormals = []

var Chunk = preload("res://assets/src/Level/Chunk.gd")

var vertices = Array()

var airBlock = AirBlock.new(0)
var grassBlock = GrassBlock.new(1)
var connectBlock = ConnectBlock.new(2)

class Box3d:
	var position: Vector3
	var size: Vector3
	
	func _init(x, y, z, w, h, d):
		self.position.x = x
		self.position.y = y
		self.position.z = z
		
		self.size.x = w
		self.size.y = h
		self.size.z = d
	
	func intersects(box: Box3d):
		return ((self.position.x + self.size.x >= box.position.x) && (self.position.y + self.size.y >= box.position.y) && (self.position.z + self.size.z >= box.position.z) &&
			(box.position.x + box.size.x >= self.position.x) && (box.position.y + box.size.y >= self.position.y) && (box.position.z + box.size.z >= self.position.z))

class Block:
	const blocks = Array()
	const BLOCK_SIZE = 1

	var id = 0

	func _init(id: int):
		self.id = id
		
		Block.blocks.push_back(self)

	func generate(chunk, x, y, z) -> Array:
		return _generate(chunk, x, y, z)

	func _generate(chunk, x, y, z) -> Array:
		return []

	func tick(delta):
		_tick(delta)

	func _tick(delta):
		pass

	func mayPass() -> bool:
		return _mayPass()

	func _mayPass():
		return false
	
	func bounding(x, y, z) -> Box3d:
		return null


class AirBlock extends Block:
	func _init(id).(id):
		pass
		
	func _generate(chunk, x, y, z) -> Array:
		return []
	
	func _mayPass():
		return true

class GrassBlock extends Block:
	func _init(id).(id):
		pass
	
	func _mayPass():
		return false
	
	func _generate(chunk, x, y, z):
		var center = Vector3(x, y, z) * Block.BLOCK_SIZE
		
		var a = (Vector3(0, 1, 0) + center)
		var b = (Vector3(1, 1, 0) + center)
		var c = (Vector3(1, 0, 0) + center)
		var d = (Vector3(0, 0, 0) + center)
		var e = (Vector3(0, 1, 1) + center)
		var f = (Vector3(1, 1, 1) + center)
		var g = (Vector3(1, 0, 1) + center)
		var h = (Vector3(0, 0, 1) + center)

		var faces = [
				[a, d, c, c, b, a], #BACK
				[h, e, f, f, g, h], #FRONT
				[e, a, b, b, f, e], #TOP
				[d, h, g, g, c, d], #BOTTOM
				[e, h, d, d, a, e], #LEFT
				[b, c, g, g, f, b]  #RIGHT
		]
		
		var offset = Vector2(0, 0)
		
		var factor = 1 #0.08 / 8
		
		var uvs = [
				Vector2(0, 1) * factor,
				Vector2(0, 0) * factor,
				Vector2(1, 0) * factor,
				
				Vector2(1, 0) * factor,
				Vector2(1, 1) * factor,
				Vector2(0, 1) * factor
		]
		
		var normals = [
			Vector3.BACK,
			Vector3.FORWARD,
			Vector3.UP,
			Vector3.DOWN,
			Vector3.LEFT,
			Vector3.RIGHT
		]
		
		return [faces, uvs, normals]
	
	func bounding(x, y, z) -> Box3d:
		return Box3d.new(x, y, z, 1, 1, 1)

class ConnectBlock extends Block:
	func _init(id).(id):
		pass
	
	func _mayPass():
		return false
	
	func _generate(chunk, x, y, z) -> Array:
		
		var longx = 0.5
		var longy = 1
		var longz = 0.5
		
		var offsetx = 0.25
		var offsety = 0.0
		var offsetz = 0.25
		
		var _w = chunk.getBlockOrNextChunkBlock(x, y, z,-1, 0, 0)
		var _e = chunk.getBlockOrNextChunkBlock(x, y, z, 1, 0, 0)
		var _n = chunk.getBlockOrNextChunkBlock(x, y, z, 0, 0,-1)
		var _s = chunk.getBlockOrNextChunkBlock(x, y, z, 0, 0, 1)
		var _t = chunk.getBlockOrNextChunkBlock(x, y, z, 0,-1, 0)
		var _d = chunk.getBlockOrNextChunkBlock(x, y, z, 0, 1, 0)
		
		if _w.id == self.id && _e.id == self.id:
			longx = 1.0
			offsetx = 0.0
		
		elif _w.id == self.id && _e.id != self.id:
			longx = 0.5
			offsetx = 0.0
		
		elif _w.id != self.id && _e.id == self.id:
			longx = 0.5
			offsetx = 0.5
		
		if _n.id == self.id && _s.id == self.id:
			longz = 1.0
			offsetz = 0.0
		
		elif _n.id == self.id && _s.id != self.id:
			longz = 0.5
			offsetz = 0.0
		
		elif _n.id != self.id && _s.id == self.id:
			longz = 0.5
			offsetz = 0.5
		
		var fc = Vector3(longx, longy, longz)
		
		var siz = 1
		
		var center = Vector3(x + (offsetx), y, z + (offsetz)) * Block.BLOCK_SIZE
		
		var a = (Vector3(0.0, siz, 0.0) * fc + center)
		var b = (Vector3(siz, siz, 0.0) * fc + center)
		var c = (Vector3(siz, 0.0, 0.0) * fc + center)
		var d = (Vector3(0.0, 0.0, 0.0) * fc + center)
		var e = (Vector3(0.0, siz, siz) * fc + center)
		var f = (Vector3(siz, siz, siz) * fc + center)
		var g = (Vector3(siz, 0.0, siz) * fc + center)
		var h = (Vector3(0.0, 0.0, siz) * fc + center)

		var faces = [
				[a, d, c, c, b, a], #BACK
				[h, e, f, f, g, h], #FRONT
				[e, a, b, b, f, e], #TOP
				[d, h, g, g, c, d], #BOTTOM
				[e, h, d, d, a, e], #LEFT
				[b, c, g, g, f, b]  #RIGHT
		]
		
		var offset = Vector2(0, 0)
		
		var factor = 1 #0.08 / 8
		
		var uvs = [
				Vector2(0, 1) * factor,
				Vector2(0, 0) * factor,
				Vector2(1, 0) * factor,
				
				Vector2(1, 0) * factor,
				Vector2(1, 1) * factor,
				Vector2(0, 1) * factor
		]
		
		var normals = [
			Vector3.BACK,
			Vector3.FORWARD,
			Vector3.UP,
			Vector3.DOWN,
			Vector3.LEFT,
			Vector3.RIGHT
		]
		
		return [faces, uvs, normals]
	
	func bounding(x, y, z):
		return Box3d.new(x + 0.25, y, z + 0.25, 0.5, 1, 0.5)


class VertexManager:
	var material = null
	var vertices: Array
	var UVs: Array
	
	func _init():
		pass
	
	func setMaterial(material):
		self.material = material
	
	func clear(includes_material = false):
		self.vertices.clear()
		self.UVs.clear()
		
		if includes_material:
			self.material = null


func create() -> bool:
	chunks.resize(w * h * d)
	
	for x in range(w):
		for y in range(h):
			for z in range(d):
				
				var chunk: MeshInstance = Chunk.new()
				
				chunk.level = self
				chunk.name = "%s_%s_%s" % [x, y, z]
				
				chunk.width = CHUNK_SIZE_W
				chunk.height = CHUNK_SIZE_H
				chunk.depth = CHUNK_SIZE_D
				
				chunk.init(x, y, z)
				
				for xc in range(chunk.width):
					for yc in range(chunk.height):
						for zc in range(chunk.depth):
							
							var seedBlock = LoadScript.rng.randi_range(0, 10)
							
							var selectBlockId = airBlock.id
							
							if y == 0 || y == 3:
								if yc == 0:
									selectBlockId = grassBlock.id
							
								elif yc == 1:
									if seedBlock < 2:
										selectBlockId = connectBlock.id
							
							chunk.setBlock(xc, yc, zc, selectBlockId)
				
				chunk.generateMesh()
				
				chunks[x + y * w + z * w * h] = chunk
	
	return true

func getMeshByVertices(vertices, UVs) -> ArrayMesh:
	sTool.clear()
	
	sTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in range(UVs.size()):
		sTool.add_uv(UVs[i])
	
	for i in range(vertices.size()):
		sTool.add_vertex(vertices[i])
	
	sTool.generate_normals(false)
	
	return sTool.commit()

func getBlocksMesh():
	sTool.clear()
	
	sTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in range(blockUVs.size()):
		pass
	
	for i in range(blockVertices.size()):
		sTool.add_uv(blockUVs[i % 6])
		sTool.add_vertex(blockVertices[i])
	
	
	sTool.generate_normals(false)
	sTool.generate_tangents()
	sTool.index()
	
	return sTool.commit()

func getChunk(x, y, z):
	if (x < 0 || y < 0 || z < 0 || x >= w || y >= h || z >= d):
		return
	
	return chunks[x + y * w + z * w * h]

func getBlock(x, y, z):
	
	var xc: int = floor(x / CHUNK_SIZE_W)
	var yc: int = floor(y / CHUNK_SIZE_H)
	var zc: int = floor(z / CHUNK_SIZE_D)
	
	var chunk = getChunk(xc, yc, zc)
	
	if !chunk:
		return airBlock
	
	return chunk.getBlock(floor(x % chunk.width), floor(y % chunk.height), floor(z % chunk.depth))

func _init():
	vertices.resize(256) #Block.blocks.size())
	
	vertices[grassBlock.id] = VertexManager.new()
	vertices[grassBlock.id].setMaterial(SpatialMaterial.new())
	vertices[grassBlock.id].material.albedo_texture = LoadScript.ImageAtlasTexture.new()
	vertices[grassBlock.id].material.albedo_texture.set_atlas(preload("res://assets/images/graphics.png"))
	vertices[grassBlock.id].material.albedo_texture.set_region(Rect2(8, 0, 8, 8))
	vertices[grassBlock.id].material.params_cull_mode = SpatialMaterial.CULL_BACK
	
	vertices[connectBlock.id] = VertexManager.new()
	vertices[connectBlock.id].setMaterial(SpatialMaterial.new())
	vertices[connectBlock.id].material.albedo_texture = LoadScript.ImageAtlasTexture.new()
	vertices[connectBlock.id].material.albedo_texture.set_atlas(preload("res://assets/images/graphics.png"))
	vertices[connectBlock.id].material.albedo_texture.set_region(Rect2(16, 0, 8, 8))
	vertices[connectBlock.id].material.params_cull_mode = SpatialMaterial.CULL_BACK
	
func _ready():
	pass

var chunkBox = LoadScript.Render.getMeshCube(CHUNK_SIZE_W, CHUNK_SIZE_H, CHUNK_SIZE_D)

func _process(delta):
	var xpc = floor(LoadScript.Player.getPosition().x / CHUNK_SIZE_W)
	var ypc = floor(LoadScript.Player.getPosition().y / CHUNK_SIZE_H)
	var zpc = floor(LoadScript.Player.getPosition().z / CHUNK_SIZE_D)
	
	var chunk = getChunk(xpc, ypc, zpc)
	
	if chunk:
		#LoadScript.Player.onChunk = chunk
		
		#LoadScript.Render.drawMesh(xpc * CHUNK_SIZE_W, ypc * CHUNK_SIZE_H, zpc * CHUNK_SIZE_D, chunkBox)
		
		#LoadScript.Render.drawFont("chunk:%s %s %s" % [xpc, ypc, zpc], 0, 16, Color.blue)
		
		var xpb: int = floor(LoadScript.Player.getPosition().x / Block.BLOCK_SIZE)
		var ypb: int = floor(LoadScript.Player.getPosition().y / Block.BLOCK_SIZE)
		var zpb: int = floor(LoadScript.Player.getPosition().z / Block.BLOCK_SIZE)
		
		#LoadScript.gfx.drawFont("p. chunk: x = %s y = %s z = %s block: %s FPS: %s" % [floor(xpb - xpc * chunk.width), floor(ypb - ypc * chunk.height), floor(zpb - zpc * chunk.depth), -0, Engine.get_frames_per_second()], 0, 16 * 2, Color.red)
	
		var onBlock = chunk.getBlock(xpb, ypb, zpb)
		
		#LoadScript.gfx.drawFont("block:%s" % [onBlock.id], 0, 16 * 3, Color.green)
	
	
