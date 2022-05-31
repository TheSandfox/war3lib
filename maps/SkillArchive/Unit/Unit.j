//! import "UnitData.j"
//! import "Tombstone.j"
//! import "Undead\\Undead.j"

library Unit requires UnitData

	struct Unit extends Unit_prototype

		static triggercondition LEVEL_COND = null
		Chingho chingho = 0

		static method onLevel takes nothing returns nothing
			local integer i = 0
			local Ability a = 0
			local thistype this = LEVEL_UNIT
			local UI ui = 0
			if LEVEL_UNIT <= 0 or LEVEL_LEVEL <= 0 then
				return
			endif
			loop
				exitwhen i >= ABILITY_SIZE
				set a = getAbility(i)
				if a > 0 and a.signiture then
					call a.addLevel(LEVEL_LEVEL)
				endif
				set i = i + 1
			endloop
			set ui = UI.THIS[GetPlayerId(.owner)]
			if ui > 0 then
				call ui.setTarget(ui.target)
			endif
		endmethod

		method setChingho takes integer id returns nothing
			if .chingho > 0 then
				call .chingho.destroy()
			endif
			call Ability_prototype.new(id)
			set .chingho = ABILITY_LAST_CREATED
			if .chingho > 0 then
				set .chingho.owner = this
				call .chingho.essentialInit()
				call .chingho.init()
				set .origin_name = "|cffffcc00["+.chingho.name+"]|r\n"+.origin_name
				call BlzSetHeroProperName(.origin_unit,.origin_name)
			endif
		endmethod

		method copyStat takes integer stattype returns nothing
			if HaveSavedReal(UnitData.HASH,.id,INDEX_STAT+(stattype*STAT_INDEX_SIZE)+STAT_INDEX_BASE) then
				call setStatValue(stattype,STAT_INDEX_BASE,LoadReal(UnitData.HASH,.id,INDEX_STAT+(stattype*STAT_INDEX_SIZE)+STAT_INDEX_BASE))
			else
				call setStatValue(stattype,STAT_INDEX_BASE,LoadReal(UnitData.HASH,0,INDEX_STAT+(stattype*STAT_INDEX_SIZE)+STAT_INDEX_BASE))
			endif
			if HaveSavedReal(UnitData.HASH,.id,INDEX_STAT+(stattype*STAT_INDEX_SIZE)+STAT_INDEX_LEVEL) then
				call setStatValue(stattype,STAT_INDEX_LEVEL,LoadReal(UnitData.HASH,.id,INDEX_STAT+(stattype*STAT_INDEX_SIZE)+STAT_INDEX_LEVEL))
			else
				call setStatValue(stattype,STAT_INDEX_LEVEL,LoadReal(UnitData.HASH,0,INDEX_STAT+(stattype*STAT_INDEX_SIZE)+STAT_INDEX_LEVEL))	
			endif
			call refreshStatValue(stattype)
		endmethod

		method copyStats takes nothing returns nothing
			call copyStat(STAT_TYPE_MAXHP)
			call copyStat(STAT_TYPE_MAXMP)
			call copyStat(STAT_TYPE_ATTACK)
			call copyStat(STAT_TYPE_DEFFENCE)
			call copyStat(STAT_TYPE_MAGICPOWER)
			call copyStat(STAT_TYPE_RESISTANCE)
			call copyStat(STAT_TYPE_ACCURACY)
			call copyStat(STAT_TYPE_EVASION)
			call copyStat(STAT_TYPE_HPREGEN)
			call copyStat(STAT_TYPE_MPREGEN)
			set .mp = .maxmp
		endmethod

		method loadAbility takes nothing returns nothing
			local integer i = 0
			local Ability lc = 0
			loop
				exitwhen i >= 10 or UnitData.getInitialAbility(.id,i) <= 0
				set lc = addAbility(UnitData.getInitialAbility(.id,i))
				set lc.signiture = true
				if Ability.getTypeTag(lc.id,0) == ABILITY_STRING_WEAPON then
					call setWeaponAbility(lc)
				endif
				set i = i + 1
			endloop
		endmethod

		static method create takes player p, integer uid, real x, real y, real yaw returns thistype
			local thistype this = allocate(p,uid,x,y,yaw)
			call copyStats()
			call loadAbility()
			set .class = "Unit"
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			if .chingho > 0 then
				call .chingho.destroy()
			endif
		endmethod

		static method onInit takes nothing returns nothing
			set LEVEL_COND = TriggerAddCondition(LEVEL_TRIGGER,function thistype.onLevel)
		endmethod

	endstruct

endlibrary