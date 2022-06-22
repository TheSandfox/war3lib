library Item

	globals
		private hashtable HASH = InitHashtable()
		private constant integer INDEX_NAME = 0
		private constant integer INDEX_ICON = 1
		private constant integer INDEX_DESC = 2
		private constant integer INDEX_TIER = 3
		private constant integer INDEX_SETNUM = 4

		constant integer ITEMSET_ETERNAL_CYCLONE = 0
	endglobals

	struct Item extends Item_prototype

		integer tier = 0

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

		static method onInit takes nothing returns nothing
			set ItemPrototype_SIZE = 4
		endmethod

		method relativeTooltip takes nothing returns string
			return "Tooltip Missing"
		endmethod

		stub method onRightClick takes nothing returns boolean
			return true
		endmethod

	endstruct

endlibrary

//! import "Artifact\\Artifact.j"