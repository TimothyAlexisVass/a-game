extends Panel

enum check{ACHIEVED, PROGRESS}

var achievement_template = preload("res://scenes/achievement.tscn")
var achievement_objects_list = {}
var achievement_object

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
		"title": ["One whole coin!", "One thousand coins.", "One million coins.", "1234567890...", "One hundred eleven billion one hundred eleven million one hundred and eleven", "Trillion!"],
		"requirement": [1, pow(10,3), pow(10,6), 1234567890, 11111111111, pow(10,12)],
		"reward": [1, 2, 1.5, 1 + 1/3, 1.25, 1.2],
		"function": coins_achievements_function,
		"image": load("res://assets/achievement_images/coin.svg"),
		"description": ["Enables upgrades and income.", "Income +100%.", "Income  +50%", "Income +33%", "Income +25%", "Income +20%"]
	},
	{
		"name": "total_coins_ever",
		"level": 0,
		"title": ["1M Total coins ever", "1T Total coins ever", "1Qa Total coins ever", "1Qi Total coins ever", "1Sx Total coins ever"],
		"requirement": [pow(10,6), pow(10,9), pow(10,12), pow(10,15), pow(10,18)],
		"reward": [2, 2, 2, 2, 2],
		"function": total_coins_ever_achievements_function,
		"image": load("res://assets/achievement_images/coin.svg"),
		"description": ["Doubles income", "Doubles income", "Doubles income", "Doubles income", "Doubles income"]
	}
]

var completed = []

func _ready():
	for achievement in open:
		if achievement.title[0] != null:
			achievement_object = achievement_template.instance()
			achievement_object.get_node("TextureProgress/TextureButton").texture_normal = achievement["image"]
			achievement_object.get_node("LevelLabel").text = str(achievement.level) + "/" + str(achievement["title"].size())
			get_node("ScrollContainer/MarginContainer/GridContainer/").add_child(achievement_object)
			achievement_objects_list[achievement.name] = achievement_object

func _on_CheckAchievements_timeout():
	for achievement in open:
		if achievement["level"] == achievement["title"].size():
			completed.append(achievement)
			open.erase(achievement)
		achievement["function"].call_func(achievement, check.ACHIEVED)
		if achievement.title[0] != null:
			achievement_object = achievement_objects_list[achievement.name]
			achievement_object.get_child(1).text = str(achievement.level) + "/" + str(achievement["title"].size())
			achievement_object.get_child(0).value = achievement["function"].call_func(achievement, check.PROGRESS)

func progress_events(achievement, _result):
	if Main.coins >= 0.3:
		Main.achievements_button.visible = Main.coins >= 0.3
		achievement["level"] += 1
	if Main.coins >= 1:
		Main.upgrades_button.disabled = Main.coins < 1
		achievement["level"] += 1

func coins_achievements(achievement, result):
	if result == check.PROGRESS:
		return 100 * Main.coins / achievement.requirement[achievement.level]
	if Main.coins >= achievement.requirement[achievement.level]:
		Main.income_multiplier *= achievement.reward[achievement.level]
		achievement["level"] += 1

func total_coins_ever_achievements(achievement, result):
	if result == check.PROGRESS:
		return 100 * Main.total_coins_ever / achievement.requirement[achievement.level]
	if Main.total_coins_ever >= achievement.requirement[achievement.level]:
		Main.income_multiplier *= achievement.reward[achievement.level]
		achievement["level"] += 1

