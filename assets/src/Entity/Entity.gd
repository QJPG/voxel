extends Spatial

var JumpForce: float = 1.5
var Vel: Vector3
var VoxelLevel = null
var isOnFloor = false
var Mass: int = 4

func _init():
	pass

func _ready():
	pass

func _process(delta):
	pass

func Move(dx, dy, dz, delta):
	if (dx != 0): Move2(dx, 0, 0, delta)
	if (dy != 0): Move2(0, dy, 0, delta)
	if (dz != 0): Move2(0, 0, dz, delta)

func Move2(dx, dy, dz, delta):
	var VXZ = VoxelLevel.VOXEL_SIZE
	var chunkSize = int(VoxelLevel.CHUNK_SIZE * VXZ)
	
	var x:int = floor((GetOrigin().x + dx) / VXZ)
	var y:int = floor((GetOrigin().y + dy) / VXZ)
	var z:int = floor((GetOrigin().z + dz) / VXZ)
	
	var x0 = floor((GetOrigin().x + dx) / chunkSize)
	var y0 = floor((GetOrigin().y + dy) / chunkSize)
	var z0 = floor((GetOrigin().z + dz) / chunkSize)
	
	var OnChunk = VoxelLevel.GetChunk(x0, y0, z0)
	
	if (dy != 0):
		if not isOnFloor:
			if Vel.y > -2:
				Vel.y += VoxelLevel.Gravity * delta * Mass
		
		isOnFloor = false
	
	if (OnChunk):
		
		var xx = x - (OnChunk.WorldX * OnChunk.Width)
		var yy = y - (OnChunk.WorldY * OnChunk.Height)
		var zz = z - (OnChunk.WorldZ * OnChunk.Depth)
		
		var VoxelCol = OnChunk.GetVoxel(xx, yy, zz)
		
		if (VoxelCol != Color.transparent):
			#print("%s %s %s" % [xx,yy,zz])
			
			if (dz != 0 || dx != 0):
				Vel.y = JumpForce
			
			if (dy < 0):
				isOnFloor = true
				
			return false
	
	global_transform.origin += Vector3(dx, dy, dz)
	
	return true

func SetOrigin(x, y, z) -> void:
	global_transform.origin = Vector3(x, y, z)

func GetOrigin() -> Vector3:
	return global_transform.origin
