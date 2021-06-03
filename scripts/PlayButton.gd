extends TextureRect

var start := false

func _gui_input(event):
	if event is InputEventMouseButton:
		if not $Chime.playing:
			MenuMusic.stop()
			$Chime.play()
		start = true

func _process(delta):
	if start and not $Chime.playing:
		get_tree().change_scene("res://scenes/Level.tscn")
