library Numberpad requires Frame

	globals
		trigger NUMBERPAD_INPUT_TRIGGER = CreateTrigger()
		framehandle NUMBERPAD_CONTAINER = null
		framehandle array NUMBERPAD_BTN[11]
		framehandle NUMBERPAD_TEXT = null
		framehandle NUMBERPAD_BTN_CLEAR	= null
		framehandle NUMBERPAD_BTN_SUMMIT = null
		framehandle NUMBERPAD_BTN_DELETE = null

		constant string NUMBERPAD_INPUT_DEFAULT = "0"
		constant integer NUMBERPAD_INPUT_LIMIT = 12

		trigger NUMBERPAD_SUMMIT_TRIGGER = CreateTrigger()
		player NUMBERPAD_SUMMIT_PLAYER = null
		string NUMBERPAD_SUMMIT_PREFIX = ""
		string NUMBERPAD_SUMMIT_SUBFIX = ""
		string NUMBERPAD_SUMMIT_VALUE = ""
		boolean NUMBERPAD_SUMMIT_RESULT = false
	endglobals

	struct Numberpad

		player owner = null
		boolean visible_flag = false
		boolean allow_input_zero = false
		implement ThisUI

		string prefix = ""
		string subfix = ""
		string value = NUMBERPAD_INPUT_DEFAULT

		static method operator [] takes player p returns thistype
			return THIS[GetPlayerId(p)]
		endmethod

		method refreshDisplay takes nothing returns nothing
			if GetLocalPlayer() == .owner then
				call BlzFrameSetText(NUMBERPAD_TEXT,.value)
			endif
		endmethod

		method add takes string s returns nothing
			if .value == NUMBERPAD_INPUT_DEFAULT and not .allow_input_zero then
				set .value = s
			else
				set .value = .value + s
			endif
			set .value = SubString(.value,0,NUMBERPAD_INPUT_LIMIT)
			call refreshDisplay()
		endmethod

		method delete takes nothing returns nothing
			if .value == "" then
				return
			endif
			if StringLength(.value) <= 1 and not .allow_input_zero then
				set .value = NUMBERPAD_INPUT_DEFAULT
			else
				set .value = SubString(.value,0,StringLength(.value)-1)
			endif
			call refreshDisplay()
		endmethod

		method clear takes nothing returns nothing
			if .allow_input_zero then
				set .value = ""
			else
				set .value = NUMBERPAD_INPUT_DEFAULT
			endif
			call refreshDisplay()
		endmethod

		method allowInputZero takes boolean b returns nothing
			set .allow_input_zero = b
			call clear()
		endmethod

		private method visibleForPlayer takes boolean flag returns nothing
			if GetLocalPlayer() == .owner then
				call BlzFrameSetVisible(NUMBERPAD_CONTAINER,flag)
				call clear()
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

		method setProperty takes string prefix, string subfix returns nothing
			set .prefix = prefix
			set .subfix = subfix
		endmethod

		method close takes nothing returns boolean
			if .visible_flag then
				call setProperty("","")
				call visibleForPlayer(false)
				return true
			endif
			return false
		endmethod

		method open takes nothing returns nothing
			call visibleForPlayer(true)
		endmethod

		method openSimple takes nothing returns nothing
			call visibleForPlayer(true)
			call setPoint(FRAMEPOINT_CENTER,BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI,0),FRAMEPOINT_CENTER,0,0)
		endmethod

		method summit takes nothing returns nothing
			set NUMBERPAD_SUMMIT_RESULT = false
			set NUMBERPAD_SUMMIT_PLAYER = null
			set NUMBERPAD_SUMMIT_PLAYER = .owner
			set NUMBERPAD_SUMMIT_PREFIX = .prefix
			set NUMBERPAD_SUMMIT_SUBFIX = .subfix
			set NUMBERPAD_SUMMIT_VALUE = .value
			call TriggerEvaluate(NUMBERPAD_SUMMIT_TRIGGER)
			if NUMBERPAD_SUMMIT_RESULT then
				call close()
			endif
		endmethod

		static method create takes player p returns thistype
			local thistype this = allocate()
			set .owner = p
			call openSimple()
			call clear()
			set THIS[GetPlayerId(p)] = this
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
			set NUMBERPAD_CONTAINER = BlzCreateFrame("Numberpad",FRAME_GAME_UI,0,0)
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