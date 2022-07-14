library Inventory requires UI, User

	globals
		private constant integer PER_ROW = 16
		private constant integer PER_COL = 4
		public constant integer SLOT = PER_ROW * PER_COL
		private constant integer CATEGORY = 8
		private constant integer INSET_Y = 40
		private constant integer SIZE = 48
		trigger INVENTORY_RIGHTCLICK_TRIGGER = CreateTrigger()
		integer INVENTORY_RIGHTCLICK_INDEX = -1
		player INVENTORY_RIGHTCLICK_PLAYER = null
		player INVENTORY_ITEM_USE_PLAYER = null

		private boolean INVENTORY_ITEM_MERGE = true

		private trigger INVENTORY_ICON_RESET_FOCUS = CreateTrigger()
		private framehandle array INVENTORY_ICON_ICON
		private framehandle array INVENTORY_ICON_TIER_BORDER
		private framehandle array INVENTORY_ICON_BTN
		private framehandle array INVENTORY_ICON_EXTRA_BACKDROP
		private framehandle array INVENTORY_ICON_EXTRA_TEXT
	endglobals

	struct InventoryIcon extends IconFrame

		integer index = -1

		Item target = -1
		player owner = null
		
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
			if LocalScope(.owner) then
				call BlzFrameSetVisible(INVENTORY_ICON_TIER_BORDER[.index],false)
				call BlzFrameSetVisible(INVENTORY_ICON_EXTRA_BACKDROP[.index],false)
				call BlzFrameSetVisible(INVENTORY_ICON_EXTRA_TEXT[.index],false)
			endif
			if target <= 0 then
				if LocalScope(.owner) then
					call BlzFrameSetTexture(INVENTORY_ICON_ICON[.index],"icons\\btnblackicon.blp",0,true)
					call BlzFrameSetAlpha(INVENTORY_ICON_ICON[.index],64)
				endif
				/*트리거&프레임 비활성화*/
				set .in = false
				if LocalScope(.owner) then
					call BlzFrameSetVisible(INVENTORY_ICON_BTN[.index],false)
				endif
				call DisableTrigger(.main_trigger)
			else
				if LocalScope(.owner) then
					call BlzFrameSetTexture(INVENTORY_ICON_ICON[.index],Item.getTypeIconPath(target.id),0,true)
					call BlzFrameSetAlpha(INVENTORY_ICON_ICON[.index],255)
					call BlzFrameSetVisible(INVENTORY_ICON_TIER_BORDER[.index],true)
					call BlzFrameSetTexture(INVENTORY_ICON_TIER_BORDER[.index],"Textures\\ability_border_tier"+I2S(Item.getTypeTier(target.id))+".blp",0,true)
				endif
				call target.resetTooltip()
				call target.setTooltipPosition(FRAME_INVENTORY,FRAMEPOINT_TOPLEFT,0.,0.,.owner,0)
				set .tooltip = target.tooltip_container
				/*엑스트라텍스트*/
				set s = target.getExtraText()
				if s != "" and LocalScope(.owner) then
					call BlzFrameSetVisible(INVENTORY_ICON_EXTRA_BACKDROP[.index],true)
					call BlzFrameSetVisible(INVENTORY_ICON_EXTRA_TEXT[.index],true)
					call BlzFrameSetText(INVENTORY_ICON_EXTRA_TEXT[.index],s)
				endif
				/*트리거&프레임 활성화*/
				if LocalScope(.owner) then
					call BlzFrameSetVisible(INVENTORY_ICON_BTN[.index],true)
				endif
				call EnableTrigger(.main_trigger)
			endif
			set .target = target
		endmethod

		static method cond takes nothing returns nothing
			local thistype this = Trigger.getData(GetTriggeringTrigger())
			if GetTriggerPlayer() != .owner then
				return
			endif
			if BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_ENTER then
				call showTooltip()
				set .in = true
				return
			elseif BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_LEAVE then
				call hideTooltip()
				set .in = false
				return
			elseif .in and BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_RIGHT then
				if .target > 0 then
					if not Craft[.owner].visible_flag then
						/*ALT우클릭 : 한개만떨구기*/
						/*if User.getKeyState(.owner,OSKEY_LALT) and User.getKeyState(.owner,OSKEY_LALT) then
							call Numberpad.customSummit(.owner,"INV_DIVDROP#"+I2S(.target),"")
							return
						
						else*/
						/*SHIFT우클릭 : 나누기*/
						if User.getKeyState(.owner,OSKEY_LSHIFT) then
							if Item.getTypeItemType(.target.id) != ITEMTYPE_ARTIFACT and .target.count > 1 then
								call Numberpad[.owner].open("INV_DIV#"+I2S(.target))
								call Numberpad[.owner].setPoint(FRAMEPOINT_RIGHT,INVENTORY_ICON_ICON[.index],FRAMEPOINT_RIGHT,0.,0.)
								call Numberpad[.owner].setInitialValue("1")
							endif
							return
						/*CONTROL우클릭 : 떨구기*/
						elseif User.getKeyState(.owner,OSKEY_LCONTROL) then
							call Numberpad.customSummit(.owner,"INV_DROP",I2S(.index))
							return
						else
							set INVENTORY_RIGHTCLICK_INDEX = .index
							set INVENTORY_RIGHTCLICK_PLAYER = .owner
							call TriggerEvaluate(INVENTORY_RIGHTCLICK_TRIGGER)
							return
						endif
					else
						set INVENTORY_RIGHTCLICK_INDEX = .index
						set INVENTORY_RIGHTCLICK_PLAYER = .owner
						call TriggerEvaluate(INVENTORY_RIGHTCLICK_TRIGGER)
						return
					endif
					return
				endif
			endif
		endmethod

		static method create takes player owner, integer index returns thistype
			local thistype this = allocate()
			set .index = index
			set .owner = owner
			set .main_trigger = Trigger.new(this)
			set .main_cond = TriggerAddCondition(.main_trigger,function thistype.cond)
			
			call BlzTriggerRegisterFrameEvent(.main_trigger,INVENTORY_ICON_BTN[.index],FRAMEEVENT_MOUSE_ENTER)
			call BlzTriggerRegisterFrameEvent(.main_trigger,INVENTORY_ICON_BTN[.index],FRAMEEVENT_MOUSE_LEAVE)
			call TriggerRegisterPlayerEvent(.main_trigger,.owner,EVENT_PLAYER_MOUSE_DOWN)
			//
			call setTarget(0)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
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
		integer category = -1
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
			if index < 0 then
				return 0
			endif
			if HaveSavedInteger(HASH,this,index+category*SLOT) then
				return LoadInteger(HASH,this,index+category*SLOT)
			else
				return 0
			endif
		endmethod

		method spaceExists takes integer category returns boolean
			return getItem(category,SLOT-1) == 0
		endmethod

		method getItemIndexById takes integer iid returns integer
			local integer cat = Item.getTypeItemType(iid)
			local integer i = 0
			local Item it = 0
			loop
				exitwhen i >= SLOT
				set it = getItem(cat,i)
				if it > 0 then
					if it.id == iid then
						return i
					endif
				endif
				set i = i + 1
			endloop
			return -1
		endmethod

		method addItem takes Item it returns boolean
			local integer i = 0
			local integer iidx = 0
			local integer category = Item.getTypeItemType(it.id)
			if Item.getTypeStackable(it.id) and INVENTORY_ITEM_MERGE then
				set iidx = getItemIndexById(it.id)
				if iidx > -1 then
					call it.merge(getItem(category,iidx))
					if category == .category then
						call getIcon(iidx).setTarget(getItem(category,iidx))
					endif
					return true
				endif
			endif
			if spaceExists(category) then
				loop
					exitwhen i >= SLOT
					if getItem(category,i) <= 0 then
						call setItem(category,i,it)
						if category == .category then
							call getIcon(i).setTarget(it)
						endif
						if i < SLOT-1 then
							call setItem(category,i+1,-1)
							if category == .category then
								call getIcon(i+1).setTarget(-1)
							endif
						endif
						return true
					endif
					set i = i + 1
				endloop
			else
				call it.drop(User.getFocusUnit(.owner).x,User.getFocusUnit(.owner).y)
				return false
			endif
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
			call BlzFrameSetVisible(.dialog_backdrop,LocalScope(.owner))
			call BlzFrameSetVisible(.mouseover_above,LocalScope(.owner))
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
				exitwhen ii == -1
				set i = i + 1
			endloop
			call setItem(category,SLOT-1,0)
			if category == .category then
				call getIcon(SLOT-1).setTarget(0)
			endif
		endmethod

		method refresh takes integer category returns nothing
			local integer i = 0
			local Item it = -1
			loop
				exitwhen i >= SLOT
				set it = getItem(category,i)
				if it == -1 then
					call getIcon(i).setTarget(it)
				elseif not Item.exists(it) then
					call pull(category,i)
				elseif .category == category then
					call getIcon(i).setTarget(it)
				endif
				set i = i + 1
			endloop
		endmethod

		method drop takes integer index returns nothing
			local Item it = getItem(.category,index)
			if it > 0 then
				call it.drop(User.getFocusUnit(.owner).x,User.getFocusUnit(.owner).y)
				call setItem(.category,index,0)
				call pull(.category,index)
			else
			endif
		endmethod

		method divide takes Item it, integer count returns boolean
			local Item nit = 0
			local integer cat = 0
			if it <= 0 then
				return true
			endif
			if it.count <= 1 then
				return true
			endif
			set cat = Item.getTypeItemType(it.id)
			if getItemIndexById(it.id) > -1 then
				set nit = it.divide(count)
				if nit > 0 then
					set INVENTORY_ITEM_MERGE = false
					call addItem(nit)
					set INVENTORY_ITEM_MERGE = true
					call refresh(cat)
					return true
				else
					return false
				endif
			endif
			return true
		endmethod

		method changeCategory takes integer category returns nothing
			local integer i = 0
			if .dialog_visible then
				return
			endif
			if category != .category then
				loop
					exitwhen i >= ITEMTYPE_MAX
					if LocalScope(.owner) then
						call BlzFrameSetVisible(FRAME_INVENTORY_CATEGORY_HIGHTLIGHT[i], i == category)
					endif
					set i = i + 1
				endloop
				set i = 0
				loop
					exitwhen i >= SLOT
					call getIcon(i).setTarget(getItem(category,i))
					set i = i + 1
				endloop
			endif
			set .category = category
		endmethod

		method setIcon takes integer index, InventoryIcon ni returns nothing
			call SaveInteger(UI.HASH,this,UI.INDEX_INVENTORY_ICON+index,ni)
		endmethod

		method getIcon takes integer index returns InventoryIcon
			return LoadInteger(UI.HASH,this,UI.INDEX_INVENTORY_ICON+index)
		endmethod

		/*method consume takes integer iid, integer count returns nothing*/
			/*local Item it = 0
			local integer category = 0
			local integer index = 0
			if iid <= 0 or count <= 0 then
				return
			endif
			set category = Item.getTypeItemType(iid)
			set index = getItemIndexById(iid)
			set it = getItem(category,index)
			if it <= 0 then
				return
			endif
			if it.count <= count then
				call it.useCount(count)
				call pull(category,index)
			else
				call it.useCount(count)
				if .category == category then
					call getIcon(index).setTarget(it)
				endif
			endif*/
		/*endmethod*/

		method consume takes Item it, integer count returns nothing
			local integer category = -1
			if not Item.exists(it) then
				return
			endif
			set category = Item.getTypeItemType(it.id)
			call it.useCount(count)
			call refresh(category)
		endmethod

		method rightClick takes integer index returns nothing
			if Craft.THIS[GetPlayerId(.owner)].visible_flag then
				call Craft.THIS[GetPlayerId(.owner)].regist(getItem(.category,index))
				return
			endif
			if Item.getTypeItemType(getItem(.category,index).id) == ITEMTYPE_ARTIFACT then
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
			/*아이콘*/
			loop
				exitwhen i >= SLOT
				call setIcon(i,InventoryIcon.create(p,i))
				set i = i + 1
			endloop
			/*마우스오버*/
			set .mouseover_above = BlzCreateFrameByType("FRAME","",FRAME_INVENTORY,"",0)
			call BlzFrameSetAllPoints(.mouseover_above,FRAME_INVENTORY)
			call BlzFrameSetVisible(.mouseover_above,false)
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
			/*첫번째칸 엔드인덱스*/
			set i = 0
			loop
				exitwhen i >= CATEGORY
				call setItem(i,0,-1)
				set i = i + 1
			endloop
			/*인덱싱*/
			set THIS[GetPlayerId(p)] = this
			/*테스트용*/
			if .owner == Player(0) then
				call addItem(Item.new('a000'))
				call addItem(Item.new('a001'))
				call addItem(Item.new('a002'))
				call addItem(Item.new('a003'))
				call addItem(Item.new('a010'))
				call addItem(Item.new('a011'))
				call addItem(Item.new('a012'))
				call addItem(Item.new('a013'))
				call addItem(Item.new('a020'))
				call addItem(Item.new('a021'))
				call addItem(Item.new('a022'))
				call addItem(Item.new('a023'))
				call addItem(Item.new('a030'))
				call addItem(Item.new('a031'))
				call addItem(Item.new('a032'))
				call addItem(Item.new('a033'))
				call addItem(Item.new('a040'))
				call addItem(Item.new('a041'))
				call addItem(Item.new('a042'))
				call addItem(Item.new('a043'))
				call addItem(Item.new('a050'))
				call addItem(Item.new('a051'))
				call addItem(Item.new('a052'))
				call addItem(Item.new('a053'))
				call addItem(Item.new('a060'))
				call addItem(Item.new('a061'))
				call addItem(Item.new('a062'))
				call addItem(Item.new('a063'))
				call addItem(Item.new('a070'))
				call addItem(Item.new('a071'))
				call addItem(Item.new('a072'))
				call addItem(Item.new('a073'))
			endif
			if .owner == Player(1) then

			endif
			/*call Item.new('m000').drop(0,-300)
			call Item.new('m000').drop(0,-300)
			call Item.new('m000').drop(0,-300)
			call Item.new('m000').drop(0,-300)*/
			call changeCategory(CATEGORY_MATERIAL)
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

		static method itemPick takes nothing returns nothing
			local Unit picker = Unit(ITEM_PICK_UNIT)
			local thistype this = THIS[GetPlayerId(picker.owner)]
			local Item it = ITEM_PICK_ITEM
			if this <= 0 or it <= 0 then
				return
			endif
			if not addItem(it) then
				call it.drop(picker.x,picker.y)
			endif
		endmethod

		static method numberpadSummit takes nothing returns nothing
			if NUMBERPAD_REFINED_PREFIX == "INV_DIV" then
				set NUMBERPAD_SUMMIT_RESULT = thistype[NUMBERPAD_SUMMIT_PLAYER].divide(Item(S2I(NUMBERPAD_REFINED_SUBFIX)),S2I(NUMBERPAD_SUMMIT_VALUE))
				return
			endif
			if NUMBERPAD_SUMMIT_PREFIX == "INV_DROP" then
				call thistype[NUMBERPAD_SUMMIT_PLAYER].drop(S2I(NUMBERPAD_SUMMIT_VALUE))
				return
			endif
			if NUMBERPAD_REFINED_PREFIX == "INV_DIVDROP" then
				call thistype[NUMBERPAD_SUMMIT_PLAYER].divide(Item(S2I(NUMBERPAD_REFINED_SUBFIX)),1)
				return
			endif
		endmethod

		static method onInit takes nothing returns nothing
			call TriggerAddCondition(INVENTORY_RIGHTCLICK_TRIGGER,function thistype.rightClickRequest)
			call TriggerAddCondition(ITEM_PICK_TRIGGER,function thistype.itemPick)
			call TriggerAddCondition(NUMBERPAD_SUMMIT_TRIGGER,function thistype.numberpadSummit)
		endmethod

		static method init takes nothing returns nothing
			local integer i = 0
			loop
				exitwhen i >= SLOT
				set INVENTORY_ICON_ICON[i] = BlzCreateFrameByType("BACKDROP","",FRAME_INVENTORY,"",0)
				call BlzFrameSetPointPixel(INVENTORY_ICON_ICON[i],FRAMEPOINT_TOPLEFT,FRAME_INVENTORY,FRAMEPOINT_TOPLEFT,32+ModuloInteger(i,PER_ROW)*SIZE,-32-INSET_Y-R2I(i/PER_ROW)*SIZE)
				call BlzFrameSetSizePixel(INVENTORY_ICON_ICON[i],SIZE,SIZE)
				set INVENTORY_ICON_TIER_BORDER[i] = BlzCreateFrameByType("BACKDROP","",INVENTORY_ICON_ICON[i],"",0)
				call BlzFrameSetAllPoints(INVENTORY_ICON_TIER_BORDER[i],INVENTORY_ICON_ICON[i])
				set INVENTORY_ICON_EXTRA_BACKDROP[i] = BlzCreateFrameByType("BACKDROP","",INVENTORY_ICON_ICON[i],"",0)
				call BlzFrameSetAlpha(INVENTORY_ICON_EXTRA_BACKDROP[i],128)
				call BlzFrameSetTexture(INVENTORY_ICON_EXTRA_BACKDROP[i],"textures\\black32.blp",0,true)
				set INVENTORY_ICON_EXTRA_TEXT[i] = BlzCreateFrame("MyTextSmall",INVENTORY_ICON_ICON[i],0,0)
				call BlzFrameSetPointPixel(INVENTORY_ICON_EXTRA_TEXT[i],FRAMEPOINT_BOTTOMRIGHT,INVENTORY_ICON_ICON[i],FRAMEPOINT_BOTTOMRIGHT,-2,2)
				call BlzFrameSetPointPixel(INVENTORY_ICON_EXTRA_BACKDROP[i],FRAMEPOINT_BOTTOMRIGHT,INVENTORY_ICON_EXTRA_TEXT[i],FRAMEPOINT_BOTTOMRIGHT,2,-2)
				call BlzFrameSetPointPixel(INVENTORY_ICON_EXTRA_BACKDROP[i],FRAMEPOINT_TOPLEFT,INVENTORY_ICON_EXTRA_TEXT[i],FRAMEPOINT_TOPLEFT,-2,2)
				call BlzFrameSetVisible(INVENTORY_ICON_EXTRA_BACKDROP[i],false)
				call BlzFrameSetVisible(INVENTORY_ICON_EXTRA_TEXT[i],false)
				set INVENTORY_ICON_BTN[i] = BlzCreateFrameByType("BUTTON","",FRAME_INVENTORY,"",0)
				call BlzFrameSetAllPoints(INVENTORY_ICON_BTN[i],INVENTORY_ICON_ICON[i])
				call BlzTriggerRegisterFrameEvent(INVENTORY_ICON_RESET_FOCUS,INVENTORY_ICON_BTN[i],FRAMEEVENT_MOUSE_ENTER)
				call BlzTriggerRegisterFrameEvent(INVENTORY_ICON_RESET_FOCUS,INVENTORY_ICON_BTN[i],FRAMEEVENT_MOUSE_LEAVE)
				call BlzTriggerRegisterFrameEvent(INVENTORY_ICON_RESET_FOCUS,INVENTORY_ICON_BTN[i],FRAMEEVENT_CONTROL_CLICK)
				set i = i + 1
			endloop
			call TriggerAddCondition(INVENTORY_ICON_RESET_FOCUS,function Frame.resetFocus)
		endmethod	

	endstruct

endlibrary