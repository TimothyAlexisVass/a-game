extends Panel

var achievement_template = preload("res://scenes/achievement.tscn")
var achievement_object

var enable_achievements = funcref(self, "enable_achievements")
var enable_upgrades = funcref(self, "enable_upgrades")

var get_total = funcref(self, "get_total")

var open = [
	{
		"title": "Event",
		"requirement": [get_total, .3],
		"function": enable_achievements
	},
	{
		"title": "Your first coin!",
		"requirement": [get_total, 1],
		"image": load("res://assets/achievement_images/your_first_coin.svg"),
		"reward": "Enable upgrades.",
		"function": enable_upgrades
	},
	{
		"title": "Your second coin!",
		"requirement": [get_total, 3],
		"image": load("res://assets/achievement_images/your_first_coin.svg"),
		"reward": "Enable upgrades.",
		"function": enable_upgrades
	}
	
]

var done = []

onready var tween = get_node("Tween")

func _ready():
	self.visible = false
	for achievement in open:
		if achievement["title"] != "Event":
			achievement_object = achievement_template.instance()
			achievement_object.get_child(0).get_child(0).texture_normal = achievement["image"]
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

func enable_achievements():
	Main.achievements_button.visible = true

func enable_upgrades():
	Main.upgrades_button.disabled = false

func get_total():
	return Main.total

func _on_CheckAchievements_timeout():
	for achievement in open:
		if achievement["requirement"][0].call_func() >= achievement["requirement"][1]:
			achievement["function"].call_func()
			done.append(achievement)
			open.erase(achievement)
