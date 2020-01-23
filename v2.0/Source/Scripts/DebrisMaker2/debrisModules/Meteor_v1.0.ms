--*****************************************************
-- Tool part of the DebrisMaker 2.0 by
-- Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.0 : 06.25.2013  >> Created					  
--*****************************************************

meteoriteModuleVer = 1.0
try(removeSubRollout debrisMaker.theSubrollout meteoriteModule)catch()

rollout meteoriteModule ("Meteorite v" + (meteoriteModuleVer as string))
(
	groupbox meteorGroup "Options"  width:177 pos:[5,5] height:125
		spinner spinnerCount "" range:[1,10,5] type:#integer pos:[12,25] width:40 tooltip:"Amount of meteor objects to create"
		label labelCount ":Meteor Count" offset:[40,-20] align:#left tooltip:"Amount of meteor objects to create"
		spinner spinnerIrregularityLarge "" range:[0,20,10] type:#integer pos:[12,45] width:40 tooltip:"Amount of overall shape irregularity"
		label labelIrregularityLarge ":Large irregularity" offset:[40,-20] align:#left  tooltip:"Overall shape irregularity"
		spinner spinnerIrregularityMedium "" range:[0,20,10] type:#integer pos:[12,65] width:40 tooltip:"Amount of medium shape irregularity"
		label labelIrregularityMedium ":Medium irregularity" offset:[40,-20] align:#left  tooltip:"Amount of medium shape irregularity"
		spinner spinnerIrregularitySmall "" range:[0,20,10] type:#integer pos:[12,85] width:40  tooltip:"Strength of small craters"
		label labelIrregularitySmall ":Small irregularity" offset:[40,-20] align:#left tooltip:"Strength of small craters"
		checkbox checkboxOptimize "Optimize result" pos:[12,105] tooltip:"Optimize and collapse geometry"
		spinner spinnerOptimize "" range:[10,90,30] type:#integer pos:[105,105] width:40 enabled:False tooltip:"Percent of verticies to remain after optimization"
		label labelPercent "%" offset:[135,-20] align:#left tooltip:"Percent of verticies to remain after optimization"
	
	groupbox groupboxGeneration "Generation" pos:[5,135] height:80 width:177
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
			-- Variables
			rockBoxSegs = 5
			rockBoxSideX = random 8 20
			rockBoxSideY = random 8 20
			rockBoxSideZ = random 8 20
			rockDisplaceValNoise = ((random -6.50 -5.5)*(spinnerIrregularityLarge.value * .1))
			rockDisplace2ValNoise = ((random -0.20 -0.25)*(spinnerIrregularitySmall.value * .1))
			rockDisplace3ValNoise = ((random -0.70 -.75)*(spinnerIrregularityMedium.value * .1))
			rockDisplaceMapSize = 20

			-- Create new geo
			newRock = box length:rockBoxSideX width:rockBoxSideY height:rockBoxSideZ lengthsegs:rockBoxSegs heightsegs:rockBoxSegs widthsegs:rockBoxSegs
			addmodifier newRock (spherify PERCENT:(random 30 100) )
			addmodifier newRock (turbosmooth iterations:5)

			-- Create large shape displace
			newCellular = cellular size:(random 18.000 21.000) fractal:on iterations:2 --phase:(random 1.0 999.0)
			newDisplace = (displace strength:rockDisplaceValNoise maptype:2 length:rockDisplaceMapSize width:rockDisplaceMapSize height:rockDisplaceMapSize lumCenterEnable:on)
			addmodifier newRock newDisplace
			newDisplace.map = newCellular

			-- Relax Edges
			newRelax = relax iterations:6 Relax_Value:1
			addmodifier newRock newRelax

			-- Introduce some noise
			newNoise = Noisemodifier scale:(random 2.50 3.00) strength: [0.3,0.3,0.3] fractal: on seed:(random 0 9999)
			addmodifier newRock newNoise

			-- Create small pitts displace
			newCellular2 = cellular name:"cell2" size:(random 1.500 2.500) spread:.1 --phase:(random 1.0 999.0)
			newDisplace2 = (displace strength:rockDisplace2ValNoise maptype:2 length:rockDisplaceMapSize width:rockDisplaceMapSize height:rockDisplaceMapSize)
			addmodifier newRock newDisplace2
			newDisplace2.map = newCellular2

			newRelax = relax iterations:1 Relax_Value:1
			addmodifier newRock newRelax

			-- Introduce some noise
			newNoise = Noisemodifier scale:(random 2.50 3.00) strength: [0.15,0.15,0.15] fractal: on seed:(random 0 9999)
			addmodifier newRock newNoise

			-- Create large pitts displace
			newCellular3 = cellular name:"cell2" size:(random 5.0 6.0) spread:.1 --phase:(random 1.0 999.0)
			newDisplace3 = (displace strength:rockDisplace3ValNoise maptype:2 length:rockDisplaceMapSize width:rockDisplaceMapSize height:rockDisplaceMapSize)
			addmodifier newRock newDisplace3
			newDisplace3.map = newCellular3
			
			scale newRock [.4,.4,.4]
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
			newRock.pos = [((i-1) * 10),0,0]
			
			newRock.wirecolor = [20,20,20]
			
			iString = substring ((i + 1000) as string) 2 5
			newRock.name = ("Meteorite_" + iString) 
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
AddSubRollout DebrisMaker.theSubrollout meteoriteModule
debrisMaker.height = 270