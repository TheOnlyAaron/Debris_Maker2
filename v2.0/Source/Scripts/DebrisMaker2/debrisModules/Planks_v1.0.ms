--*****************************************************
-- Tool part of the DebrisMaker 2.0 by
-- Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.0 : 03.12.2012  >> Created					  
--*****************************************************

planksModuleVer = 1.0
try(removeSubRollout debrisMaker.theSubrollout planksModule)catch()

(
	global plank_lengthMax
	global plank_lengthMin
	global plank_widthMax
	global plank_widthMin
	global plank_heightMax
	global plank_heightMin
	global plankIrregularEnds
	global plankCracks
	global plankCracksCount
	global plankBreak
	global plankKnotHoles
	global curLength
	global curWidth
)

rollout planksModule ("Planks v" + (planksModuleVer as string))
(
	groupbox optionsGrp "Options"  width:177 pos:[5,5] height:285
		spinner spinnerPlankCount "" range:[1,25,10] type:#integer pos:[12,25] width:40
		label labelShardSides ":Number of planks" offset:[40,-20] align:#left
	
		spinner spinnerLenMax "" range:[10,80,60] type:#float pos:[12,45] width:40
		label labelLenMax ":Length Max" offset:[40,-20] align:#left
		spinner spinnerLenMin "" range:[10,80,50] type:#float pos:[12,65] width:40
		label labelLenMin ":Length Min" offset:[40,-20] align:#left
	
		spinner spinnerWidthMax "" range:[.5,20,6] type:#float pos:[12,85] width:40
		label labelWidthMax ":Width Max" offset:[40,-20] align:#left
		spinner spinnerWidthMin "" range:[.5,20,4] type:#float pos:[12,105] width:40
		label labelWidthMin ":Width Min" offset:[40,-20] align:#left	
	
		spinner spinnerHeightMax "" range:[.5,20,1] type:#float pos:[12,125] width:40
		label labelHeightMax ":Height Max" offset:[40,-20] align:#left
		spinner spinnerHeightMin "" range:[.5,20,1] type:#float pos:[12,145] width:40
		label labelHeightMin ":Height Min" offset:[40,-20] align:#left	
	
		checkbox checkboxIrregularEnds "Irregular Ends" pos:[12,165] checked:true
		checkbox checkboxBreakPlanks "Break Planks" pos:[12,185]  checked:true
		checkbox checkboxKnotHoles "Knot Holes" pos:[12,205]  checked:true
		checkbox checkboxTwist "Twist Planks" pos:[12,225]  checked:true
		
		checkbox checkboxPlankCracks "Plank Cracks" pos:[12,245]  checked:false
			spinner spinnerPlankCracks "" range:[1,4,2] type:#integer pos:[22,265] width:40 enabled:false
			label labelPlankCracks ":Number of cracks" offset:[50,-20] align:#left enabled:false


	groupbox groupboxGeneration "Generation" pos:[5,295] height:80 width:177
		button GenerateButton "<<  Generate  >>" width:164 height:30 offset:[-1,-70]
		progressbar theProgressGroup width:165 height:6 offset:[-3,0] value:0
		label progressLabel " status: ready" offset:[-1,-5] style_sunkenedge:true width:165 height:16
		
	FN FN_BaseMesh =
		(
		curWidth = (random plank_widthMax plank_widthMin)
		curLength = (random plank_lengthMin plank_lengthMax)
		newDebris = plane length:curLength  width:curWidth lengthSegs:curLength widthSegs:curWidth
				
		newDebris
		)

	FN FN_AddThickness arg = -- arg: newDebris
		(
		newDebris = arg
			
		curThickness = (random plank_heightMin plank_heightMax)
			
		if curThickness > 1
		then (curSegs = 3)
		else(curSegs =2)
		
		newShell = shell outerAmount:curThickness

		addmodifier newDebris newShell
		newShell.Segments = curSegs
		
		newRelax = relax Relax_Value:.6
		addmodifier newDebris newRelax
		)
		
	FN FN_IrregularEnds arg = -- arg: newDebris
		(
		newDebris = arg
			
		newVolSel = Vol__Select level:2 method:0 invert:on volume:0
		addmodifier newDebris newVolSel
		validmodifier newDebris newVolSel
		
		newVolSel.gizmo.scale = [1.1,.95,1.1]
		
		if highPoly == true
		then()
		else(
			newTesselate = tessellate iterations:0 tension:0
			addmodifier newDebris newTesselate
			)
			
		newSubdivide = subdivide size:5
		addmodifier newDebris newSubdivide
		
		newVolSel = Vol__Select level:1 method:0 invert:on volume:0 UseAffectRegion:on falloff:2.5
		addmodifier newDebris newVolSel
		validmodifier newDebris newVolSel
		
		newVolSel.gizmo.scale = [1.1,.8,1.1]
		
		newNoise = noisemodifier scale: (random 1.5 5.8) strength: [0,(random .25 .80 ),0] fractal:on seed: (random 0 9999)
		addmodifier newDebris newNoise
		validmodifier newDebris newNoise
		
		newNoise.gizmo.scale = [1,1,10]
		
		converttopoly newDebris
		)
		
	FN FN_Cracks arg = -- arg: newDebris
		(
		newDebris = arg
			
		for i in 1 to plankCracksCount do
			(
			curLength2 = (((random .8 .3) *curLength) as integer)
			
			coinFlip = (random 1 2)
			whichEnd = undefined
			case coinFlip of
				(
				1:(whichEnd = -1)	
				2:(whichEnd = 1)
				)
			
			posY = (((curLength *.5) - (curLength2 * .4))*whichEnd)
			posX = (random ((curWidth *.50) * -1) ((curWidth *.50)))
			newCrack = box length:curLength2 height:3 width:(random .05 .30) pos:[posX,posY,-.5] heightsegs:5 lengthsegs:curLength2 rotation:(angleaxis (random -30 30) [0,1,0])
			
			newTaper = taper primaryaxis:1 effectaxis:0 amount:(whichEnd * 1.5)
			addmodifier newCrack newTaper

			newTurbosmooth = turbosmooth iterations:1
			addmodifier newCrack newTurbosmooth
			
			newNoise = noisemodifier scale: (random 4.0 6.0) strength: [(random .25 .50 ),0,0] fractal:on seed: (random 0 9999)
			addmodifier newCrack newNoise
			
			newSubdivide = subdivide()
			addmodifier newCrack newSubdivide
			addmodifier newCrack newSubdivide
			newSubdivide. size = .5
			
			ProBoolean.createBooleanObject newDebris newCrack 2 0 0
			
			newSubdivide = subdivide()
			addmodifier newDebris newSubdivide
			addmodifier newDebris newSubdivide
			newSubdivide. size = .5
			)
			
		newVertexWeld = vertexweld threshold:.04
		addmodifier newDebris newVertexWeld
		)
		
	FN FN_KnotHoles arg =--arg: newDebris
		(
		newDebris = arg
			
		for i in 1 to (random 0 2) do
			(
			newKnotBool = cylinder radius: (random .75 .25) height: 3 heightsegs: 4 capsegs: 2 sides: 16 pos:[(random ((curWidth*.5)*-1) (curWidth*.5)),(random ((curLength*.5)*-1) (curLength*.5)),-.5] scale:[1,(random 1.5 2),1]
			newTaper = taper amount: -3 curve: 3 primaryaxis: 1 effectaxis: 0
			addmodifier newKnotBool newTaper
				
			newNoise = noiseModifier strength: [0.35,0.35,0] seed:(random 1 9999) fractal:on scale:.75
			addmodifier newKnotBool newNoise 

			ProBoolean.createBooleanObject newDebris newKnotBool 2 0 0
				
			newSubdivide = subdivide()
			addmodifier newDebris newSubdivide
			addmodifier newDebris newSubdivide
			newSubdivide. size = .5
			)
			
		newVertexWeld = vertexweld threshold:.07
		addmodifier newDebris newVertexWeld
		)

	FN FN_BreakBoards arg = -- arg: newDebris
		(
		newDebris = arg
			
		newBoxBool = box lengthsegs:1 widthsegs:40 heightsegs:40 length:(random 10 50) width:10 height:10
		newBoxBool.pivot = newBoxBool.center
		
		newNoise = noiseModifier seed:(random 1 9999) scale: 0.04 strength: [0,(random 5.0 6.0),0] 	
		addmodifier newBoxBool newNoise
			
		newBoxBool.pos = [0,(random 0 (plank_lengthMax * .5)),0]
		newBoxBool.scale = [1,1,.5]
			
		newTaper = taper primaryaxis: 2 effectaxis: 2 amount: ((random .25 .75) * -1)
		addmodifier newBoxBool newTaper
		
		newNoise = noiseModifier seed:(random 1 9999) scale: (random 6.0 8.0) strength: [0,(random 10 15),0] 	fractal:on
		addmodifier newBoxBool newNoise
			
		ProBoolean.createBooleanObject newDebris newBoxBool 1 0 0
			
		newSubdivide = subdivide()
		addmodifier newDebris newSubdivide
		addmodifier newDebris newSubdivide
		newSubdivide. size = .5
			
		)
		
	FN FN_Bend arg =
		(
		newDebris = arg
		newBend = bend BendAngle:(random -30 30) BendAxis:0
		addmodifier newDebris newBend
		)
		
	FN FN_Warp arg =
		(
		newDebris = arg
		newNoise = noisemodifier scale:(random .25 .50) seed:(random 0 9999) strength:[0,0,(random .15 .3)]
		addmodifier newDebris newNoise
		validmodifier newDebris newNoise
			
		newNoise.gizmo.scale = [1,40,1]
		)
		
	FN FN_Twist arg =
		(
		newDebris = arg
		newTwist = twist angle:(random -30 30) axis:1 bias:(random 0 50)
		addmodifier newDebris newTwist
		)
		
	on spinnerlenMax changed state do(if state < spinnerlenMin.value then spinnerlenMin.value = state else())		
	on spinnerlenMin changed state do(if state > spinnerlenMax.value then spinnerlenMax.value = state else())
		
	on spinnerWidthMax changed state do(if state < spinnerWidthMin.value then spinnerWidthMin.value = state else())		
	on spinnerWidthMin changed state do(if state > spinnerWidthMax.value then spinnerWidthMax.value = state else())
	
	on spinnerHeightMax changed state do(if state < spinnerHeightMin.value then spinnerHeightMin.value = state else())		
	on spinnerHeightMin changed state do(if state > spinnerHeightMax.value then spinnerHeightMax.value = state else())
		
	on checkboxPlankCracks changed state do
	(
	spinnerPlankCracks.enabled = state
	labelPlankCracks.enabled = state
	)

	on GenerateButton pressed do
	(
	timerStart = timeStamp()
		
	debrisCount = spinnerPlankCount.value --10

	plank_lengthMax = spinnerLenMax.value --60
	plank_lengthMin = spinnerLenMin.value --50--20
	plank_widthMax = spinnerWidthMax.value --4--8
	plank_widthMin = spinnerWidthMin.value --6--2
	plank_heightMax = spinnerHeightMax.value --1--1.5
	plank_heightMin = spinnerHeightMin.value --1--.5

	plankIrregularEnds = checkboxIrregularEnds.checked --true
	plankCracks = checkboxPlankCracks.checked --false
		plankCracksCount = spinnerPlankCracks.value--2
	plankBreak = checkboxBreakPlanks.checked -- true
	plankKnotHoles = checkboxKnotHoles.checked --True

	curLength = undefined
	curWidth = undefined		
		
	max create mode
		
	i = 0
	while i < debrisCount do
		(
		theProgressGroup.value  = (((i + 0.00) / debrisCount) * 100)
		progressLabel.text = (" status: Building " + (i as string) + " of " + (debrisCount as string))
-- 		print i
		newDebris = FN_BaseMesh()
		FN_AddThickness newDebris

		if plankIrregularEnds == true then (FN_IrregularEnds newDebris)else()
		if plankBreak == true then (FN_BreakBoards newDebris)else()
		if plankKnotHoles == true then (FN_KnotHoles newDebris)else()
		if plankCracks == true then (FN_Cracks newDebris)else()
			
		FN_Warp newDebris
		FN_Bend newDebris
		if checkboxTwist.checked then (FN_Twist newDebris)else()

		converttopoly newDebris
		newDebris.pivot = newDebris.center
		newDebris.position = [0,0,0]
			
		scale newDebris [.5,.5,.5]
		ResetScale newDebris

		newDebris.name = ("Plank_"+(i as string))
		newdebris.wirecolor = [20,20,20]
		move newdebris [(i*10),0,0]
			
		if newDebris.GetNumVertices() > 1500
		then(i += 1)
		else
			(
-- 			print "FAIL!!!"
	-- 		print (i as string)
			delete newDebris
			)
		)
	timerEnd = timeStamp()
	progressLabel.text =  (" Generation took: " + (((timerEnd - timerStart) / 1000.0) as string) + " s")
	)		
)
AddSubRollout DebrisMaker.theSubrollout planksModule
debrisMaker.height = 430