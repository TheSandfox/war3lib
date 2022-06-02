/*0010 물약 제조*//*0011 폭발, 0012 산성*/
//! import "Special\\MakePotion.j"

/*0013 소용돌이*/
scope Ability0013 initializer init
	//! runtextmacro abilityDataHeader("0013","소용돌이","BTNWhirlwind","2","STAT_TYPE_ATTACK","STAT_TYPE_ARMOR_PENET")
	
		globals
			private constant real INTERVAL = 0.25
			private constant integer COUNT = 8
			private constant real DAMAGE_PER_ATTACK = 0.3
			private constant real DAMAGE_PER_LEVEL = 0.1
			private constant real RAD = 200.
			private constant real ROTSPEED = 6.
			private constant string EFFECT_PATH1 = "Effects\\Whirlwind.mdl"
			private constant string EFFECT_PATH2 = "Abilities\\Weapons\\Rifle\\RifleImpact.mdl"
			private constant string EFFECT_PATH3 = "Effects\\WindSlash.mdl"
		endglobals

		private struct exp extends Explosion

			integer level = 0

			method executeExplosion takes Unit target returns nothing
				local Effect ef = 0
				if IsUnitInGroup(target.origin_unit,.group_wave) then
					set .damage = ( .owner.attack * DAMAGE_PER_ATTACK ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) )
				else
					set .damage = ( .owner.attack * DAMAGE_PER_ATTACK ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) )
				endif
				call damageTarget(target)
				call Effect.createAttatched(EFFECT_PATH2,target.origin_unit,"chest").setDuration(1.5)
				set ef = Effect.create(EFFECT_PATH3,target.x+GetRandomReal(-25,25),target.y,target.z+target.pivot_z+GetRandomReal(-25,25),270.)
				call ef.setRoll(GetRandomReal(0.,360.))
				call ef.setMatrixScale(1.25,1.25,2.)
				call ef.setAlpha(192)
				call ef.setDuration(1.0)
			endmethod

			method beforeExplosion takes nothing returns nothing
				set .x = .owner.x
				set .y = .owner.y
			endmethod

			static method create takes Unit caster, real x, real y, real rad, integer level returns thistype
				local thistype this = allocate(caster,x,y,rad)
				set .level = level
				set .damage_type = DAMAGE_TYPE_PHYSICAL
				set .weapon_type = WEAPON_TYPE_METAL_HEAVY_BASH
				set .is_ranged = false
				set .damage_id = ID
				set .damage = ( .owner.attack * DAMAGE_PER_ATTACK ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) )
				return this
			endmethod

		endstruct

		public struct actor extends UnitActor
	
			Mover mover = 0
			Explosion ex = 0
			Circle c = 0
			Effect ef = 0
			real anim_progress = 0.

			method periodicAction takes nothing returns nothing
				set .anim_progress = .anim_progress + TIMER_TICK
				call .c.setPosition(.caster.x,.caster.y,5.)
				set .caster.yaw = .caster.yaw + 360 * TIMER_TICK * ROTSPEED
				if .anim_progress >= INTERVAL then
					call .caster.setAnimSpeed(6.)
					call .caster.setAnim("stand")
					call .caster.setAnim("attack")
					set .anim_progress = .anim_progress - INTERVAL
				endif
			endmethod
	
			static method create takes Unit u, real x, real y, integer level returns thistype
				local thistype this = allocate(u,0,x,y,level,INTERVAL*COUNT,true)
				call .caster.setAnim("attack")
				call .caster.setAnimSpeed(2.)
				set .progress_bar = ProgressBar.create(NAME,.caster.owner)
				set .progress_bar.reverse = true
				set .mover = Mover.create(.caster)
				set .mover.refresh_facing = false
				set .ex = exp.create(.caster,.caster.x,.caster.y,RAD,level)
				set .ex.count = -1
				set .ex.interval = INTERVAL
				call .ex.activate()
				set .c = Circle.create(.caster.x,.caster.y,5.,RAD)
				set .c.alpha_max = 0.45
				set .c.alpha = 0.
				call .c.fadeIn(0.35)
				set .ef = Effect.createAttatched(EFFECT_PATH1,.caster.origin_unit,"origin")
				return this
			endmethod

			method onDestroy takes nothing returns nothing
				call .caster.queueAnim("stand ready")
				call .caster.setAnimSpeed(1.)
				call .mover.destroy()
				if .ex > 0 then
					call .ex.destroy()
				endif
				call .c.destroy()
				call .ef.kill()
			endmethod
	
		endstruct
	
		public struct main extends Ability
	
			method relativeTooltip takes nothing returns string
				return "주변의 적들을 무자비하게 강타하여 "+/*
				*/ConstantString.statStringReal(STAT_TYPE_ATTACK,( .owner.attack * DAMAGE_PER_ATTACK ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ),1)+/*
				*/"의 "+DAMAGE_STRING_PHYSICAL+"를 입힙니다. 총 "+STRING_COLOR_CONSTANT+I2S(COUNT)+"회|r 공격합니다.\n\n|cff999999사용하면서 움직일 수 있습니다.|r"
			endmethod

			method execute takes nothing returns nothing
				local actor a = actor.create(.owner,.command_x,.command_y,level)
			endmethod
	
			method init takes nothing returns nothing
				set .is_active = true
				set .preserve_order = true
				set .cooldown_max = 0.	
				set .cooldown_min = 0.
				set .manacost = 18
				set .is_immediate = true
				call plusStatValue(5)
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.addTypeTag(ID,ABILITY_STRING_IMMEDIATE)
				call Ability.addTypeTag(ID,ABILITY_TAG_IRON)
				call Ability.setTypeTooltip(ID,"주변 적 연속공격\n ")
			endmethod
	
		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

/*0014 카드 투척*/
scope Ability0014 initializer init
	//! runtextmacro abilityDataHeader("0014","카드 투척","BTNPickACard","2","STAT_TYPE_ACCURACY","STAT_TYPE_ATTACK")
	
		globals
			private constant real BACKSWING = 0.25
			private constant real STARTAT = 25.
			private constant string EFFECT_PATH1 = "Effects\\MagicCardRed.mdl"
			private constant string EFFECT_PATH2 = "Effects\\MagicCardBlue.mdl"
			private constant string EFFECT_PATH3 = "Effects\\MagicCardGold.mdl"
			private constant string EFFECT_PATH4 = "Effects\\MagicCardPurple.mdl"
			private constant real DAMAGE_PER_ATTACK = 0.55
			private constant real DAMAGE_PER_LEVEL = 0.1
			private constant integer NEED_TO = 4
			private constant real VELO = 1250
		endglobals

			//! textmacro Ability0014_tm0
				local integer rint = GetRandomInt(0,3)
				local real nx = Math.pPX(.caster.x,STARTAT,.caster.yaw)
				local real ny = Math.pPY(.caster.y,STARTAT,.caster.yaw)
				local Missile ms = 0
				/*빨*/
				if rint == 0 then
					set ms = Missile.create(.caster,EFFECT_PATH1,nx,ny,.caster.z+.caster.pivot_z,.caster.yaw)
					set ms.damage_type = DAMAGE_TYPE_PHYSICAL
					set ms.attack_type = ATTACK_TYPE_BASIC
				/*파*/
				elseif rint == 1 then
					set ms = Missile.create(.caster,EFFECT_PATH2,nx,ny,.caster.z+.caster.pivot_z,.caster.yaw)
					set ms.damage_type = DAMAGE_TYPE_MAGICAL
					set ms.attack_type = ATTACK_TYPE_BASIC
				/*노*/
				elseif rint == 2 then
					set ms = Missile.create(.caster,EFFECT_PATH3,nx,ny,.caster.z+.caster.pivot_z,.caster.yaw)
					set ms.damage_type = DAMAGE_TYPE_PHYSICAL
					set ms.attack_type = ATTACK_TYPE_SPELL
				/*보*/
				else
					set ms = Missile.create(.caster,EFFECT_PATH4,nx,ny,.caster.z+.caster.pivot_z,.caster.yaw)
					set ms.damage_type = DAMAGE_TYPE_MAGICAL
					set ms.attack_type = ATTACK_TYPE_SPELL
				endif
				set ms.damage_id = ID
				set ms.damage = (.caster.attack * DAMAGE_PER_ATTACK) * (1+DAMAGE_PER_LEVEL*(.level-1))
				set ms.radius_target = VELO*TIMER_TICK*0.5
				set ms.velo = VELO
				set ms.weapon_type = WEAPON_TYPE_WOOD_LIGHT_BASH
				call ms.setTarget(.target)
			//! endtextmacro

		struct additional extends UnitActor

			method onComplete takes nothing returns nothing
				//! runtextmacro Ability0014_tm0()
			endmethod

			static method create takes Unit caster, Unit target, integer level returns thistype
				local thistype this = allocate(caster,target,0.,0.,level,0.15,false)
				return this
			endmethod

		endstruct
	
		public struct actor extends MeleeAttack

			method onComplete takes nothing returns nothing
				local Ability a = .caster.getAbilityById(ID)
				//! runtextmacro Ability0014_tm0()
				if a > 0 then
					call a.addValue(1)
					if a.value >= NEED_TO then
						call additional.create(.caster,.target,.level)
						set a.value = 0
					endif
				endif
				call Backswing.create(.caster)
			endmethod
	
			static method create takes Unit caster, Unit target, integer level returns thistype
				local thistype this = allocate(caster,target)
				set .level = level
				return this
			endmethod

		endstruct
	
		public struct main extends Ability

			method relativeTooltip takes nothing returns string
				return "대상에게 "+/*
				*/ConstantString.statStringReal(STAT_TYPE_ATTACK,(.owner.attack * DAMAGE_PER_ATTACK) * (1+DAMAGE_PER_LEVEL*(.level-1)),1)+/*
				*/"의 피해를 입히는 무작위 카드를 투척합니다. 카드의 공격유형과 피해유형은 카드의 색깔에 따라 달라집니다. "+/*
				*/"네 번째 공격 마다 한 장의 카드를 추가로 투척합니다."+/*
				*/"\n\n|cffff0000빨간색 카드 : |r"+DAMAGE_STRING_PHYSICAL+", "+ATTACK_STRING_BASIC+/*
				*/"\n\n|cff0099ff파란색 카드 : |r"+DAMAGE_STRING_MAGICAL+", "+ATTACK_STRING_BASIC+/*
				*/"\n\n|cffffff00황금색 카드 : |r"+DAMAGE_STRING_PHYSICAL+", "+ATTACK_STRING_SPELL+/*
				*/"\n\n|cffcc00cc보라색 카드 : |r"+DAMAGE_STRING_MAGICAL+", "+ATTACK_STRING_SPELL/*
				*/
			endmethod

			method basicAttack takes Unit target returns nothing
				local actor ac = actor.create(.owner,target,level)
			endmethod

			method init takes nothing returns nothing
				set .weapon_delay = 1.
				set .weapon_range = 550.
				set .count = 0
				call plusStatValue(5)
			endmethod

			static method onInit takes nothing returns nothing
				call Ability.addTypeTag(ID,ABILITY_STRING_WEAPON)
				call Ability.addTypeTag(ID,ABILITY_TAG_CARDMAGIC)
				call Ability.addTypeTag(ID,ABILITY_TAG_THROW)
				call Ability.setTypeTooltip(ID,"무작위 피해유형을 가진\n카드 투척")
			endmethod
	
		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

/*0015 암흑비전파동*/
scope Ability0015 initializer init
	//! runtextmacro abilityDataHeader("0015","암흑비전파동","BTNArchonQ","2","STAT_TYPE_MAGICPOWER","STAT_TYPE_MAGIC_PENET")
	
		globals
			private constant real DELAY = 0.5
			private constant real BACKSWING = 0.25
			private constant real DAMAGE_PER_MAGICPOWER = 2.65
			private constant real DAMAGE_PER_LEVEL = 0.1
			private constant real COLRAD = 80.
			private constant real CHARGE_MAX_AT = 1.25
			private constant real CHARGE_TIMEOUT = 2.5
			private constant real RANGE_INITIAL = 450.
			private constant real RANGE_MAX	= 1000.
			private constant string EFFECT_PATH1 = "Abilities\\Weapons\\VengeanceMissile\\VengeanceMissile.mdl"
			private constant string EFFECT_PATH2 = "Abilities\\Spells\\Demon\\DemonBoltImpact\\DemonBoltImpact.mdl"
		endglobals

		private struct exp extends LineExplosion

			integer level = 0

			method executeExplosion takes Unit target returns nothing
				call damageTarget(target)
				call Effect.createAttatched(EFFECT_PATH2,target.origin_unit,"origin").setDuration(1.5)
			endmethod

			static method create takes Unit caster, real x, real y, real x2, real y2, real rad, integer level returns thistype
				local thistype this = allocate(caster,x,y,x2,y2,rad)
				local real angle = Math.anglePoints(.x,.y,.x2,.y2)
				local Lightning lh = 0
				set .level = level
				set .is_ranged = false
				set .damage_id = ID
				set .damage = ( .owner.magic_power * DAMAGE_PER_MAGICPOWER ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) )
				call Effect.create(EFFECT_PATH1,.x,.y,55.,270.).setScale(2.5).kill()
				call Effect.create(EFFECT_PATH2,.x,.y,0.,270.).setDuration(1.5)
				call Effect.create(EFFECT_PATH1,.x2,.y2,55.,270.).setScale(2.5).kill()
				set lh = Lightning.create("AFOD",.x,.y,55.,.x2,.y2,55.)
				call lh.setDuration(1.5)
				call lh.setFade(-TIMER_TICK*0.5)
				return this
			endmethod

		endstruct

		public struct actor extends UnitActor

			real range = 0.
			real angle = 0.

			Square sq = 0

			method periodicAction takes nothing returns nothing
				if .sq > 0 then
					call .sq.setPosition(.caster.x,.caster.y,2.)
				endif
			endmethod

			method onComplete takes nothing returns nothing
				local exp ex = exp.create(.caster,Math.pPX(.caster.x,COLRAD,angle),Math.pPY(.caster.y,COLRAD,angle),/*
				*/Math.pPX(.caster.x,.range-COLRAD,.angle),Math.pPY(.caster.y,.range-COLRAD,.angle),COLRAD,.level)
				call ex.activate()
				call UnitActor.create(.caster,0,0.,0.,0,BACKSWING,true)
				call .caster.queueAnim("stand ready")
				call .caster.setAnimSpeed(1.)
				set .sq.alphaaxis = -1./0.5
			endmethod
	
			static method create takes Unit u, real x, real y, integer level, real range returns thistype
				local thistype this = allocate(u,0,x,y,level,DELAY,true)
				set .angle = Math.anglePoints(.caster.x,.caster.y,.x,.y)
				set .sq = Square.create(.caster.x,.caster.y,2.,range,angle,COLRAD,null)
				call .sq.setColor(1.,0.,0.,0.)
				set .sq.alphaaxis = 1./0.35
				set .range = range
				call .caster.setAnim("attack")
				call .caster.setAnimSpeed(0.66)
				set .progress_bar = ProgressBar.create(NAME,.caster.owner)
				call SetUnitFacing(.caster.origin_unit,angle)
				return this
			endmethod

			method onSuspend takes nothing returns nothing
				call .caster.queueAnim("stand ready")
				call .caster.setAnimSpeed(1.)
				call .sq.destroy()
				set .sq = 0
			endmethod
	
			method onDestroy takes nothing returns nothing
				set .sq = 0
			endmethod

		endstruct

		private struct ind extends LineIndicator

			method beforeRefresh takes nothing returns nothing
				set .x = .abil.owner.x
				set .y = .abil.owner.y
				set .yaw = Math.anglePoints(.x,.y,Mouse.getVX(owner),Mouse.getVY(owner))
				set .range = .abil.cast_range
				set .width = COLRAD
			endmethod

			static method create takes Ability_prototype abil, player owner returns thistype
				local thistype this = allocate(abil,owner)
				call .ef.setColor(255,0,0)
				call .circle.setColor(255,0,0)
				return this
			endmethod

		endstruct

		public struct charge extends UnitActor

			Effect ef = 0

			Mover mv = 0

			method periodicAction takes nothing returns nothing
				call .ef.setPosition(.caster.x,.caster.y,.caster.z+125)
				set .link_ability.cast_range = .link_ability.cast_range + ((RANGE_MAX-RANGE_INITIAL)*TIMER_TICK)/CHARGE_MAX_AT
				call .ef.setScale(.ef.getScale()+TIMER_TICK)
				if .link_ability.cast_range > RANGE_MAX then
					set .link_ability.cast_range = RANGE_MAX
					call .ef.setScale(3.0)
				endif
				if .timeout >= 0.25 and .stage == 0 then
					call .caster.setAnimSpeed(0.)
					set .stage = 1
				endif
			endmethod

			static method create takes Unit caster returns thistype
				local thistype this = allocate(caster,0,0.,0.,0,CHARGE_TIMEOUT,true)
				set .mv = Mover.create(.caster)
				set .mv.refresh_facing = true
				call .caster.setAnim("attack")
				call .caster.setAnim("spell")
				set .ef = Effect.create(EFFECT_PATH1,.caster.x,.caster.y,.caster.z+125.,270.)
				call .ef.setScale(2.0)
				set .progress_bar = ProgressBar.create(NAME,.caster.owner)
				set .progress_bar.reverse = true
				return this
			endmethod

			method onDestroy takes nothing returns nothing
				call mv.destroy()
				set mv = 0
				call .caster.setAnimSpeed(1.0)
				call .ef.destroy()
			endmethod

		endstruct
	
		public struct main extends Ability

			real range_temp = 0.

			method relativeTooltip takes nothing returns string
				return "직선 범위 내의 적들에게 "+ConstantString.statStringReal(STAT_TYPE_MAGICPOWER,( .owner.magic_power * DAMAGE_PER_MAGICPOWER ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ),1)+/*
				*/"의 "+DAMAGE_STRING_MAGICAL+"를 입히는 파동을 방출합니다. 스킬 버튼을 오래 누를 수록 사거리가 증가합니다."
			endmethod

			method beforeRelease takes nothing returns nothing
				if .pressing then
					set .command_x = Mouse.getX(.owner.owner)
					set .command_y = Mouse.getY(.owner.owner)
					set .range_temp = .cast_range
					set .cast_range = -1.
					if .link_actor > 0 then
						set .useable_cast = true
					endif
				endif
			endmethod

			method onRelease takes nothing returns nothing
				if .link_actor > 0 then
					call .link_actor.destroy()
				endif
				set .cast_range = -1.
				set .useable_cast = false
			endmethod

			/*선입력했을경우 우클릭으로 취소가능*/
			method onRightClick takes nothing returns nothing
				if .link_actor <= 0 then
					call setPressState(false)
				endif
			endmethod

			method execute takes nothing returns nothing
				local actor a = 0
				if .link_actor > 0 then
					call .link_actor.destroy()
					set .link_actor = 0
				endif
				set a = actor.create(.owner,.command_x,.command_y,level,.range_temp)
				set .cast_range = -1.
				set .useable_cast = false
			endmethod
	
			method onPress takes nothing returns nothing
				local charge a = 0
				set .useable_cast = false
				if costFilter() and enableFilter() then
					/*선입력 사용이 아니면 차징 액터 생성*/
					if castFilter() then
						set a = charge.create(.owner)
						call linkActor(a)
					endif
					set .cast_range = RANGE_INITIAL
				else
					call sendError()
				endif
			endmethod

			method init takes nothing returns nothing
				set .is_active = true
				set .preserve_order = false
				set .cooldown_max = 7.5	
				set .cooldown_min = 2.
				set .manacost = 25
				set .indicator = ind.create(this,.owner.owner)
				set .drag_to_use = true
				set .cancle_rightclick = false
				call plusStatValue(5)
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.addTypeTag(ID,ABILITY_STRING_TARGET_LOCATION)
				call Ability.addTypeTag(ID,ABILITY_TAG_MAGIC)
				call Ability.addTypeTag(ID,ABILITY_TAG_DARK)
				call Ability.setTypeTooltip(ID,"장거리 직선 범위공격\n")
			endmethod
	
		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

/*0016 수리검 투척*/
scope Ability0016 initializer init
	//! runtextmacro abilityDataHeader("0016","수리검 투척","BTNShuriken","2","STAT_TYPE_ATTACK","STAT_TYPE_ACCURACY")
	
		globals
			private constant real DELAY = 0.25
			private constant real DAMAGE_PER_ATTACK = 0.15
			private constant real DAMAGE_PER_ACCURACY = 0.05
			private constant real DAMAGE_PER_LEVEL = 0.1
			private constant real BACKSWING = 0.15
			private constant real INTERVAL = 0.15
			private constant integer COUNT = 3
			private constant integer CHARGE = 3
			private constant real RANGE = 500.
			private constant real STARTAT = 35.
			private constant real VELO = 1250.
			private constant string EFFECT_PATH1 = "Effects\\Shuriken.mdl"
		endglobals

		public struct actor extends UnitActor

			Mover mv = 0

			integer count = COUNT

			method killFilter takes nothing returns boolean
				set .count = .count - 1
				if .count > 0 then
					set .duration = INTERVAL
					set .timeout = 0.
					return false
				else
					return true
				endif
			endmethod

			method periodicAction takes nothing returns nothing
				set .caster.yaw = Math.anglePoints(.caster.x,.caster.y,.target.x,.target.y)
			endmethod

			method onComplete takes nothing returns nothing
				local real a = Math.anglePoints(.caster.x,.caster.y,.target.x,.target.y)
				local Missile ms = Missile.create(.caster,EFFECT_PATH1,Math.pPX(.caster.x,STARTAT,a),Math.pPY(.caster.y,STARTAT,a),.caster.z+.caster.pivot_z,a)
				call ms.damageFlagTemplateTargetMagic()
				set ms.damage_type = DAMAGE_TYPE_PHYSICAL
				set ms.damage = ( .owner.attack * DAMAGE_PER_ATTACK ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ) +/*
				*/ ( .owner.accuracy * DAMAGE_PER_ACCURACY ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) )
				set ms.damage_id = ID
				set ms.weapon_type = WEAPON_TYPE_METAL_LIGHT_SLICE
				if .count == COUNT then
					set ms.is_onhit = true
				else
					set ms.is_onhit = false
				endif
				if .count == COUNT - 1 then
					/*채널링프리*/
					call .caster.queueAnim("stand ready")
					call .caster.setAnimSpeed(1.)
					call .mv.destroy()
					set .mv = 0
					call resetChanneling()
				endif
				call ms.setTarget(.target)
				set ms.velo = VELO
			endmethod

			method onSuspend takes nothing returns nothing
				call .caster.setAnimSpeed(1.)
			endmethod
	
			static method create takes Unit u, Unit target, integer level returns thistype
				local thistype this = allocate(u,target,0.,0.,level,DELAY,true)
				call .caster.setAnim("attack")
				call .caster.setAnimSpeed(1.66)
				call SetUnitFacing(.caster.origin_unit,Math.anglePoints(.caster.x,.caster.y,.target.x,.target.y))
				set .mv = Mover.create(.caster)
				return this
			endmethod

			method onDestroy takes nothing returns nothing
				if .mv > 0 then
					call .mv.destroy()
					set .mv = 0
				endif
			endmethod
	
		endstruct
	
		public struct main extends Ability
	
			method relativeTooltip takes nothing returns string
				return "대상에게 "+/*
				*/ConstantString.statStringReal(STAT_TYPE_ATTACK,( .owner.attack * DAMAGE_PER_ATTACK ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ),1)+"+"+/*
				*/ConstantString.statStringReal(STAT_TYPE_ACCURACY,( .owner.accuracy * DAMAGE_PER_ACCURACY ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ),1)+/*
				*/"의 "+DAMAGE_STRING_PHYSICAL+"를 입히는 수리검을 "+STRING_COLOR_CONSTANT+I2S(COUNT)+"개|r 투척합니다. 최대 "+STRING_COLOR_CONSTANT+/*
				*/I2S(CHARGE)+"회|r 충전됩니다.\n\n|cff999999사용하면서 움직일 수 있습니다.|r"
			endmethod
	
			method execute takes nothing returns nothing
				call actor.create(.owner,Unit_prototype.get(.command_target),level)
			endmethod
	
			method init takes nothing returns nothing
				set .manacost = 3
				set .is_active = true
				set .is_target = true
				set .cast_range = RANGE
				set .preserve_order = true
				set .cooldown_max = 1.5
				set .cooldown_min = 1.5
				set .count_max = CHARGE
				set .count = CHARGE
				set .indicator = AbilityIndicator.create(this,.owner.owner)
				set .smart = 2
				call plusStatValue(5)
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.addTypeTag(ID,ABILITY_STRING_TARGET_UNIT)
				call Ability.addTypeTag(ID,ABILITY_TAG_IRON)
				call Ability.addTypeTag(ID,ABILITY_TAG_THROW)
				call Ability.setTypeTooltip(ID,"단일 대상에게\n수리검 투척")
			endmethod
	
		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

/*u010 광란(버프)*/
scope Buffu010 initializer init
	//! runtextmacro buffHeader("광란","u010","0","BTNUnholyFrenzy")

	public struct main extends Buff

		static constant real ATTACK_SPEED_BONUS = 3.
		static constant real DAMAGE_PER_LEVEL = 0.15
		static constant real HP_COST = 0.05
		static constant real HP_THRESHOLD = 0.1
		static constant string EFFECT_PATH1 = "Abilities\\Spells\\Undead\\UnholyFrenzy\\UnholyFrenzyTarget.mdl"

		trigger main_trigger = null
		triggercondition main_cond = null

		method getAdditionalDamage takes nothing returns real
			return .target.maxhp * HP_COST * (1+DAMAGE_PER_LEVEL * (.level - 1))
		endmethod

		method reduceHP takes real val returns nothing
			local real th = .target.maxhp * HP_THRESHOLD
			if .target.hp <= th then
				return
			endif
			if .target.hp - val <= th then
				set .target.hp = th
			else
				set .target.hp = .target.hp - val
			endif
		endmethod

		static method cond takes nothing returns nothing
			local thistype this = Trigger.getData(GetTriggeringTrigger())
			if Event.getValue() == DAMAGE_EVENT_MODIFY_STAT then
				if DAMAGE_ATTACKER != .target then
					return
				endif
				if ATTACK_TYPE == ATTACK_TYPE_BASIC then
					set DAMAGE_AMOUNT = DAMAGE_AMOUNT + getAdditionalDamage()
					call reduceHP(.target.maxhp * HP_COST)
				endif
			elseif Event.getValue() == WEAPON_CHANGE_EVENT then
				if WEAPON_CHANGE_UNIT != .target then
					return
				endif
				if WEAPON_CHANGE_OLD != WEAPON_CHANGE_NEW then
					call destroy()
				endif
			endif
		endmethod

		method update takes nothing returns nothing

		endmethod

		method init takes nothing returns nothing
			call addEffect(Effect.createAttatched(EFFECT_PATH1,.target.origin_unit,"overhead"))
			call .target.plusStatValue(STAT_TYPE_ATTACK_SPEED,ATTACK_SPEED_BONUS)
			set .main_trigger = Trigger.new(this)
			set .main_cond = TriggerAddCondition(.main_trigger,function thistype.cond)
			call Event.triggerRegisterDamageEvent(.main_trigger,DAMAGE_EVENT_MODIFY_STAT)
			call Event.triggerRegisterWeaponChangeEvent(.main_trigger)
		endmethod

		method onDestroy takes nothing returns nothing
			call .target.plusStatValue(STAT_TYPE_ATTACK_SPEED,-ATTACK_SPEED_BONUS)
			//! runtextmacro destroyTriggerAndCondition(".main_trigger",".main_cond")
		endmethod

	endstruct

	//! runtextmacro buffEnd()
endscope

/*u010 광란*/
scope Abilityu010 initializer init
	//! runtextmacro abilityDataHeader("u010","광란","BTNUnholyFrenzy","2","STAT_TYPE_ATTACK","STAT_TYPE_MAXHP")
	
		globals
			private constant real DURATION = 3.
		endglobals
	
		public struct main extends Ability
	
			method useFilterAdditional takes nothing returns boolean
				if .owner.weapon_ability.weapon_is_ranged then
					set ERROR_MESSAGE = "원거리 무기로 사용할 수 없는 능력입니다."
					return false
				else
					return true
				endif
			endmethod

			method relativeTooltip takes nothing returns string
				return STRING_COLOR_CONSTANT+R2SW(DURATION,1,1)+"초|r 동안 "+STAT_TYPE_COLOR[STAT_TYPE_ATTACK_SPEED]+STAT_TYPE_NAME[STAT_TYPE_ATTACK_SPEED]+"|r가 "+/*
				*/STRING_COLOR_CONSTANT+I2S(R2I(Buffu010_main.ATTACK_SPEED_BONUS*100))+"%|r 증가하며 "+ATTACK_STRING_BASIC+"의 피해량이 "+/*
				*/ConstantString.statStringReal(STAT_TYPE_MAXHP,( .owner.maxhp * Buffu010_main.HP_COST ) * ( 1+Buffu010_main.DAMAGE_PER_LEVEL*(.level-1) ),1)+" 증가하는 대신 "+/*
				*/ATTACK_STRING_BASIC+" 적중 시 "+ConstantString.statStringReal(STAT_TYPE_MAXHP,.owner.maxhp * Buffu010_main.HP_COST,1)+"의 체력을 잃습니다.\n\n"+/*
				*/" - 상기된 체력감소 효과로 보유한 체력이 "+STRING_COLOR_CONSTANT+I2S(R2I(Buffu010_main.HP_THRESHOLD*100))+"%|r 밑으로 내려가지 않습니다.\n"+/*
				*/" - 원거리 무기 사용 중에 사용할 수 없습니다.\n - 무기교체 시 강화효과가 해제됩니다."
			endmethod

			method execute takes nothing returns nothing
				local Buff b = Buff.add(.owner,.owner,ID,DURATION)
				set b.level = .level
			endmethod
	
			method init takes nothing returns nothing
				set .is_active = true
				set .preserve_order = true
				set .cooldown_max = 5.	
				set .cooldown_min = 5.
				set .manacost = 30
				set .is_immediate = true
				call plusStatValue(5)
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.addTypeTag(ID,ABILITY_STRING_IMMEDIATE)
				call Ability.addTypeTag(ID,ABILITY_TAG_UNDEAD)
				call Ability.setTypeTooltip(ID,"공격속도 급증 및 체력 희생\n ")
			endmethod
	
		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

/*u011 부패가스(버프)*/
scope Buffu011 initializer init
	//! runtextmacro buffHeader("부패가스","u011","0","BTNPlagueCloud")

	public struct main extends Buff

		static constant real REDUCE = 0.75
		static constant string EFFECT_PATH1 = "Units\\Undead\\PlagueCloud\\PlagueCloudtarget.mdl"

		method update takes nothing returns nothing

		endmethod

		method init takes nothing returns nothing
			call addEffect(Effect.createAttatched(EFFECT_PATH1,.target.origin_unit,"head"))
			call .target.divideStatValue(STAT_TYPE_HEAL_AMP,(1/(1-REDUCE)) - 1)
		endmethod

		method onDestroy takes nothing returns nothing
			call .target.divideStatValue(STAT_TYPE_HEAL_AMP,-((1/(1-REDUCE)) - 1))
		endmethod

	endstruct

	//! runtextmacro buffEnd()
endscope

/*u011 부패가스*/
scope Abilityu011 initializer init
	//! runtextmacro abilityDataHeader("u011","부패가스","BTNPlagueCloud","2","STAT_TYPE_HPREGEN","STAT_TYPE_RESISTANCE")
	
		globals
			private constant real DURATION = 1.5
			private constant real INTERVAL = 0.5
			private constant real DAMAGE_PER_HPREGEN = 0.75
			private constant real DAMAGE_PER_LEVEL = 0.1
			private constant integer COUNT = 8
			private constant real EXPRAD = 200.
			private constant string EFFECT_PATH1 = "Abilities\\Spells\\Undead\\PlagueCloud\\PlagueCloudCaster.mdl"
			/**/
			private trigger DESTROY_REQUEST = CreateTrigger()
			private integer DESTROY_REQUEST_ABILITY = 0
		endglobals

		private struct exx extends Explosion

			Ability a = 0
			integer level = 1
			Effect ef = 0

			method executeExplosion takes Unit target returns nothing
				if damageTarget(target) > 0. then
					call Buff.add(.owner,target,ID,DURATION)
				endif
			endmethod

			method beforeExplosion takes nothing returns nothing
				set .x = .owner.x
				set .y = .owner.y
				set .damage = ( .owner.hpregen * DAMAGE_PER_HPREGEN ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) )
			endmethod

			static method create takes Unit caster returns thistype
				local thistype this = allocate(caster,0.,0.,EXPRAD)
				set .activate_initial = false
				set .count = COUNT
				set .interval = INTERVAL
				set .damage_id = ID
				call damageFlagTemplateMagicalExplosion()
				set .is_onhit = false
				set .interval_type = INTERVAL_TYPE_PERIODIC
				/*이펙트*/
				set .ef = Effect.createAttatched(EFFECT_PATH1,.owner.origin_unit,"origin")
				return this
			endmethod

			method onDestroy takes nothing returns nothing
				call .ef.kill()
				set .ef = 0
				set DESTROY_REQUEST_ABILITY = .a
				call TriggerEvaluate(DESTROY_REQUEST)
				set DESTROY_REQUEST_ABILITY = 0
			endmethod

		endstruct
	
		public struct main extends Ability

			private exx ex = 0
			private trigger main_trigger = null
			private triggercondition main_cond = null
	
			method relativeTooltip takes nothing returns string
				return "적에게 피해를 입으면 매 "+STRING_COLOR_CONSTANT+R2SW(INTERVAL,1,1)+"초|r 마다 주변 적들에게 "+/*
				*/ConstantString.statStringReal(STAT_TYPE_HPREGEN,( .owner.hpregen * DAMAGE_PER_HPREGEN ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ),1)+"의 "+DAMAGE_STRING_MAGICAL+/*
				*/"를 입히며 "+STRING_COLOR_CONSTANT+STRING_COLOR_CONSTANT+R2SW(DURATION,1,1)+"초|r 동안 대상의 "+STAT_TYPE_COLOR[STAT_TYPE_HEAL_AMP]+STAT_TYPE_NAME[STAT_TYPE_HEAL_AMP]+"|r을 "+/*
				*/STRING_COLOR_CONSTANT+I2S(R2I(Buffu011_main.REDUCE*100))+"%|r 감소시키는 부패가스를 분출합니다."
			endmethod

			method execute takes nothing returns nothing
				if .ex > 0 then
					set .ex.count = COUNT
				else
					set .ex = exx.create(.owner)
					set .ex.a = this
					call .ex.activate()
				endif
				set .ex.level = .level
			endmethod

			static method damageAction takes nothing returns nothing
				local thistype this = Trigger.getData(GetTriggeringTrigger())
				if this <= 0 or .owner != DAMAGE_TARGET then
					return
				endif
				call execute()
			endmethod
	
			method init takes nothing returns nothing
				set .cooldown_max = 0.	
				set .cooldown_min = 0.
				call plusStatValue(5)
				/**/
				set .main_trigger = Trigger.new(this)
				set .main_cond = TriggerAddCondition(.main_trigger,function thistype.damageAction)
				call Event.triggerRegisterDamageEvent(.main_trigger,DAMAGE_EVENT_BEFORE_HPREDUCE)
			endmethod

			method onDestroy takes nothing returns nothing
				if .ex > 0 then
					call .ex.destroy()
					set .ex = 0
				endif
				//! runtextmacro destroyTriggerAndCondition(".main_trigger",".main_cond")
			endmethod

			static method destroyRequest takes nothing returns nothing
				if DESTROY_REQUEST_ABILITY <= 0 then
					return
				endif
				set thistype(DESTROY_REQUEST_ABILITY).ex = 0
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.addTypeTag(ID,ABILITY_STRING_PASSIVE)
				call Ability.addTypeTag(ID,ABILITY_TAG_POISON)
				call Ability.addTypeTag(ID,ABILITY_TAG_UNDEAD)
				call Ability.setTypeTooltip(ID,"지속 범위피해 및\n대상 받는 치유량 감소")
				call TriggerAddCondition(DESTROY_REQUEST,function thistype.destroyRequest)
			endmethod
	
		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

scope AddRandomAbility2 initializer init

	private function init takes nothing returns nothing
		call Ability.addRandomAbility('0010',2)
		call Ability.addRandomAbility('0013',2)
		call Ability.addRandomAbility('0014',2)
		call Ability.addRandomAbility('0015',2)
		call Ability.addRandomAbility('0016',2)
	endfunction

endscope