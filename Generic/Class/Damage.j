library Damage

	globals

		integer ATTACK_TYPE		= 0		/*0:기본공격판정 1:스킬공격판정 2:둘 다*/
		constant integer ATTACK_TYPE_BASIC 		= 0
		constant integer ATTACK_TYPE_SPELL 		= 1
		constant integer ATTACK_TYPE_HYBRID		= 2
		constant integer ATTACK_TYPE_ETC			= 3
		integer DAMAGE_TYPE 		= 0		/*0:물리 1:마법 2:고정*/
		constant integer DAMAGE_TYPE_PHYSICAL 	= 0
		constant integer DAMAGE_TYPE_MAGICAL 	= 1
		constant integer DAMAGE_TYPE_TRUE		= 2
		boolean IS_TARGET 	= true
		boolean IS_AOE 		= false
		integer INTERVAL_TYPE	= 0 	/*0:단발성 1:지속성*/
		constant integer INTERVAL_TYPE_SINGLE	= 0
		constant integer INTERVAL_TYPE_PERIODIC	= 1
		integer VECTOR_TYPE		= 0 	/*0:외부피해 1:내부피해*/
		constant integer VECTOR_TYPE_OUTTER		= 0
		constant integer VECTOR_TYPE_INNER		= 1
		boolean IS_ONHIT		= false		/*온힛여부*/
		boolean IS_RANGED	= false		/*근 원*/

		integer DAMAGE_ID = 0
		boolean USE_DAMAGE_POSITION = false
		real DAMAGE_X = 0.
		real DAMAGE_Y = 0.

		Unit_prototype	DAMAGE_ATTACKER = 0
		Unit_prototype 	DAMAGE_TARGET = 0
		real 			DAMAGE_LAST = 0.
		real DAMAGE_AMOUNT = 0.
		real DAMAGE_AMOUNT_ORIGIN = 0.
		real DAMAGE_LOWBOUND = 0.
		real DAMAGE_HP_REDUCED = 0.

		constant real DAMAGE_EVENT_NULL = 0.0
	endglobals

	struct Damage extends array

		static method setFlag takes integer damage, integer attack, boolean target, boolean aoe, integer interval, integer vector, boolean onhit, boolean ranged returns nothing
			set DAMAGE_TYPE 	= damage
			set ATTACK_TYPE 	= attack
			set IS_TARGET 		= target
			set IS_AOE			= aoe
			set INTERVAL_TYPE 	= interval
			set VECTOR_TYPE 	= vector
			set IS_ONHIT		= onhit
			set IS_RANGED		= ranged
		endmethod

		static method flagTempleteMeleeAttack takes nothing returns nothing
			call setFlag(DAMAGE_TYPE_PHYSICAL,ATTACK_TYPE_BASIC,true,false,INTERVAL_TYPE_SINGLE,VECTOR_TYPE_OUTTER,true,false)
		endmethod

		static method flagTempleteRangedAttack takes nothing returns nothing
			call setFlag(DAMAGE_TYPE_PHYSICAL,ATTACK_TYPE_BASIC,true,false,INTERVAL_TYPE_SINGLE,VECTOR_TYPE_OUTTER,true,true)
		endmethod

		static method flagTempleteMagicalExplosion takes nothing returns nothing
			call setFlag(DAMAGE_TYPE_MAGICAL,ATTACK_TYPE_SPELL,false,true,INTERVAL_TYPE_SINGLE,VECTOR_TYPE_OUTTER,true,true)
		endmethod

		static method flagTempletePhysicalExplosion takes nothing returns nothing
			call setFlag(DAMAGE_TYPE_PHYSICAL,ATTACK_TYPE_SPELL,false,true,INTERVAL_TYPE_SINGLE,VECTOR_TYPE_OUTTER,true,true)
		endmethod

		static method flagTempleteDOT takes nothing returns nothing
			call setFlag(DAMAGE_TYPE_MAGICAL,ATTACK_TYPE_ETC,false,false,INTERVAL_TYPE_PERIODIC,VECTOR_TYPE_INNER,false,true)
		endmethod
		
		static method clearFlag takes nothing returns nothing
			set ATTACK_TYPE 	= 0
			set DAMAGE_TYPE 	= 0
			set IS_TARGET	 	= true
			set IS_AOE			= false
			set INTERVAL_TYPE 	= 0
			set VECTOR_TYPE 	= 0
			set IS_ONHIT		= false
			set USE_DAMAGE_POSITION = false
			/**/
			set DAMAGE_ATTACKER 	= 0
			set DAMAGE_TARGET 	= 0
			set DAMAGE_LAST 	= 0.
			set DAMAGE_AMOUNT = 0.
			set DAMAGE_AMOUNT_ORIGIN = 0.
			set DAMAGE_ID = 0
		endmethod

		static method unitDamageTarget takes Unit_prototype attacker, Unit_prototype target, real damage, weapontype wt returns real
			local real armor = 0.
			set DAMAGE_HP_REDUCED = 0.
			set DAMAGE_AMOUNT_ORIGIN = damage
			set DAMAGE_AMOUNT = damage
			set DAMAGE_ATTACKER = attacker
			set DAMAGE_TARGET = target
			set DAMAGE_LOWBOUND = (100+attacker.accuracy)/(100+target.evasion)
			/*죽었으면 무요*/
			if target.getStatus(STATUS_DEAD) > 0 or attacker <= 0 or target <= 0 then
				return 0.
			endif
			/*데미지포지션 사용여부*/
			if USE_DAMAGE_POSITION then
				/*사용 시 냅두기*/
			else
				/*안쓰면 공격자의 위치로 조정*/
				set DAMAGE_X = attacker.x
				set DAMAGE_Y = attacker.y
			endif
			if DAMAGE_LOWBOUND > 1. then
				set DAMAGE_LOWBOUND = GetRandomReal(1.0,DAMAGE_LOWBOUND)
			else
				set DAMAGE_LOWBOUND = GetRandomReal(DAMAGE_LOWBOUND,1.0)
			endif
			if DAMAGE_ID == 0 then
				call BJDebugMsg("데미지 ID가 정의되지 않았습니다.")
			endif
			if ATTACK_TYPE == ATTACK_TYPE_BASIC then
				if attacker.getStatus(STATUS_BLIND) > 0 or target.getStatus(STATUS_EVASION) > 0 then
					call clearFlag()
					return 0.
				endif
			endif
			/*스탯 모디파이 트리거*/
			set udg_EVENT_VALUE = 0.
			set udg_EVENT_VALUE = DAMAGE_EVENT_MODIFY_STAT
			if DAMAGE_TYPE == DAMAGE_TYPE_TRUE then
			else
				if DAMAGE_TYPE == DAMAGE_TYPE_PHYSICAL then
					set armor = target.getCarculatedStatValue(STAT_TYPE_DEFFENCE) - attacker.getCarculatedStatValue(STAT_TYPE_ARMOR_PENET)
				elseif DAMAGE_TYPE == DAMAGE_TYPE_MAGICAL then
					set armor = target.getCarculatedStatValue(STAT_TYPE_RESISTANCE) - attacker.getCarculatedStatValue(STAT_TYPE_MAGIC_PENET)
				endif
				/*1차가공(방어력)*/
				if armor >= 0. then
					set DAMAGE_AMOUNT = DAMAGE_AMOUNT * 100./(100.+armor)
				else
					set DAMAGE_AMOUNT = DAMAGE_AMOUNT * 1.-(armor*0.01)
				endif
				/*2차가공(회피)*/
				set DAMAGE_AMOUNT = DAMAGE_AMOUNT * DAMAGE_LOWBOUND
			endif
			/*데미지 모디파이*/
			set udg_EVENT_VALUE = DAMAGE_EVENT_MODIFY_DAMAGE
			/*타격음 재생*/
			call UnitDamageTarget(attacker.origin_unit,target.origin_unit,0.,false,true,ATTACK_TYPE_HERO,DAMAGE_TYPE_MAGIC,wt)
			/*체력 감소 전*/
			set udg_EVENT_VALUE = DAMAGE_EVENT_BEFORE_HPREDUCE
			/*죽었는지 판별&체력감소*/
			if DAMAGE_AMOUNT >= target.hp - 0.405 then
				set DAMAGE_HP_REDUCED = target.hp
				set target.hp = 1.
				set DEATH_KILLER = attacker
				call target.plusStatus(STATUS_DEAD)
			else
				set DAMAGE_HP_REDUCED = DAMAGE_AMOUNT
				set target.hp = target.hp - DAMAGE_AMOUNT
			endif
			set DAMAGE_LAST = DAMAGE_HP_REDUCED
			if DAMAGE_TYPE == DAMAGE_TYPE_PHYSICAL then
				call InstantText.setColor(255,153,0)
			elseif DAMAGE_TYPE == DAMAGE_TYPE_MAGICAL then
				call InstantText.setColor(0,153,255)
			endif
			/*데미지텍스트*/
			set InstantText.SIZE = 10.
			call InstantText.createForBothPlayer(target.x,target.y,target.z+75,I2S(R2I(DAMAGE_AMOUNT)),attacker.owner,target.owner)
			/*데미지 관련 트리거*/
			set udg_EVENT_VALUE = DAMAGE_EVENT_AFTER_HPREDUCE
			/**/
			call clearFlag()
			return DAMAGE_HP_REDUCED
		endmethod

		static method damageTarget takes Unit target, real amount returns real
			local real reduced = 0.
			call clearFlag()
			set DAMAGE_AMOUNT = amount
			/*죽었는지 판별&체력감소*/
			if DAMAGE_AMOUNT >= target.hp - 0.405 then
				set reduced = target.hp
				set target.hp = 1.
				set DEATH_KILLER = 0
				call target.plusStatus(STATUS_DEAD)
			else
				set target.hp = target.hp - DAMAGE_AMOUNT
				set reduced = DAMAGE_AMOUNT
			endif
			call clearFlag()
			return reduced
		endmethod

	endstruct

	module DamageFlag

		integer damage_type = DAMAGE_TYPE_PHYSICAL
		integer attack_type = ATTACK_TYPE_BASIC
		boolean is_target = false
		boolean is_aoe = false
		integer interval_type = INTERVAL_TYPE_SINGLE
		integer vector_type = VECTOR_TYPE_OUTTER
		boolean is_onhit = true
		boolean is_ranged = true
		weapontype weapon_type = WEAPON_TYPE_WHOKNOWS
		
		integer damage_id = 0
		real damage_x = 0.
		real damage_y = 0.
		boolean use_damage_position = false

		real damage = 0.

		method setDamagePosition takes real x, real y returns nothing
			set .damage_x = x
			set .damage_y = y
		endmethod

		method applyDamageFlag takes nothing returns nothing
			call Damage.setFlag(.damage_type,.attack_type,.is_target,.is_aoe,.interval_type,.vector_type,.is_onhit,.is_ranged)
			set DAMAGE_ID = .damage_id
			set USE_DAMAGE_POSITION = .use_damage_position
			if .use_damage_position then
				set DAMAGE_X = .damage_x
				set DAMAGE_Y = .damage_y
			endif
		endmethod

		method damageTarget takes Unit_prototype target returns real
			call applyDamageFlag()
			return .owner.damageTarget(target,.damage,.weapon_type)
		endmethod

		method setDamageFlag takes integer damage, integer attack, boolean target, boolean aoe, integer interval, integer vector, boolean onhit, boolean ranged returns nothing
			set .damage_type 	= damage
			set .attack_type 	= attack
			set .is_target 		= target
			set .is_aoe			= aoe
			set .interval_type 	= interval
			set .vector_type 	= vector
			set .is_onhit		= onhit
			set .is_ranged		= ranged
		endmethod

		method damageFlagTemplateMeleeAttack takes nothing returns nothing
			call setDamageFlag(DAMAGE_TYPE_PHYSICAL,ATTACK_TYPE_BASIC,true,false,INTERVAL_TYPE_SINGLE,VECTOR_TYPE_OUTTER,true,false)
		endmethod

		method damageFlagTemplateRangedAttack takes nothing returns nothing
			call setDamageFlag(DAMAGE_TYPE_PHYSICAL,ATTACK_TYPE_BASIC,true,false,INTERVAL_TYPE_SINGLE,VECTOR_TYPE_OUTTER,true,true)
		endmethod

		method damageFlagTemplateMagicalExplosion takes nothing returns nothing
			call setDamageFlag(DAMAGE_TYPE_MAGICAL,ATTACK_TYPE_SPELL,false,true,INTERVAL_TYPE_SINGLE,VECTOR_TYPE_OUTTER,true,true)
		endmethod

		method damageFlagTemplatePhysicalExplosion takes nothing returns nothing
			call setDamageFlag(DAMAGE_TYPE_PHYSICAL,ATTACK_TYPE_SPELL,false,true,INTERVAL_TYPE_SINGLE,VECTOR_TYPE_OUTTER,true,true)
		endmethod

		method damageFlagTemplateTargetMagic takes nothing returns nothing
			call setDamageFlag(DAMAGE_TYPE_MAGICAL,ATTACK_TYPE_SPELL,true,false,INTERVAL_TYPE_SINGLE,VECTOR_TYPE_OUTTER,true,true)
		endmethod

		method damageFlagTemplateDOT takes nothing returns nothing
			call setDamageFlag(DAMAGE_TYPE_MAGICAL,ATTACK_TYPE_ETC,false,false,INTERVAL_TYPE_PERIODIC,VECTOR_TYPE_INNER,false,true)
		endmethod

	endmodule

endlibrary 