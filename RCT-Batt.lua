--[[
	---------------------------------------------------------
	
    Battery Percentage application converts capacity used (mAh)
	to percentage-range 100-0% from full to empty battery. 
	
	Possibility to define a 3-position switch to select between
	3 different size packs. If no switch is defined only battery
	1 is used.
	
	Also app makes a LUA control (switch) that can be used as
	any other switch, voices, alarms etc.
	
	---------------------------------------------------------
	Battery Percentage is part of RC-Thoughts Jeti Tools.
	---------------------------------------------------------
	Released under MIT-license by Tero @ RC-Thoughts.com 2016
	---------------------------------------------------------
--]]
--------------------------------------------------------------------------------
-- Locals for the application
local sens, sensid, senspa, id, param, telVal
local res1, res2, res3, lbl1, lbl2, lbl3
local alarm1, alarm2, alarm3, Sw1, Sw2, Sw3
local alarm1Tr, alarm2Tr, alarm3Tr
local sensorLalist = {"..."}
local sensorIdlist = {"..."}
local sensorPalist = {"..."}
--------------------------------------------------------------------------------
-- Translations
local transSensor = {en = "Select sensor", de = "Wählen Sensor"}
local transSettings1 = {en = "Battery 1 Settings", de = "Batterie 1 Einstellungen"}
local transSettings2 = {en = "Battery 2 Settings", de = "Batterie 2 Einstellungen"}
local transSettings3 = {en = "Battery 3 Settings", de = "Batterie 3 Einstellungen"}
local transLabel = {en = "Sensor", de = "Sensor"}
local transLabelW = {en = "Window Label", de = "Fenster Etikett"}
local transSwitch1 = {en = "Battery Switch", de = "Batterie Schalter"}
local transSwitch2 = {en = "Battery Switch", de = "Batterie Schalter"}
local transSwitch3 = {en = "Battery Switch", de = "Batterie Schalter"}
local transCapa = {en = "Battery Capacity (mAh)", de = "Batteriekapazität (mAh)"}
local transAlm = {en = "Alarm", de = "Alarm"}
local transAlmVal = {en = "Alarm Value (%)", de = "Alarmwert (%)"}
--------------------------------------------------------------------------------
-- Read available sensors for user to select
local sensors = system.getSensors()
for i,sensor in ipairs(sensors) do
	if (sensor.label ~= "") then
		table.insert(sensorLalist, string.format("%s", sensor.label))
		table.insert(sensorIdlist, string.format("%s", sensor.id))
		table.insert(sensorPalist, string.format("%s", sensor.param))
	end
end
--------------------------------------------------------------------------------
-- Draw the telemetry windows
local function printTelemetry()
	if (telVal == "-") then
		lcd.drawText(145 - lcd.getTextWidth(FONT_MAXI,"-"),10,"-",FONT_MAXI)
		lcd.drawText(145 - lcd.getTextWidth(FONT_MINI,"RC-Thoughts.com"),54,"RC-Thoughts.com",FONT_MINI)
		lcd.drawImage(1,51, ":graph")
		else
		lcd.drawText(145 - lcd.getTextWidth(FONT_MAXI,string.format("%s%%", telVal)),10,string.format("%s%%", telVal),FONT_MAXI)
		lcd.drawText(145 - lcd.getTextWidth(FONT_MINI,"RC-Thoughts.com"),54,"RC-Thoughts.com",FONT_MINI)
		lcd.drawImage(1,51, ":graph")
	end
end
--------------------------------------------------------------------------------
-- Store settings when changed by user
local function sensorChanged(value)
	sens=value
	sensid=value
	senspa=value
	system.pSave("sens",value)
	system.pSave("sensid",value)
	system.pSave("senspa",value)
	id = string.format("%s", sensorIdlist[sensid])
	param = string.format("%s", sensorPalist[senspa])
	if (id == "...") then
		id = 0
		param = 0
	end
	system.pSave("id", id)
	system.pSave("param", param)
end
-----------------
local function lbl1Changed(value)
	lbl1=value
	system.pSave("lbl1",value)
	-- Redraw telemetrywindow if label is changed by user
	system.registerTelemetry(1,lbl1,2,printTelemetry)
end
local function lbl2Changed(value)
	lbl2=value
	system.pSave("lbl2",value)
	-- Redraw telemetrywindow if label is changed by user
	system.registerTelemetry(1,lbl2,2,printTelemetry)
end
local function lbl3Changed(value)
	lbl3=value
	system.pSave("lbl3",value)
	-- Redraw telemetrywindow if label is changed by user
	system.registerTelemetry(1,lbl3,2,printTelemetry)
end
-----------------
local function SwChanged1(value)
	Sw1 = value
	system.pSave("Sw1",value)
end
local function SwChanged2(value)
	Sw2 = value
	system.pSave("Sw2",value)
end
local function SwChanged3(value)
	Sw3 = value
	system.pSave("Sw3",value)
end
-----------------
local function capa1Changed(value)
	capa1=value
	system.pSave("capa1",value)
end
local function capa2Changed(value)
	capa2=value
	system.pSave("capa2",value)
end
local function capa3Changed(value)
	capa3=value
	system.pSave("capa3",value)
end
-----------------
local function alarm1Changed(value)
	alarm1=value
	system.pSave("alarm1",value)
	alarm1Tr = string.format("%.1f", alarm1)
	system.pSave("alarm1Tr", alarm1Tr)
end
local function alarm2Changed(value)
	alarm2=value
	system.pSave("alarm2",value)
	alarm2Tr = string.format("%.1f", alarm2)
	system.pSave("alarm2Tr", alarm2Tr)
end
local function alarm3Changed(value)
	alarm3=value
	system.pSave("alarm3",value)
	alarm3Tr = string.format("%.1f", alarm3)
	system.pSave("alarm3Tr", alarm3Tr)
end
--------------------------------------------------------------------------------
-- Draw the main form (Application inteface)
-- Initialize with page 1
local function initForm(subform)
	local locale = system.getLocale()
	local transSensor = transSensor[locale] or transSensor["en"]
	local transSettings1 = transSettings1[locale] or transSettings1["en"]
	local transSettings2 = transSettings2[locale] or transSettings2["en"]
	local transSettings3 = transSettings3[locale] or transSettings3["en"]
	local transLabel = transLabel[locale] or transLabel["en"]
	local transLabelW = transLabelW[locale] or transLabelW["en"]
	local transSwitch1 = transSwitch1[locale] or transSwitch1["en"]
	local transSwitch2 = transSwitch2[locale] or transSwitch2["en"]
	local transSwitch3 = transSwitch3[locale] or transSwitch3["en"]
	local transCapa = transCapa[locale] or transCapa["en"]
	local transAlm = transAlm[locale] or transAlm["en"]
	local transAlmVal = transAlmVal[locale] or transAlmVal["en"]
	----
	if(subform == 1) then
		form.setButton(1,"Batt1",HIGHLIGHTED)
		form.setButton(2,"Batt2",ENABLED)
		form.setButton(3,"Batt3",ENABLED)
		
		form.addRow(1)
		form.addLabel({label="---     RC-Thoughts Jeti Tools      ---",font=FONT_BIG})
		
		form.addRow(1)
		form.addLabel({label=transLabel,font=FONT_BOLD})
		
		form.addRow(2)
		form.addLabel({label=transSensor})
		form.addSelectbox(sensorLalist,sens,true,sensorChanged)
		
		form.addRow(1)
		form.addLabel({label=transSettings1,font=FONT_BOLD})
		
		form.addRow(2)
		form.addLabel({label=transLabelW,width=160})
		form.addTextbox(lbl1,14,lbl1Changed)
		
		form.addRow(2)
		form.addLabel({label=transSwitch1})
		form.addInputbox(Sw1,true,SwChanged1)
		
		form.addRow(2)
		form.addLabel({label=transCapa,width=180})
		form.addIntbox(capa1,0,32767,0,0,1,capa1Changed)
		
		form.addRow(1)
		form.addLabel({label=transAlm,font=FONT_BOLD})
		
		form.addRow(2)
		form.addLabel({label=transAlmVal})
		form.addIntbox(alarm1,0,32767,0,0,1,alarm1Changed)
		
		form.addRow(1)
		form.addLabel({label="Powered by RC-Thoughts.com",font=FONT_MINI, alignRight=true})	
		
		form.setFocusedRow (1)
		formID = 1
		
		else
		-- If we are on second page build the form for display
		if(subform == 2) then
			form.setButton(1,"Batt1",ENABLED)
			form.setButton(2,"Batt2",HIGHLIGHTED)
			form.setButton(3,"Batt3",ENABLED)
			
			form.addRow(1)
			form.addLabel({label="---     RC-Thoughts Jeti Tools      ---",font=FONT_BIG})
			
			form.addRow(1)
			form.addLabel({label=transSettings2,font=FONT_BOLD})
			
			form.addRow(2)
			form.addLabel({label=transLabelW,width=160})
			form.addTextbox(lbl2,14,lbl2Changed)
			
			form.addRow(2)
			form.addLabel({label=transSwitch2})
			form.addInputbox(Sw2,true,SwChanged2)
			
			form.addRow(2)
			form.addLabel({label=transCapa,width=180})
			form.addIntbox(capa2,0,32767,0,0,1,capa2Changed)
			
			form.addRow(1)
			form.addLabel({label=transAlm,font=FONT_BOLD})
			
			form.addRow(2)
			form.addLabel({label=transAlmVal})
			form.addIntbox(alarm2,0,32767,0,0,1,alarm2Changed)
			
			form.addRow(1)
			form.addLabel({label="Powered by RC-Thoughts.com",font=FONT_MINI, alignRight=true})	
			
			form.setFocusedRow (1)
			formID = 2
			
			else
			-- If we are on third page build the form for display
			if(subform == 3) then
				form.setButton(1,"Batt1",ENABLED)
				form.setButton(2,"Batt2",ENABLED)
				form.setButton(3,"Batt3",HIGHLIGHTED)
				
				form.addRow(1)
				form.addLabel({label="---     RC-Thoughts Jeti Tools      ---",font=FONT_BIG})
				
				form.addRow(1)
				form.addLabel({label=transSettings3,font=FONT_BOLD})
				
				form.addRow(2)
				form.addLabel({label=transLabelW,width=160})
				form.addTextbox(lbl3,14,lbl3Changed)
				
				form.addRow(2)
				form.addLabel({label=transSwitch3})
				form.addInputbox(Sw3,true,SwChanged3)
				
				form.addRow(2)
				form.addLabel({label=transCapa,width=180})
				form.addIntbox(capa3,0,32767,0,0,1,capa3Changed)
				
				form.addRow(1)
				form.addLabel({label=transAlm,font=FONT_BOLD})
				
				form.addRow(2)
				form.addLabel({label=transAlmVal})
				form.addIntbox(alarm3,0,32767,0,0,1,alarm3Changed)
				
				form.addRow(1)
				form.addLabel({label="Powered by RC-Thoughts.com",font=FONT_MINI, alignRight=true})	
				
				form.setFocusedRow (1)
				formID = 3
			end
		end
	end
end
--------------------------------------------------------------------------------
-- Re-init correct page if navigation buttons are pressed
local function keyPressed(key)
	if(key==KEY_1) then
		form.reinit(1)
	end
	if(key==KEY_2) then
		form.reinit(2)
	end
	if(key==KEY_3) then
		form.reinit(3)
	end
end
---------------------------------------------------------------------------------
-- Runtime functions, read sensor, convert to percentage, keep percentage between 0 and 100 at all times
-- Display on main screen the selected battery and values, take care of correct alarm-value
local function loop()
	local sensor = system.getSensorByID(id, param)
	local Sw1, Sw2, Sw3 = system.getInputsVal(Sw1, Sw2, Sw3)
	-----------------
	if (Sw1 == nil and Sw2 == nil and Sw3 == nil) then
		system.registerTelemetry(1,lbl1,2,printTelemetry)
		if(sensor and sensor.valid) then
			res1 = (((capa1 - sensor.value) * 100) / capa1) 
			if (res1 < 0) then
				res1 = 0
				else
				if (res1 > 100) then
					res1 = 100
				end
			end
			telVal = string.format("%.1f", res1)
			if(alarm1Tr == 0) then
				system.setControl(10,0,0,1)
				else
				if (telVal <= alarm1Tr) then
					system.setControl(10,1,0,1)
					else
					system.setControl(10,0,0,1)
				end
			end
			else
			telVal = "-"
		end
	end
	if (Sw1 == 1) then
		system.registerTelemetry(1,lbl1,2,printTelemetry)
		if(sensor and sensor.valid) then
			res1 = (((capa1 - sensor.value) * 100) / capa1) 
			if (res1 < 0) then
				res1 = 0
				else
				if (res1 > 100) then
					res1 = 100
				end
			end
			telVal = string.format("%.1f", res1)
			if(alarm1Tr == 0) then
				system.setControl(10,0,0,1)
				else
				if (telVal <= alarm1Tr) then
					system.setControl(10,1,0,1)
					else
					system.setControl(10,0,0,1)
				end
			end
			else
			telVal = "-"
		end
	end
	-----------------
	if (Sw2 == 1) then
		system.registerTelemetry(1,lbl2,2,printTelemetry)
		if(sensor and sensor.valid) then
			res2 = (((capa2 - sensor.value) * 100) / capa2) 
			if (res2 < 0) then
				res2 = 0
				else
				if (res2 > 100) then
					res2 = 100
				end
			end
			telVal = string.format("%.1f", res2)
			if(alarm2Tr == 0) then
				system.setControl(10,0,0,1)
				else
				if (telVal <= alarm2Tr) then
					system.setControl(10,1,0,1)
					else
					system.setControl(10,0,0,1)
				end
			end
			else
			telVal = "-"
		end
	end
	-----------------
	if (Sw3 == 1) then
		system.registerTelemetry(1,lbl3,2,printTelemetry)
		if(sensor and sensor.valid) then
			res3 = (((capa3 - sensor.value) * 100) / capa3) 
			if (res3 < 0) then
				res3 = 0
				else
				if (res3 > 100) then
					res3 = 100
				end
			end
			telVal = string.format("%.1f", res3)
			if(alarm3Tr == 0) then
				system.setControl(10,0,0,1)
				else
				if (telVal <= alarm3Tr) then
					system.setControl(10,1,0,1)
					else
					system.setControl(10,0,0,1)
				end
			end
			else
			telVal = "-"
		end
	end
end
--------------------------------------------------------------------------------Batterie 1
-- Application initialization
local function init()
	local locale = system.getLocale()
	local transControl = {en = "Battery Alarm", de = "Batterie-Warnung"}
	local transAppName = {en = "Battery Percentage", de = "Batterie-Prozentsatz"}
	local transBatt1 = {en = "Battery 1", de = "Batterie 1"}
	local transBatt2 = {en = "Battery 2", de = "Batterie 2"}
	local transBatt3 = {en = "Battery 3", de = "Batterie 3"}
	local transControl = transControl[locale] or transControl["en"]
	local transAppName = transAppName[locale] or transAppName["en"]
	local transBatt1 = transBatt1[locale] or transBatt1["en"]
	local transBatt2 = transBatt2[locale] or transBatt2["en"]
	local transBatt3 = transBatt3[locale] or transBatt3["en"]
	local appName = transAppName
	telVal = "-"
	sens = system.pLoad("sens",0)
	sensid = system.pLoad("sensid",0)
	senspa = system.pLoad("senspa",0)
	id = system.pLoad("id",0)
	param = system.pLoad("param",0)
	lbl1 = system.pLoad("lbl1",transBatt1)
	lbl2 = system.pLoad("lbl2",transBatt2)
	lbl3 = system.pLoad("lbl3",transBatt3)
	capa1 = system.pLoad("capa1",0)
	capa2 = system.pLoad("capa2",0)
	capa3 = system.pLoad("capa3",0)
	alarm1 = system.pLoad("alarm1",0)
	alarm2 = system.pLoad("alarm2",0)
	alarm3 = system.pLoad("alarm3",0)
	alarm1Tr = system.pLoad("alarm1Tr",0)
	alarm2Tr = system.pLoad("alarm2Tr",0)
	alarm3Tr = system.pLoad("alarm3Tr",0)
	Sw1 = system.pLoad("Sw1")
	Sw2 = system.pLoad("Sw2")
	Sw3 = system.pLoad("Sw3")
	system.registerTelemetry(1,lbl1,2,printTelemetry)
	system.registerControl (10, transControl, "B01")
	system.registerForm(1,MENU_APPS,appName,initForm,keyPressed)
end
--------------------------------------------------------------------------------
return {init=init, loop=loop, author="RC-Thoughts", version="1.1", name=appName} 					