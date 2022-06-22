library Artifact

	globals
		private constant integer LIMIT = 1024
		private constant integer STAT_SIZE = 4
		private constant integer LIMIT2 = LIMIT * STAT_SIZE
	endglobals

	struct ItemSetAbility

		private static hashtable HASH = InitHashtable()

		Unit owner = 0
		integer setnum = -1

		stub method init takes nothing returns nothing

		endmethod

		static method create takes Unit owner, integer setnum returns thistype
			local thistype this = 0
			if HaveSavedInteger(HASH,owner,setnum) then
				set this = LoadInteger(HASH,owner,setnum)
			else
				set this = allocate()
				call SaveInteger(HASH,owner,setnum,this)
			endif
			set .owner = owner
			set .setnum = setnum
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call RemoveSavedInteger(HASH,.owner,.setnum)
		endmethod

		static method new takes thistype a returns thistype
			call a.init()
			return a
		endmethod

	endstruct

	struct Artifact extends Item

		static integer CREATE_ID = 0
		static integer LAST_CREATED = 0
		static trigger CREATE_TRIGGER = null
		static integer array STAT_TYPE[LIMIT2]	/*장비의 스탯보너스 종류*/
		static real array STAT_BONUS[LIMIT2]	/*장비의 스탯보너스 양*/
		static real array STAT_VALUE[LIMIT2]	/*착용자에게 실적용돼있는 값*/

		method getStatType takes integer index returns integer
			return STAT_TYPE[this*STAT_SIZE+index]
		endmethod

		method setStatType takes integer index, integer newval returns nothing
			set STAT_TYPE[this*STAT_SIZE+index] = newval
		endmethod

		method getStatBonus takes integer index returns real
			return STAT_BONUS[this*STAT_SIZE+index]
		endmethod

		method setStatBonus takes integer index, real newval returns nothing
			set STAT_BONUS[this*STAT_SIZE+index] = newval
		endmethod

		method getStatValue takes integer index returns real
			return STAT_VALUE[this*STAT_SIZE+index]
		endmethod

		method setStatValue takes integer index, real newval returns nothing
			set STAT_VALUE[this*STAT_SIZE+index] = newval
		endmethod

		method applyStatValue takes integer i returns nothing
			if .owner <= 0 then
				return
			endif
			if getStatType(i) >= 0 then
				call .owner.plusStatValue(getStatType(i),getStatBonus(i))
				call setStatValue(i,getStatBonus(i))
			endif
		endmethod

		method applyAllStatValue takes nothing returns nothing
			local integer i = 0
			loop
				exitwhen i >= STAT_SIZE
				call applyStatValue(i)
				set i = i + 1
			endloop
		endmethod

		method resetStatValue takes integer i returns nothing
			if .owner <= 0 then
				return
			endif
			if getStatType(i) >= 0 then
				call .owner.plusStatValue(getStatType(i),-getStatValue(i))
				call setStatValue(i,0.)
			endif
		endmethod

		method resetAllStatValue takes nothing returns nothing
			local integer i = 0
			loop
				exitwhen i >= STAT_SIZE
				call resetStatValue(i)
				set i = i + 1
			endloop
		endmethod

		method changeStatValue takes integer index, integer stattype, real statbonus returns nothing
			call resetStatValue(index)
			call setStatType(index,stattype)
			call setStatBonus(index,statbonus*STAT_NORMAL_VALUE[stattype])
			call applyStatValue(index)
		endmethod

		stub method activate takes nothing returns nothing
		
		endmethod

		stub method deactivate takes nothing returns nothing

		endmethod

		method onEquip takes nothing returns nothing
			call applyAllStatValue()
			call Item.setUnitSetNum(.owner,getTypeSetNum(.id),getUnitSetNum(.owner,getTypeSetNum(.id))+1)
			call activate()
		endmethod

		method onUnequip takes nothing returns nothing
			call Item.setUnitSetNum(.owner,getTypeSetNum(.id),getUnitSetNum(.owner,getTypeSetNum(.id))-1)
			call deactivate()
			call resetAllStatValue()
		endmethod

		method onRightClick takes nothing returns boolean
			local Unit u = User.getFocusUnit(GetTriggerPlayer())
			local integer result = 0
			if u > 0 then
				if u.getItemById(.id) > 0 then
					return false
				else
					set result = equip(u)
					if result == 1 then
						call UI.THIS[GetPlayerId(GetTriggerPlayer())].refreshArtifactIcons()
						return true
					else
						return false
					endif
				endif
			else
				return false
			endif
		endmethod

		method initialize takes nothing returns nothing
			local integer i = 0
			loop
				exitwhen i >= STAT_SIZE
				call setStatType(i,-1)
				call setStatBonus(i,0.)
				call setStatValue(i,0.)
				set i = i + 1
			endloop
		endmethod

		static method create takes nothing returns thistype
			local thistype this = allocate()
			if this >= LIMIT then
				call destroy()
				return 0
			else
				call initialize()
				return this
			endif
		endmethod

		static method new takes integer iid returns thistype
			set LAST_CREATED = 0
			set CREATE_ID = iid
			call TriggerEvaluate(thistype.CREATE_TRIGGER)
			return LAST_CREATED
		endmethod

		static method onInit takes nothing returns nothing
			set CREATE_TRIGGER = CreateTrigger()
		endmethod

	endstruct

endlibrary

//! textmacro artifactHeader takes id, name, path, setnum

	globals
		private constant integer ID = '$id$'
		private constant string NAME = "$name$"
		private constant string ICON_PATH = "$path$"
		private constant integer SETNUM = $setnum$
	endglobals

//! endtextmacro

//! textmacro artifactEnd

	private function act takes nothing returns nothing
		local main a = 0
		if Artifact.CREATE_ID != ID then
			return
		endif
		set a = main.create()
		set a.id = ID
		set a.name = NAME
		set a.icon = ICON_PATH
		set Artifact.LAST_CREATED = a
	endfunction

	private function init takes nothing returns nothing
		call TriggerAddCondition(Artifact.CREATE_TRIGGER,function act)
		call Item.setTypeSetNum(ID,SETNUM)
	endfunction

//! endtextmacro

//! import "vol1.j"