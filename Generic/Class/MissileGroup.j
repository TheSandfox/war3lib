library MissileGroup

	struct MissileGroup

		static hashtable HASH = InitHashtable()
		group group_wave = null
		timer main_timer = null

		static method decay takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			call destroy()
		endmethod

		method setDuration takes real nv returns nothing
			if nv < 0. then
				return
			endif
			if .main_timer == null then
				set .main_timer = Timer.new(this)
			endif
			call Timer.start(.main_timer,nv,false,function thistype.decay)
		endmethod

		method pull takes integer index returns nothing
			local integer i = index
			loop
				exitwhen not HaveSavedInteger(HASH,this,i+1)
				call SaveInteger(HASH,this,i,LoadInteger(HASH,this,i+1))
				call RemoveSavedInteger(HASH,this,i+1)
				set i = i + 1
			endloop
		endmethod

		method remove takes Missile target returns nothing
			local integer i = 0
			loop
				exitwhen not HaveSavedInteger(HASH,this,i)
				if LoadInteger(HASH,this,i) == target then
					set target.group_wave = null
					call RemoveSavedInteger(HASH,this,i)
					call pull(i)
					exitwhen true
				endif
				set i = i + 1
			endloop
			if not HaveSavedInteger(HASH,this,0) and .main_timer == null then
				call destroy()
			endif
		endmethod

		method add takes Missile target returns nothing
			local integer i = 0
			loop
				if not HaveSavedInteger(HASH,this,i) then
					call SaveInteger(HASH,this,i,target)
					call Group.release(target.group_wave)
					set target.group_wave = .group_wave
					set target.group_link = this
					return
				endif
				set i = i + 1
			endloop
		endmethod

		static method create takes nothing returns thistype
			local thistype this = allocate()
			set .group_wave = Group.new()
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call Group.release(.group_wave)
			set .group_wave = null
			if .main_timer != null then
				call Timer.release(.main_timer)
			endif
			set .main_timer = null
		endmethod

	endstruct

endlibrary