/*값끼리 !절대! 겹치면 안됨*/
library Event

	globals
		constant real DAMAGE_EVENT_MODIFY_STAT = 1.0
		constant real DAMAGE_EVENT_MODIFY_DAMAGE = 2.0
		constant real DAMAGE_EVENT_AFTER_HPREDUCE = 3.0
		constant real DAMAGE_EVENT_BEFORE_HPREDUCE = 4.0
		constant real RIGHT_CLICK_EVENT = 5.0
		constant real WEAPON_CHANGE_EVENT = 6.0
	endglobals

	struct Event

		static method triggerRegisterGenericRightClick takes trigger t returns nothing
			call TriggerRegisterVariableEvent(t,"udg_EVENT_VALUE",EQUAL,RIGHT_CLICK_EVENT)
		endmethod

		static method triggerRegisterDamageEvent takes trigger t, real de returns nothing
			call TriggerRegisterVariableEvent(t,"udg_EVENT_VALUE",EQUAL,de)
		endmethod

		static method triggerRegisterWeaponChangeEvent takes trigger t returns nothing
			call TriggerRegisterVariableEvent(t,"udg_EVENT_VALUE",EQUAL,WEAPON_CHANGE_EVENT)
		endmethod

		static method getValue takes nothing returns real
			return udg_EVENT_VALUE
		endmethod

		static method reset takes nothing returns nothing
			set udg_EVENT_VALUE = 0.
		endmethod

		static method activate takes real v returns nothing
			set udg_EVENT_VALUE = v
		endmethod

	endstruct

endlibrary