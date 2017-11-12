--[[
	---------------------------------------------------------
    Battery Percentage application converts capacity used (mAh)
	to percentage-range 100-0% from full to empty battery. 
	
	Possibility to define a 3-position switch to select between
	3 different size packs. If no switch is defined only battery
	1 is used.
	
	Possibility to select audiofile to be announcent with or 
	without 3-times repeat when alarm occurs.
	
	Possibility to use different audiofile per battery.
	
	Voice announcement of battery percentage with switch
	
	Also app makes a LUA control (switch) that can be used as
	any other switch, voices, alarms etc.
	
	Telemetry-screne on main-screen with or without Battery-
	symbol. Symbol is realtime - Charge gets lower on use.
	
	Localisation-file has to be as /Apps/Lang/RCT-Batt.jsn
	
	French translation courtesy from Daniel Memim
	Italian translation courtesy from Fabrizio Zaini
	Czech and Slovak translations by Michal Hutnik
	---------------------------------------------------------
	Battery Percentage is part of RC-Thoughts Jeti Tools.
	---------------------------------------------------------
	Released under MIT-license by Tero @ RC-Thoughts.com 2017
	---------------------------------------------------------
--]]
collectgarbage()
--------------------------------------------------------------------------------
-- Locals for the application
local sens, sensid, senspa, telVal, trans
local res1, res2, res3, lbl1, lbl2, lbl3
local alarm1, alarm2, alarm3, Sw1, Sw2, Sw3
local alarm1Tr, alarm2Tr, alarm3Tr, tSet1, tSet2, tSet3
local rptSnd, sValid1, sValid2, sValid3, anGo, anSw
local vF1Played, vF2Played, vF3Played, battSym
local rptSndlist = {}
local battSymlist = {}
local sensorLalist = {"..."}
local sensorIdlist = {"..."}
local sensorPalist = {"..."}
local tSet1, tSet2, tSet3, anTime = 0,0,0,0
--------------------------------------------------------------------------------
-- Read translations
local function setLanguage()
    local lng=system.getLocale()
    local file = io.readall("Apps/Lang/RCT-Batt.jsn")
    local obj = json.decode(file)
    if(obj) then
        trans = obj[lng] or obj[obj.default]
    end
end
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
local function printTelem()
	if (battSym == 2) then
		local txtr,txtg,txtb
		local bgr,bgg,bgb = lcd.getBgColor()
		if (bgr+bgg+bgb)/3 >128 then
			txtr,txtg,txtb = 0,0,0
			else
			txtr,txtg,txtb = 255,255,255
		end	
		if (telVal == "-") then
			lcd.drawRectangle(5,9,26,55)
			lcd.drawFilledRectangle(12,6,12,4)
			lcd.drawText(145 - lcd.getTextWidth(FONT_MAXI,"-%"),10,"-%",FONT_MAXI)
			lcd.drawText(145 - lcd.getTextWidth(FONT_MINI,"RC-Thoughts.com"),54,"RC-Thoughts.com",FONT_MINI)
			--lcd.drawImage(1,51, ":graph")
			else
			lcd.drawRectangle(5,9,26,55)
			lcd.drawFilledRectangle(12,6,12,4)
			chgY = (64-(telVal*0.54))
			chgH = ((telVal*0.54))
			lcd.setColor(0,196,0)
			lcd.drawFilledRectangle(6,chgY,24,chgH)
			lcd.setColor(txtr,txtg,txtb)
			lcd.drawText(145 - lcd.getTextWidth(FONT_MAXI,string.format("%s%%",telVal)),10,string.format("%s%%",telVal),FONT_MAXI)
			lcd.drawText(145 - lcd.getTextWidth(FONT_MINI,"RC-Thoughts.com"),53,"RC-Thoughts.com",FONT_MINI)
			--lcd.drawImage(1,51, ":graph")
		end
		else
		if (telVal == "-") then
			lcd.drawText(145 - lcd.getTextWidth(FONT_MAXI,"-"),10,"-",FONT_MAXI)
			lcd.drawText(145 - lcd.getTextWidth(FONT_MINI,"RC-Thoughts.com"),54,"RC-Thoughts.com",FONT_MINI)
			lcd.drawImage(1,51, ":graph")
			else
			lcd.drawText(145 - lcd.getTextWidth(FONT_MAXI,string.format("%s%%",telVal)),10,string.format("%s%%",telVal),FONT_MAXI)
			lcd.drawText(145 - lcd.getTextWidth(FONT_MINI,"RC-Thoughts.com"),53,"RC-Thoughts.com",FONT_MINI)
			lcd.drawImage(1,51, ":graph")
		end
	end
end
--------------------------------------------------------------------------------
-- Store settings when changed by user
local function sensorChanged(value)
	sens=value
	system.pSave("sens",value)
	sensid = string.format("%s", sensorIdlist[sens])
	senspa = string.format("%s", sensorPalist[sens])
	if (sensid == "...") then
		sensid = 0
		senspa = 0
	end
	system.pSave("sensid",sensid)
	system.pSave("senspa",senspa)
end
local function battSymChanged(value)
	battSym=value
	system.pSave("battSym",value)
	-- Redraw telemetrywindow if label is changed by user
	system.registerTelemetry(1,lbl1,2,printTelem)
end
local function rptSndChanged(value)
	rptSnd=value
	system.pSave("rptSnd",value)
end
-----------------
local function lbl1Changed(value)
	lbl1=value
	system.pSave("lbl1",value)
	-- Redraw telemetrywindow if label is changed by user
	system.registerTelemetry(1,lbl1,2,printTelem)
end
local function lbl2Changed(value)
	lbl2=value
	system.pSave("lbl2",value)
	-- Redraw telemetrywindow if label is changed by user
	system.registerTelemetry(1,lbl2,2,printTelem)
end
local function lbl3Changed(value)
	lbl3=value
	system.pSave("lbl3",value)
	-- Redraw telemetrywindow if label is changed by user
	system.registerTelemetry(1,lbl3,2,printTelem)
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
-----------------
local function vF1Changed(value)
	vF1=value
	system.pSave("vF1",value)
end
local function vF2Changed(value)
	vF2=value
	system.pSave("vF2",value)
end
local function vF3Changed(value)
	vF3=value
	system.pSave("vF3",value)
end
-----------------
local function anSwChanged(value)
	anSw = value
	system.pSave("anSw",value)
end
--------------------------------------------------------------------------------
-- Draw the main form (Application inteface)
-- Initialize with page 1
local function initForm(subform)
	-- If we are on first page build the form for display
	if(subform == 1) then
		form.setButton(1,trans.btn1,HIGHLIGHTED)
		form.setButton(2,trans.btn2,ENABLED)
		form.setButton(3,trans.btn3,ENABLED)
		form.setButton(4,trans.btn4,ENABLED)
		
		form.addRow(1)
		form.addLabel({label="---     RC-Thoughts Jeti Tools      ---",font=FONT_BIG})
		
		form.addRow(1)
		form.addLabel({label=trans.Label,font=FONT_BOLD})
		
		form.addRow(2)
		form.addLabel({label=trans.Sensor})
		form.addSelectbox(sensorLalist,sens,true,sensorChanged)
		
		form.addRow(1)
		form.addLabel({label=trans.symSettings,font=FONT_BOLD})
		
		form.addRow(2)
		form.addLabel({label=trans.battSym,width=230})
		form.addSelectbox(battSymlist,battSym,false,battSymChanged)
		
		form.addRow(2)
		form.addLabel({label=trans.rpt,width=200})
		form.addSelectbox(rptSndlist,rptSnd,false,rptSndChanged)
		
		form.addRow(2)
		form.addLabel({label=trans.anSw,width=220})
		form.addInputbox(anSw,true,anSwChanged)
		
		form.addRow(1)
		form.addLabel({label="Powered by RC-Thoughts.com - v."..battVersion.." ",font=FONT_MINI, alignRight=true})
		
		form.setFocusedRow (1)
		formID = 1
		else
		-- If we are on second page build the form for display
		if(subform == 2) then
			form.setButton(1,trans.btn1,ENABLED)
			form.setButton(2,trans.btn2,HIGHLIGHTED)
			form.setButton(3,trans.btn3,ENABLED)
			form.setButton(4,trans.btn4,ENABLED)
			
			form.addRow(1)
			form.addLabel({label="---     RC-Thoughts Jeti Tools      ---",font=FONT_BIG})
			
			form.addRow(1)
			form.addLabel({label=trans.Settings1,font=FONT_BOLD})
			
			form.addRow(2)
			form.addLabel({label=trans.LabelW,width=160})
			form.addTextbox(lbl1,14,lbl1Changed)
			
			form.addRow(2)
			form.addLabel({label=trans.Switch})
			form.addInputbox(Sw1,true,SwChanged1)
			
			form.addRow(2)
			form.addLabel({label=trans.Capa,width=180})
			form.addIntbox(capa1,0,32767,0,0,1,capa1Changed)
			
			form.addRow(1)
			form.addLabel({label=trans.Alm,font=FONT_BOLD})
			
			form.addRow(2)
			form.addLabel({label=trans.AlmVal})
			form.addIntbox(alarm1,0,32767,0,0,1,alarm1Changed)
			
			form.addRow(2)
			form.addLabel({label=trans.selAudio})
			form.addAudioFilebox(vF1,vF1Changed)
			
			form.addRow(1)
			form.addLabel({label="Powered by RC-Thoughts.com - v."..battVersion.." ",font=FONT_MINI, alignRight=true})
			
			form.setFocusedRow (1)
			formID = 2
			else
			-- If we are on third page build the form for display
			if(subform == 3) then
				form.setButton(1,trans.btn1,ENABLED)
				form.setButton(2,trans.btn2,ENABLED)
				form.setButton(3,trans.btn3,HIGHLIGHTED)
				form.setButton(4,trans.btn4,ENABLED)
				
				form.addRow(1)
				form.addLabel({label="---     RC-Thoughts Jeti Tools      ---",font=FONT_BIG})
				
				form.addRow(1)
				form.addLabel({label=trans.Settings2,font=FONT_BOLD})
				
				form.addRow(2)
				form.addLabel({label=trans.LabelW,width=160})
				form.addTextbox(lbl2,14,lbl2Changed)
				
				form.addRow(2)
				form.addLabel({label=trans.Switch})
				form.addInputbox(Sw2,true,SwChanged2)
				
				form.addRow(2)
				form.addLabel({label=trans.Capa,width=180})
				form.addIntbox(capa2,0,32767,0,0,1,capa2Changed)
				
				form.addRow(1)
				form.addLabel({label=trans.Alm,font=FONT_BOLD})
				
				form.addRow(2)
				form.addLabel({label=trans.AlmVal})
				form.addIntbox(alarm2,0,32767,0,0,1,alarm2Changed)
				
				form.addRow(2)
				form.addLabel({label=trans.selAudio})
				form.addAudioFilebox(vF2,vF2Changed)
				
				form.addRow(1)
				form.addLabel({label="Powered by RC-Thoughts.com - v."..battVersion.." ",font=FONT_MINI, alignRight=true})
				
				form.setFocusedRow (1)
				formID = 3
				else
				-- If we are on fourth page build the form for display
				if(subform == 4) then
					form.setButton(1,trans.btn1,ENABLED)
					form.setButton(2,trans.btn2,ENABLED)
					form.setButton(3,trans.btn3,ENABLED)
					form.setButton(4,trans.btn4,HIGHLIGHTED)
					
					form.addRow(1)
					form.addLabel({label="---     RC-Thoughts Jeti Tools      ---",font=FONT_BIG})
					
					form.addRow(1)
					form.addLabel({label=trans.Settings3,font=FONT_BOLD})
					
					form.addRow(2)
					form.addLabel({label=trans.LabelW,width=160})
					form.addTextbox(lbl3,14,lbl3Changed)
					
					form.addRow(2)
					form.addLabel({label=trans.Switch})
					form.addInputbox(Sw3,true,SwChanged3)
					
					form.addRow(2)
					form.addLabel({label=trans.Capa,width=180})
					form.addIntbox(capa3,0,32767,0,0,1,capa3Changed)
					
					form.addRow(1)
					form.addLabel({label=trans.Alm,font=FONT_BOLD})
					
					form.addRow(2)
					form.addLabel({label=trans.AlmVal})
					form.addIntbox(alarm3,0,32767,0,0,1,alarm3Changed)
					
					form.addRow(2)
					form.addLabel({label=trans.selAudio})
					form.addAudioFilebox(vF3,vF3Changed)
					
					form.addRow(1)
					form.addLabel({label="Powered by RC-Thoughts.com - v."..battVersion.." ",font=FONT_MINI, alignRight=true})
					
					form.setFocusedRow (1)
					formID = 4
				end
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
	if(key==KEY_4) then
		form.reinit(4)
	end
end
---------------------------------------------------------------------------------
-- Runtime functions, read sensor, convert to percentage, keep percentage between 0 and 100 at all times
-- Display on main screen the selected battery and values, take care of correct alarm-value
local function loop()
	local sensor = system.getSensorByID(sensid, senspa)
	local Sw1, Sw2, Sw3, anGo = system.getInputsVal(Sw1, Sw2, Sw3, anSw)
	local tTime = system.getTime()
	-----------------
	if ((Sw1 == nil or Sw1 == 0 ) and (Sw2 == nil or Sw2 == 0) and (Sw3 == nil or Sw3 == 0)) then
		system.registerTelemetry(1,lbl1,2,printTelem)
		if(sensor and sensor.valid) then
			if(tSet1 == 0) then
				tCur1 = tTime
				tStr1 = tTime + 5
				tSet1 = 1
				else
				tCur1 = tTime
			end
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
				system.setControl(10,0,0,0)
				vF1played = 0
				tStr1 = 0
				else
				if(res1 <= alarm1) then
					if(tStr1 <= tCur1 and tSet1 == 1) then
						system.setControl(10,1,0,0)
						if(vF1played == 0 or vF1played == nil and vF1 ~= "...") then
							if (rptSnd == 2) then
								system.playFile(vF1,AUDIO_AUDIO_QUEUE)
								system.playFile(vF1,AUDIO_AUDIO_QUEUE)
								system.playFile(vF1,AUDIO_AUDIO_QUEUE)
								vF1played = 1
								else
								system.playFile(vF1,AUDIO_AUDIO_QUEUE)
								vF1played = 1
							end
						end
					end
					else
					system.setControl(10,0,0,0)
					vF1played = 0
				end
			end
			else
			telVal = "-"
			vF1played = 0
			tSet1 = 0
		end
	end
	if (Sw1 == 1) then
		system.registerTelemetry(1,lbl1,2,printTelem)
		if(sensor and sensor.valid) then
			if(tSet1 == 0) then
				tCur1 = tTime
				tStr1 = tTime + 5
				tSet1 = 1
				else
				tCur1 = tTime
			end
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
				system.setControl(10,0,0,0)
				vF1played = 0
				tStr1 = 0
				else
				if(res1 <= alarm1) then
					if(tStr1 <= tCur1 and tSet1 == 1) then
						system.setControl(10,1,0,0)
						if(vF1played == 0 or vF1played == nil and vF1 ~= "...") then
							if (rptSnd == 2) then
								system.playFile(vF1,AUDIO_AUDIO_QUEUE)
								system.playFile(vF1,AUDIO_AUDIO_QUEUE)
								system.playFile(vF1,AUDIO_AUDIO_QUEUE)
								vF1played = 1
								else
								system.playFile(vF1,AUDIO_AUDIO_QUEUE)
								vF1played = 1
							end
						end
					end
					else
					system.setControl(10,0,0,0)
					vF1played = 0
				end
			end
			else
			telVal = "-"
			vF1played = 0
			tSet1 = 0
		end
	end
	-----------------
	if (Sw2 == 1) then
		system.registerTelemetry(1,lbl2,2,printTelem)
		if(sensor and sensor.valid) then
			if(tSet2 == 0) then
				tCur2 = tTime
				tStr2 = tTime + 5
				tSet2 = 1
				else
				tCur2 = tTime
			end
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
				system.setControl(10,0,0,0)
				vF2played = 0
				tStr2 = 0
				else
				if(res2 <= alarm2) then
					if(tStr2 <= tCur2 and tSet2 == 1) then
						system.setControl(10,1,0,0)
						if(vF2played == 0 or vF2played == nil and vF2 ~= "...") then
							if (rptSnd == 2) then
								system.playFile(vF2,AUDIO_AUDIO_QUEUE)
								system.playFile(vF2,AUDIO_AUDIO_QUEUE)
								system.playFile(vF2,AUDIO_AUDIO_QUEUE)
								vF2played = 1
								else
								system.playFile(vF2,AUDIO_AUDIO_QUEUE)
								vF2played = 1
							end
						end
					end
					else
					system.setControl(10,0,0,0)
					vF2played = 0
				end
			end
			else
			telVal = "-"
			vF2played = 0
			tSet2 = 0
		end
	end
	-----------------
	if (Sw3 == 1) then
		system.registerTelemetry(1,lbl3,2,printTelem)
		if(sensor and sensor.valid) then
			if(tSet3 == 0) then
				tCur3 = tTime
				tStr3 = tTime + 5
				tSet3 = 1
				else
				tCur3 = tTime
			end
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
				system.setControl(10,0,0,0)
				vF3played = 0
				tStr3 = 0
				else
				if(res3 <= alarm3) then
					if(tStr3 <= tCur3 and tSet3 == 1) then
						system.setControl(10,1,0,0)
						if(vF3played == 0 or vF3played == nil and vF3 ~= "...") then
							if (rptSnd == 2) then
								system.playFile(vF3,AUDIO_AUDIO_QUEUE)
								system.playFile(vF3,AUDIO_AUDIO_QUEUE)
								system.playFile(vF3,AUDIO_AUDIO_QUEUE)
								vF3played = 1
								else
								system.playFile(vF3,AUDIO_AUDIO_QUEUE)
								vF3played = 1
							end
						end
					end
					else
					system.setControl(10,0,0,0)
					vF3played = 0
				end
			end
			else
			telVal = "-"
			vF3played = 0
			tSet3 = 0
		end
	end
	if(anGo == 1 and telVal ~= "-" and anTime < tTime) then
		system.playNumber(telVal, 0, "%", trans.anCap)
		anTime = tTime + 3
	end
    collectgarbage()
end
--------------------------------------------------------------------------------
-- Application initialization
local function init()
	telVal = "-"
	sens = system.pLoad("sens",0)
	sensid = system.pLoad("sensid",0)
	senspa = system.pLoad("senspa",0)
	battSym = system.pLoad("battSym",2)
	lbl1 = system.pLoad("lbl1",trans.Batt1)
	lbl2 = system.pLoad("lbl2",trans.Batt2)
	lbl3 = system.pLoad("lbl3",trans.Batt3)
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
	vF1 = system.pLoad("vF1","...")
	vF2 = system.pLoad("vF2","...")
	vF3 = system.pLoad("vF3","...")
	rptSnd = system.pLoad("rptSnd",1)
	table.insert(rptSndlist,trans.neg)
	table.insert(rptSndlist,trans.pos)
	table.insert(battSymlist,trans.neg)
	table.insert(battSymlist,trans.pos)
	anSw = system.pLoad("anSw")
	system.registerTelemetry(1,lbl1,2,printTelem)
	system.registerControl(10,trans.battCtrl,trans.battSw)
	system.registerForm(1,MENU_APPS,trans.appName,initForm,keyPressed)
end
--------------------------------------------------------------------------------
battVersion = "2.4"
setLanguage()
collectgarbage()
return {init=init, loop=loop, author="RC-Thoughts", version=battVersion, name=trans.appName}