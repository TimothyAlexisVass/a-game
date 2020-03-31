extends Panel

onready var tween = get_node("Tween")
func _ready():
	self.visible = false

func _on_AchievementsButton_pressed():
	self.visible = true
	Main.upgradesbutton.visible = false
	Main.achievementsbutton.visible = false
	Main.move_enabled = false
	tween.interpolate_property(self, "rect_position", Vector2(16, 850), Vector2(16, 16), .6, tween.TRANS_EXPO, tween.EASE_OUT)
	tween.start()


func _on_CloseButton_pressed():
	tween.interpolate_property(self, "rect_position", Vector2(16, 16), Vector2(16, 850), .6, tween.TRANS_EXPO, tween.EASE_OUT)
	tween.start()
	yield(get_tree().create_timer(.6), "timeout")
	Main.upgradesbutton.visible = true
	Main.achievementsbutton.visible = true
	Main.move_enabled = true
	self.visible = false
