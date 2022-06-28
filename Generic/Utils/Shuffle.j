library ShufflePrototype

	struct Shuffle_prototype

		private static integer array VALUE[1024]
		private static integer array RANDOM[1024]
		private static integer SIZE = 0

		static method addValue takes integer i returns nothing
			set VALUE[SIZE] = i
			set SIZE = SIZE + 1
		endmethod

		static method reset takes nothing returns nothing
			set SIZE = 0
		endmethod

		static method pick takes nothing returns integer
			local integer i = GetRandomInt(0,SIZE-1)
			local integer rv = VALUE[i]
			loop
				exitwhen i + 1 >= SIZE
				set VALUE[i] = VALUE[i+1]
				set i = i + 1
			endloop
			set SIZE = SIZE - 1
			return rv
		endmethod

	endstruct

endlibrary