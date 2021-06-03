extends Label

var count := 0
var reset_count := 0

func update_text():
	text = str(count)

func collect():
	count += 1
	update_text()

func reset():
	count = reset_count
	update_text()

func checkpoint():
	reset_count = count
