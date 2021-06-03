extends Label

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.doubleclick:
			OS.shell_open("https://fontspace.com/heaven-castro")
