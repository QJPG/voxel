extends Control

var ScreenTheme: Theme = Theme.new()

func _init():
	rect_size = OS.window_size
	
	ScreenTheme.default_font = preload("res://DefaultFont.tres")
	
	theme = ScreenTheme

func DisplayTextLabel(text: String, dst: Rect2, clip = true):
	var LabelText = Label.new()
	LabelText.text = text
	LabelText.rect_size = dst.size
	LabelText.rect_position = dst.position
	LabelText.rect_clip_content = clip
	
	add_child(LabelText)
	
	return LabelText
