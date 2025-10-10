extends Node


func _ready() -> void:
	SceneLoader.main_node = self
	SceneLoader.load_scene("main_menu", true)
