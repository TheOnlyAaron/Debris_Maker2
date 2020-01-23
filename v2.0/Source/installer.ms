-- DEBRIS MAKER2 © COPYRIGHT 2014 - Aaron dabelow - aarondabelow@gmail.com - www.aarondabelow.com
--
-- This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.

try(destroyDialog rollout_DMinstaller)catch()

rollout rollout_DMinstaller "Debris Maker Installation" width:260 height:150
(
	button BTNinstall " Install Debris Maker " width: 250 height:40 align:#left offset:[-8,0]

	groupbox GRPoptions "Options" offset:[-8,0] width:250 height:45
	checkbox CHKcreateMenuItem "Add 'Debris Maker' to main menu" align:#left offset:[2,((GRPoptions.height * -1) + 15)] checked:true enabled:true

	button BTNremove " Un-install Debris Maker " width: 250 height:20 align:#left offset:[-8,12]
	button BTNonline " Check online for newer versions "width: 250 height:20 align:#left offset:[-8,0]
	
	function addDebrisMaker_mainMenu =
	(
		macroScript LaunchDebrisMaker category:"DebrisMaker2"
		(
			try(filein ((getdir #userscripts) + "\DebrisMaker2\DebrisMaker.ms"))catch()
		)

		theMainMenu = menuMan.getMainMenuBar() 
		theMenu = menuMan.createMenu "DebrisMaker2" 
		theSubMenu = menuMan.createSubMenuItem "DebrisMaker2" theMenu 
		theMainMenu.addItem theSubMenu (theMainMenu.numItems()+1) 
		theAction = menuMan.createActionItem "LaunchDebrisMaker" "DebrisMaker2"
		theMenu.addItem theAction (theMenu.numItems()+1) 
		menuMan.updateMenuBar()
	)

	function removeDebrisMaker_mainMenu =
	(
		try(
			toolsMenu = menuMan.getMainMenuBar()
			toolsMenuCount = toolsMenu.numItems()

			for i = 1 to toolsMenuCount do
			(
				fileMenu = (toolsMenu.getItem i).getTitle()
				if fileMenu == "DebrisMaker2" do
				(
					toolsMenu.removeItemByPosition  i
					menuMan.updateMenuBar()
				)
			)
		)catch()
	)

	function removeFiles =
	(
		hiddenDOSCommand ("rmdir /s /q \"" + ((getDir #userscripts) + @"\DebrisMaker2\") + "\"")
		hiddenDOSCommand ("del \"" +(( getdir #userMacros ) + @"\Macro_DebrisMaker2.mcr") + "\"")	
		hiddenDOSCommand ("del \"" +(( getdir #usericons ) + @"\DebrisMaker2_16i.bmp") + "\"")
		hiddenDOSCommand ("del \"" +(( getdir #usericons ) + @"\DebrisMaker2_16a.bmp") + "\"")
		hiddenDOSCommand ("del \"" +(( getdir #usericons ) + @"\DebrisMaker2_24i.bmp") + "\"")
		hiddenDOSCommand ("del \"" +(( getdir #usericons ) + @"\DebrisMaker2_24a.bmp") + "\"")
	)
	
	function installFiles =
	(
		tempDir = ((getdir #temp) + @"\" + "DebrisMaker2.0" + @"\" ) -- CHANGE THIS LINE TO MATCH FUTURE FOLDER NAMES
		copyMacroscriptsFolder = ("xcopy " + "\"" + tempDir + "MacroScripts" + "\"" + " " + "\"" + (getdir #userMacros) + @"\" + "\"" + " /E")
		copyScriptsFolder = ("xcopy " + "\"" + tempDir + "Scripts" + "\"" + " " + "\"" + (getDir #userscripts) + @"\" + "\""  + " /E")
		copyIconsFolder = ("xcopy " + "\"" + tempDir + @"UI_ln\Icons" + "\"" + " " + "\"" + (getDir #usericons) + @"\" + "\""  + " /E")
		
		hiddenDOSCommand copyMacroscriptsFolder
		hiddenDOSCommand copyScriptsFolder
		hiddenDOSCommand copyIconsFolder
		
		colorman.reInitIcons()
		filein (( getdir #userMacros ) + @"\Macro_DebrisMaker2.mcr")
	)
	
	function removeAll = 
	(
	removeFiles()
	removeDebrisMaker_mainMenu()
	)
	
	on BTNinstall pressed do 
	(
		removeAll()
		installFiles()
		
		if CHKcreateMenuItem.checked == true then addDebrisMaker_mainMenu()
		
		messagebox ("DebrisMaker2 Has been installed successfully!")
		destroyDialog rollout_DMinstaller
		filein ((getdir #userscripts) + "\DebrisMaker2\DebrisMaker.ms")
	)
	
	on BTNremove pressed do 
	(
		removeAll()		
		messagebox ("DebrisMaker2 Has been removed from your computer.")
	)
	
	on BTNonline pressed do 
	(
		shelllaunch "http://www.debrismaker.aarondabelow.com/" ""
	)
)
createDialog rollout_DMinstaller	