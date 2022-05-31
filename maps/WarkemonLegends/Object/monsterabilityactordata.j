//! textmacro MonsterAbilityActorHeader takes id
struct Actor$id$ extends MonsterAbilityActor

	private static constant integer ID = '$id$'

//! endtextmacro

//! textmacro MonsterAbilityActorEnd

	static method create takes nothing returns thistype
		local thistype this = allocate(MonsterAbilityActorRequest.BATTLE,MonsterAbilityActorRequest.ORIGIN_ABILITY,MonsterAbilityActorRequest.CASTER,MonsterAbilityActorRequest.TARGET)
		if not abortCondition() then
			call firstFrame()
		else
			call abort()
		endif
		return this
	endmethod

	private static method act takes nothing returns nothing
		if MonsterAbilityActorRequest.ID == ID then
			call create()
		endif
	endmethod

	private static method onInit takes nothing returns nothing
		call TriggerAddAction(MonsterAbilityActorRequest.TRIGGER,function thistype.act)
	endmethod

endstruct
//! endtextmacro
/*내부에 periodicAction() 메서드를 오버라이딩해서 작성*/
/*periodicAction() 내에 반드시 end() 구문이 포함되어야함 */

/*000_0:후려치기*/
library Actor0000
//! runtextmacro MonsterAbilityActorHeader("0000")

	private static constant string EFFECT_PATH1 = "Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl"

	method firstFrame takes nothing returns nothing
	endmethod

	method lastFrame takes nothing returns nothing
	endmethod

	method periodicAction takes nothing returns nothing
		if .stage == 0 then
			if .timeout >= 0.25 then
				call .caster_effect.setAnim(ANIM_TYPE_ATTACK)
				call stageNext()
			endif
		elseif .stage == 1 then
			call moveForward(-300)
			if .timeout >= 0.5 then
				call stageNext()
				call .caster_effect.setAnimSpeed(2.0)
			endif
		elseif .stage == 2 then
			call moveForward(2400)
			if .timeout >= 0.125 then
				call Effect.create(EFFECT_PATH1,.target_effect.x,target_effect.y,target_effect.z+55,0).setScale(1.5).kill()
				call setDamageFlag(0)
				call .caster.damageToTarget(.target,.origin_ability.element_type1,.origin_ability.element_type2,DAMAGE_TYPE_PHYSICAL,/*
					*/.caster.getCarculatedStat(STAT_TYPE_ATTACK)*.origin_ability.value1/*
				*/)
				call .caster_effect.setAnim(ANIM_TYPE_STAND)
				call .caster_effect.setAnimSpeed(1.0)
				call stageNext()
			endif
		elseif .stage == 3 then
			call moveForward(-300)
			if .timeout >= 0.5 then
				call stageNext()
			endif
		elseif .stage == 4 then
			if .timeout >= 0.5 then
				call end()
			endif
		endif
	endmethod

//! runtextmacro MonsterAbilityActorEnd()
endlibrary

library Actor0001
	//! runtextmacro MonsterAbilityActorHeader("0001")
	
		private static constant string EFFECT_PATH1 = "Effects\\SoulEclipse.mdl"
	
		Effect effect = 0

		method firstFrame takes nothing returns nothing
			set .effect = Effect.create(EFFECT_PATH1,GetRectCenterX(Battle.RECT[.battle.slot]),GetRectCenterY(Battle.RECT[.battle.slot]),16,270)
			call .battle.bg.setAlpha(0)
		endmethod
	
		method lastFrame takes nothing returns nothing
		endmethod
	
		method periodicAction takes nothing returns nothing
			if .stage == 0 then
				if .timeout >= 6. then
					call .caster_effect.setAnim(ANIM_TYPE_ATTACK)
					call .effect.setAnim(ANIM_TYPE_DEATH)
					call stageNext()
				endif
			elseif .stage == 1 then
				if .timeout >= 2.5 then
					set .effect.wantremove = true
					call .effect.destroy()
					set .effect = 0
					call .battle.bg.setAlpha(255)
					call end()
				endif
			endif
		endmethod
	
	//! runtextmacro MonsterAbilityActorEnd()
endlibrary
	

/*001_0:독침*/
library Actor0010
//! runtextmacro MonsterAbilityActorHeader("0010")

	private static constant string EFFECT_PATH1 = "Abilities\\Weapons\\snapMissile\\snapMissile.mdl"

	Effect ef = 0

	method firstFrame takes nothing returns nothing
		call .caster_effect.setAnim(ANIM_TYPE_ATTACK)
		call .caster_effect.setAnimSpeed(1.66)
	endmethod

	method lastFrame takes nothing returns nothing
		call .ef.kill()
	endmethod

	method periodicAction takes nothing returns nothing
		if .stage == 0 then
			if .timeout >= 0.5 then
				set .ef = Effect.create(EFFECT_PATH1,.caster_effect.x,.caster_effect.y,.caster_effect.z+55,.caster_effect.yaw)
				call stageNext()
			endif
		elseif .stage == 1 then
			if .timeout >= 0.25 then
				call .caster_effect.setAnim(ANIM_TYPE_STAND)
				call .caster_effect.setAnimSpeed(1.0)
				call setDamageFlag(1)
				call .caster.damageToTarget(.target,.origin_ability.element_type1,.origin_ability.element_type2,DAMAGE_TYPE_PHYSICAL,/*
					*/.caster.getCarculatedStat(STAT_TYPE_ATTACK)*.origin_ability.value1/*
				*/)
				call end()
			endif
		endif
	endmethod

//! runtextmacro MonsterAbilityActorEnd()
endlibrary

/*002_0:나무주먹*/
library Actor0020
	//! runtextmacro MonsterAbilityActorHeader("0020")
	
		private static constant string EFFECT_PATH1 = "Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl"
	
		method firstFrame takes nothing returns nothing
		endmethod
	
		method lastFrame takes nothing returns nothing
		endmethod
	
		method periodicAction takes nothing returns nothing
			if .stage == 0 then
				if .timeout >= 0.25 then
					call .caster_effect.setAnim(ANIM_TYPE_ATTACK)
					call stageNext()
				endif
			elseif .stage == 1 then
				call moveForward(-300)
				if .timeout >= 0.5 then
					call stageNext()
					call .caster_effect.setAnimSpeed(2.0)
				endif
			elseif .stage == 2 then
				call moveForward(2400)
				if .timeout >= 0.125 then
					call Effect.create(EFFECT_PATH1,.target_effect.x,target_effect.y,target_effect.z+55,0).setScale(1.5).kill()
					call setDamageFlag(0)
					call .caster.damageToTarget(.target,.origin_ability.element_type1,.origin_ability.element_type2,DAMAGE_TYPE_PHYSICAL,/*
						*/.caster.getCarculatedStat(STAT_TYPE_ATTACK)*.origin_ability.value1/*
					*/)
					call .caster_effect.setAnim(ANIM_TYPE_STAND)
					call .caster_effect.setAnimSpeed(1.0)
					call stageNext()
				endif
			elseif .stage == 3 then
				call moveForward(-300)
				if .timeout >= 0.5 then
					call stageNext()
				endif
			elseif .stage == 4 then
				if .timeout >= 0.5 then
					call end()
				endif
			endif
		endmethod
	
	//! runtextmacro MonsterAbilityActorEnd()
endlibrary

/*004_0:갑각찌르기*/
library Actor0040
	//! runtextmacro MonsterAbilityActorHeader("0040")
	
		private static constant string EFFECT_PATH1 = "Abilities\\Weapons\\GargoyleMissile\\GargoyleMissile.mdll"
		private static constant string EFFECT_PATH2 = "Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl"
	
		method firstFrame takes nothing returns nothing
		endmethod
	
		method lastFrame takes nothing returns nothing
		endmethod
	
		method periodicAction takes nothing returns nothing
			if .stage == 0 then
				if .timeout >= 0.25 then
					call .caster_effect.setAnim(ANIM_TYPE_ATTACK)
					call stageNext()
				endif
			elseif .stage == 1 then
				call moveForward(-150)
				if .timeout >= 0.5 then
					call stageNext()
					call .caster_effect.setAnimSpeed(2.0)
				endif
			elseif .stage == 2 then
				call moveForward(1200)
				if .timeout >= 0.125 then
					call Effect.create(EFFECT_PATH1,.target_effect.x,target_effect.y,target_effect.z+55,0).setScale(1.5).kill()
					call Effect.create(EFFECT_PATH2,.target_effect.x,target_effect.y,target_effect.z+55,0).setScale(1.5).setDuration(1.5)
					call setDamageFlag(0)
					call .caster.damageToTarget(.target,.origin_ability.element_type1,.origin_ability.element_type2,DAMAGE_TYPE_PHYSICAL,/*
						*/.caster.getCarculatedStat(STAT_TYPE_ATTACK)*.origin_ability.value1/*
					*/)
					call .caster_effect.setAnim(ANIM_TYPE_STAND)
					call .caster_effect.setAnimSpeed(1.0)
					call stageNext()
				endif
			elseif .stage == 3 then
				call moveForward(-150)
				if .timeout >= 0.5 then
					call .battle.pushMonsterAbilityActorRequest(0,.origin_ability.actor_id2, .origin_ability, .caster, .target, MonsterAbilityActorRequest.TYPE_MAIN)
					call end()
				endif
			endif
		endmethod
	
	//! runtextmacro MonsterAbilityActorEnd()
endlibrary

/*004_1:갑각찌르기2nd*/
library Actor0041
	//! runtextmacro MonsterAbilityActorHeader("0041")
	
		private static constant string EFFECT_PATH1 = "Abilities\\Weapons\\GargoyleMissile\\GargoyleMissile.mdll"
		private static constant string EFFECT_PATH2 = "Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl"
	
		method firstFrame takes nothing returns nothing
		endmethod
	
		method lastFrame takes nothing returns nothing
		endmethod
	
		method periodicAction takes nothing returns nothing
			if .stage == 0 then
				if .timeout >= 0.25 then
					call .caster_effect.setAnim(ANIM_TYPE_ATTACK)
					call stageNext()
				endif
			elseif .stage == 1 then
				call moveForward(-150)
				if .timeout >= 0.5 then
					call stageNext()
					call .caster_effect.setAnimSpeed(2.0)
				endif
			elseif .stage == 2 then
				call moveForward(1200)
				if .timeout >= 0.125 then
					call Effect.create(EFFECT_PATH1,.target_effect.x,target_effect.y,target_effect.z+55,0).setScale(1.5).kill()
					call Effect.create(EFFECT_PATH2,.target_effect.x,target_effect.y,target_effect.z+55,0).setScale(1.5).setDuration(1.5)
					call setDamageFlag(0)
					call .caster.damageToTarget(.target,.origin_ability.element_type1,.origin_ability.element_type2,DAMAGE_TYPE_PHYSICAL,/*
						*/.caster.getCarculatedStat(STAT_TYPE_ATTACK)*.origin_ability.value1/*
					*/)
					call .caster_effect.setAnim(ANIM_TYPE_STAND)
					call .caster_effect.setAnimSpeed(1.0)
					call stageNext()
				endif
			elseif .stage == 3 then
				call moveForward(-150)
				if .timeout >= 0.5 then
					call stageNext()
				endif
			elseif .stage == 4 then
				if .timeout >= 0.5 then
					call end()
				endif
			endif
		endmethod
	
	//! runtextmacro MonsterAbilityActorEnd()
endlibrary

/*xxx_0:몬스터볼 던지기*/
library Actorxxx0
	//! runtextmacro MonsterAbilityActorHeader("xxx0")
	
		private static constant string EFFECT_PATH1 = "Abilities\\Spells\\Human\\Polymorph\\PolyMorphDoneGround.mdl"
		private static constant string EFFECT_PATH2 = "Units\\Creeps\\HeroTinkerFactory\\HeroTinkerFactoryMissle.mdl"

		Effect effect = 0

		private method carculateCatch takes nothing returns boolean
			local real r = GetRandomReal(0.2,1.)
			local Profile pr = 0
			local integer i = 0
			local boolean b = false
			set pr = Profile.getPlayerProfile(.battle.battle_player[0])
			loop
				exitwhen i >= Party.ARRAY_SIZE
				if Party.getMonster(pr,i) == 0 then
					set b = true
					exitwhen true
				endif
				set i = i + 1
			endloop
			return r > (.target.hp/.target.getCarculatedStat(STAT_TYPE_MAXHP)) and b
		endmethod
	
		method firstFrame takes nothing returns nothing
			set .effect = Effect.create(EFFECT_PATH2,.caster_effect.x,.caster_effect.y,1500,270)
		endmethod
	
		method lastFrame takes nothing returns nothing
		endmethod
	
		method periodicAction takes nothing returns nothing
			local Profile pr = 0
			local integer i = 0
			local Monster nm = 0
			if .stage == 0 then
				if .timeout > 0.5 then
					call .effect.kill()
					call stageNext()
				endif
			elseif .stage == 1 then
				if .timeout > 0.5 then
					if carculateCatch() then
						set .target.alive = false
						call .target_effect.setAlpha(0)
						call Effect.create(EFFECT_PATH1,.target_effect.x,.target_effect.y,0,0).setDuration(1.5).setScale(3.5)
						set pr = Profile.getPlayerProfile(.battle.battle_player[0])
						set nm = Monster.create(.target.id)
						call nm.setLevel(.target.level)
						set nm.hp = nm.hp * (.target.hp/.target.getCarculatedStat(STAT_TYPE_MAXHP))
						call Party.addMonster(pr,nm)
					else
						call Effect.create(EFFECT_PATH1,.target_effect.x,.target_effect.y,0,0).setDuration(1.5).setScale(1.)
						call InstantText.create(.target_effect.x,.target_effect.y,.target_effect.z,"|cffff3333포획 실패!|r")
					endif
					call stageNext()
				endif
			elseif .stage == 2 then
				if .timeout > 1.25 then
					call end()
				endif
			endif
		endmethod
	
	//! runtextmacro MonsterAbilityActorEnd()
endlibrary

