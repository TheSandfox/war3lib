library UnitActor

	struct UnitActor extends Actor
		
		Unit_prototype target = 0
		Ability_prototype link_ability = 0
		integer level = 0

		trigger suspend_trigger = null
		triggercondition suspend_condition = null

		boolean suspend_stun = true		/*스턴에 방해받는가*/
		boolean suspend_ensnare = false	/*속박에 방해받는가*/
		boolean suspend_silence = true	/*침묵에 방해받는가*/
		boolean suspend_dead	= true	/*죽으면 끊기는가*/
		boolean suspend_rclick  = false /*우클릭에 취소되는가*/
		boolean suspend_ability = false
		boolean suspend_stop	= false /*스탑에 취소되는가*/

		boolean channeling = true		/*정신집중인가*/

		/*무슨일이 있어도 취소되지 않음*/
		method suspendFree takes nothing returns nothing
			set .suspend_stun 		= false
			set .suspend_ensnare 	= false
			set .suspend_silence 	= false
			set .suspend_dead 		= false
			set .suspend_rclick 	= false
			set .suspend_ability	= true
			set .suspend_stop 		= false
		endmethod

		method operator caster takes nothing returns Unit_prototype
			return .actor
		endmethod

		method operator caster= takes Unit_prototype u returns nothing
			set .actor = u
		endmethod

		method operator owner takes nothing returns Unit_prototype
			return .caster
		endmethod

		method operator owner= takes Unit_prototype u returns nothing
			set .caster = u
		endmethod

		stub method rightClick takes nothing returns nothing

		endmethod

		stub method onSuspend takes nothing returns nothing

		endmethod

		stub method onComplete takes nothing returns nothing

		endmethod

		stub method periodicAction takes nothing returns nothing

		endmethod

		method resetChanneling takes nothing returns nothing
			if .channeling then
				call .caster.minusStatus(STATUS_CAST)
			endif
			set .channeling = false
		endmethod

		method unlinkAbility takes nothing returns nothing
			if .link_ability > 0 then
				call .link_ability.onUnlink()
				set .link_ability.link_actor = 0
			endif
			set .link_ability = 0
		endmethod

		stub method suspendFilterAdditional takes nothing returns boolean
			return false
		endmethod

		method suspendFilter takes nothing returns boolean
			return (suspend_stun and .caster.getStatus(STATUS_STUN) > 0) or /*
			*/(suspend_ensnare and .caster.getStatus(STATUS_ENSNARE) > 0) or /*
			*/(suspend_silence and .caster.getStatus(STATUS_SILENCE) > 0) or /*
			*/(suspend_dead and .caster.isUnitType(UNIT_TYPE_DEAD)) or /*
			*/suspendFilterAdditional()
		endmethod

		static method suspendAction takes nothing returns nothing
			local thistype this = Trigger.getData(GetTriggeringTrigger())
			if (BlzGetTriggerPlayerKey() == OSKEY_S and .suspend_stop) then
				call onSuspend()
				call destroy()
				return
			endif
			if RIGHT_CLICK_PLAYER == .caster.owner and RIGHT_CLICK_UNIT == null then
				if User.getFocusUnit(.caster.owner) == .caster then
					if .suspend_rclick then
						call onSuspend()
						call destroy()
						return
					else
						call rightClick()
					endif
				endif
				return
			endif
			if Event.getValue() == ABILITY_FOLLOW_EVENT then
				if ABILITY_CASTER == .caster and .suspend_ability then
					if not Ability_prototype(ABILITY_ABILITY).useable_cast then
						call onSuspend()
						call destroy()
					endif
				endif
				return
			endif
		endmethod

		static method create takes Unit_prototype caster, Unit_prototype target, real x, real y, integer level, real duration, boolean channeling returns thistype
			local thistype this = allocate(caster,x,y,duration)
			set .target = target
			set .level = level
			set .suspend_trigger = Trigger.new(this)
			set .suspend_condition = TriggerAddCondition(.suspend_trigger,function thistype.suspendAction)
			call BlzTriggerRegisterPlayerKeyEvent(.suspend_trigger,.caster.owner,OSKEY_S,0,true)
			call Event.triggerRegisterGenericRightClick(.suspend_trigger)
			call Event.triggerRegisterAbilityFollow(.suspend_trigger)
			set .channeling = channeling
			if .channeling then
				call .caster.plusStatus(STATUS_CAST)
			endif
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call resetChanneling()
			call TriggerRemoveCondition(.suspend_trigger,.suspend_condition)
			call Trigger.remove(.suspend_trigger)
			set .suspend_trigger = null
			set .suspend_condition = null
			call unlinkAbility()
		endmethod

	endstruct

	struct Backswing extends UnitActor

		private static constant real BACKSWING_DEFAULT = 0.25

		static method create takes Unit_prototype caster returns thistype
			local thistype this = allocate(caster,0,0,0,0,BACKSWING_DEFAULT/caster.attack_speed,true)
			set .suspend_rclick = true
			set .suspend_stop = true
			set .suspend_ability = true
			return this
		endmethod

	endstruct

	struct MeleeAttack extends UnitActor

		private static constant real DAMAGE_POINT_DEFAULT = 0.25

		stub method onSuspend takes nothing returns nothing
			call .caster.queueAnim("stand ready")
			call .caster.setAnimSpeed(1.0)
		endmethod

		stub method onComplete takes nothing returns nothing
			local Effect ef = 0
			call Damage.flagTempleteMeleeAttack()
			set DAMAGE_ID = 'Aatk'
			call caster.damageTarget(.target,.caster.attack,WEAPON_TYPE_METAL_MEDIUM_BASH)
			call Backswing.create(.caster)
		endmethod

		static method create takes Unit_prototype caster, Unit_prototype target returns thistype
			local thistype this = allocate(caster,target,0,0,0,DAMAGE_POINT_DEFAULT/caster.attack_speed,true)
			set .suspend_rclick = true
			set .suspend_stop = true
			call .caster.setAnim("stand")
			call .caster.setAnim("attack")
			call .caster.setAnimSpeed(1.0*.caster.attack_speed)
			call .caster.issueTargetOrder("attack",.target.origin_unit)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call .caster.queueAnim("stand ready")
			call .caster.setAnimSpeed(1.0)
		endmethod

	endstruct

endlibrary