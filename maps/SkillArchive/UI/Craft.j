library Craft requires Frame, User

	globals
		private framehandle CRAFT_MIX_BACKDROP1
		private framehandle CRAFT_MIX_TIER_BORDER1
		private framehandle CRAFT_MIX_BTN1
		private framehandle CRAFT_MIX_BACKDROP2
		private framehandle CRAFT_MIX_TIER_BORDER2
		private framehandle CRAFT_MIX_BTN2
		private framehandle CRAFT_MIX_RESULT_BACKDROP
		private framehandle CRAFT_MIX_RESULT_TIER_BORDER
		private framehandle CRAFT_MIX_CONFIRM_BUTTON
		private framehandle CRAFT_MIX_CLEAR_BUTTON
		private framehandle CRAFT_MIX_PLUS
		private framehandle CRAFT_MIX_EQUAL
		private framehandle CRAFT_MIX_RESULT_COUNT
	endglobals

	struct Craft extends Closeable

		static constant integer PAGE_MIX = 0
		static constant integer PAGE_UPGRADE = 1
		static constant integer PAGE_MAX = 2

		player owner = null
		boolean visible_flag = false	
		implement ThisUI

		trigger keypress = null
		triggercondition keypress_cond = null

		integer page = -1
		/*MIX*/
		integer mix_target1 = 0
		integer mix_target2 = 0
		boolean mix_in1 = false
		boolean mix_in2 = false

		method setPage takes integer pg returns nothing
			local integer i = 0
			if pg < 0 or pg >= PAGE_MAX then
				return
			endif
			loop
				exitwhen i >= PAGE_MAX
				if LocalScope(.owner) then
					call BlzFrameSetVisible(FRAME_CRAFT_PAGE[i], i == pg)
				endif
				set i = i + 1
			endloop
			set .page = pg
		endmethod

		method setMixResult takes integer iid returns nothing
			if iid <= 0 then
				if LocalScope(.owner) then
					call BlzFrameSetTexture(CRAFT_MIX_RESULT_BACKDROP,"replaceabletextures\\commandbuttons\\btnblackicon.blp",0,true)
					call BlzFrameSetVisible(CRAFT_MIX_RESULT_TIER_BORDER,false)
					call BlzFrameSetText(CRAFT_MIX_PLUS,"|cff999999+|r")
					call BlzFrameSetText(CRAFT_MIX_EQUAL,"|cff999999->|r")
					call BlzFrameSetText(CRAFT_MIX_RESULT_COUNT,"")
				endif
			else
				if LocalScope(.owner) then
					call BlzFrameSetTexture(CRAFT_MIX_RESULT_BACKDROP,"replaceabletextures\\commandbuttons\\"+Item.getTypeIconPath(iid)+".blp",0,true)
					call BlzFrameSetVisible(CRAFT_MIX_RESULT_TIER_BORDER,true)
					call BlzFrameSetTexture(CRAFT_MIX_RESULT_TIER_BORDER,"textures\\ability_border_tier"+I2S(Item.getTypeTier(iid))+".blp",0,true)
					call BlzFrameSetText(CRAFT_MIX_PLUS,"|cffffcc00+|r")
					call BlzFrameSetText(CRAFT_MIX_EQUAL,"|cffffcc00->|r")
					call BlzFrameSetText(CRAFT_MIX_RESULT_COUNT,"|cffffcc00x"+I2S(Material.getMixResultCount(iid))+"|r")
				endif
			endif
		endmethod

		method setMixTarget takes integer index, integer iid returns nothing
			if index == 0 then
				if LocalScope(.owner) then
					call BlzFrameSetTexture(CRAFT_MIX_BACKDROP1,"replaceabletextures\\commandbuttons\\"+Item.getTypeIconPath(iid)+".blp",0,true)
					call BlzFrameSetTexture(CRAFT_MIX_TIER_BORDER1,"textures\\ability_border_tier"+I2S(Item.getTypeTier(iid))+".blp",0,true)
					call BlzFrameSetVisible(CRAFT_MIX_TIER_BORDER1,iid > 0)
					call BlzFrameSetVisible(CRAFT_MIX_BTN1,iid > 0)
				endif
				set .mix_target1 = iid
			elseif index == 1 then
				if LocalScope(.owner) then
					call BlzFrameSetTexture(CRAFT_MIX_BACKDROP2,"replaceabletextures\\commandbuttons\\"+Item.getTypeIconPath(iid)+".blp",0,true)
					call BlzFrameSetTexture(CRAFT_MIX_TIER_BORDER2,"textures\\ability_border_tier"+I2S(Item.getTypeTier(iid))+".blp",0,true)
					call BlzFrameSetVisible(CRAFT_MIX_TIER_BORDER2,iid > 0)
					call BlzFrameSetVisible(CRAFT_MIX_BTN2,iid > 0)
				endif
				set .mix_target2 = iid
			endif
			call setMixResult(Material.getMixResult(.mix_target1,.mix_target2))
		endmethod

		method clearMix takes nothing returns nothing
			call setMixTarget(0,0)
			call setMixTarget(1,0)
			call setMixResult(0)
		endmethod

		method adjustMix takes nothing returns nothing
			local Inventory inv = Inventory.THIS[GetPlayerId(.owner)]
			local Item it1 = 0
			local Item it2 = 0
			local Item new = 0
			local integer result = Material.getMixResult(.mix_target1,.mix_target2)
			/*조합 결과 존재 시*/
			if result > 0 then
				/*같은 재료를 합칠 때*/
				if .mix_target1 == .mix_target2 then
					set it1 = inv.getItem(Item.getTypeItemType(.mix_target1),inv.getItemIndexById(.mix_target1))
					/*인벤토리에 해당 아이템이 존재& 해당 아이템의 개수가 모자라지 않은지*/
					if it1 > 0 and it1.count >= 2 then
						call inv.consume(.mix_target1,2)
						set new = Item.new(result)
						set new.count = Material.getMixResultCount(result)
						call inv.addItem(new)
						if inv.getItemIndexById(.mix_target1) < 0 then
							call clearMix()
						endif
					endif
				/*다른 재료를 합칠 때*/
				else
					set it1 = inv.getItem(Item.getTypeItemType(.mix_target1),inv.getItemIndexById(.mix_target1))
					set it2 = inv.getItem(Item.getTypeItemType(.mix_target2),inv.getItemIndexById(.mix_target2))
					/*인벤토리에 해당 아이템이 존재& 해당 아이템의 개수가 모자라지 않은지*/
					if it1 > 0 and it2 > 0 then
						call inv.consume(.mix_target1,1)
						call inv.consume(.mix_target2,1)
						set new = Item.new(result)
						set new.count = Material.getMixResultCount(result)
						call inv.addItem(new)
						if inv.getItemIndexById(.mix_target1) < 0 or inv.getItemIndexById(.mix_target2) < 0 then
							call clearMix()
						endif
					endif
				endif
			endif
		endmethod

		method regist takes Item it returns nothing
			if it <= 0 then
				return
			endif
			if .page == PAGE_MIX then
				/*첫째칸에 등록된게 없으면*/
				if .mix_target1 <= 0 then
					call setMixTarget(0,it.id)
				/*둘째칸에 등록된게 없으면*/
				elseif .mix_target2 <= 0 then
					/*믹스테이블에 두번째 아이템이 등록되면 결과아이템 보여주기*/
					call setMixTarget(1,it.id)
				endif
				return
			elseif true then

			endif
		endmethod

		method visibleForPlayer takes boolean flag returns nothing
			local Inventory inv = 0
			set .visible_flag = flag
			if flag then
				set inv = Inventory.THIS[GetPlayerId(.owner)]
				if not inv.visible_flag then
					call inv.visibleForPlayer(true)
				endif
				if GetLocalPlayer() == .owner then
					call BlzFrameSetVisible(FRAME_CRAFT,true)
				endif
			else
				if GetLocalPlayer() == .owner then
					call BlzFrameSetVisible(FRAME_CRAFT,false)
				endif
				call clearMix()
			endif
		endmethod

		method close takes nothing returns boolean
			if .visible_flag then
				call visibleForPlayer(false)
				return true
			else
				return false
			endif
		endmethod

		method switch takes nothing returns nothing
			call visibleForPlayer(not .visible_flag)
		endmethod

		private static method press takes nothing returns nothing
			local thistype this = Trigger.getData(GetTriggeringTrigger())
			if GetTriggerPlayer() != .owner then
				return
			endif
			if BlzGetTriggerPlayerKey() == OSKEY_U then
				call switch()
				return
			elseif BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_ENTER then
				if BlzGetTriggerFrame() == CRAFT_MIX_BTN1 then
					set .mix_in1 = true
				elseif BlzGetTriggerFrame() == CRAFT_MIX_BTN2 then
					set .mix_in2 = true
				endif
				return
			elseif BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_LEAVE then
				if BlzGetTriggerFrame() == CRAFT_MIX_BTN1 then
					set .mix_in1 = false
				elseif BlzGetTriggerFrame() == CRAFT_MIX_BTN2 then
					set .mix_in2 = false
				endif
				return
			elseif BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_RIGHT then
				if .mix_in1 then
					call setMixTarget(0,0)
				elseif .mix_in2 then
					call setMixTarget(1,0)
				endif
				return
			elseif BlzGetTriggerFrame() == CRAFT_MIX_CONFIRM_BUTTON then
				call adjustMix()
			elseif BlzGetTriggerFrame() == CRAFT_MIX_CLEAR_BUTTON then
				call clearMix()
			endif
		endmethod

		static method create takes player owner returns thistype
			local thistype this = allocate()
			set .owner = owner
			/**/
			call setPage(PAGE_MIX)
			call clearMix()
			/*트리거*/
			set .keypress = Trigger.new(this)
			call BlzTriggerRegisterPlayerKeyEvent(.keypress,.owner,OSKEY_U,0,true)
			set .keypress_cond = TriggerAddCondition(.keypress,function thistype.press)
			call BlzTriggerRegisterFrameEvent(.keypress,CRAFT_MIX_BTN1,FRAMEEVENT_MOUSE_ENTER)
			call BlzTriggerRegisterFrameEvent(.keypress,CRAFT_MIX_BTN1,FRAMEEVENT_MOUSE_LEAVE)
			call BlzTriggerRegisterFrameEvent(.keypress,CRAFT_MIX_BTN2,FRAMEEVENT_MOUSE_ENTER)
			call BlzTriggerRegisterFrameEvent(.keypress,CRAFT_MIX_BTN2,FRAMEEVENT_MOUSE_LEAVE)
			call TriggerRegisterPlayerEvent(.keypress,.owner,EVENT_PLAYER_MOUSE_DOWN)
			call BlzTriggerRegisterFrameEvent(.keypress,CRAFT_MIX_CONFIRM_BUTTON,FRAMEEVENT_CONTROL_CLICK)
			call BlzTriggerRegisterFrameEvent(.keypress,CRAFT_MIX_CLEAR_BUTTON,FRAMEEVENT_CONTROL_CLICK)
			/**/
			set THIS[GetPlayerId(.owner)] = this
			return this
		endmethod

		method onDestroy takes nothing returns nothing

		endmethod

		static method init takes nothing returns nothing
			local trigger t = CreateTrigger()
			set CRAFT_MIX_CONFIRM_BUTTON = BlzCreateFrame("CraftMixConfirmButton",FRAME_CRAFT_PAGE[PAGE_MIX],0,0)
			call BlzFrameSetPointPixel(CRAFT_MIX_CONFIRM_BUTTON,FRAMEPOINT_BOTTOM,FRAME_CRAFT_PAGE[PAGE_MIX],FRAMEPOINT_BOTTOM,0,0)
			set CRAFT_MIX_CLEAR_BUTTON = BlzCreateFrame("CraftMixClearButton",FRAME_CRAFT_PAGE[PAGE_MIX],0,0)
			call BlzFrameSetPointPixel(CRAFT_MIX_CLEAR_BUTTON,FRAMEPOINT_BOTTOM,CRAFT_MIX_CONFIRM_BUTTON,FRAMEPOINT_TOP,0,0)
			set CRAFT_MIX_BACKDROP1 = BlzCreateFrameByType("BACKDROP","",FRAME_CRAFT_PAGE[PAGE_MIX],"",0)
			call BlzFrameSetSizePixel(CRAFT_MIX_BACKDROP1,64,64)
			set CRAFT_MIX_TIER_BORDER1 = BlzCreateFrameByType("BACKDROP","",CRAFT_MIX_BACKDROP1,"",0)
			call BlzFrameSetAllPoints(CRAFT_MIX_TIER_BORDER1,CRAFT_MIX_BACKDROP1)
			set CRAFT_MIX_BTN1 = BlzCreateFrameByType("BUTTON","",CRAFT_MIX_BACKDROP1,"",0)
			call BlzFrameSetAllPoints(CRAFT_MIX_BTN1,CRAFT_MIX_BACKDROP1)
			set CRAFT_MIX_BACKDROP2 = BlzCreateFrameByType("BACKDROP","",FRAME_CRAFT_PAGE[PAGE_MIX],"",0)
			call BlzFrameSetPointPixel(CRAFT_MIX_BACKDROP2,FRAMEPOINT_BOTTOM,CRAFT_MIX_CLEAR_BUTTON,FRAMEPOINT_TOP,0,16)
			call BlzFrameSetSizePixel(CRAFT_MIX_BACKDROP2,64,64)
			call BlzFrameSetPointPixel(CRAFT_MIX_BACKDROP1,FRAMEPOINT_RIGHT,CRAFT_MIX_BACKDROP2,FRAMEPOINT_LEFT,-48,0)
			set CRAFT_MIX_TIER_BORDER2 = BlzCreateFrameByType("BACKDROP","",CRAFT_MIX_BACKDROP2,"",0)
			call BlzFrameSetAllPoints(CRAFT_MIX_TIER_BORDER2,CRAFT_MIX_BACKDROP2)
			set CRAFT_MIX_BTN2 = BlzCreateFrameByType("BUTTON","",CRAFT_MIX_BACKDROP2,"",0)
			call BlzFrameSetAllPoints(CRAFT_MIX_BTN2,CRAFT_MIX_BACKDROP2)
			set CRAFT_MIX_RESULT_BACKDROP = BlzCreateFrameByType("BACKDROP","",FRAME_CRAFT_PAGE[PAGE_MIX],"",0)
			call BlzFrameSetPointPixel(CRAFT_MIX_RESULT_BACKDROP,FRAMEPOINT_LEFT,CRAFT_MIX_BACKDROP2,FRAMEPOINT_RIGHT,48,0)
			call BlzFrameSetSizePixel(CRAFT_MIX_RESULT_BACKDROP,64,64)
			set CRAFT_MIX_RESULT_TIER_BORDER = BlzCreateFrameByType("BACKDROP","",CRAFT_MIX_RESULT_BACKDROP,"",0)
			call BlzFrameSetAllPoints(CRAFT_MIX_RESULT_TIER_BORDER,CRAFT_MIX_RESULT_BACKDROP)
			set CRAFT_MIX_RESULT_COUNT = BlzCreateFrame("MyText",FRAME_CRAFT_PAGE[PAGE_MIX],0,0)
			call BlzFrameSetPointPixel(CRAFT_MIX_RESULT_COUNT,FRAMEPOINT_LEFT,CRAFT_MIX_RESULT_BACKDROP,FRAMEPOINT_RIGHT,4,0)
			set CRAFT_MIX_PLUS = BlzCreateFrame("MyTextLarge",FRAME_CRAFT_PAGE[PAGE_MIX],0,0)
			call BlzFrameSetPointPixel(CRAFT_MIX_PLUS,FRAMEPOINT_CENTER,CRAFT_MIX_BACKDROP1,FRAMEPOINT_RIGHT,24,0)
			set CRAFT_MIX_EQUAL = BlzCreateFrame("MyTextLarge",FRAME_CRAFT_PAGE[PAGE_MIX],0,0)
			call BlzFrameSetPointPixel(CRAFT_MIX_EQUAL,FRAMEPOINT_CENTER,CRAFT_MIX_BACKDROP2,FRAMEPOINT_RIGHT,24,0)
			/**/
			call BlzTriggerRegisterFrameEvent(t,CRAFT_MIX_BTN1,FRAMEEVENT_CONTROL_CLICK)
			call BlzTriggerRegisterFrameEvent(t,CRAFT_MIX_BTN1,FRAMEEVENT_MOUSE_ENTER)
			call BlzTriggerRegisterFrameEvent(t,CRAFT_MIX_BTN1,FRAMEEVENT_MOUSE_LEAVE)
			call BlzTriggerRegisterFrameEvent(t,CRAFT_MIX_BTN2,FRAMEEVENT_CONTROL_CLICK)
			call BlzTriggerRegisterFrameEvent(t,CRAFT_MIX_BTN2,FRAMEEVENT_MOUSE_ENTER)
			call BlzTriggerRegisterFrameEvent(t,CRAFT_MIX_BTN2,FRAMEEVENT_MOUSE_LEAVE)
			call BlzTriggerRegisterFrameEvent(t,CRAFT_MIX_CONFIRM_BUTTON,FRAMEEVENT_CONTROL_CLICK)
			call BlzTriggerRegisterFrameEvent(t,CRAFT_MIX_CONFIRM_BUTTON,FRAMEEVENT_MOUSE_ENTER)
			call BlzTriggerRegisterFrameEvent(t,CRAFT_MIX_CONFIRM_BUTTON,FRAMEEVENT_MOUSE_LEAVE)
			call BlzTriggerRegisterFrameEvent(t,CRAFT_MIX_CLEAR_BUTTON,FRAMEEVENT_CONTROL_CLICK)
			call BlzTriggerRegisterFrameEvent(t,CRAFT_MIX_CLEAR_BUTTON,FRAMEEVENT_MOUSE_ENTER)
			call BlzTriggerRegisterFrameEvent(t,CRAFT_MIX_CLEAR_BUTTON,FRAMEEVENT_MOUSE_LEAVE)
			call TriggerAddCondition(t,function Frame.resetFocus)
			set t = null
		endmethod

	endstruct

endlibrary