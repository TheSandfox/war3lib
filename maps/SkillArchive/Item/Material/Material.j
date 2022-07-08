library Material

	globals
		private hashtable HASH = InitHashtable()
		private constant integer INDEX_MIX_RESULT_COUNT = 0
		private constant integer INDEX_ELEMENT_TYPE = 1

		constant integer MATERIAL_ELEMENT_TYPE_EARTH = 0
		constant integer MATERIAL_ELEMENT_TYPE_WATER = 1
		constant integer MATERIAL_ELEMENT_TYPE_FIRE = 2
		constant integer MATERIAL_ELEMENT_TYPE_WIND = 3
		constant integer MATERIAL_ELEMENT_TYPE_NATURE = 4
		constant integer MATERIAL_ELEMENT_TYPE_NONE = 5
		constant integer MATERIAL_ELEMENT_TYPE_DARK = 6
		constant integer MATERIAL_ELEMENT_TYPE_LIGHT = 7
	endglobals

	struct Material extends Item

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
			return ""
		endmethod

		method getExtraText takes nothing returns string
			return I2S(.count)
		endmethod

	endstruct

endlibrary

//! textmacro materialHeader takes id, name, path, tier, element
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
		call Item.genericConfiguration('$id$',t,function act,"$path$","$name$")
		call Item.materialConfiguration('$id$',$tier$)
		call Material.setElementType('$id$',MATERIAL_ELEMENT_TYPE_$element$)
		set t = null
	endfunction
endscope
//! endtextmacro


//! import "MaterialData.j"