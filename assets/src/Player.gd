extends "res://assets/src/Entity/Entity.gd"

var Inventory = preload("res://assets/src/Inventory/Inventory.gd").new()
var camera: Camera = Camera.new()
var raycast: RayCast = RayCast.new()
var flyMode = false
var fly = 0
var flashLight: SpotLight = SpotLight.new()
var SpriteItem: Sprite3D = Sprite3D.new()

#Entity methods

var spaceCounts = 0

var collisionBox = null

var meshHitbox = ArrayMesh.new()

var OnChunk = null

var CountPress = 0

var graphics = preload("res://assets/images/graphics.png")


func angle_basis_(dir):
	return global_transform.basis.x * dir.x + global_transform.basis.z * dir.y

func GetRaycastVoxel(rayOrigin: Vector3, dist: float) -> Array:
	#var rvx:int = floor((rayOrigin.x) / VoxelLevel.VOXEL_SIZE)
	#var rvy:int = floor((rayOrigin.y) / VoxelLevel.VOXEL_SIZE)
	#var rvz:int = floor((rayOrigin.z) / VoxelLevel.VOXEL_SIZE)
	
	#Send the chunk tambem
	
	var ray: Vector3 = rayOrigin
	
	for d in range(0.0, dist):
		ray = raycast.global_transform.xform(Vector3.FORWARD * (d * 0.1))
	
		var rayVoxel: Vector3 = ray / VoxelLevel.VOXEL_SIZE
	
		var rcx:int = floor((ray.x) / int(OnChunk.Width * VoxelLevel.VOXEL_SIZE))
		var rcy:int = floor((ray.y) / int(OnChunk.Height * VoxelLevel.VOXEL_SIZE))
		var rcz:int = floor((ray.z) / int(OnChunk.Depth * VoxelLevel.VOXEL_SIZE))
	
		var RayOnChunk = VoxelLevel.GetChunk(rcx, rcy, rcz)
	
		if !RayOnChunk:
			return []
	
		var x: int = rayVoxel.x - (RayOnChunk.WorldX * (RayOnChunk.Width))
		var y: int = rayVoxel.y - (RayOnChunk.WorldY * (RayOnChunk.Height))
		var z: int = rayVoxel.z - (RayOnChunk.WorldZ * (RayOnChunk.Depth))
	
		var VoxelOnChunk: Color = RayOnChunk.GetVoxel(x, y, z)
		
		if VoxelOnChunk != Color.transparent:
			return [VoxelOnChunk, Vector3(x, y, z), RayOnChunk]
	
	return []

func _init():
	add_child(Inventory)
	add_child(camera)
	
	camera.fov = 100
	camera.transform.origin.y = 1.8
	
	camera.add_child(raycast)
	raycast.cast_to = Vector3.FORWARD * 3
	raycast.enabled = true
	
	camera.add_child(flashLight)
	
	camera.add_child(SpriteItem)
	SpriteItem.transform.origin.x = 0.1
	SpriteItem.transform.origin.z = -0.1
	SpriteItem.rotation_degrees.x = -10
	SpriteItem.rotation_degrees.y = -10
	SpriteItem.transform.origin.y = -0.1
	SpriteItem.texture = graphics
	SpriteItem.region_enabled = true
	SpriteItem.region_rect = Rect2(16, 24, 16, 16)

func _ready():
	#collisionBox = level.Box3d.new(0, 0, 0, 0.5, 1.8, 0.5)
	meshHitbox = LoadScript.gfx.getMeshCube(collisionBox.size.x, collisionBox.size.y, collisionBox.size.z, Color.red)

func _input(event):
	if event is InputEventMouseMotion:
		var rel = event.relative
		
		rotate_y(rel.x * -0.005)
		
		camera.rotate_x(rel.y * -0.005)
		
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
	
func _process(delta):
	
	var impulse = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	
	Vel.x = angle_basis_(impulse).x 
	Vel.z = angle_basis_(impulse).z
	
	#LoadScript.gfx.drawMeshOnInstance(GetOrigin().x - collisionBox.size.x / 2, GetOrigin().y, GetOrigin().z - collisionBox.size.z / 2, meshHitbox, LoadScript.gfx.extraInstance)
	
	
	var x = floor((GetOrigin().x) / int(VoxelLevel.CHUNK_SIZE * VoxelLevel.VOXEL_SIZE))
	var y = floor((GetOrigin().y) / int(VoxelLevel.CHUNK_SIZE * VoxelLevel.VOXEL_SIZE))
	var z = floor((GetOrigin().z) / int(VoxelLevel.CHUNK_SIZE * VoxelLevel.VOXEL_SIZE))
		
	OnChunk = VoxelLevel.GetChunk(x, y, z)
	
	if OnChunk:
		#$
		var xnc = floor((GetOrigin().x) / int(OnChunk.Width * VoxelLevel.VOXEL_SIZE))
		var ync = floor((GetOrigin().y - 1) / int(OnChunk.Height * VoxelLevel.VOXEL_SIZE))
		var znc = floor((GetOrigin().z) / int(OnChunk.Depth * VoxelLevel.VOXEL_SIZE))
		
		var nextChunk = VoxelLevel.GetChunk(xnc, ync, znc)
		
		var xb: int = (GetOrigin().x / VoxelLevel.VOXEL_SIZE) - (OnChunk.WorldX * (OnChunk.Width))
		var yb: int = ((GetOrigin().y) / VoxelLevel.VOXEL_SIZE) - (OnChunk.WorldY * (OnChunk.Height))
		var zb: int = (GetOrigin().z / VoxelLevel.VOXEL_SIZE) - (OnChunk.WorldZ * (OnChunk.Depth))
		
		
		var RayOrigin = raycast.global_transform.xform(raycast.cast_to)
		
		#var xrb: int = int(RayOrigin.x / VoxelLevel.VOXEL_SIZE) % OnChunk.Width #- (OnChunk.WorldX * (OnChunk.Width))
		#var yrb: int = int(RayOrigin.y / VoxelLevel.VOXEL_SIZE) % OnChunk.Height #- (OnChunk.WorldY * (OnChunk.Height))
		#var zrb: int = int(RayOrigin.z / VoxelLevel.VOXEL_SIZE) % OnChunk.Depth #- (OnChunk.WorldZ * (OnChunk.Depth))
		
		#var xrb0: int = int(RayOrigin.x / VoxelLevel.VOXEL_SIZE)# % OnChunk.Width # - (OnChunk.WorldX * (OnChunk.Width))
		#var yrb0: int = int(RayOrigin.y / VoxelLevel.VOXEL_SIZE)# % OnChunk.Height # - (OnChunk.WorldY * (OnChunk.Height))
		#var zrb0: int = int(RayOrigin.z / VoxelLevel.VOXEL_SIZE)# % OnChunk.Depth # - (OnChunk.WorldZ * (OnChunk.Depth))
		
		#get_parent().get_node("CursorMesh").global_transform.origin = Vector3(RayOrigin.x, RayOrigin.y, RayOrigin.z) + Vector3(0.15, 0.15, 0.15)
		
		#var e = raycast.global_transform.xform(raycast.cast_to)
	
		var xb0:int = floor((RayOrigin.x) / VoxelLevel.VOXEL_SIZE)
		var yb0:int = floor((RayOrigin.y) / VoxelLevel.VOXEL_SIZE)
		var zb0:int = floor((RayOrigin.z) / VoxelLevel.VOXEL_SIZE)
		
		var xc:int = floor((RayOrigin.x) / int(OnChunk.Width * VoxelLevel.VOXEL_SIZE))
		var yc:int = floor((RayOrigin.y) / int(OnChunk.Height * VoxelLevel.VOXEL_SIZE))
		var zc:int = floor((RayOrigin.z) / int(OnChunk.Depth * VoxelLevel.VOXEL_SIZE))
		
		#var RayChunk = VoxelLevel.GetChunk(xc, yc, zc)
		
		var rayHit = GetRaycastVoxel(raycast.global_transform.origin, 20.0)
		
		if rayHit.size() > 0:
			get_parent().get_node("CursorMesh").global_transform.origin = (rayHit[1] + Vector3(rayHit[2].WorldX * rayHit[2].Width, rayHit[2].WorldY * rayHit[2].Height, rayHit[2].WorldZ * rayHit[2].Depth)) * VoxelLevel.VOXEL_SIZE + Vector3(0.15, 0.15, 0.15)
			
			if Input.is_action_pressed("mouse1"):
				print("placed %s" % [rayHit[1]])
				
				rayHit[2].SetVoxel(rayHit[1].x, rayHit[1].y, rayHit[1].z, Color.red)
				
				rayHit[2].GenerateVoxelMesh(VoxelLevel.VOXEL_SIZE)
		
		"""
		if RayChunk:
			xb0 = xb0 - (RayChunk.WorldX * (RayChunk.Width))
			yb0 = yb0 - (RayChunk.WorldY * (RayChunk.Height))
			zb0 = zb0 - (RayChunk.WorldZ * (RayChunk.Depth))
			
			if VoxelHitTest != Color.transparent:
				if Input.is_action_pressed("mouse1"):
					RayChunk.SetVoxel(xb0, yb0, zb0, Color.red)
				
					RayChunk.GenerateVoxelMesh(VoxelLevel.VOXEL_SIZE)
			else:
				for i in range(10):
					raycast.cast_to += Vector3.FORWARD * i
					RayOrigin = raycast.global_transform.xform(raycast.cast_to)
		"""
		
		if nextChunk:
			var xbn: int = (GetOrigin().x / VoxelLevel.VOXEL_SIZE) - (nextChunk.WorldX * nextChunk.Width)
			var ybn: int = ((GetOrigin().y - 1) / VoxelLevel.VOXEL_SIZE) - (nextChunk.WorldY * nextChunk.Height)
			var zbn: int = (GetOrigin().z / VoxelLevel.VOXEL_SIZE) - (nextChunk.WorldZ * nextChunk.Depth)
			
			if !nextChunk.GetVoxel(xb, yb, zb) != Color.transparent:
				pass #isOnFloor = true
		
		LoadScript.Render.DrawTextFont("on chunk %s %s %s" % [OnChunk.WorldX, OnChunk.WorldY, OnChunk.WorldZ], Vector2(0, 16), Color.red)
		LoadScript.Render.DrawTextFont("player on chunk %s %s %s" % [xb, yb, zb], Vector2(0, 16 + 16), Color.blue)
		
		if Input.is_action_pressed("ui_accept"):
			
			if CountPress < 12:
				if isOnFloor:
					Vel.y = JumpForce
				
				CountPress += 1
			else:
				Vel.y = JumpForce + 1.2
		else:
			CountPress = 0

	Move(Vel.x * 0.09, Vel.y * 0.09, Vel.z * 0.09, delta)
	
	var e = raycast.global_transform.xform(raycast.cast_to)
	
	var xb:int = floor((e.x) / 0.5)
	var yb:int = floor((e.y) / 0.5)
	var zb:int = floor((e.z) / 0.5)
	
	var xc:int = floor( (e.x) / 10 )
	var yc:int = floor( (e.y) / 10 )
	var zc:int = floor( (e.z) / 10 )
	
	var chunk = VoxelLevel.GetChunk(xc, yc, zc)
	
	for i in range(Inventory.HotBar.size()):
		LoadScript.Render.drawTexture(Rect2((OS.window_size.x - Inventory.HotBar.size() * 32) / 2 + (i * (32 + 0)), (OS.window_size.y - 32), 32, 32), Rect2(16, 8, 16, 16), graphics)
		
		if i == Inventory.HotBarIndex:
			LoadScript.Render.drawTexture(Rect2((OS.window_size.x - Inventory.HotBar.size() * 32) / 2 + (i * 32), (OS.window_size.y - 32), 32, 32), Rect2(32, 8, 16, 16), graphics)
		
	#if (Inventory.GetCurrentHotBar() is Inventory.Tool):
	#	pass
	
		
	#if chunk.getBlock(floor( xb - xc * onChunk.width ), floor( yb - yc * onChunk.height ), floor( zb - zc * onChunk.depth )).id != level.airBlock.id:
	#	if Input.is_action_just_pressed("mouse0"):
	#		chunk.setBlock(floor( xb - xc * onChunk.width ), floor( yb - yc * onChunk.height ), floor( zb - zc * onChunk.depth ), level.airBlock.id)
	#		chunk.generateMesh()

"""
func move(dx, dy, dz):
	if (dx != 0): move2(dx, 0, 0)
	if (dy != 0): move2(0, dy, 0)
	if (dz != 0): move2(0, 0, dz)

func move2(dx, dy, dz):
	if !onChunk:
		return
	
	var nextChunk = null
	
	var rx = collisionBox.size.x / 2
	var ry = collisionBox.size.y
	var rz = collisionBox.size.z / 2
	
	var xnc = floor(((getPosition().x + dx)) / onChunk.width)
	var ync = floor(((getPosition().y + dy)) / onChunk.height)
	var znc = floor(((getPosition().z + dz)) / onChunk.depth)
	
	nextChunk = get_parent().level.getChunk(xnc, ync, znc)
	
	var xb:int = floor( (getPosition().x + dx + collisionBox.size.x) / level.Block.BLOCK_SIZE)
	var yb:int = floor( (getPosition().y + dy + collisionBox.size.y) / level.Block.BLOCK_SIZE)
	var zb:int = floor( (getPosition().z + dz + collisionBox.size.z) / level.Block.BLOCK_SIZE)
				
	var x:int = floor( xb % onChunk.width )
	var y:int = floor( yb % onChunk.height )
	var z:int = floor( zb % onChunk.depth )
	
	#.bounding(xb, yb, zb).intersects(self.collisionBox)
	
	
	var hitboxes = null
	
	var tx = global_transform.origin.x + dx
	var ty = global_transform.origin.y + dy
	var tz = global_transform.origin.z + dz
	
	isOnFloor = false
	
	collisionBox.position = Vector3(tx - collisionBox.size.x / 2, ty, tz - collisionBox.size.z / 2)
	
	
	#if nextChunk == onChunk:
	#	for i in range(onChunk.hitboxes.size()):
	#		if onChunk.hitboxes[i] != null:
	#			
	#			if self.collisionBox.intersects(onChunk.hitboxes[i]):
	#				
	#				if dy < 0:
	#					isOnFloor = true
	#				
	#				return false
	
	if nextChunk:
		for i in range(nextChunk.hitboxes.size()):
			if nextChunk.hitboxes[i] != null:
				
				if self.collisionBox.intersects(nextChunk.hitboxes[i]):
					
					if dy < 0:
						isOnFloor = true
						
					return false
	
	#if nextChunk == null:
	#	if !onChunk.getBlock(x, y, z).mayPass():
	#		return false
	#else:
	#	if !nextChunk.getBlock(x, y, z).mayPass():
	#		return false
	
	
	global_transform.origin += Vector3(dx, dy, dz)
	
	return true

func getPosition():
	return global_transform.origin
"""
