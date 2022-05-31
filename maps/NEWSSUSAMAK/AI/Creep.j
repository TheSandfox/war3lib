library Creep requires TimerUtils
struct Creep

	private static real TICK = 0.5
	private static real BREAK_TIME = 3.

	trigger ondeath = null
	trigger ondamaged = null
	timer combattimer = null
	boolean combat = true
	UnitEx caster = 0
	/*복귀좌표*/
	real ox = 0.
	real oy = 0.
	real oa = 0.
	/*인식범위*/
	real airange = 800.
	/*마지막 공격유닛*/
	UnitEx lasttarget = 0
	/*초기화게이지*/
	real innaesim = 1.
	/*휴식남은타임*/
	real breaktime = BREAK_TIME
	/*캠프*/
	Camp camp = 0

	method setCamp takes Camp nc returns nothing
		set camp = nc
	endmethod

	static method break takes nothing returns nothing
		local thistype this = Timer.getDataEx()
		if Math.distancePoints(caster.x,caster.y,ox,oy) <= 10. then
			set caster.x = ox
			set caster.y = oy
			call caster.immediateOrder("holdposition")
			call SetUnitFacing(caster.getOrigin(),oa)
		endif
		if breaktime > 0. then
			set caster.hp = caster.hp + caster.getMaxHP()*0.125
			set caster.mp = caster.mp + caster.getMaxMP()*0.125
			if caster.hp == caster.getMaxHP() and caster.mp == caster.getMaxMP() then
				set breaktime = 0.
			else
				set breaktime = breaktime - TICK
			endif
		endif
	endmethod

	method getNearest takes nothing returns Unit
		local group g = NewGroup()
		local integer i = 0
		local Unit u = 0
		call Group.fillUnitsInRange(g,caster.x,caster.y,airange*2)
		loop
			exitwhen BlzGroupUnitAt(g,i) == null
			set u = Unit.get(BlzGroupUnitAt(g,i))
			if u.isEnemyEx(caster.getOwner()) and u.inRange(ox,oy,airange) and u.isVisible(caster.getOwner()) then
				set i = i + 1
			else
				call GroupRemoveUnit(g,BlzGroupUnitAt(g,i))
			endif
		endloop
		set u = Group.getNearest(g,caster.x,caster.y)
		call ReleaseGroup(g)
		set g = null
		return u
	endmethod

	static method combatTimer takes nothing returns nothing
		local thistype this = Timer.getDataEx()
		local boolean alive = true
		local integer i = 0
		local integer j = 0
		local integer randomint = 0
		local Ability array randomabil
		if lasttarget == 0 then
			set lasttarget = getNearest()
			if lasttarget == 0 then
				set alive = false
				call onCombat(false)
			else
				call caster.targetOrder(lasttarget,"attack")
			endif
		endif
		if lasttarget != 0 then
			if lasttarget.isUnitType(UNIT_TYPE_DEAD) or lasttarget.inStatus(STATUS_TYPE_MUJEOK) or not lasttarget.isVisible(caster.getOwner()) then
				set lasttarget = 0
			else
				/*있는 어빌리티 색출*/
				loop
					exitwhen i >= ABIL_MAX
					if caster.getAbility(i) != 0 then
						set randomabil[j] = caster.getAbility(i)
						/*랜덤어빌리티 배열의 사이즈*/
						set j = j + 1
						set randomabil[j] = 0
					endif
					set i = i + 1
				endloop
				/*어빌리티 순서 섞기*/
				set i = 0
				loop
					exitwhen i >= j
					set randomint = GetRandomInt(0,j-1)
					set randomabil[j] = randomabil[randomint]
					set randomabil[randomint] = randomabil[i]
					set randomabil[i] = randomabil[j]
					set i = i + 1
				endloop
				/*AI 순차적으로 실행(하나라도 성공하면 중단)*/
				set i = 0
				loop
					exitwhen i >= j
					if randomabil[i].executeAI(lasttarget) then
						call caster.targetOrder(lasttarget,"attack")
						set i = j
					endif
					set i = i + 1
				endloop
				/*와리가리하면 타겟팅변경*/
				if Math.distancePoints(caster.x,caster.y,lasttarget.x,lasttarget.y) > caster.getRange() then
					set innaesim = innaesim - 0.15
					if innaesim <= 0. then
						set lasttarget = 0
						set innaesim = 1.
					endif
				endif
			endif	
		endif
		if Math.distancePoints(caster.x,caster.y,ox,oy) >= airange then
			set alive = false
			call onCombat(false)
		endif
		if alive then
			call Timer.start(combattimer,TICK,false,function thistype.combatTimer)
		endif
	endmethod

	method onCombat takes boolean flag returns nothing
		if combat != flag and not caster.isUnitType(UNIT_TYPE_DEAD) then
			if flag then
				if breaktime <= 0. or caster.hp >= caster.getMaxHP() then
					/*전투돌입*/
					set innaesim = 1.
					call InstantText.create(caster.getOrigin(), GetOwningPlayer(GetEventDamageSource()), "!")
					call caster.removeStatus(STATUS_TYPE_DISARM)
					call Timer.start(combattimer,0.03125,false,function thistype.combatTimer)
					if camp != 0 then
						call camp.helpCall(Unit.get(GetEventDamageSource()),caster.getOrigin())
					endif
					set combat = true
				endif
			else
				/*전투종료&휴식*/
				call InstantText.createAll(caster.getOrigin(), "...")
				call caster.addStatus(STATUS_TYPE_DISARM)
				call caster.pointOrder(ox,oy,"move")
				set breaktime = BREAK_TIME
				call Timer.start(combattimer,TICK,true,function thistype.break)
				set combat = false
			endif
		endif
	endmethod

	static method onDamaged takes nothing returns nothing
		local thistype this = Trigger.getData(GetTriggeringTrigger())
		if not Damage.isTry() then
			call onCombat(true)
		endif
	endmethod

	static method decay takes nothing returns nothing
		local thistype this = Timer.getDataEx()
		call destroy()
	endmethod

	static method onDeath takes nothing returns nothing
		local thistype this = Trigger.getData(GetTriggeringTrigger())
		if camp != 0 then
			call camp.removeUnit(caster)
		endif
		call Timer.start(combattimer,10,false,function thistype.decay)
	endmethod

	static method create takes UnitEx u returns thistype
		local thistype this = allocate()
		set .caster = u
		set .ox = caster.x
		set .oy = caster.y
		set .oa = caster.angle
		set .ondeath = Trigger.new(this)
		set .ondamaged = Trigger.new(this)
		set .combattimer = Timer.new(this)
		call TriggerRegisterUnitEvent(ondeath,caster.getOrigin(),EVENT_UNIT_DEATH)
		call TriggerRegisterUnitEvent(ondamaged,caster.getOrigin(),EVENT_UNIT_DAMAGED)
		call TriggerAddCondition(ondeath,function thistype.onDeath)
		call TriggerAddCondition(ondamaged,function thistype.onDamaged)
		call onCombat(false)
		return this
	endmethod

	method onDestroy takes nothing returns nothing
		call caster.destroy()
		call Timer.release(combattimer)
		call Trigger.remove(ondeath)
		call Trigger.remove(ondamaged)
		set combattimer = null
		set ondeath = null
		set ondamaged = null
	endmethod

endstruct
endlibrary