library Moolgun

	globals
		private trigger INTERACTION_TRIGGER = CreateTrigger()
	endglobals

	struct Moolgun extends Agent

		method operator origin_moolgun takes nothing returns destructable
			return LoadDestructableHandle(HASH,GetHandleId(.origin_agent),INDEX_ORIGIN_HANDLE)
		endmethod

		method operator id takes nothing returns integer
			return GetDestructableTypeId(.origin_moolgun)
		endmethod

		method operator name takes nothing returns string
			return GetDestructableName(.origin_moolgun)
		endmethod

		method operator x takes nothing returns real
			return GetDestructableX(.origin_moolgun)
		endmethod

		method operator y takes nothing returns real
			return GetDestructableY(.origin_moolgun)
		endmethod

		method setAnim takes string s returns nothing
			call SetDestructableAnimation(.origin_moolgun,s)
		endmethod

		method setAnimSpeed takes real r returns nothing
			call SetDestructableAnimationSpeed(.origin_moolgun,r)
		endmethod

		stub method onInteract takes Unit_prototype caster returns nothing
			//call BJDebugMsg(.name)
		endmethod

		static method create takes integer did, real x, real y, real yaw returns thistype
			local thistype this = allocate(CreateDestructable(did,x,y,yaw,1.,0))
			return this
		endmethod

		static method get takes destructable ds returns thistype
			if HaveSavedInteger(HASH,GetHandleId(ds),INDEX_INSTANCE_ID) and ds != null then
				return LoadInteger(HASH,GetHandleId(ds),INDEX_INSTANCE_ID)
			else
				return 0
			endif
		endmethod

		static method interaction takes nothing returns nothing
			local thistype this = 0
			if GetSpellAbilityId() == 'Axx4' then
				set this = get(GetSpellTargetDestructable())
				if this > 0 then
					call onInteract(Unit_prototype.get(GetTriggerUnit()))
				endif
			elseif (GetIssuedOrderIdBJ() == String2OrderIdBJ("smart")) then
				call IssueTargetOrder(GetTriggerUnit(),"absorb",GetOrderTargetDestructable())
			endif
		endmethod

		static method onInit takes nothing returns nothing
			call TriggerRegisterAnyUnitEventBJ(INTERACTION_TRIGGER,EVENT_PLAYER_UNIT_SPELL_EFFECT)
			call TriggerRegisterAnyUnitEventBJ(INTERACTION_TRIGGER,EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
			call TriggerAddCondition(INTERACTION_TRIGGER,function thistype.interaction)
		endmethod

	endstruct

endlibrary