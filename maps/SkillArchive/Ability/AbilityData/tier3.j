/*0020 기관총 난사*/
scope Ability0020 initializer init
	//! runtextmacro abilityDataHeader("0020","기관총 난사","BTNFlakCannons","3","STAT_TYPE_ATTACK","STAT_TYPE_ACCURACY")
	
		globals
			private constant real INTERVAL = 0.125
			private constant integer COUNT = 8
			private constant real DAMAGE_PER_ATTACK = 0.45
			private constant real DAMAGE_PER_LEVEL = 0.15
			private constant real BACKSWING = 0.15
			private constant real STARTAT = 32.5
			private constant real COLRAD = 65.
			private constant real VELO = 1875.
			private constant real RANGE = 750.
			private constant string EFFECT_PATH1 = "Effects\\Bullet.mdl"
			private constant string EFFECT_PATH2 = "Abilities\\Weapons\\Rifle\\RifleImpact.mdl"
		endglobals
	
		private struct bullet extends Missile

			method executeTarget takes Unit_prototype target returns nothing
				call damageTarget(target)
				call Effect.create(EFFECT_PATH2,target.x,target.y,target.z+target.pivot_z,270).setDuration(1.5)
			endmethod

			static method create takes Unit owner, real x, real y, real z, real yaw, integer level returns thistype
				local thistype this = allocate(owner,EFFECT_PATH1,x,y,z,yaw)
				local Effect ef
				set .velo = VELO
				set .damage = ( .owner.attack * DAMAGE_PER_ATTACK ) * ( 1+DAMAGE_PER_LEVEL*(level-1) )
				set .damage_id = ID
				call setCollision(COLRAD)
				call setDuration((RANGE-STARTAT)/VELO)
				call damageFlagTemplateTargetMagic()
				set .damage_type = DAMAGE_TYPE_PHYSICAL
				set .weapon_type = WEAPON_TYPE_METAL_LIGHT_CHOP
				set ef = Effect.create(EFFECT_PATH2,Math.pPX(.x,STARTAT,yaw),Math.pPY(.y,STARTAT,yaw),.z,270).setScale(1.5).setDuration(1.5)
				set ef.movement = Movement.create(ef,VELO*0.23,yaw)
				return this
			endmethod

		endstruct

		public struct actor extends UnitActor
	
			integer count = COUNT
			real angle = 0.
			real shoot = 0.
			Mover mover = 0

			method onComplete takes nothing returns nothing
				local bullet ms = 0
				if .count > 0 then
					set ms = bullet.create(.caster,/*
					*/Math.pPX(.caster.x,STARTAT,.angle),/*
					*/Math.pPY(.caster.y,STARTAT,.angle),.caster.z+.caster.pivot_z,/*
					*/.angle,.level)
				endif
			endmethod

			method periodicAction takes nothing returns nothing
				local bullet ms = 0
				set .shoot = .shoot + TIMER_TICK
				if .shoot >= INTERVAL and .count > 0 then
					set ms = bullet.create(.caster,/*
					*/Math.pPX(.caster.x,STARTAT,.angle),/*
					*/Math.pPY(.caster.y,STARTAT,.angle),.caster.z+.caster.pivot_z,/*
					*/.angle+GetRandomReal(-3,3),.level)
					set .caster.yaw = .angle
					set .count = .count - 1
					set .shoot = .shoot - INTERVAL
					if .count > 0 then
						call .caster.setAnim("stand")
						call .caster.setAnim("attack")
						call .caster.setAnimSpeed(3.)
					endif
				endif
			endmethod
	
			static method create takes Unit u, real x, real y, integer level returns thistype
				local thistype this = allocate(u,0,x,y,level,INTERVAL*COUNT,true)
				set .angle = Math.anglePoints(.caster.x,.caster.y,x,y)
				call .caster.setAnim("attack")
				call .caster.setAnimSpeed(3.)
				set .caster.yaw = .angle
				set .progress_bar = ProgressBar.create(NAME,.caster.owner)
				set .progress_bar.reverse = true
				set .mover = Mover.create(.caster)
				set .mover.refresh_facing = false
				return this
			endmethod

			method onDestroy takes nothing returns nothing
				call .caster.queueAnim("stand ready")
				call .caster.setAnimSpeed(1.)
				call .mover.destroy()
			endmethod
	
		endstruct

		private struct ind extends LineIndicator

			method beforeRefresh takes nothing returns nothing
				set .x = .abil.owner.x
				set .y = .abil.owner.y
				set .yaw = Math.anglePoints(.x,.y,Mouse.getVX(owner),Mouse.getVY(owner))
				set .range = RANGE
				set .width = COLRAD
			endmethod

			static method create takes Ability_prototype abil, player owner returns thistype
				local thistype this = allocate(abil,owner)
				return this
			endmethod

		endstruct
	
		public struct main extends Ability
	
			method relativeTooltip takes nothing returns string
				return "지정한 방향으로 "+STRING_COLOR_CONSTANT+I2S(COUNT)+"발|r의 총알을 난사하여 발 당 "+/*
				*/ConstantString.statStringReal(STAT_TYPE_ATTACK,( .owner.attack * DAMAGE_PER_ATTACK ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ),1)+/*
				*/"의 "+DAMAGE_STRING_PHYSICAL+"를 입힙니다.\n\n|cff999999사용하면서 움직일 수 있습니다.|r"
			endmethod

			method execute takes nothing returns nothing
				local actor a = actor.create(.owner,.command_x,.command_y,level)
			endmethod
	
			method init takes nothing returns nothing
				set .is_active = true
				set .preserve_order = true
				set .cooldown_max = 0.5//8.
				set .cooldown_min = 0.5//1.5
				set .manacost = 26
				set .indicator = ind.create(this,.owner.owner)
				call plusStatValue(5)
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.addTypeTag(ID,ABILITY_STRING_TARGET_LOCATION)
				call Ability.addTypeTag(ID,ABILITY_TAG_FIREARM)
				call Ability.addTypeTag(ID,ABILITY_TAG_SHOOTING)
				call Ability.setTypeTooltip(ID,"지정한 방향으로\n다수의 투사체 발사")
			endmethod
	
		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

/*0021 감속(버프)*/
scope Buff0021 initializer init
	//! runtextmacro buffHeader("감속","0021","1","BTNSlow")

	public struct main extends Buff

		static constant real DAMAGE_PER_MAGICPOWER = 0.10
		static constant real DAMAGE_PER_LEVEL = 0.15
		static constant real REDUCE_VAL = 0.2
		static constant integer SLOW = 15
		static constant string EFFECT_PATH1 = "Abilities\\Spells\\Human\\slow\\slowtarget.mdl"

		integer val1 = 0
		real val2 = 0.

		method addValue takes integer level returns nothing
			call .target.minusStatValue(STAT_TYPE_MOVEMENT_SPEED,SLOW)
			call .target.plusStatValue(STAT_TYPE_EVASION,(.caster.magic_power * DAMAGE_PER_MAGICPOWER) * (1+DAMAGE_PER_LEVEL*(level-1)) * REDUCE_VAL)
			set .val1 = .val1 + SLOW
			set .val2 = .val2 + (.caster.magic_power * DAMAGE_PER_MAGICPOWER) * (1+DAMAGE_PER_LEVEL*(level-1)) * REDUCE_VAL
		endmethod

		method update takes nothing returns nothing

		endmethod

		method init takes nothing returns nothing
			call addEffect(Effect.createAttatched(EFFECT_PATH1,.target.origin_unit,"origin"))
		endmethod

		method onDestroy takes nothing returns nothing
			call .target.minusStatValue(STAT_TYPE_MOVEMENT_SPEED,-val1)
			call .target.plusStatValue(STAT_TYPE_EVASION,-val2)
		endmethod

	endstruct

	//! runtextmacro buffEnd()
endscope

/*0021 감속*/
scope Ability0021 initializer init
	//! runtextmacro abilityDataHeader("0021","감속","BTNSlow","3","STAT_TYPE_MAGICPOWER","STAT_TYPE_MPREGEN")

	globals
		private constant real CAST = 0.25
		private constant real INTERVAL = 0.5
		private constant integer COUNT = 10
		private constant real DAMAGE_PER_MAGICPOWER = 0.10
		private constant real DAMAGE_PER_LEVEL = 0.15
		private constant real REDUCE_VAL = 0.2
		private constant real DURATION = 4.5
		private constant integer SLOW = 15
		private constant real BACKSWING = 0.15
		private constant real EXPRAD = 200.
		private constant real RANGE = 800.
		private constant string EFFECT_PATH1 = "Abilities\\Spells\\Human\\slow\\slowtarget.mdl"
		private constant string EFFECT_PATH2 = "Abilities\\Spells\\Human\\Slow\\SlowCaster.mdl"
		private constant string EFFECT_PATH3 = "Abilities\\Spells\\Orc\\Disenchant\\DisenchantSpecialArt.mdl"
	endglobals

	public struct explosion extends Explosion

		Circle c = 0
		Effect ef = 0

		integer level = 0

		method beforeExplosion takes nothing returns nothing
			local Effect e = Effect.create(EFFECT_PATH3,.x,.y,GetRandomReal(2,55),270)
			call e.setDuration(1.25)
			call e.setScale(GetRandomReal(1.5,3))
		endmethod

		method executeExplosion takes Unit_prototype target returns nothing
			local Effect e = Effect.create(EFFECT_PATH2,target.x,target.y,target.z+target.pivot_z,270)
			local Buff bf = 0
			call e.setDuration(1.5)
			if IsUnitInGroup(target.origin_unit,.group_wave) then
				set .is_onhit = false
			else
				set .is_onhit = true
			endif
			set bf = Buff.add(.owner,target,ID,DURATION)
			call bf.addValue(.level)
			call damageTarget(target)
		endmethod

		static method create takes Unit caster, real x, real y, real rad, integer level returns thistype
			local thistype this = allocate(caster,x,y,rad)
			set .level = level
			set .interval_type = INTERVAL_TYPE_PERIODIC
			set .interval = INTERVAL
			set .damage_id = ID
			set .count = COUNT
			set .c = Circle.create(.x,.y,2.,EXPRAD)
			call .c.setColor(255,R2I(255*0.9),0)
			call .c.setAlpha(0)
			call .c.fadeIn(0.45)
			set .ef = Effect.create(EFFECT_PATH1,.x,.y,2.,270)
			call .ef.setScale(2.5)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call .c.setFadeOutPoint(0.01,0.75)
			set .c = 0
			call .ef.kill()
		endmethod

	endstruct

	public struct actor extends UnitActor

		method onComplete takes nothing returns nothing
			local explosion ex = explosion.create(.caster,.x,.y,EXPRAD,.level)
			set ex.damage = ( .caster.magic_power * DAMAGE_PER_MAGICPOWER ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) )
			call ex.activate()
		endmethod

		static method create takes Unit caster, real x, real y, integer level returns thistype
			local thistype this = allocate(caster,0,x,y,level,CAST,true)
			call SetUnitFacing(.caster.origin_unit,Math.anglePoints(.caster.x,.caster.y,x,y))
			call .caster.setAnim("attack")
			call .caster.setAnimSpeed(2.)
			set .progress_bar = ProgressBar.create(NAME,.caster.owner)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call .caster.queueAnim("stand ready")
			call .caster.setAnimSpeed(1.)
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
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call .c.destroy()
		endmethod

	endstruct

	public struct main extends Ability

		method relativeTooltip takes nothing returns string
			return "매 "+STRING_COLOR_CONSTANT+R2SW(INTERVAL,1,1)+"초|r마다 "+/*
			*/ConstantString.statStringReal(STAT_TYPE_MAGICPOWER,( .owner.magic_power * DAMAGE_PER_MAGICPOWER ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ),1)+/*
			*/"의 "+DAMAGE_STRING_MAGICAL+"를 입히는 영역을 전개합니다. 대상은 피해를 입을 때 마다 "+/*
			*/STRING_COLOR_CONSTANT+R2SW(DURATION,1,1)+"초|r 동안 "+STAT_TYPE_NAME[STAT_TYPE_MOVEMENT_SPEED]+"가 "+/*
			*/STRING_COLOR_CONSTANT+I2S(SLOW)+"|r, "+STAT_TYPE_NAME[STAT_TYPE_EVASION]+"가 "+/*
			*/ConstantString.statStringReal(STAT_TYPE_MAGICPOWER,( .owner.magic_power * DAMAGE_PER_MAGICPOWER ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ) * REDUCE_VAL,1)+/*
			*/" 감소합니다. 총 "+STRING_COLOR_CONSTANT+I2S(COUNT)+"회|r 공격합니다."
		endmethod

		method execute takes nothing returns nothing
			local actor a = actor.create(.owner,.command_x,.command_y,level)
		endmethod

		method init takes nothing returns nothing
			set .is_active = true
			set .cast_range = RANGE
			set .preserve_order = false
			set .cooldown_max = 10.
			set .cooldown_min = 4.
			set .manacost = 30
			set .indicator = ind.create(this,.owner.owner)
			call plusStatValue(5)
		endmethod

		static method onInit takes nothing returns nothing
			call Ability.addTypeTag(ID,ABILITY_STRING_TARGET_LOCATION)
			call Ability.addTypeTag(ID,ABILITY_TAG_MAGIC)
			call Ability.setTypeTooltip(ID,"이동속도, 회피치\n감소 영역 전개")
		endmethod

	endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

scope AddRandomAbility3 initializer init

	private function init takes nothing returns nothing
		call Ability.addRandomAbility('0020',3)
		call Ability.addRandomAbility('0021',3)
	endfunction

endscope