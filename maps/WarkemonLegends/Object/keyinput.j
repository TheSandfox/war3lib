library KeyInput requires GenericKeyTrigger, UI

	globals
		constant integer KEY_INPUT_UP	 	= 0
		constant integer KEY_INPUT_DOWN 	= 1
		constant integer KEY_INPUT_LEFT 	= 2
		constant integer KEY_INPUT_RIGHT 	= 3
		constant integer KEY_INPUT_Z 		= 4
		constant integer KEY_INPUT_X 		= 5
		constant integer KEY_INPUT_SIZE 	= 6
		private oskeytype array INDEX_TO_OSKEY[KEY_INPUT_SIZE]
	endglobals

	struct KeyInput

		trigger trigger_keypress 	= null
		player owner 				= null
		framehandle vk_container	= null
		framehandle array vk_1[KEY_INPUT_Z]
		framehandle array vk_2[KEY_INPUT_Z]

		boolean array key_state[KEY_INPUT_SIZE]

		method getKeyState takes integer i returns boolean
			return key_state[i]
		endmethod

		private method adjustVKeyOverlay takes integer k, boolean flag returns nothing
			call BlzFrameSetVisible(vk_2[k],flag)
			call BlzFrameSetVisible(vk_1[k],not flag)
		endmethod

		private static method keyAction takes nothing returns boolean
			local thistype this = Trigger.getData(GetTriggeringTrigger())
			local integer i = 0
			loop
				exitwhen i >= KEY_INPUT_SIZE
				if INDEX_TO_OSKEY[i] == BlzGetTriggerPlayerKey() then
					if BlzGetTriggerPlayerIsKeyDown()  then
						if not .key_state[i] then
							/*온프레스*/	
							set .key_state[i] = true
							if i >= KEY_INPUT_UP and i <= KEY_INPUT_RIGHT then
								call adjustVKeyOverlay(i,true)
							endif
						endif
						/*프레스*/
					else
						/*릴리즈*/
						set .key_state[i] = false
						if i >= KEY_INPUT_UP and i <= KEY_INPUT_RIGHT then
							call adjustVKeyOverlay(i,false)
						endif
					endif
				endif
				set i = i + 1
			endloop
			return true
		endmethod

		private method initKeyState takes nothing returns nothing
			local integer i = 0
			loop
				exitwhen i >= KEY_INPUT_SIZE
				set key_state[i] = false
				set i = i + 1
			endloop
		endmethod

		static method create takes player p returns thistype
			local thistype this = allocate()
			set .owner = p
			set .trigger_keypress = Trigger.new(this)
			call initKeyState()
			/*키보드 이벤트 등록*/
			//! runtextmacro registerKeyEvent("UP"		)
			//! runtextmacro registerKeyEvent("DOWN"	)
			//! runtextmacro registerKeyEvent("LEFT"	)
			//! runtextmacro registerKeyEvent("RIGHT"	)
			//! runtextmacro registerKeyEvent("Z"		)
			//! runtextmacro registerKeyEvent("X"		)
			/*키보드 액션 등록*/
			call TriggerAddCondition(.trigger_keypress,function thistype.keyAction)
			/*인풋 오버레이*/
			set .vk_container = BlzCreateFrameByType("FRAME","",UI.SURFACE_UI,"",0)
			call BlzFrameSetVisible(.vk_container,GetLocalPlayer()==.owner)
			call BlzFrameSetPoint(.vk_container,FRAMEPOINT_BOTTOMLEFT,UI.ORIGIN,FRAMEPOINT_BOTTOMRIGHT,0.,0.)
			//! runtextmacro createVKeyOverlay("UP","up")
			//! runtextmacro createVKeyOverlay("DOWN","down")
			//! runtextmacro createVKeyOverlay("LEFT","left")
			//! runtextmacro createVKeyOverlay("RIGHT","right")
			return this
		endmethod

		//! textmacro registerKeyEvent takes key
			call BlzTriggerRegisterPlayerKeyEvent(.trigger_keypress,.owner,OSKEY_$key$,0,true)
			call BlzTriggerRegisterPlayerKeyEvent(.trigger_keypress,.owner,OSKEY_$key$,0,false)
		//! endtextmacro

		//! textmacro createVKeyOverlay takes prime, sub
			set .vk_1[KEY_INPUT_$prime$] = BlzCreateFrameByType("SPRITE","",.vk_container,"",0)
			call BlzFrameSetModel(	.vk_1[KEY_INPUT_$prime$],"ui\\ui_vk1_$sub$.mdl",0)
			call BlzFrameSetPoint(	.vk_1[KEY_INPUT_$prime$],FRAMEPOINT_BOTTOMLEFT,UI.ORIGIN,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			call BlzFrameSetSize(	.vk_1[KEY_INPUT_$prime$],1.,1.)
			set .vk_2[KEY_INPUT_$prime$] = BlzCreateFrameByType("SPRITE","",.vk_container,"",0)
			call BlzFrameSetModel(	.vk_2[KEY_INPUT_$prime$],"ui\\ui_vk2_$sub$.mdl",0)
			call BlzFrameSetPoint(	.vk_2[KEY_INPUT_$prime$],FRAMEPOINT_BOTTOMLEFT,UI.ORIGIN,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			call BlzFrameSetSize(	.vk_2[KEY_INPUT_$prime$],1.,1.)
			call BlzFrameSetVisible(.vk_2[KEY_INPUT_$prime$],false)
		//! endtextmacro

		private method onDestroy takes nothing returns nothing
			local integer i = 0
			call Trigger.remove(.trigger_keypress)
			call BlzDestroyFrame(.vk_container)
			set .trigger_keypress = null
			set .owner = null
			set .vk_container = null
			loop
				exitwhen i >= KEY_INPUT_RIGHT
				set .vk_1[i] = null
				set .vk_2[i] = null
				set i = i + 1
			endloop
		endmethod

		private static method onInit takes nothing returns nothing
			set INDEX_TO_OSKEY[KEY_INPUT_UP] = OSKEY_UP
			set INDEX_TO_OSKEY[KEY_INPUT_DOWN] = OSKEY_DOWN
			set INDEX_TO_OSKEY[KEY_INPUT_LEFT] = OSKEY_LEFT
			set INDEX_TO_OSKEY[KEY_INPUT_RIGHT] = OSKEY_RIGHT
			set INDEX_TO_OSKEY[KEY_INPUT_Z] = OSKEY_Z
			set INDEX_TO_OSKEY[KEY_INPUT_X] = OSKEY_X
		endmethod

	endstruct

endlibrary