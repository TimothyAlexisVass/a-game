extends Panel

var achievement_template = preload("res://scenes/achievement.tscn")
var achievement_objects_list = []
var achievement_object

var progress_events_function = funcref(self, "progress_events")
var coin_achievements_function = funcref(self, "coin_achievements")

var open = [
	{
		"level": 0,
		"title": [null],
		"function": progress_events_function
	},
	{
		"level": 0,
		"title": ["One whole coin!", "One thousand coins.", "One million coins.", "1234567890...", "One hundred eleven billion one hundred eleven million one hundred and eleven", "Trillion!"],
		"requirement": [1, pow(10,3), pow(10,6), 1234567890, 11111111111, pow(10,12)],
		"reward": [1, 2, 1.5, 1 + 1/3, 1.25, 1.2],
		"function": coin_achievements_function,
		"image": load("res://assets/achievement_images/your_first_coin.svg"),
		"description": ["Enables upgrades and income.", "Income +100%.", "Income  +50%", "Income +33%", "Income +25%", "Income +20%"]
	}
]

var completed = []

onready var tween = get_node("Tween")

func _ready():
	self.visible = false
	for achievement in open:
		if achievement.title[0] != null:
			achievement_object = achievement_template.instance()
			achievement_object.get_child(0).get_child(0).texture_normal = achievement["image"]
			achievement_object.get_child(1).text = str(achievement.level) + "/" + str(achievement["title"].size())
			get_node("ScrollContainer/MarginContainer/GridContainer/").add_child(achievement_object)
			achievement_objects_list.append(achievement_object)

func _on_AchievementsButton_pressed():
	self.visible = true
	Main.upgrades_button.visible = false
	Main.achievements_button.visible = false
	Main.move_enabled = false
	tween.interpolate_property(self, "rect_position", Vector2(16, 850), Vector2(16, 16), .6, tween.TRANS_EXPO, tween.EASE_OUT)
	tween.start()

func _on_CloseButton_pressed():
	Main.upgrades_button.visible = true
	Main.achievements_button.visible = true
	tween.interpolate_property(self, "rect_position", Vector2(16, 16), Vector2(16, 850), .6, tween.TRANS_EXPO, tween.EASE_OUT)
	tween.start()
	yield(get_tree().create_timer(.6), "timeout")
	Main.move_enabled = true
	self.visible = false

func _on_CheckAchievements_timeout():
	for achievement in open:
		if achievement["function"].call_func(achievement):
			achievement["level"] += 1
		if achievement["level"] == achievement["title"].size():
			completed.append(achievement)
			open.erase(achievement)

func progress_events(achievement):
	match achievement.level:
		0:
			Main.achievements_button.visible = Main.total >= 0.3
			return Main.total >= 0.3
		1:
			Main.upgrades_button.disabled = Main.total < 1
			return Main.total >= 1

func coin_achievements(achievement):
	if Main.total >= achievement.requirement[achievement.level]:
		Main.income_multiplier *= achievement.reward[achievement.level]
		return true
	else:
		return false
