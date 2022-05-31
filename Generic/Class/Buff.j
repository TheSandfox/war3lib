library Buff

	//! textmacro buffHeader takes name, id, ind, icon

		globals
			private string NAME = "$name$"
			private integer ID = '$id$'
			private integer INDIVISUAL = $ind$
			private string ICON_PATH = "$icon$"
		endglobals
	//! endtextmacro

	//! textmacro buffEnd

			private function new takes Unit_prototype caster, Unit_prototype target, real duration returns main
				local main b = 0
				if INDIVISUAL == 2 then /*완전개별(누가 걸어도 중첩가능)*/
					set b = main.create(ID,caster,target,duration,NAME)
					set b.icon = ICON_PATH
					call b.init()
				elseif INDIVISUAL == 1 then /*캐스터&타겟 매칭(시전자가 다르면 중첩가능)*/
					set b = Buff.getMatchingCasterAndTarget(caster,target,ID)
					if b == 0 then
						set b = main.create(ID,caster,target,duration,NAME)
						set b.icon = ICON_PATH
						call b.init()
					else
						if duration > b.duration then
							set b.duration = duration
							if b.duration_max < duration then
								set b.duration_max = duration
							endif
						endif
						set b.caster = caster
						call b.update()
					endif
				elseif INDIVISUAL == 0 then	/*완전공용(무조건 중첩불가, 타겟 당 하나씩만)*/
					set b = Buff.getUnitBuffById(target,ID)
					if b == 0 then
						set b = main.create(ID,caster,target,duration,NAME)
						set b.icon = ICON_PATH
						call b.init()
					else
						if duration > b.duration then
							set b.duration = duration
							if b.duration_max < duration then
								set b.duration_max = duration
							endif
						endif
						set b.caster = caster
						call b.update()
					endif
				endif
				return b
			endfunction

			private function cond takes nothing returns nothing
				if BUFF_CREATE_ID == ID and BUFF_CREATE_TARGET > 0 then
					set BUFF_LAST_CREATED = new(BUFF_CREATE_CASTER,BUFF_CREATE_TARGET,BUFF_CREATE_DURATION)
				endif
			endfunction

			private function init takes nothing returns nothing
				call TriggerAddCondition(BUFF_CREATE_TRIGGER,function cond)
			endfunction

	//! endtextmacro

	globals
		trigger BUFF_CREATE_TRIGGER = CreateTrigger()
		trigger BUFF_REFRESH_TRIGGER = CreateTrigger()
		integer BUFF_CREATE_ID = -1
		integer BUFF_CREATE_CASTER = -1
		integer BUFF_CREATE_TARGET = -1
		real 	BUFF_CREATE_DURATION = 0.
		integer BUFF_LAST_CREATED = -1
	endglobals

	struct Buff

		static hashtable HASH = InitHashtable()

		private thistype node_prev = -1
		private thistype node_next = -1

		Unit_prototype caster = 0
		Unit_prototype target = 0
		integer id = 0
		Effect buff_effect = 0
		integer level = 0

		timer main_timer = null
		real duration_true = 0.
		real duration_max = 0.
		boolean duration_display = true
		real timeout = 0.
		real interval = 0.
		string icon = ""
		string name = ""
		boolean icon_display = true

		boolean want_kill = false

		static method add takes Unit_prototype caster, Unit_prototype target, integer id, real duration returns thistype
			set BUFF_LAST_CREATED = 0
			set BUFF_CREATE_CASTER = caster
			set BUFF_CREATE_TARGET = target
			set BUFF_CREATE_ID = id
			set BUFF_CREATE_DURATION = duration
			call TriggerEvaluate(BUFF_CREATE_TRIGGER)
			call TriggerEvaluate(BUFF_REFRESH_TRIGGER)
			return BUFF_LAST_CREATED
		endmethod
		
		static method getUnitRootBuff takes Unit_prototype target returns thistype
			if HaveSavedInteger(HASH,target,0) then
				return LoadInteger(HASH,target,0)
			else
				return 0
			endif
		endmethod

		static method getMatchingCasterAndTarget takes Unit_prototype caster, Unit_prototype target, integer id returns thistype
			local thistype b = getUnitRootBuff(target)
			if b > 0 then
				loop
					if b.id == id and b.caster == caster then
						return b
					else
						if b.node_next > 0 then
							set b = b.node_next
						else
							return 0
						endif
					endif
				endloop
			else
				return 0
			endif
			return 0
		endmethod

		static method getUnitBuffById takes Unit_prototype target, integer id returns integer
			local thistype b = getUnitRootBuff(target)
			if b > 0 then
				loop
					if b.id == id then
						return b
					else
						if b.node_next > 0 then
							set b = b.node_next
						else
							return 0
						endif
					endif
				endloop
			else
				return 0
			endif
			return 0
		endmethod

		static method unitHasBuff takes Unit_prototype target, integer id returns boolean
			return getUnitBuffById(target,id) > 0
		endmethod

		static method unitDestroyBuffs takes Unit_prototype target returns nothing
			local thistype b = 0
			loop
				set b = getUnitRootBuff(target)
				exitwhen b <= 0
				call b.destroy()
			endloop
		endmethod

		method addEffect takes Effect ef returns nothing
			if .buff_effect > 0 then
				call .buff_effect.kill()
				set .buff_effect = 0
			endif
			set .buff_effect = ef
		endmethod

		stub method addValue takes integer level returns nothing

		endmethod

		stub method init takes nothing returns nothing
		
		endmethod

		stub method update takes nothing returns nothing

		endmethod

		stub method intervalAction takes nothing returns nothing

		endmethod

		stub method periodicAction takes nothing returns nothing

		endmethod

		static method timerAction takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			set .duration_true = .duration_true - TIMER_TICK
			set .timeout = .timeout + TIMER_TICK
			call periodicAction()
			if .interval > 0. and .timeout >= .interval then
				loop
					exitwhen .timeout < .interval
					call intervalAction()
					set .timeout = .timeout - .interval
				endloop
			endif
			if .duration_true <= 0. then
				call destroy()
			endif
		endmethod

		method operator duration takes nothing returns real
			return .duration_true
		endmethod

		method operator duration= takes real nv returns nothing
			if nv > 0. then
				if .main_timer == null then
					set .main_timer = Timer.new(this)
					call Timer.start(.main_timer,TIMER_TICK,true,function thistype.timerAction)
				endif
			elseif nv == 0. then
				if .main_timer != null then
					call Timer.release(.main_timer)
					set .main_timer = null
				endif
				set .timeout = 0.
			else
				call destroy()
				return
			endif
			set .duration_true = nv
		endmethod

		method linkNode takes nothing returns nothing
			local thistype b = getUnitRootBuff(.target)
			if b > 0 then
				loop
					if b.node_next == -1 then
						set b.node_next = this
						set .node_prev = b
						exitwhen true
					else
						set b = b.node_next
					endif
				endloop
			else
				call SaveInteger(HASH,.target,0,this)
			endif
		endmethod

		method unlinkNode takes nothing returns nothing
			if this == getUnitRootBuff(.target) then
				if .node_next > 0 then
					call SaveInteger(HASH,.target,0,.node_next)
					set .node_next.node_prev = -1
				else
					call RemoveSavedInteger(HASH,.target,0)
				endif
			else
				set .node_prev.node_next = .node_next
				if .node_next > 0 then
					set .node_next.node_prev = .node_prev
				endif
			endif
		endmethod

		method relativeTooltip takes nothing returns string
			return "TooltipMissing"
		endmethod

		static method create takes integer id, Unit_prototype caster, Unit_prototype target, real duration, string name returns thistype
			local thistype this = allocate()
			set .id = id
			set .caster = caster
			set .target = target
			set .duration = duration
			set .duration_max = duration
			call linkNode()
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			if .buff_effect > 0 then
				call .buff_effect.kill()
				set .buff_effect = 0
			endif
			call unlinkNode()
			if .main_timer != null then
				call Timer.release(.main_timer)
			endif
			set .main_timer = null
		endmethod

	endstruct

endlibrary


/*스턴*/
scope BuffStun initializer init
	//! runtextmacro buffHeader("기절","Stun","0","BTNStun")

	public struct main extends Buff

		Effect ef = 0

		method update takes nothing returns nothing
			//call BJDebugMsg("Stun.update()")
		endmethod

		method init takes nothing returns nothing
			call .target.plusStatus(STATUS_STUN)
			set ef = Effect.createAttatched("Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl",.target.origin_unit,"overhead")
		endmethod

		method onDestroy takes nothing returns nothing
			call .target.minusStatus(STATUS_STUN)
			call ef.kill()
		endmethod

	endstruct

	//! runtextmacro buffEnd()
endscope

/*속박*/
scope BuffEnsn initializer init
	//! runtextmacro buffHeader("속박","Ensn","0","BTNEnsnare")

	public struct main extends Buff

		method update takes nothing returns nothing
			//call BJDebugMsg("Ensn.update()")
		endmethod

		method init takes nothing returns nothing
			call .target.plusStatus(STATUS_ENSNARE)
		endmethod

		method onDestroy takes nothing returns nothing
			call .target.minusStatus(STATUS_ENSNARE)
		endmethod

	endstruct

	//! runtextmacro buffEnd()
endscope
