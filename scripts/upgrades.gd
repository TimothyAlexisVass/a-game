extends Panel

enum check{UPGRADE, AFFORDABLE}

var upgrade_template = preload("res://scenes/upgrade.tscn")
var upgrade_objects_list = {}
var upgrade_object

var board_size_function = funcref(self, "board_size")

var open = [
	{
		"name": "board_size",
		"level": 0,
		"requirement": [200, 15000, 2000000, 3000000000],
		"reward": [3, 4, 5, 6],
		"image": load("res://assets/upgrade_images/tile.svg"),
		"description": ["Increase board size (3x3)", "Increase board size (4x4)", "Increase board size (5x5)", "Increase board size (6x6)"]
	},
]

var completed = []

func _ready():
	for upgrade in open:
		upgrade_object = upgrade_template.instance()
		upgrade_object.get_node("Background/MarginContainer/Panel/MarginContainer2/HBoxContainer/ImageBackground/UpgradeImage").texture = upgrade["image"]
		upgrade_object.get_node("Background/MarginContainer/Panel/HBoxContainer/PriceLabel").text = str(upgrade.requirement[upgrade.level])
		upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").connect("pressed", self, "_on_UpgradeBuyButton_pressed", [upgrade_object])
		get_node("ScrollContainer/MarginContainer/VBoxContainer").add_child(upgrade_object)
		upgrade_objects_list[upgrade.name] = upgrade_object

func _on_CheckUpgrades_timeout():
	for upgrade_object in upgrade_objects_list:
		if Main.coins >= upgrade_object.get_node("Background/MarginContainer/Panel/HBoxContainer/PriceLabel").text:
			upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").deactivate = false
		else:
			upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").deactivate = true

func _on_UpgradeBuyButton_pressed(upgrade):
	if Main.coins >= upgrade_objects_list[upgrade.name].get_node("Background/MarginContainer/Panel/HBoxContainer/PriceLabel").text:
		upgraded(upgrade)
	else:
		upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").deactivate = true

func upgraded(upgrade):
	if upgrade.name == "board_size":
		Main.board_size += 1
		upgrade.level += 1
		upgrade_object.get_node("Background/MarginContainer/Panel/HBoxContainer/PriceLabel").text = upgrade.requirement[upgrade.level]
		if Main.coins >= upgrade_object.get_node("Background/MarginContainer/Panel/HBoxContainer/PriceLabel").text:
			upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").deactivate = false
		else:
			upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").deactivate = true
