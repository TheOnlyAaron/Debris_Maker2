--*****************************************************
-- Tool part of the DebrisMaker 2.0 by
-- Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.0 : 06.25.2013  >> Created					  
--*****************************************************

obsidianModuleVer = 1.0
try(removeSubRollout debrisMaker.theSubrollout obsidianModule)catch()

rollout obsidianModule ("Obsidian v" + (obsidianModuleVer as string))
(
	groupbox obsidianGroup "Options"  width:177 pos:[5,5] height:105
		spinner spinnerCount "" range:[1,10,5] type:#integer pos:[12,25] width:40 tooltip:"Amount of obsidian shards to create"
		label labelCount ": Obsidian Shards Count" offset:[40,-20] align:#left tooltip:"Amount of obsidian shards to create"
		spinner spinnerChipStrength "" range:[0,30,10] type:#integer pos:[12,45] width:40 tooltip:"Amount of chipping strength"
 		label labelChipStrength ": Chipping amount" offset:[40,-20] align:#left  tooltip:"Amount of chipping strength"
		spinner spinnerBandingAmount "" range:[0,50,10] type:#integer pos:[12,65] width:40 tooltip:"Amount of banding strength"
		label labelBandingAmount ": Banding Amount" offset:[40,-20] align:#left tooltip:"Amount of banding strength"
		checkbox checkboxOptimize "Optimize result" pos:[12,85] tooltip:"Optimize and collapse geometry"
		spinner spinnerOptimize "" range:[10,90,30] type:#integer pos:[105,85] width:40 enabled:False tooltip:"Percent of verticies to remain after optimization"
		label labelPercent "%" offset:[135,-20] align:#left tooltip:"Percent of verticies to remain after optimization"
	
	groupbox groupboxGeneration "Generation" pos:[5,115] height:80 width:177
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
			rockBoxSidesX = (random 10 20)
			rockBoxSidesY = (random 10 20)
			rockBoxSidesZ = (random 5 15)
			rockDisplaceValNoise = ((random -6.50 -5.5)*1)
			rockDisplace2ValNoise = ((random -0.30 -0.40)*(spinnerChipStrength.value *.1))
			rockDisplace3ValNoise = ((random 0.150 0.200)*(spinnerBandingAmount.value *.1))
			rockDisplaceMapSize = 20

			-- Create new geo
			newRock = box length:rockBoxSidesX width:rockBoxSidesY height:rockBoxSidesZ lengthsegs:rockBoxSegs heightsegs:rockBoxSegs widthsegs:rockBoxSegs
			addmodifier newRock (spherify PERCENT:(random 80 100) )
			addmodifier newRock (turbosmooth iterations:5)

			-- Create large shape displace
			newCellular = cellular size:(random 18.000 21.000) --phase:(random 1.0 999.0)
			newDisplace = (displace strength:rockDisplaceValNoise maptype:2 length:rockDisplaceMapSize width:rockDisplaceMapSize height:rockDisplaceMapSize)
			addmodifier newRock newDisplace
			newDisplace.map = newCellular

			-- Create small shape displace
			newCellular2 = cellular name:"cell2" size:(random 3.000 5.000) --phase:(random 1.0 999.0)
			newDisplace2 = (displace strength:rockDisplace2ValNoise maptype:2 length:rockDisplaceMapSize width:rockDisplaceMapSize height:rockDisplaceMapSize)
			addmodifier newRock newDisplace2
			newDisplace2.map = newCellular2
			
			-- Add Tapering
			newTaper = (Taper amount: (random -0.40 -0.7) curve: (random -0.60 -0.80) primaryaxis:(random 0 2) effectaxis: 0)
			addmodifier newRock newTaper

			-- Create Banding displace
			newNoise3 = noise name:"noise3" size:(random 0.300 0.400) type:1 phase:(random 0 9999) --phase:(random 1.0 999.0)
			newNoise3.coords.Tiling = [0,0,1]
			newNoise3.coords.angle = [(random -20 20),(random -20 20),(random -4 4)]--[(random -0.30 0.30),(random -0.30 0.30),(random -0.050 0.050)]--[0.307178,0.328122,0.0593412]
			newDisplace3 = (displace strength:rockDisplace3ValNoise maptype:0 length:rockDisplaceMapSize width:rockDisplaceMapSize height:rockDisplaceMapSize)
			addmodifier newRock newDisplace3
			newDisplace3.map = newNoise3
			
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
			newRock.pos = [i*6,0,0]

			newRock.wirecolor = [20,20,20]
				
			iString = substring ((i + 1000) as string) 2 5
			newRock.name = ("Obsidian_" + iString) 
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
AddSubRollout DebrisMaker.theSubrollout obsidianModule
debrisMaker.height = 250