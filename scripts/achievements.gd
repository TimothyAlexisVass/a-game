extends Panel

var achievement_template = preload("res://scenes/achievement.tscn")
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
		"title": ["Your first coin!", "A thousand coins."],
		"function": coin_achievements_function,
		"image": load("res://assets/achievement_images/your_first_coin.svg"),
		"description": ["Enables upgrades and income.", "Increases income multiplier."]
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
	tween.interpolate_property(self, "rect_position", Vector2(16, 16), Vector2(16, -850), .6, tween.TRANS_EXPO, tween.EASE_OUT)
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

func coin_achievements(achievement):
	match achievement.level:
		0:
			Main.upgrades_button.disabled = Main.total < 1
			return Main.total >= 1
		1:
			return Main.total >= 1000
