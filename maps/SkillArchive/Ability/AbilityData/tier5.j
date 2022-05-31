/*0040 화룡의 숨결*/
scope Ability0040 initializer init
	//! runtextmacro abilityDataHeader("0040","화룡의 숨결","BTNstorm_ui_icon_deathwing_molten_flame","5","STAT_TYPE_MAGICPOWER","STAT_TYPE_MAGIC_PENET")

	globals
		private constant real CAST = 0.75
		private constant real INTERVAL = 0.2
		private constant integer COUNT = 15
		private constant real DAMAGE_PER_MAGICPOWER = 0.4
		private constant real DAMAGE_PER_LEVEL = 0.25
		private constant real IGNORE_GUARD = 0.5
		private constant real EXPRAD = 250.
		private constant real RANGE = 800.
		private constant real DRAGON_DIST = 800.
		private constant real FIRE_OFFSET = 200.
		private constant integer ALPHA = 200
		private constant string EFFECT_PATH1 = "units\\creeps\\RedDragon\\RedDragon.mdl"
		private constant string EFFECT_PATH2 = "Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl"
		private constant string EFFECT_PATH3 = "Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl"
		private constant string EFFECT_PATH4 = "Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl"
		private constant string EFFECT_PATH5 = "Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeTarget.mdl"
	endglobals

	private struct mystruct

		static real DURATION = 1.

		real timeout = 0.
		timer t = null
		Effect ef = 0
		boolean b = false

		static method act takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			set .timeout = .timeout + TIMER_TICK
			set .ef.z = .ef.z + 500*TIMER_TICK
			call .ef.setAlpha(R2I(ALPHA*(DURATION-.timeout)))
			if .timeout >= 0.6 and not b then
				call .ef.setAnim(ANIM_TYPE_STAND)
				set .b = true
			endif
			if .timeout >= DURATION then
				call destroy()
			endif
		endmethod

		static method create takes Effect ef returns thistype
			local thistype this = allocate()
			set .ef = ef
			set .t = Timer.new(this)
			call .ef.setAnimSpeed(1.)
			call Timer.start(.t,TIMER_TICK,true,function thistype.act)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			set .ef.want_remove = true
			call .ef.destroy()
			call Timer.release(.t)
			set .ef = 0
			set .t = null
		endmethod

	endstruct	

	public struct explosion extends Explosion

		Circle c = 0
		Effect ef = 0
		Effect ef2 = 0

		integer level = 0

		method beforeExplosion takes nothing returns nothing
			local Effect e = Effect.create(EFFECT_PATH3,Math.pPX(.x,EXPRAD/2,GetRandomReal(0,360)),Math.pPY(.y,EXPRAD/2,GetRandomReal(0,360)),GetRandomReal(2,55),270)
			call e.setDuration(1.25)
			call e.setScale(GetRandomReal(0.25,0.75))
			set e = 0
			set e = Effect.create(EFFECT_PATH4,Math.pPX(.ef.x,FIRE_OFFSET,.ef.yaw),Math.pPY(.ef.y,FIRE_OFFSET,.ef.yaw),DRAGON_DIST-FIRE_OFFSET,.ef.yaw)
			call e.setPitch(135)
			call e.setDuration(1.5)
			call e.setAnimSpeed(2.)
			call e.setMatrixScale(1.,1.,3.5)
		endmethod

		method executeExplosion takes Unit_prototype target returns nothing
			local Effect e = Effect.create(EFFECT_PATH2,target.x,target.y,target.z+target.pivot_z,270)
			local Buff bf = 0
			call e.kill()
			if IsUnitInGroup(target.origin_unit,.group_wave) then
				set .is_onhit = false
			else
				set .is_onhit = true
			endif
			call target.divideStatValue(STAT_TYPE_RESISTANCE,1)
			call damageTarget(target)
			call target.divideStatValue(STAT_TYPE_RESISTANCE,-1)
		endmethod

		static method create takes Unit caster, real x, real y, real rad, integer level, Effect ef returns thistype
			local thistype this = allocate(caster,x,y,rad)
			set .level = level
			set .interval_type = INTERVAL_TYPE_PERIODIC
			set .interval = INTERVAL
			set .damage_id = ID
			set .count = COUNT
			set .c = Circle.create(.x,.y,2.,EXPRAD)
			call .c.setColor(255,R2I(255*0.65),0)
			call .c.setAlpha(0)
			call .c.fadeIn(0.45)
			set .ef = ef
			call .ef.setAnimSpeed(0.)
			set .ef2 = Effect.create(EFFECT_PATH5,.x,.y,0.,0.)
			call .ef2.setScale(0.75)
			call .ef2.setAnimSpeed(2.)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call .c.setFadeOutPoint(0.01,0.75)
			set .c = 0
			call mystruct.create(.ef)
			set .ef = 0
			call .ef2.kill()
		endmethod

	endstruct

	public struct actor extends UnitActor

		Effect ef = 0
		boolean b = false

		method periodicAction takes nothing returns nothing
			local explosion ex = 0
			if .stage == 0 then
				set .ef.z = DRAGON_DIST+(500.-(500.*.timeout/CAST))
				if .timeout >= CAST then
					set ex = explosion.create(.caster,.x,.y,EXPRAD,.level,.ef)
					set ex.damage = ( .caster.magic_power * DAMAGE_PER_MAGICPOWER ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) )
					call ex.activate()
					set .stage = 1
					set .timeout = 0.
				endif
			elseif .stage == 1 then
				if .b then
					set .ef.offset_z = 2.5
				else
					set .ef.offset_z = -2.5
				endif
				set .b = not .b
				if .timeout >= COUNT*INTERVAL then
					set .want_destroy = true
				endif
			endif
		endmethod

		static method create takes Unit caster, real x, real y, integer level returns thistype
			local real a = Math.anglePoints(caster.x,caster.y,x,y)
			local thistype this = allocate(caster,0,x,y,level,-1,false)
			call suspendFree()
			set .ef = Effect.create(EFFECT_PATH1,Math.pPX(x,-DRAGON_DIST,a),Math.pPY(y,-DRAGON_DIST,a),DRAGON_DIST+(500.),a)
			call .ef.setAlpha(ALPHA)
			call .ef.setAnim(ANIM_TYPE_ATTACK)
			call .ef.setScale(3.)
			call .ef.setAnimSpeed(1.2)
			call .ef.setColor(255,R2I(255*0.65),0)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			set .ef = 0
		endmethod

	endstruct

	private struct ind extends AbilityIndicator

		Effect c = 0

		method refresh takes nothing returns nothing
			call .c.setPosition(Mouse.getVX(.owner),Mouse.getVY(.owner),2.)
		endmethod

		method show takes boolean flag returns nothing
			if flag then
				if GetLocalPlayer() == .owner then
					call .c.setLocalAlpha(192)
				endif
			else
				call .c.setLocalAlpha(0)
			endif
		endmethod

		static method create takes Ability_prototype abil, player owner returns thistype
			local thistype this = allocate(abil,owner)
			set .c = Effect.create("Effects\\RCircle.mdl",0.,0.,2.,270.)
			call .c.setScale(EXPRAD/100.)
			call .c.setLocalAlpha(0)
			call .c.setColor(255,R2I(255*0.65),0)
			call .circle.setColor(255,R2I(255*0.65),0)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call .c.destroy()
		endmethod

	endstruct

	public struct main extends Ability

		method relativeTooltip takes nothing returns string
			return "매 "+STRING_COLOR_CONSTANT+R2SW(INTERVAL,1,1)+"초|r마다 지정 범위 내의 적들에게 "+/*
			*/ConstantString.statStringReal(STAT_TYPE_MAGICPOWER,( .owner.magic_power * DAMAGE_PER_MAGICPOWER ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ),1)+/*
			*/"의 "+DAMAGE_STRING_MAGICAL+"를 입힙니다. 해당 공격은 대상의 저항력을 "+STRING_COLOR_CONSTANT+R2SW(IGNORE_GUARD*100,1,1)+"%|r 무시하며 총 "+STRING_COLOR_CONSTANT+I2S(COUNT)+"회|r 공격합니다.\n\n|cff999999다른 행동 중에 사용할 수 있습니다.|r"
		endmethod

		method execute takes nothing returns nothing
			local actor a = actor.create(.owner,.command_x,.command_y,level)
		endmethod

		method init takes nothing returns nothing
			set .is_active = true
			set .cast_range = RANGE
			set .preserve_order = true
			set .useable_cast = true
			set .cooldown_max = 25.
			set .cooldown_min = 5.
			set .manacost = 100
			set .indicator = ind.create(this,.owner.owner)
			call plusStatValue(5)
		endmethod

		static method onInit takes nothing returns nothing
			call Ability.addTypeTag(ID,ABILITY_STRING_TARGET_LOCATION)
			call Ability.addTypeTag(ID,ABILITY_TAG_FIRE)
			call Ability.addTypeTag(ID,ABILITY_TAG_DRAGON)
			call Ability.setTypeTooltip(ID,"지정 범위 초토화\n ")
		endmethod

	endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

scope AddRandomAbility5 initializer init

	private function init takes nothing returns nothing
		call Ability.addRandomAbility('0040',5)
	endfunction

endscope