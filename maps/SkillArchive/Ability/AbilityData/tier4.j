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

/*0031 유성 낙하*/
scope Ability0031 initializer init
	//! runtextmacro abilityDataHeader("0031","유성 낙하","BTNFireRocks","4","STAT_TYPE_MAGICPOWER","STAT_TYPE_MAXMP")

	globals
		private constant real CAST = 0.25
		private constant real DELAY = 0.5
		private constant real DAMAGE_PER_MAGICPOWER = 3.2
		private constant real DAMAGE_PER_LEVEL = 0.2
		private constant real DAMAGE_ADDITIONAL = 0.25
		private constant real EXPRAD = 200.
		private constant real RANGE = 800.
		private constant real RANGE_SECOND = 1500.
		private constant real VELO = 1500.
		private constant real BALL_DIST = 1000.
		private constant real BALL_HEIGHT = 600.
		private constant real EFFECT_INTERVAL = 0.12
		private constant string EFFECT_PATH1 = "units\\human\\phoenix\\phoenix.mdl"
		private constant string EFFECT_PATH2 = "Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl"
		private constant string EFFECT_PATH3 = "Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl"
	endglobals

	private struct ball extends Missile

		integer level = 0
		integer stage = 0
		Circle c = 0
		real to = 0.

		method periodicAction takes nothing returns nothing
			if .c > 0 then
				set .c.x = .x
				set .c.y = .y
			endif
			if .stage == 1 then
				set .to = .to + TIMER_TICK
				if .to >= EFFECT_INTERVAL then
					call Effect.create(EFFECT_PATH2,.x,.y,125.,.yaw).setPitch(-90).setDuration(1.0).setAnimSpeed(2.)
					set .to = .to - EFFECT_INTERVAL
				endif
			endif
		endmethod

		method afterWave takes nothing returns nothing
			local real d = SquareRoot(GetRandomReal(0,(EXPRAD/2)*(EXPRAD/2)))
			local real a = GetRandomReal(0,360)
			call Effect.create(EFFECT_PATH3,Math.pPX(.x,d,a),Math.pPY(.y,d,a),0.,.yaw).setDuration(1.5).setScale(2.).setPitch(-30.)
		endmethod

		method executeWave takes Unit target returns nothing
			call damageTarget(target)
			call Effect.create(EFFECT_PATH2,target.x,target.y,target.z+55.,.yaw).setScale(0.5).setDuration(1.5).setPitch(-90)
		endmethod

		method afterExplosion takes nothing returns nothing
			local Effect ef = Effect.create(EFFECT_PATH2,.x,.y,125.,.yaw)
			call ef.setDuration(1.0)
			call ef.setPitch(-90)
			call resetTargetLocation()
			set .movement.curve = 0
			set .movement.refresh_facing = false
			set .velo = VELO
			set .pitch = 20.
			call setDuration(RANGE_SECOND/VELO)
			call setWave(EXPRAD)
			call setColor(255,255,153)
			set .c = Circle.create(.x,.y,1.,EXPRAD)
			call .c.setColor(255,R2I(0.65*255),0)
			call .c.fadeIn(CAST)
		endmethod

		method executeExplosion takes Unit target returns nothing

		endmethod

		method killFilter takes nothing returns boolean
			if .stage == 0 then
				set .stage = 1
				set .want_kill = false
				return false
			endif
			return true
		endmethod

		static method create takes Unit caster, real x, real y, real angle, integer level returns thistype
			local real tx = Math.pPX(x,BALL_DIST,angle+180)
			local real ty = Math.pPY(y,BALL_DIST,angle+180)
			local thistype this = allocate(caster,EFFECT_PATH1,tx,ty,BALL_HEIGHT,angle)
			call setYaw(90.)
			set .movement.curve = Bezier2.create(tx,ty,BALL_HEIGHT,x,y,0.)
			set .movement.curve.overtime = DELAY
			call .movement.curve.setX(INDEX_POINT_MIDDLE,tx)
			call .movement.curve.setY(INDEX_POINT_MIDDLE,ty)
			call .movement.curve.setZ(INDEX_POINT_MIDDLE,0.)
			set .movement.refresh_facing = true
			set .offset_z = 125.
			call setScale(2.)
			set .level = level
			call setTargetLocation(x,y,0.)
			call setExplosion(EXPRAD)
			call damageFlagTemplateMagicalExplosion()
			set .damage_id = ID
			set .damage = (.owner.magic_power * DAMAGE_PER_MAGICPOWER ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) )
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			if .c > 0 then
				call .c.setFadeOutPoint(0.,1.25)
			endif
			set .c = 0
		endmethod

	endstruct

	private struct actor extends UnitActor

		real angle = 0.

		method onComplete takes nothing returns nothing
			call ball.create(caster,x,y,angle,level)
		endmethod

		static method create takes Unit caster, real x, real y, real angle, integer level returns thistype
			local thistype this = allocate(caster,0,x,y,level,CAST,true)
			call .caster.setAnim("attack")
			call .caster.setAnim("spell")
			call .caster.queueAnim("stand ready")
			call .caster.setAnimSpeed(1.66)
			set .angle = angle
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call .caster.setAnimSpeed(1.)
		endmethod

	endstruct

	private struct ind extends LineIndicator

		method beforeRefresh takes nothing returns nothing
			set .yaw = Math.anglePoints(.abil.command_x_temp,.abil.command_y_temp,Mouse.getVX(owner),Mouse.getVY(owner))
			set .x = Math.pPX(.abil.command_x_temp,-EXPRAD,.yaw)
			set .y = Math.pPY(.abil.command_y_temp,-EXPRAD,.yaw)
			set .range = RANGE_SECOND+EXPRAD*2
			set .width = EXPRAD
		endmethod

		static method create takes Ability_prototype abil, player owner returns thistype
			local thistype this = allocate(abil,owner)
			call .ef.setColor(255,R2I(0.65*255),0)
			call .circle.setColor(255,R2I(0.65*255),0)
			return this
		endmethod

	endstruct

	public struct main extends Ability

		method relativeTooltip takes nothing returns string
			return "지정 범위 내의 적들에게 "+ConstantString.statStringReal(STAT_TYPE_MAGICPOWER,( .owner.magic_power * DAMAGE_PER_MAGICPOWER ),1)+/*
			*/"의 "+DAMAGE_STRING_MAGICAL+"를 입힙니다."
		endmethod

		method execute takes nothing returns nothing
			local actor a = actor.create(.owner,.command_x,.command_y,Math.anglePoints(.command_x,.command_y,.command_x2,.command_y2),level)
		endmethod

		method init takes nothing returns nothing
			set .drag_to_use = true
			set .is_active = true
			set .cast_range = RANGE
			set .preserve_order = false
			set .cooldown_max = 0//9.
			set .cooldown_min = 0//3.
			set .manacost = 0//55
			set .indicator = ind.create(this,.owner.owner)
			call plusStatValue(5)
		endmethod

		static method onInit takes nothing returns nothing
			call Ability.addTypeTag(ID,ABILITY_STRING_DRAG_TO_USE)
			call Ability.addTypeTag(ID,ABILITY_TAG_FIRE)
			call Ability.addTypeTag(ID,ABILITY_TAG_MAGIC)
			call Ability.setTypeTooltip(ID,"직선범위 적 공격\n ")
		endmethod

	endstruct
	
	//! runtextmacro abilityDataEnd()
endscope


scope AddRandomAbility4 initializer init

	private function init takes nothing returns nothing
		call Ability.addRandomAbility('0030',4)
		call Ability.addRandomAbility('0031',4)
	endfunction

endscope