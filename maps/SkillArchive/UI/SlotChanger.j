library SlotChanger requires UI

	struct SlotChanger

		implement ThisUI

		boolean visible_flag = false

		player owner = null
		trigger keypress = null
		triggercondition keypress_cond = null
		framehandle container = null
		framehandle confirm_button = null

		integer state = 0	/*0:기본상태, 1:임시변경중*/
		integer first_index = -1

		static integer array ABILITY_TEMP[10]

		method refresh takes nothing returns nothing
			local integer i = 0
			local framehandle f = null
			local Ability a = 0
			/*위젯 리프레시*/
			set i = 0
			loop
				exitwhen i >= 10
				/*유닛어빌리티 가져오기*/
				set a = User.getFocusUnit(.owner).getAbility(UI.getObject(this,UI.INDEX_SLOT_CHANGER_INDEX+i))
				/*아이콘 설정*/
				set f = LoadFrameHandle(UI.HASH,this,UI.INDEX_SLOT_CHANGER_ICON+i)
				if User.getFocusUnit(.owner) <= 0 or a <= 0 then
					call BlzFrameSetTexture(f,"ReplaceableTextures\\CommandButtons\\BTNBlackIcon.blp",0,true)
				else
					call BlzFrameSetTexture(f,"ReplaceableTextures\\CommandButtons\\"+Ability.getTypeIconPath(a.id)+".blp",0,true)
				endif
				/*버튼프레임 상태 설정*/
				set f = LoadFrameHandle(UI.HASH,this,UI.INDEX_SLOT_CHANGER_BUTTON+i)
				/*시작지 버튼 프레임 출력*/
				if .state == 0 or .state == 2 then
					/*빈 어빌리티면 표시 안함*/
					if User.getFocusUnit(.owner) <= 0 or a <= 0 then
						call BlzFrameSetVisible(f,false)
					/*비어있지 않은 어빌리티의 위치에만 시작지 버튼 출력*/
					else
						call BlzFrameSetVisible(f,true)
						if .state == 0 then
							call BlzFrameSetText(BlzGetFrameByName("SlotChangerButtonText",this*10+i),"|cffffcc00"+User.OSKEY_INDEX_TO_STRING[i]+"|r")
						elseif .state == 2 then
							call BlzFrameSetText(BlzGetFrameByName("SlotChangerButtonText",this*10+i),"|cff00ccff"+User.OSKEY_INDEX_TO_STRING[i]+"|r")
						endif
					endif
				/*목적지 버튼 프레임 출력*/
				else
					if User.getFocusUnit(.owner) <= 0 then
						call BlzFrameSetVisible(f,false)
					/*어빌리티가 비어있어도 목적지 버튼 출력*/
					else
						call BlzFrameSetVisible(f,true)
						if i == .first_index then
							call BlzFrameSetText(BlzGetFrameByName("SlotChangerButtonText",this*10+i),"|cffffff00"+User.OSKEY_INDEX_TO_STRING[i]+"|r")
						else
							call BlzFrameSetText(BlzGetFrameByName("SlotChangerButtonText",this*10+i),"|cff00cc00"+User.OSKEY_INDEX_TO_STRING[i]+"|r")
						endif
					endif
				endif
				set i = i + 1
			endloop
			/*적용버튼 리프레시*/
			if .state == 0 or .state == 1 then
				set f = BlzGetFrameByName("SlotChangerConfirmButtonText",this)
				call BlzFrameSetText(f,"|cff999999적용|r")
				call BlzFrameSetEnable(.confirm_button,false)
			elseif .state == 2 then
				set f = BlzGetFrameByName("SlotChangerConfirmButtonText",this)
				call BlzFrameSetText(f,"|cff00ccff적용|r")
				call BlzFrameSetEnable(.confirm_button,true)
			endif
			set f = null
		endmethod

		method stateEdited takes integer target_index returns nothing
			local integer i = UI.getObject(this,UI.INDEX_SLOT_CHANGER_INDEX+.first_index)
			call UI.setObject(this,UI.INDEX_SLOT_CHANGER_INDEX+.first_index,UI.getObject(this,UI.INDEX_SLOT_CHANGER_INDEX+target_index))
			call UI.setObject(this,UI.INDEX_SLOT_CHANGER_INDEX+target_index,i)
			set .state = 2
			call refresh()
		endmethod

		method stateSelectFirst takes integer first_index returns nothing
			set .first_index = first_index
			set .state = 1
			call refresh()
		endmethod

		method stateDefault takes nothing returns nothing
			local integer i = 0
			set .state = 0
			set .first_index = -1
			loop
				exitwhen i >= 10
				call UI.setObject(this,UI.INDEX_SLOT_CHANGER_INDEX+i,i)
				set i = i + 1
			endloop
			call refresh()
		endmethod

		method confirm takes nothing returns nothing
			local integer i = 0
			local Unit u = User.getFocusUnit(.owner)
			loop
				exitwhen i >= 10
				set ABILITY_TEMP[i] = u.getAbility(UI.getObject(this,UI.INDEX_SLOT_CHANGER_INDEX+i))
				set i = i + 1
			endloop
			set i = 0
			loop
				exitwhen i >= 10
				call u.setAbility(i,ABILITY_TEMP[i])
				set i = i + 1
			endloop
			call UI.THIS[GetPlayerId(.owner)].refreshAbilityIconsTarget()
			call stateDefault()
		endmethod

		method visibleForPlayer takes boolean flag returns nothing
			if not .visible_flag and flag then
				call stateDefault()
			endif
			if GetLocalPlayer() == .owner then
				call BlzFrameSetVisible(FRAME_SLOT_CHANGER,flag)
			endif
			set .visible_flag = flag
		endmethod

		method close takes nothing returns boolean
			if .visible_flag then
				call visibleForPlayer(false)
				return true
			else
				return false
			endif
		endmethod

		static method act takes nothing returns nothing
			local thistype this = Trigger.getData(GetTriggeringTrigger())
			local integer i = 0
			/*G키 입력*/
			if BlzGetTriggerPlayerKey() == OSKEY_G then
				call visibleForPlayer(not .visible_flag)
				return
			endif
			if BlzGetTriggerFrame() != null then
				if BlzFrameGetEnable(BlzGetTriggerFrame()) then
					call BlzFrameSetEnable(BlzGetTriggerFrame(),false)
					call BlzFrameSetEnable(BlzGetTriggerFrame(),true)
				endif
				if BlzGetTriggerFrameEvent() == FRAMEEVENT_CONTROL_CLICK then
					if BlzGetTriggerFrame() == .confirm_button then
						call confirm()
						return
					endif
					loop
						exitwhen i >= 10
						if BlzGetTriggerFrame() == LoadFrameHandle(UI.HASH,this,UI.INDEX_SLOT_CHANGER_BUTTON+i) then
							if .state == 0 or .state == 2 then
								call stateSelectFirst(i)
								return
							elseif .state == 1 then
								/*TODO TEMPORARY CHANGE*/
								call stateEdited(i)
								return
							endif
							return
						endif
						set i = i + 1
					endloop
				endif
				return
			endif
		endmethod

		static method create takes player p returns thistype
			local thistype this = allocate()
			local integer i = 0
			local framehandle f = null
			set .owner = p
			set .keypress = Trigger.new(this)
			set .keypress_cond = TriggerAddCondition(.keypress,function thistype.act)
			call BlzTriggerRegisterPlayerKeyEvent(.keypress,.owner,OSKEY_G,0,true)
			/**/
			set .container = BlzCreateFrameByType("FRAME","",FRAME_SLOT_CHANGER,"",0)
			call BlzFrameSetPoint(.container,FRAMEPOINT_TOPLEFT,FRAME_SLOT_CHANGER,FRAMEPOINT_TOPLEFT,0.,0.)
			/**/
			loop
				exitwhen i >= 10
				call UI.setObject(this,UI.INDEX_SLOT_CHANGER_INDEX+i,i)
				/*아이콘*/
				set f = BlzCreateFrameByType("BACKDROP","",.container,"",0)
				call BlzFrameSetPoint(f,FRAMEPOINT_TOPLEFT,FRAME_SLOT_CHANGER,FRAMEPOINT_TOPLEFT,Math.px2Size(16+(16+48)*i),Math.px2Size(-16))
				call BlzFrameSetSize(f,Math.px2Size(48),Math.px2Size(48))
				call SaveFrameHandle(UI.HASH,this,UI.INDEX_SLOT_CHANGER_ICON+i,f)
				/*백그라운드 텍스트*/
				set f = BlzCreateFrame("MyText",.container,0,0)
				call BlzFrameSetPoint(f,FRAMEPOINT_TOP,LoadFrameHandle(UI.HASH,this,UI.INDEX_SLOT_CHANGER_ICON+i),FRAMEPOINT_BOTTOM,0.,-Math.px2Size(16))
				call BlzFrameSetSize(f,Math.px2Size(48),Math.px2Size(48))
				call BlzFrameSetTextAlignment(f,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
				call BlzFrameSetText(f,"|cff999999"+User.OSKEY_INDEX_TO_STRING[i]+"|r")
				call SaveFrameHandle(UI.HASH,this,UI.INDEX_SLOT_CHANGER_HOTKEY+i,f)
				/*버튼프레임*/
				set f = BlzCreateFrame("SlotChangerButton",.container,0,this*10+i)
				call BlzFrameSetPoint(f,FRAMEPOINT_TOP,LoadFrameHandle(UI.HASH,this,UI.INDEX_SLOT_CHANGER_ICON+i),FRAMEPOINT_BOTTOM,0.,-Math.px2Size(16))
				call BlzFrameSetSize(f,Math.px2Size(48),Math.px2Size(48))
				call BlzTriggerRegisterFrameEvent(.keypress,f,FRAMEEVENT_CONTROL_CLICK)
				call BlzTriggerRegisterFrameEvent(.keypress,f,FRAMEEVENT_MOUSE_LEAVE)
				call SaveFrameHandle(UI.HASH,this,UI.INDEX_SLOT_CHANGER_BUTTON+i,f)
				set f = BlzGetFrameByName("SlotChangerButtonText",this*10+i)
				call BlzFrameSetText(f,"|cffffcc00"+User.OSKEY_INDEX_TO_STRING[i]+"|r")
				call BlzFrameSetPoint(f,FRAMEPOINT_CENTER,LoadFrameHandle(UI.HASH,this,UI.INDEX_SLOT_CHANGER_BUTTON+i),FRAMEPOINT_CENTER,0.,0.)
				call BlzFrameSetTextAlignment(f,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
				set i = i + 1
			endloop
			/*컨펌버튼*/
			set .confirm_button = BlzCreateFrame("SlotChangerConfirmButton",.container,0,this)
			call BlzFrameSetPoint(.confirm_button,FRAMEPOINT_BOTTOM,FRAME_SLOT_CHANGER,FRAMEPOINT_BOTTOM,0,Math.px2Size(16))
			call BlzFrameSetSize(.confirm_button,Math.px2Size(192),Math.px2Size(48))
			call BlzTriggerRegisterFrameEvent(.keypress,.confirm_button,FRAMEEVENT_CONTROL_CLICK)
			call BlzTriggerRegisterFrameEvent(.keypress,.confirm_button,FRAMEEVENT_MOUSE_LEAVE)
			set f = BlzGetFrameByName("SlotChangerConfirmButtonText",this)
			call BlzFrameSetPoint(f,FRAMEPOINT_CENTER,.confirm_button,FRAMEPOINT_CENTER,0,0)
			call BlzFrameSetTextAlignment(f,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
			call BlzFrameSetText(f,"|cff999999적용|r")
			call BlzFrameSetEnable(.confirm_button,false)
			/**/
			call BlzFrameSetVisible(.container,GetLocalPlayer()==.owner)
			/**/
			set THIS[GetPlayerId(p)] = this
			set f = null
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			local integer i = 0
			loop
				exitwhen i >= 10
				call BlzDestroyFrame(LoadFrameHandle(UI.HASH,this,UI.INDEX_SLOT_CHANGER_ICON+i))
				call BlzDestroyFrame(LoadFrameHandle(UI.HASH,this,UI.INDEX_SLOT_CHANGER_BUTTON+i))
				call BlzDestroyFrame(LoadFrameHandle(UI.HASH,this,UI.INDEX_SLOT_CHANGER_HOTKEY+i))
				set i = i + 1
			endloop
			//! runtextmacro destroyFrame(".container")
			//! runtextmacro destroyFrame(".confirm_button")
			call TriggerRemoveCondition(.keypress,.keypress_cond)
			call Trigger.remove(.keypress)
			set .keypress = null
			set .keypress_cond = null
			set .owner = null
		endmethod

	endstruct

endlibrary