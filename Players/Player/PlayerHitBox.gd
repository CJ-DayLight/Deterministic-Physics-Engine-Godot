tool
extends Spatial

export var Height :int = 0
export var Depth :int = 0
export var Width :int = 0

export var X:int = 0
export var Y:int = 0
export var Z:int = 0
onready var Owner = $"../.."

var V1 :Vector3 = Vector3(1,1,1)
var V2 :Vector3 = Vector3(1,1,1)
var V3 :Vector3 = Vector3(1,1,1)
var V4 :Vector3 = Vector3(1,1,1)
var HV :Vector3 = Vector3(0,0,1)


func _ready():
	SetPhysics()

func _physics_process(delta):
	SetPhysics()




func SetPhysics():
	V1 = $"../..".global_translation + Vector3(X,Y,Z)
	V2 = $"../..".global_translation + Vector3(Width,0,0) + Vector3(X,Y,Z)
	V3 = $"../..".global_translation + Vector3(0,0,Depth) + Vector3(X,Y,Z)
	V4 = $"../..".global_translation + Vector3(Width,0,Depth) + Vector3(X,Y,Z)
	HV = $"../..".global_translation + Vector3(0,Height,0) + Vector3(0,Y,0)
	$V1.global_translation = V1
	$V2.global_translation = V2
	$V3.global_translation = V3
	$V4.global_translation = V4
	$HV.global_translation = HV
	$CSGPolygon.polygon = PoolVector2Array([Vector2((0 + X), -(0 + Y)), Vector2((Width + X), -(0 + Y)), Vector2((Width + X),-(Height + Y)), Vector2((0 + X),-(Height + Y))])
	$CSGPolygon.depth = Depth
	$CSGPolygon.global_translation.z = ($"../..".global_translation.z + Z)
	$CSGPolygon.global_translation.x = ($"../..".global_translation.x)
	$CSGPolygon.global_translation.y = ($"../..".global_translation.y)
	
