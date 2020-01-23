Struct DMfun
(
-- Settings Window
	function settings =
	(
		try(destroyDialog rollout_DMsettings)catch()
		
		rollout rollout_DMsettings "Settings" width:200 height:100
		(
			groupbox GRPsettings "Settings" pos:[10,5] width:180 height:86
			checkbox CHKautoloadmodule "Auto-load last used module" align:#left offset:[10,((GRPsettings.height * -1) + 15)]
			checkbox CHKrememberposition "Remember window position" align:#left offset:[10,0]
			checkbox CHKstartupcheck "Automatic online check" align:#left offset:[10,0] --enabled:false
			
			on rollout_DMsettings open do
			(
				CHKautoloadmodule.checked = DMfun.INIcheckModule()
				CHKrememberposition.checked = DMfun.INIcheckPos()
				CHKstartupcheck.checked = DMfun.INIcheckUpdate()
				
				SetDialogPos rollout_DMsettings ((GetDialogPos DebrisMaker) + [50,50])
			)
			
			on CHKautoloadmodule changed state do (	DMfun.INIenableModule CHKautoloadmodule.checked )
			on CHKrememberposition changed state do ( DMfun.INIenablePos CHKrememberposition.checked )
			on CHKstartupcheck changed state do ( DMfun.INIenableUpdate CHKstartupcheck.checked )
		)
		createDialog rollout_DMsettings	
	),
	
-- Online Check and Update Functions
	function onlineVersionAvailable arg = -- arg: release version available online
	(
		global newDebrisMakerVersioNumber = arg
		try(destroyDialog rollout_DMupdate)catch()
		
		rollout rollout_DMupdate "DebrisMaker update" width:200 height:80
		(
			label lab1 "" align:#left
			label lab2 "" align:#left
			button BTNgetUpdate " Newer version available! " width:180 height:30
			
			on rollout_DMupdate open do
			(
			lab1.text = (" Current version: " + DebrisMakerVerString )
			lab2.text = (" Version " + ( newDebrisMakerVersioNumber as string ) + " available")
			)
			
			on BTNgetUpdate pressed do (DMfun.GoWebsite();destroyDialog rollout_DMupdate)
		)
		createDialog rollout_DMupdate
		 
	),
	
	-- Prompt the user that their version is up to date
	function onlineVersionNoUpdate =
	(
		try(destroyDialog rollout_DMupdate)catch()
		
		rollout rollout_DMupdate "DebrisMaker update" width:200 height:80
		(
			label lab1 " "
			label lab2 "" align:#center
			label lab3 "is up to date"  align:#center
			
			on rollout_DMupdate open do
			(
			lab2.text = (" Current version " + DebrisMakerVerString )
			)
		)
		createDialog rollout_DMupdate
	),
	
	-- Read file from my website and check if it is more current than the current version
	function onlineVersionCompare silent =
	(
	try(
		if (internet.CheckConnection url:"http://www.aarondabelow.com/" force:true ) == true
		then
			(
			print "checking online for newer version"
			local onlineVersionStr = execute ((dotNetObject "System.Net.WebClient").downloadString @"http://www.debrismaker.aarondabelow.com/ver.dat")
			onlineVersion = execute onlineVersionStr
			if DebrisMakerVer < onlineVersion
			then
				(
				print "update available"
				DMfun.onlineVersionAvailable onlineVersion
				)
			else
				(
				print "current version up to date"
				if silent then() else( DMfun.onlineVersionNoUpdate())
				)
		)
		else(print "unable to establish internet connection")
	)catch(messagebox"DebrisMaker update error")
	),
	
	
-- INI File Functions
	-- Set the .ini file to the global variable to be used by the other .ini functions
	function INIinitalize = ( DebrisMakerINIfile = (DebrisMaker2InstallationDir + @"\DebrisMaker2\includes\settings.ini")),
	-- Set the position of the DebrisMaker dialog to the .ini file
	function INIwritePos = ( setinisetting DebrisMakerINIfile "WindowPosition" "WinPos" ((GetDialogPos DebrisMaker) as string)),
	-- Set "Remember window position" in the .ini
	function INIenablePos arg =	(setinisetting DebrisMakerINIfile "WindowPosition" "WinPosEnabled" (arg as string)),
	-- Get "Remember window position" in the .ini
	function INIcheckPos = ( execute (getinisetting DebrisMakerINIfile "WindowPosition" "WinPosEnabled")),
	-- Get the stored position from the .ini file and apply it to the DebrisMaker
	function INIgetPos = ( SetDialogPos DebrisMaker ( execute (getinisetting DebrisMakerINIfile "WindowPosition" "WinPos"))),
	-- Set the filename of the last loaded module to the .ini file
	function INIwriteModule arg = ( setinisetting DebrisMakerINIfile "Autoload" "AutoloadFile" arg),
	-- Set "Autoload last module" in the .ini
	function INIenableModule arg = ( setinisetting DebrisMakerINIfile "Autoload" "AutoloadEnabled" (arg as string)),
	-- Get "Autoload last module" in the .ini
	function INIcheckModule = ( execute (getinisetting DebrisMakerINIfile "Autoload" "AutoloadEnabled")),
	-- Get the last loaded file from the .ini and load it into the DebrisMaker
	function INIgetModule =	(try(filein (getinisetting DebrisMakerINIfile "Autoload" "AutoloadFile"))catch()),		
	-- Set "Autoload last module" in the .ini
	function INIenableUpdate arg = ( setinisetting DebrisMakerINIfile "OnlineCheck" "UpdateEnabled" (arg as string)),
	-- Get "Autoload last module" in the .ini
	function INIcheckUpdate = ( execute (getinisetting DebrisMakerINIfile "OnlineCheck" "UpdateEnabled")),
	-- Get the last loaded file from the .ini and load it into the DebrisMaker
	function INIgetVersion =	(execute (getinisetting DebrisMakerINIfile "OnlineCheck" "CurVersion")),
		
		
		
	
-- Dialog Window Functions
	-- Update the debris modules, and set the dropdown items
	function UpdateDropDown = 
	(
		debrisModules = getfiles (DebrisMaker2InstallationDir + "//DebrisMaker2//debrisModules//*.mse")
		debrisModuleNames=#()
		for i in 1 to (debrisModules.count) do (join debrisModuleNames #((" "+(getFilenameFile debrisModules[i]))))
		debrisMaker.dropDownListModules.items = debrisModuleNames
	),
	
	-- Set the max and min heights for the dialog windw
	function DialogHeightSet =
	(
		maxHeight = 700
		minHeight = 20
		if debrisMaker.height <= (minHeight - 1) then (debrisMaker.height = minHeight)else ()
		if debrisMaker.height >= (maxHeight + 1) then (debrisMaker.height = maxHeight)else ()
	),
	
	-- Remove all debris modules from the subrollout
	function ClearSubrollout =
	(
		for i in 1 to debrisMaker.theSubrollout.rollouts.count do
		(
			removeSubRollout debrisMaker.theSubrollout debrisMaker.theSubrollout.rollouts[debrisMaker.theSubrollout.rollouts.count]
		)
	),
	
-- Menubar Functions
	function readAboutFile =
	(
	aboutFile = openFile  (DebrisMaker2InstallationDir + @"\DebrisMaker2\about.txt") mode:#rt
	fileText = readDelimitedString aboutFile "~"
	close aboutFile
	fileText
	),
	
	-- Opens the modules directory in windows explorer
	function OpenModulesDir = (shelllaunch (DebrisMaker2InstallationDir + @"\DebrisMaker2\debrisModules\") ""),
	-- Calls the updater function to check for a newer version online
-- 	function CheckOnlineModules = ( shelllaunch "http://www.debrismaker.aarondabelow.com/download/" "" ),
	-- Opens up the DebrisMaker release versions in the default browser
	function GoWebsite = ( shelllaunch "http://www.debrismaker.aarondabelow.com/download/" "" ),
	-- Opens up the DebrisMaker online help in the default browser
	function Help =	( shelllaunch  "http://www.debrismaker.aarondabelow.com/" "" ),
	-- Opens up the DebrisMaker request feature subforum in the default browser
	function RequestFeature =( shelllaunch "http://aarondabelow.com/forum/viewforum.php?f=6" "" ),
	-- Opens up the DebrisMaker bugs subforum in the default browser
	function ReportBug = (shelllaunch "http://aarondabelow.com/forum/viewforum.php?f=7" ""),
	-- Creates the 'about' floater window, and places the information witin it.
	function AboutDM =
	(
		try(destroyDialog rollout_DMabout)catch()
		
		rollout rollout_DMabout "About Debris Maker" width:400 height:180
		(
			dotnetcontrol aboutTextbox "System.Windows.Forms.RichTextBox" width:(rollout_DMabout.width - 10) height:(rollout_DMabout.height - 10) align:#left pos:[5,5]
			
			on rollout_DMabout open do
			(
				aboutText = ("  Debris Maker " + DebrisMakerVerString + "\n © 2014 Aaron Dabelow \n" + DMfun.readAboutFile())
				aboutTextbox.multiline = true
				aboutTextbox.wordwrap = true
				aboutTextbox.ReadOnly = true
				aboutTextbox.DetectUrls = false
				aboutTextbox.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 50 50 50 --68 68 68
				aboutTextbox.ForeColor = (dotNetClass "System.Drawing.Color").FromArgb 200 200 200
				aboutTextbox.BorderStyle = none
				aboutTextbox.text = aboutText
			)
		)
		createDialog rollout_DMabout	
	)
)