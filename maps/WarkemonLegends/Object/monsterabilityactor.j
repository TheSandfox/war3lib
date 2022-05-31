library MonsterAbilityActorRequest

	struct MonsterAbilityActorRequest

		static constant integer TYPE_MAIN 	= 0
		static constant integer TYPE_SUB	= 1

		static trigger TRIGGER 			= CreateTrigger()
		/*리퀘스트 파라메터*/
		static integer ID				= 0
		static integer CASTER 			= 0
		static integer TARGET 			= 0
		static integer BATTLE			= 0
		static integer ORIGIN_ABILITY	= 0
		static integer LAST_CREATED		= 0

		integer battle 			= 0
		integer id				= 0
		integer caster			= 0
		integer target			= 0
		integer type			= 0		/*0:메인 액트(공격행동 등), 1:서브액트(독 틱뎀,추가효과 등)*/
		integer origin_ability 	= 0

		method request takes nothing returns integer
			set BATTLE 			= .battle
			set ID				= .id
			set ORIGIN_ABILITY 	= .origin_ability
			set CASTER			= .caster
			set TARGET			= .target
			call TriggerExecute(TRIGGER)
			return LAST_CREATED
		endmethod

		static method create takes integer cb, integer id, integer origin_ability, integer caster, integer target, integer t returns thistype
			local thistype this = allocate()
			set .battle = cb
			set .id 	= id
			set .origin_ability	= origin_ability
			set .caster = caster
			set .target = target
			set .type	= t
			return this
		endmethod

	endstruct

endlibrary

library MonsterAbilityActor requires Battle

	struct MonsterAbilityActor

		Battle battle			= 0
		BattleMonster caster 	= 0
		Effect caster_effect	= 0
		BattleMonster target 	= 0
		Effect target_effect	= 0
		integer stage 			= 0	
		timer periodic_timer 	= null
		real timeout 			= 0.
		real caster_origin_x	= 0.
		real caster_origin_y	= 0.
		real caster_origin_z	= 0.
		real caster_origin_yaw 	= 0.
		real caster_origin_pitch= 0.
		real caster_origin_roll	= 0.
		real caster_origin_scale= 0.
		real target_origin_x	= 0.
		real target_origin_y	= 0.
		real target_origin_z	= 0.
		real target_origin_yaw 	= 0.
		real target_origin_pitch= 0.
		real target_origin_roll	= 0.
		real target_origin_scale= 0.
		BattleMonsterAbility origin_ability = 0

		method abort takes nothing returns nothing
			call .battle.setStatePlayActor()
			call destroy()
		endmethod

		stub method abortCondition takes nothing returns boolean
			return not caster.alive or ( .target != 0 and not .target.alive)
		endmethod

		method setDamageFlag takes integer ranged returns nothing
			set DAMAGE_FLAG_RANGED = ranged
		endmethod

		method stageNext takes nothing returns nothing
			set .stage = .stage + 1
			set .timeout = 0.
		endmethod

		stub method lastFrame takes nothing returns nothing

		endmethod

		method moveForward takes real velo returns nothing
			call .caster_effect.setX(Math.pPX(.caster_effect.getX(),velo*TIMER_TICK,.caster_effect.getYaw()))
			call .caster_effect.setY(Math.pPY(.caster_effect.getY(),velo*TIMER_TICK,.caster_effect.getYaw()))
		endmethod

		method facingTarget takes nothing returns nothing
			call .caster_effect.setYaw(Math.anglePoints(.caster_effect.getX(),.caster_effect.getY(),.target_effect.getX(),.target_effect.getY()))
		endmethod

		private method resetTransform takes nothing returns nothing
			if .caster != 0 then
				call .caster.effect.setPosition(.caster_origin_x,.caster_origin_y,.caster_origin_z)
				call .caster.effect.setOrientation(.caster_origin_yaw,.caster_origin_pitch,.caster_origin_roll)
				call .caster.effect.setScale(.caster_origin_scale)
				call .caster.effect.setAnimSpeed(1.0)
			endif
			if .target != 0 then
				call .target.effect.setPosition(.target_origin_x,.target_origin_y,.target_origin_z)
				call .target.effect.setOrientation(.target_origin_yaw,.target_origin_pitch,.target_origin_roll)
				call .target.effect.setScale(.target_origin_scale)
				call .target.effect.setAnimSpeed(1.0)
			endif
		endmethod

		method end takes nothing returns nothing
			call lastFrame()
			call resetTransform()
			call .battle.setStatePlayActor()
			call destroy()
		endmethod

		stub method firstFrame takes nothing returns nothing

		endmethod

		stub method periodicAction takes nothing returns nothing

		endmethod

		private static method periodicTimer takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			set .timeout = .timeout + TIMER_TICK
			call periodicAction()
		endmethod

		static method create takes Battle battle, BattleMonsterAbility oa, BattleMonster caster, BattleMonster target returns thistype
			local thistype this = allocate()
			set .battle = battle
			set .caster = caster
			set .caster_effect = .caster.effect
			set .target = target
			set .target_effect = .target.effect
			set .periodic_timer = Timer.new(this)
			set .origin_ability = oa
			if .caster != 0 then
				set .caster_origin_x = .caster.effect.getX()
				set .caster_origin_y = .caster.effect.getY()
				set .caster_origin_z = .caster.effect.getZ()
				set .caster_origin_yaw = .caster.effect.getYaw()
				set .caster_origin_pitch = .caster.effect.getPitch()
				set .caster_origin_roll = .caster.effect.getRoll()
				set .caster_origin_scale = .caster.scale
			endif
			if .target != 0 then
				set .target_origin_x = .target.effect.getX()
				set .target_origin_y = .target.effect.getY()
				set .target_origin_z = .target.effect.getZ()
				set .target_origin_yaw = .target.effect.getYaw()
				set .target_origin_pitch = .target.effect.getPitch()
				set .target_origin_roll = .target.effect.getRoll()
				set .target_origin_scale = .target.scale
			endif
			call Timer.start(.periodic_timer,TIMER_TICK,true,function thistype.periodicTimer)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call Timer.release(.periodic_timer)
			set .periodic_timer = null
		endmethod

	endstruct

endlibrary

//! import "monsterabilityactordata.j"