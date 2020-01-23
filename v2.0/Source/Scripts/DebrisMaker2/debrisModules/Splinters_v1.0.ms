--*****************************************************
-- Tool part of the DebrisMaker 2.0 by
-- Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.0 : 03.12.2012  >> Created					  
--*****************************************************

splintersModuleVer = 1.0
try(removeSubRollout debrisMaker.theSubrollout splintersModule)catch()

global twistRange

rollout splintersModule ("Splinters v" + (splintersModuleVer as string))
(
	groupbox geometryShards "Options"  width:177 pos:[5,5] height:100
		spinner spinnerSplintersCount "" range:[1,40,20] type:#integer pos:[12,25] width:40
		label labelSplintersCount ":Splinter Count" offset:[40,-20] align:#left
	
		spinner spinnerSplinterTwist "" range:[1,120,10] type:#integer pos:[12,45] width:40
		label labelSplinterTwist ":Twisting" offset:[40,-20] align:#left
	
		spinner spinnerSplinterHeight "" range:[30,100,50] type:#integer pos:[12,65] width:40
		label labelSplinterHeight ":Height" offset:[40,-20] align:#left
	
		spinner spinnerSplinterHeightRange "" range:[0,40,20] type:#integer pos:[12,85] width:40
		label labelSplinterHeightRange ":Height variation" offset:[40,-20] align:#left
	
	groupbox groupboxGeneration "Generation" pos:[5,110] height:80 width:177
		button GenerateButton "<<  Generate  >>" width:164 height:30 offset:[-1,-70]
		progressbar theProgressGroup width:165 height:6 offset:[-3,0] value:0
		label progressLabel " status: ready" offset:[-1,-5] style_sunkenedge:true width:165 height:16

	
	
	fn FN_NewBaseObj arg =
		(
			
		newDebris = plane length:(random .75 1.5) width:(random .75 3.0) lengthSegs:1 widthSegs:1
		
		newTaper = taper primaryaxis:0 effectaxis:2 amount:1 curve:0
		addmodifier newDebris newTaper

		newShell = shell outerAmount:arg innerAmount:0 segments:30
		addmodifier newDebris newShell
			
		newDebris
		)
		
	fn FN_TaperArg arg =
		(
		newTaper = taper primaryaxis:2 effectaxis:2 amount:(random -.30 -.75) curve:0
		addmodifier arg newTaper
		
		arg
		)
		
	fn FN_TwistArg arg =
		(
		newTwist = twist axis: 2 angle:(random (-1 * twistRange) twistRange)
		addmodifier arg newTwist
		
		arg
		)
		
	fn FN_NoiseGrain arg =
		(
		newNoise = noisemodifier seed: (random 0 9999) scale: (random 1.0 1.5) fractal: on strength: [1,1,0]
		addmodifier arg newNoise
		validmodifier arg newNoise
		
		newNoise.gizmo.scale = [1,1,50]
		)
		
	fn FN_JaggyBool arg arg2 =
		(
		newDebris = arg
			
		newBool = box width:10 length:6 height:(arg2 * .6) lengthSegs:20 widthSegs:20 heightsegs:0 --20
		newBool.center = arg.center
			
		newNoise = noisemodifier scale:(random .40 .60) fractal:on seed:(random 0 9999) strength:[0,0,(random 20 30)] 
		addmodifier newBool newNoise
			
		newBool.pos.z = ( random -10 10 )
			
		FN_TwistArg newBool
		FN_TaperArg newBool
			
		newBool.parent = newDebris
			
		ProBoolean.createBooleanObject newDebris newBool 1 0 0
		)
		
	fn FN_Subdivide arg =
		(
		newDebris = arg
		
		newSubdivide = subdivide()
		addmodifier newDebris newSubdivide
		validmodifier newDebris newSubdivide
		newSubdivide. size = 1
		)

	on GenerateButton pressed do
		(
		timerStart = timeStamp()
			
		max create mode
			
		debrisCount = spinnerSplintersCount.value --10
		twistRange = spinnerSplinterTwist.value --10 -- 120
		splinterHeight = spinnerSplinterHeight.value --50
		splinterHeightRange = spinnerSplinterHeightRange.value --50
			
		for i in 1 to debrisCount do
			(
			theProgressGroup.value  = (((i + 0.00) / debrisCount) * 100)
			progressLabel.text = (" status: Building " + (i as string) + " of " + (debrisCount as string))
				
			curHeight = ((random 0 splinterHeightRange) + splinterHeight )
				
			newDebris = FN_NewBaseObj curHeight
				
			FN_TaperArg newDebris
			FN_Subdivide newDebris
			FN_NoiseGrain newDebris	
				
			FN_JaggyBool newDebris curHeight
				
			converttopoly newDebris
			newDebris.pivot = newDebris.center
			newDebris.position = [0,0,0]
				
			scale newDebris [.5,.5,.5]
			ResetScale newDebris

			newDebris.name = ("Splinter_"+(i as string))
			newdebris.wirecolor = [20,20,20]
			move newdebris [(i*5),0,0]
				
			if newDebris.GetNumVertices() < 2500
			then()
			else
				(
-- 				print "FAIL!!!"
				i = ( i - 1 )
				delete newDebris
				)
			)
		timerEnd = timeStamp()
		progressLabel.text =  (" Generation took: " + (((timerEnd - timerStart) / 1000.0) as string) + " s")
		)
	)
AddSubRollout DebrisMaker.theSubrollout splintersModule
debrisMaker.height = 244

