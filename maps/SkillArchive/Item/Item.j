//! import "Artifact\\Artifact.j"
//! import "Material\\Material.j"

library Item requires Frame

	globals
		private hashtable HASH = InitHashtable()
		private constant integer INDEX_NAME = 0
		private constant integer INDEX_ICON = 1
		private constant integer INDEX_DESC = 2
		private constant integer INDEX_TIER = 3
		private constant integer INDEX_SETNUM = 4
		private constant integer INDEX_ITEMTYPE = 5
		private constant integer INDEX_STACKABLE = 6
		private constant integer INDEX_CREATE_TRIGGER = 7

		constant integer ITEMSET_VENOMANCER = 0
		constant integer ITEMSET_VOLCANIC_CAVALIER = 1
		constant integer ITEMSET_VENGEANCE = 2
		constant integer ITEMSET_DESOLATOR = 3
		constant integer ITEMSET_GLADIATOR = 4
		constant integer ITEMSET_ENGINEER = 5
		constant integer ITEMSET_CAPTAIN = 6
		constant integer ITEMSET_MIDAS = 7

		string array ITEMSET_NAME
		integer array ITEMSET_ITEM
		integer array ITEMSET_REGIST_INDEX
		string array ITEMSET_DESC1
		string array ITEMSET_DESC2

		constant integer ITEMTYPE_MATERIAL = 0
		constant integer ITEMTYPE_ARTIFACT = 1
		constant integer ITEMTYPE_FOOD = 2
		constant integer ITEMTYPE_GACHA = 3
		constant integer ITEMTYPE_MAX = 4

		string array ITEMTYPE_ICON
		string array ITEMTYPE_NAME

		private texttag ITEM_NAME_INDICATOR = null
		private trigger ITEM_NAME_INDICATOR_TRIGGER = null
	endglobals

	struct Shuffle extends Shuffle_prototype

		static method shuffleRandomStat takes nothing returns nothing
			call reset()
			call addValue(STAT_TYPE_MAXHP)
			call addValue(STAT_TYPE_MAXMP)
			call addValue(STAT_TYPE_ATTACK)
			call addValue(STAT_TYPE_DEFFENCE)
			call addValue(STAT_TYPE_MAGICPOWER)
			call addValue(STAT_TYPE_RESISTANCE)
			call addValue(STAT_TYPE_ACCURACY)
			call addValue(STAT_TYPE_EVASION)
			call addValue(STAT_TYPE_ARMOR_PENET)
			call addValue(STAT_TYPE_MAGIC_PENET)
			call addValue(STAT_TYPE_SPELL_BOOST)
			call addValue(STAT_TYPE_LUCK)
			call addValue(STAT_TYPE_HPREGEN)
			call addValue(STAT_TYPE_MPREGEN)
		endmethod

	endstruct

	struct Item extends Item_prototype

		static integer LAST_CREATED = 0

		boolean exist = true
		integer tier = 0
		framehandle tooltip_container = null
		framehandle tooltip_outline = null
		framehandle tooltip_backdrop = null
		framehandle tooltip_icon = null
		framehandle tooltip_tier_border = null
		framehandle tooltip_name = null
		framehandle tooltip_text = null
		framehandle itemtype_backdrop = null
		framehandle itemtype_icon = null
		framehandle itemtype_text = null

		framehandle pivot = null
		integer tooltip_width = 320
		integer tooltip_inset_top = 64
		integer tooltip_inset_bottom = 0

		string description = ""

		static method exists takes thistype it returns boolean
			if it <= 0 then
				return false
			endif
			return it.exist
		endmethod

		static method getItemsetDesc takes integer setnum, integer index returns string
			if index == 0 then
				return ITEMSET_DESC1[setnum]
			else
				return ITEMSET_DESC2[setnum]
			endif
		endmethod

		static method getTypeName takes integer iid returns string
			return LoadStr(HASH,iid,INDEX_NAME)
		endmethod

		static method setTypeName takes integer iid, string nv returns nothing
			call SaveStr(HASH,iid,INDEX_NAME,nv)
		endmethod

		static method getTypeDesc takes integer iid returns string
			return LoadStr(HASH,iid,INDEX_DESC)
		endmethod

		static method setTypeDesc takes integer iid, string nv returns nothing
			call SaveStr(HASH,iid,INDEX_DESC,nv)
		endmethod

		static method getItemsetItem takes integer setnum, integer index returns integer
			return ITEMSET_ITEM[setnum*4+index]
		endmethod

		static method setItemsetItem takes integer setnum, integer index, integer iid returns nothing
			set ITEMSET_ITEM[setnum*4+index] = iid
		endmethod

		static method getTypeTier takes integer iid returns integer
			if HaveSavedInteger(HASH,iid,INDEX_TIER) then
				return LoadInteger(HASH,iid,INDEX_TIER)
			else
				return 0
			endif
		endmethod

		static method setTypeTier takes integer iid, integer tier returns nothing
			call SaveInteger(HASH,iid,INDEX_TIER,tier)
		endmethod

		static method getTypeIconPath takes integer iid returns string
			if HaveSavedString(HASH,iid,INDEX_ICON) then
				return LoadStr(HASH,iid,INDEX_ICON)
			else
				return "icons\\btnblackicon.blp"
			endif
		endmethod

		static method setTypeIconPath takes integer iid, string path returns nothing
			call SaveStr(HASH,iid,INDEX_ICON,path)
		endmethod

		static method getTypeSetNum takes integer iid returns integer
			if HaveSavedInteger(HASH,iid,INDEX_SETNUM) then
				return LoadInteger(HASH,iid,INDEX_SETNUM)
			else
				return -1
			endif
		endmethod

		static method setTypeSetNum takes integer iid, integer val returns nothing
			call SaveInteger(HASH,iid,INDEX_SETNUM,val)
		endmethod

		static method getUnitSetNum takes Unit_prototype target, integer setnum returns integer
			if HaveSavedInteger(HASH,target,setnum) then
				return LoadInteger(HASH,target,setnum)
			else
				return 0
			endif
		endmethod

		static method setUnitSetNum takes Unit_prototype target, integer setnum, integer val returns nothing
			call SaveInteger(HASH,target,setnum,val)
		endmethod

		static method getTypeItemType takes integer iid returns integer
			return LoadInteger(HASH,iid,INDEX_ITEMTYPE)
		endmethod

		static method setTypeItemType takes integer iid, integer it returns nothing
			call SaveInteger(HASH,iid,INDEX_ITEMTYPE,it)
		endmethod

		static method getTypeStackable takes integer iid returns boolean
			return LoadBoolean(HASH,iid,INDEX_STACKABLE)
		endmethod

		static method setTypeStackable takes integer iid, boolean b returns nothing
			call SaveBoolean(HASH,iid,INDEX_STACKABLE,b)
		endmethod

		static method getTypeCreateTrigger takes integer iid returns trigger
			return LoadTriggerHandle(HASH,iid,INDEX_CREATE_TRIGGER)
		endmethod

		static method setTypeCreateTrigger takes integer iid, trigger tr returns nothing
			call SaveTriggerHandle(HASH,iid,INDEX_CREATE_TRIGGER,tr)
		endmethod

		method divide takes integer i returns thistype
			local Item nit = 0
			if .count <= 1 or i <= 0 then
				return 0
			endif
			set nit = new(.id)
			if i >= .count then
				set nit.count = .count - 1
				set .count = 1
			else
				set nit.count = i
				set .count = .count - i
			endif
			return nit
		endmethod

		stub method merge takes thistype target returns boolean
			if target.id != .id then
				return false
			endif
			set target.count = target.count + .count
			call destroy()
			return true
		endmethod
		
		stub method onUseCount takes integer i returns nothing

		endmethod

		method useCount takes integer i returns nothing
			if i <= 0 then
				return
			endif
			set .count = .count - i
			call onUseCount(i)
			if .count <= 0 then
				call destroy()
			endif
		endmethod

		stub method getExtraText takes nothing returns string
			return ""
		endmethod

		stub method getDialogText takes nothing returns string
			return "Tooltip Missing"
		endmethod

		stub method relativeTooltip takes nothing returns string
			return "Tooltip Missing"
		endmethod

		stub method onRightClick takes nothing returns boolean
			return true
		endmethod

		stub method getDropName takes nothing returns string
			return TIER_STRING_COLOR[getTypeTier(.id)]+.name +" x"+I2S(.count)
		endmethod

		stub method refreshTooltip takes nothing returns nothing
			if .tooltip_container == null then
				return
			endif
			call BlzFrameSetText(.tooltip_text,relativeTooltip())
		endmethod

		method resetTooltip takes nothing returns nothing
			if .tooltip_container == null then
				return
			endif
			set .pivot = null
			call BlzFrameSetVisible(.tooltip_container,false)
		endmethod

		method initTooltip takes nothing returns nothing
			if .tooltip_container != null then
				return
			endif
			set .tooltip_container = BlzCreateFrameByType("FRAME","",FRAME_TOOLTIP,"",0)
			set	.tooltip_outline = BlzCreateFrameByType("BACKDROP","",.tooltip_container,"",0)
			call BlzFrameSetTexture(.tooltip_outline,"replaceabletextures\\teamcolor\\teamcolor16.blp",0,true)
			set .tooltip_backdrop = BlzCreateFrameByType("BACKDROP","",.tooltip_container,"",0)
			call BlzFrameSetTexture(.tooltip_backdrop,"replaceabletextures\\teamcolor\\teamcolor24.blp",0,true)
			set .tooltip_icon = BlzCreateFrameByType("BACKDROP","",.tooltip_container,"",0)
			call BlzFrameSetPointPixel(.tooltip_icon,FRAMEPOINT_TOPLEFT,.tooltip_outline,FRAMEPOINT_TOPLEFT,8,-8)
			call BlzFrameSetSizePixel(.tooltip_icon,48,48)
			call BlzFrameSetTexture(.tooltip_icon,getTypeIconPath(.id),0,true)
			set .tooltip_tier_border = BlzCreateFrameByType("BACKDROP","",.tooltip_icon,"",0)
			call BlzFrameSetAllPoints(.tooltip_tier_border,.tooltip_icon)
			call BlzFrameSetTexture(.tooltip_tier_border,"Textures\\ability_border_tier"+I2S(Item.getTypeTier(.id))+".blp",0,true)
			set .tooltip_name = BlzCreateFrame("MyTextLarge",.tooltip_container,0,0)
			call BlzFrameSetText(.tooltip_name,TIER_STRING_COLOR[getTypeTier(.id)]+.name+"|r")
			call BlzFrameSetTextAlignment(.tooltip_name,TEXT_JUSTIFY_TOP,TEXT_JUSTIFY_LEFT)
			set .tooltip_text = BlzCreateFrame("MyText",.tooltip_container,0,0)
			call BlzFrameSetPoint(.tooltip_backdrop,FRAMEPOINT_BOTTOMRIGHT,.tooltip_text,FRAMEPOINT_BOTTOMRIGHT,.004,-.004+Math.px2Size(-.tooltip_inset_bottom))
			call BlzFrameSetPoint(.tooltip_backdrop,FRAMEPOINT_TOPLEFT,.tooltip_text,FRAMEPOINT_TOPLEFT,-.004,.004+Math.px2Size(.tooltip_inset_top))
			call BlzFrameSetPoint(.tooltip_outline,FRAMEPOINT_BOTTOMRIGHT,.tooltip_backdrop,FRAMEPOINT_BOTTOMRIGHT,.001,-.001)
			call BlzFrameSetPoint(.tooltip_outline,FRAMEPOINT_TOPLEFT,.tooltip_backdrop,FRAMEPOINT_TOPLEFT,-.001,.001)
			call BlzFrameSetPointPixel(.tooltip_name,FRAMEPOINT_LEFT,.tooltip_icon,FRAMEPOINT_RIGHT,4,0)
			call BlzFrameSetText(.tooltip_text,relativeTooltip())
			set .itemtype_backdrop = BlzCreateFrameByType("BACKDROP","",.tooltip_container,"",0)
			call BlzFrameSetTexture(.itemtype_backdrop,"textures\\black32.blp",0,true)
			call BlzFrameSetAlpha(.itemtype_backdrop,128)
			set .itemtype_icon = BlzCreateFrameByType("BACKDROP","",.tooltip_container,"",0)
			call BlzFrameSetPointPixel(.itemtype_icon,FRAMEPOINT_BOTTOMLEFT,.tooltip_outline,FRAMEPOINT_TOPLEFT,4,4)
			call BlzFrameSetSizePixel(.itemtype_icon,24,24)
			call BlzFrameSetTexture(.itemtype_icon,ITEMTYPE_ICON[getTypeItemType(.id)],0,true)
			set .itemtype_text = BlzCreateFrame("MyText",.tooltip_container,0,0)
			call BlzFrameSetPointPixel(.itemtype_text,FRAMEPOINT_LEFT,.itemtype_icon,FRAMEPOINT_RIGHT,4,0)
			call BlzFrameSetText(.itemtype_text,ITEMTYPE_NAME[getTypeItemType(.id)])
			call BlzFrameSetPointPixel(.itemtype_backdrop,FRAMEPOINT_BOTTOMLEFT,.itemtype_icon,FRAMEPOINT_BOTTOMLEFT,-4,-4)
			call BlzFrameSetPointPixel(.itemtype_backdrop,FRAMEPOINT_TOP,.itemtype_icon,FRAMEPOINT_TOP,0,4)
			call BlzFrameSetPointPixel(.itemtype_backdrop,FRAMEPOINT_RIGHT,.itemtype_text,FRAMEPOINT_RIGHT,4,0)
			//
			call BlzFrameSetVisible(.tooltip_container,false)
		endmethod

		method setTooltipPosition takes framehandle parent, framepointtype pivot_point, real offset_x, real offset_y, player visible, integer align returns nothing
			if parent == null then
				return
			endif
			if .tooltip_container == null then
				call initTooltip()
			endif
			set .pivot = parent
			call BlzFrameClearAllPoints(.tooltip_text)
			if align == 0 then
				call BlzFrameSetTextAlignment(.tooltip_text,TEXT_JUSTIFY_TOP,TEXT_JUSTIFY_LEFT)
				call BlzFrameSetPoint(.tooltip_text,FRAMEPOINT_TOPRIGHT,.pivot,pivot_point,Math.px2Size(offset_x)-0.005,Math.px2Size(offset_y-.tooltip_inset_top)-0.005)
				call BlzFrameSetPoint(.tooltip_text,FRAMEPOINT_TOPLEFT,.pivot,pivot_point,Math.px2Size(offset_x-.tooltip_width)+0.005,Math.px2Size(offset_y-.tooltip_inset_top)-0.005)
			else
				call BlzFrameSetTextAlignment(.tooltip_text,TEXT_JUSTIFY_BOTTOM,TEXT_JUSTIFY_LEFT)
				call BlzFrameSetPoint(.tooltip_text,FRAMEPOINT_BOTTOMRIGHT,.pivot,pivot_point,Math.px2Size(offset_x)-0.005,Math.px2Size(offset_y+.tooltip_inset_bottom)+0.005)
				call BlzFrameSetPoint(.tooltip_text,FRAMEPOINT_BOTTOMLEFT,.pivot,pivot_point,Math.px2Size(offset_x-.tooltip_width)+0.005,Math.px2Size(offset_y+.tooltip_inset_bottom)+0.005)
			endif
			call refreshTooltip()
			//call BlzFrameSetVisible(.tooltip_container,GetLocalPlayer()==visible)
		endmethod

		stub method initialize takes nothing returns nothing

		endmethod

		static method new takes integer iid returns thistype
			set LAST_CREATED = 0
			call TriggerEvaluate(getTypeCreateTrigger(iid))
			if LAST_CREATED > 0 then
				call thistype(LAST_CREATED).initialize()
			endif
			return LAST_CREATED
		endmethod

		method onDestroy takes nothing returns nothing
			if .tooltip_container != null then
				//! runtextmacro destroyFrame(".tooltip_container")
				//! runtextmacro destroyFrame(".tooltip_outline")
				//! runtextmacro destroyFrame(".tooltip_backdrop")
				//! runtextmacro destroyFrame(".tooltip_icon")
				//! runtextmacro destroyFrame(".tooltip_tier_border")
				//! runtextmacro destroyFrame(".tooltip_name")
				//! runtextmacro destroyFrame(".tooltip_text")
				//! runtextmacro destroyFrame(".itemtype_backdrop")
				//! runtextmacro destroyFrame(".itemtype_icon")
				//! runtextmacro destroyFrame(".itemtype_text")
			endif
			set .pivot = null
			set .exist = false
		endmethod

		static method genericConfiguration takes integer iid, trigger trig, code cond, string name returns nothing  
			call setTypeCreateTrigger(iid,trig)
			call TriggerAddCondition(trig,Condition(cond))
			
			call setTypeName(iid,name)
		endmethod

		static method artifactConfiguration takes integer iid, integer setnum, string icon returns nothing
			call setTypeIconPath(iid,icon)
			call setTypeSetNum(iid,setnum)
			call setTypeItemType(iid,ITEMTYPE_ARTIFACT)
			call setTypeStackable(iid,false)
			call setTypeTier(iid,5)
			call setItemsetItem(setnum,ITEMSET_REGIST_INDEX[setnum],iid)
			set ITEMSET_REGIST_INDEX[setnum] = ITEMSET_REGIST_INDEX[setnum] + 1
		endmethod

		static method materialConfiguration takes integer iid, integer tier, string icon returns nothing
			call setTypeIconPath(iid,"Icons\\Items\\Materials\\"+icon+".blp")
			call setTypeSetNum(iid,-1)
			call setTypeTier(iid,tier)
			call setTypeItemType(iid,ITEMTYPE_MATERIAL)
			call setTypeStackable(iid,true)
		endmethod

		static method refreshItemNameIndicator takes player p returns nothing
			if GetLocalPlayer() == p then
				if BlzGetMouseFocusUnit() == null then
					call SetTextTagVisibility(ITEM_NAME_INDICATOR,false)
					return
				endif
				if GetUnitTypeId(BlzGetMouseFocusUnit()) != 'idum' then
					call SetTextTagVisibility(ITEM_NAME_INDICATOR,false)
					return
				endif
				call SetTextTagText(ITEM_NAME_INDICATOR,GetUnitName(BlzGetMouseFocusUnit()),0.02)
				call SetTextTagVisibility(ITEM_NAME_INDICATOR,true)
				call SetTextTagPos(ITEM_NAME_INDICATOR,GetUnitX(BlzGetMouseFocusUnit()),GetUnitY(BlzGetMouseFocusUnit()),65.)
			endif
		endmethod

		static method refreshItemNameCallback takes nothing returns nothing
			local integer i = 0
			if GetTriggerEventId() == EVENT_PLAYER_MOUSE_MOVE then
				call refreshItemNameIndicator(GetTriggerPlayer())
			elseif GetTriggerEventId() == EVENT_GAME_TIMER_EXPIRED then
				loop
					exitwhen i >= bj_MAX_PLAYERS
					call refreshItemNameIndicator(Player(i))
					set i = i + 1
				endloop
			endif
		endmethod

		static method onInit takes nothing returns nothing
			local integer i = 0
			set ItemPrototype_SIZE = 4
			//! textmacro initItemsetIndex takes prime, name
			set ITEMSET_NAME[ITEMSET_$prime$] = "$name$"
			set ITEMSET_REGIST_INDEX[ITEMSET_$prime$] = 0
			set ITEMSET_DESC1[ITEMSET_$prime$] = "2세트 효과 (작성중)"
			set ITEMSET_DESC2[ITEMSET_$prime$] = "4세트 효과 (작성중)"
			//! endtextmacro
			//! runtextmacro initItemsetIndex("VENOMANCER","맹독술사")
			//! runtextmacro initItemsetIndex("VOLCANIC_CAVALIER","용암 기병대")
			//! runtextmacro initItemsetIndex("VENGEANCE","응징왕")
			//! runtextmacro initItemsetIndex("DESOLATOR","잔악한 고문")
			//! runtextmacro initItemsetIndex("GLADIATOR","검투사")
			//! runtextmacro initItemsetIndex("ENGINEER","기계공의 유산")
			//! runtextmacro initItemsetIndex("CAPTAIN","쿨한 지휘관")
			//! runtextmacro initItemsetIndex("MIDAS","황금의 왕")
			//
			set ITEMTYPE_NAME[ITEMTYPE_MATERIAL] = "소재"
			set ITEMTYPE_NAME[ITEMTYPE_ARTIFACT] = "아티팩트"
			set ITEMTYPE_NAME[ITEMTYPE_FOOD] = "요리"
			set ITEMTYPE_NAME[ITEMTYPE_GACHA] = "소모품"
			set ITEMTYPE_ICON[ITEMTYPE_MATERIAL] = "ui\\widgets\\tooltips\\human\\tooltipmaterialicon.blp"
			set ITEMTYPE_ICON[ITEMTYPE_ARTIFACT] = "ui\\widgets\\tooltips\\human\\tooltipartifacticon.blp"
			set ITEMTYPE_ICON[ITEMTYPE_FOOD] = "ui\\widgets\\tooltips\\human\\tooltipfoodicon.blp"
			set ITEMTYPE_ICON[ITEMTYPE_GACHA] = "ui\\widgets\\tooltips\\human\\tooltipgachaicon.blp"
			//
			/*set ITEMSET_DESC1[ITEMSET_VENOMANCER] = "영구순환의 소용돌이 2세트효과(작성중)"
			set ITEMSET_DESC2[ITEMSET_VENOMANCER] = "영구순환의 소용돌이 4세트효과(작성중)"
			set ITEMSET_DESC1[ITEMSET_VOLCANIC_CAVALIER] = "정화의 불길 2세트효과(작성중)"
			set ITEMSET_DESC2[ITEMSET_VOLCANIC_CAVALIER] = "정화의 불길 4세트효과(작성중)"
			set ITEMSET_DESC1[ITEMSET_VENGEANCE] = "영구순환의 소용돌이 2세트효과(작성중)"
			set ITEMSET_DESC2[ITEMSET_VENGEANCE] = "영구순환의 소용돌이 4세트효과(작성중)"*/
			/*INIT ITEM NAME INDICATOR*/
			set ITEM_NAME_INDICATOR = CreateTextTag()
			call SetTextTagPermanent(ITEM_NAME_INDICATOR,true)
			call SetTextTagVisibility(ITEM_NAME_INDICATOR,false)
			set ITEM_NAME_INDICATOR_TRIGGER = CreateTrigger()
			loop
				exitwhen i >= bj_MAX_PLAYERS
				call TriggerRegisterPlayerEvent(ITEM_NAME_INDICATOR_TRIGGER,Player(i),EVENT_PLAYER_MOUSE_MOVE)
				set i = i + 1
			endloop
			call TriggerRegisterTimerEvent(ITEM_NAME_INDICATOR_TRIGGER,0.05,true)
			call TriggerAddCondition(ITEM_NAME_INDICATOR_TRIGGER,function thistype.refreshItemNameCallback)
		endmethod

	endstruct

endlibrary