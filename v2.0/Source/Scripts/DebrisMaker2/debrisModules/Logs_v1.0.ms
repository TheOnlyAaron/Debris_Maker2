--*****************************************************
-- Tool part of the DebrisMaker 2.0 by
-- Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.0 : 03.12.2012  >> Created					  
--*****************************************************

woodLoglModuleVer = 1.0
try(removeSubRollout debrisMaker.theSubrollout woodLoglModule)catch()

try(
	global spinnerLogRadiusVal = 3
	global spinnerLogRadiusDeviationVal = 80
	global spinnerLogLengthVal = 10
	global spinnerLogLengthDeviationVal = 50
	global spinnerLogDeformationVal = 6
		
	global checkboxMakeBarkVal = false
	global spinnerBarkThicknessVal = .2 -- .1 to  .3
		
	global checkboxSmoothResultVal = false
		
	global spinnerGenerationNumberVal = 15--6

	global checkbuttonArrangeArrayVal = false
	global checkbuttonArrangeStackedVal = true
		
	global spinnerStackWidthVal = 10
	global spinnerStackHeightVal = 3
	)catch()

rollout woodLoglModule ("Wood - Logs v" + (woodLoglModuleVer as string))
(
	groupbox groupboxGeometry "Geometry"  width:177 pos:[5,5] height:125 --offset:[-8,0]
		spinner spinnerLogRadius "" range:[3,10,3] type:#integer pos:[12,25] width:40
		label labelLogRadius ":Radius" offset:[40,-20] align:#left
		spinner spinnerLogRadiusDeviation "" range:[30,80,50] type:#integer offset:[80,-19] width:40 align:#left
		label labelLogRadiusDeviation ":% rand" offset:[123,-20] align:#left
	
		spinner spinnerLogLength "" range:[3,20,10] type:#integer pos:[12,45] width:40
		label labelLogLength ":Length" offset:[40,-20] align:#left
		spinner spinnerLogLengthDeviation "" range:[30,80,50] type:#integer offset:[80,-19] width:40 align:#left
		label labelLogLengthDeviation ":% rand" offset:[123,-20] align:#left
	
		spinner spinnerLogDeformation "" range:[3,12,6] type:#integer pos:[12,65] width:40
		label labelLogDeformation ":Log Deformation" offset:[40,-20] align:#left
	
		checkbox checkboxMakeBark ":Make Bark" pos:[12,87] checked:on
		spinner spinnerBarkThickness "" range:[1.0,3.0,2.0] type:#float offset:[80,-20] width:40 align:#left enabled:true
		label labelBarkThickness ":Thick" offset:[123,-20] align:#left enabled:true
	
		checkbox checkboxSmoothResult ":High-Poly Result" pos:[12,108] checked:on
	
	groupbox groupboxUniqueLogs "Uniqueness"  width:177 pos:[5,135] height:45 --offset:[-8,0]
		spinner spinnerGenerationNumber "" range:[1,20,5] type:#integer pos:[12,155] width:40
		label labelGenerationNumber ":Unique Logs" offset:[40,-20] align:#left
		
	groupbox groupboxArrangement "Arrangement"  width:177 pos:[5,185] height:65 --offset:[-8,0]
 		checkbutton checkbuttonArrangeArray "Array" width:80 height:20 align:#left offset:[0,-54]  checked:true
 		checkbutton checkbuttonArrangeStacked "Stacked" width:80 height:20 align:#left offset:[82,-25]
 		
 		spinner spinnerStackWidth "" range:[3,35,12] type:#integer pos:[12,225] width:40 enabled:false
		label labelStackWidth ":Width" offset:[40,-20] align:#left enabled:false
		spinner spinnerStackHeight "" range:[1,8,3] type:#integer offset:[80,-19] width:40 align:#left  enabled:false
		label labelStackHeight ":Height" offset:[123,-20] align:#left enabled:false
		
	groupbox groupboxGeneration "Generation" pos:[5,255] height:80 width:177
		button GenerateButton "<<  Generate  >>" width:164 height:30 offset:[-1,-70]
		progressbar theProgressGroup width:165 height:6 offset:[-3,0] value:0
		label progressLabel " status: ready" offset:[-1,-5] style_sunkenedge:true width:165 height:16
		
---------------- FUNCTIONS --------------
		
	fn functionToggleWholeChopped var= 
		(
		checkboxLogsWhole.checked = false
		checkboxLogsChopped.checked = false
		var.checked = true
		)
		
	fn functionToggleMakeBark =
		(
		if checkboxMakeBark.checked == true then
			(
			spinnerBarkThickness.enabled = true
			labelBarkThickness.enabled = true
			)
		else
			(
			spinnerBarkThickness.enabled = false
			labelBarkThickness.enabled = false
			)
		)
		
	fn functionToggleStackedEnable = 
		(
		if checkbuttonArrangeStacked.checked == true then
			(
			spinnerStackWidth.enabled = true
			labelStackWidth.enabled = true 
			spinnerStackHeight.enabled = true
			labelStackHeight.enabled = true
			)
		else
			(
			spinnerStackWidth.enabled = false
			labelStackWidth.enabled = false 
			spinnerStackHeight.enabled = false
			labelStackHeight.enabled = false
			)
		)
		
	fn functionArrangementToggle var=
		(
		checkbuttonArrangeArray.checked = false
		checkbuttonArrangeStacked.checked = false
		var.checked = true
			
		functionToggleStackedEnable()
		)
		
	function functionPrepScene = 
		(
		Global xPos = 0
		Global  logsBankArray = #()
		Global  logsStackedArray = #()
		Global  previousLogData = undefined
		)

	function functionGetNodeWidth curNode = 
		(
		bb = nodeLocalBoundingBox curNode
		bbSize = (bb[1] - bb[2])
		return (abs(bbSize[1]))
		)

	function functionDropLog curLog =
		(
		test = false
		rayStart = curLog.pos
		dropRay = ray rayStart [0,0,-1]
			
		logsStackedNumber = logsStackedArray.count
		
		while logsStackedNumber > 0 do
			(
			curTestLog = logsStackedArray[logsStackedNumber]
				
			try(
				curZpos = (intersectRay curTestLog dropRay).pos
				test=true
				)
			catch(logsStackedNumber = (logsStackedNumber - 1))
				
			if test == true then
				(
				curWidth = functionGetNodeWidth curLog
				curLog.pos.z = ((curZpos[3] + (curWidth / 2)) +.1)
				exit
				)
			else()
			)
		)
	
	function functionCreateHorizontalRow rowNumber logsNumber =  -- the height iteration, the number of logs
		(
		-- Stack First Log
		curLog = instance logsBankArray[(random 1 logsBankArray.count)]
		bb = nodeLocalBoundingBox curLog
		bb1 = bb[1]
		transX = ((bb1[1] * -1) + (spinnerLogRadiusVal * rowNumber ) - .1)
		transY = (bb1[2] * -1)
		transZ = (bb1[3] * -1)
		move curLog [transX,transY,transZ]
		curlog.pos.y = 0
		
		if rowNumber == 1 then()
		else
			(
			curlog.pos.z = (rowNumber * (spinnerLogRadiusVal * 3))
			functionDropLog curLog
			)

		-- Add the current log to the stacked logs array
		join logsStackedArray curLog
			
		-- set the properties for the previous log
		previousLogBB = nodeLocalBoundingBox curLog
		
		-- Stack the first row
		for i in 1 to (spinnerStackWidthVal - rowNumber) do
			(
			-- Instance log from the bank, and measure it
			curLog = instance logsBankArray[(random 1 logsBankArray.count)]
			bb = nodeLocalBoundingBox curLog
			bb1 = bb[1]
			previousLogBB2 = previousLogBB[2]
			transX = ((bb1[1] * -1)+previousLogBB2[1])
			transY = (bb1[2] * -1)
			transZ = (bb1[3] * -1)
			
			-- position the log
			move curLog [transX,transY,transZ]
			curlog.pos.y = 0
			
			-- Set the appropriate height
			if rowNumber == 1 then()
			else
				(
				curlog.pos.z = (rowNumber * (spinnerLogRadiusVal * 3))
				functionDropLog curLog
				)
			
			-- Add the current log to the stacked logs array
			join logsStackedArray curLog
				
			-- set the properties for the previous log
			previousLogBB = nodeLocalBoundingBox curLog
			)
		)
		
	function functionStackTheLogs widthNumber heightNumber = 
		(
		for i in 1 to spinnerStackHeightVal do(functionCreateHorizontalRow i (spinnerStackWidthVal + 1 - i))
		for i in 1 to logsStackedArray.count do
			(
			rotate logsStackedArray[i] (eulerangles 0 (random 0 360) 0)	
			)
		)
	
	function functionCreateTheLogs = 
		(
		For i in 1 to spinnerGenerationNumberVal do--spinnerGenerationNumberVal do
			(
			
			theProgressGroup.value = (((100 / spinnerGenerationNumberVal) * i) *.8)
				
			-- Iteration Customizers
			if (random 0 1) == 1 then (posNeg = 1) else (posNeg = -1)
			curRadius = (spinnerLogRadiusVal + ((random 0.0 spinnerLogRadiusDeviationVal) * .015 ) * posNeg )
			curLength = (spinnerLogLengthVal + ((random 0.0 spinnerLogLengthDeviationVal) * .04 ) * posNeg )
			curName = "Log_Geo_" + (i as string)
			
			-- Position Stuff
			if checkbuttonArrangeArrayVal == True then ( yPos = 0 ) else ( yPos = -25)
			zPos = curLength * -.5

			-- Create Core OBJ
			newLog = cylinder wirecolor:gray sides:24 heightsegs:10 capsegs:4 radius:curRadius height:curLength name:curName pos:[xPos,yPos,zPos] 
			addmodifier newLog (noisemodifier strength:[0,0,.5] scale:8 fractal:on seed:(random 0000 9999)) -- Disturb the ends
			addmodifier newLog (taper amount:(random -.13 .13)) -- Taper the log
			
				-- Core Displace
				newNoise = noise size: 3 phase:(random 1.0 999.0)
				newNoise.coords.Tiling = [1,1,0.1]
				newDisplace = (Displace strength:((random 2.0 4.0)/6 * spinnerLogDeformationVal) lumCenterEnable:on lumCenter:.5 maptype:1 cap:off)
				addmodifier newLog newDisplace
				newDisplace.map = newNoise
			
			-- Create Bark OBJ
			if checkboxMakeBarkVal == true then
				(
				newBark = copy newLog
				converttopoly newBark
				move newBark [0,0,0]
				deleteArray = #()
				collapseArray = #()
			
				-- Bark Face Deletion
				for i in 1 to 96 do (join deleteArray #(i))
				for i in 337 to 432 do (join deleteArray #(i))
				polyop.deleteFaces newBark deleteArray
					
				-- Bark Displacement
				addmodifier newBark (Turbosmooth iterations: 2  sepBySmGroups:on)
				addmodifier newBark (Noisemodifier strength:[0,0,.2] fractal:on scale:20 roughness:1 seed:(random 1 9999) ) -- edge height noise
					
				newNoise = noise size: .1 phase:(random 1.0 999.0) type:1 levels:6
				newNoise.coords.Tiling = [1,1,0.001]
				newDisplace = (Displace strength:1 lumCenterEnable:on lumCenter:.5 maptype:1)
				addmodifier newBark newDisplace
				newDisplace.map = newNoise
					
				-- Bark Shelling / Smoothing
				addmodifier newBark (shell outerAmount:spinnerBarkThicknessVal)
				if checkboxSmoothResultVal == true then (addmodifier newBark (Turbosmooth iterations: 1))else()
				)
				else()
					
			-- Modify Core OBJ Faces
				convertToPoly newLog
						
				collapseArray = #()
				for i in 409 to 432 do (join collapseArray #(i))
				polyop.collapseFaces newLog collapseArray			
					
				collapseArray = #()
				for i in 1 to 24 do (join collapseArray #(i))
				polyop.collapseFaces newLog collapseArray
				
				if checkboxSmoothResultVal == true then (addmodifier newLog (Turbosmooth iterations: 2 sepBySmGroups:on))else(addmodifier newLog (Turbosmooth iterations: 1 sepBySmGroups:on))
				newDisplace = (Displace strength:1 lumCenterEnable:on lumCenter:.5 maptype:1)
				addmodifier newLog newDisplace
				newDisplace.map = newNoise
				if checkboxSmoothResultVal == true then (addmodifier newLog (Relax Relax_Value: 0.5 iterations:1 ) )else(addmodifier newLog (Relax Relax_Value: 0.5 iterations:1))

			awesomeRand = (random 1 3)
					
			case awesomeRand of
				(
				1:(  -- HACK AND SLASH
					newRamp = gradient_ramp Gradient_Type: 9
					
					newRamp.Coordinates.U_angle = (random 100 200)
					newRamp.Coordinates.V_angle = (random 100 200)
					
					newDisplace = (Displace strength:.15 lumCenterEnable:on lumCenter:.5 maptype:0)
					addmodifier newLog newDisplace
					newDisplace.map = newRamp
					
					addmodifier newLog (Relax Relax_Value: 0.5 iterations:1 )
					)
					
				2:(  -- RADIAL SAW
					newRamp = gradient_ramp Gradient_Type: 9
					
					newRamp.Coordinates.W_angle = (random 0 360)
					
					newDisplace = (Displace strength:.15 lumCenterEnable:on lumCenter:.5 maptype:0)
					addmodifier newLog newDisplace
					newDisplace.map = newRamp
					
					addmodifier newLog (Relax Relax_Value: 0.5 iterations:1 )
					)
					
				3:() -- FREE PASS!!
				)
					
			-- attach pieces
			if checkboxMakeBarkVal == true then 
				(
				converttopoly newbark
				converttopoly newLog
				polyop.attach newLog newBark
				) else ()
				
			converttomesh newLog
			newLog.wirecolor = [20,20,20]
			
			-- Positioning Stuff
			newLog.pivot = newLog.center
			rotate newlog (angleaxis 90 [1,0,0]) 
			xPos = ((curRadius *3) + xPos)
			
			-- Add Logs to array
			join logsBankArray newLog
			)
		)
	
---------------- EVENT HANDLERS --------------
	on checkboxLogsWhole changed state do (functionToggleWholeChopped checkboxLogsWhole)
	on checkboxLogsChopped changed state do (functionToggleWholeChopped checkboxLogsChopped)
		
	on checkboxMakeBark changed state do (functionToggleMakeBark())
		
	on checkbuttonArrangeArray changed state do (functionArrangementToggle checkbuttonArrangeArray)
	on checkbuttonArrangeStacked changed state do (functionArrangementToggle checkbuttonArrangeStacked)
		
	on GenerateButton pressed do
		(
			
		timerStart = timeStamp()
			
		disableSceneRedraw()
			
		progressLabel.text = " status: preparing scene"
		theProgressGroup.value = 10
		spinnerLogRadiusVal = spinnerLogRadius.value --3
		spinnerLogRadiusDeviationVal = spinnerLogRadiusDeviation.value --80
		spinnerLogLengthVal = spinnerLogLength.value --10
		spinnerLogLengthDeviationVal = spinnerLogLengthDeviation.value --50
		spinnerLogDeformationVal = spinnerLogDeformation.value -- 6
		checkboxMakeBarkVal = checkboxMakeBark.checked -- false
		spinnerBarkThicknessVal = (spinnerBarkThickness.value * .1)  --.2 -- .1 to  .3
		global checkboxSmoothResultVal = checkboxSmoothResult.checked -- false
		spinnerGenerationNumberVal = spinnerGenerationNumber.value --6
		checkbuttonArrangeArrayVal = checkbuttonArrangeArray.checked -- false
		checkbuttonArrangeStackedVal = checkbuttonArrangeStacked.checked -- true
		spinnerStackWidthVal = spinnerStackWidth.value -- 10
		spinnerStackHeightVal = spinnerStackHeight.value -- 3
			
		functionPrepScene()
			
		progressLabel.text = " status: Creating Logs"			
		functionCreateTheLogs()
		
		progressLabel.text = " status: Aranging Logs"
		theProgressGroup.value = 95
		
		if checkbuttonArrangeArrayVal == false then (functionStackTheLogs spinnerStackWidthVal spinnerStackHeightVal;delete logsBankArray) else()
		enableSceneRedraw()
		redrawViews()
		
		theProgressGroup.value = 100
		
		timerEnd = timeStamp()
		progressLabel.text =  (" Generation took: " + (((timerEnd - timerStart) / 1000.0) as string) + " s")
		
		)
)

AddSubRollout DebrisMaker.theSubrollout woodLoglModule
debrisMaker.height = 387