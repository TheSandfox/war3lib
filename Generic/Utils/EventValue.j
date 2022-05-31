/*값끼리 !절대! 겹치면 안됨*/
library Event

	globals
		constant real DAMAGE_EVENT_MODIFY_STAT = 1.0
		constant real DAMAGE_EVENT_MODIFY_DAMAGE = 2.0
		constant real DAMAGE_EVENT_AFTER_HPREDUCE = 3.0
		constant real DAMAGE_EVENT_BEFORE_HPREDUCE = 4.0
		constant real RIGHT_CLICK_EVENT = 5.0
	endglobals

	struct Event

		static method reset takes nothing returns nothing
			set udg_EVENT_VALUE = 0.
		endmethod

		static method activate takes real v returns nothing
			set udg_EVENT_VALUE = v
		endmethod

	endstruct

endlibrary