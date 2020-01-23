-- Global variables
(
DebrisModules = #()
DebrisMakerVer = 2.0 
DebrisMakerVerString = ((DebrisMakerVer as string) + "")
)

-- Destroy the toobox if it exists already
try(destroyDialog DebrisMaker)catch()

-- Rollout for the Main Sidebar
rollout DebrisMaker ("Debris Maker v" + (DebrisMakerVerString as string))
	(
	dropDownList dropDownListModules items:#(" "," ") pos:[-1,0] width:202 height:25 tooltip: "Choose desired debris module from the dropdown"
	SubRollout theSubrollout "Subrollout" height:800 width:200 pos:[0,21]	
		
-- Event Handlers	
	-- Pick module from the dropdown
	on dropDownListModules selected i 	do(DMfun.ClearSubrollout();filein debrisModules[i];DMfun.INIwriteModule debrisModules[i])
	-- Resize the dialog window
	on DebrisMaker resized arg 			do (DMfun.DialogHeightSet()) 
	-- When the debris maker is opened
	on debrisMaker open	do
		(
		-- POISIONPILL
		(
-- 		onlineVersionStr = execute ((dotNetObject "System.Net.WebClient").downloadString @"http://www.debrismaker.aarondabelow.com/ver.dat")
-- 		if onlineVersionStr == "0.0" then(print "yes") else (messagebox ("beta is disabled, please update to current version");try(destroyDialog DebrisMaker)catch())
		)
			
		-- Loads the .ini file
		DMfun.INIinitalize() 			
		-- Sets the location of the dialog to the stored value, if set to
		if DMfun.INIcheckPos() then(DMfun.INIgetPos()) else()
		-- Loads the last used module, if set to
		if DMfun.INIcheckModule() then(DMfun.INIgetModule()) else()	
		-- Udates the dropdown with any available modules
		DMfun.UpdateDropDown()	
		-- Checks online for newer versions in silent mode
		if DMfun.INIcheckUpdate() then (DMfun.onlineVersionCompare true)else()
			
		)
	-- Write the position of the floater window to the .ini anytime the window is moved
	on DebrisMaker moved arg do (DMfun.INIwritePos())
	)

-- RCmenu for the sysmenu	
rcMenu rc_MainMenu
	(
	subMenu		"Modules"
		(
-- 		menuItem	MI_DebrisMakerWebsite	"DebrisMaker website"		enabled:true
		menuItem	MI_CheckOnlineModules	"Check online for more..."		enabled:true
		menuItem	MI_RefreshModulesDrop	"Refresh Modules Dropdown"	enabled:true
		menuItem	MI_OpenModulesDir 		"Open modules directory"	enabled:true
		)	
	subMenu		"Settings"
		(
		menuItem	MI_Settings				"Settings"					enabled:true
		)
	subMenu		"Info"
		(
		menuItem	MI_Help					"Online help..."			enabled:true
		menuItem	MI_RequestFeature		"Request a feature..."		enabled:true
		menuItem	MI_ReportBug			"Report a bug..."			enabled:true
		menuItem	MI_About				"About"						enabled:true
		)
	
-- 	on MI_DebrisMakerWebsite picked do (DMfun.GoWebsite())
	on MI_RefreshModulesDrop picked	do (DMfun.UpdateDropDown())
	on MI_OpenModulesDir picked		do (DMfun.OpenModulesDir())
	on MI_CheckOnlineModules picked	do (DMfun.onlineVersionCompare false) -- false is non-silent mode
	on MI_Settings picked 			do (DMfun.Settings())
	on MI_Help picked				do (DMfun.Help())
	on MI_RequestFeature picked 	do (DMfun.RequestFeature())
	on MI_ReportBug picked 			do (DMfun.ReportBug())
	on MI_About picked 				do (DMfun.AboutDM())
	)

-- Create the dialog
createDialog DebrisMaker 200 20 menu:rc_MainMenu style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing) lockWidth:true