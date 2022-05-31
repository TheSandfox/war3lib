/*0030 미사일 컨테이너*/
scope Ability0030 initializer init
	//! runtextmacro abilityDataHeader("0030","미사일 컨테이너","BTNClusterRockets","4","STAT_TYPE_ATTACK","STAT_TYPE_SPELL_BOOST")
	
		globals
			private constant real DELAY = 0.2
			private constant integer COUNT = 20
			private constant real INTERVAL = 0.125
			private constant real DAMAGE_PER_ATTACK = 0.85
			private constant real DAMAGE_PER_LEVEL = 0.2
			private constant real DAMAGE_SECONDARY = 0.3
			private constant real BACKSWING = 0.15
			private constant real STARTAT = 32.5
			private constant real COLRAD = 65.
			private constant real EXPRAD = 500.
			private constant real VELO = 400.
			private constant real RANGE = 1200.
			private constant string EFFECT_PATH1 = "Effects\\MissilePod.mdl"
			private constant string EFFECT_PATH2 = "Abilities\\Spells\\Other\\TinkerRocket\\TinkerRocketMissile.mdl"
			private constant string EFFECT_PATH3 = "Abilities\\Weapons\\SearingArrow\\SearingArrowMissile.mdl"
		endglobals

		private struct mss extends Missile

			method executeTarget takes Unit target returns nothing
				if IsUnitInGroup(target.origin_unit,.group_wave) then
					set .damage = .damage * DAMAGE_SECONDARY
					set .is_onhit = false
				endif
				call damageTarget(target)
			endmethod

			static method create takes Unit caster, Unit target, real x, real y, real z, integer level returns thistype
				local real a = GetRandomReal(45,135)
				local thistype this = allocate(caster,EFFECT_PATH2,x,y,z,Math.anglePoints(x,y,target.x,target.y))
				local Bezier3 bz = 0
				call setTarget(target)
				set .curve = Bezier3.create(x,y,z,target.x,target.y,target.z+target.pivot_z)
				set .curve.overtime = 0.75
				set bz = .curve
				call bz.setProjectedControlPoint(0,-800, 300, a)
				call bz.setProjectedControlPoint(1, 0, 800, a)
				set .damage_id = ID
				set .damage = ( .owner.attack * DAMAGE_PER_ATTACK ) * ( 1+DAMAGE_PER_LEVEL*(level-1) )
				call damageFlagTemplateTargetMagic()
				set .damage_type = DAMAGE_TYPE_PHYSICAL
				set .weapon_type = WEAPON_TYPE_METAL_MEDIUM_BASH
				set .movement.refresh_facing = true
				return this
			endmethod

			method onDestroy takes nothing returns nothing
				set .pitch = 0.
			endmethod

		endstruct

		private struct ball extends Missile

			integer count_true = COUNT
			integer level = 0
			Circle c = 0

			MissileGroup mg = 0

			method periodicAction takes nothing returns nothing
				call .c.setPosition(.x,.y,2.)
			endmethod

			method executeWave takes Unit target returns nothing

			endmethod

			method beforeWave takes nothing returns nothing
				call GroupClear(.group_wave)
			endmethod

			method afterWave takes nothing returns nothing
				local Unit u = Unit_prototype.get(Group.getRandomUnit(.group_wave))
				local Missile ms = 0
				local Effect ef = 0
				if u > 0 then
					set ms = mss.create(.owner,u,.x,.y,.z,.level)
					call .mg.add(ms)
					set .count_true = .count_true - 1
					if .count_true <= 0 then
						set .want_kill = true
					endif
					set .velo = VELO*0.5
					set ef = Effect.create(EFFECT_PATH3,Math.pPX(.x,STARTAT*-1,Math.anglePoints(.x,.y,u.x,u.y)),/*
						*/Math.pPY(.y,STARTAT*-1,Math.anglePoints(.x,.y,u.x,u.y)),.z,Math.anglePoints(.x,.y,u.x,u.y))
					set ef.pitch = -90.
					call ef.kill()
				else
					set .velo = VELO
				endif
			endmethod

			static method create takes Unit caster, real x, real y, real z, real yaw, integer level returns thistype
				local thistype this = allocate(caster,EFFECT_PATH1,x,y,z,yaw)
				call setScale(3.)
				set .level = level
				set .velo = VELO
				set .mg = MissileGroup.create()
				call .mg.setDuration(15.)
				call setWave(EXPRAD)
				set .wave_interval = INTERVAL
				call setDuration(RANGE/VELO)
				set .c = Circle.createSpecific("Effects\\CastRangeCircle.mdl",x,y,2.,0.)
				call .c.setScale(EXPRAD/100.)
				call .c.setAlpha(192)
				return this
			endmethod

			method onDestroy takes nothing returns nothing
				call .mg.setDuration(15.)
				set .mg = 0
				call .c.setFadeOutPoint(0.,0.75)
			endmethod

		endstruct

		public struct actor extends UnitActor
	
			real angle = 0.

			method onComplete takes nothing returns nothing
				local ball ms = ball.create(.caster,/*
				*/Math.pPX(.caster.x,STARTAT,Math.anglePoints(.caster.x,.caster.y,.x,.y)),/*
				*/Math.pPY(.caster.y,STARTAT,Math.anglePoints(.caster.x,.caster.y,.x,.y)),75.,/*
				*/.angle,.level)
				call UnitActor.create(.caster,0,0.,0.,0,BACKSWING,true)
			endmethod
	
			static method create takes Unit u, real x, real y, real delay, integer level returns thistype
				local thistype this = allocate(u,0,x,y,level,delay,true)
				set .angle = Math.anglePoints(.caster.x,.caster.y,.x,.y)
				call .caster.setAnim("attack")
				call .caster.setAnim("spell")
				call .caster.setAnimSpeed(1.66)
				call SetUnitFacing(.caster.origin_unit,Math.anglePoints(.caster.x,.caster.y,x,y))
				set .progress_bar = ProgressBar.create(NAME,.caster.owner)
				return this
			endmethod

			method onDestroy takes nothing returns nothing
				call .caster.queueAnim("stand ready")
				call .caster.setAnimSpeed(1.)
			endmethod
	
		endstruct
	
		private struct ind extends LineIndicator

			method beforeRefresh takes nothing returns nothing
				set .yaw = Math.anglePoints(.abil.owner.x,.abil.owner.y,Mouse.getVX(owner),Mouse.getVY(owner))
				set .x = Math.pPX(.abil.owner.x,-EXPRAD,.yaw)
				set .y = Math.pPY(.abil.owner.y,-EXPRAD,.yaw)
				set .range = RANGE+EXPRAD*2
				set .width = EXPRAD
			endmethod

			static method create takes Ability_prototype abil, player owner returns thistype
				local thistype this = allocate(abil,owner)
				return this
			endmethod

		endstruct

		public struct main extends Ability
	
			method relativeTooltip takes nothing returns string
				return "지정한 방향으로 이동하는 미사일 컨테이너를 소환합니다. 미사일 컨테이너는 매 "+STRING_COLOR_CONSTANT+R2SW(INTERVAL,3,3)+"초|r 마다 "+/*
				*/ConstantString.statStringReal(STAT_TYPE_ATTACK,( .owner.attack * DAMAGE_PER_ATTACK ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ),1)+/*
				*/"의 "+DAMAGE_STRING_PHYSICAL+"를 입히는 미사일을 발사합니다. 적을 "+STRING_COLOR_CONSTANT+I2S(COUNT)+"회|r 공격하거나 "+STRING_COLOR_CONSTANT+/*
				*/R2SW(RANGE/VELO,1,1)+"초|r가 경과하면 미사일 컨테이너는 소멸됩니다.\n\n - 미사일 발사 시 미사일 컨테이너의 이동속도가 감소합니다.\n - 미사일은 같은 대상 공격 시 "+STRING_COLOR_CONSTANT+R2SW(DAMAGE_SECONDARY*100,1,1)+"%|r의 피해를 입힙니다."
			endmethod
	
			method execute takes nothing returns nothing
				call actor.create(.owner,.command_x,.command_y,.cast_delay,level)
			endmethod
	
			method init takes nothing returns nothing
				set .is_active = true
				set .preserve_order = false
				set .cooldown_max = 12.
				set .cooldown_min = 2.
				set .cast_delay = DELAY
				set .manacost = 50
				set .indicator = ind.create(this,.owner.owner)
				call plusStatValue(5)
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.addTypeTag(ID,ABILITY_STRING_TARGET_LOCATION)
				call Ability.addTypeTag(ID,ABILITY_TAG_FIREARM)
				call Ability.setTypeTooltip(ID,"연발 미사일 컨테이너 소환\n ")
			endmethod
	
		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

scope AddRandomAbility4 initializer init

	private function init takes nothing returns nothing
		call Ability.addRandomAbility('0030',4)
	endfunction

endscope