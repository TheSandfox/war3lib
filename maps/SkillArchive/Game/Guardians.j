library Guardians requires UnitData

	struct Guardian extends Unit

		real origin_x = 0.
		real origin_y = 0.
		real origin_yaw = 0.
		boolean moving = false
		boolean attacking = false
		integer position = 0

		real acquire_range = 600.
		Undead target = 0
		timer ai_timer = null

		static method guardianDeath takes nothing returns nothing
			local thistype this = DEATH_UNIT
			local integer i = 0
			local unit u = null
			local Undead ud = 0
			if this <= 0 or .class != "Guardian" then
				return
			endif
			loop
				set u = BlzGroupUnitAt(Undead_GROUP,i)
				exitwhen u == null
				set ud = Unit_prototype.get(u)
				if ud.position == .position then
					call ud.encount()
				endif
				set i = i + 1
			endloop
			set u = null
		endmethod

		method countUndeads takes nothing returns integer
			local integer i = 0
			local integer j = 0
			local unit u = null
			local Undead ud = 0
			local real dist = 0.
			set .target = 0
			loop
				set u = BlzGroupUnitAt(Undead_GROUP,i)
				exitwhen u == null
				set ud = Unit_prototype.get(u)
				if ud.inRange(.x,.y,.acquire_range) then
					if j == 0 then
						set .target = ud
						set dist = Math.distancePoints(.x,.y,ud.x,ud.y)
					elseif Math.distancePoints(.x,.y,ud.x,ud.y) < dist then
						set .target = ud
						set dist = Math.distancePoints(.x,.y,ud.x,ud.y)
					endif
					set j = j + 1
				endif
				set i = i + 1
			endloop
			set u = null
			return j
		endmethod

		method targetAction takes nothing returns nothing
			
		endmethod

		static method timerAction takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			if isUnitType(UNIT_TYPE_DEAD) then
				return
			endif
			if countUndeads() <=  0 then
				set .attacking = false
				if Math.distancePoints(.x,.y,.origin_x,.origin_y) < 32. then
					call issueImmediateOrder("holdposition")
					call SetUnitFacing(.origin_unit,.origin_yaw)
					set .moving = false
				else
					if not .moving then
						call issuePointOrder("move",.origin_x,.origin_y)
						set .moving = true
					endif
				endif
			else
				set .moving = false
				if not .attacking then
					call issueTargetOrder("attack",.target.origin_unit)
					set .attacking = true
				else
					call targetAction()
				endif
			endif
		endmethod

		static method create takes real x, real y, real facing, integer position returns thistype
			local thistype this = allocate(PLAYER_GUARDIANS,'G000',x,y,facing)
			local integer i = 0
			local Ability a = 0
			set .origin_x = x
			set .origin_y = y
			set .origin_yaw = facing
			set .class = "Guardian"
			set .position = position
			loop
				exitwhen getAbility(i) <= 0
				set a = getAbility(i)
				set a.is_ai = true
				set i = i + 1
			endloop
			set .main_timer = Timer.new(this)
			call Timer.start(.main_timer,1.0,true,function thistype.timerAction)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call Timer.release(.main_timer)
			set .main_timer = null
		endmethod

		static method onInit takes nothing returns nothing
			call TriggerAddCondition(DEATH_TRIGGER,function thistype.guardianDeath)
		endmethod

	endstruct

	struct GuardianFrame

		implement ThisUI

		static constant integer WIDTH = 128
		static constant integer HEIGHT = 48
		static constant real OFFSET_X = 4

		Unit target = 0
		integer index = 0
		framehandle container = null
		framehandle icon = null
		framehandle gauge_backdrop = null
		framehandle gauge_fill = null
		framehandle position = null
		framehandle death = null
		boolean in = false	/*local*/

		trigger main_trigger = null
		triggercondition main_cond = null

		method refresh takes nothing returns nothing
			local real val = .target.hp / .target.maxhp
			call BlzFrameSetVisible(.gauge_fill,val > 0.05)
			call BlzFrameSetSizePixel(.gauge_fill,(WIDTH-HEIGHT)*val,8)
			call BlzFrameSetVisible(.death,.target.getStatus(STATUS_DEAD) > 0)
		endmethod

		static method cond takes nothing returns nothing
			local thistype this = Trigger.getData(GetTriggeringTrigger())
			if GetLocalPlayer() == GetTriggerPlayer() then
				call BlzFrameSetEnable(.container,false)
				call BlzFrameSetEnable(.container,true)
				if BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_ENTER then
					set .in = true
				elseif BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_LEAVE then
					set .in = false
				elseif BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_LEFT then
					if .in then
						call PanCameraToTimed(.target.x,.target.y,0.)
					endif
				endif
			endif
		endmethod

		static method create takes Unit target, integer index returns thistype
			local thistype this = allocate()
			local integer i = 0 
			set .target = target
			set .index = index
			/*FRAME*/
			set .container = BlzCreateFrameByType("BUTTON","",FRAME_GAME_UI,"",0)
			call BlzFrameSetPointPixel(.container,FRAMEPOINT_TOPLEFT,FRAME_MINIMAP_BACKDROP,FRAMEPOINT_TOPRIGHT,4,-(HEIGHT+10)*index)
			call BlzFrameSetSizePixel(.container,HEIGHT,HEIGHT)
			set .icon = BlzCreateFrameByType("BACKDROP","",.container,"",0)
			call BlzFrameSetPoint(.icon,FRAMEPOINT_TOPLEFT,.container,FRAMEPOINT_TOPLEFT,0.,0.)
			call BlzFrameSetSizePixel(.icon,HEIGHT,HEIGHT)
			call BlzFrameSetTexture(.icon,"ReplaceableTextures\\CommandButtons\\"+UnitData.getIconPath(.target.id)+".blp",0,true)
			set .gauge_backdrop = BlzCreateFrameByType("BACKDROP","",.container,"",0)
			call BlzFrameSetPoint(.gauge_backdrop,FRAMEPOINT_BOTTOMLEFT,.icon,FRAMEPOINT_BOTTOMRIGHT,0.,0.)
			call BlzFrameSetSizePixel(.gauge_backdrop,WIDTH-HEIGHT,8)
			call BlzFrameSetTexture(.gauge_backdrop,"ReplaceableTextures\\teamcolor\\teamcolor00.blp",0,true)
			call BlzFrameSetAlpha(.gauge_backdrop,128)
			set .gauge_fill = BlzCreateFrameByType("BACKDROP","",.container,"",0)
			call BlzFrameSetPoint(.gauge_fill,FRAMEPOINT_BOTTOMLEFT,.gauge_backdrop,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			call BlzFrameSetTexture(.gauge_fill,"ReplaceableTextures\\teamcolor\\teamcolor06.blp",0,true)
			call BlzFrameSetVisible(.gauge_fill,false)
			set .death = BlzCreateFrameByType("BACKDROP","",.container,"",0)
			call BlzFrameSetAllPoints(.death,.icon)
			call BlzFrameSetTexture(.death,"ReplaceableTextures\\teamcolor\\teamcolor00.blp",0,true)
			call BlzFrameSetAlpha(.death,128)
			call BlzFrameSetVisible(.death,false)
			set .position = BlzCreateFrameByType("BACKDROP","",.container,"",0)
			call BlzFrameSetPoint(.position,FRAMEPOINT_TOPLEFT,.icon,FRAMEPOINT_TOPRIGHT,0,0)
			call BlzFrameSetSizePixel(.position,32,32)
			if index ==  0 then
				call BlzFrameSetTexture(.position,"Textures\\ui_position_top",0,true)
			elseif index == 1 then
				call BlzFrameSetTexture(.position,"Textures\\ui_position_left",0,true)
			elseif index == 2 then
				call BlzFrameSetTexture(.position,"Textures\\ui_position_right",0,true)
			elseif index == 3 then
				call BlzFrameSetTexture(.position,"Textures\\ui_position_bottom",0,true)
			else
				call BlzFrameSetTexture(.position,"replaceabletextures\\commandbuttons\\btnblackicon.blp",0,true)
			endif
			/**/
			set .main_trigger = Trigger.new(this)
			set .main_cond = TriggerAddCondition(.main_trigger,function thistype.cond)
			loop
				exitwhen i >= PLAYER_MAX
				call TriggerRegisterPlayerEvent(.main_trigger,Player(i),EVENT_PLAYER_MOUSE_DOWN)
				set i = i + 1
			endloop
			call BlzTriggerRegisterFrameEvent(.main_trigger,.container,FRAMEEVENT_MOUSE_LEAVE)
			call BlzTriggerRegisterFrameEvent(.main_trigger,.container,FRAMEEVENT_MOUSE_ENTER)
			/**/
			call refresh()
			set THIS[.index] = this
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			//! runtextmacro destroyFrame(".container")
			//! runtextmacro destroyFrame(".icon")
			//! runtextmacro destroyFrame(".gauge_backdrop")
			//! runtextmacro destroyFrame(".gauge_fill")
			//! runtextmacro destroyFrame(".position")
			//! runtextmacro destroyFrame(".death")
			//! runtextmacro destroyTriggerAndCondition(".main_trigger",".main_cond")
			set THIS[.index] = 0
		endmethod

	endstruct

	struct Guardians

		static Unit array GUARDIAN
		static timer FRAME_REFRESH_TIMER = null

		static method kill takes nothing returns nothing
			call GUARDIAN[0].kill()
			set GUARDIAN[0].hp = 1.
			call GUARDIAN[1].kill()
			set GUARDIAN[1].hp = 1.
			call GUARDIAN[2].kill()
			set GUARDIAN[2].hp = 1.
			call GUARDIAN[3].kill()
			set GUARDIAN[3].hp = 1.
		endmethod

		static method addLevel takes nothing returns nothing
			local Effect ef = 0
			local integer i = 0
			loop
				exitwhen i >= 4
				set GUARDIAN[i].level = GUARDIAN[i].level + 1
				set ef = Effect.createAttatched("Abilities\\Spells\\Other\\Levelup\\LevelupCaster.mdl",GUARDIAN[i].origin_unit,"origin").setDuration(1.5)
				set i = i + 1
			endloop
		endmethod

		static method refreshFrame takes nothing returns nothing
			call GuardianFrame.THIS[0].refresh()
			call GuardianFrame.THIS[1].refresh()
			call GuardianFrame.THIS[2].refresh()
			call GuardianFrame.THIS[3].refresh()
		endmethod

		static method init takes nothing returns nothing
			local integer i = 0
			set GUARDIAN[0] = Guardian.create(GetRectCenterX(gg_rct_GuardianNorth),GetRectCenterY(gg_rct_GuardianNorth),90.,0)
			set GUARDIAN[1] = Guardian.create(GetRectCenterX(gg_rct_GuardianWest),GetRectCenterY(gg_rct_GuardianWest),180.,1)
			set GUARDIAN[2] = Guardian.create(GetRectCenterX(gg_rct_GuardianEast),GetRectCenterY(gg_rct_GuardianEast),0.,2)
			set GUARDIAN[3] = Guardian.create(GetRectCenterX(gg_rct_GuardianSouth),GetRectCenterY(gg_rct_GuardianSouth),270.,3)
			loop
				exitwhen i >= 4
				set GUARDIAN[i].is_revive = true
				set GUARDIAN[i].level = 10
				call GuardianFrame.create(GUARDIAN[i],i)
				set i = i + 1
			endloop
			set FRAME_REFRESH_TIMER = Timer.new(0)
			call Timer.start(FRAME_REFRESH_TIMER,0.25,true,function thistype.refreshFrame)
		endmethod

	endstruct

endlibrary