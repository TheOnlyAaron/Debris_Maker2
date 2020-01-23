--*****************************************************
-- Tool part of the DebrisMaker 2.0 by
-- Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.0 : 06.26.2013  >> Created					  
--*****************************************************

slateModuleVer = 1.0
try(removeSubRollout debrisMaker.theSubrollout slateModule)catch()

rollout slateModule ("Slate v" + (slateModuleVer as string))
(
	groupbox slateGroup "Options"  width:177 pos:[5,5] height:165
		spinner spinnerCount "" range:[1,10,5] type:#integer pos:[12,25] width:40 tooltip:"Amount of slate to create"
		label labelCount ": Slate Count" offset:[40,-20] align:#left tooltip:"Amount of slate to create"
		label labelFacetsRange "Range of Facets: " pos:[13,45] align:#left 
			spinner spinnerFacetsStart "" range:[3,15,4] width:35 type:#integer pos:[96,45] tooltip:"Lowest number of edges possible on a rock"
			spinner spinnerFacetsEnd "to" range:[3,15,9] width:35 type:#integer pos:[142,45] tooltip:"Highest number of edges possible on a rock"
		spinner spinnerThickness "" range:[1,40,10] type:#integer pos:[12,65] width:40 tooltip:"Thickness of each rock"  ---------------- newShellThickness
		label labelThickness ": Thickness" offset:[40,-20] align:#left tooltip:"Thickness of each rock"
		spinner spinnerThicknessVariation "" range:[0,20,10] type:#integer pos:[12,85] width:40 tooltip:"Variation of thicknesses"
		label labelThicknessVariation ": Thickness Variation" offset:[40,-20] align:#left tooltip:"Variation of thicknesses"

		spinner spinnerPlatesCount "" range:[1,15,5] type:#integer pos:[12,105] width:40 tooltip:"Number of plates to have in each slate stack"
		label labelPlatesCount ": Number of plates" offset:[40,-20] align:#left tooltip:"Number of plates to have in each slate stack"
		spinner spinnerPlatesCountVariation "" range:[0,14,0] type:#integer pos:[12,125] width:40 tooltip:"Number of plates to have in each slate stack"
		label labelPlatesCountVariation ": Variation in plate count" offset:[40,-20] align:#left tooltip:"Number of plates to have in each slate stack"	
	
		checkbox checkboxOptimize "Optimize result" pos:[12,145] tooltip:"Optimize and collapse geometry"
		spinner spinnerOptimize "" range:[10,90,30] type:#integer pos:[105,145] width:40 enabled:False tooltip:"Percent of verticies to remain after optimization"
		label labelPercent "%" offset:[135,-20] align:#left tooltip:"Percent of verticies to remain after optimization"
	
	groupbox groupboxGeneration "Generation" pos:[5,175] height:80 width:177
		button GenerateButton "<<  Generate  >>" width:164 height:30 offset:[-1,-70] tooltip:"Generate Debris"
		progressbar theProgressGroup width:165 height:6 offset:[-3,0] value:0
		label progressLabel " status: ready" offset:[-1,-5] style_sunkenedge:true width:165 height:16
	
-- Functions
	function functionGenerate = 
	(
	timerStart = timeStamp()
		
	shaleStacks = spinnerPlatesCount.value
	facetsRange = #(spinnerFacetsStart.value, spinnerFacetsEnd.value)
	curIter = 3--3
	instanceTurbosmooth = (Turbosmooth iterations:curIter sepBySmGroups:on)
	newVol = 1

		
	try(
		disablesceneredraw()

		for i in 1 to spinnerCount.value do
			(
			theProgressGroup.value  = (((i + 0.00) / spinnerCount.value) * 100)
			progressLabel.text = (" status: Building " + (i as string) + " of " + (spinnerCount.value as string))
			
			shellThicknessRange = ((spinnerThicknessVariation.value * .03) *.5)
				
			newShellThickness = ((random (.65 - shellThicknessRange) (.65 + shellThicknessRange))*.2*(spinnerThickness.value*.1))
			newRock = cylinder sides:(random facetsRange[1] facetsRange[2]) capsegs:2 radius:(random 3.0 8.0)
			newVol = Vol__Select level:2 type:1
			newDeleteMesh = DeleteMesh()
			newNoise1 = Noisemodifier strength:[(random 4 6),(random 4 6),0] seed:(random 0 9999) fractal:on scale:2
			newRelax = Relax Relax_Value:1 iterations:10 Keep_Boundary_Pts_Fixed:1
			newTessellate = tessellate faceType: 1 iterations:1
			newNoise2 = Noisemodifier strength:[(random .75 1.25),(random .75 1.25),0] seed:(random 0 9999) fractal:on scale:0.8
			newRelax2 = Relax Relax_Value:.25 iterations:1 Keep_Boundary_Pts_Fixed:0
			newShell = shell innerAmount:newShellThickness outerAmount:0 Segments:3

			addmodifier newRock newVol
			validmodifier newRock newVol
			newVol.gizmo.position = [0,0,1]
			addmodifier newRock newDeleteMesh
			addmodifier newRock (Mesh_Select())
			addmodifier newRock newnoise1
			addmodifier newRock newRelax
			addmodifier newRock newTessellate
			addmodifier newRock newRelax
			addmodifier newRock newnoise2
			addmodifier newRock newRelax
			addmodifier newRock newRelax2
			addmodifier newRock newShell
			converttopoly newRock
			addmodifier newRock instanceTurbosmooth

			commonNoise = (Noisemodifier strength:[(random .75 1.25),(random .75 1.25),0] iterations:6 seed:(random 0 9999) fractal:on scale:(random 3.00 3.50))
			stackArray = #()
			
			curToggle = (if (random 0 1) == 0 then (-1) else (1))
			curRandOffset = ((random 0 (spinnerPlatesCountVariation.value))*curtoggle)
			curShaleStacks = (shaleStacks + curRandOffset)
				
			for i in 1 to (curShaleStacks) do
				(
				newStack = copy newRock
				newStack.pos = [0,0,(newShellThickness * i)]
				
				uniqueNoise = copy commonNoise
					
				addmodifier newStack uniqueNoise
				validmodifier newStack uniqueNoise
				uniqueNoise.gizmo.scale = [1,1,.05]
				uniqueNoise.seed = (random 0 9999)
				
				converttopoly newStack
				newStack.name = (i as string)
				join stackArray #(newStack)
				)

			newRockAttached = stackArray[1]
				
			for i in 1 to (stackArray.count) do
				(
				try(polyop.attach newRockAttached stackArray[stackArray.count - i +1 ])catch()--+ 1
				)
				
			addmodifier (newRockAttached) (Noisemodifier strength:[0,0,(random 0.05 0.15)] iterations:6 seed:(random 0 9999) fractal:on scale:(random 5.00 5.50))	
			
			if checkboxOptimize.checked == true then
				(
				progressLabel.text = (" status: Optimizing " + (i as string) + " of " + (spinnerCount.value as string))
				newOptimize = ProOptimizer LockMat:off VertexPercent:(spinnerOptimize.value)
				addmodifier newRockAttached newOptimize
				validModifier newRockAttached newOptimize
				newOptimize.Calculate = True
					
-- 				newWelder = welder threshold: 0.1 weldMethod:1 dontWeldSelectedEdges: on
-- 				addmodifier newRockAttached newWelder
					
				converttopoly newRockAttached
				)

			progressLabel.text = (" status: Placing " + (i as string) + " of " + (spinnerCount.value as string))

			move newRockAttached [(i*15),0,0]
			delete newRock

			newRockAttached.wirecolor = [20,20,20]
				
			iString = substring ((i + 1000) as string) 2 5
			newRockAttached.name = ("Slate_" + iString) 
			)
			
		enablesceneredraw()
		redrawviews()
		)
	catch
		(
		enablesceneredraw()
		redrawviews()
		)
	timerEnd = timeStamp()
	progressLabel.text =  (" Generation took: " + (((timerEnd - timerStart) / 1000.0) as string) + " s")
	)
	
-- Event Handlers
	on spinnerPlatesCount changed state do (if spinnerPlatesCount.value <= spinnerPlatesCountVariation.value then (spinnerPlatesCountVariation.value = ((spinnerPlatesCount.value) - 1 ))else())
	on spinnerPlatesCountVariation changed state do (if spinnerPlatesCountVariation.value >= spinnerPlatesCount.value then (spinnerPlatesCount.value = ((spinnerPlatesCountVariation.value) + 1 ))else())
	on spinnerFacetsStart changed state do (if spinnerFacetsStart.value > spinnerFacetsEnd.value then (spinnerFacetsEnd.value = spinnerFacetsStart.value))
	on spinnerFacetsEnd changed state do (if spinnerFacetsEnd.value < spinnerFacetsStart.value then (spinnerFacetsStart.value = spinnerFacetsEnd.value))
	on checkboxOptimize changed state do ( if checkboxOptimize.checked == true then (spinnerOptimize.enabled = true) else(spinnerOptimize.enabled = False))
	on generateButton pressed do (functionGenerate())
)
AddSubRollout DebrisMaker.theSubrollout slateModule
debrisMaker.height = 307