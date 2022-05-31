library Group requires Math

	globals
		private integer LOOP_INDEX = 0
		private real TARGET_X = 0
		private real TARGET_Y = 0
		private real CURRENT_DIST = 0
		private unit CURRENT_UNIT = null
		private group RETURNGROUP = null
	endglobals

	struct Group

		static hashtable HASH = InitHashtable()

		static method new takes nothing returns group
			set RETURNGROUP = null
			//set RETURNGROUP = CreateGroup()
			set RETURNGROUP = NewGroup()
			return RETURNGROUP
		endmethod

		static method release takes group g returns nothing
			//call DestroyGroup(g)
			call ReleaseGroup(g)
		endmethod

		static method clear takes group g returns nothing
			call GroupClear(g)
		endmethod

		/*static method fillUnitsInRange takes group g, real nx, real ny, real radius returns nothing
			local integer i = 0
			local unit u = null
			call GroupClear(g)
			call GroupEnumUnitsInRange(g,nx,ny,radius*2,null)
			loop
				set u = BlzGroupUnitAt(g,i)
				exitwhen u == null
				if IsUnitInGroup(u,UnitPrototype_GROUP) then
					set i = i + 1
				else
					call GroupRemoveUnit(g,u)
				endif
			endloop
			set u = null
		endmethod*/

		static method copy takes group source returns group
			set RETURNGROUP = CreateGroup()
			call BlzGroupAddGroupFast(source,RETURNGROUP)	
			return RETURNGROUP	
		endmethod

		static method getFurthest takes group g, real x, real y, unit except returns unit
			local real d
			local unit u
			set LOOP_INDEX = 0
			set TARGET_X = x
			set TARGET_Y = y
			set CURRENT_UNIT = null
			set CURRENT_DIST = 0
			loop
				set u = BlzGroupUnitAt(g,LOOP_INDEX)
				exitwhen u == null
				if u != except then
					set d = Math.distancePoints(GetUnitX(u),GetUnitY(u),TARGET_X,TARGET_Y)
					if LOOP_INDEX == 0 then
						set CURRENT_UNIT = u
						set CURRENT_DIST = d
					else
						if d > CURRENT_DIST then
							set CURRENT_UNIT = u
							set CURRENT_DIST = d
						endif
					endif
				endif
				set LOOP_INDEX = LOOP_INDEX + 1	
			endloop
			set u = null
			return CURRENT_UNIT
		endmethod

		static method getRandomUnit takes group g returns unit
			return BlzGroupUnitAt(g,GetRandomInt(0,BlzGroupGetSize(g)-1))
		endmethod

		static method getNearest takes group g, real x, real y, unit except returns unit
			local real d
			local unit u
			set LOOP_INDEX = 0
			set TARGET_X = x
			set TARGET_Y = y
			set CURRENT_UNIT = null
			set CURRENT_DIST = 0
			loop
				set u = BlzGroupUnitAt(g,LOOP_INDEX)
				exitwhen u == null
				if u != except then
					set d = Math.distancePoints(GetUnitX(u),GetUnitY(u),TARGET_X,TARGET_Y)
					if LOOP_INDEX == 0 then
						set CURRENT_UNIT = u
						set CURRENT_DIST = d
					else
						if d < CURRENT_DIST then
							set CURRENT_UNIT = u
							set CURRENT_DIST = d
						endif
					endif
				endif
				set LOOP_INDEX = LOOP_INDEX + 1	
			endloop
			set u = null
			return CURRENT_UNIT
		endmethod

	endstruct

endlibrary

//! textmacro groupFilter
	local unit u
	local Unit_prototype ux
	local integer i = 0
	if g == null then
		call GroupClear(GENERIC)
		call BlzGroupAddGroupFast(allUnits(),GENERIC)
	else
		set GENERIC = g
	endif
	loop
		set u = BlzGroupUnitAt(GENERIC,i)
		exitwhen u == null
		set ux = Unit_prototype.get(BlzGroupUnitAt(GENERIC,i))
		
//! endtextmacro
//! textmacro groupFilterEnd
			call GroupRemoveUnit(GENERIC,u)
		else
			set i = i + 1
		endif	
	endloop
	set u = null
	return GENERIC	
//! endtextmacro