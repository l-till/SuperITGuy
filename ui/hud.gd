extends MarginContainer


#
@onready var life_label = $HBoxContainer/LifeCounter/LifeLabel

func _ready():
	GameState.lives_changed.connect(update_life)
	update_life(GameState.lives)

#
func update_life(value):
	life_label.text = "X" + str(value)


#
func update_score(value):
	$HBoxContainer/Score.text = str(value)
