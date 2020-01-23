--*****************************************************
-- Tool part of the DebrisMaker 2.0 by
-- Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.0 : 06.25.2013  >> Created					  
--*****************************************************

gravelModuleVer = 1.0
try(removeSubRollout debrisMaker.theSubrollout gravelModule)catch()

rollout gravelModule ("Gravel v" + (gravelModuleVer as string))
(
	groupbox meteorGroup "Options"  width:177 pos:[5,5] height:105 
		spinner spinnerCount "" range:[1,50,10] type:#integer pos:[12,25] width:40 tooltip:"Amount of gravel objects to create"
		label labelCount ": Gravel Count" offset:[40,-20] align:#left tooltip:"Amount of gravel objects"
		spinner spinnerIrregularitySize "" range:[1,10,5] type:#integer pos:[12,45] width:40 tooltip:"Size of the objects displacement"
		label labelIrregularitySize ": Irregularity Size" offset:[40,-20] align:#left tooltip:"Size of the objects displacement"
		spinner spinnerSmoothness "" range:[0,20,10] type:#integer pos:[12,65] width:40 tooltip:"Roughness of the object"
		label labelSmoothness ": Roughness" offset:[40,-20] align:#left tooltip:"Roughness of the object"
		checkbox checkboxOptimize "Optimize result" pos:[12,85] tooltip:"Optimize and collapse geometry" checked:true
		spinner spinnerOptimize "" range:[10,90,30] type:#integer pos:[105,85] width:40 enabled:true tooltip:"Percent of verticies to remain after optimization"
		label labelPercent "%" offset:[135,-20] align:#left tooltip:"Percent of verticies to remain after optimization"
	
	groupbox groupboxGeneration "Generation" pos:[5,115] height:80 width:177 
		button GenerateButton "<<  Generate  >>" width:164 height:30 offset:[-1,-70] tooltip:"Generate Debris"
		progressbar theProgressGroup width:165 height:6 offset:[-3,0] value:0
		label progressLabel " status: ready" offset:[-1,-5] style_sunkenedge:true width:165 height:16 tooltip:"Status Bar"
	
-- Functions
	function functionGenerate = 
	(
		
	timerStart = timeStamp()
		
	try(
		disablesceneredraw()

		newRockArray = #()
		-- delete objects
		for i in 1 to spinnerCount.value do 
			(
			theProgressGroup.value  = (((i + 0.00) / spinnerCount.value) * 100)
			progressLabel.text = (" status: Building " + (i as string) + " of " + (spinnerCount.value as string))
			-- Variables
			rockBoxSegs = 5
			rockBoxSidesX = (random 10 20)
			rockBoxSidesY = (random 10 20)
			rockBoxSidesZ = (random 5 15)
			rockDisplaceValNoise = ((random -6.50 -5.5)*(spinnerSmoothness.value / 5)) -- spinnerSmoothness.value
			rockDisplaceMapSize = (spinnerIrregularitySize.value * 10)

			-- Create new geo
			newRock = box length:rockBoxSidesX width:rockBoxSidesY height:rockBoxSidesZ lengthsegs:rockBoxSegs heightsegs:rockBoxSegs widthsegs:rockBoxSegs
			addmodifier newRock (spherify PERCENT:(random 80 100) )
			addmodifier newRock (turbosmooth iterations:2)

			-- Create large shape displace
			newCellular = cellular size:(random 11 15) --phase:(random 1.0 999.0)
			newDisplace = (displace strength:rockDisplaceValNoise maptype:2 length:rockDisplaceMapSize width:rockDisplaceMapSize height:rockDisplaceMapSize lumCenterEnable:on lumCenter: 1)
			addmodifier newRock newDisplace
			newDisplace.map = newCellular

			newWeld = (Vertex_Weld threshold:2.55)
			addmodifier newRock newWeld
				
			newSub = subdivide threshold:1.3
			addmodifier newRock newSub

			newWeld = (Vertex_Weld threshold:1.3)
			addmodifier newRock newWeld

			newWeld = (Vertex_Weld threshold:1)
			addmodifier newRock newWeld
				
			newRelax = (relax Keep_Boundary_Pts_Fixed: 1  Relax_Value: 0.5 iterations: 1)
			addmodifier newRock newRelax
			newRock.pivot = newRock.center
			newRock.pos = [0,0,0]

			newRock.scale = [.2,.2,.2]
			ResetScale newRock
			
			if checkboxOptimize.checked == true then
				(
				progressLabel.text = (" status: Optimizing " + (i as string) + " of " + (spinnerCount.value as string))
				newOptimize = ProOptimizer LockMat:off VertexPercent:(spinnerOptimize.value)
				addmodifier newRock newOptimize
				validModifier newRock newOptimize
				newOptimize.Calculate = True
					
				newWelder = welder dontWeldSelectedEdges:off weldMethod:0 threshold:0.1
				addmodifier newRock newWelder
				converttopoly newRock
				)

			progressLabel.text = (" status: Placing " + (i as string) + " of " + (spinnerCount.value as string))
			move newrock [((i*10)-i),0,0]	
			join newRockArray newRock
			newRock.wirecolor = [20,20,20]
			
			iString = substring ((i + 1000) as string) 2 5
			newRock.name = ("Gravel_" + iString) 
				
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
	on checkboxOptimize changed state do ( if checkboxOptimize.checked == true then (spinnerOptimize.enabled = true) else(spinnerOptimize.enabled = False))
	on generateButton pressed do (functionGenerate())
)
AddSubRollout DebrisMaker.theSubrollout gravelModule
debrisMaker.height = 250