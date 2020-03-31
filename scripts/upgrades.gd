extends Panel

func _ready():
	self.visible = false

func _on_UpgradesButton_pressed():
	self.visible = true
	Main.move_enabled = false
