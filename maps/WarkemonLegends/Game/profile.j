library Profile requires ProfileUI

	struct Profile

		private static constant real CAM_OFFSET_Y = 125.

		private static constant integer STATE_NORMAL = 0
		private static constant integer STATE_BATTLE = 1
		private static constant integer STATE_STORAGE = 2

		unit cam_unit 				= null
		timer cam_timer 			= null
		camerasetup cam_current 	= null
		player owner 				= null
		PlayerCharacter character 	= 0
		PartyUI party_ui		= 0
		StorageUI storage_ui	= 0

		integer state = 0		/*0:일반,1:배틀,2:창고*/
		trigger keypress = null

		method setState takes integer i returns nothing
			set .state = i
			if .state == STATE_NORMAL then
				call .party_ui.show(true).refresh()
				call .storage_ui.show(false)
				set .character.suspend = false
			elseif .state == STATE_BATTLE then
				call .party_ui.show(false)
				call .storage_ui.show(false)
				set .character.suspend = true
			elseif .state == STATE_STORAGE then
				call .party_ui.show(true).refresh()
				call .storage_ui.show(true)
				set .character.suspend = true
			endif
		endmethod
		
		static method getPlayerProfile takes player p returns thistype
			local integer i = 0
			if p == null then
				return 0
			endif
			loop
				exitwhen i >= 32
				if Profile(i).owner == p then
					return Profile(i)
				endif
				set i = i + 1
			endloop
			return 0
		endmethod

		private static method camTimer takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			if .cam_current ==  gg_cam_DEFAULT then
				call SetUnitPosition(.cam_unit,.character.getX(),.character.getY())
			endif
			if GetLocalPlayer() == .owner then
				call CameraSetupApply(.cam_current,true,true)
				call SetCameraTargetController(.cam_unit,0,CAM_OFFSET_Y,false)
			endif
		endmethod

		method pauseCamTimer takes nothing returns nothing
			call Timer.pause(.cam_timer)
		endmethod

		method startCamTimer takes nothing returns nothing
			call Timer.start(.cam_timer,TIMER_TICK,true,function thistype.camTimer)
		endmethod

		method pressASZX takes nothing returns nothing
			if BlzGetTriggerPlayerKey() == OSKEY_S then
				if .state == STATE_NORMAL then
					call setState(STATE_STORAGE)
				elseif .state == STATE_STORAGE then
					call setState(STATE_NORMAL)
				endif
			elseif BlzGetTriggerPlayerKey() == OSKEY_X then
				if .state == STATE_STORAGE then
					call setState(STATE_NORMAL)
				endif
			endif
		endmethod

		method pressArrow takes nothing returns nothing
			local integer i = .storage_ui.cursor
			if .state == STATE_STORAGE then
				if BlzGetTriggerPlayerKey() == OSKEY_UP then
					set i = i - StorageUI.ICON_PER_ROW
					if i < 0 then
						set i = i + StorageUI.ICON_PER_ROW
					endif
				elseif BlzGetTriggerPlayerKey() == OSKEY_DOWN then
					set i = i + StorageUI.ICON_PER_ROW
					if i > 31 then
						set i = i - StorageUI.ICON_PER_ROW
					endif
				elseif BlzGetTriggerPlayerKey() == OSKEY_LEFT then
					if i > 0 then
						set i = i - 1
					endif
				else
					if i < 31 then
						set i = i + 1
					endif
				endif
				set .storage_ui.cursor = i
				call .storage_ui.refresh()
			endif
		endmethod

		method pressNum takes nothing returns nothing
			local integer i = 0
			if .state == STATE_STORAGE then
				if BlzGetTriggerPlayerKey() == OSKEY_1 then
					set i = 0
				elseif BlzGetTriggerPlayerKey() == OSKEY_2 then
					set i = 1
				elseif BlzGetTriggerPlayerKey() == OSKEY_3 then
					set i = 2
				elseif BlzGetTriggerPlayerKey() == OSKEY_4 then
					set i = 3
				else
					set i = 4
				endif
				call Party.swap(this,i,.storage_ui.cursor+5)
				call .storage_ui.refresh()
				call .party_ui.refresh()
			endif
		endmethod

		static method keyAct takes nothing returns nothing
			local thistype this = Trigger.getData(GetTriggeringTrigger())
			if BlzGetTriggerPlayerKey() == OSKEY_A or BlzGetTriggerPlayerKey() == OSKEY_S or/*
				*/ BlzGetTriggerPlayerKey() == OSKEY_Z or BlzGetTriggerPlayerKey() == OSKEY_X then
				call pressASZX()
			elseif BlzGetTriggerPlayerKey() == OSKEY_UP or BlzGetTriggerPlayerKey() == OSKEY_DOWN or/*
				*/ BlzGetTriggerPlayerKey() == OSKEY_LEFT or BlzGetTriggerPlayerKey() == OSKEY_RIGHT then
				call pressArrow()
			else
				/*임시*/
				call pressNum()
			endif
		endmethod

		static method create takes player p returns thistype
			local thistype this = allocate()
			set .cam_unit = CreateUnit(p,'dumm',0,0,0)
			set .owner = p
			set .character = PlayerCharacter.create(p)
			set .cam_timer = Timer.new(this)
			set .cam_current = gg_cam_DEFAULT
			if GetLocalPlayer() == .owner then
				call CameraSetupApply(.cam_current,true,true)
				call SetCameraTargetController(.cam_unit,0,CAM_OFFSET_Y,false)
			endif
			/*파티초기화 임시*/
			call Party.addMonster(this,Monster.create(1))
			call Party.getMonster(this,0).setLevel(5)
			call Party.addMonster(this,Monster.create(0))
			call Party.getMonster(this,1).setLevel(5)
			call Party.addMonster(this,Monster.create(0))
			call Party.getMonster(this,2).setLevel(5)
			/*프로필UI*/
			set .party_ui = PartyUI.create(.owner)
			call .party_ui.setDisplayTarget(0,Party.getMonster(this,0))
			call .party_ui.setDisplayTarget(1,Party.getMonster(this,1))
			call .party_ui.setDisplayTarget(2,Party.getMonster(this,2))
			call .party_ui.refresh()
			/*창고UI*/
			set .storage_ui = StorageUI.create(.party_ui)
			/*타이머*/
			call startCamTimer()
			/*키프레스*/
			set .keypress = Trigger.new(this)
			call BlzTriggerRegisterPlayerKeyEvent(.keypress,.owner,OSKEY_A,0,true)
			call BlzTriggerRegisterPlayerKeyEvent(.keypress,.owner,OSKEY_S,0,true)
			call BlzTriggerRegisterPlayerKeyEvent(.keypress,.owner,OSKEY_Z,0,true)
			call BlzTriggerRegisterPlayerKeyEvent(.keypress,.owner,OSKEY_X,0,true)
			call BlzTriggerRegisterPlayerKeyEvent(.keypress,.owner,OSKEY_UP,0,true)
			call BlzTriggerRegisterPlayerKeyEvent(.keypress,.owner,OSKEY_DOWN,0,true)
			call BlzTriggerRegisterPlayerKeyEvent(.keypress,.owner,OSKEY_LEFT,0,true)
			call BlzTriggerRegisterPlayerKeyEvent(.keypress,.owner,OSKEY_RIGHT,0,true)
			call BlzTriggerRegisterPlayerKeyEvent(.keypress,.owner,OSKEY_1,0,true)
			call BlzTriggerRegisterPlayerKeyEvent(.keypress,.owner,OSKEY_2,0,true)
			call BlzTriggerRegisterPlayerKeyEvent(.keypress,.owner,OSKEY_3,0,true)
			call BlzTriggerRegisterPlayerKeyEvent(.keypress,.owner,OSKEY_4,0,true)
			call BlzTriggerRegisterPlayerKeyEvent(.keypress,.owner,OSKEY_5,0,true)
			call TriggerAddCondition(.keypress,function thistype.keyAct)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call RemoveUnit(cam_unit)
			call Trigger.remove(.keypress)
			set .keypress = null
			set .cam_unit = null
			set .owner = null
			set .cam_timer = null
			set .cam_current = null
			call .party_ui.destroy()
			call .storage_ui.destroy()
		endmethod

	endstruct

endlibrary

library SelectStartMonster requires Profile
	
endlibrary