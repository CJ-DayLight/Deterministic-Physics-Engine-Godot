tool
extends Spatial

export var X:int = 1
export var Y:int = 1
export var Z:int = 1

var PlayerRotationY = 0
onready var OwnerNode = $"../.."




func _physics_process(delta):
	global_translation = $"../..".global_translation + Vector3(X,Y,Z)
	PlayerRotationY = $"../..".rotation_degrees.y
	rotation_degrees.y = PlayerRotationY
	
