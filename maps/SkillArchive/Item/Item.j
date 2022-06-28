library Item requires Frame

	globals
		private hashtable HASH = InitHashtable()
		private constant integer INDEX_NAME = 0
		private constant integer INDEX_ICON = 1
		private constant integer INDEX_DESC = 2
		private constant integer INDEX_TIER = 3
		private constant integer INDEX_SETNUM = 4

		constant integer ITEMSET_ETERNAL_CYCLONE = 0
		constant integer ITEMSET_CLEANSING_FIRE = 1

		string array ITEMSET_NAME
		integer array ITEMSET_ITEM
		integer array ITEMSET_REGIST_INDEX
		string array ITEMSET_DESC1
		string array ITEMSET_DESC2

		constant integer ITEMTYPE_MATERIAL = 0
		constant integer ITEMTYPE_ARTIFACT = 1

		string array ITEMTYPE_ICON
		string array ITEMTYPE_NAME
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

		integer tier = 0
		integer itemtype = -1
		framehandle tooltip_container = null
		framehandle tooltip_outline = null
		framehandle tooltip_backdrop = null
		framehandle tooltip_icon = null
		framehandle tooltip_name = null
		framehandle tooltip_text = null
		framehandle itemtype_backdrop = null
		framehandle itemtype_icon = null
		framehandle itemtype_text = null

		framehandle pivot = null
		integer tooltip_width = 320
		integer tooltip_inset_top = 64
		integer tooltip_inset_bottom = 0

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

		static method getItemsetItem takes integer setnum, integer index returns integer
			return ITEMSET_ITEM[setnum*4+index]
		endmethod

		static method setItemsetItem takes integer setnum, integer index, integer iid returns nothing
			set ITEMSET_ITEM[setnum*4+index] = iid
		endmethod

		static method getTypeTier takes integer iid returns integer
			return LoadInteger(HASH,iid,INDEX_TIER)
		endmethod

		static method setTypeTier takes integer iid, integer tier returns nothing
			call SaveInteger(HASH,iid,INDEX_TIER,tier)
		endmethod

		static method getTypeIconPath takes integer iid returns string
			return LoadStr(HASH,iid,INDEX_ICON)
		endmethod

		static method setTypeIconPath takes integer iid, string path returns nothing
			call SaveStr(HASH,iid,INDEX_ICON,path)
		endmethod

		static method getTypeSetNum takes integer iid returns integer
			return LoadInteger(HASH,iid,INDEX_SETNUM)
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

		stub method relativeTooltip takes nothing returns string
			return "Tooltip Missing"
		endmethod

		stub method onRightClick takes nothing returns boolean
			return true
		endmethod

		stub method refreshTooltip takes nothing returns nothing
			call BlzFrameSetText(.tooltip_text,relativeTooltip())
		endmethod

		method resetTooltip takes nothing returns nothing
			set .pivot = null
			call BlzFrameSetVisible(.tooltip_container,false)
		endmethod

		method initTooltip takes nothing returns nothing
			set .tooltip_container = BlzCreateFrameByType("FRAME","",FRAME_GAME_UI,"",0)
			set	.tooltip_outline = BlzCreateFrameByType("BACKDROP","",.tooltip_container,"",0)
			call BlzFrameSetTexture(.tooltip_outline,"replaceabletextures\\teamcolor\\teamcolor16.blp",0,true)
			set .tooltip_backdrop = BlzCreateFrameByType("BACKDROP","",.tooltip_container,"",0)
			call BlzFrameSetTexture(.tooltip_backdrop,"replaceabletextures\\teamcolor\\teamcolor24.blp",0,true)
			set .tooltip_icon = BlzCreateFrameByType("BACKDROP","",.tooltip_container,"",0)
			call BlzFrameSetPointPixel(.tooltip_icon,FRAMEPOINT_TOPLEFT,.tooltip_outline,FRAMEPOINT_TOPLEFT,8,-8)
			call BlzFrameSetSizePixel(.tooltip_icon,48,48)
			call BlzFrameSetTexture(.tooltip_icon,"replaceabletextures\\commandbuttons\\"+getTypeIconPath(.id)+".blp",0,true)
			set .tooltip_name = BlzCreateFrame("MyTextLarge",.tooltip_container,0,0)
			call BlzFrameSetText(.tooltip_name,.name)
			call BlzFrameSetTextAlignment(.tooltip_name,TEXT_JUSTIFY_TOP,TEXT_JUSTIFY_LEFT)
			set .tooltip_text = BlzCreateFrame("MyText",.tooltip_container,0,0)
			call BlzFrameSetPoint(.tooltip_backdrop,FRAMEPOINT_BOTTOMRIGHT,.tooltip_text,FRAMEPOINT_BOTTOMRIGHT,.004,-.004+Math.px2Size(-.tooltip_inset_bottom))
			call BlzFrameSetPoint(.tooltip_backdrop,FRAMEPOINT_TOPLEFT,.tooltip_text,FRAMEPOINT_TOPLEFT,-.004,.004+Math.px2Size(.tooltip_inset_top))
			call BlzFrameSetPoint(.tooltip_outline,FRAMEPOINT_BOTTOMRIGHT,.tooltip_backdrop,FRAMEPOINT_BOTTOMRIGHT,.001,-.001)
			call BlzFrameSetPoint(.tooltip_outline,FRAMEPOINT_TOPLEFT,.tooltip_backdrop,FRAMEPOINT_TOPLEFT,-.001,.001)
			call BlzFrameSetPointPixel(.tooltip_name,FRAMEPOINT_LEFT,.tooltip_icon,FRAMEPOINT_RIGHT,4,0)
			set .itemtype_backdrop = BlzCreateFrameByType("BACKDROP","",.tooltip_container,"",0)
			call BlzFrameSetTexture(.itemtype_backdrop,"textures\\black32.blp",0,true)
			call BlzFrameSetAlpha(.itemtype_backdrop,128)
			set .itemtype_icon = BlzCreateFrameByType("BACKDROP","",.tooltip_container,"",0)
			call BlzFrameSetPointPixel(.itemtype_icon,FRAMEPOINT_BOTTOMLEFT,.tooltip_outline,FRAMEPOINT_TOPLEFT,4,4)
			call BlzFrameSetSizePixel(.itemtype_icon,24,24)
			call BlzFrameSetTexture(.itemtype_icon,ITEMTYPE_ICON[.itemtype],0,true)
			set .itemtype_text = BlzCreateFrame("MyText",.tooltip_container,0,0)
			call BlzFrameSetPointPixel(.itemtype_text,FRAMEPOINT_LEFT,.itemtype_icon,FRAMEPOINT_RIGHT,4,0)
			call BlzFrameSetText(.itemtype_text,ITEMTYPE_NAME[.itemtype])
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

		method onDestroy takes nothing returns nothing
			if .tooltip_container != null then
				//! runtextmacro destroyFrame(".tooltip_container")
				//! runtextmacro destroyFrame(".tooltip_outline")
				//! runtextmacro destroyFrame(".tooltip_backdrop")
				//! runtextmacro destroyFrame(".tooltip_icon")
				//! runtextmacro destroyFrame(".tooltip_name")
				//! runtextmacro destroyFrame(".tooltip_text")
				//! runtextmacro destroyFrame(".itemtype_backdrop")
				//! runtextmacro destroyFrame(".itemtype_icon")
				//! runtextmacro destroyFrame(".itemtype_text")
			endif
			set .pivot = null
		endmethod

		static method onInit takes nothing returns nothing
			set ItemPrototype_SIZE = 4
			set ITEMSET_NAME[ITEMSET_ETERNAL_CYCLONE] = "영구순환의 소용돌이"
			set ITEMSET_NAME[ITEMSET_CLEANSING_FIRE] = "정화의 불길"
			set ITEMSET_REGIST_INDEX[ITEMSET_ETERNAL_CYCLONE] = 0
			set ITEMSET_REGIST_INDEX[ITEMSET_CLEANSING_FIRE] = 0
			//
			set ITEMTYPE_NAME[ITEMTYPE_MATERIAL] = "소재"
			set ITEMTYPE_NAME[ITEMTYPE_ARTIFACT] = "아티팩트"
			set ITEMTYPE_ICON[ITEMTYPE_MATERIAL] = "replaceabletextures\\commandbuttons\\btnfootman.blp"
			set ITEMTYPE_ICON[ITEMTYPE_ARTIFACT] = "ui\\widgets\\tooltips\\human\\tooltipartifacticon.blp"
			//
			set ITEMSET_DESC1[ITEMSET_ETERNAL_CYCLONE] = "영구순환의 소용돌이 2세트효과(작성중)"
			set ITEMSET_DESC2[ITEMSET_ETERNAL_CYCLONE] = "영구순환의 소용돌이 4세트효과(작성중)"
			set ITEMSET_DESC1[ITEMSET_CLEANSING_FIRE] = "정화의 불길 2세트효과(작성중)"
			set ITEMSET_DESC2[ITEMSET_CLEANSING_FIRE] = "정화의 불길 4세트효과(작성중)"
		endmethod

	endstruct

endlibrary

//! import "Artifact\\Artifact.j"