library Inventory requires UI

	globals
		private constant integer PER_ROW = 16
		private constant integer PER_COL = 4
		public constant integer SLOT = PER_ROW * PER_COL
		private constant integer CATEGORY = 8
		private constant integer INSET_Y = 40
		private constant integer SIZE = 48
		private trigger INVENTORY_RIGHTCLICK = CreateTrigger()
		private integer INVENTORY_RIGHTCLICK_INDEX = -1
		private player INVENTORY_RIGHTCLICK_PLAYER = null
		player INVENTORY_ITEM_USE_PLAYER = null
	endglobals

	struct InventoryIcon extends IconFrame

		integer index = -1

		Item target = -1
		player owner = null
		framehandle icon = null
		framehandle btn = null
		framehandle extra_backdrop = null
		framehandle extra_text = null

		framehandle tooltip = null //EXTERNAL!!!! DO NOT DESTROY. JUST SET NULL

		trigger main_trigger = null
		triggercondition main_cond = null
		boolean in = false

		method showTooltip takes nothing returns nothing
			if .tooltip != null then
				call BlzFrameSetVisible(.tooltip,false)
				call BlzFrameSetVisible(.tooltip,GetLocalPlayer() == .owner)
			endif
		endmethod

		method hideTooltip takes nothing returns nothing
			if .tooltip != null then
				call BlzFrameSetVisible(.tooltip,false)
			endif
		endmethod

		method setTarget takes Item target returns nothing
			local string s = ""
			if .target > 0 then
				call .target.resetTooltip()
			endif
			set .tooltip = null
			if .target != target then
				call BlzFrameSetVisible(.extra_backdrop,false)
				call BlzFrameSetVisible(.extra_text,false)
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
					/*엑스트라텍스트*/
					set s = target.getExtraText()
					if s != "" then
						call BlzFrameSetVisible(.extra_backdrop,true)
						call BlzFrameSetVisible(.extra_text,true)
						call BlzFrameSetText(.extra_text,s)
					endif
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
				call hideTooltip()
				set .in = false
			elseif .in and BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_RIGHT then
				if .target > 0 then
					set INVENTORY_RIGHTCLICK_INDEX = .index
					set INVENTORY_RIGHTCLICK_PLAYER = .owner
					call TriggerEvaluate(INVENTORY_RIGHTCLICK)
				endif
			endif
		endmethod

		static method create takes player owner, integer index, framehandle parent returns thistype
			local thistype this = allocate()
			set .index = index
			set .owner = owner
			set .main_trigger = Trigger.new(this)
			set .main_cond = TriggerAddCondition(.main_trigger,function thistype.cond)
			set .icon = BlzCreateFrameByType("BACKDROP","",parent,"",0)
			call BlzFrameSetPointPixel(.icon,FRAMEPOINT_TOPLEFT,FRAME_INVENTORY,FRAMEPOINT_TOPLEFT,32+ModuloInteger(index,PER_ROW)*SIZE,-32-INSET_Y-R2I(index/PER_ROW)*SIZE)
			call BlzFrameSetSizePixel(.icon,SIZE,SIZE)
			set .extra_backdrop = BlzCreateFrameByType("BACKDROP","",.icon,"",0)
			call BlzFrameSetAlpha(.extra_backdrop,128)
			call BlzFrameSetTexture(.extra_backdrop,"textures\\black32.blp",0,true)
			set .extra_text = BlzCreateFrame("MyTextSmall",.icon,0,0)
			call BlzFrameSetPointPixel(.extra_text,FRAMEPOINT_BOTTOMRIGHT,.icon,FRAMEPOINT_BOTTOMRIGHT,-2,2)
			call BlzFrameSetPointPixel(.extra_backdrop,FRAMEPOINT_BOTTOMRIGHT,.extra_text,FRAMEPOINT_BOTTOMRIGHT,2,-2)
			call BlzFrameSetPointPixel(.extra_backdrop,FRAMEPOINT_TOPLEFT,.extra_text,FRAMEPOINT_TOPLEFT,-2,2)
			call BlzFrameSetVisible(.extra_backdrop,false)
			call BlzFrameSetVisible(.extra_text,false)
			set .btn = BlzCreateFrameByType("BUTTON","",parent,"",0)
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
			//! runtextmacro destroyFrame(".extra_backdrop")
			//! runtextmacro destroyFrame(".extra_text")
			//! runtextmacro destroyTriggerAndCondition(".main_trigger",".main_cond")
			set .tooltip = null
			set .owner = null
		endmethod

	endstruct

	struct Inventory extends Closeable

		private static hashtable HASH = InitHashtable()

		static integer CATEGORY_MATERIAL = 0
		static integer CATEGORY_ARTIFACT = 1

		static constant integer DIALOG_WIDTH = 480
		static constant integer DIALOG_HEIGHT = 192

		trigger keypress = null
		triggercondition keypress_cond = null
		boolean visible_flag = false
		player owner = null
		integer category = 0
		/*컨테이너*/
		framehandle container = null
		/*마우스가리개*/
		framehandle mouseover_above = null
		/*Dialog*/
		framehandle dialog_backdrop = null
		framehandle dialog_text = null
		framehandle dialog_btn_confirm = null
		framehandle dialog_btn_cancle = null
		boolean dialog_visible = false
		integer dialog_category = -1
		integer dialog_index = -1
		/**/
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

		method closeDialog takes nothing returns nothing
			set .dialog_category = -1
			set .dialog_index = -1
			call BlzFrameSetVisible(.dialog_backdrop,false)
			call BlzFrameSetVisible(.mouseover_above,false)
			set .dialog_visible = false
		endmethod

		method useRequest takes integer category, integer index returns nothing
			set INVENTORY_ITEM_USE_PLAYER = .owner
			if getItem(category,index).onRightClick() then
				call pull(category,index)
				if .dialog_visible then
					call closeDialog()
				else
					call getIcon(index).showTooltip()
				endif
			else
				if GetLocalPlayer() == .owner then
					call PlaySoundBJ(gg_snd_Error)
				endif
			endif
		endmethod

		method dialogConfirm takes nothing returns nothing
			if .dialog_category < 0 or .dialog_index < 0 then
				return
			endif
			call useRequest(.dialog_category,.dialog_index)
		endmethod

		method showDialog takes integer category, integer index returns nothing
			set .dialog_category = category
			set .dialog_index = index
			call getIcon(index).hideTooltip()
			call BlzFrameSetText(.dialog_text,getItem(.dialog_category,.dialog_index).getDialogText())
			call BlzFrameSetVisible(.dialog_backdrop,GetLocalPlayer() == .owner)
			call BlzFrameSetVisible(.mouseover_above,true)
			set .dialog_visible = true
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
			if .dialog_visible then
				return
			endif
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
			if getItem(.category,index).itemtype == ITEMTYPE_ARTIFACT then
				call showDialog(.category,index)
			else
				call useRequest(.category,index)
			endif
		endmethod

		method visibleForPlayer takes boolean flag returns nothing
			set .visible_flag = flag
			if GetLocalPlayer()==.owner then
				call BlzFrameSetVisible(FRAME_INVENTORY,flag)
			endif
			if .visible_flag then
				//TODO REFRESH
			else
				call closeDialog()
				call Craft.THIS[GetPlayerId(.owner)].visibleForPlayer(false)
			endif
		endmethod

		method switch takes nothing returns nothing
			call visibleForPlayer(not .visible_flag)
		endmethod

		method close takes nothing returns boolean
			if .visible_flag then
				if .dialog_visible then
					call closeDialog()
					return true
				else
					call visibleForPlayer(false)
					return true
				endif
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
				if BlzGetTriggerFrameEvent() == FRAMEEVENT_CONTROL_CLICK then
					if BlzGetTriggerFrame() == .dialog_btn_confirm then
						call dialogConfirm()
					elseif BlzGetTriggerFrame() == .dialog_btn_cancle then
						call closeDialog()
					endif
				endif
			endif
		endmethod

		static method create takes player p returns thistype
			local thistype this = allocate()
			local integer i = 0
			set .owner = p
			/*트리거*/
			set .keypress = Trigger.new(this)
			call BlzTriggerRegisterPlayerKeyEvent(.keypress,.owner,OSKEY_B,0,true)
			set .keypress_cond = TriggerAddCondition(.keypress,function thistype.press)
			/*컨테이너*/
			set .container = BlzCreateFrameByType("FRAME","",FRAME_INVENTORY,"",0)
			call BlzFrameSetVisible(.container,GetLocalPlayer() == .owner)
			/*아이콘*/
			loop
				exitwhen i >= SLOT
				call setIcon(i,InventoryIcon.create(p,i,.container))
				set i = i + 1
			endloop
			/*마우스오버*/
			set .mouseover_above = BlzCreateFrameByType("FRAME","",.container,"",0)
			call BlzFrameSetAllPoints(.mouseover_above,FRAME_INVENTORY)
			/*다이얼로그*/
			set .dialog_backdrop = BlzCreateFrame("MBEdge",FRAME_GAME_UI,0,0)
			call BlzFrameSetPoint(.dialog_backdrop,FRAMEPOINT_CENTER,FRAME_ORIGIN,FRAMEPOINT_CENTER,0.,0.)
			call BlzFrameSetSizePixel(.dialog_backdrop,DIALOG_WIDTH,DIALOG_HEIGHT)
			call closeDialog()
			set .dialog_text = BlzCreateFrame("MyText",.dialog_backdrop,0,0)
			call BlzFrameSetPointPixel(.dialog_text,FRAMEPOINT_TOPLEFT,.dialog_backdrop,FRAMEPOINT_TOPLEFT,32,-32)
			call BlzFrameSetPointPixel(.dialog_text,FRAMEPOINT_BOTTOMRIGHT,.dialog_backdrop,FRAMEPOINT_BOTTOMRIGHT,-32,32)
			call BlzFrameSetTextAlignment(.dialog_text,TEXT_JUSTIFY_TOP,TEXT_JUSTIFY_CENTER)
			set .dialog_btn_confirm = BlzCreateFrame("InventoryDialogConfirmButton",.dialog_backdrop,0,0)
			call BlzFrameSetPointPixel(.dialog_btn_confirm,FRAMEPOINT_BOTTOMRIGHT,.dialog_backdrop,FRAMEPOINT_BOTTOM,-16,16)
			call BlzFrameSetSizePixel(.dialog_btn_confirm,192,48)
			call BlzTriggerRegisterFrameEvent(.keypress,.dialog_btn_confirm,FRAMEEVENT_CONTROL_CLICK)
			call BlzTriggerRegisterFrameEvent(.keypress,.dialog_btn_confirm,FRAMEEVENT_MOUSE_ENTER)
			call BlzTriggerRegisterFrameEvent(.keypress,.dialog_btn_confirm,FRAMEEVENT_MOUSE_LEAVE)
			set .dialog_btn_cancle = BlzCreateFrame("InventoryDialogCancleButton",.dialog_backdrop,0,0)
			call BlzFrameSetPointPixel(.dialog_btn_cancle,FRAMEPOINT_BOTTOMLEFT,.dialog_backdrop,FRAMEPOINT_BOTTOM,16,16)
			call BlzFrameSetSizePixel(.dialog_btn_cancle,192,48)
			call BlzTriggerRegisterFrameEvent(.keypress,.dialog_btn_cancle,FRAMEEVENT_CONTROL_CLICK)
			call BlzTriggerRegisterFrameEvent(.keypress,.dialog_btn_cancle,FRAMEEVENT_MOUSE_ENTER)
			call BlzTriggerRegisterFrameEvent(.keypress,.dialog_btn_cancle,FRAMEEVENT_MOUSE_LEAVE)
			/*인덱싱*/
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
			//! runtextmacro destroyFrame(".container")
			//! runtextmacro destroyFrame(".dialog_backdrop")
			//! runtextmacro destroyFrame(".dialog_text")
			//! runtextmacro destroyFrame(".dialog_btn_confirm")
			//! runtextmacro destroyFrame(".dialog_btn_cancle")
			//! runtextmacro destroyFrame(".mouseover_above")
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