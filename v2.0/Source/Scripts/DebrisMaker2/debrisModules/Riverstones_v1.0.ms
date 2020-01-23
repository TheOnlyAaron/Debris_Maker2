--*****************************************************
-- Tool part of the DebrisMaker 2.0 by
-- Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.0 : 06.26.2013  >> Created					  
--*****************************************************

riverstoneModuleVer = 1.0
try(removeSubRollout debrisMaker.theSubrollout riverstoneModule)catch()

rollout riverstoneModule ("Riverstone v" + (riverstoneModuleVer as string))
(
	groupbox riverstoneGroup "Options"  width:177 pos:[5,5] height:280
		spinner spinnerCount "" range:[1,10,5] type:#integer pos:[12,25] width:40 tooltip:"Amount of riverstones to create"
		label labelCount ": Riverstones Count" offset:[40,-20] align:#left tooltip:"Amount of riverstones to create"
	
		checkbox checkboxIrregularShape "Irregular Shape" pos:[12,45] checked:true tooltip:"Make the shape lumpy-ish"
			spinner spinnerIrregularityAmount "" range:[0,30,10] type:#integer pos:[22,65] width:40 tooltip:"Make the shape lumpy-ish"
			label labelIrregularityAmount ": Irregularity amount" offset:[50,-20] align:#left tooltip:"Make the shape lumpy-ish"
			spinner spinnerIrregularitySize "" range:[0,30,10] type:#integer pos:[22,85] width:40 tooltip:"Make the shape lumpy-ish"
			label labelIrregularitySize ": Irregularity size" offset:[50,-20] align:#left tooltip:"Make the shape lumpy-ish"
		
		checkbox checkboxBanding "Banding" pos:[12,105] checked:true tooltip:"Add banding pattern to rock geometry"
			spinner spinnerBandingAmount "" range:[0,30,10] type:#integer pos:[22,125] width:40 tooltip:"Add banding pattern to rock geometry"
			label labelBandingAmount ": Banding amount" offset:[50,-20] align:#left tooltip:"Ammount of banding to add"
			spinner spinnerBandingSize "" range:[0,30,10] type:#integer pos:[22,145] width:40 tooltip:"Size of banding to add"
			label labelBandingSize ": Banding size" offset:[50,-20] align:#left tooltip:"Size of banding to add"
	
		checkbox checkboxPitting "Pitting" pos:[12,165] checked:true tooltip:"Add pitting pattern to rock geometry"
			spinner spinnerPittingAmount "" range:[0,30,10] type:#integer pos:[22,185] width:40 tooltip:"Add pitting pattern to rock geometry"
			label labelPittingAmount ": Pitting amount" offset:[50,-20] align:#left tooltip:"Ammount of pitting to add"
			spinner spinnerPittingSize "" range:[0,30,10] type:#integer pos:[22,205] width:40 tooltip:"Size of pitting to add"
			label labelPittingSize ": Pitting size" offset:[50,-20] align:#left tooltip:"Size of pitting to add"
	
		checkbox checkboxChipping "Chipping" pos:[12,225] checked:false tooltip:"Chip the rock geometry ( slow )"
			spinner spinnerChippingAmount "" range:[0,30,10] type:#integer pos:[22,245] width:40 enabled:false tooltip:"Amount of chipping to perform on rocks ( slow )"
			label labelChippingAmount ": Chipping amount" offset:[50,-20] align:#left enabled:false tooltip:"Amount of chipping to perform on rocks ( slow )"

		checkbox checkboxOptimize "Optimize result" pos:[12,265] tooltip:"Optimize and collapse geometry"
			spinner spinnerOptimize "" range:[10,90,30] type:#integer pos:[105,265] width:40 enabled:False tooltip:"Percent of verticies to remain after optimization"
 	 		label labelPercent "%" offset:[135,-20] align:#left tooltip:"Percent of verticies to remain after optimization"
	
	groupbox groupboxGeneration "Generation" pos:[5,290] height:80 width:177
		button GenerateButton "<<  Generate  >>" width:164 height:30 offset:[-1,-70] tooltip:"Generate Debris"
		progressbar theProgressGroup width:165 height:6 offset:[-3,0] value:0
		label progressLabel " status: ready" offset:[-1,-5] style_sunkenedge:true width:165 height:16
-- 	
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
				
			rockIrregularity = checkboxIrregularShape.checked
				rockIrregularityStrength = ((random -2 -3)*(spinnerIrregularityAmount.value * .2)) --2
				rockIrregularitySize = ((random 8.000 10.000)*(spinnerIrregularitySize.value * .1)) --1
			rockRounding = true
				rockRoundingIterations = int((random 5 7)*25)
			rockStripes = checkboxBanding.checked
				rockStripesStrength = ((random .15 .30)*(spinnerBandingAmount.value * .1)) --1
				rockStripesSize = (random 10.0 13.0*(spinnerBandingSize.value * .1)) --1
			rockPitting = checkboxPitting.checked
				rockPittingStrength = ((random -.75 -.1)*(spinnerPittingAmount.value * .1)) -- 1
				rockPittingSize = ((random .400 .200) * (spinnerPittingSize.value *.1)) -- 1
			rockChipping = checkboxChipping.checked
				rockChippingAmmount = (spinnerChippingAmount.value * .1) -- 3
				
			if rockStripes == false and rockPitting == false then (smoothIterations = 5)else(smoothIterations = 6)
				
			-- Create base geometry
			boxX = (random 5 10)
			boxY = (random 5 10)
			boxZ = (random 2 6)
			newRock = box width:boxX length:boxY height:boxZ
			if rockChipping == false then(addmodifier newRock (turbosmooth iterations:smoothIterations isolineDisplay:off))else(addmodifier newRock (turbosmooth iterations:6 isolineDisplay:off))

			if rockIrregularity == true then
				(
				-- Create large shape displace
				newCellular = cellular size:rockIrregularitySize fractal:on iterations:2 --phase:(random 1.0 999.0)
				newDisplace = (displace strength:rockIrregularityStrength maptype:2  lumCenterEnable:on lumCenter:.8 )--length:rockDisplaceMapSize width:rockDisplaceMapSize height:rockDisplaceMapSize)
				addmodifier newRock newDisplace
				newDisplace.map = newCellular
				)else()
				
			if rockRounding == true then
				(
				newRelax = relax iterations:rockRoundingIterations
				addmodifier newRock newRelax
				)else()

			if rockChipping== true then
				(
				newRock. pivot = newRock.center	
				
				newChipOperand = plane length:15 width:15 lengthsegs:160 widthsegs:160 
				newChipShell = shell outerAmount:4
				newChipNoise = Noisemodifier scale:5 fractal:on strength:[1,1,.5] seed:(random 10 1000)
				addmodifier newChipOperand newChipShell
				addmodifier newChipOperand newChipNoise
					
				newChipOperand.transform = newRock.transform
				rotate newChipOperand (eulerangles (random 0 360) (random 0 360) (random 0 360))
					
				in coordsys local newChipOperand.pos = ((random [0,0,2.00] [0,0,3.00]) * rockChippingAmmount )
					
				--newRock = (newRock - newChipOperand)
				ProBoolean.createBooleanObject newRock newChipOperand 2 0 0
				
				newVertexWeld = vertexWeld threshold:.05
				newSmooth = smooth threshold:180 preventIndirect: off autosmooth:on
					
				addmodifier newRock newVertexWeld
				addmodifier newRock newSmooth
				
				)else()
				
			if rockStripes == true then
				(
				-- Create maps for composite material
				rockStripesMap1 = Color_Correction ()
				rockStripesMap1.color = (color 255 255 255) 

				rockStripesMap2 = wood color1:[255,255,255] color2:[0,0,0] thickness:rockStripesSize radialNoise:(random 1.0 4.0)
				rockStripesMap2.coords.Tiling = [1,3,1]
					
				rockStripesMap3 = Gradient_Ramp Gradient_Type:8 Noise_Type:1 Levels:4
				rockStripesMap3.gradient_ramp.flag__1.color = [255,255,255]
				rockStripesMap3.gradient_ramp.flag__3.color = [0,0,0]
				rockStripesMap3.gradient_ramp.flag__2.color = [0,0,0]
				rockStripesMap3.Coordinates.U_Tile = true
				rockStripesMap3.Coordinates.V_Tile = false
				rockStripesMap3.Coordinates.U_Tiling = 1
				rockStripesMap3.Coordinates.V_Tiling = 2
				rockStripesMap3.Coordinates.U_Offset = (random 0.00 1.00)
				rockStripesMap3.Coordinates.V_Offset = (random -.30 .30)
				rockStripesMap3.size = 5
				rockStripesMap3.amount = .5
				rockStripesMap3.phase = (random 0.0 1000.0)
					
				-- Construct Composite Material
				rockStripesMap = CompositeTexturemap()
				rockStripesMap.mapList[1] = rockStripesMap1
				rockStripesMap.mapList[2] = rockStripesMap2
				rockStripesMap.mask[2] = rockStripesMap3

				-- Create UVW map for Displacements
				newUvwmap = Uvwmap maptype:1 
				addmodifier newRock newUvwmap
				
				-- Add displacement
				newDisplace = (displace strength:rockStripesStrength lumCenterEnable:on useMap:on lumCenter: 1)
				addmodifier newRock newDisplace
				newDisplace.map = rockStripesMap
				)else()
				
			if rockPitting == true then
				(
				-- Create small pitts displace
				rockPittingMap1 = cellular name:"cell2" size:rockPittingSize spread:.1 fractal:on --phase:(random 1.0 999.0)
				rockPittingMap2 = Noise  size:1 thresholdHigh:.666 thresholdLow:.555 type:1	
				
				rockPittsMap = CompositeTexturemap()
				rockPittsMap.mapList[1] = rockPittingMap1
				rockPittsMap.mask[1] = rockPittingMap2
				
				newDisplace = (displace strength:rockPittingStrength maptype:2 lumCenterEnable:on useMap:on lumCenter:0)
				addmodifier newRock newDisplace
				newDisplace.map = rockPittsMap

				newRelax = relax iterations:3 Relax_Value:1
				addmodifier newRock newRelax
				)else()
				
			newRock. pivot = newRock.center
		
			scale newRock [.8,.8,.8]
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
			newRock.name = ("Riverstone_" + iString) 
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
	on checkboxIrregularShape changed state do (
		if checkboxIrregularShape.checked == true then
			(
			spinnerIrregularityAmount.enabled = true
			labelIrregularityAmount.enabled = true
			spinnerIrregularitySize.enabled = true
			labelIrregularitySize.enabled = true
			)
			else
			(
			spinnerIrregularityAmount.enabled = false
			labelIrregularityAmount.enabled = false
			spinnerIrregularitySize.enabled = false
			labelIrregularitySize.enabled = false
			)
		)
		
	on checkboxBanding changed state do (
		if checkboxBanding.checked == true then
			(
			spinnerBandingAmount.enabled = true
			labelBandingAmount.enabled = true
			spinnerBandingSize.enabled = true
			labelBandingSize.enabled = true
			)
			else
			(
			spinnerBandingAmount.enabled = false
			labelBandingAmount.enabled = false
			spinnerBandingSize.enabled = false
			labelBandingSize.enabled = false
			)
		)
		
	on checkboxPitting changed state do (
		if checkboxPitting.checked == true then
			(
			spinnerPittingAmount.enabled = true
			labelPittingAmount.enabled = true
			spinnerPittingSize.enabled = true
			labelPittingSize.enabled = true
			)
			else
			(
			spinnerPittingAmount.enabled = false
			labelPittingAmount.enabled = false
			spinnerPittingSize.enabled = false
			labelPittingSize.enabled = false
			)
		)
		
	on checkboxPitting changed state do (
		if checkboxPitting.checked == true then
			(
			spinnerPittingAmount.enabled = true
			labelPittingAmount.enabled = true
			spinnerPittingSize.enabled = true
			labelPittingSize.enabled = true
			)
			else
			(
			spinnerPittingAmount.enabled = false
			labelPittingAmount.enabled = false
			spinnerPittingSize.enabled = false
			labelPittingSize.enabled = false
			)
		)
	
	on checkboxChipping changed state do ( if checkboxChipping.checked == true then (spinnerChippingAmount.enabled = true;labelChippingAmount.enabled = true) else(spinnerChippingAmount.enabled = False;labelChippingAmount.enabled = False))
		
	on checkboxOptimize changed state do ( if checkboxOptimize.checked == true then (spinnerOptimize.enabled = true) else(spinnerOptimize.enabled = False))
	on generateButton pressed do (functionGenerate())
)
AddSubRollout DebrisMaker.theSubrollout riverstoneModule
debrisMaker.height = 423