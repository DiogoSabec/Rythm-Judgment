extends Control

var level = "res://World/world.tscn"
@onready var pause = $"."

func _on_btn_play_click_end():
	var _level = get_tree().change_scene_to_file(level)

func _on_btn_exit_click_end():
	get_tree().quit()


func _on_btn_return_click_end():
	pause.visible = false
	Engine.time_scale = 1
