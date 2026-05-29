class_name InteractTrigger

extends Area3D

signal interacted(player: Player)

@export var tooltip: String = "Sample tooltip"


func interact(player: Player):
	interacted.emit(player)
