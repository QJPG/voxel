extends Node

var ToolHammer = Hammer.new(0)
var HotBarIndex = 0

var HotBar: Array = Array()

func _init():
	HotBar.resize(6)
	HotBar[0] = ToolHammer

class Tool:
	var tools = []
	
	var id = 0
	
	func _init(id):
		self.id = id
		
		Tool.tools.append(self)

class Hammer extends Tool:
	func _init(id).(id):
		pass
