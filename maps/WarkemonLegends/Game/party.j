library Party requires Character, Field

	struct Party extends array

		static constant integer PARTY_SIZE = 5		/*0~4 	파티	*/
		static constant integer STORAGE_SIZE = 32	/*5~36	창고	*/

		static hashtable HASH = InitHashtable()
		/*주소값*/
		static constant integer INDEX_MONSTER = 0		
		static integer INDEX_STORAGE = 0				
		static integer ARRAY_SIZE = 0				/*37 전체크기	*/
		/*null 프로필*/
		static constant integer TEMP = 0

		/*FOR PROFILE*/
		static method setMonster takes integer pr, integer index, integer v returns nothing
			call SaveInteger(HASH,pr*ARRAY_SIZE,INDEX_MONSTER+index,v)
		endmethod

		static method getMonster takes integer pr, integer index returns Monster
			if HaveSavedInteger(HASH,pr*ARRAY_SIZE,INDEX_MONSTER+index) then 
				return LoadInteger(HASH,pr*ARRAY_SIZE,INDEX_MONSTER+index)
			else
				return 0
			endif
		endmethod

		static method swap takes integer pr, integer pointer1, integer pointer2 returns nothing
			local integer monster_temp = getMonster(pr,pointer1)
			if (pointer1 != 0 and pointer2 != 0) or (getMonster(pr,pointer1) != 0 and getMonster(pr,pointer2) != 0) then
				call SaveInteger(HASH,pr*ARRAY_SIZE,INDEX_MONSTER+pointer1,getMonster(pr,pointer2))
				call SaveInteger(HASH,pr*ARRAY_SIZE,INDEX_MONSTER+pointer2,monster_temp)
			endif
		endmethod

		private static method clear takes integer pr returns nothing
			local integer i = 0
			local Monster m = 0
			loop
				exitwhen i+INDEX_MONSTER >= ARRAY_SIZE
				set m = getMonster(pr,i)
				if m != 0 then
					call m.destroy()
					call SaveInteger(HASH,pr*ARRAY_SIZE,INDEX_MONSTER+i,0)
				endif
				set i = i + 1
			endloop
			call RemoveSavedInteger(HASH,pr*ARRAY_SIZE,INDEX_MONSTER)
		endmethod

		static method clearTemp takes nothing returns nothing
			call clear(0)
		endmethod

		static method addMonster takes integer pr, integer monster returns nothing
			local integer i = 0
			local boolean success = false
			loop
				exitwhen i+INDEX_MONSTER >= ARRAY_SIZE
				if getMonster(pr,i) == 0 then
					call SaveInteger(HASH,pr*ARRAY_SIZE,INDEX_MONSTER+i,monster)
					set success = true
					exitwhen true
				endif
				set i = i + 1
			endloop
			if not success then
				/*생성 실패*/
			endif
		endmethod

		static method onInit takes nothing returns nothing
			set INDEX_STORAGE = PARTY_SIZE
			set ARRAY_SIZE = PARTY_SIZE + STORAGE_SIZE
		endmethod

	endstruct

endlibrary