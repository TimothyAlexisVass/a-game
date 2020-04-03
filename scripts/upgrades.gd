extends Panel

enum check{AFFORDABLE, PROGRESS}

var upgrade_template = preload("res://scenes/upgrade.tscn")
var upgrade_objects_list = {}
var upgrade_object

var board_size_function = funcref(self, "board_size")

var open = [
	{
		"name": "board_size",
		"level": 0,
		"title": ["One whole coin!", "One thousand coins.", "One million coins.", "1234567890...", "One hundred eleven billion one hundred eleven million one hundred and eleven", "Trillion!"],
		"requirement": [1, pow(10,3), pow(10,6), 1234567890, 11111111111, pow(10,12)],
		"reward": [1, 2, 1.5, 1 + 1/3, 1.25, 1.2],
		"function": board_size_function,
		"image": load("res://assets/upgrade_images/tile.svg"),
		"description": ["Enables upgrades and income.", "Income +100%.", "Income  +50%", "Income +33%", "Income +25%", "Income +20%"]
	},
]

var completed = []

func _ready():
	for upgrade in open:
		if upgrade.title[0] != null:
			upgrade_object = upgrade_template.instance()
			upgrade_object.get_node("Background/MarginContainer/Panel/MarginContainer2/HBoxContainer/ImageBackground/UpgradeImage").texture = upgrade["image"]
			get_node("ScrollContainer/MarginContainer/VBoxContainer").add_child(upgrade_object)
			upgrade_objects_list[upgrade.name] = upgrade_object

func _on_CheckUpgrades_timeout():
	pass # Replace with function body.

func board_size(upgrade, result):
	print(upgrade + result)
	pass
