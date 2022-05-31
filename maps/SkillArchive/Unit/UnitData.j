//! textmacro unitDataHeader takes key, icon
	private function init takes nothing returns nothing
		set UnitData.ID = '$key$'
		call UnitData.setIconPath("$icon$")
//! endtextmacro

//! textmacro unitDataEnd
	endfunction
//! endtextmacro

library UnitData requires UnitPrototype

	struct UnitData extends array

		static hashtable HASH = InitHashtable()
		static integer INDEX_EXTERNAL = 0 
		static integer ID = 0

		static method getIconPath takes integer uid returns string
			if HaveSavedString(HASH,uid,INDEX_EXTERNAL+0) then
				return LoadStr(HASH,uid,INDEX_EXTERNAL+0)
			else
				return "BTNBlackIcon"
			endif
		endmethod

		static method setIconPath takes string nval returns nothing
			call SaveStr(HASH,ID,INDEX_EXTERNAL+0,nval)
		endmethod

		static method getInitialAbility takes integer uid, integer index returns integer
			if HaveSavedInteger(HASH,uid,INDEX_ABILITY+index) then
				return LoadInteger(HASH,uid,INDEX_ABILITY+index)
			else
				return 0
			endif
		endmethod

		static method setInitialAbility takes integer index, integer aid returns nothing
			call SaveInteger(HASH,ID,INDEX_ABILITY+index,aid)
		endmethod

		static method setStatValue takes integer stattype, real base, real level returns nothing
			call SaveReal(HASH,ID,INDEX_STAT+(stattype*STAT_INDEX_SIZE)+STAT_INDEX_BASE,base)
			call SaveReal(HASH,ID,INDEX_STAT+(stattype*STAT_INDEX_SIZE)+STAT_INDEX_LEVEL,level)
		endmethod

		static method setDefaults takes nothing returns nothing
			set ID = 0
			call setStatValue(STAT_TYPE_MAXHP,		400.,	40.	)
			call setStatValue(STAT_TYPE_MAXMP,		100.,	10.	)
			call setStatValue(STAT_TYPE_ATTACK,		20.,	2.	)
			call setStatValue(STAT_TYPE_DEFFENCE,	20.,	2.	)
			call setStatValue(STAT_TYPE_MAGICPOWER,	20.,	2.	)
			call setStatValue(STAT_TYPE_RESISTANCE,	20.,	2.	)
			call setStatValue(STAT_TYPE_ACCURACY,	20.,	2.	)
			call setStatValue(STAT_TYPE_EVASION,	20.,	2.	)
			call setStatValue(STAT_TYPE_HPREGEN,	4.,		0.4	)
			call setStatValue(STAT_TYPE_MPREGEN,	1.,		0.1	)
		endmethod

		private static method onInit takes nothing returns nothing
			set INDEX_EXTERNAL = INDEX_LAST
			call setDefaults()
		endmethod

	endstruct

endlibrary

//! import "GeneratedUnitData.j"