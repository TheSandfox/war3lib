library CloseUI requires UI

	struct CloseUI

		trigger esc_trigger = null
		triggercondition esc_cond = null

		player owner = null

		static method act takes nothing returns nothing
			local thistype this = Trigger.getData(GetTriggeringTrigger())
			if SlotChanger.THIS[GetPlayerId(.owner)] > 0 and SlotChanger.THIS[GetPlayerId(.owner)].close() then
				return 
			endif
			if SkillShop.THIS[GetPlayerId(.owner)] > 0 and SkillShop.THIS[GetPlayerId(.owner)].close() then
				return 
			endif
		endmethod

		static method create takes player p returns thistype
			local thistype this = allocate()
			set .owner = p
			set .esc_trigger = Trigger.new(this)
			set .esc_cond = TriggerAddCondition(.esc_trigger,function thistype.act)
			call BlzTriggerRegisterPlayerKeyEvent(.esc_trigger,.owner,OSKEY_ESCAPE,0,true)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call TriggerRemoveCondition(.esc_trigger,.esc_cond)
			call Trigger.remove(.esc_trigger)
			set .esc_trigger = null
			set .esc_cond = null
			set .owner = null
		endmethod

	endstruct

endlibrary