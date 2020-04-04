extends Node2D

var value = 1
onready var tween = get_node("Tween")

func _ready():
	get_node("ProfitIndicator/HBoxContainer/ValueLabel").text = str(value)
	tween.interpolate_property(self, "scale", Vector2(.2, .2), Vector2(1, 1), 1.3, tween.TRANS_ELASTIC, tween.EASE_OUT)
	tween.start()
	tween.interpolate_property(self, "position", position, self.get_position() + Vector2(0, -150), 1.3, tween.TRANS_CUBIC, tween.EASE_OUT)
	tween.start()
	yield(get_tree().create_timer(.3), "timeout")
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), .7, tween.TRANS_SINE, tween.EASE_OUT)
	tween.start()
	yield(get_tree().create_timer(.9), "timeout")
	self.queue_free()
