extends Node

var open_events = [
	"Achievements enabled",
	"Income and upgrades enabled"
]

var completed_events = []

func _ready():
	for event in completed_events:
		_enable(event)

func _on_MainTimer_timeout():
	for event in open_events:
		if completed(event):
			_enable(event)
			Main.display_notification(event)
			completed_events.append(event)
			open_events.erase(event)

func completed(event):
	match(event):
		"Achievements enabled":
			if Global.data.coins >= 0.3:
				return true
		"Income and upgrades enabled":
			if Global.data.coins >= 1:
				return true

func _enable(event):
	match(event):
		"Achievements enabled":
			Main.achievements_button.visible = true
		"Income and upgrades enabled":
			Main.move_info.visible = true
			Main.upgrades_button.disabled = false
			get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/IncomeLabel").visible = true
			get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/PerSecondLabel").visible = true
			get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/Parenthesis").visible = true
			Global.data.base_income = 0.09
			Main.set_income()
			Main.get_node("/root/main/IncomeTimer").start()
