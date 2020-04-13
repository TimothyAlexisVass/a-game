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

var open_achievements = [
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
						pow(10, 12)],
		"reward": [1, 1.5, 2, 1.5, 1 + 1/3, 1.25, 1.2],
		"image": load("res://assets/achievement_images/coins.svg"),
		"description": ["Enables upgrades and income.", "Base income +50%", "Doubles base income.", "Base income +50%", "Base income +1/3", "Base income +25%", "Base income +20%"]
	},
	{
		"name": "total_coins",
		"level": 0,
		"title": ["1K Total coins ever",
				  "1M Total coins ever",
				  "1T Total coins ever",
				  "1Qa Total coins ever",
				  "1Qi Total coins ever",
				  "1Sx Total coins ever"],
		"requirement": [pow(10, 3),
						pow(10, 6),
						pow(10, 9),
						pow(10, 12),
						pow(10, 15),
						pow(10, 18)],
		"reward": [2, 2, 2, 2, 2, 2],
		"image": load("res://assets/achievement_images/total_coins.svg"),
		"description": ["Doubles income multiplier", "Doubles income multiplier", "Doubles income multiplier", "Doubles income multiplier", "Doubles income multiplier", "Doubles income multiplier"]
	},
	{
		"name": "total_recycles",
		"level": 0,
		"title": ["25 Recycles",
				  "500 Recycles",
				  "7500 Recycles",
				  "100000 Recycles",
				  "1 Million Recycles",
				  "1 Billion Recycles"],
		"requirement": [25,
						500,
						7500,
						pow(10, 5),
						pow(10, 6),
						pow(10, 9)],
		"reward": [1.5, 1.5, 2, 2, 2, 10],
		"image": load("res://assets/achievement_images/total_recycles.svg"),
		"description": ["50% bonus when recycling a full board", "Increase full board bonus by 50%", "Doubles full board bonus", "Doubles full board bonus", "Doubles full board bonus", "1000% full board bonus"]
	},
	{
		"name": "top_tile_order",
		"level": 0,
		"title": [	"4th order",
					"5th order",
					"6th order",
					"7th order",
					"8th order",
					"9th order",
					"10th order",
					"11th order",
					"12th order",
					"13th order"],
		"requirement": [4, 5, 6, 7, 8, 9, 10, 11, 12, 13],
		"reward": [2, 3, 4, 5, 6, 8, 10, 12, 14, 16],
		"image": load("res://assets/achievement_images/top_tile_order.svg"),
		"description": ["2 tiles after recycle", "3 tiles after recycle", "4 tiles after recycle", "5 tiles after recycle", "6 tiles after recycle", "8 tiles after recycle", "10 tiles after recycle", "12 tiles after recycle", "14 tiles after recycle", "16 tiles after recycle"]
	},
	{
		"name": "combinations_done",
		"level": 0,
		"title": [	"100 combinations done",
					"1000 combinations done",
					"10000 combinations done",
					"100000 combinations done",
					"A million combinations done",
					"10 million combinations done"],
		"requirement": [pow(10, 2),
						pow(10, 3),
						pow(10, 4),
						pow(10, 5),
						pow(10, 6),
						pow(10, 7)],
		"reward": [0.02, 0.05, 0.10, 0.25, 0.5, 1],
		"image": load("res://assets/achievement_images/combinations_done.svg"),
		"description": ["Increased income from combining tiles", "Increased income from combining tiles", "Increased income from combining tiles", "Increased income from combining tiles", "Increased income from combining tiles", "Increased income from combining tiles"]
	},
	{
		"name": "total_moves",
		"level": 0,
		"title": [	"100 total moves made",
					"1000 total moves made",
					"10000 total moves made",
					"100000 total moves made",
					"A million total moves made",
					"10 million total moves made"],
		"requirement": [pow(10, 2),
						pow(10, 3),
						pow(10, 4),
						pow(10, 5),
						pow(10, 6),
						pow(10, 7)],
		"reward": [1, 1, 2, 2, 2, 3],
		"image": load("res://assets/achievement_images/total_moves.svg"),
		"description": ["Gain income faster", "Gain income faster", "Gain income faster", "Gain income faster", "Gain income faster", "Gain income faster"]
	}
]

var completed_achievements = []

func _ready():
	description.visible = false
	for achievement in open_achievements:
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

func _on_MainTimer_timeout():
	if achievement_described != null:
		description_progress_bar.value = check_progress(achievement_described)
	for achievement in open_achievements:
		_check_if_achieved(achievement)
		achievement_object = achievement_objects_list[achievement.name]
		achievement_object.get_node("LevelLabel").text = str(achievement.level) + "/" + str(achievement["title"].size())
		achievement_object.get_node("TextureProgress").value = check_progress(achievement)

func check_progress(achievement):
	if achievement.level == achievement["title"].size():
		return 100
	match(achievement.name):
		"coins":
			return 100 * Global.data.coins / achievement.requirement[achievement.level]
		"total_coins":
			return 100 * Global.data.total_coins / achievement.requirement[achievement.level]
		"total_recycles":
			return 100 * Global.data.total_recycles / achievement.requirement[achievement.level]
		"top_tile_order":
			return 100 * Global.data.top_tile_order / achievement.requirement[achievement.level]
		"combinations_done":
			return 100 * Global.data.combinations_done / achievement.requirement[achievement.level]
		"total_moves":
			return 100 * Global.data.total_moves / achievement.requirement[achievement.level]

func _check_if_achieved(achievement):
	# Move to array "completed" if all levels are completed
	if achievement.level == achievement["title"].size():
		completed_achievements.append(achievement)
		open_achievements.erase(achievement)

	else:
		match(achievement.name):
			"coins":
				if Global.data.coins >= achievement.requirement[achievement.level]:
					Global.data.base_income *= achievement.reward[achievement.level]
					achieved = true
			"total_coins":
				if Global.data.total_coins >= achievement.requirement[achievement.level]:
					Global.data.income_multiplier *= achievement.reward[achievement.level]
					achieved = true
			"total_recycles":
				if Global.data.total_recycles >= achievement.requirement[achievement.level]:
					Global.data.full_board_multiplier *= achievement.reward[achievement.level]
					achieved = true
			"top_tile_order":
				if Global.data.top_tile_order >= achievement.requirement[achievement.level]:
					Global.data.starting_tiles = achievement.reward[achievement.level]
					achieved = true
			"combinations_done":
				if Global.data.combinations_done >= achievement.requirement[achievement.level]:
					Global.data.combination_multiplier = achievement.reward[achievement.level]
					achieved = true
			"total_moves":
				if Global.data.total_moves >= achievement.requirement[achievement.level]:
					Global.data.income_timer -= achievement.reward[achievement.level]
					achieved = true

		if achieved:
			Main.display_notification(achievement.title[achievement.level] + "\n(" + achievement.description[achievement.level] + ")")
			Main.set_income()
			achievement.level += 1
	
			achieved = false
