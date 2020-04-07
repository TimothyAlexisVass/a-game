extends Panel

enum check{ACHIEVED, PROGRESS}

var achievement_template = preload("res://scenes/achievement.tscn")
var achievement_objects_list = {}
var achievement_object
var achievement_described = null
var achieved = false

onready var description = get_node("Description")
onready var description_title_label = get_node("Description/Background/MarginContainer/Panel/TitleLabel")
onready var description_progress_bar = get_node("Description/Background/MarginContainer/Panel/ProgressBar")
onready var description_label = get_node("Description/Background/MarginContainer/Panel/MarginContainer/DescriptionLabel")

var open = [
	{
		"name": "progress_events",
		"level": 0,
	},
	{
		"name": "coins",
		"level": 0,
		"title": [	"One whole coin!",
					"One hundred coins",
					"One thousand coins.",
					"One million coins.",
					"1234567890...",
					"One hundred eleven billion one hundred eleven million one hundred and eleven",
					"Trillion!"],
		"requirement": [1,
						100,
						1000,
						1000000,
						1234567890,
						11111111111,
						pow(10,12)],
		"reward": [1, 1.5, 2, 1.5, 1 + 1/3, 1.25, 1.2],
		"image": load("res://assets/achievement_images/coin.svg"),
		"description": ["Enables upgrades and income.", "Base income +50%", "Doubles base income.", "Base income +50%", "Base income +1/3", "Base income +25%", "Base income +20%"]
	},
	{
		"name": "total_coins_ever",
		"level": 0,
		"title": ["1K Total coins ever",
				  "1M Total coins ever",
				  "1T Total coins ever",
				  "1Qa Total coins ever",
				  "1Qi Total coins ever",
				  "1Sx Total coins ever"],
		"requirement": [pow(10,3),
						pow(10,6),
						pow(10,9),
						pow(10,12),
						pow(10,15),
						pow(10,18)],
		"reward": [2, 2, 2, 2, 2, 2],
		"image": load("res://assets/achievement_images/coin.svg"),
		"description": ["Doubles income multiplier", "Doubles income multiplier", "Doubles income multiplier", "Doubles income multiplier", "Doubles income multiplier", "Doubles income multiplier"]
	}
]

var completed = []

func _ready():
	description.visible = false
	for achievement in open:
		if achievement.name != "progress_events":
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
	achievement_described = achievement
	description_title_label.text = achievement.title[achievement.level]
	description_label.text = achievement.description[achievement.level]
	description_progress_bar.value = check_progress(achievement_described)
	description.visible = true

func _hide_achievement_description():
	description.visible = false

func _on_CheckAchievements_timeout():
	if achievement_described != null:
		description_progress_bar.value = check_progress(achievement_described)
	for achievement in open:
		if achievement.name == "progress_events":
			progress_events(achievement)
		else:
			check_if_achieved(achievement)
			achievement_object = achievement_objects_list[achievement.name]
			achievement_object.get_node("LevelLabel").text = str(achievement.level) + "/" + str(achievement["title"].size())
			achievement_object.get_node("TextureProgress").value = check_progress(achievement)

func progress_events(achievement):
	match(achievement.level):
		0:
			if Main.coins >= 0.3:
				Main.achievements_button.visible = Main.coins >= 0.3
				achievement.level += 1
				Main.display_notification("Achievements enabled")
		1:
			if Main.coins >= 1:
				Main.upgrades_button.disabled = Main.coins < 1
				Main.move_info.visible = true
				get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/IncomeLabel").visible = true
				get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/PerSecondLabel").visible = true
				get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/Parenthesis").visible = true
				Main.base_income = 0.09
				Main.set_income()
				achievement.level += 1
		# Move to array "completed" when all levels are completed
		_:
			completed.append(achievement)
			open.erase(achievement)

func check_progress(achievement):
	if achievement.level == achievement["title"].size():
		return 100
	match(achievement.name):
		"coins":
			return 100 * Main.coins / achievement.requirement[achievement.level]
		"total_coins_ever":
			return 100 * Main.total_coins_ever / achievement.requirement[achievement.level]

func check_if_achieved(achievement):
	match(achievement.name):
		"coins":
			if Main.coins >= achievement.requirement[achievement.level]:
				Main.base_income *= achievement.reward[achievement.level]
				achieved = true
		"total_coins_ever":
			if Main.total_coins_ever >= achievement.requirement[achievement.level]:
				Main.income_multiplier *= achievement.reward[achievement.level]
				achieved = true
	if achieved:
		Main.display_notification(achievement.title[achievement.level] + " (" + achievement.description[achievement.level] + ")")
		Main.set_income()
		achievement.level += 1
	
		# Move to array "completed" when all levels are completed
		if achievement.level == achievement["title"].size():
			completed.append(achievement)
			open.erase(achievement)
		achieved = false
