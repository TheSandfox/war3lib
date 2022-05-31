library Undead requires Unit

	globals
		public trigger CREATE_REQUEST = CreateTrigger()
		public real CREATE_X = 0.
		public real CREATE_Y = 0.
		public integer CREATE_ID = 0
		public integer CREATE_POSITION = 0
		public integer LAST_CREATED = 0

		public group GROUP = null
	endglobals

	struct Undead extends Unit

		static constant real AI_TICK = 1.

		timer ai_timer = null
		trigger main_trigger = null
		triggercondition main_cond = null

		Unit target = 0
		boolean target_is_different = true
		integer position = 0
		boolean running = false
		real acquire_range = 600.

		method timerBreak takes nothing returns nothing
			set .target = 0
			call Timer.pause(.ai_timer)
			set .running = false
		endmethod

		/*공격할 수 있는 적이 아무도 없을 때 본진돌격*/
		/*본진돌격 안하면 해당함수 실행하지 말 것*/
		method goToSpawnLocation takes nothing returns nothing
			call issuePointOrder("move",GetRectCenterX(gg_rct_spawn),GetRectCenterY(gg_rct_spawn))
			call timerBreak()
		endmethod

		/*중심원 바깥에 있으면서 자기 포지션의 수호자가 살아있는지 체크*/
		/*수호자 무시 시 항상 false*/
		stub method isGuardianAlive takes nothing returns boolean
			return not Guardians.GUARDIAN[.position].isUnitType(UNIT_TYPE_DEAD) and /*
			*/Math.distancePoints(.x,.y,GetRectCenterX(gg_rct_spawn),GetRectCenterY(gg_rct_spawn)) > 768.
		endmethod

		method unitCondition takes Unit u returns boolean
			return u.inRange(.x,.y,.acquire_range) and not u.isUnitType(UNIT_TYPE_DEAD) and u.isVisible(.owner)
		endmethod

		/*영웅을 무시하고 싶으면 항상 0을 리턴하게 할 것*/
		stub method getNearestHero takes nothing returns Unit
			local integer i = 0
			local Unit g = 0
			local Unit r = 0
			local real dist = 0.
			loop
				exitwhen i >= 4
				set g = User.getFocusUnit(Player(i))
				if unitCondition(g) then
					if i == 0 or r == 0 then
						set r = g
						set dist = Math.distancePoints(.x,.y,g.x,g.y)
					elseif Math.distancePoints(.x,.y,g.x,g.y) < dist then
						set r = g
						set dist = Math.distancePoints(.x,.y,g.x,g.y)
					endif
				endif
				set i = i + 1
			endloop
			return r
		endmethod

		/*수호자를 무시하고 싶으면 항상 0을 리턴하게 할 것*/
		stub method getNearestGuardian takes nothing returns Unit
			local integer i = 0
			local Unit g = 0
			local Unit r = 0
			local real dist = 0.
			loop
				exitwhen i >= 4
				set g = Guardians.GUARDIAN[i]
				if unitCondition(g) then
					if i == 0 or r == 0 then
						set r = g
						set dist = Math.distancePoints(.x,.y,g.x,g.y)
					elseif Math.distancePoints(.x,.y,g.x,g.y) < dist then
						set r = g
						set dist = Math.distancePoints(.x,.y,g.x,g.y)
					endif
				endif
				set i = i + 1
			endloop
			return r
		endmethod

		method getNearestEnemy takes nothing returns Unit
			local Unit u1 = getNearestHero()
			local Unit u2 = getNearestGuardian()
			if u1 > 0 and u2 > 0 then
				if Math.distancePoints(.x,.y,u1.x,u1.y) >= Math.distancePoints(.x,.y,u2.x,u2.y) then
					return u2
				else
					return u1
				endif
			elseif u1 > 0 then
				return u1
			elseif u2 > 0 then
				return u2
			else
				return 0
			endif
		endmethod

		stub method onSetTarget takes nothing returns nothing
			//if .target_is_different then
				call issueTargetOrder("attack",.target.origin_unit)
			//endif
		endmethod

		/*생명의 나무로 돌격 안하는 언데드는 이 함수의 내용을 재정의할 것*/
		stub method onFreeTarget takes nothing returns nothing
			call goToSpawnLocation()
		endmethod

		method setTarget takes Unit u returns nothing
			set .target_is_different = u == .target
			set .target = u
			if .target > 0 then
				call onSetTarget()
			else
				call onFreeTarget()
			endif
		endmethod

		stub method refreshTarget takes nothing returns nothing
			local Unit u = 0
			/*근처에 살아있는 수호자가 없으면*/
			set u = getNearestGuardian()
			if u == 0 then
				/*근처에 살아있는 플레이어가 없으면*/
				set u = getNearestHero()
				if u == 0 then
					/*자기 포지션에 살아있는 가디언이 있으면*/
					if isGuardianAlive() then
						call setTarget(Guardians.GUARDIAN[.position])
					/*자기 포지션에 살아있는 가디언이 없으면*/
					else
						/*본진으로 돌격*/
						call setTarget(0)
					endif
				/*근처에 살아있는 플레이어가 있으면*/
				else
					call setTarget(u)
				endif
			/*근처에 살아있는 수호자가 있으면*/
			else
				call setTarget(u)
			endif
		endmethod

		method getTarget takes nothing returns Unit
			local Unit u = 0
			if .target != 0 then
				if not unitCondition(.target) then
					call refreshTarget()
				elseif .target.class != "Guardian" then
					set u = getNearestGuardian()
					if u > 0 then
						call setTarget(u)
					endif
				endif
			else
				call refreshTarget()
			endif
			return .target
		endmethod

		stub method periodicAction takes nothing returns nothing
			call getTarget()
		endmethod

		private static method timerAction takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			call periodicAction()
		endmethod

		stub method onDamaged takes nothing returns nothing

		endmethod

		method encount takes nothing returns nothing
			if not .running then
				call refreshTarget()
				set .running = true
				call Timer.start(.ai_timer,AI_TICK,true,function thistype.timerAction)
			endif
		endmethod

		method helpCall takes nothing returns nothing
			local integer i = 0
			local unit u = null
			local Undead ud = 0
			/*도움요청*/
			loop
				set u = BlzGroupUnitAt(GROUP,i)
				exitwhen u == null
				if u != .origin_unit then
					set ud = Undead.get(u)
					call ud.encount()
				endif
				set i = i + 1
			endloop
			set u = null
		endmethod

		static method cond takes nothing returns nothing
			local thistype this = Trigger.getData(GetTriggeringTrigger())
			if not (DAMAGE_ATTACKER == this or DAMAGE_TARGET == this) then
				return
			endif
			call encount()
			call onDamaged()
		endmethod

		stub method init takes nothing returns nothing

		endmethod

		static method create takes integer uid, real x, real y, real yaw, integer position returns thistype
			local thistype this = allocate(PLAYER_UNDEAD,uid,x,y,yaw)
			local integer i = 0
			local Ability a = 0
			call GroupAddUnit(GROUP,.origin_unit)
			set .position = position
			set .ai_timer = Timer.new(this)
			set .main_trigger = Trigger.new(this)
			set .main_cond = TriggerAddCondition(.main_trigger,function thistype.cond)
			call Damage.triggerRegisterDamageEvent(.main_trigger,DAMAGE_EVENT_BEFORE_HPREDUCE)
			set .class = "Undead"
			loop
				exitwhen getAbility(i) <= 0
				set a = getAbility(i)
				set a.is_ai = true
				set i = i + 1
			endloop
			return this
		endmethod

		static method new takes integer uid, real x, real y, integer position returns thistype
			set LAST_CREATED = 0
			set CREATE_ID = uid
			set CREATE_X = x
			set CREATE_Y = y
			set CREATE_POSITION = position
			call TriggerEvaluate(CREATE_REQUEST)
			return LAST_CREATED
		endmethod

		static method unregister2 takes nothing returns nothing
			if UNREGISTER_GROUP_UNIT == null then
				return
			else
				call GroupRemoveUnit(GROUP,UNREGISTER_GROUP_UNIT)
			endif
		endmethod

		method onDestroy takes nothing returns nothing
			call Timer.release(.ai_timer)
			set .ai_timer = null
			//! runtextmacro destroyTriggerAndCondition(".main_trigger",".main_cond")
		endmethod

		static method onInit takes nothing returns nothing
			set GROUP = Group.new()
			call TriggerAddCondition(UNREGISTER_GROUP,function thistype.unregister2)
		endmethod

	endstruct

endlibrary

//! textmacro undeadHeader takes id
struct Undead$id$ extends Undead

	private static constant integer ID = '$id$'
//! endtextmacro

//! textmacro undeadEnd

	static method create takes real x, real y, integer position returns thistype
		local thistype this = allocate(ID,x,y,Math.anglePoints(x,y,GetRectCenterX(gg_rct_spawn),GetRectCenterY(gg_rct_spawn)),position)
		return this
	endmethod

	private static method request takes nothing returns nothing
		if Undead_CREATE_ID == ID then
			set Undead_LAST_CREATED = create(Undead_CREATE_X,Undead_CREATE_Y,Undead_CREATE_POSITION)
			call thistype(Undead_LAST_CREATED).init()
		endif
	endmethod

	private static method onInit takes nothing returns nothing
		call TriggerAddCondition(Undead_CREATE_REQUEST,function thistype.request)
	endmethod

endstruct
//! endtextmacro

//! import "UndeadData.j"