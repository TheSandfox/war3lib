library AbilityPrototype requires LocationEx

	globals
		trigger ABILITY_CREATE_TRIGGER = CreateTrigger()
		integer ABILITY_CREATE_ID = -1
		integer ABILITY_LAST_CREATED = -1
		trigger ERROR_MESSAGE_TRIGGER = CreateTrigger()
		player ERROR_MESSAGE_PLAYER = null
		string ERROR_MESSAGE = ""
		private constant real COMMAND_TIMER_TICK = 0.05
		trigger ABILITY_SYNC_TARGET_TRIGGER = CreateTrigger()
		trigger ABILITY_UI_REFRESH = CreateTrigger()
		player ABILITY_UI_REFRESH_PLAYER = null
	endglobals

	struct Ability_prototype

		timer cooldown_timer = null
		timer command_timer = null
		timer decay_timer = null
		timer indicator_timer = null

		Unit_prototype owner = 0
		AbilityIndicator indicator = 0
		UnitActor link_actor = 0
		boolean is_active = false
		boolean is_target = false
		boolean is_freetarget = false
		boolean is_immediate = false
		boolean useable_stun = false		/*스턴걸렸을때 쓸 수 있나*/
		boolean useable_cast = false		/*다른 동작 중일 때 쓸 수 있나*/
		boolean useable_ensnare = true		/*속박걸렸을 때 쓸 수 있나*/
		boolean useable_silence = false		/*침묵걸렸을 때 쓸 수 있나*/
		boolean useable_grabbed = false		/*잡혔을때 쓸 수 있나*/
		boolean useable_dead 	= false		/*죽었을 때 쓸 수 있나*/
		boolean target_useable_invincible = false	/*무적인 대상에게 쓸 수 있나*/
		boolean target_useable_enemy = true
		boolean target_useable_ally = false
		boolean target_useable_self = false
		boolean target_useable_grabbed = true	/*잡힌 대상에게 쓸 수 있나*/
		boolean target_useable_dead = false		/*죽은 대상에게 쓸 수 있나*/
		boolean reserve_order = true		/*명령예약가능여부*/
		boolean preserve_order = true		/*명령유지여부*/
		boolean is_following = false
		boolean is_reserving = false
		boolean drag_to_use = false
		boolean pressing = false
		boolean cancle_rightclick = true
		boolean check_cast = false	/*버튼입력 이벤트에서 캐스트필터 적용 여부*/
		integer smart = 1	/*0스마트 안함, 1사거리표시, 2노빠꾸*/

		integer id = 0
		string name = ""
		string icon = ""
		integer level = 1
		integer manacost = 0
		real cooldown_remaining = 0.
		real cooldown_max = 0.
		real cooldown_min = 0.
		integer count = 1
		integer count_max = 1
		integer value = 0
		real gauge = 0.

		real weapon_range = 150.
		real weapon_delay = 1.5
		boolean weapon_is_ranged = true

		trigger command_trigger = null
		triggercondition command_condition = null
		real command_x = 0.
		real command_y = 0.
		unit command_target = null
		real command_x2 = 0.
		real command_y2 = 0.
		real command_x_temp = 0.
		real command_y_temp = 0.
		boolean is_ai = false
		real ai_mouse_x = 0.
		real ai_mouse_y = 0.
		unit ai_target = null

		real cast_range = -1.

		real cast_delay = 0.

		boolean dead = false

		stub method addValue takes integer v returns nothing
			set .value = .value + v
		endmethod

		stub method addLevel takes integer v returns nothing
			set .level = .level + v
		endmethod

		stub method addCount takes nothing returns nothing
			set .count = .count + 1
		endmethod

		stub method useCount takes nothing returns nothing
			set .count = .count - 1
		endmethod

		method setIcon takes string newval returns nothing
			set .icon = newval
			set ABILITY_UI_REFRESH_PLAYER = .owner.owner
			call TriggerEvaluate(ABILITY_UI_REFRESH)
			set ABILITY_UI_REFRESH_PLAYER = null
		endmethod

		method getCarculatedCastDelayByAttackSpeed takes nothing returns real
			if .cast_delay / .owner.getCarculatedStatValue(STAT_TYPE_ATTACK_SPEED) > .cast_delay then
				return .cast_delay
			else
				return .cast_delay / .owner.getCarculatedStatValue(STAT_TYPE_ATTACK_SPEED)
			endif
		endmethod

		method getCarculatedManacost takes nothing returns real
			return I2R(.manacost)
		endmethod

		method getMaxCooldownBySpellBoost takes nothing returns real
			return .cooldown_max / (1+0.01*.owner.getCarculatedStatValue(STAT_TYPE_SPELL_BOOST))
		endmethod

		method getMaxCooldownValueByAttackSpeed takes nothing returns real	/*	0. ~ 1.0	*/
			local real v = .owner.getCarculatedStatValue(STAT_TYPE_ATTACK_SPEED)
			if v < 1. then
				return 1.
			else
				return 1./v
			endif
		endmethod

		stub method getMaxCooldown takes nothing returns real
			return getMaxCooldownBySpellBoost()
		endmethod

		method getCarculatedMaxCooldown takes nothing returns real
			local real v = getMaxCooldown()
			if v < .cooldown_min then
				return .cooldown_min
			else
				return v
			endif
		endmethod

		stub method iconClick takes nothing returns nothing
			
		endmethod

		stub method relativeTooltip takes nothing returns string
			return "MissingTooltip"
		endmethod

		method endCooldown takes nothing returns nothing
			if .count <= 0 then
				set .count = 1
			endif
			set .cooldown_remaining = 0.
			call Timer.pause(.cooldown_timer)
		endmethod

		method runCooldown takes real v returns nothing
			set .cooldown_remaining = .cooldown_remaining - v
			loop
				if .cooldown_remaining <= 0. then
					call addCount()
					if .count >= .count_max then
						call endCooldown()
						exitwhen true
					else
						set .cooldown_remaining = .cooldown_remaining + getCarculatedMaxCooldown()
					endif
				else
					exitwhen true
				endif
			endloop
		endmethod

		static method cooldownTimer takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			call runCooldown(TIMER_TICK)
		endmethod

		method startCooldown takes real v returns nothing
			if v > 0. and .cooldown_remaining <= 0. then
				set .cooldown_remaining = v
				call Timer.start(.cooldown_timer,TIMER_TICK,true,function thistype.cooldownTimer)
			endif
		endmethod

		stub method getCount takes nothing returns integer
			return .count
		endmethod

		stub method onUnlink takes nothing returns nothing
			call setPressState(false)
		endmethod

		method linkActor takes UnitActor na returns nothing
			set .link_actor = na
			set na.link_ability = this
		endmethod

		stub method basicAttack takes Unit_prototype target returns nothing

		endmethod

		stub method execute takes nothing returns nothing

		endmethod

		static method reservationTimer takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			call useRequest(.command_x,.command_y,.command_target,false)
		endmethod

		static method followTimer takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			/*if .is_target then
				call .owner.issuePointOrder("move",GetUnitX(.command_target),GetUnitY(.command_target))
			else
				call .owner.issuePointOrder("move",.command_x,.command_y)
			endif*/
			call useRequest(.command_x,.command_y,.command_target,false)
		endmethod

		method cancleFollow takes nothing returns nothing
			set .is_following = false
			call Timer.pause(.command_timer)
		endmethod

		method cancleReservation takes nothing returns nothing
			set .is_reserving = false
			call Timer.pause(.command_timer)
		endmethod

		method follow takes nothing returns nothing
			if not .is_following then
				if .is_target then
					call .owner.issueTargetOrder("channel",.command_target)
					if Mover.getUnitMover(.owner) > 0 then
						call Mover.getUnitMover(.owner).follow(.command_target)
					endif
				else
					call .owner.issuePointOrder("channel",.command_x,.command_y)
					if Mover.getUnitMover(.owner) > 0 then
						call Mover.getUnitMover(.owner).move(.command_x,.command_y)
					endif
				endif
			endif
			set .is_following = true
			call Timer.start(.command_timer,COMMAND_TIMER_TICK,true,function thistype.followTimer)
		endmethod

		method reserve takes nothing returns nothing
			set .is_reserving = true
			call Timer.start(.command_timer,COMMAND_TIMER_TICK,true,function thistype.reservationTimer)
		endmethod

		method checkDistance takes real x, real y, unit target returns boolean
			if .cast_range < 0. then
				return true
			else
				if .is_target then
					return IsUnitInRangeXY(target,.owner.x,.owner.y,.cast_range)
				else
					return .cast_range >= Math.distancePoints(.owner.x,.owner.y,x,y)
				endif
			endif
		endmethod

		stub method targetFilterAdditional takes Unit_prototype target returns boolean
			return true
		endmethod

		method targetFilter takes unit target returns boolean
			local Unit_prototype u = Unit_prototype.get(target)
			if .is_target and not .is_freetarget then
				if u == 0 then
					set ERROR_MESSAGE = "대상이 없습니다."
					return false
				else
					if not (.target_useable_invincible or .owner.getStatus(STATUS_INVINCIBLE) <= 0) then
						set ERROR_MESSAGE = "대상에게 사용할 수 없습니다."
						return false
					elseif not (.target_useable_enemy or not .owner.isEnemy(u.owner)) then
						set ERROR_MESSAGE = "적에게 사용할 수 없습니다."
						return false
					elseif not (.target_useable_self or .owner != u) then
						set ERROR_MESSAGE = "자신에게 사용할 수 없습니다."
						return false
					elseif not (.target_useable_ally or not .owner.isAlly(u.owner)) then
						set ERROR_MESSAGE = "아군에게 사용할 수 없습니다."
						return false
					elseif not (.target_useable_grabbed or .owner.getStatus(STATUS_GRABBED) <= 0) then
						set ERROR_MESSAGE = "붙잡힌 대상에게 사용할 수 없습니다."
						return false
					elseif u.isUnitType(UNIT_TYPE_DEAD) then
						return false
					elseif not u.isVisible(.owner.owner) then
						return false
					else
						return targetFilterAdditional(u)
					endif
				endif
			else
				return true
			endif
		endmethod

		method enableFilter takes nothing returns boolean
			if not (.useable_stun or .owner.getStatus(STATUS_STUN) <= 0) then
				set ERROR_MESSAGE = "기절 상태에서 사용할 수 없습니다."
				return false
			elseif not (.useable_ensnare or .owner.getStatus(STATUS_ENSNARE) <= 0) then
				set ERROR_MESSAGE = "이동불가 상태에서 사용할 수 없습니다."
				return false
			elseif not (.useable_silence or .owner.getStatus(STATUS_SILENCE) <= 0) then
				set ERROR_MESSAGE = "지금 사용할 수 없습니다."
				return false
			elseif not (.useable_grabbed or .owner.getStatus(STATUS_GRABBED) <= 0) then
				set ERROR_MESSAGE = "붙잡힌 상태에서 사용할 수 없습니다."
				return false
			elseif .owner.isUnitType(UNIT_TYPE_DEAD) then
				set ERROR_MESSAGE = "죽은 상태에서 사용할 수 없습니다."
				return false
			else
				return true
			endif
		endmethod

		method costFilter takes nothing returns boolean
			if .owner.mp < getCarculatedManacost() then
				set ERROR_MESSAGE = "마나가 부족합니다."
				return false
			elseif getCount() <= 0 and getCarculatedMaxCooldown() > 0. then
				set ERROR_MESSAGE = "아직 사용할 수 없습니다."
				return false
			else
				return true
			endif
		endmethod

		stub method useFilterAdditional takes nothing returns boolean
			return true
		endmethod

		method useFilter takes nothing returns boolean
			return costFilter() and enableFilter() and useFilterAdditional()
		endmethod

		method castFilter takes nothing returns boolean
			return (.useable_cast or .owner.getStatus(STATUS_CAST) <= 0)
		endmethod

		method sendError takes nothing returns nothing
			if ERROR_MESSAGE != "" then
				set ERROR_MESSAGE_PLAYER = .owner.owner
				call TriggerEvaluate(ERROR_MESSAGE_TRIGGER)
				if GetLocalPlayer() == .owner.owner then
					call PlaySoundBJ(gg_snd_Error)
				endif
			endif
		endmethod

		method confirmEffect takes nothing returns nothing
			local Effect ef = 0
			if .is_target and not .is_freetarget then
				set ef = TargetCircle.create(Unit_prototype.get(.command_target),.owner.owner)
				if IsUnitEnemy(.command_target,.owner.owner) then
					call ef.setLocalColor(255,0,0)
				elseif GetOwningPlayer(.command_target) == .owner.owner then
					call ef.setLocalColor(0,255,0)
				else
					call ef.setLocalColor(255,255,0)
				endif
			else
				set ef = Effect.create("UI\\Feedback\\Confirmation\\Confirmation.mdl",.command_x,.command_y,0.,0.)
				call ef.setLocalColor(0,255,0)
			endif
			if GetLocalPlayer() != .owner.owner then
				call ef.setLocalAlpha(0)
			endif
			call ef.setDuration(1.5)
		endmethod

		method pressSound takes nothing returns nothing
			if GetLocalPlayer() == .owner.owner then
				call PlaySoundBJ(gg_snd_MouseClick1)
			endif
		endmethod

		private method activateFollowTrigger takes nothing returns nothing
			set ABILITY_CASTER = .owner
			set ABILITY_TARGET = Unit_prototype.get(.command_target)
			set ABILITY_POSITION_X = .command_x
			set ABILITY_POSITION_Y = .command_y
			set ABILITY_ABILITY = this
			call Event.reset()
			call Event.activate(ABILITY_FOLLOW_EVENT)
			set ABILITY_CASTER = 0
			set ABILITY_TARGET = 0
			set ABILITY_POSITION_X = 0
			set ABILITY_POSITION_Y = 0
			set ABILITY_ABILITY = 0
		endmethod

		method useRequest takes real x, real y, unit target, boolean onpress returns boolean
			set ERROR_MESSAGE = ""
			set ERROR_MESSAGE_PLAYER = null
			set .command_x = x
			set .command_y = y
			set .command_target = target
			/*어빌리티 사용이 가능한가*/
			if enableFilter() and costFilter() and useFilterAdditional() then
				/*컨펌이펙트*/
				if onpress and not .is_target then
					call confirmEffect()
				endif
				/*타겟팅 조건에 부합하는가(타겟팅 스킬이 아니면 무조건 패스)*/
				if targetFilter(target) then
					if onpress and .is_target then
						call confirmEffect()
					endif
					/*쓸 수는 있는데 다른 행동중인가?*/
					if castFilter() then
						/*거리에 들어오는가*/
						if checkDistance(x,y,target) then
							set .owner.mp = .owner.mp - getCarculatedManacost()
							call startCooldown(getCarculatedMaxCooldown())
							call execute()
							call useCount()
							call cancleFollow()
							call cancleReservation()
							set ABILITY_CASTER = .owner
							set ABILITY_TARGET = Unit_prototype.get(.command_target)
							set ABILITY_POSITION_X = .command_x
							set ABILITY_POSITION_Y = .command_y
							set ABILITY_ABILITY = this
							call Event.reset()
							call Event.activate(ABILITY_CAST_EVENT)
							set ABILITY_CASTER = 0
							set ABILITY_TARGET = 0
							set ABILITY_POSITION_X = 0
							set ABILITY_POSITION_Y = 0
							set ABILITY_ABILITY = 0
							if not .preserve_order then
								call .owner.issueImmediateOrder("stop")
							endif
							return true
						/*거리에 안들어오면 대상 추적타이머 작동*/
						else
							call follow()
							call activateFollowTrigger()
							return false
						endif
					/*다른 행동 중이면 예약타이머 작동*/
					else
						if .reserve_order then
							call reserve()
							call activateFollowTrigger()
						endif
						return false
					endif
				/*타겟팅 조건에 부합하지 않으면 따라가기 취소*/
				else
					call cancleFollow()
					return false
				endif
			/*사용이 불가능하면*/
			else
				return false
			endif
		endmethod

		stub method init takes nothing returns nothing	/*be called external*/

		endmethod

		stub method update takes nothing returns nothing /*be called external*/

		endmethod

		method pressRequest takes nothing returns boolean
			local real mx = 0.
			local real my = 0.
			if not .is_target and not .is_freetarget then
				call .owner.cancleAbilityReservation()
				call .owner.cancleAbilityFollow()
				if .drag_to_use then
					set mx = .command_x
					set my = .command_y
				else
					if .is_ai then
						set mx = .ai_mouse_x
						set my = .ai_mouse_y
					else
						set mx = Mouse.getX(.owner.owner)
						set my = Mouse.getY(.owner.owner)
					endif
				endif
				if not useRequest(mx,my,null,true) then
					call sendError()
					return false
				else
					return true
				endif
			else
				if .is_ai then
					if .ai_target != null then
						return useRequest(.ai_mouse_x,.ai_mouse_y,.ai_target,true)
					else
						return false
					endif
				else
					call sendSyncTarget()
					return true
				endif
			endif
		endmethod

		private static method refreshIndicatorTimer takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			if .indicator > 0 then
				call .indicator.refresh()
				call .indicator.refreshEssencial()
			endif
		endmethod

		method setPressState takes boolean flag returns nothing
			if .indicator > 0 then
				call .indicator.show(flag)
				call .indicator.showEssencial(flag)
				if flag then
					call .indicator.refresh()
					call .indicator.refreshEssencial()
					call Timer.start(.indicator_timer,0.025,true,function thistype.refreshIndicatorTimer)
				else
					call Timer.pause(.indicator_timer)
				endif
			endif
			set .pressing = flag
		endmethod

		stub method onRelease takes nothing returns nothing

		endmethod

		stub method beforeRelease takes nothing returns nothing

		endmethod

		method release takes nothing returns nothing
			set .command_x = .command_x_temp
			set .command_y = .command_y_temp
			if .drag_to_use then
				if .is_ai then
					set .command_x2 = .ai_mouse_x
					set .command_y2 = .ai_mouse_y
				else	
					set .command_x2 = Mouse.getX(.owner.owner)
					set .command_y2 = Mouse.getY(.owner.owner)
				endif
			endif
			call beforeRelease()
			if .is_active and .pressing then
				call pressRequest()
			endif
			call setPressState(false)
			call onRelease()
		endmethod

		stub method onKeyboard takes nothing returns nothing

		endmethod

		stub method onPress takes nothing returns nothing

		endmethod

		stub method beforePress takes nothing returns nothing

		endmethod

		method press takes nothing returns nothing
			call pressSound()
			call beforePress()
			if useFilter() and (not .check_cast or castFilter() )then
				if .is_ai then
					set .command_x_temp = .ai_mouse_x
					set .command_y_temp = .ai_mouse_y
				else
					set .command_x_temp = Mouse.getX(.owner.owner)
					set .command_y_temp = Mouse.getY(.owner.owner)
				endif
				call setPressState(true)
				if (.is_immediate or .smart==2) and not .drag_to_use then
					call release()
				endif
			else
				call sendError()
			endif
			call onPress()
		endmethod

		stub method getAttackSpeedValue takes real v returns real
			return v
		endmethod

		stub method leftClick takes nothing returns nothing
			call release()
		endmethod

		stub method onRightClick takes nothing returns nothing

		endmethod

		stub method onStop takes nothing returns nothing

		endmethod

		method rightClick takes nothing returns nothing
			call cancleFollow()
			call cancleReservation()
			if .cancle_rightclick then
				call setPressState(false)
			endif
			call onRightClick()
		endmethod

		stub method stopButton takes nothing returns nothing
			call cancleFollow()
			call cancleReservation()
			call onStop()
		endmethod

		static method commandAction takes nothing returns nothing
			local thistype this = Trigger.getData(GetTriggeringTrigger())
			if BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_RIGHT then
				call rightClick()
			elseif BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_LEFT then
				call leftClick()
			elseif BlzGetTriggerPlayerKey() == OSKEY_S then
				call stopButton()
			endif
		endmethod

		/*CALLED BY Unit_prototype.addAbility()*/
		method essentialInit takes nothing returns nothing
			set .cooldown_timer = Timer.new(this)
			set .command_trigger = Trigger.new(this)
			set .command_condition = TriggerAddCondition(.command_trigger,function thistype.commandAction)
			set .command_timer = Timer.new(this)
			set .decay_timer = Timer.new(this)
			set .indicator_timer = Timer.new(this)
			call BlzTriggerRegisterPlayerKeyEvent(.command_trigger,.owner.owner,OSKEY_S,0,true)
			call TriggerRegisterPlayerEvent(.command_trigger,.owner.owner,EVENT_PLAYER_MOUSE_DOWN)
		endmethod

		static method create takes nothing returns thistype
			local thistype this = allocate()			
			return this
		endmethod

		stub method onDeath takes nothing returns nothing

		endmethod

		static method decay takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			call destroy()
		endmethod

		method kill takes nothing returns nothing	/*DO NOT CALL .destroy()*/
			if not .dead then
				/*웨폰비활성화*/
				if .owner.weapon_ability == this then
					call .owner.setWeaponAbility(0)
				endif
				/*액터링크 해제*/
				if .link_actor > 0 then
					call .link_actor.destroy()
				endif
				set .link_actor = 0
				/*사망 시*/
				call onDeath()
				/*핸들프리*/
				call Timer.release(.cooldown_timer)
				set .cooldown_timer = null
				call TriggerRemoveCondition(.command_trigger,.command_condition)
				call Trigger.remove(.command_trigger)
				set .command_trigger = null
				set .command_condition = null
				call Timer.release(.command_timer)
				set .command_timer = null
				set .command_target = null
				call Timer.release(.indicator_timer)
				set .indicator_timer = null
				set .ai_target = null
				/*인디케이터 디스트로이*/
				if .indicator > 0 then
					call .indicator.destroy()
					set .indicator = 0
				endif
				/*디케이*/
				call Timer.start(.decay_timer,1.25,false,function thistype.decay)
			endif
			set .dead = true
		endmethod

		method onDestroy takes nothing returns nothing
			call Timer.release(.decay_timer)
			set .decay_timer = null
		endmethod

		static method new takes integer aid returns thistype
			set ABILITY_LAST_CREATED = -1
			set ABILITY_CREATE_ID = aid
			call TriggerEvaluate(ABILITY_CREATE_TRIGGER)
			return ABILITY_LAST_CREATED
		endmethod

		method sendSyncTarget takes nothing returns nothing
			if GetLocalPlayer() == .owner.owner then
				call BlzSendSyncData("SA",I2S(this)+"#"+I2S(GetHandleId(BlzGetMouseFocusUnit())))
			endif
		endmethod

		static method syncTarget takes nothing returns nothing
			local string source = BlzGetTriggerSyncData()
			local unit u = null
			local integer i = 0
			local integer l = StringLength(source)
			local thistype this = 0
			/*String To Integer*/
			loop
				exitwhen SubString(source,i,i+1) == "#"
				set i = i + 1
			endloop
			//call BJDebugMsg(source+", "+instance+", "+unithandle)
			set u = Agent.H2U(S2I(SubString(source,i+1,l)))
			/*인스턴스 액션*/
			set this = S2I(SubString(source,0,i))
			if this > 0 and not .dead then
				call .owner.cancleAbilityReservation()
				call .owner.cancleAbilityFollow()
				call pressSound()
				if not useRequest(.command_x,.command_y,u,true) then
					call sendError()
				endif
			endif
			set u = null
		endmethod

		static method onInit takes nothing returns nothing
			local integer i = 0
			loop
				exitwhen i >= PLAYER_MAX
				call BlzTriggerRegisterPlayerSyncEvent(ABILITY_SYNC_TARGET_TRIGGER,Player(i),"SA",false)
				set i = i + 1
			endloop
			call TriggerAddAction(ABILITY_SYNC_TARGET_TRIGGER,function thistype.syncTarget)
		endmethod

	endstruct

endlibrary

//! import "AbilityIndicator.j"