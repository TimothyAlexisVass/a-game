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
		upgrade_object.get_node("Background/MarginContainer/Panel/MarginContainer2/HBoxContainer/RichTextLabel").text = str(upgrade.description[upgrade.level])
		upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").connect("pressed", self, "_on_UpgradeBuyButton_pressed", [upgrade])
		get_node("ScrollContainer/MarginContainer/VBoxContainer").add_child(upgrade_object)
		upgrade_objects_list[upgrade.name] = upgrade_object

func _on_CheckUpgrades_timeout():
	for upgrade in open:
		upgrade_object = upgrade_objects_list[upgrade.name]
		if Main.coins >= upgrade.requirement[upgrade.level]:
			upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").disabled = false
		else:
			upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").disabled = true

func _on_UpgradeBuyButton_pressed(upgrade):
	upgrade_object = upgrade_objects_list[upgrade.name]
	if Main.coins >= upgrade.requirement[upgrade.level]:
		perform_upgrade(upgrade)
	else:
		upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").disabled = true

func perform_upgrade(upgrade):
	if upgrade.name == "board_size":
		Main.change_total(-upgrade.requirement[upgrade.level], get_global_mouse_position())
		Main.board_size += 1
		upgrade.level += 1
		upgrade_object.get_node("Background/MarginContainer/Panel/HBoxContainer/PriceLabel").text = str(upgrade.requirement[upgrade.level])
		get_node("/root/main/BoardBackground/TileBoard").recycle()
		
		if Main.coins >= upgrade.requirement[upgrade.level]:
			upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").disabled = false
		else:
			upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").disabled = true
		print(Main.board_size)
