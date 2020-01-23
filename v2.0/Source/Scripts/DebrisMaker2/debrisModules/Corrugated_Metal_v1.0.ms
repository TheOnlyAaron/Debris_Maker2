--*****************************************************
-- Tool part of the DebrisMaker 2.0 by
-- Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.0 : 03.12.2012  >> Created					  
--*****************************************************

corrugatedMetalModuleVer = 1.0
try(removeSubRollout debrisMaker.theSubrollout corrugatedMetalModule)catch()


-- 	debrisCount = spinnerDebrisCount.value	
(		
global corrugatedDetail

global corrugatedSlicedShapes 
global corrugatedIrregularShapes
global corrugatedRustHoles
global corrugatedRustClusters 
global corrugatedRustCount 

global corrugatedWrapDeform 
global corrugatedWrapDeformCreases 
global corrugatedWrapDeformIntensity 
)







rollout corrugatedMetalModule ("Corrugated Metal v" + (corrugatedMetalModuleVer as string))
(
	groupbox groupboxOptions "Options"  width:177 pos:[5,5] height:65
		spinner spinnerDebrisCount "" range:[1,20,10] type:#integer pos:[12,25] width:40
		label labelDebrisCount ":Metal panels count " offset:[40,-20] align:#left
		spinner spinnerDetailLevel "" range:[1,3,2] type:#integer pos:[12,45] width:40
		label labelDetailLevel ":Detal Level" offset:[40,-20] align:#left
	
	groupbox groupboxShape "Shape"  width:177 pos:[5,70] height:120
		checkbox checkboxShapeSlice "Slice panels" align:#left offset:[0,((groupboxShape.height * -1) +10)] checked:true
		checkbox checkboxShapeIrregular "Irregular Shapes" checked:true
		checkbox checkboxShapeRust "Rust Holes" checked:true
			spinner spinnerShapeRustHoles "" range:[1,20,10] type:#integer offset:[20,0] width:40 align:#left
			label labelShapeRustHoles ":Holes per-cluster" offset:[65,-20] align:#left
			spinner spinnerShapeRustClusters "" range:[1,10,5] type:#integer offset:[20,0] width:40 align:#left
			label labelShapeRustClusters ":Clusters per-panel" offset:[65,-20] align:#left
		
	groupbox groupboxDeform "Wrap Deform"  width:177 pos:[5,190] height:80
		checkbox checkboxDeformWrap "Wrap Deform" align:#left offset:[0,((groupboxDeform.height * -1) +10)] checked:true
		spinner spinnerDeformCreases "" range:[1,12,6] type:#integer width:40 align:#left offset:[20,0]
		label labelDeformCreases ":Creases Count " offset:[65,-20] align:#left
		spinner spinnerDeformAmount "" range:[.1,1.0,.3] type:#float width:40 align:#left offset:[20,0]
		label labelDeformAmount ":Crease Amount " offset:[65,-20] align:#left
		
	groupbox groupboxGeneration "Generation" pos:[5,275] height:80 width:177
		button GenerateButton "<<  Generate  >>" width:164 height:30 offset:[-1,-70]
		progressbar theProgressGroup width:165 height:6 offset:[-3,0] value:0
		label progressLabel " status: ready" offset:[-1,-5] style_sunkenedge:true width:165 height:16

-- Build a Corrugated spline (for use in the panel)
	Fn FN_CorrugatedSpline=
		(
			SS = SplineShape pos:[0,0,0] --rot:[90,0,0]
			SS.name = UniqueName "CorrugatedSpline"
			addNewSpline ss
				addKnot ss 1 #bezier #curve [20.0879,-0.560261,0] [20.603,-0.560261,0] [19.5729,-0.560261,0]
				addKnot ss 1 #bezier #curve [18.5427,0.560266,0] [19.0578,0.560266,0] [18.0276,0.560266,0]
				addKnot ss 1 #bezier #curve [16.9975,-0.560261,0] [17.5126,-0.560261,0] [16.4824,-0.560261,0]
				addKnot ss 1 #bezier #curve [15.4523,0.560266,0] [15.9673,0.560266,0] [14.9372,0.560266,0]
				addKnot ss 1 #bezier #curve [13.907,-0.560262,0] [14.4221,-0.560261,0] [13.392,-0.560263,0]
				addKnot ss 1 #bezier #curve [12.3618,0.560265,0] [12.8769,0.560266,0] [11.8467,0.560264,0]
				addKnot ss 1 #bezier #curve [10.8166,-0.560262,0] [11.3317,-0.560262,0] [10.3015,-0.560262,0]
				addKnot ss 1 #bezier #curve [9.27136,0.560265,0] [9.78644,0.560265,0] [8.75628,0.560265,0]
				addKnot ss 1 #bezier #curve [7.72613,-0.560262,0] [8.24121,-0.560262,0] [7.21106,-0.560263,0]
				addKnot ss 1 #bezier #curve [6.18091,0.560265,0] [6.69598,0.560265,0] [5.66583,0.560265,0]
				addKnot ss 1 #bezier #curve [4.63568,-0.560263,0] [5.15076,-0.560263,0] [4.1206,-0.560263,0]
				addKnot ss 1 #bezier #curve [3.09045,0.560264,0] [3.60553,0.560264,0] [2.57538,0.560264,0]
				addKnot ss 1 #bezier #curve [1.54523,-0.560263,0] [2.0603,-0.560263,0] [1.03015,-0.560263,0]
				addKnot ss 1 #bezier #curve [0,0.560264,0] [0.515076,0.560264,0] [-0.515076,0.560264,0]
				addKnot ss 1 #bezier #curve [-1.54523,-0.560264,0] [-1.03015,-0.560264,0] [-2.0603,-0.560264,0]
				addKnot ss 1 #bezier #curve [-3.09045,0.560263,0] [-2.57538,0.560263,0] [-3.60553,0.560263,0]
				addKnot ss 1 #bezier #curve [-4.63568,-0.560264,0] [-4.1206,-0.560264,0] [-5.15076,-0.560264,0]
				addKnot ss 1 #bezier #curve [-6.18091,0.560263,0] [-5.66583,0.560263,0] [-6.69598,0.560263,0]
				addKnot ss 1 #bezier #curve [-7.72613,-0.560265,0] [-7.21106,-0.560265,0] [-8.24121,-0.560265,0]
				addKnot ss 1 #bezier #curve [-9.27136,0.560262,0] [-8.75628,0.560262,0] [-9.78644,0.560262,0]
				addKnot ss 1 #bezier #curve [-10.8166,-0.560265,0] [-10.3015,-0.560265,0] [-11.3317,-0.560265,0]
				addKnot ss 1 #bezier #curve [-12.3618,0.560262,0] [-11.8467,0.560262,0] [-12.8769,0.560262,0]
				addKnot ss 1 #bezier #curve [-13.907,-0.560266,0] [-13.392,-0.560266,0] [-14.4221,-0.560266,0]
				addKnot ss 1 #bezier #curve [-15.4523,0.560261,0] [-14.9372,0.560261,0] [-15.9673,0.560261,0]
				addKnot ss 1 #bezier #curve [-16.9975,-0.560266,0] [-16.4824,-0.560266,0] [-17.5126,-0.560266,0]
				addKnot ss 1 #bezier #curve [-18.5427,0.560261,0] [-18.0276,0.560261,0] [-19.0578,0.560261,0]
				addKnot ss 1 #bezier #curve [-20.0879,-0.560267,0] [-19.5729,-0.560267,0] [-20.603,-0.560267,0]
			updateshape ss
			ss --end with ss so that you can assign a variable to the Fn
		)

	-- Build a Corrugated panel
	FN FN_CorrugatedBase  =
		(
			CorrugatedBase = FN_CorrugatedSpline()
			rotate CorrugatedBase (angleaxis 90 [1,0,0])
			
			case corrugatedDetail of
			(
			1: CorrugatedBase.steps = 0
			2: CorrugatedBase.steps = 2
			3: CorrugatedBase.steps = 3
			)
			
			newExtrude = Extrude amount:-80 segs:(30*corrugatedDetail)
			newUVW = uvwMap maptype:0 axis:1 length:81 width:41 height: 1	
			addmodifier CorrugatedBase newExtrude
			addmodifier CorrugatedBase newUVW
			CorrugatedBase
		)
		
	FN FN_ShapeIrregular arg=
		(
 		converttopoly arg
			
		newVolSel = vol__select level:1 method:0 -- Should be 2, but it is shit
		addmodifier arg newVolSel
		validmodifier arg vol__select
			
		arg.modifiers[#Vol__Select].gizmo.scale = [(random .5 1),2,(random .5 1)]
		arg.modifiers[#Vol__Select].gizmo.pos = [(random -35 35),0,(random 75 -75)] 
			
		newDeleteMesh = deletemesh()
		addmodifier arg newDeleteMesh
			
		converttopoly arg
		)

	FN FN_ShapeSlice arg=  
		(
		newSlice = slicemodifier Slice_Type:3
		addmodifier arg newSlice
		arg.modifiers[#Slice].slice_plane.rotation = ((eulerAngles 00 (random 270 90) 0) as quat)
		arg.modifiers[#Slice].slice_plane.position = [(random -35 35),0,(random -15 15)]
			
	-- 	converttopoly arg
		)	

	FN FN_RustHoles arg = 
		(
		-- Number of clusters
		for J in 1 to corrugatedRustClusters do
			(
			newCluster = box length:1 width:1 height:1 pos:[0,0,10]
			converttopoly newCluster
			for k in 1 to corrugatedRustCount do
				(
				newCyl = cylinder sides: 8 heightsegs: 1 height: 10 radius:(random .05 0.50) pos:[(random -3.0 3.0),(random -3.0 3.0),-5]
				converttopoly newCyl
				polyop.attach newCluster newCyl
				)
			newCluster.scale = ((random .75 1.5) * [1,1,1])
			newCluster.pos = [(random -20 20),(random 0 80),10 ]
				
			arg - newCluster
			delete newCluster
			)
		newSmooth = smooth autosmooth: on preventIndirect: on threshold: 60
		addmodifier arg newsmooth
		arg
		)
		
	FN FN_WrapDeform arg =
		(
		newWrapDeformer = plane pos:[0,40,0] width:45 length:85
		
		for j in 1 to corrugatedWrapDeformCreases do
			(
			newSlice = slicemodifier Slice_Type:0
			addmodifier newWrapDeformer newSlice
			newWrapDeformer.modifiers[#Slice].slice_plane.rotation = ((eulerAngles 90 (random 0 360) 0) as quat)
			newWrapDeformer.modifiers[#Slice].slice_plane.position = [(random -15 15),(random -35 35),0]
			)
			
		newNoise = noisemodifier strength: [0,0,0] fractal: on scale: 50 seed:(random 0 9999)
		newTesselate = tessellate tension:0 iterations:0
		addmodifier newWrapDeformer newNoise
		addmodifier newWrapDeformer newTesselate
		
		newSkinWrap = Skin_Wrap engine:0 weightAllVerts:on meshList:#(newWrapDeformer)
		addmodifier arg newSkinWrap
		validmodifier arg Skin_Wrap
		
		newWrapDeformer.modifiers[#Noise].strength = [(20*corrugatedWrapDeformIntensity),(40*corrugatedWrapDeformIntensity),(40*corrugatedWrapDeformIntensity)] 
		converttopoly arg
	 	delete newWrapDeformer
		)

	on checkboxShapeRust changed state do
	(
	spinnerShapeRustHoles.enabled = state
	labelShapeRustHoles.enabled = state
	spinnerShapeRustClusters.enabled = state
	labelShapeRustClusters.enabled = state
	)
		
	on checkboxDeformWrap changed state do
	(
	spinnerDeformCreases.enabled = state
	labelDeformCreases.enabled = state
	spinnerDeformAmount.enabled = state
	labelDeformAmount.enabled = state
	)
		
	on GenerateButton pressed do
	(
	timerStart = timeStamp()
		
	debrisCount = spinnerDebrisCount.value	
		
	corrugatedDetail = spinnerDetailLevel.value						-- 1-3

	corrugatedSlicedShapes = checkboxShapeSlice.checked				-- slice corners on some objects
	corrugatedIrregularShapes = checkboxShapeIrregular.checked		-- volselect to delete grids out of panels
	corrugatedRustHoles = checkboxShapeRust.checked					-- make rusty holes
		corrugatedRustClusters = spinnerShapeRustClusters.value		-- Clusters of rust
		corrugatedRustCount = spinnerShapeRustHoles.value			-- Count per cluster

	corrugatedWrapDeform = checkboxDeformWrap.checked				-- deform using a skinwrap on beveled plane
		corrugatedWrapDeformCreases = spinnerDeformCreases.value	-- number of creases to add to the wrap deformer
		corrugatedWrapDeformIntensity = spinnerDeformAmount.value	-- 0 to 1 - Multiplier on noise
		
		for i in 1 to debrisCount do
		(
			theProgressGroup.value  = (((i + 0.00) / debrisCount) * 100)
			progressLabel.text = (" status: Building " + (i as string) + " of " + (debrisCount as string))
			
			newDebris = FN_CorrugatedBase()

			if corrugatedIrregularShapes == true then (FN_ShapeIrregular newDebris)else()	
			if corrugatedSlicedShapes == true then (FN_ShapeSlice newDebris)else()
			if corrugatedRustHoles == true then (newDebris = FN_RustHoles newDebris)else()
				
			progressLabel.text = (" status: Deforming " + (i as string) + " of " + (debrisCount as string))
			if corrugatedWrapDeform == true then (FN_WrapDeform newDebris)else()
			
			progressLabel.text = (" status: Placing " + (i as string) + " of " + (debrisCount as string))
			--End Stuff
			scale newDebris [.25,.25,.25]
			newDebris.name = ("Roofing_"+(i as string))
			newDebris.wirecolor = [20,20,20]
			move newdebris [(i*20),0,0]
				
-- 			select newDebris
		)
		
	timerEnd = timeStamp()
	progressLabel.text =  (" Generation took: " + (((timerEnd - timerStart) / 1000.0) as string) + " s")
	)
)
AddSubRollout DebrisMaker.theSubrollout corrugatedMetalModule
debrisMaker.height = 410