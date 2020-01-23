--*****************************************************
-- Tool part of the DebrisMaker 2.0 by
-- Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.0 : 07.06.2013  >> Created					  
--*****************************************************

gemstoneModuleVer = 1.0
try(removeSubRollout debrisMaker.theSubrollout gemstoneModule)catch()

rollout gemstoneModule ("Gemstone v" + (gemstoneModuleVer as string))
(
	groupbox gemstoneGroup "Options"  width:177 pos:[5,5] height:105
		spinner spinnerCount "" range:[1,10,5] type:#integer pos:[12,25] width:40 tooltip:"Amount of gemstone to create"
		label labelCount ": Gemstones Count" offset:[40,-20] align:#left tooltip:"Amount of gemstone to create"
	
		spinner spinnerIrregularity "" range:[0,10,10] type:#integer pos:[12,45] width:40 tooltip:"Facets cut on each rock"
 		label labelIrregularity ": Shape Irregularity" offset:[40,-20] align:#left tooltip:"Facets cut on each rock"
	
		spinner spinnerFacets "" range:[1,100,10] type:#integer pos:[12,65] width:40 tooltip:"Facets cut on each rock"
 		label labelFacets ": Facets to cut" offset:[40,-20] align:#left tooltip:"Facets cut on each rock"

		checkbox checkboxChamferEdges "Chamfer Edges" checked:true pos:[12,85] tooltip:"Add strata detail to edge of rock"
			spinner spinnerChamferEdges "" range:[.1,9.9,1] width:35 type:#float pos:[108,85] tooltip:"Lowest number of edges possible on a rock"
	
	groupbox groupboxGeneration "Generation" pos:[5,115] height:80 width:177
		button GenerateButton "<<  Generate  >>" width:164 height:30 offset:[-1,-70] tooltip:"Generate Debris"
		progressbar theProgressGroup width:165 height:6 offset:[-3,0] value:0
		label progressLabel " status: ready" offset:[-1,-5] style_sunkenedge:true width:165 height:16
	
-- Functions
	function FN_RandomInRange minRangeArg maxRangeArg =
		(
		newRand = (random minRangeArg maxRangeArg)
		coinFlip = (random 0 1)
		if coinFlip == 0 then (newRand)else(newRand*-1)
		)

	function functionGenerate = 
		(
			
		timerStart = timeStamp()
			
		try(
			disablesceneredraw()

			majorFacets = spinnerFacets.value
			minRange = (10 - spinnerIrregularity.value)
			maxRange = 10
			ChamferEdges = checkboxChamferEdges.checked 
			chamferAmt = (spinnerChamferEdges.value*.1)

			for i in 1 to spinnerCount.value do
				(
				theProgressGroup.value  = (((i + 0.00) / spinnerCount.value) * 100)
				progressLabel.text = (" status: Building " + (i as string) + " of " + (spinnerCount.value as string))
					
				newRock = geosphere radius:20 segments:1-- box height:20 length:20 width:20
				newRock.pivot = newRock.center
					
				for i in 1 to majorFacets do 
					(
					progressLabel.text = (" status: Faceting " + (i as string) + " of " + (spinnerCount.value as string))
						
					newPoint = point()
					newSlice = sliceModifier()
					newCap = cap_holes()

					random_X_Pos = FN_RandomInRange minRange maxRange
					random_Y_Pos = FN_RandomInRange minRange maxRange
					random_Z_Pos = FN_RandomInRange minRange maxRange
						
					newPoint.pos = [random_X_Pos,random_Y_Pos,random_Z_Pos]
					newLookat = newPoint.rotation.controller = LookAt_Constraint  ()
					newLookat.target_axis = 2
					newLookat.appendTarget newRock 100
					
					addmodifier newRock newSlice
					newSlice.slice_plane.transform = newPoint.transform
					newSlice.Slice_Type = 3
						
					addmodifier newRock newCap
					delete newPoint
					)
					
				--Chamfers the edges of the shard if specified to
				if ChamferEdges == true then
					(
					progressLabel.text = (" status: Chamfering " + (i as string) + " of " + (spinnerCount.value as string))
						
					converttopoly newRock
					totalEdges = (newRock.edges.count)
					edgesArray = #{}
					for i in 1 to totalEdges do(join edgesArray #{i})
					polyop.chamferEdges newRock edgesArray chamferAmt
					)
					
				newSmooth = smooth()
				addmodifier newRock newSmooth
				scale newRock [.2,.2,.2]
				ResetScale newRock

				progressLabel.text = (" status: Placing " + (i as string) + " of " + (spinnerCount.value as string))
				newRock.pivot = newRock.center
				newRock.pos = [i*10,0,0]
				newRock.wirecolor = [20,20,20]
					
				iString = substring ((i + 1000) as string) 2 5
				newRock.name = ("Gemstone_" + iString) 
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
	on checkboxChamferEdges changed state do ( if checkboxChamferEdges.checked == true then (spinnerChamferEdges.enabled = true)else (spinnerChamferEdges.enabled = false))
	on generateButton pressed do (functionGenerate())
)
AddSubRollout DebrisMaker.theSubrollout gemstoneModule
debrisMaker.height = 250