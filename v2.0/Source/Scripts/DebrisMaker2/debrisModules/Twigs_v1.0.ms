--*****************************************************
-- Tool part of the DebrisMaker 2.0 by
-- Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.0 : 03.12.2012  >> Created					  
--*****************************************************

twigsModuleVer = 1.0
try(removeSubRollout debrisMaker.theSubrollout twigsModule)catch()

(
global cylGeo = undefined
global debrisCount
global twigLength
global twigSegs
global twigBranches
global twigBranchesNumberCap
global twigBranchesLength
global twigWarts
global twigWartsNumberCap
global twigTwisting
global twigNoisyness
global twigBrokenEnds
global twigBrokenEndsJaggyness
global twigAttachAllElements
)

rollout twigsModule ("Twigs v" + (twigsModuleVer as string))
(
	groupbox twigOptions "Options"  width:177 pos:[5,5] height:280
	
	spinner spinnerTwigCount "" range:[1,20,5] type:#integer pos:[12,22] width:40
		label labelTwigCount ":Twig Count" offset:[40,-20] align:#left
		spinner spinnerTwigLength "" range:[30,100,50] type:#integer pos:[22,42] width:40
		label labelTwigLength ":Length" offset:[50,-20] align:#left
		spinner spinnerTwigSegments "" range:[5,20,10] type:#integer pos:[22,62] width:40
		label labelTwigSegments ":Segments" offset:[50,-20] align:#left
	
	checkbox checkboxTwigTwisting "Twisting" pos:[12,82] checked:true
	checkbox checkboxTwigWarping "Warping" pos:[12,102] checked:true
	
	checkbox checkboxTwigWarts "Twig Warts" pos:[12,122] checked:true
		spinner spinnerTwigWarts "" range:[1,20,8] type:#integer pos:[22,142] width:40
		label labelTwigWarts ":Max number" offset:[50,-20] align:#left
	
	checkbox checkboxTwigEnds "Broken ends" pos:[12,162] checked:true
		spinner spinnerTwigEnds "" range:[.10,1.00,.50] type:#float pos:[22,182] width:40
		label labelTwigEnds ":End Jaggyness" offset:[50,-20] align:#left
	
	checkbox checkboxTwigBranching "Twig Branching" pos:[12,202] checked:false
		spinner spinnerTwigBranchLength "" range:[1,30,5] type:#integer pos:[22,222] width:40 enabled:false
		label labelTwigBranchLength ":Max length" offset:[50,-20] align:#left enabled:false
		spinner spinnerTwigBranchCount "" range:[1,5,3] type:#integer pos:[22,242] width:40 enabled:false
		label labelTwigBranchCount ":Max Number" offset:[50,-20] align:#left enabled:false
	
	checkbox checkboxAttachElements "Weld all elements" pos:[12,262] checked:true
	
	groupbox groupboxGeneration "Generation" pos:[5,292] height:80 width:177
		button GenerateButton "<<  Generate  >>" width:164 height:30 offset:[-1,-70]
		progressbar theProgressGroup width:165 height:6 offset:[-3,0] value:0
		label progressLabel " status: ready" offset:[-1,-5] style_sunkenedge:true width:165 height:16
		
fn FN_Subdivide arg =
(
	newSubdivide = subdivide size:5
	addmodifier arg newSubdivide
)

fn FN_RelaxSelection arg =
(
	newMeshSel = meshselect subobjectLevel: 1 useSoftSelection: on softselFalloff: 5 softselUseEdgeDistance: on softselEdgeDist: 5
	addmodifier arg newMeshSel
	validmodifier arg newMeshSel
	select arg
	
	subobjectLevel = 1
	modPanel.addModToSelection (Relax iterations: 5) --ui:on
	selection[1].modifiers[#Relax].Relax_Value = 1
)

fn FN_NewVertexWeld arg =
(
newVertexWeld = vertexWeld threshold: 0.1
addmodifier arg newVertexWeld
)

fn FN_CapHoles arg = 
(
newCapHoles = cap_holes()
addmodifier arg newCapHoles
)

fn FN_AttachAll arg =
(
	times = (arg.count - 1)
	baseObj = arg[1]
	
	for i in 1 to times do
		(
		curObj = arg[(i + 1)]
		
		FN_CapHoles curObj
			
 		FN_Subdivide curObj
 		FN_NewVertexWeld curObj
--  		ProBoolean.createBooleanObject baseObj curObj 0 0 0
		
		baseObj =  baseObj + curObj
		delete curObj
		converttopoly baseObj
			
		FN_RelaxSelection baseObj
		clearselection()
			
 		FN_Subdivide baseObj
 		FN_NewVertexWeld baseObj		
		)
		
	arg[1]
)

fn FN_BoolEnd arg pos =
(
	newBox = box length: 4 width: 4 height: 4 lengthsegs: 40 widthsegs: 40
	newBox.pivot = newBox.center
	
	newBox.pos = (pos)
	
	newNoise = noisemodifier seed:(random 1 9999) scale: 1 strength: [0,0,((random 2.0 6.0) * twigBrokenEndsJaggyness)] fractal: on
	addmodifier newBox newNoise
	validmodifier newBox newNoise
	
	FN_Subdivide arg
	FN_NewVertexWeld arg
	
	FN_Subdivide newBox
	
	ProBoolean.createBooleanObject arg newBox 2 0 0
-- 	arg - newBox
-- 	delete newBox
	
	FN_NewVertexWeld arg
	FN_Subdivide arg
	FN_NewVertexWeld arg
)

fn FN_TwistCyl arg mult = -- arg: object to twist
(
	newTwist = twist angle: ((random -400 400 ) * mult) axis: 2
	addmodifier arg newTwist
)

fn FN_NoiseCyl arg mult= -- arg: object to noise
(
	newNoise = noisemodifier seed:(random 1 9999) scale: 1 strength: ([0.5,0.5,0] * mult)fractal: on
	addmodifier arg newNoise
	validmodifier arg newNoise
	newNoise.gizmo.scale = [1,1,50]
)

fn FN_NoiseCylGeneric arg mult= -- arg: object to noise
(
	newNoise = noisemodifier seed:(random 1 9999)  seed: 1 scale:(random 1.0 2.0) fractal: on strength: ([0.25,0.25,0.25] * mult)
	addmodifier arg newNoise
)

fn FN_SmoothCyl arg arg2= -- arg: object to turbosmooth
(
	newTurbo =  turbosmooth iterations:arg2
	addmodifier arg newTurbo
)

fn FN_TaperCyl arg =
(
	newTaper = taper amount:-.5 primaryaxis: 2 effectaxis: 2
	addmodifier arg newTaper
)

fn FN_AddNoise2BaseSpline arg= 
(
	newDebris = arg
	newNoise = noisemodifier strength: [10,0,10] fractal: on scale: (random 50 80) seed:(random 1 9999)
	addmodifier newDebris newNoise
	
	maxOps.CollapseNodeTo newDebris 1 off 
)

fn FN_AddCyl2Spline arg mode scaleMod = -- arg: the Spline | mode: 1(main) 2(branch) 3(nub) | scaleMod: the scale offset
(
	lengthArr = getSegLengths arg 1
	cylLength = lengthArr[lengthArr.count]
	
	case mode of 
		(
		1: ( -- main
			cylRadius = 1
			cylSegs = ( twigSegs * 2 )
			cylScale = [1,1,1]
			newCyl = cylinder Height:cylLength HeightSegs:cylSegs radius:cylRadius sides:8 pos:(arg.pos)
			
			FN_SmoothCyl newCyl 2
			FN_NoiseCyl newCyl 1
			FN_TaperCyl newCyl
			FN_TwistCyl newCyl 1
			FN_NoiseCylGeneric newCyl 1
			
			FN_BoolEnd newCyl [0,0,0] --break base
			
			FN_BoolEnd newCyl [0,0,cylLength] -- break tips
			
			)
		2: ( -- branch
			cylRadius = (random .75 .65)
			cylSegs = ( twigSegs )
			cylScale = [scaleMod,scaleMod,scaleMod]
			newCyl = cylinder Height:cylLength HeightSegs:cylSegs radius:cylRadius sides:8 pos:(arg.pos)
			
			FN_SmoothCyl newCyl 2
			FN_NoiseCyl newCyl .5
			FN_TaperCyl newCyl
			FN_TwistCyl newCyl .5
			FN_NoiseCylGeneric newCyl 1
			
			FN_BoolEnd newCyl [arg.pos.x,arg.pos.y,(cylLength + arg.pos.z)] -- break tips
			
			)
		3: ( -- nub
			cylRadius = .75
			cylSegs = ( twigSegs * 2 )
			newCyl = cylinder Height:cylLength HeightSegs:cylSegs radius:cylRadius sides:8 pos:(arg.pos)
			
			FN_SmoothCyl newCyl 2
			FN_NoiseCyl newCyl 1
			FN_TaperCyl newCyl
			FN_TwistCyl newCyl 1
			
			)
		)
	
	newPathDef = SpacePathDeform path:arg
	addmodifier newCyl newPathDef
	
	maxOps.CollapseNodeTo newCyl 1 off
	newCyl.scale = cylScale
		
	join cylGeo #(newCyl)
)

fn FN_NewDebrisBase = 
(
	twigSpacing = (twigLength / twigSegs )
	twigVectorOffset = ( twigSpacing * .5 )
	
	newDebris = SplineShape pos:[0,0,0] render_renderable:false render_displayRenderMesh:false sides:6
	newDebris.name = UniqueName "CorrugatedSpline"
	addNewSpline newDebris
	
	for i in 1 to ( twigSegs + 1 ) do
		(
		iterMult = ( i - 1 )
		randYoffset = (( random -.25 .25) * twigSpacing)
		addKnot newDebris 1 #bezier #curve [0,((iterMult * twigSpacing) + randYoffset),0] [0,(((iterMult * twigSpacing) - twigVectorOffset ) + randYoffset),0] [0,(((iterMult * twigSpacing) + twigVectorOffset ) + randYoffset),0]
		)
		
	updateshape newDebris
	newDebris	
)

fn FN_NewBranchBase arg =  -- arg: baseSpline
(
	count = ((numknots arg 1 ) - 3 )
	if count > twigBranchesNumberCap then count = twigBranchesNumberCap
	scaleMod = 1
	
	for i in 2 to count do 
	(
		offAmt = .75
		offHalf = ( offAmt * .50)
		
		(random (-1 * offHalf) offHalf)
		
		posStart = getKnotPoint arg 1 (random 2 (count + 2)) -- i
		posEnd = (posStart + [(random (twigBranchesLength * -1) (twigBranchesLength)),(random (twigBranchesLength / 2) (twigBranchesLength)+(twigBranchesLength / 2)),(random (twigBranchesLength * -1) (twigBranchesLength))])
		posMid = ((( posEnd + posStart ) / 2) + [(random (-1 * offAmt) offAmt),(random (-1 * offAmt) offAmt),(random (-1 * offAmt) offAmt)] )
		
		posMid1 = ((( posStart + posMid ) / 2) + [(random (-1 * offHalf) offHalf),(random (-1 * offHalf) offHalf),(random (-1 * offHalf) offHalf)] )
		posMid2 = ((( posMid + posEnd ) / 2) + [(random (-1 * offHalf) offHalf),(random (-1 * offHalf) offHalf),(random (-1 * offHalf) offHalf)] )

		newBranch = SplineShape pos:posStart render_renderable:false render_displayRenderMesh:false sides:6
		newBranch.name = UniqueName "CorrugatedSpline"
		addNewSpline newBranch
		
		addKnot newBranch 1 #smooth #curve posStart posStart posStart --bezier
		addKnot newBranch 1 #smooth #curve posMid1 posMid1 posMid1
		addKnot newBranch 1 #smooth #curve posMid posMid posMid
		addKnot newBranch 1 #smooth #curve posMid2 posMid2 posMid2
		addKnot newBranch 1 #smooth #curve posEnd posEnd posEnd
	
		updateshape newBranch
		
		FN_AddCyl2Spline newBranch 2 scaleMod
		delete newBranch
		
		scaleMod = (scaleMod * .9)
	)
)

fn FN_NewWartGeo = 
(
	newCyl = cylinder  radius: .75 height: 1.25 sides: 8 capsegs: 2 heightsegs:4
	FN_TaperCyl newCyl
	
	FN_NoiseCylGeneric newCyl 1
	
	FN_SmoothCyl newCyl 1
	
	FN_NoiseCylGeneric newCyl 1
	
	FN_Subdivide newCyl

	newCyl
)

fn FN_NewWarts arg =
(
percentAmt = (100 / (twigWartsNumberCap +1))
	
for i in 1 to twigWartsNumberCap do
	(
-- 	newWart = geosphere radius:2 segs: 7
		
	newWart = FN_NewWartGeo()
		
		
	newPC = path_constraint path:arg follow: on
		
	newWart.position.controller = newPC
		
	newPC.PERCENT = (percentAmt * i)
	
	rotate newWart (angleaxis -34 [1,0,0])
	rotate newWart (angleaxis (random 0 360) [0,1,0])
	
	newWartCollapsed = snapshot newWart
	delete newWart

	join cylGeo #(newWartCollapsed)
	)
)

on checkboxTwigWarts changed state do
(
spinnerTwigWarts.enabled = state
labelTwigWarts.enabled = state
)

on checkboxTwigBranching changed state do
(
spinnerTwigBranchLength.enabled = state
spinnerTwigBranchCount.enabled = state
	
labelTwigBranchLength.enabled = state
labelTwigBranchCount.enabled = state
	)

on GenerateButton pressed do
	(
	timerStart = timeStamp()
		
	debrisCount = spinnerTwigCount.value --5

	twigLength = spinnerTwigLength.value --50
	twigSegs = spinnerTwigSegments.value --10

	twigBranches = checkboxTwigBranching.checked --true
	twigBranchesNumberCap =  spinnerTwigBranchCount.value --4 --6
	twigBranchesLength = spinnerTwigBranchLength.value --7 --5
			
	twigWarts = checkboxTwigWarts.checked --true
	twigWartsNumberCap = spinnerTwigWarts.value --8 --10

	twigTwisting = checkboxTwigTwisting.checked --true
	twigNoisyness = checkboxTwigWarping.checked --true

	twigBrokenEnds = checkboxTwigEnds --true
	twigBrokenEndsJaggyness = spinnerTwigEnds.value --.5

	twigAttachAllElements = checkboxAttachElements.checked -- true
	
	max modify mode 
	badcount = 0

	for i in 1 to debrisCount do 
		(
-- 		try(
			theProgressGroup.value  = (((i + 0.00) / debrisCount) * 100)
			progressLabel.text = (" status: Building " + (i as string) + " of " + (debrisCount as string))
			
			cylGeo = #()
			twigLength = ((random -5 5) + twigLength)
			twigSegs = ((random -3 3) + twigSegs)
				
			newDebris = FN_NewDebrisBase()
			FN_AddNoise2BaseSpline newDebris
				
			FN_AddCyl2Spline newDebris 1 1 -- twigLength twigSegs  --newDebris
			
			if twigBranches then FN_NewBranchBase newDebris 
			if twigWarts then FN_NewWarts newDebris
				
			newDebrisSpline = newDebris
			
			progressLabel.text = (" status: Welding " + (i as string) + " of " + (debrisCount as string))
			if twigAttachAllElements then (newDebris = FN_AttachAll cylGeo) else (newDebris = group cylGeo name:"Twig")
			
			delete newDebrisSpline
			
			converttopoly newDebris
			newDebris.pivot = newDebris.center
			resetscale newDebris
			
			progressLabel.text = (" status: Placing " + (i as string) + " of " + (debrisCount as string))
			newDebris.pos = [((i-1)*25),0,0]
			newDebris.wirecolor = [20,20,20]
			
			select newDebris
			max zoomext sel
			redrawviews()
			clearselection()
-- 			)catch()
			progressLabel.text = (" status: Error, retrying " + (i as string) + " of " + (debrisCount as string))
			badcount += 1
			)
	
	timerEnd = timeStamp()
	progressLabel.text =  (" Generation took: " + (((timerEnd - timerStart) / 1000.0) as string) + " s")
	)	
	
)
AddSubRollout DebrisMaker.theSubrollout twigsModule
debrisMaker.height = 424