extends CanvasLayer

@onready var score_item_container: VBoxContainer = $MarginContainer/Board/HighScores/ScoreItemContainer
@onready var loading_container: CenterContainer = $MarginContainer/Board/LoadingContainer


func _ready() -> void:
	visible = false


func display():
	visible = true
	
	var scores = await get_high_scores()
	print(scores)
	update_score_display(scores)


func get_high_scores():
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores().sw_get_scores_complete
	return(sw_result.scores)


func update_score_display(scores):
	loading_container.visible = false
	for score in scores:
		var l: Label = Label.new()
		l.text = score.player_name + ": " + str(-score.score)
		score_item_container.add_child(l)
