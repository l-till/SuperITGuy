extends MarginContainer


#
@onready var life_label = $HBoxContainer/LifeCounter/LifeLabel


#
func update_life(value):
	life_label.text = "x" + str(value)


#
func update_score(value):
	$HBoxContainer/Score.text = str(value)
