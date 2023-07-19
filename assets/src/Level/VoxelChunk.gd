extends MeshInstance

var Width: int = 0
var Height: int = 0
var Depth: int = 0

var WorldX: int = 0
var WorldY: int = 0
var WorldZ: int = 0

var Voxels: Array = Array()

func Start():
	Voxels.resize(Width * Height * Depth)

func SetVoxel(x, y, z, col) -> void:
	if (x < 0 || y < 0 || z < 0 || x >= Width || y >= Height || z >= Depth):
		return
	
	Voxels[x + y * Width + z * Width * Height] = col

func GetVoxel(x, y, z) -> Color:
	if (x < 0 || y < 0 || z < 0 || x >= Width || y >= Height || z >= Depth):
		return Color.transparent
	
	return Voxels[x + y * Width + z * Width * Height]

func GenerateVoxelMesh(VoxelSize: float):
	var Surface = SurfaceTool.new()
	Surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var Mat = SpatialMaterial.new()
	Mat.vertex_color_use_as_albedo = true
	Mat.params_cull_mode = SpatialMaterial.CULL_BACK
	
	Surface.set_material(Mat)
	
	for x in range(Width):
		for y in range(Height):
			for z in range(Depth):
				var VoxelColor = GetVoxel(x, y, z)
				
				if VoxelColor == Color.transparent:
					continue
				
				var VSZ = VoxelSize
				var center = Vector3(x, y, z) * VSZ
			
				var a = (Vector3(0.0, VSZ, 0.0) + center)
				var b = (Vector3(VSZ, VSZ, 0.0) + center)
				var c = (Vector3(VSZ, 0.0, 0.0) + center)
				var d = (Vector3(0.0, 0.0, 0.0) + center)
				var e = (Vector3(0.0, VSZ, VSZ) + center)
				var f = (Vector3(VSZ, VSZ, VSZ) + center)
				var g = (Vector3(VSZ, 0.0, VSZ) + center)
				var h = (Vector3(0.0, 0.0, VSZ) + center)

				var faces = [
						[a, d, c, c, b, a], #BACK
						[h, e, f, f, g, h], #FRONT
						[e, a, b, b, f, e], #TOP
						[d, h, g, g, c, d], #BOTTOM
						[e, h, d, d, a, e], #LEFT
						[b, c, g, g, f, b]  #RIGHT
				]
				
				var backFace = GetVoxel(x, y, (z - 1))
				var frontFace = GetVoxel(x, y, (z + 1))
				var leftFace = GetVoxel((x - 1), y, z)
				var rightFace = GetVoxel((x + 1), y, z)
				var topFace = GetVoxel(x, (y + 1), z)
				var bottomFace = GetVoxel(x, (y - 1), z)
				
				var newFace = []
				
				if (topFace == Color.transparent):
					newFace.append(faces[2])
				
				if (bottomFace == Color.transparent):
					newFace.append(faces[3])
				
				if (backFace == Color.transparent):
					newFace.append(faces[0])
				
				if (frontFace == Color.transparent):
					newFace.append(faces[1])
				
				if (leftFace == Color.transparent):
					newFace.append(faces[4])
				
				if (rightFace == Color.transparent):
					newFace.append(faces[5])
				
				faces = newFace
				
				var factor = 1
				
				var uvs = [
						Vector2(0, 1) * factor,
						Vector2(0, 0) * factor,
						Vector2(1, 0) * factor,
						
						Vector2(1, 0) * factor,
						Vector2(1, 1) * factor,
						Vector2(0, 1) * factor
				]
				
				for i in range(faces.size()):
					for j in range(faces[i].size()):
						Surface.add_color(VoxelColor)
						Surface.add_uv(uvs[j])
						Surface.add_vertex(faces[i][j])
				
	Surface.generate_normals()
	
	mesh = Surface.commit()

func _init():
	lod_max_distance = 1.0
	lod_min_distance = 0.5

func _ready():
	pass

func _process(delta):
	pass
