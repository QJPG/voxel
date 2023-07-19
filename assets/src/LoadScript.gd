extends Node

signal LogRegistered(message)

var canvas = CanvasLayer.new()
var rng = RandomNumberGenerator.new()
var Render = preload("res://assets/src/Render.gd").new()
var Player = null
var Screen = preload("res://assets/src/Screen.gd").new()
var Texts: Dictionary
var Options: Dictionary
var Logs = []

class ImageAtlasTexture extends ImageTexture:
	var atlas: Texture setget set_atlas
	var region: Rect2 setget set_region

	func _init():
		update_image()

	func set_atlas(val):
		atlas = val
		if atlas and not atlas.is_connected("changed", self, "update_image"):
			var __ = atlas.connect("changed", self, "update_image")
		update_image()
		emit_changed()


	func set_region(val):
		region = val
		update_image()
		emit_changed()


	func update_image():
		if !atlas:
			return
		
		if !region.size:
			return
		
		var oldFlags = self.atlas.flags
		
		self.create_from_image(self.atlas.get_data().get_rect(self.region))
		self.flags = oldFlags

func LogRegister(message: String):
	Logs.append(message)
	
	emit_signal("LogRegistered", message)

func _init():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	add_child(canvas)
	canvas.add_child(Screen)
	
	add_child(Render)
	
	var TextsFile = File.new()
	TextsFile.open("res://assets/texts/Texts.json", File.READ)
	Texts = JSON.parse(TextsFile.get_as_text()).result
	TextsFile.close()
	
	var OptionsFile = File.new()
	OptionsFile.open("res://assets/texts/Options.json", File.READ)
	Options = JSON.parse(OptionsFile.get_as_text()).result
	OptionsFile.close()

func _ready():
	rng.randomize()
	
	Render.setCanvasParent(canvas.get_viewport().world_2d.canvas, canvas.get_viewport().world.scenario)

func _input(event):
	if event is InputEventKey:
		if event.pressed && event.scancode == KEY_F11:
			OS.window_fullscreen = !OS.window_fullscreen
		
		if event.pressed && event.scancode == KEY_F5:
			if Player.is_inside_tree():
				Player.global_transform.origin = Vector3(5, 5, 5)
		
		if event.pressed && event.scancode == KEY_ESCAPE:
			if (Input.mouse_mode != Input.MOUSE_MODE_CAPTURED):
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta):
	Render.Clear()
	
	for i in range(Logs.size()):
		Render.DrawTextFont(Logs[i], Vector2(0, ((OS.window_size.y - 16) / 2) + (i * 16)))

func Throw(what, _call_meth: String, _pr = false):
	if what:
		what.call(_call_meth)
	else:
		if _pr:
			print_debug("Trow Error: <what> is NULL")
