library Numberpad requires Frame

	globals
		private constant boolean DEBUG = true

		trigger NUMBERPAD_INPUT_TRIGGER = CreateTrigger()
		framehandle NUMBERPAD_CONTAINER = null
		framehandle array NUMBERPAD_BTN[11]
		framehandle NUMBERPAD_TEXT = null
		framehandle NUMBERPAD_PREFIX_INDICATOR = null
		framehandle NUMBERPAD_BTN_CLEAR	= null
		framehandle NUMBERPAD_BTN_SUMMIT = null
		framehandle NUMBERPAD_BTN_DELETE = null

		constant string NUMBERPAD_INPUT_DEFAULT = "0"
		constant integer NUMBERPAD_INPUT_LIMIT = 12

		trigger NUMBERPAD_SUMMIT_TRIGGER = CreateTrigger()
		player NUMBERPAD_SUMMIT_PLAYER = null
		string NUMBERPAD_SUMMIT_PREFIX = ""
		string NUMBERPAD_SUMMIT_VALUE = ""
		string NUMBERPAD_REFINED_PREFIX = ""
		string NUMBERPAD_REFINED_SUBFIX = ""
		boolean NUMBERPAD_SUMMIT_RESULT = false
	endglobals

	struct Numberpad

		player owner = null
		boolean visible_flag = false
		boolean allow_zero_input = false
		boolean initial = false
		implement ThisUI

		string prefix = ""
		string value = NUMBERPAD_INPUT_DEFAULT

		static method getPrefix takes nothing returns string
			return NUMBERPAD_SUMMIT_PREFIX
		endmethod

		static method getRefinedPrefix takes nothing returns string
			return NUMBERPAD_REFINED_PREFIX
		endmethod

		static method getRefinedSubfix takes nothing returns string
			return NUMBERPAD_REFINED_SUBFIX
		endmethod

		static method refinePrefix takes nothing returns nothing
			local integer i = 0
			set NUMBERPAD_REFINED_PREFIX = ""
			set NUMBERPAD_REFINED_SUBFIX = ""
			loop
				if i >= StringLength(NUMBERPAD_SUMMIT_PREFIX)-1 then
					set NUMBERPAD_REFINED_PREFIX = NUMBERPAD_SUMMIT_PREFIX
					exitwhen true
				elseif SubString(NUMBERPAD_SUMMIT_PREFIX,i,i+1) == "#" then
					set NUMBERPAD_REFINED_PREFIX = SubString(NUMBERPAD_SUMMIT_PREFIX,0,i)
					set NUMBERPAD_REFINED_SUBFIX = SubString(NUMBERPAD_SUMMIT_PREFIX,i+1,StringLength(NUMBERPAD_SUMMIT_PREFIX))
					exitwhen true
				else
					set i = i + 1
				endif
			endloop
			if DEBUG then
				call BJDebugMsg(NUMBERPAD_SUMMIT_PREFIX+", "+NUMBERPAD_REFINED_PREFIX+", "+NUMBERPAD_REFINED_SUBFIX)
			endif
		endmethod

		static method customSummit takes player p, string prefix, string value returns nothing
			set NUMBERPAD_SUMMIT_RESULT = false
			set NUMBERPAD_SUMMIT_PLAYER = null
			set NUMBERPAD_SUMMIT_PLAYER = p
			set NUMBERPAD_SUMMIT_PREFIX = prefix
			set NUMBERPAD_SUMMIT_VALUE = value
			call refinePrefix()
			call TriggerEvaluate(NUMBERPAD_SUMMIT_TRIGGER)
		endmethod

		method refreshDisplay takes nothing returns nothing
			if GetLocalPlayer() == .owner then
				if .initial then
					call BlzFrameSetText(NUMBERPAD_TEXT,"|cffffff00"+.value+"|r")
				else
					call BlzFrameSetText(NUMBERPAD_TEXT,.value)
				endif
			endif
		endmethod

		method setPrefix takes string s returns nothing
			set .prefix = s
			if GetLocalPlayer() == .owner then
				call BlzFrameSetText(NUMBERPAD_PREFIX_INDICATOR,"#"+.prefix)
			endif
		endmethod

		method setInitialValue takes string s returns nothing
			set .initial = true
			set .value = s
			call refreshDisplay()
		endmethod

		method add takes string s returns nothing
			call BJDebugMsg(s)
			if S2I(s) == 0 then
				if .allow_zero_input then
					if .initial then
						set .value = s
					else
						set .value = .value + s
					endif
				else
					if S2I(s) > 0 then
						set .value = .value + s
					endif
				endif
			else
				if .initial or (S2I(.value) == 0 and not .allow_zero_input) then
					set .value = s
				else
					set .value = .value + s
				endif
			endif
			set .value = SubString(.value,0,NUMBERPAD_INPUT_LIMIT)
			set .initial = false
			call refreshDisplay()
		endmethod

		method delete takes nothing returns nothing
			if .value == "" then
				return
			endif
			if StringLength(.value) <= 1 and not .allow_zero_input then
				set .value = NUMBERPAD_INPUT_DEFAULT
			else
				set .value = SubString(.value,0,StringLength(.value)-1)
			endif
			call refreshDisplay()
		endmethod

		method clear takes nothing returns nothing
			if .allow_zero_input then
				set .value = ""
			else
				set .value = NUMBERPAD_INPUT_DEFAULT
			endif
			call refreshDisplay()
		endmethod

		method allowZeroInput takes boolean b returns nothing
			set .allow_zero_input = b
			call clear()
		endmethod

		private method visibleForPlayer takes boolean flag returns nothing
			if GetLocalPlayer() == .owner then
				call BlzFrameSetVisible(NUMBERPAD_CONTAINER,flag)
			endif
			set .visible_flag = flag
		endmethod

		method setAbsPoint takes framepointtype pivot, real offset_x, real offset_y returns nothing
			if GetLocalPlayer() == .owner then
				call BlzFrameClearAllPoints(NUMBERPAD_CONTAINER)
				call BlzFrameSetAbsPointPixel(NUMBERPAD_CONTAINER,pivot,offset_x,offset_y)
			endif
		endmethod

		method setPoint takes framepointtype pivot, framehandle target, framepointtype relative, real offset_x, real offset_y returns nothing
			if GetLocalPlayer() == .owner then
				call BlzFrameClearAllPoints(NUMBERPAD_CONTAINER)
				call BlzFrameSetPointPixel(NUMBERPAD_CONTAINER,pivot,target,relative,offset_x,offset_y)
			endif
		endmethod

		method setProperty takes string prefix returns nothing
			set .prefix = prefix
		endmethod

		method close takes nothing returns boolean
			if .visible_flag then
				call setProperty("")
				call visibleForPlayer(false)
				return true
			endif
			return false
		endmethod

		method open takes string prefix returns nothing
			call setInitialValue(NUMBERPAD_INPUT_DEFAULT)
			call setPrefix(prefix)
			call visibleForPlayer(true)
		endmethod

		method openSimple takes string prefix returns nothing
			call open(prefix)
			call setPoint(FRAMEPOINT_CENTER,BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI,0),FRAMEPOINT_CENTER,0,0)
		endmethod

		method summit takes nothing returns nothing
			call customSummit(.owner,.prefix,.value)
			if NUMBERPAD_SUMMIT_RESULT then
				call close()
			endif
		endmethod

		static method create takes player p returns thistype
			local thistype this = allocate()
			set .owner = p
			call close()
			call clear()
			set thistype[p] = this
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			set THIS[GetPlayerId(.owner)] = 0
			set .owner = null
		endmethod

		static method genericInput takes nothing returns nothing
			local thistype this = 0
			local integer i = 0
			if GetLocalPlayer() == GetTriggerPlayer() then
				call BlzFrameSetEnable(BlzGetTriggerFrame(),false)
				call BlzFrameSetEnable(BlzGetTriggerFrame(),true)
			endif
			if BlzGetTriggerFrameEvent() != FRAMEEVENT_CONTROL_CLICK then
				return
			endif
			set this = thistype[GetTriggerPlayer()]
			loop
				exitwhen i >= 10
				if BlzGetTriggerFrame() == NUMBERPAD_BTN[i] then
					call add(I2S(i))
					return
				endif
				set i = i + 1
			endloop
			if BlzGetTriggerFrame() == NUMBERPAD_BTN[10] then
				if .value != NUMBERPAD_INPUT_DEFAULT then
					call add("00")
				endif
				return
			elseif BlzGetTriggerFrame() == NUMBERPAD_BTN_CLEAR then
				call clear()
				return
			elseif BlzGetTriggerFrame() == NUMBERPAD_BTN_SUMMIT then
				call summit()
				return
			elseif BlzGetTriggerFrame() == NUMBERPAD_BTN_DELETE then
				call delete()
				return
			endif
		endmethod

		static method init2 takes nothing returns nothing
			local integer i = 0
			set NUMBERPAD_CONTAINER = BlzCreateFrame("Numberpad",FRAME_TOOLTIP,0,0)
			set NUMBERPAD_TEXT = BlzGetFrameByName("NumberpadDisplayText",0)
			set NUMBERPAD_BTN[0] = BlzGetFrameByName("NumberpadButton0",0)
			set NUMBERPAD_BTN[1] = BlzGetFrameByName("NumberpadButton1",0)
			set NUMBERPAD_BTN[2] = BlzGetFrameByName("NumberpadButton2",0)
			set NUMBERPAD_BTN[3] = BlzGetFrameByName("NumberpadButton3",0)
			set NUMBERPAD_BTN[4] = BlzGetFrameByName("NumberpadButton4",0)
			set NUMBERPAD_BTN[5] = BlzGetFrameByName("NumberpadButton5",0)
			set NUMBERPAD_BTN[6] = BlzGetFrameByName("NumberpadButton6",0)
			set NUMBERPAD_BTN[7] = BlzGetFrameByName("NumberpadButton7",0)
			set NUMBERPAD_BTN[8] = BlzGetFrameByName("NumberpadButton8",0)
			set NUMBERPAD_BTN[9] = BlzGetFrameByName("NumberpadButton9",0)
			set NUMBERPAD_BTN[10] = BlzGetFrameByName("NumberpadButton00",0)
			set NUMBERPAD_BTN_SUMMIT = BlzGetFrameByName("NumberpadSummitButton",0)
			set NUMBERPAD_BTN_CLEAR = BlzGetFrameByName("NumberpadClearButton",0)
			set NUMBERPAD_BTN_DELETE = BlzGetFrameByName("NumberpadDeleteButton",0)
			set NUMBERPAD_PREFIX_INDICATOR = BlzCreateFrame("MyTextSmall",NUMBERPAD_CONTAINER,0,0)
			call BlzFrameSetPointPixel(NUMBERPAD_PREFIX_INDICATOR,FRAMEPOINT_TOPLEFT,NUMBERPAD_CONTAINER,FRAMEPOINT_TOPLEFT,16,-16)
			loop
				exitwhen i >= 11
				//! runtextmacro triggerRegisterFrameEventSimple("NUMBERPAD_INPUT_TRIGGER","NUMBERPAD_BTN[i]")
				set i = i + 1
			endloop
			//! runtextmacro triggerRegisterFrameEventSimple("NUMBERPAD_INPUT_TRIGGER","NUMBERPAD_BTN_SUMMIT")
			//! runtextmacro triggerRegisterFrameEventSimple("NUMBERPAD_INPUT_TRIGGER","NUMBERPAD_BTN_DELETE")
			//! runtextmacro triggerRegisterFrameEventSimple("NUMBERPAD_INPUT_TRIGGER","NUMBERPAD_BTN_CLEAR")
			call TriggerAddCondition(NUMBERPAD_INPUT_TRIGGER,function thistype.genericInput)
			call BlzFrameSetVisible(NUMBERPAD_CONTAINER,false)
		endmethod

		static method init takes nothing returns nothing
			local trigger t = CreateTrigger()
			call TriggerAddCondition(t,function thistype.init2)
			call TriggerEvaluate(t)
			call DestroyTrigger(t)
			set t = null
		endmethod

	endstruct

endlibrary