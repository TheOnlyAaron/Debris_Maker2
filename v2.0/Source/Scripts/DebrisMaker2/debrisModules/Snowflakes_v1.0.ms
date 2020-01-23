--*****************************************************
-- Tool part of the DebrisMaker 2.0 by
-- Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.0 : 05.09.2014  >> Created					  
--*****************************************************

snowflakeModuleVer = 1.0
try(removeSubRollout debrisMaker.theSubrollout snowflakeModule)catch()

global armCount = 50
global widthAmount 
global debrisCount = 5
global newDebris = 5

rollout snowflakeModule ("Snowflakes v" + (snowflakeModuleVer as string))
(
	groupbox geometryShards "Option"  width:177 pos:[5,5] height:45
		spinner spinnerDebrisCount "" range:[1,50,5] type:#integer pos:[12,25] width:40
		label labelDebrisCount ":Snowflakes count" offset:[40,-20] align:#left
	
	groupbox groupboxGeneration "Generation" pos:[5,50] height:80 width:177
		button GenerateButton "<<  Generate  >>" width:164 height:30 offset:[-1,-70]
		progressbar theProgressGroup width:165 height:6 offset:[-3,0] value:0
		label progressLabel " status: ready" offset:[-1,-5] style_sunkenedge:true width:165 height:16
	
fn FN_SexaSemetry argObj =
	(
	newSem0 = symmetry flip:on threshold: .01 
	addmodifier argObj newSem0
	newSem0.mirror.rotation = (quat 0 0 0.707107 0.707107)
	newSem1 = symmetry flip:on threshold: .01 
	addmodifier argObj newSem1
	newSem1.mirror.rotation = (quat 0 0 -0.5 0.866025)
	newSem2 = symmetry flip:off threshold: .01 
	addmodifier argObj newSem2
	newSem1.mirror.rotation = (quat 0 0 0.866025 -0.5)
	newSem3 = symmetry flip:on threshold: .01 
	addmodifier argObj newSem3
	newSem3.mirror.rotation = (quat 0 0 0.707107 0.707107)
	)
	
fn FN_ArmBase argObj = 
	(
	argObj = newDebris
	baseArm = box length:(random .25 1.75) width:widthAmount height:1 widthsegs:widthAmount  pos:[(widthAmount *.4),0,0] -- (random .25 1.75)
	newNoise = noisemodifier strength:[0,(random 1 .5),0] scale:.5 seed:(random 0 1111)
	newTaper = taper primaryaxis:0 effectaxis:1
	addmodifier baseArm newNoise
	addmodifier baseArm newTaper
	newTaper.gizmo.rotation += quat 0 0 -1 0
	newDebris + baseArm
	delete baseArm
	newDebris
	)
	
fn FN_SubArm arg1 arg2=  --arg1: curThickness | arg2: curWidth
	(
	newArm = box length:arg1 width:arg2 height:1 widthsegs:2  pos:[(widthAmount *.4),0,0]
	newNoise = noisemodifier strength:[0,(random .2 .05),0] scale:.5 seed:(random 0 1111)
	newTaper = taper primaryaxis:0 effectaxis:1
	addmodifier newArm newNoise
	addmodifier newArm newTaper
	newTaper.gizmo.rotation += quat 0 0 -1 0
	newArm
	)
	
fn FN_DeleteTop argObj =
	(
	newDebris = argObj
	newVolSel = Vol__Select level:2 volume:0 type:1
	addmodifier newDebris newVolSel
	validmodifier newDebris newVolSel
	newVolSel.gizmo.position = [0,0,.1]
	newDeletemesh = deletemesh()
	addmodifier newDebris newDeletemesh
	converttopoly newDebris
	newVertexWeld = vertexWeld threshold:.08
	addmodifier NewDebris newVertexWeld
	converttopoly newDebris
	)
	
fn FN_AddThickness argObj =
	(
	argObj = newDebris
	newShell = shell outerAmount:0 innerAmount: (random .25 .50)
	addmodifier argObj newShell
	newRelax = relax Relax_Value:.5 iterations:4
	addmodifier argObj newRelax
	newVertexWeld = vertexWeld threshold:.025
	addmodifier NewDebris newVertexWeld
	newSmooth = smooth autosmooth:on  preventIndirect:on threshold:120
	addmodifier newDebris newSmooth
	newVertexWeld = vertexWeld threshold:.05
	addmodifier NewDebris newVertexWeld
	)

fn FN_AddSubArms arg = --arg:newDebris
	(
	newDebris = arg
		
	curThickness = (random .25 2.25)
	curModulus = 1
	for i in 1 to armCount do
		(
		curModulus = ( curModulus * .8)
		curThickness = (curThickness *.8)
		curWidth = ((random .50 .90) * widthAmount)
		newArm = FN_SubArm curThickness curWidth
		randCase = (random 1 2) -- front or back rotation
		case randCase of 
			(
			1:(rotate newArm (angleaxis -60 [0,0,1]))
			2:(rotate newArm (angleaxis -120 [0,0,1]))
			)
			
		w2 = (widthAmount  + .01 )
		spacing = w2 / (armCount + 2)
		newArm.pos.x = (spacing *i)
		newArm.scale = [curModulus,1,1]
		converttopoly newArm
		newDebris + newArm
		delete newArm
		)
	)

on GenerateButton pressed do
	(
	debrisCount = spinnerDebrisCount.value	
	timerStart = timeStamp()
		
	for j in 1 to debrisCount do 
		(
		theProgressGroup.value  = (((j + 0.00) / debrisCount) * 100)
		progressLabel.text = (" status: Building " + (j as string) + " of " + (debrisCount as string))
			
		try(
			widthAmount = (random 8 15)
			armCount = (random 3 15) 
			newDebris = box length:.1 width:.1 height:.1 pos:[0,0,10]
			converttopoly newDebris
			newDebris = FN_ArmBase newBaseObj
			FN_AddSubArms newDebris
			FN_SexaSemetry newDebris
			FN_DeleteTop newDebris
			FN_AddThickness newDebris
			
			progressLabel.text = (" status: Placing " + (j as string) + " of " + (debrisCount as string))
				
			converttopoly newDebris
			newDebris.pivot = newDebris.center
			resetscale newDebris
			newDebris.pos = [((j-1)*25),0,0]
			newDebris.wirecolor = [20,20,20]
			
			newDebris.name = ("snowflake_" + (j as string) )
			
			)catch()
		)
		
	timerEnd = timeStamp()
	progressLabel.text =  (" Generation took: " + (((timerEnd - timerStart) / 1000.0) as string) + " s")
	)
)

AddSubRollout DebrisMaker.theSubrollout snowflakeModule
debrisMaker.height = 185