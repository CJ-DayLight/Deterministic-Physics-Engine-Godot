tool
extends Spatial


export var Height :int = 2
export var Depth :int = 2
export var Width :int = 2

var PlayerWide:int = 500
var PlayerDepth:int = 500
var PlayerHeight:int = 2100

var V1 :Vector3 = Vector3(1,1,1)
var V2 :Vector3 = Vector3(1,1,1)
var V3 :Vector3 = Vector3(1,1,1)
var V4 :Vector3 = Vector3(1,1,1)
var HV :Vector3 = Vector3(0,0,1)

var PV1:Vector3 = Vector3(0,0,0)
var PV2:Vector3 = Vector3(0,0,0)
var PV4:Vector3 = Vector3(0,0,0)
var PHV:Vector3 = Vector3(0,0,0)





func _ready():
	SetPhysics()

func _physics_process(delta):
	SetPhysics()





func SetPhysics():
	V1 = global_translation
	V2 = global_translation + Vector3(Width,0,0)
	V3 = global_translation + Vector3(0,0,Depth)
	V4 = global_translation + Vector3(Width,0,Depth)
	HV = global_translation + Vector3(0,Height,0)
	PV1.x = V1.x - PlayerWide
	PV1.z = V1.z - PlayerDepth
	PV2.x = V2.x + PlayerWide
	PV2.z = V2.z - PlayerDepth
	PV4.x = V4.x + PlayerWide
	PV4.z = V4.z + PlayerWide
	PHV.y = HV.y + PlayerHeight
	$V1.global_translation = V1
	$V2.global_translation = V2
	$V3.global_translation = V3
	$V4.global_translation = V4
	$CSGPolygon.global_translation = global_translation
	$CSGPolygon.polygon = PoolVector2Array([Vector2(0, 0), Vector2(Depth,0), Vector2(Depth,Height), Vector2(0,Height)])
	$CSGPolygon.depth = Width
