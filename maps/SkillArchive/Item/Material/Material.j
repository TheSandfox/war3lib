library Material

	globals
		private hashtable HASH = InitHashtable()
		private constant integer INDEX_MIX_RESULT_COUNT = 0
		private constant integer INDEX_ELEMENT_TYPE = 1
		private constant integer INDEX_MATERIAL_TYPE = 2
		private constant integer INDEX_DESC = 3

		constant integer MATERIAL_TYPE_MATERIAL = 0
		constant integer MATERIAL_TYPE_INGREDIENT = 1
		constant integer MATERIAL_TYPE_DUST = 2
		constant integer MATERIAL_TYPE_ELEMENTAL = 3

		constant integer MATERIAL_TYPE_GEM = 4
		constant integer MATERIAL_TYPE_INK = 5
		constant integer MATERIAL_TYPE_CORE = 6
		constant integer MATERIAL_TYPE_RUNE = 7
		constant integer MATERIAL_TYPE_SCROLL = 8

		constant integer MATERIAL_ELEMENT_TYPE_EARTH = 0
		constant integer MATERIAL_ELEMENT_TYPE_WATER = 1
		constant integer MATERIAL_ELEMENT_TYPE_FIRE = 2
		constant integer MATERIAL_ELEMENT_TYPE_WIND = 3
		constant integer MATERIAL_ELEMENT_TYPE_NATURE = 4
		constant integer MATERIAL_ELEMENT_TYPE_NONE = 5
		constant integer MATERIAL_ELEMENT_TYPE_DARK = 6
		constant integer MATERIAL_ELEMENT_TYPE_LIGHT = 7

		string array MATERIAL_TYPE_NAME
		string array MATERIAL_ELEMENT_TYPE_NAME
	endglobals

	struct Material extends Item

		framehandle material_type_text = null

		static method setDesc takes integer iid, string desc returns nothing
			call SaveStr(HASH,iid,INDEX_DESC,desc)
		endmethod

		static method getDesc takes integer iid returns string
			return LoadStr(HASH,iid,INDEX_DESC)
		endmethod

		static method createDesc takes integer iid returns nothing
			local string s = "|cffffcc00합성 레시피:|r\n"
			local integer i = 0
			/*1티어 재료*/
			if Item.getTypeTier(iid) == 1 then
				set s = s + "+같은 속성 원자재or식자재 = |cff00ff00유색 마법가루|r\n+다른 속성 원자재or식자재 = |cff00ff00회색 마법가루|r"
				call setDesc(iid,s)
				return
			endif
			/*원소*/
			if Material.getMaterialType(iid) == MATERIAL_TYPE_ELEMENTAL then
				set i = Material.getElementType(iid)
				if i == MATERIAL_ELEMENT_TYPE_EARTH then
					set s = s + "+1티어 원자재 = "+TIER_STRING_COLOR[3]+MATERIAL_TYPE_NAME[MATERIAL_TYPE_GEM]+"|r"
				elseif i == MATERIAL_ELEMENT_TYPE_WATER then
					set s = s + "+1티어 원자재 = "+TIER_STRING_COLOR[3]+MATERIAL_TYPE_NAME[MATERIAL_TYPE_INK]+"|r"
				elseif i == MATERIAL_ELEMENT_TYPE_FIRE then
					set s = s + "+1티어 원자재 = "+TIER_STRING_COLOR[3]+MATERIAL_TYPE_NAME[MATERIAL_TYPE_CORE]+"|r"
				elseif i == MATERIAL_ELEMENT_TYPE_WIND then
					set s = s + "+1티어 원자재 = "+TIER_STRING_COLOR[3]+MATERIAL_TYPE_NAME[MATERIAL_TYPE_RUNE]+"|r"
				elseif i == MATERIAL_ELEMENT_TYPE_NATURE then
					set s = s + "+1티어 원자재 = "+TIER_STRING_COLOR[3]+MATERIAL_TYPE_NAME[MATERIAL_TYPE_SCROLL]+"|r"
				endif
				call setDesc(iid,s)
				return
			endif
			/*마법가루*/
			if Material.getMaterialType(iid) == MATERIAL_TYPE_DUST then
				set i = Material.getElementType(iid)
				if i != MATERIAL_ELEMENT_TYPE_NONE and i != MATERIAL_ELEMENT_TYPE_DARK then
					set s = s + "+|cff00ff00유색 마법가루|r = |cff00ff00회색 마법가루|r"
				elseif i == MATERIAL_ELEMENT_TYPE_NONE then
					set s = s + "+|cff00ff00유색 마법가루|r = |cff00ff00흑색 마법가루|r"
				endif
				call setDesc(iid,s)
				return
			endif
			/*원소결합물*/
			if Material.getTypeTier(iid) == 3 then
				set s = s + "+"+TIER_STRING_COLOR[3]+"다른 속성 "+MATERIAL_TYPE_NAME[Material.getMaterialType(iid)]+"|r = "+TIER_STRING_COLOR[4]+"빛속성 "+MATERIAL_TYPE_NAME[Material.getMaterialType(iid)]+"|r"
				call setDesc(iid,s)
				return 
			endif
		endmethod

		static method setMaterialType takes integer iid, integer mt returns nothing
			call SaveInteger(HASH,iid,INDEX_MATERIAL_TYPE,mt)
		endmethod

		static method getMaterialType takes integer iid returns integer
			return LoadInteger(HASH,iid,INDEX_MATERIAL_TYPE)
		endmethod

		static method setElementType takes integer iid, integer eid returns nothing
			call SaveInteger(HASH,iid,INDEX_ELEMENT_TYPE,eid)
		endmethod

		static method getElementType takes integer iid returns integer
			if HaveSavedInteger(HASH,iid,INDEX_ELEMENT_TYPE) then
				return LoadInteger(HASH,iid,INDEX_ELEMENT_TYPE)
			else
				return 5
			endif
		endmethod

		static method setMixResult takes integer iid1, integer iid2, integer res returns nothing
			if iid1 <= 0 then
				return
			endif
			call SaveInteger(HASH,iid1,iid2,res)
			if iid1 != iid2 then
				call SaveInteger(HASH,iid2,iid1,res)
			endif
		endmethod

		static method getMixResult takes integer iid1, integer iid2 returns integer
			if iid1 <= 0 or iid2 <= 0 then
				return 0
			endif
			if HaveSavedInteger(HASH,iid1,iid2) then
				return LoadInteger(HASH,iid1,iid2)
			else
				return 0
			endif
		endmethod

		static method setMixResultCount takes integer iid, integer count returns nothing
			call SaveInteger(HASH,iid,INDEX_MIX_RESULT_COUNT,count)
		endmethod

		static method getMixResultCount takes integer iid returns integer
			return LoadInteger(HASH,iid,INDEX_MIX_RESULT_COUNT)
		endmethod

		method refreshTooltip takes nothing returns nothing

		endmethod

		method onRightClick takes nothing returns boolean
			return false
		endmethod

		stub method relativeTooltip takes nothing returns string
			return getDesc(.id)
		endmethod

		method getExtraText takes nothing returns string
			return I2S(.count)
		endmethod

		method initialize takes nothing returns nothing
			set .tooltip_width = 400
			call initTooltip()
			set .material_type_text = BlzCreateFrame("MyText",.tooltip_container,0,0)
			call BlzFrameSetPointPixel(.material_type_text,FRAMEPOINT_TOPRIGHT,.tooltip_outline,FRAMEPOINT_TOPRIGHT,-16,-16)
			call BlzFrameSetText(.material_type_text,"|cffffff00"+MATERIAL_TYPE_NAME[Material.getMaterialType(.id)]+/*
			*/", "+MATERIAL_ELEMENT_TYPE_NAME[Material.getElementType(.id)]+"|r")
		endmethod

		method onDestroy takes nothing returns nothing
			//! runtextmacro destroyFrame(".material_type_text")
		endmethod

		static method onInit takes nothing returns nothing
			set MATERIAL_ELEMENT_TYPE_NAME[MATERIAL_ELEMENT_TYPE_EARTH] = "대지"
			set MATERIAL_ELEMENT_TYPE_NAME[MATERIAL_ELEMENT_TYPE_WATER] = "물"
			set MATERIAL_ELEMENT_TYPE_NAME[MATERIAL_ELEMENT_TYPE_FIRE] = "불"
			set MATERIAL_ELEMENT_TYPE_NAME[MATERIAL_ELEMENT_TYPE_WIND] = "바람"
			set MATERIAL_ELEMENT_TYPE_NAME[MATERIAL_ELEMENT_TYPE_NATURE] = "자연"
			set MATERIAL_ELEMENT_TYPE_NAME[MATERIAL_ELEMENT_TYPE_NONE] = ""
			set MATERIAL_ELEMENT_TYPE_NAME[MATERIAL_ELEMENT_TYPE_DARK] = "암흑"
			set MATERIAL_ELEMENT_TYPE_NAME[MATERIAL_ELEMENT_TYPE_LIGHT] = "빛"

			set MATERIAL_TYPE_NAME[MATERIAL_TYPE_MATERIAL] = "원자재"
			set MATERIAL_TYPE_NAME[MATERIAL_TYPE_INGREDIENT] = "식자재"
			set MATERIAL_TYPE_NAME[MATERIAL_TYPE_DUST] = "마법가루"
			set MATERIAL_TYPE_NAME[MATERIAL_TYPE_ELEMENTAL] = "원소"
			set MATERIAL_TYPE_NAME[MATERIAL_TYPE_GEM] = "보석"
			set MATERIAL_TYPE_NAME[MATERIAL_TYPE_INK] = "잉크"
			set MATERIAL_TYPE_NAME[MATERIAL_TYPE_CORE] = "마력결정"
			set MATERIAL_TYPE_NAME[MATERIAL_TYPE_RUNE] = "룬"
			set MATERIAL_TYPE_NAME[MATERIAL_TYPE_SCROLL] = "두루마리"
		endmethod

	endstruct

endlibrary

//! textmacro materialHeader takes id, name, path, tier, element, mtype
scope Material$id$ initializer init

	public struct main extends Material

	endstruct

	private function act takes nothing returns nothing
		local main a = 0
		set a = main.create()
		if a > 0 then
			set a.id = '$id$'
			set a.name = "$name$"
			set a.icon = "$path$"
		endif
		set Item.LAST_CREATED = a
	endfunction

	private function init takes nothing returns nothing
		local trigger t = CreateTrigger()
		call Item.genericConfiguration('$id$',t,function act,"$name$")
		call Item.materialConfiguration('$id$',$tier$,"$path$")
		call Material.setElementType('$id$',MATERIAL_ELEMENT_TYPE_$element$)
		call Material.setMaterialType('$id$',MATERIAL_TYPE_$mtype$)
		call Material.createDesc('$id$')
		set t = null
	endfunction
endscope
//! endtextmacro


//! import "MaterialData.j"