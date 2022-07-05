library Material

	struct Material extends Item

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
	globals
		private constant integer ID = '$id$'
		private constant string NAME = "$name$"
		private constant string ICON_PATH = "$path$"
		private constant trigger CREATE_TRIGGER = CreateTrigger()
		private constant integer TIER = $tier$
	endglobals

//! endtextmacro

//! textmacro materialEnd

	private function act takes nothing returns nothing
		local main a = 0
		set a = main.create()
		if a > 0 then
			set a.id = ID
			set a.name = NAME
			set a.icon = ICON_PATH
		endif
		set Item.LAST_CREATED = a
	endfunction

	private function init takes nothing returns nothing
		call Item.genericConfiguration(ID,CREATE_TRIGGER,function act,ICON_PATH,NAME)
		call Item.materialConfiguration(ID,TIER)
	endfunction
endscope
//! endtextmacro


//! import "MaterialData.j"