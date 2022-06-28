library Inventory requires UI

	globals
		private constant integer PER_ROW = 8
		private constant integer PER_COL = 5
		private constant integer SLOT = PER_ROW * PER_COL
		private constant integer CATEGORY = 8
		private constant integer INSET_Y = 40
		private constant integer SIZE = 40
		private trigger INVENTORY_RIGHTCLICK = CreateTrigger()
		private integer INVENTORY_RIGHTCLICK_INDEX = -1
		private player INVENTORY_RIGHTCLICK_PLAYER = null
	endglobals

	struct InventoryIcon extends IconFrame

		integer index = -1

		Item target = -1
		player owner = null
		framehandle icon = null
		framehandle btn = null
		framehandle tooltip = null //EXTERNAL!!!!

		trigger main_trigger = null
		triggercondition main_cond = null
		boolean in = false

		method showTooltip takes nothing returns nothing
			if .tooltip != null then
				call BlzFrameSetVisible(.tooltip,false)
				call BlzFrameSetVisible(.tooltip,GetLocalPlayer() == .owner)
			endif
		endmethod

		method setTarget takes Item target returns nothing
			if .target > 0 then
				call .target.resetTooltip()
			endif
			set .tooltip = null
			if .target != target then
				if target <= 0 then
					call BlzFrameSetTexture(.icon,"replaceabletextures\\commandbuttons\\btnblackicon.blp",0,true)
					call BlzFrameSetAlpha(.icon,64)
					/*트리거&프레임 비활성화*/
					set .in = false
					call BlzFrameSetVisible(.btn,false)
					call DisableTrigger(.main_trigger)
				else
					call BlzFrameSetTexture(.icon,"replaceabletextures\\commandbuttons\\"+target.icon+".blp",0,true)
					call BlzFrameSetAlpha(.icon,255)
					call target.resetTooltip()
					call target.setTooltipPosition(FRAME_INVENTORY,FRAMEPOINT_TOPLEFT,0.,0.,.owner,0)
					set .tooltip = target.tooltip_container
					/*트리거&프레임 활성화*/
					call BlzFrameSetVisible(.btn,true)
					call EnableTrigger(.main_trigger)
				endif
			endif
			set .target = target
		endmethod

		static method cond takes nothing returns nothing
			local thistype this = Trigger.getData(GetTriggeringTrigger())
			call BlzFrameSetEnable(BlzGetTriggerFrame(),false)
			call BlzFrameSetEnable(BlzGetTriggerFrame(),true)
			if BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_ENTER then
				call showTooltip()
				set .in = true
			elseif BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_LEAVE then
				if .tooltip != null then
					call BlzFrameSetVisible(.tooltip,false)
				endif
				set .in = false
			elseif .in and BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_RIGHT then
				if .target > 0 then
					set INVENTORY_RIGHTCLICK_INDEX = .index
					set INVENTORY_RIGHTCLICK_PLAYER = .owner
					call TriggerEvaluate(INVENTORY_RIGHTCLICK)
				endif
			endif
		endmethod

		static method create takes player owner, integer index returns thistype
			local thistype this = allocate()
			set .index = index
			set .owner = owner
			set .main_trigger = Trigger.new(this)
			set .main_cond = TriggerAddCondition(.main_trigger,function thistype.cond)
			set .icon = BlzCreateFrameByType("BACKDROP","",FRAME_INVENTORY,"",0)
			call BlzFrameSetPointPixel(.icon,FRAMEPOINT_TOPLEFT,FRAME_INVENTORY,FRAMEPOINT_TOPLEFT,32+ModuloInteger(index,PER_ROW)*SIZE,-32-INSET_Y-R2I(index/PER_ROW)*SIZE)
			call BlzFrameSetSizePixel(.icon,SIZE,SIZE)
			set .btn = BlzCreateFrameByType("BUTTON","",FRAME_INVENTORY,"",0)
			call BlzFrameSetAllPoints(.btn,.icon)
			call BlzTriggerRegisterFrameEvent(.main_trigger,.btn,FRAMEEVENT_MOUSE_ENTER)
			call BlzTriggerRegisterFrameEvent(.main_trigger,.btn,FRAMEEVENT_MOUSE_LEAVE)
			call BlzTriggerRegisterFrameEvent(.main_trigger,.btn,FRAMEEVENT_CONTROL_CLICK)
			call TriggerRegisterPlayerEvent(.main_trigger,.owner,EVENT_PLAYER_MOUSE_DOWN)
			//
			call setTarget(0)
			call BlzFrameSetVisible(.icon,GetLocalPlayer()==.owner)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			//! runtextmacro destroyFrame(".icon")
			//! runtextmacro destroyFrame(".btn")
			//! runtextmacro destroyTriggerAndCondition(".main_trigger",".main_cond")
			set .tooltip = null
			set .owner = null
		endmethod

	endstruct

	struct Inventory extends Closeable

		private static hashtable HASH = InitHashtable()

		static integer CATEGORY_MATERIAL = 0
		static integer CATEGORY_ARTIFACT = 1

		trigger keypress = null
		triggercondition keypress_cond = null
		boolean visible_flag = false
		player owner = null
		integer category = 0
		implement ThisUI

		method setItem takes integer category, integer index, Item it returns nothing
			call SaveInteger(HASH,this,index+category*SLOT,it)
		endmethod

		method getItem takes integer category, integer index returns Item
			if HaveSavedInteger(HASH,this,index+category*SLOT) then
				return LoadInteger(HASH,this,index+category*SLOT)
			else
				return 0
			endif
		endmethod

		method addItem takes integer category, Item it returns boolean
			local integer i = 0
			loop
				exitwhen i >= SLOT
				if getItem(category,i) <= 0 then
					call setItem(category,i,it)
					if category == .category then
						call getIcon(i).setTarget(it)
					endif
					return true
				endif
				set i = i + 1
			endloop
			return false
		endmethod

		method pull takes integer category, integer index returns nothing
			local integer i = index
			local integer ii = 0
			loop
				set ii = getItem(category,i+1)
				exitwhen i >= SLOT
				call setItem(category,i,ii)
				if category == .category then
					call getIcon(i).setTarget(ii)
				endif
				exitwhen ii <= 0
				set i = i + 1
			endloop
		endmethod

		method changeCategory takes integer category returns nothing
			local integer i = 0
			if category != .category then
				loop
					exitwhen i >= SLOT
					call getIcon(i).setTarget(getItem(category,i))
					set i = i + 1
				endloop
			endif
			set .category = category
		endmethod

		method spaceExists takes integer category returns boolean
			return getItem(category,SLOT-1) == 0
		endmethod

		method setIcon takes integer index, InventoryIcon ni returns nothing
			call SaveInteger(UI.HASH,this,UI.INDEX_INVENTORY_ICON+index,ni)
		endmethod

		method getIcon takes integer index returns InventoryIcon
			return LoadInteger(UI.HASH,this,UI.INDEX_INVENTORY_ICON+index)
		endmethod

		method rightClick takes integer index returns nothing
			if getItem(.category,index).onRightClick() then
				call pull(.category,index)
				call getIcon(index).showTooltip()
			else
				if GetLocalPlayer() == .owner then
					call PlaySoundBJ(gg_snd_Error)
				endif
			endif
		endmethod

		method visibleForPlayer takes boolean flag returns nothing
			set .visible_flag = flag
			if GetLocalPlayer()==.owner then
				call BlzFrameSetVisible(FRAME_INVENTORY,flag)
			endif
			if .visible_flag then
				//TODO REFRESH
			endif
		endmethod

		method switch takes nothing returns nothing
			call visibleForPlayer(not .visible_flag)
		endmethod

		method close takes nothing returns boolean
			if .visible_flag then
				call visibleForPlayer(false)
				return true
			else
				return false
			endif
		endmethod

		static method press takes nothing returns nothing
			local thistype this = Trigger.getData(GetTriggeringTrigger())
			if BlzGetTriggerPlayerKey() == OSKEY_B then
				call switch()
			elseif BlzGetTriggerFrame() != null then
				call BlzFrameSetEnable(BlzGetTriggerFrame(),false)
				call BlzFrameSetEnable(BlzGetTriggerFrame(),true)
			endif
		endmethod

		static method create takes player p returns thistype
			local thistype this = allocate()
			local integer i = 0
			set .owner = p
			/*아이콘*/
			loop
				exitwhen i >= SLOT
				call setIcon(i,InventoryIcon.create(p,i))
				set i = i + 1
			endloop
			/*트리거*/
			set .keypress = Trigger.new(this)
			call BlzTriggerRegisterPlayerKeyEvent(.keypress,.owner,OSKEY_B,0,true)

			set .keypress_cond = TriggerAddCondition(.keypress,function thistype.press)
			set THIS[GetPlayerId(p)] = this
			/*테스트용*/
			call addItem(CATEGORY_ARTIFACT,Artifact.new('a000'))
			call addItem(CATEGORY_ARTIFACT,Artifact.new('a001'))
			call addItem(CATEGORY_ARTIFACT,Artifact.new('a002'))
			call addItem(CATEGORY_ARTIFACT,Artifact.new('a003'))
			call addItem(CATEGORY_ARTIFACT,Artifact.new('a010'))
			call addItem(CATEGORY_ARTIFACT,Artifact.new('a011'))
			call addItem(CATEGORY_ARTIFACT,Artifact.new('a012'))
			call addItem(CATEGORY_ARTIFACT,Artifact.new('a013'))
			call changeCategory(CATEGORY_ARTIFACT)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			local integer i = 0
			loop
				exitwhen i >= SLOT
				call getIcon(i).destroy()
				set i = i + 1
			endloop
			//! runtextmacro destroyTriggerAndCondition(".keypress",".keypress_cond")
			set .owner = null
		endmethod

		static method rightClickRequest takes nothing returns nothing
			call THIS[GetPlayerId(INVENTORY_RIGHTCLICK_PLAYER)].rightClick(INVENTORY_RIGHTCLICK_INDEX)
		endmethod

		static method onInit takes nothing returns nothing
			call TriggerAddCondition(INVENTORY_RIGHTCLICK,function thistype.rightClickRequest)
		endmethod

	endstruct

endlibrary