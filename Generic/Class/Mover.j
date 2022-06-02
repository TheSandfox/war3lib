library Mover

	struct Mover

		static hashtable HASH = InitHashtable()

		Unit_prototype owner = 0
		real velo = 1. /**/
		boolean refresh_facing = true

		timer main_timer = null
		trigger main_trigger = null
		triggercondition main_cond = null
		unit dummy = null

		method stop takes nothing returns nothing
			call IssueImmediateOrder(.dummy,"stop")
		endmethod

		method move takes real nx, real ny returns nothing
			call IssuePointOrder(.dummy,"move",nx,ny)
		endmethod

		method follow takes widget w returns nothing
			call IssueTargetOrder(.dummy,"channel",w)
		endmethod

		static method getUnitMover takes Unit_prototype u returns thistype
			if HaveSavedInteger(HASH,u,0) then
				return LoadInteger(HASH,u,0)
			else
				return 0
			endif
		endmethod

		static method timerAction takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			local real nx = 0. 
			local real ny = 0.
			call SetUnitMoveSpeed(.dummy,.owner.movement_speed*velo)
			if .owner.isMoveable() then
				if .refresh_facing then
					call SetUnitFacing(.owner.origin_unit,GetUnitFacing(.dummy))
				endif
				set nx = GetUnitX(.dummy)
				set ny = GetUnitY(.dummy)
				call SetUnitX(.owner.origin_unit,nx)
				call SetUnitY(.owner.origin_unit,ny)
				call SetUnitX(.dummy,nx)
				call SetUnitY(.dummy,ny)
			else
				call SetUnitX(.dummy,.owner.x)
				call SetUnitY(.dummy,.owner.y)
			endif
		endmethod

		static method triggerAction takes nothing returns nothing
			local thistype this = Trigger.getData(GetTriggeringTrigger())
			if RIGHT_CLICK_ENABLE and RIGHT_CLICK_PLAYER == .owner.owner then
				if User.getFocusUnit(.owner.owner) == .owner then
					call move(RIGHT_CLICK_X,RIGHT_CLICK_Y) 
				endif
			elseif BlzGetTriggerPlayerKey() == OSKEY_S or BlzGetTriggerPlayerKey() == OSKEY_H then
				call stop()
			endif
		endmethod

		static method create takes Unit_prototype owner returns thistype
			local thistype this = 0
			if getUnitMover(owner) > 0 then
				call getUnitMover(owner).destroy()
			endif
			set this = allocate()
			set .owner = owner
			set .dummy = .owner.mover_unit/**/
			call SetUnitX(.dummy,.owner.x)
			call SetUnitY(.dummy,.owner.y)
			set .main_timer = Timer.new(this)
			set .main_trigger = Trigger.new(this)
			set .main_cond = TriggerAddCondition(.main_trigger,function thistype.triggerAction)
			call Event.triggerRegisterGenericRightClick(.main_trigger)
			call BlzTriggerRegisterPlayerKeyEvent(.main_trigger,.owner.owner,OSKEY_S,0,true)
			call BlzTriggerRegisterPlayerKeyEvent(.main_trigger,.owner.owner,OSKEY_H,0,true)
			call Timer.start(.main_timer,TIMER_TICK,true,function thistype.timerAction)
			call BlzPauseUnitEx(.owner.origin_unit,true)
			call SetUnitMoveSpeed(.dummy,.owner.movement_speed*velo)
			call SaveInteger(HASH,.owner,0,this)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call LocationEx.collisionProjection(.owner.x,.owner.y)
			call SetUnitX(.owner.origin_unit,LocationEx.getX())
			call SetUnitY(.owner.origin_unit,LocationEx.getY())
			call BlzPauseUnitEx(.owner.origin_unit,false)
			call Timer.release(.main_timer)
			call TriggerRemoveCondition(.main_trigger,.main_cond)
			call Trigger.remove(.main_trigger)
			set .main_trigger = null
			set .main_cond = null
			set .main_timer = null
			call SetUnitMoveSpeed(.dummy,10.)
			//call ShowUnit(.dummy,false)
			set .dummy = null
			call RemoveSavedInteger(HASH,.owner,0)
		endmethod

	endstruct

endlibrary