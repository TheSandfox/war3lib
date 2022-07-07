library Material

	struct Material extends Item

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
			if HaveSavedInteger(HASH,iid1,iid2) then
				return LoadInteger(HASH,iid1,iid2)
			else
				return 0
			endif
		endmethod

		static method setMixResultCount takes integer iid, integer count returns nothing
			call SaveInteger(HASH,iid,Item_INDEX_MIX_RESULT_COUNT,count)
		endmethod

		static method getMixResultCount takes integer iid returns integer
			return LoadInteger(HASH,iid,Item_INDEX_MIX_RESULT_COUNT)
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

//! textmacro materialHeader takes id, name, path, tier
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
		set t = null
	endfunction
endscope
//! endtextmacro


//! import "MaterialData.j"