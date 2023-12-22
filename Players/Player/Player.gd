extends Spatial




 #- Devloper Vars -#
######################
#-HitBox-HurtBox-Vars-#
var PlayerHitBoxMode:int = 0
#-Gravity-Jumping-Vars-#
var GravityAccelSpeed:int = 5
var GravityAccelMax:int = 50
var JumpStrenght:int = -60
var MaxJumpCount:int = 2
#-Acceleration-#
var AccelSpeed:int = 5
var DeaccelSpeed:int = 4
var DeAccelMaxDrop:int = 10
var AirDeAccel:int = 0
var MaxAccel = 50 # Max 100
#-HealthFightVars-#
var MaxHealth:int = 100
#-WallRunAndJump-#
var WallJumpStrenght:int = -60
var WallJumpSpeed:int = 50 # Max 100
var WallRunDuration:int = 30 #Frame Basis not Seconds 1 sec = 24 Frame in this case
var WallRunSpeed = 70 # Max 100
#-OtherPhysicsVars-#
var MidAirDistance:int = 1500
#-Sliding-#
var Sliding:bool = false
var SldingDeAceel:int = 1
######################
 #- Devloper Vars -#







 #-UnchangeableVars-#
######################
#-WallDataVars-#
var WallDataN:Array = []
var WallDataPH:Array = []
var WallCount:int = 0
#-Nodes-#
onready var CameraNode = $Camera
onready var MeshI = $Node/MeshInstance
onready var AnimTree = $AnimationTree
onready var AnimTreeParamters = AnimTree.get("parameters/playback")

#-MouseInputVars-#
var LRY:int = 0
var LRX:int = 0
#-PhysicsVars-#
var LocalFVector:Vector3 = Vector3.ZERO
var Colliding:bool = false
var BakedMathArray:Array = [0,0,0,0,0,0,0,0,0,0,0,10,5,4,2,2,2,1,1,1,0,20,10,7,5,4,3,3,2,2,0,30,15,10,8,6,5,4,4,3,0,40,20,13,10,8,7,6,5,4,0,50,25,17,13,10,8,7,6,5,0,60,30,20,15,12,10,8,7,6,0,70,35,23,18,14,12,10,9,8,0,80,40,27,20,16,13,11,10,9,0,90,45,33,23,18,15,13,11,10]
var CalculatedPhysicResult:Vector3 = Vector3.ZERO
var OnFloor:bool = false
var InMidAir:bool = false
var WallNormal:Vector3 = Vector3.ZERO
var FVector:Vector3 = Vector3.ZERO
#-GravityVars-#
var GravityAccelCurrent:int = 0
var CurrentAccelRatio:int = 0
var CurrentJumpCount:int = 0
#-AimCastingVars-#
var AimResult:Vector3 = Vector3.ZERO
var CurrentWall:Vector3 = Vector3.ZERO
var CloestPlayerRef
#-HealthVars-#
var CurrentHealth:int = 100
#-WallTurnVars-#
var TurnAroundPressed:bool = false
var CurrentTurnRate:int = 0
#-Timer-#
var GlobalTimer:int = 0
######################
 #-UnchangeableVars-#





func _ready():
	yield(get_tree().create_timer(1.0), "timeout")
	SetPhysicReady()


func SetPhysicReady():
	for W in get_tree().get_nodes_in_group("StaticCollsions"):
		WallCount += 1
		WallDataN.append(W.V1)
		WallDataN.append(W.V2)
		WallDataN.append(W.V4)
		WallDataN.append(W.HV)
		WallDataPH.append(W.PV1)
		WallDataPH.append(W.PV2)
		WallDataPH.append(W.PV4)
		WallDataPH.append(W.PHV)


func _input(event):
	if is_network_master():
		if event is InputEventMouseMotion:
			LRY = int(-event.relative.x)
			LRX = int(event.relative.y)


func _physics_process(delta):
	if is_network_master():
		CalculateForwardVector()
		CalculateAimVector()


func CalculateAimVector():
	var AimVector = (-CameraNode.global_transform.basis.z * 10)
	var TotalVector = abs(AimVector.x) + abs(AimVector.y) + abs(AimVector.z)
	var FormulaValue = (TotalVector / 100)
	var CalculatedAimX = (AimVector.x / FormulaValue)
	var CalculatedAimY = (AimVector.y / FormulaValue)
	var CalculatedAimZ = (AimVector.z / FormulaValue)
	CalculatedAimX = stepify(CalculatedAimX,1)
	CalculatedAimY = stepify(CalculatedAimY,1)
	CalculatedAimZ = stepify(CalculatedAimZ,1)
	AimResult = Vector3(CalculatedAimX,CalculatedAimY,CalculatedAimZ)
	AimResult = (AimResult * 1000)


func CalculateForwardVector():
		var RoundedRotation = round(rotation_degrees.y)
		var RotationCalculated:int = 0
		var FVectorX:int = 0
		var FVectorZ:int = 0


		if RoundedRotation <= 90 and RoundedRotation >= 0:
			FVectorZ = -RoundedRotation
			FVectorX = 90 - RoundedRotation

		if RoundedRotation > 90:
			RotationCalculated = RoundedRotation - 90 
			FVectorX = -RotationCalculated
			FVectorZ = 90 - RotationCalculated
			FVectorZ = -FVectorZ
		
		if RoundedRotation < 0 and RoundedRotation > -90:
			RotationCalculated = RoundedRotation * -1
			FVectorZ = RotationCalculated
			FVectorX = 90 - RotationCalculated

		if RoundedRotation <=-90:
			RotationCalculated = RoundedRotation + 90
			FVectorZ = 90 + RotationCalculated
			FVectorX = RotationCalculated * -1
			FVectorX = -FVectorX


		LocalFVector.x = -FVectorZ
		LocalFVector.z = FVectorX
		LocalFVector.y = -1
		LocalFVector = Vector3(stepify(LocalFVector.x, 10),LocalFVector.y,stepify(LocalFVector.z, 10)) * 10








func _get_local_input() -> Dictionary:
	var input := {}
	input["RY"] = LRY
	input["RX"] = LRX
	LRY = 0
	LRX = 0
	input["FV"] = LocalFVector
	if Input.is_action_just_pressed("Jump"):
		input["J"] = true
	if Input.is_action_pressed("ui_up"):
		input["F"] = true
	if Input.is_action_just_pressed("Shoot"):
		input["S"] = true
	if Input.is_action_just_pressed("TurnBack"):
		input["T"] = true
	if Input.is_action_pressed("Slide"):
		input["Slide"] = true
	input["Aim"] = AimResult
	return input


func _network_process(input: Dictionary) -> void:
	SetInput(input.get("FV",Vector3.ZERO))
	MakeRotation(input.get("RY",0),input.get("RX",0))
	AimCasting(input.get("Aim",Vector3.ZERO),input.get("S",false))
	Gravity(input.get("J",false))
	Accelereation(input.get("F",false))
	Sliding(input.get("Slide",false))
	BasicPhysics()
	WallRunAndJump(input.get("T",false),input.get("FV",Vector3.ZERO),input.get("J",0))
	MakeMovement()


func _save_state() -> Dictionary:
	return {
		global_transform = global_transform,
		Colliding = Colliding,
		OnFloor = OnFloor,
		GravityAccelCurrent = GravityAccelCurrent,
		CurrentAccelRatio = CurrentAccelRatio,
		CurrentHealth = CurrentHealth,
		InMidAir = InMidAir,
		WallNormal = WallNormal,
		CurrentTurnRate = CurrentTurnRate,
		TurnAroundPressed = TurnAroundPressed,
		FVector = FVector,
		GlobalTimer = GlobalTimer,
		Sliding = Sliding,
		CurrentJumpCount = CurrentJumpCount
	}


func _load_state(state: Dictionary) -> void:
	global_transform = state['global_transform']
	Colliding = state['Colliding']
	OnFloor = state['OnFloor']
	GravityAccelCurrent = state['GravityAccelCurrent']
	CurrentAccelRatio = state['CurrentAccelRatio']
	CurrentHealth = state['CurrentHealth']
	InMidAir = state['InMidAir']
	WallNormal = state['WallNormal']
	CurrentTurnRate = state['CurrentTurnRate']
	TurnAroundPressed = state['TurnAroundPressed']
	FVector = state['FVector']
	GlobalTimer = state['GlobalTimer']
	Sliding = state['Sliding']
	CurrentJumpCount = state['CurrentJumpCount']
	



func SetInput(FV):
	if OnFloor:
		FVector.x = FV.x
		FVector.z = FV.z
	FVector.y = FV.y


func MakeRotation(RY,RX):
	rotate_y(deg2rad(int(RY)))
	rotation_degrees.x += RX
	rotation_degrees.x = clamp(rotation_degrees.x,-90,90)


func AimCasting(AimVectorS,Shoot): # Rounded One Ray Step Not Dynamic
	if Shoot == true:
		var CountedWallsSC:int = 0
		CurrentWall = Vector3.ZERO
		var CurrentPlayer = Vector3.ZERO
		var CurrentClosestWall = Vector3(100000,100000,100000)
		var CurrentClosestPlayer = Vector3(100000,100000,100000)
		var IndexHelperN:int = 0
		CloestPlayerRef = null
		for WallNumber in WallCount:
			CountedWallsSC += 1
			var V1 = WallDataN[0 + IndexHelperN]
			var V2 = WallDataN[1 + IndexHelperN]
			var V4 = WallDataN[2 + IndexHelperN]
			var HV = WallDataN[3 + IndexHelperN]
			var CurrentWall1 = Vector3(1000000,1000000,1000000)
			var CurrentWall2 = Vector3(1000000,1000000,1000000)
			var CurrentWall3 = Vector3(1000000,1000000,1000000)
			var CurrentWall4 = Vector3(1000000,1000000,1000000)
			var CurrentWall5 = Vector3(1000000,1000000,1000000)

			if global_translation.z < V2.z:
				if (global_translation.z + AimVectorS.z) > V2.z: #Forward AimCheck
					var ZDist = V2.z + -global_translation.z
					var ZCalc = ZDist / AimVectorS.z
					ZCalc = stepify(ZCalc,0.001)
					var ResultX = ZCalc * AimVectorS.x
					var ResultY = ZCalc * AimVectorS.y
					if global_translation.x + ResultX >= V1.x and global_translation.x + ResultX <= V2.x:
						if global_translation.y + ResultY > V1.y and global_translation.y + ResultY < HV.y:
							CurrentWall1 = Vector3(stepify(ResultX,1),stepify(ResultY,1),ZDist)


			if global_translation.z > V4.z:
				if (global_translation.z + AimVectorS.z) < V4.z: #Bottom AimCheck
					var ZDist = V4.z + -global_translation.z
					var ZCalc = ZDist / AimVectorS.z
					ZCalc = stepify(ZCalc,0.001)
					var ResultX = ZCalc * AimVectorS.x
					var ResultY = ZCalc * AimVectorS.y
					if global_translation.x + ResultX >= V1.x and global_translation.x + ResultX <= V2.x:
						if global_translation.y + ResultY > V1.y and global_translation.y + ResultY < HV.y:
							CurrentWall2 = Vector3(stepify(ResultX,1),stepify(ResultY,1),ZDist)


			if global_translation.x < V1.x:
				if (global_translation.x + AimVectorS.x) > V1.x: #Left AimCheck
					var XDist = V1.x + -global_translation.x
					var XCalc = XDist / AimVectorS.x
					XCalc = stepify(XCalc,0.001)
					var ResultZ = XCalc * AimVectorS.z
					var ResultY = XCalc * AimVectorS.y
					if global_translation.z + ResultZ >= V2.z and global_translation.z + ResultZ <= V4.z:
						if global_translation.y + ResultY > V1.y and global_translation.y + ResultY < HV.y:
							CurrentWall3 = Vector3(XDist,stepify(ResultY,1),stepify(ResultZ,1))


			if global_translation.x > V4.x:
				if (global_translation.x + AimVectorS.x) < V4.x: #Right AimCheck
					var XDist = V4.x + -global_translation.x
					var XCalc = XDist / AimVectorS.x
					XCalc = stepify(XCalc,0.001)
					var ResultZ = XCalc * AimVectorS.z
					var ResultY = XCalc * AimVectorS.y
					if global_translation.z + ResultZ >= V2.z and global_translation.z + ResultZ <= V4.z:
						if global_translation.y + ResultY > V1.y and global_translation.y + ResultY < HV.y:
							CurrentWall4 = Vector3(XDist,stepify(ResultY,1),stepify(ResultZ,1))


			if global_translation.y > (HV.y):
				if (global_translation.y + AimVectorS.y) <= HV.y: # Top AimCheck
					var YDist = HV.y + -global_translation.y
					var YCalc = YDist / (AimVectorS.y + 1)
					YCalc = stepify(YCalc,0.001)
					var ResultX = YCalc * AimVectorS.x
					var ResultZ = YCalc * AimVectorS.z
					if global_translation.z + ResultZ >= V2.z and global_translation.z + ResultZ <= V4.z:
						if global_translation.x + ResultX > V1.x and global_translation.x + ResultX < V2.x:
							CurrentWall5 = Vector3(ResultX,YDist,ResultZ)



			if (abs(CurrentWall1.x) + abs(CurrentWall1.z)) <= (abs(CurrentWall2.x) + abs(CurrentWall2.z)):
				CurrentWall1 = CurrentWall1
			else:
				CurrentWall1 = CurrentWall2

			if (abs(CurrentWall3.x) + abs(CurrentWall3.z)) <= (abs(CurrentWall4.x) + abs(CurrentWall4.z)):
				CurrentWall3 = CurrentWall3
			else:
				CurrentWall3 = CurrentWall4

			if (abs(CurrentWall3.x) + abs(CurrentWall3.z)) <= (abs(CurrentWall1.x) + abs(CurrentWall1.z)):
				CurrentWall3 = CurrentWall3
			else:
				CurrentWall3 = CurrentWall1

			if (abs(CurrentWall3.x) + abs(CurrentWall3.z)) <= (abs(CurrentWall5.x) + abs(CurrentWall5.z)):
				CurrentWall = CurrentWall3
			else:
				CurrentWall = CurrentWall5

			if (abs(CurrentWall.x) + abs(CurrentWall.z)) <= (abs(CurrentClosestWall.x) + abs(CurrentClosestWall.z)):
				CurrentClosestWall = CurrentWall
			else:
				CurrentClosestWall = CurrentClosestWall
			IndexHelperN += 4

		for HitBox in get_tree().get_nodes_in_group("PlayerHitBoxes"):
			HitBox.SetPhysics()
			var V1 = HitBox.V1
			var V2 = HitBox.V2
			var V3 = HitBox.V3
			var V4 = HitBox.V4
			var HV = HitBox.HV
			var CurrentWall1 = Vector3(1000000,1000000,1000000)
			var CurrentWall2 = Vector3(1000000,1000000,1000000)
			var CurrentWall3 = Vector3(1000000,1000000,1000000)
			var CurrentWall4 = Vector3(1000000,1000000,1000000)
			var CurrentWall5 = Vector3(1000000,1000000,1000000)
			var CurrentPlayerRef = HitBox.Owner

			if global_translation.z < V2.z:
				if (global_translation.z + AimVectorS.z) > V2.z: #Forward AimCheck
					var ZDist = V2.z + -global_translation.z
					var ZCalc = ZDist / AimVectorS.z
					ZCalc = stepify(ZCalc,0.001)
					var ResultX = ZCalc * AimVectorS.x
					var ResultY = ZCalc * AimVectorS.y
					if global_translation.x + ResultX >= V1.x and global_translation.x + ResultX <= V2.x\
					and global_translation.y + ResultY > V1.y and global_translation.y + ResultY < HV.y:
						CurrentWall1 = Vector3(stepify(ResultX,1),stepify(ResultY,1),ZDist)


			if global_translation.z > V4.z:
				if (global_translation.z + AimVectorS.z) < V4.z: #Bottom AimCheck
					var ZDist = V4.z + -global_translation.z
					var ZCalc = ZDist / AimVectorS.z
					ZCalc = stepify(ZCalc,0.001)
					var ResultX = ZCalc * AimVectorS.x
					var ResultY = ZCalc * AimVectorS.y
					if global_translation.x + ResultX >= V1.x and global_translation.x + ResultX <= V2.x\
					and global_translation.y + ResultY > V1.y and global_translation.y + ResultY < HV.y:
						CurrentWall2 = Vector3(stepify(ResultX,1),stepify(ResultY,1),ZDist)


			if global_translation.x < V1.x:
				if (global_translation.x + AimVectorS.x) > V1.x: #Left AimCheck
					var XDist = V1.x + -global_translation.x
					var XCalc = XDist / AimVectorS.x
					XCalc = stepify(XCalc,0.001)
					var ResultZ = XCalc * AimVectorS.z
					var ResultY = XCalc * AimVectorS.y
					if global_translation.z + ResultZ >= V2.z and global_translation.z + ResultZ <= V4.z\
					and global_translation.y + ResultY > V1.y and global_translation.y + ResultY < HV.y:
						CurrentWall3 = Vector3(XDist,stepify(ResultY,1),stepify(ResultZ,1))


			if global_translation.x > V4.x:
				if (global_translation.x + AimVectorS.x) < V4.x: #Right AimCheck
					var XDist = V4.x + -global_translation.x
					var XCalc = XDist / AimVectorS.x
					XCalc = stepify(XCalc,0.001)
					var ResultZ = XCalc * AimVectorS.z
					var ResultY = XCalc * AimVectorS.y
					if global_translation.z + ResultZ >= V2.z and global_translation.z + ResultZ <= V4.z\
					and global_translation.y + ResultY > V1.y and global_translation.y + ResultY < HV.y:
						CurrentWall4 = Vector3(XDist,stepify(ResultY,1),stepify(ResultZ,1))


			if global_translation.y > (HV.y):
				if (global_translation.y + AimVectorS.y) <= HV.y: # Top AimCheck
					var YDist = HV.y + -global_translation.y
					var YCalc = YDist / (AimVectorS.y + 1)
					YCalc = stepify(YCalc,0.001)
					var ResultX = YCalc * AimVectorS.x
					var ResultZ = YCalc * AimVectorS.z
					if global_translation.z + ResultZ >= V2.z and global_translation.z + ResultZ <= V4.z\
					and global_translation.x + ResultX > V1.x and global_translation.x + ResultX < V2.x:
						CurrentWall5 = Vector3(ResultX,YDist,ResultZ)



			if (abs(CurrentWall1.x) + abs(CurrentWall1.z)) <= (abs(CurrentWall2.x) + abs(CurrentWall2.z)):
				CurrentWall1 = CurrentWall1
			else:
				CurrentWall1 = CurrentWall2

			if (abs(CurrentWall3.x) + abs(CurrentWall3.z)) <= (abs(CurrentWall4.x) + abs(CurrentWall4.z)):
				CurrentWall3 = CurrentWall3
			else:
				CurrentWall3 = CurrentWall4

			if (abs(CurrentWall3.x) + abs(CurrentWall3.z)) <= (abs(CurrentWall1.x) + abs(CurrentWall1.z)):
				CurrentWall3 = CurrentWall3
			else:
				CurrentWall3 = CurrentWall1

			if (abs(CurrentWall3.x) + abs(CurrentWall3.z)) <= (abs(CurrentWall5.x) + abs(CurrentWall5.z)):
				CurrentPlayer = CurrentWall3
			else:
				CurrentPlayer = CurrentWall5

			if (abs(CurrentPlayer.x) + abs(CurrentPlayer.z)) < (abs(CurrentClosestPlayer.x) + abs(CurrentClosestPlayer.z)):
				CurrentClosestPlayer = CurrentPlayer
				CloestPlayerRef = CurrentPlayerRef
			else:
				CurrentClosestPlayer = CurrentClosestPlayer
				CloestPlayerRef = CloestPlayerRef

			if (abs(CurrentClosestPlayer.x) + abs(CurrentClosestPlayer.z)) <= (abs(CurrentClosestWall.x) + abs(CurrentClosestWall.z)):
				CurrentClosestWall = CurrentClosestPlayer
				
			else:
				CurrentClosestWall = CurrentClosestWall

		MeshI.global_translation = CameraNode.global_translation + CurrentClosestWall
		if CloestPlayerRef != null:
			print(CloestPlayerRef)
			CloestPlayerRef.CurrentHealth -= 10
			if CloestPlayerRef.CurrentHealth <= 0:
				CloestPlayerRef.global_translation.z += 1000
				CloestPlayerRef.CurrentHealth = MaxHealth


func Gravity(Jump):
	if OnFloor:
		CurrentJumpCount = 0
		GlobalTimer = 0
		AnimTreeParamters.travel("Sliding")
	if Jump:
		if GlobalTimer == 0 or GlobalTimer > WallRunDuration:
			if CurrentJumpCount < MaxJumpCount:
				CurrentJumpCount += 1
				GravityAccelCurrent = JumpStrenght
		


	GravityAccelCurrent += GravityAccelSpeed
	if GravityAccelCurrent >= GravityAccelMax:
		GravityAccelCurrent = GravityAccelMax


func Accelereation(F):
	if F:
		if OnFloor:
			if not Sliding:
				if CurrentAccelRatio < MaxAccel:
					CurrentAccelRatio += AccelSpeed

				if CurrentAccelRatio > MaxAccel:
					CurrentAccelRatio -= DeAccelMaxDrop
	else:
		if OnFloor:
			if not Sliding:
				if CurrentAccelRatio > MaxAccel:
					CurrentAccelRatio -= DeAccelMaxDrop
			
				elif not CurrentAccelRatio > MaxAccel:
					CurrentAccelRatio -= DeaccelSpeed
			else:
				CurrentAccelRatio -= SldingDeAceel
		if CurrentAccelRatio <= 0:
			CurrentAccelRatio = 0


func BasicPhysics(): # So Basic But Fast
	WallNormal = Vector3.ZERO
	InMidAir = false
	OnFloor = false
	Colliding = false
	var IndexHelperN:int = 0
	CalculatedPhysicResult.x = (global_translation.x + (FVector.x / 100) * CurrentAccelRatio)
	CalculatedPhysicResult.z = (global_translation.z + (FVector.z / 100) * CurrentAccelRatio)
	CalculatedPhysicResult.y = (global_translation.y + (FVector.y * GravityAccelCurrent))
	var GlobalTranslation:Vector3 = global_translation
	var FVectorXDvided = (FVector.x / 100)
	var FVectorYDvided = (FVector.y / 10)
	var FVectorZDvided = (FVector.z / 100)
	var ColideCount:int = 0
	var NextFrameVectorX:int = (global_translation.x + FVector.x)
	var NextFrameVectorZ:int = (global_translation.z + FVector.z)
	for WallNumber in WallCount:
		var V1 = WallDataPH[0 + IndexHelperN]
		var V2 = WallDataPH[1 + IndexHelperN]
		var V4 = WallDataPH[2 + IndexHelperN]
		var HV = WallDataPH[3 + IndexHelperN]

		if CalculatedPhysicResult.z >= V2.z and CalculatedPhysicResult.z <= V4.z:
			if CalculatedPhysicResult.x >= V1.x and CalculatedPhysicResult.x <= V2.x:

				if GlobalTranslation.z <= V2.z:
					if NextFrameVectorZ >= V2.z:
						var ZDist = V2.z + -GlobalTranslation.z
						var StepSize = BakedMathArray[(ZDist / 10) + FVectorZDvided]
						var ResultY = stepify((FVectorYDvided * StepSize),1)
						var ResultCalculatedY = (GlobalTranslation.y + ResultY)
						if ResultCalculatedY >= V1.y and ResultCalculatedY <= HV.y:
							CalculatedPhysicResult.z = V2.z
							WallNormal.z = -1
							Colliding = true
							ColideCount += 1


				if GlobalTranslation.z >= V4.z:
					if NextFrameVectorZ <= V4.z:
						var ZDist = GlobalTranslation.z - V4.z
						var StepSize = BakedMathArray[(ZDist / 10) + FVectorZDvided]
						var ResultY = stepify((FVectorYDvided * StepSize),1)
						var ResultCalculatedY = (GlobalTranslation.y + ResultY)
						if ResultCalculatedY > V1.y and ResultCalculatedY < HV.y:
							CalculatedPhysicResult.z = V4.z
							WallNormal.z = 1
							Colliding = true
							ColideCount += 1


				if GlobalTranslation.x <= V1.x:
					if NextFrameVectorX >= V1.x:
						var XDist = V1.x + -GlobalTranslation.x
						var StepSize = BakedMathArray[(XDist / 10) + FVectorXDvided]
						var ResultY = stepify((FVectorYDvided * StepSize),1)
						var ResultCalculatedY = (GlobalTranslation.y + ResultY)
						if ResultCalculatedY > V1.y and ResultCalculatedY < HV.y:
							CalculatedPhysicResult.x = V1.x
							WallNormal.x = -1
							Colliding = true
							ColideCount += 1


				if GlobalTranslation.x >= V4.x:
					if NextFrameVectorX <= V4.x:
						var XDist = V4.x + -GlobalTranslation.x
						var StepSize = BakedMathArray[(XDist / 10) + FVectorXDvided]
						var ResultY = stepify((FVectorYDvided * StepSize),1)
						var ResultCalculatedY = (GlobalTranslation.y + ResultY)
						if ResultCalculatedY > V1.y and ResultCalculatedY < HV.y:
							CalculatedPhysicResult.x = V4.x
							WallNormal.x = 1
							Colliding = true
							ColideCount += 1


				if global_translation.y >= HV.y:
					if (global_translation.y - HV.y) > MidAirDistance:
						InMidAir = true
					if CalculatedPhysicResult.y <= HV.y:
						CalculatedPhysicResult.y = HV.y
						OnFloor = true


		IndexHelperN += 4

	if ColideCount > 1:
		CalculatedPhysicResult.x = global_translation.x
		CalculatedPhysicResult.z = global_translation.z


func WallRunAndJump(TurnInput,FV,WallJump):
	if InMidAir:
		if Colliding:
				var AbsulteWallNormalX = abs(WallNormal.x)
				var AbsulteWallNormalZ = abs(WallNormal.z)
				if FVector.x > (AbsulteWallNormalZ * -200)\
				and FVector.x < (AbsulteWallNormalZ * 200)\
				or FVector.z > (AbsulteWallNormalX * -200)\
				and FVector.z < (AbsulteWallNormalX * 200):
					AnimTreeParamters.travel("Sliding")
					if TurnInput:
						TurnAroundPressed = true
				else: # The think player can show skill here
					GlobalTimer += 1
					if GlobalTimer <= WallRunDuration:
						AnimTreeParamters.travel("WallRun")
						CurrentAccelRatio = WallRunSpeed
						GravityAccelCurrent = -GravityAccelSpeed
						if WallNormal.x == 1:
							if FVector.z > 0:
								FVector.z = 900
								FVector.x = 0
								AnimTree.set("parameters/WallRun/Transition/current",false)
							else:
								FVector.z = -900
								FVector.x = 0
								AnimTree.set("parameters/WallRun/Transition/current",true)

						elif WallNormal.x == -1:
							if FVector.z > 0:
								FVector.z = 900
								FVector.x = 0
								AnimTree.set("parameters/WallRun/Transition/current",true)
							else:
								FVector.z = -900
								FVector.x = 0
								AnimTree.set("parameters/WallRun/Transition/current",false)

						elif WallNormal.z == 1:
							if FVector.x > 0:
								FVector.x = 900
								FVector.z = 0
								AnimTree.set("parameters/WallRun/Transition/current",true)
							else:
								FVector.x = -900
								FVector.z = 0
								AnimTree.set("parameters/WallRun/Transition/current",false)

						elif WallNormal.z == -1:
							if FVector.x > 0:
								FVector.x = 900
								FVector.z = 0
								AnimTree.set("parameters/WallRun/Transition/current",false)
							else:
								FVector.x = -900
								FVector.z = 0
								AnimTree.set("parameters/WallRun/Transition/current",true)
								
						if WallJump:
							GlobalTimer = WallRunDuration + 10
							FVector += WallNormal * 900
							GravityAccelCurrent = WallJumpStrenght
							AnimTreeParamters.travel("Sliding")
							CurrentJumpCount = (MaxJumpCount - 1)
					else:
						AnimTreeParamters.travel("Sliding")
	if TurnAroundPressed:
		CurrentTurnRate += 30
		rotate_y(deg2rad(int(30)))
		if CurrentTurnRate == 180:
			FVector = WallNormal * 900
			CurrentTurnRate = 0
			TurnAroundPressed = false
			CurrentAccelRatio = WallJumpSpeed
			GravityAccelCurrent = WallJumpStrenght


func Sliding(input):
	if input:
		Sliding = true
		AnimTree.set("parameters/Sliding/Transition/current",true)
		AnimTreeParamters.travel("Sliding")
	else:
		Sliding = false
		AnimTree.set("parameters/Sliding/Transition/current",false)


func MakeMovement():
	if is_network_master():
		$Accel.text = str(CurrentAccelRatio)
		$GlobalTimer.text = str(GlobalTimer)
		$JumpCount.text = str(CurrentJumpCount)
	if Colliding:
		global_translation = CalculatedPhysicResult
	else:
		global_translation.x += (FVector.x / 100) * CurrentAccelRatio
		global_translation.z += (FVector.z / 100) * CurrentAccelRatio
		global_translation.y = CalculatedPhysicResult.y



#func TakeHit():
#	if CurrentHealth <= 0:
#

















































