--*****************************************************
-- Tool part of the DebrisMaker 2.0 by
-- Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.0 : 03.12.2012  >> Created					  
--*****************************************************


-- TODO:
	-- Ribbons with gromets and junk attached
-- 	typeStrips = false  -- SAVE FOR LATER!!

	-- Distorted and twisted cylindrical sections
-- 	typeWrappers = false -- SAVE FOR LATER!!

	-- cylindrical shapes, like bullet casings
-- 	typePellets = false -- SAVE FOR LATER!!

	-- like glass shatters, flat ngons
-- 	typeShards = false -- SAVE FOR LATER!!

shrapnelModuleVer = 1.0
try(removeSubRollout debrisMaker.theSubrollout shrapnelModule)catch()

(
global typePanels
global typePanelsResolution
global typePanelsShapeNoiseSize
global typePanelsCutHoles
)


rollout shrapnelModule ("Shrapnel v" + (shrapnelModuleVer as string))
(
	groupbox geometryOptions "Options"  width:177 pos:[5,5] height:40
		spinner spinnerDebrisCount "" range:[1,50,10] type:#integer  align:#left width:40 offset:[-2,((geometryOptions.height * -1 ) + 10)]
			label labelDebrisCount ":Debris Count" offset:[40,-20] align:#left
		
	groupbox panelOptions "Panel Options"  width:177 offset:[-8,8] height:75
		spinner spinnerPanelResolution "" range:[1,50,20] type:#integer  align:#left width:40 offset:[-2,((panelOptions.height * -1 ) + 10)]
			label labelPanelResolution ":Panel Resolution" offset:[40,-20] align:#left
		spinner spinnerPanelNoiseScale "" range:[1.0,10.0,2.5] type:#float width:40 offset:[-2,0] align:#left
			label labelPanelNoiseScale ":Noise Scale" offset:[40,-20] align:#left
		checkbox checkboxPanelCutHoles "Cut Holes" align:#left offsest:[0,0] checked:true
	
	groupbox groupboxGeneration "Generation" height:80 width:177 offset:[-8,8]
		button GenerateButton "<<  Generate  >>" width:164 height:30 offset:[-1,-70]
		progressbar theProgressGroup width:165 height:6 offset:[-3,0] value:0
			label progressLabel " status: ready" offset:[-1,-5] style_sunkenedge:true width:165 height:16
		
	--------------- FUNCTIONS -----------------
	FN FN_TypePanels =
	(
		-- Create Base Obj
		newDebris = plane length:typePanelsResolution width:typePanelsResolution lengthsegs:typePanelsResolution widthsegs:typePanelsResolution
			
		-- Cut holes along one edge
		if typePanelsCutHoles == true then
			(
			newCyl = cylinder sides: 8 heightsegs: 1 height: 10 radius:( random 0.10 0.25) pos:[(-typePanelsResolution*.47),(-typePanelsResolution*.5),-5]
			holesCutter = box pos:[0,0,-10] length:1 width:1 height:1
			newDivisor = (random 5.00 25.00)
			
			for j in 1 to newDivisor do 
				(
				curCyl = copy newCyl
				move curCyl [0,((typePanelsResolution/newDivisor)*j),0]
				holesCutter = (holesCutter + curCyl)
				delete curCyl
				)
			
			-- Make a second row of holes to cut half way across the object
			holesCutterCopy = copy holesCutter
			move holesCutterCopy [10,0,0]
			holesCutter = (holesCutter + holesCutterCopy)
			delete holesCutterCopy
			
			newDebris = boolObj.createBooleanObject holesCutter newDebris 4 1
			boolObj.setBoolOp newDebris 4
				
			delete newCyl
			)
			
		-- creates new shape cutter
		(
		newCutter = geosphere radius:(random 3.0 8.0) segs:10
		cutterNoise = noisemodifier scale:((random .30 2.3 )+typePanelsShapeNoiseSize) fractal: on strength: [2,2,2] seed:(random 0 9999)
		cutterRelax = relax Relax_Value:.5
		cutterStretch = stretch stretch:(random 0.00 .41) amplify:(random 0.00 1.01) axis:1
		
		addmodifier newCutter cutterNoise
		addmodifier newCutter cutterRelax
		addmodifier newCutter cutterStretch
		
		newCutter.pos = [(random (-typePanelsResolution *.5) (typePanelsResolution*.5)),(random (-typePanelsResolution *.5) (typePanelsResolution*.5)),0]
		rotate newCutter (angleaxis (random 0 360) [0,0,1])
		)

		-- cuts out the shape
		(
		newDebris = boolObj.createBooleanObject newCutter newDebris 4 1
		boolObj.setBoolOp newDebris 2	
		)
			
		-- cleans up the resulting geometry
		(
		newVertexWeld = vertexWeld threshold: 0.08
		newSubdivide = subdivide size:10 manualupdate:1
			
		addmodifier newDebris newVertexWeld
		addmodifier newDebris newSubdivide
		
		validmodifier newDebris subdivide
	 
		newDebris.pivot = newDebris.center
		newDebris.pos = [0,0,0]
			
		converttopoly newDebris
		)
		
		-- Bend the shit out of that thing
		(
		newBend = bend BendAngle:(random 30 200) BendDir:90 BendAxis:1
		addmodifier newDebris newBend
		validmodifier newDebris bend
		newDebris.modifiers[#Bend].gizmo.rotation =  ((eulerAngles  (random 0 360) (random 0 360) (random 0 360)) as quat)
			
		newNoise = noisemodifier strength:[2,2,2] fractal:on scale:(random 10 15) seed:(random 0 9999)
		addmodifier newDebris newNoise
		addmodifier newDebris newVertexWeld
		
		newShell = shell innerAmount:.1  outerAmount:0
		addmodifier newDebris newShell
		)
		
		newDebris
	)
	
	on GenerateButton pressed do
	(
	debrisCount = spinnerDebrisCount.value	
	timerStart = timeStamp()

	--------------- ARGS -----------------
	debrisOperationArray = #(1,0,0,0,0)

	-- Irregular shapes with holes and slight curviture
	typePanels = true
		typePanelsResolution = spinnerPanelResolution.value --20
		typePanelsShapeNoiseSize = spinnerPanelNoiseScale.value -- 1 - 5
		typePanelsCutHoles = checkboxPanelCutHoles.checked

	-- Ribbons with gromets and junk attached
-- 	typeStrips = false  -- SAVE FOR LATER!!

	-- Distorted and twisted cylindrical sections
-- 	typeWrappers = false -- SAVE FOR LATER!!

	-- cylindrical shapes, like bullet casings
-- 	typePellets = false -- SAVE FOR LATER!!

	-- like glass shatters, flat ngons
-- 	typeShards = false -- SAVE FOR LATER!!

		for i in 1 to debrisCount do
		(
			theProgressGroup.value  = (((i + 0.00) / debrisCount) * 100)
			progressLabel.text = (" status: Building " + (i as string) + " of " + (debrisCount as string))
			
			newDebris = FN_TypePanels()
			newDebris.name = ("Shrapnel_"+(i as string))
			newdebris.wirecolor = [20,20,20]
			move newdebris [(i*20),0,0]
		)
		
	timerEnd = timeStamp()
	progressLabel.text =  (" Generation took: " + (((timerEnd - timerStart) / 1000.0) as string) + " s")
	)
)
AddSubRollout DebrisMaker.theSubrollout shrapnelModule
debrisMaker.height = 262