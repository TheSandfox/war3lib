library Camp
struct Camp

	private static thistype LAST_CREATED_CAMP = 0 

	real x = 0.
	real y = 0.
	real a = 0.
	integer level = 0
	integer array uid[5]	/*생성될 유닛의 TypeId*/
	real array angle[5]		/*생성될 유닛이 바라볼 각도(offset)*/
	real array dist[5]		/*생성될 유닛의 이격거리(원점에서부터)*/
	real array dir[5] 		/*생성될 유닛을 이격시킬 방향(offset)*/
	integer array lvl[5]	/*생성될 유닛의 레벨(camp의 레벨과 합해져서)*/
	real regentime = 0.		/*재생성 대기시간*/
	timer regentimer = null	/*재생성 타이머*/
	group creeps = null
	integer dataindex = 0
	unit seeya = null

	method helpCall takes Unit attacker, unit caller returns nothing
		local integer i = 0
		loop
			exitwhen BlzGroupUnitAt(creeps,i) == null
			if BlzGroupUnitAt(creeps,i) != caller then
				call DOT.createOnce(attacker,Unit.get(BlzGroupUnitAt(creeps,i)),0,A_ETC,D_TRUE,WEAPON_TYPE_WHOKNOWS)
			endif
			set i = i + 1
		endloop
	endmethod

	method createCreeps takes nothing returns nothing
		local integer i = 0
		local integer j = 0
		local UnitEx nu = 0
		local Creep nc = 0
		loop
			exitwhen uid[i] == -1
			set nu = UnitEx.create(PLAYER_MONSTER,uid[i],Math.pPX(x,dist[i],dir[i]+a),Math.pPY(y,dist[i],dir[i]+a),angle[i]+a)
			call nu.addLevel(level+lvl[i])
			set j = 0
			loop
				exitwhen j >= ABIL_MAX
					if nu.getAbility(j) != 0 then
						call nu.getAbility(j).addLevel(level+lvl[i])
					endif
				set j = j + 1
			endloop
			set nc = Creep.create(nu)
			call GroupAddUnit(creeps,nu.getOrigin())
			call nc.setCamp(this)
			set i = i + 1
		endloop
	endmethod

	method setData takes integer nuid, real nangle, real ndist, real ndir, integer nlvl returns nothing
		if dataindex < 5 then
			set uid[dataindex] = nuid
			set angle[dataindex] = nangle
			set dist[dataindex] = ndist
			set dir[dataindex] = ndir
			set lvl[dataindex] = nlvl
			set dataindex = dataindex + 1
			set uid[dataindex] = -1
			set angle[dataindex] = -1
			set dist[dataindex] = -1
			set dir[dataindex] = -1
			set lvl[dataindex] = -1
		endif
	endmethod

	method setRegenTime takes real nv returns nothing
		set regentime = nv
	endmethod

	static method respawn takes nothing returns nothing
		local thistype this = Timer.getDataEx()
		call createCreeps()
	endmethod

	method removeUnit takes Unit u returns nothing
		call GroupRemoveUnit(creeps,u.getOrigin())
		if FirstOfGroup(creeps) == null then
			call Timer.start(regentimer,regentime,false,function thistype.respawn)
		endif
	endmethod

	static method create takes real x, real y, real a, real regentime returns thistype
		local thistype this = allocate()
		set .x = x
		set .y = y
		set .a = a
		set .regentime = regentime
		set regentimer = Timer.new(this)
		set creeps = Group.new()
		set uid[0] = -1
		set angle[0] = -1
		set dist[0] = -1
		set dir[0] = -1
		set lvl[0] = -1
		call Timer.start(regentimer,regentime,false,function thistype.respawn)
		set LAST_CREATED_CAMP = this
		set seeya = CreateUnit(PLAYER_MONSTER,'st00',x,y,0)
		return this
	endmethod

	method onDestroy takes nothing returns nothing
		call Timer.release(regentimer)
		call Group.release(creeps)
		call RemoveUnit(seeya)
		set regentimer = null
		set creeps = null
		set seeya = null
	endmethod

	static method init takes nothing returns nothing
		call create(GetRectCenterX(gg_rct_c1),GetRectCenterY(gg_rct_c1),270,10)
		call LAST_CREATED_CAMP.setData('CR00',0,75,0,3)
		call LAST_CREATED_CAMP.setData('CR01',0,100,90,2)
		call LAST_CREATED_CAMP.setData('CR01',0,100,-90,2)
		call create(GetRectCenterX(gg_rct_c2),GetRectCenterY(gg_rct_c2),180,10)
		call LAST_CREATED_CAMP.setData('CR00',0,75,0,3)
		call LAST_CREATED_CAMP.setData('CR01',0,100,90,2)
		call LAST_CREATED_CAMP.setData('CR01',0,100,-90,2)
	endmethod

endstruct
endlibrary