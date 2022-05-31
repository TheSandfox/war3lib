library YouCantAttackAlly initializer init

	globals
		private trigger TRIG = CreateTrigger()
	endglobals

	private function act takes nothing returns nothing
		if IsUnitAlly(GetTriggerUnit(),GetOwningPlayer(GetAttacker())) then
			call IssueImmediateOrder(GetAttacker(),"stop")
			//call BlzUnitInterruptAttack(GetAttacker())
		endif
	endfunction
	

	private function init takes nothing returns nothing
		call TriggerRegisterAnyUnitEventBJ(TRIG,EVENT_PLAYER_UNIT_ATTACKED)
		call TriggerAddCondition(TRIG,function act)
	endfunction

endlibrary