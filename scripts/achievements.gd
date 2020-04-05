extends Panel

enum check{ACHIEVED, PROGRESS}

var achievement_template = preload("res://scenes/achievement.tscn")
var achievement_objects_list = {}
var achievement_object

onready var description = get_node("Description")
onready var description_title_label = get_node("Description/Background/MarginContainer/Panel/TitleLabel")
onready var description_progress_bar = get_node("Description/Background/MarginContainer/Panel/ProgressBar")
onready var description_label = get_node("Description/Background/MarginContainer/Panel/MarginContainer/DescriptionLabel")

var progress_events_function = funcref(self, "progress_events")
var coins_achievements_function = funcref(self, "coins_achievements")
var total_coins_ever_achievements_function = funcref(self, "total_coins_ever_achievements")
var energy_achievements_function = funcref(self, "energy_achievements")

var open = [
	{
		"level": 0,
		"title": [null],
		"function": progress_events_function
	},
	{
		"name": "coins",
		"level": 0,
		"title": ["One whole coin!", "One hundred coins", "One thousand coins.", "One million coins.", "1234567890...", "One hundred eleven billion one hundred eleven million one hundred and eleven", "Trillion!"],
		"requirement": [1, 100, 1000, 1000000, 1234567890, 11111111111, pow(10,12)],
		"reward": [1, 1.5, 2, 1.5, 1 + 1/3, 1.25, 1.2],
		"function": coins_achievements_function,
		"image": load("res://assets/achievement_images/coin.svg"),
		"description": ["Enables upgrades and income.", "Income  +50%", "Doubles income.", "Income  +50%", "Income +33%", "Income +25%", "Income +20%"]
	},
	{
		"name": "total_coins_ever",
		"level": 0,
		"title": ["1K Total coins ever", "1M Total coins ever", "1T Total coins ever", "1Qa Total coins ever", "1Qi Total coins ever", "1Sx Total coins ever"],
		"requirement": [pow(10,3), pow(10,6), pow(10,9), pow(10,12), pow(10,15), pow(10,18)],
		"reward": [2, 2, 2, 2, 2, 2],
		"function": total_coins_ever_achievements_function,
		"image": load("res://assets/achievement_images/coin.svg"),
		"description": ["Doubles income", "Doubles income", "Doubles income", "Doubles income", "Doubles income", "Doubles income"]
	}
]

var completed = []

func _ready():
	description.visible = false
	for achievement in open:
		if achievement.title[0] != null:
			achievement_object = achievement_template.instance()
			achievement_object.get_node("TextureProgress/TextureButton").texture_normal = achievement["image"]
			achievement_object.get_node("TextureProgress/TextureButton").connect("mouse_entered", self, "_show_achievement_description", [achievement])
			achievement_object.get_node("TextureProgress/TextureButton").connect("mouse_exited", self, "_hide_achievement_description")
			achievement_object.get_node("TextureProgress/TextureButton").connect("button_down", self, "_show_achievement_description", [achievement])
			achievement_object.get_node("TextureProgress/TextureButton").connect("button_up", self, "_hide_achievement_description")
			achievement_object.get_node("LevelLabel").text = str(achievement.level) + "/" + str(achievement["title"].size())
			get_node("ScrollContainer/MarginContainer/GridContainer/").add_child(achievement_object)
			achievement_objects_list[achievement.name] = achievement_object

func _show_achievement_description(achievement):
	description_title_label.text = achievement.title[achievement.level]
	description_label.text = achievement.description[achievement.level]
	description_progress_bar.value = achievement_objects_list[achievement.name].get_node("TextureProgress").value
	description.visible = true

func _hide_achievement_description():
	description.visible = false

func _on_CheckAchievements_timeout():
	for achievement in open:
		if achievement.level == achievement["title"].size() + 1:
			completed.append(achievement)
			open.erase(achievement)
		achievement["function"].call_func(achievement, check.ACHIEVED)
		if achievement.title[0] != null:
			achievement_object = achievement_objects_list[achievement.name]
			achievement_object.get_child(1).text = str(achievement.level) + "/" + str(achievement["title"].size())
			achievement_object.get_child(0).value = achievement["function"].call_func(achievement, check.PROGRESS)

func progress_events(achievement, _result):
	if Main.coins >= 0.3 and achievement.level == 0:
		Main.achievements_button.visible = Main.coins >= 0.3
		achievement.level += 1
	if Main.coins >= 1 and achievement.level == 1:
		Main.upgrades_button.disabled = Main.coins < 1
		Main.move_info.visible = true
		get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/IncomeLabel").visible = true
		get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/PerSecondLabel").visible = true
		get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/Parenthesis").visible = true
		Main.base_income = 0.09
		Main.set_income()
		achievement.level += 1

func coins_achievements(achievement, result):
	if result == check.PROGRESS:
		return 100 * Main.coins / achievement.requirement[achievement.level]
	if Main.coins >= achievement.requirement[achievement.level]:
		Main.income_multiplier *= achievement.reward[achievement.level]
		Main.set_income()
		achievement.level += 1

		print("Main.income_multiplier")
		print(Main.income_multiplier)

func total_coins_ever_achievements(achievement, result):
	if result == check.PROGRESS:
		return 100 * Main.total_coins_ever / achievement.requirement[achievement.level]
	if Main.total_coins_ever >= achievement.requirement[achievement.level]:
		Main.income_multiplier *= achievement.reward[achievement.level]
		Main.set_income()
		achievement.level += 1
