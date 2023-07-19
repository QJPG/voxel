extends Node

const CHARS = "abcdefghijklmnopqrstuvwxyz0123456789-()+., ?!=:"

var spritesheetFont = preload("res://assets/images/fontproject.png")
var DefaultTextFont = preload("res://DefaultFont.tres")

var canvasItem = VisualServer.canvas_item_create()
var renderInstance = VisualServer.instance_create()
var extraInstance = VisualServer.instance_create()

func _ready():
	pass

func setCanvasParent(parent: RID, parent3d: RID):
	VisualServer.canvas_item_set_parent(canvasItem, parent)
	VisualServer.instance_set_scenario(renderInstance, parent3d)
	VisualServer.instance_set_scenario(extraInstance, parent3d)

func drawFont(text: String, x, y, col = Color.white):
	text = text.to_lower()
	
	for i in range(text.length()):
		var index = CHARS.find(text[i])
		
		if index > -1:
			VisualServer.canvas_item_add_texture_rect_region(canvasItem, Rect2(x + (16 * i), y, 16, 16), spritesheetFont, Rect2(index * 8, 0, 8, 8), col)

func DrawTextFont(text: String, src: Vector2, color = Color.white, wclip = -1):
	DefaultTextFont.draw(canvasItem, src, text, color, wclip)

func drawTexture(src, dst, image):
	VisualServer.canvas_item_add_texture_rect_region(canvasItem, src, image, dst)

func getMeshCube(sizeX, sizeY, sizeZ, color = Color.white) -> ArrayMesh:
	var center = Vector3.ONE * Vector3(sizeX, sizeY, sizeZ)
	
	var a = (Vector3(0, 0.3, 0) * center)
	var b = (Vector3(0.3, 0.3, 0) * center)
	var c = (Vector3(0.3, 0, 0) * center)
	var d = (Vector3(0, 0, 0) * center)
	var e = (Vector3(0, 0.3, 0.3) * center)
	var f = (Vector3(0.3, 0.3, 0.3) * center)
	var g = (Vector3(0.3, 0, 0.3) * center)
	var h = (Vector3(0, 0, 0.3) * center)
	
	#inverter: cima pra baixo e direita
	#inverter: baixo pra cima e esquerda
	#reverter: cima pra baixo e esquerda
	#reverter: baixo pra cima e direita
	
	var faces = [
		[a, d, c, c, b, a], #BACK
		[h, e, f, f, g, h], #FRONT
		[e, a, b, b, f, e], #TOP
		[d, h, g, g, c, d], #BOTTOM
		[e, h, d, d, a, e], #LEFT
		[b, c, g, g, f, b]  #RIGHT
	]
	
	var uvs = [
		Vector2(0, 1),
		Vector2(0, 0),
		Vector2(1, 0),
		
		Vector2(1, 0),
		Vector2(1, 1),
		Vector2(0, 1)
	]
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in range(faces.size()):
		for j in range(faces[i].size()):
			st.add_uv(uvs[j])
			st.add_color(color)
			st.add_vertex(faces[i][j])
	
	#st.generate_normals()
	
	var meshRID = VisualServer.mesh_create()
	
	VisualServer.mesh_add_surface_from_arrays(meshRID, VisualServer.PRIMITIVE_LINE_LOOP, st.commit_to_arrays())
	
	var mat = SpatialMaterial.new()
	
	mat.flags_unshaded = true
	mat.vertex_color_use_as_albedo = true
	
	VisualServer.mesh_surface_set_material(meshRID, 0, mat.get_rid())
	
	return meshRID

func drawMesh(x, y, z, mesh: RID):
	VisualServer.instance_set_base(renderInstance, mesh)
	VisualServer.instance_set_transform(renderInstance, Transform(Basis(), Vector3(x, y, z)))

func drawMeshOnInstance(x, y, z, mesh:RID, instance: RID):
	VisualServer.instance_set_base(instance, mesh)
	VisualServer.instance_set_transform(instance, Transform(Basis(), Vector3(x, y, z)))

func Clear():
	VisualServer.canvas_item_clear(canvasItem)
