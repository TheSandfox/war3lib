//! import "Hellgate.j"
//! import "Waygate.j"

library Interactive

	struct Interactive extends array

		static method init takes nothing returns nothing
			call Hellgate.init()
			call Waygate.init()
		endmethod

	endstruct

endlibrary
