library Agent

	struct Agent extends Object

		static constant integer INDEX_ORIGIN_HANDLE = 0
		static constant integer INDEX_INSTANCE_ID = 1

		agent origin_agent = null

		static hashtable HASH = InitHashtable()

		static method H2U takes integer id returns unit
			if id <= 0 then
				return null
			else
				call RemoveSavedHandle(HASH,0,0)
				call SaveFogStateHandle(HASH,0,0,ConvertFogState(id))
				return LoadUnitHandle(HASH,0,0)
			endif
		endmethod

		static method create takes agent a returns thistype
			local thistype this = allocate()
			set .origin_agent = a
			call SaveAgentHandle(HASH,GetHandleId(.origin_agent),INDEX_ORIGIN_HANDLE,.origin_agent)
			call SaveInteger(HASH,GetHandleId(.origin_agent),INDEX_INSTANCE_ID,this)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call RemoveSavedHandle(HASH,GetHandleId(.origin_agent),INDEX_ORIGIN_HANDLE)
			call RemoveSavedInteger(HASH,GetHandleId(.origin_agent),INDEX_INSTANCE_ID)
			set .origin_agent = null
		endmethod

	endstruct

endlibrary