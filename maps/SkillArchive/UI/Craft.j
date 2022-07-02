library Craft

	struct Craft extends Closeable

		player owner = null
		boolean visible_flag = false	
		implement ThisUI

		trigger keypress = null
		triggercondition keypress_cond = null

		method visibleForPlayer takes boolean flag returns nothing
			local Inventory inv = 0
			set .visible_flag = flag
			if flag then
				set inv = Inventory.THIS[GetPlayerId(.owner)]
				if not inv.visible_flag then
					call inv.visibleForPlayer(true)
				endif
				if GetLocalPlayer() == .owner then
					call BlzFrameSetVisible(FRAME_CRAFT,true)
				endif
			else
				if GetLocalPlayer() == .owner then
					call BlzFrameSetVisible(FRAME_CRAFT,false)
				endif
			endif
		endmethod

		method close takes nothing returns boolean
			call visibleForPlayer(false)
			return true
		endmethod

		method switch takes nothing returns nothing
			call visibleForPlayer(not .visible_flag)
		endmethod

		private static method press takes nothing returns nothing
			local thistype this = Trigger.getData(GetTriggeringTrigger())
			if BlzGetTriggerPlayerKey() == OSKEY_U then
				call switch()
				return
			endif
		endmethod

		static method create takes player owner returns thistype
			local thistype this = allocate()
			set .owner = owner
			/*트리거*/
			set .keypress = Trigger.new(this)
			call BlzTriggerRegisterPlayerKeyEvent(.keypress,.owner,OSKEY_U,0,true)
			set .keypress_cond = TriggerAddCondition(.keypress,function thistype.press)
			set THIS[GetPlayerId(.owner)] = this
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			//! runtextmacro destroyTriggerAndCondition(".keypress",".keypress_cond")
		endmethod

	endstruct

endlibrary