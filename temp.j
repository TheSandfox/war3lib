//! import "import\\DzAPIFrameHandle.j"
//! import "import\\DzAPISync.j"

library Numberpad

	struct Numberpad extends array

		private static trigger INPUT_TRIGGER = CreateTrigger()
		private static integer FRAME_OVERLAY
		private static integer CONTAINER
		private static integer array BTN[14]
		private static integer TEXT
		private static integer BTN_CLEAR
		private static integer BTN_SUMMIT
		private static integer BTN_DELETE

		private static constant integer INPUT_LIMIT = 12

		private static trigger SUMMIT_TRIGGER = CreateTrigger()
		private static player SUMMIT_PLAYER = null
		private static string SUMMIT_PREFIX = ""
		private static string SUMMIT_VALUE = ""
		private static string REFINED_PREFIX = ""
		private static string REFINED_SUBFIX = ""
		private static boolean SUMMIT_RESULT = false

		player owner
		boolean visible_flag
		boolean allow_zero_input
		boolean initial

		string prefix
		string value

		static method operator [] takes player p returns thistype
			return thistype(GetPlayerId(p))
		endmethod

		static method registerCondition takes code func returns triggercondition
			return TriggerAddCondition(SUMMIT_TRIGGER,Condition(func))
		endmethod

		static method refinePrefix takes nothing returns nothing
			local integer i = 0
			set REFINED_PREFIX = ""
			set REFINED_SUBFIX = ""
			loop
				if i >= StringLength(SUMMIT_PREFIX)-1 then
					set REFINED_PREFIX = SUMMIT_PREFIX
					exitwhen true
				elseif SubString(SUMMIT_PREFIX,i,i+1) == "#" then
					set REFINED_PREFIX = SubString(SUMMIT_PREFIX,0,i)
					set REFINED_SUBFIX = SubString(SUMMIT_PREFIX,i+1,StringLength(SUMMIT_PREFIX))
					exitwhen true
				else
					set i = i + 1
				endif
			endloop
		endmethod

		static method customSummit takes player p, string prefix, string value returns nothing
			set SUMMIT_RESULT = false
			set SUMMIT_PLAYER = null
			set SUMMIT_PLAYER = p
			set SUMMIT_PREFIX = prefix
			set SUMMIT_VALUE = value
			call refinePrefix()
			call TriggerEvaluate(SUMMIT_TRIGGER)
		endmethod

		method refreshDisplay takes nothing returns nothing
			if GetLocalPlayer() == .owner then
				if .initial then
					call JNFrameSetText(TEXT,"|cffffff00"+.value+"|r")
				else
					call JNFrameSetText(TEXT,.value)
				endif
			endif
		endmethod

		method setPrefix takes string s returns nothing
			set .prefix = s
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
					if S2I(.value) > 0 then
						set .value = .value + s
					else
						return
					endif
				endif
			else
				if .initial or (S2I(.value) == 0 and not .allow_zero_input) then
					set .value = s
				else
					set .value = .value + s
				endif
			endif
			set .value = SubString(.value,0,INPUT_LIMIT)
			set .initial = false
			call refreshDisplay()
		endmethod

		method delete takes nothing returns nothing
			if .value == "" then
				return
			endif
			if StringLength(.value) <= 1 and not .allow_zero_input then
				set .value = ""
			else
				set .value = SubString(.value,0,StringLength(.value)-1)
			endif
			call refreshDisplay()
		endmethod

		method clear takes nothing returns nothing
			set .value = ""
			call refreshDisplay()
		endmethod

		method allowZeroInput takes boolean b returns nothing
			set .allow_zero_input = b
			call clear()
		endmethod

		private method visibleForPlayer takes boolean flag returns nothing
			if GetLocalPlayer() == .owner then
				call JNFrameSetVisible(CONTAINER,flag)
			endif
			set .visible_flag = flag
		endmethod

		method setAbsPoint takes integer pivot, real offset_x, real offset_y returns nothing
			if GetLocalPlayer() == .owner then
				call JNFrameClearAllPoints(CONTAINER)
				call JNFrameSetAbsPoint(CONTAINER,pivot,offset_x,offset_y)
			endif
		endmethod

		method setPoint takes integer pivot, integer target, integer relative, real offset_x, real offset_y returns nothing
			if GetLocalPlayer() == .owner then
				call JNFrameClearAllPoints(CONTAINER)
				call JNFrameSetPoint(CONTAINER,pivot,target,relative,offset_x,offset_y)
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
			call setPrefix(prefix)
			call setInitialValue("0")
			call visibleForPlayer(true)
		endmethod

		method openSimple takes string prefix returns nothing
			call setPoint(JN_FRAMEPOINT_CENTER,JNGetGameUI(),JN_FRAMEPOINT_CENTER,0,0)
			call open(prefix)
		endmethod

		method summit takes nothing returns nothing
			call customSummit(.owner,.prefix,.value)
			if SUMMIT_RESULT then
				call close()
			endif
		endmethod

		static method create takes player p returns thistype
			local thistype this = thistype[p]
			set .owner = p
			set .visible_flag = false
			set .allow_zero_input = false
			set .initial = false
			set .prefix = ""
			set .value = ""
			call clear()
			call openSimple("")//close()
			return this
		endmethod

		static method genericInput takes player p, integer i returns nothing
			local thistype this = thistype[p]
			if GetLocalPlayer() == .owner then
				call JNFrameSetEnable(BTN[i],false)
				call JNFrameSetEnable(BTN[i],true)
			endif
			if i >= 0 and i <= 9 then
				call add(I2S(i))
			elseif i == 10 then
				call add("00")
			elseif i == 11 then
				call summit()
			elseif i == 12 then
				call clear()
			elseif i == 13 then
				call delete()
			endif
		endmethod

		//! textmacro genericInputMacro takes index
		static method genericInput$index$ takes nothing returns nothing
			call genericInput(DzGetTriggerUIEventPlayer(),$index$)
		endmethod
		//! endtextmacro
		//! runtextmacro genericInputMacro("0")
		//! runtextmacro genericInputMacro("1")
		//! runtextmacro genericInputMacro("2")
		//! runtextmacro genericInputMacro("3")
		//! runtextmacro genericInputMacro("4")
		//! runtextmacro genericInputMacro("5")
		//! runtextmacro genericInputMacro("6")
		//! runtextmacro genericInputMacro("7")
		//! runtextmacro genericInputMacro("8")
		//! runtextmacro genericInputMacro("9")
		//! runtextmacro genericInputMacro("10")
		//! runtextmacro genericInputMacro("11")
		//! runtextmacro genericInputMacro("12")
		//! runtextmacro genericInputMacro("13")

		static method delayedInit takes nothing returns nothing
			local integer i = 0
			call JNLoadTOCFile("ui\\framedef\\Numberpad.toc")
			/*Init Frames*/
			//set FRAME_OVERLAY = JNCreateFrameByType("FRAME","",JNFrameGetParent(JNGetGameUI()),"",0)
			set CONTAINER = JNCreateFrame ("Numberpad",JNGetGameUI(),0,0)
			set TEXT = JNGetFrameByName("NumberpadDisplayText",0)
			set BTN[0] = JNGetFrameByName("NumberpadButton0",0)
			set BTN[1] = JNGetFrameByName("NumberpadButton1",0)
			set BTN[2] = JNGetFrameByName("NumberpadButton2",0)
			set BTN[3] = JNGetFrameByName("NumberpadButton3",0)
			set BTN[4] = JNGetFrameByName("NumberpadButton4",0)
			set BTN[5] = JNGetFrameByName("NumberpadButton5",0)
			set BTN[6] = JNGetFrameByName("NumberpadButton6",0)
			set BTN[7] = JNGetFrameByName("NumberpadButton7",0)
			set BTN[8] = JNGetFrameByName("NumberpadButton8",0)
			set BTN[9] = JNGetFrameByName("NumberpadButton9",0)
			set BTN[10] = JNGetFrameByName("NumberpadButton00",0)
			set BTN[11] = JNGetFrameByName("NumberpadSummitButton",0)
			set BTN[12] = JNGetFrameByName("NumberpadClearButton",0)
			set BTN[13] = JNGetFrameByName("NumberpadDeleteButton",0)
			call DzFrameSetAlpha(JNGetFrameByName("NumberpadDisplayTextBackdrop",0),128)
			/*Register Button Action*/
			call DzFrameSetScriptByCode(BTN[0],JN_FRAMEEVENT_CONTROL_CLICK,function thistype.genericInput0,true)
			call DzFrameSetScriptByCode(BTN[1],JN_FRAMEEVENT_CONTROL_CLICK,function thistype.genericInput1,true)
			call DzFrameSetScriptByCode(BTN[2],JN_FRAMEEVENT_CONTROL_CLICK,function thistype.genericInput2,true)
			call DzFrameSetScriptByCode(BTN[3],JN_FRAMEEVENT_CONTROL_CLICK,function thistype.genericInput3,true)
			call DzFrameSetScriptByCode(BTN[4],JN_FRAMEEVENT_CONTROL_CLICK,function thistype.genericInput4,true)
			call DzFrameSetScriptByCode(BTN[5],JN_FRAMEEVENT_CONTROL_CLICK,function thistype.genericInput5,true)
			call DzFrameSetScriptByCode(BTN[6],JN_FRAMEEVENT_CONTROL_CLICK,function thistype.genericInput6,true)
			call DzFrameSetScriptByCode(BTN[7],JN_FRAMEEVENT_CONTROL_CLICK,function thistype.genericInput7,true)
			call DzFrameSetScriptByCode(BTN[8],JN_FRAMEEVENT_CONTROL_CLICK,function thistype.genericInput8,true)
			call DzFrameSetScriptByCode(BTN[9],JN_FRAMEEVENT_CONTROL_CLICK,function thistype.genericInput9,true)
			call DzFrameSetScriptByCode(BTN[10],JN_FRAMEEVENT_CONTROL_CLICK,function thistype.genericInput10,true)
			call DzFrameSetScriptByCode(BTN[11],JN_FRAMEEVENT_CONTROL_CLICK,function thistype.genericInput11,true)
			call DzFrameSetScriptByCode(BTN[12],JN_FRAMEEVENT_CONTROL_CLICK,function thistype.genericInput12,true)
			call DzFrameSetScriptByCode(BTN[13],JN_FRAMEEVENT_CONTROL_CLICK,function thistype.genericInput13,true)
			call JNFrameSetVisible(CONTAINER,false)
			/*Player Configuration*/
			set i = 0
			loop
				exitwhen i >= bj_MAX_PLAYER_SLOTS
				call create(Player(i))
				set i = i + 1
			endloop
			//
			call DestroyTrigger(GetTriggeringTrigger())
		endmethod

		static method onInit takes nothing returns nothing
			local trigger t = CreateTrigger()
			call TriggerAddCondition(t,function thistype.delayedInit)
			call TriggerRegisterTimerEvent(t,0.0,false)
			set t = null
		endmethod

	endstruct

endlibrary