class_name NpcGreetingDialogue

static func create() -> DialogueData:
	var data := DialogueData.new()
	data.start_line_id = "greet"

	var line1 := DialogueLine.new()
	line1.id = "greet"
	line1.speaker = "Elder"
	line1.text = "Welcome, traveler! It's dangerous out here."
	line1.choices = [
		{"text": "Tell me more.", "next_line_id": "info"},
		{"text": "I can handle it.", "next_line_id": "brave"},
	]

	var line2 := DialogueLine.new()
	line2.id = "info"
	line2.speaker = "Elder"
	line2.text = "Slimes have been appearing near the village. Defeat them and I'll reward you."
	line2.next_line_id = ""

	var line3 := DialogueLine.new()
	line3.id = "brave"
	line3.speaker = "Elder"
	line3.text = "Ha! Bold words. Prove it by clearing the slimes."
	line3.next_line_id = ""

	data.lines = [line1, line2, line3]
	return data
