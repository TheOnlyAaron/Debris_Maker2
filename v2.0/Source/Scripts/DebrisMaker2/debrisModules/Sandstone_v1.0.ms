--*****************************************************
-- Tool part of the DebrisMaker 2.0 by
-- Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.0 : 06.26.2013  >> Created					  
--*****************************************************

sandstoneModuleVer = 1.0
try(removeSubRollout debrisMaker.theSubrollout sandstoneModule)catch()

rollout sandstoneModule ("Sandstone v" + (sandstoneModuleVer as string))
(
	groupbox sandstoneGroup "Options"  width:177 pos:[5,5] height:145
		spinner spinnerCount "" range:[1,10,5] type:#integer pos:[12,25] width:40 tooltip:"Amount of sandstone to create"
		label labelCount ": Sandstones Count" offset:[40,-20] align:#left tooltip:"Amount of sandstone to create"
		label labelFacetsRange "Range of Facets: " pos:[13,45] align:#left 
			spinner spinnerFacetsStart "" range:[3,15,4] width:35 type:#integer pos:[96,45] tooltip:"Lowest number of edges possible on a rock"
			spinner spinnerFacetsEnd "to" range:[3,15,9] width:35 type:#integer pos:[142,45] tooltip:"Highest number of edges possible on a rock"
		spinner spinnerThickness "" range:[1,20,10] type:#integer pos:[12,65] width:40 tooltip:"Thickness of each rock"
 		label labelThickness ": Thickness" offset:[40,-20] align:#left tooltip:"Thickness of each rock"
		spinner spinnerThicknessVariation "" range:[0,20,10] type:#integer pos:[12,85] width:40 tooltip:"Variation of thicknesses"
		label labelThicknessVariation ": Thickness Variation" offset:[40,-20] align:#left tooltip:"Variation of thicknesses"
		checkbox checkboxDetailedEdges "Edge Detail" checked:true pos:[12,105] tooltip:"Add strata detail to edge of rock"
		checkbox checkboxOptimize "Optimize result" pos:[12,125] tooltip:"Optimize and collapse geometry"
		spinner spinnerOptimize "" range:[10,90,30] type:#integer pos:[105,125] width:40 enabled:False tooltip:"Percent of verticies to remain after optimization"
		label labelPercent "%" offset:[135,-20] align:#left tooltip:"Percent of verticies to remain after optimization"
	
	groupbox groupboxGeneration "Generation" pos:[5,155] height:80 width:177
		button GenerateButton "<<  Generate  >>" width:164 height:30 offset:[-1,-70] tooltip:"Generate Debris"
		progressbar theProgressGroup width:165 height:6 offset:[-3,0] value:0
		label progressLabel " status: ready" offset:[-1,-5] style_sunkenedge:true width:165 height:16
	
-- Functions
	function functionGenerate = 
	(
		
	timerStart = timeStamp()
		
	try(
		disablesceneredraw()

		for i in 1 to spinnerCount.value do
			(
			theProgressGroup.value  = (((i + 0.00) / spinnerCount.value) * 100)
			progressLabel.text = (" status: Building " + (i as string) + " of " + (spinnerCount.value as string))
				
			facetsRange = #(spinnerFacetsStart.value, spinnerFacetsEnd.value)
			newShellThickness = ((random ((spinnerThicknessVariation.value *.05)+2) ((spinnerThicknessVariation.value *.15) + 2))*(spinnerThickness.value * .1))
			highPolyResult = checkboxDetailedEdges.checked
			curIter = 2

			newRock = cylinder sides:(random facetsRange[1] facetsRange[2]) capsegs:2 radius:(random 5.0 10.0)
			newVol__Select = Vol__Select level:2 type:1
			newDeleteMesh = DeleteMesh()
			newNoise1 = Noisemodifier strength:[(random 4 6),(random 4 6),0] seed:(random 0 9999) fractal:on scale:2
			newRelax = Relax Relax_Value:1 iterations:10 Keep_Boundary_Pts_Fixed:1
			newTessellate = tessellate faceType: 1 iterations:1
			newNoise2 = Noisemodifier strength:[(random .75 1.25),(random .75 1.25),0] seed:(random 0 9999) fractal:on scale:0.8
			newRelax2 = Relax Relax_Value:.25 iterations:1 Keep_Boundary_Pts_Fixed:0
			newShell = shell innerAmount:newShellThickness outerAmount:0 Segments:3

			addmodifier newRock newVol__Select
			validmodifier newRock newVol__Select
			newVol__Select.gizmo.position = [0,0,1]
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

			if highPolyResult == true then(curIter = 3)else(curIter =2)
			newTurbosmooth = (Turbosmooth iterations:curIter sepBySmGroups:on)
			addmodifier newRock newTurbosmooth
			addmodifier newRock (Turbosmooth iterations:1 sepBySmGroups:off)
				
			newNoiseMap = (noise type:1 size:(random 4.50 5.50) thresholdHigh:.7 thresholdLow:.3)
			newNoiseMap.coords.Tiling = [0,90,0]
			newNoiseMap.coords.coordType  = 2
			
			if checkboxDetailedEdges.checked == true then
				(
				newDisplace = (displace strength:.1 maptype:1 applyMap:on)
				addmodifier newRock newDisplace
				newDisplace.map = newNoiseMap
				)else()
				
			addmodifier newRock (Noisemodifier strength:[(random .75 1.25),(random .75 1.25),0] iterations:6 seed:(random 0 9999) fractal:on scale:(random 3.00 3.50))
			addmodifier newRock (Noisemodifier strength:[0,0,(random 0.150 0.250)] iterations:6 seed:(random 0 9999) fractal:on scale:(random 5.00 5.50))
				
			scale newRock [.5,.5,.5]
			ResetScale newRock
			
			if checkboxOptimize.checked == true then
				(
				progressLabel.text = (" status: Optimizing " + (i as string) + " of " + (spinnerCount.value as string))
				newOptimize = ProOptimizer LockMat:off VertexPercent:(spinnerOptimize.value)
				addmodifier newRock newOptimize
				validModifier newRock newOptimize
				newOptimize.Calculate = True
				converttopoly newRock
				)

			progressLabel.text = (" status: Placing " + (i as string) + " of " + (spinnerCount.value as string))
			newRock.pivot = newRock.center
			newRock.pos = [i*10,0,0]

			newRock.wirecolor = [20,20,20]
				
			iString = substring ((i + 1000) as string) 2 5
			newRock.name = ("Sandstone_" + iString) 
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
	on spinnerFacetsStart changed state do (if spinnerFacetsStart.value > spinnerFacetsEnd.value then (spinnerFacetsEnd.value = spinnerFacetsStart.value))
	on spinnerFacetsEnd changed state do (if spinnerFacetsEnd.value < spinnerFacetsStart.value then (spinnerFacetsStart.value = spinnerFacetsEnd.value))
	on checkboxOptimize changed state do ( if checkboxOptimize.checked == true then (spinnerOptimize.enabled = true) else(spinnerOptimize.enabled = False))
	on generateButton pressed do (functionGenerate())
)
AddSubRollout DebrisMaker.theSubrollout sandstoneModule
debrisMaker.height = 288