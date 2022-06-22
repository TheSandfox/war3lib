library Ability requires AbilityPrototype

	globals
		private hashtable HASH = InitHashtable()
		constant integer CAST_TYPE_TARGET_LOCATION = 0
		constant integer CAST_TYPE_TARGET_UNIT = 1
		constant integer CAST_TYPE_IMMEDIATE = 2
		constant integer CAST_TYPE_PASSIVE = 3
		constant integer CAST_TYPE_DRAG_TO_USE = 4
		constant integer CAST_TYPE_WEAPON = 5
		constant integer ABILITY_TAG_IRON		= 0
		constant integer ABILITY_TAG_ASSASSINATE= 1
		constant integer ABILITY_TAG_BRAWL 		= 2
		constant integer ABILITY_TAG_MAGIC 		= 3
		constant integer ABILITY_TAG_LIGHTNING 	= 4
		constant integer ABILITY_TAG_FIREARM	= 5
		constant integer ABILITY_TAG_SHOOTING	= 6
		constant integer ABILITY_TAG_ARCHERY	= 7
		constant integer ABILITY_TAG_FIRE		= 8
		constant integer ABILITY_TAG_DIVINE		= 9
		constant integer ABILITY_TAG_PRODUCT	= 10
		constant integer ABILITY_TAG_DRUG		= 11
		constant integer ABILITY_TAG_POISON		= 12
		constant integer ABILITY_TAG_CARDMAGIC	= 13
		constant integer ABILITY_TAG_THROW		= 14
		constant integer ABILITY_TAG_DARK		= 15
		constant integer ABILITY_TAG_DRAGON		= 16
		constant integer ABILITY_TAG_FROST		= 17
		constant integer ABILITY_TAG_UNDEAD		= 18
		constant integer ABILITY_TAG_BUG		= 19
	endglobals

	struct AbilityProperty extends array

		string tag_name
		string cast_type

		private static method onInit takes nothing returns nothing
			set thistype(ABILITY_TAG_IRON		).tag_name = "|cffffff00강철|r"
			set thistype(ABILITY_TAG_ASSASSINATE).tag_name = "|cffffff00암살|r"
			set thistype(ABILITY_TAG_BRAWL		).tag_name = "|cffffff00체술|r"
			set thistype(ABILITY_TAG_MAGIC		).tag_name = "|cffffff00마법|r"
			set thistype(ABILITY_TAG_LIGHTNING	).tag_name = "|cffffff00전격|r"
			set thistype(ABILITY_TAG_FIREARM	).tag_name = "|cffffff00병기|r"
			set thistype(ABILITY_TAG_SHOOTING	).tag_name = "|cffffff00사격|r"
			set thistype(ABILITY_TAG_ARCHERY	).tag_name = "|cffffff00궁술|r"
			set thistype(ABILITY_TAG_FIRE		).tag_name = "|cffffff00화염|r"
			set thistype(ABILITY_TAG_DIVINE		).tag_name = "|cffffff00신성|r"
			set thistype(ABILITY_TAG_PRODUCT	).tag_name = "|cffffff00생산|r"
			set thistype(ABILITY_TAG_DRUG		).tag_name = "|cffffff00약물|r"
			set thistype(ABILITY_TAG_POISON		).tag_name = "|cffffff00독성|r"
			set thistype(ABILITY_TAG_CARDMAGIC	).tag_name = "|cffffff00마술|r"
			set thistype(ABILITY_TAG_THROW		).tag_name = "|cffffff00투척|r"
			set thistype(ABILITY_TAG_DARK		).tag_name = "|cffffff00암흑|r"
			set thistype(ABILITY_TAG_DRAGON		).tag_name = "|cffffff00용혈|r"
			set thistype(ABILITY_TAG_FROST		).tag_name = "|cffffff00냉기|r"
			set thistype(ABILITY_TAG_UNDEAD		).tag_name = "|cffffff00언데드|r"
			set thistype(ABILITY_TAG_BUG		).tag_name = "|cffffff00벌레|r"
			set thistype(CAST_TYPE_TARGET_LOCATION	).cast_type = "|cff00ffff지점 목표물|r"
			set thistype(CAST_TYPE_TARGET_UNIT		).cast_type = "|cff00ffff유닛 목표물|r"
			set thistype(CAST_TYPE_IMMEDIATE		).cast_type = "|cff00ffff즉시 시전|r"
			set thistype(CAST_TYPE_PASSIVE			).cast_type = "|cff00ffff지속효과|r"
			set thistype(CAST_TYPE_DRAG_TO_USE		).cast_type = "|cff00ffff끌어서 사용|r"
			set thistype(CAST_TYPE_WEAPON			).cast_type = "|cffcc0000무기|r"
		endmethod

	endstruct


	struct Ability extends Ability_prototype

		static integer array TABLE_INDEX
		static constant integer TABLE_INDEX_LIMIT = 1024

		private static constant integer INDEX_TAG = 0
		private static constant integer INDEX_ICON_PATH = 8
		private static constant integer INDEX_NAME = 9
		private static constant integer INDEX_TIER = 10
		private static constant integer INDEX_COST = 11
		private static constant integer INDEX_BONUS_STAT = 12	/*SIZE : 2*/
		private static constant integer INDEX_TOOLTIP = 14
		private static constant integer INDEX_IS_WEAPON = 15
		private static constant integer INDEX_CAST_TYPE = 16
		private static constant integer INDEX_LAST = 17

		real stat_bonus1 = 0.
		real stat_bonus2 = 0.
		boolean signiture = false

		static method getTypeIsWeapon takes integer id returns boolean
			return LoadBoolean(HASH,id,INDEX_IS_WEAPON)
		endmethod

		static method setTypeIsWeapon takes integer id, boolean b returns nothing
			call SaveBoolean(HASH,id,INDEX_IS_WEAPON,b)
		endmethod

		static method getTypeTier takes integer id returns integer
			return LoadInteger(HASH,id,INDEX_TIER)
		endmethod

		static method setTypeTier takes integer id, integer val returns nothing
			call SaveInteger(HASH,id,INDEX_TIER,val)
		endmethod

		static method getTypeCastType takes integer id returns integer
			return LoadInteger(HASH,id,INDEX_CAST_TYPE)
		endmethod

		static method setTypeCastType takes integer id, integer val returns nothing
			call SaveInteger(HASH,id,INDEX_CAST_TYPE,val)
		endmethod

		static method addRandomAbility takes integer id, integer table_num returns nothing
			if table_num < TABLE_INDEX_LIMIT then
				call SaveInteger(HASH,table_num,TABLE_INDEX[table_num],id)
				set TABLE_INDEX[table_num] = TABLE_INDEX[table_num] + 1
			endif
		endmethod

		static method getRandomAbility takes integer table_num returns integer
			local integer i = GetRandomInt(0,TABLE_INDEX[table_num]-1)
			return LoadInteger(HASH,table_num,i)
		endmethod

		static method getTypeTooltip takes integer id returns string
			if HaveSavedString(HASH,id,INDEX_TOOLTIP) then
				return LoadStr(HASH,id,INDEX_TOOLTIP)
			else
				return "ToolTip Missing"
			endif
		endmethod

		static method setTypeTooltip takes integer id, string val returns nothing
			call SaveStr(HASH,id,INDEX_TOOLTIP,val)
		endmethod

		static method getTypeCost takes integer id returns integer
			return LoadInteger(HASH,id,INDEX_COST)
		endmethod

		static method setTypeCost takes integer id, integer val returns nothing
			call SaveInteger(HASH,id,INDEX_COST,val)
		endmethod

		static method getTypeName takes integer id returns string
			return LoadStr(HASH,id,INDEX_NAME)
		endmethod

		static method setTypeName takes integer id, string val returns nothing
			call SaveStr(HASH,id,INDEX_NAME,val)
		endmethod

		static method getTypeIconPath takes integer id returns string
			return LoadStr(HASH,id,INDEX_ICON_PATH)
		endmethod

		static method setTypeIconPath takes integer id, string val returns nothing
			call SaveStr(HASH,id,INDEX_ICON_PATH,val)
		endmethod

		static method getTypeBonusStatIndex takes integer id, integer slot returns integer
			return LoadInteger(HASH,id,INDEX_BONUS_STAT+slot)
		endmethod

		static method setTypeBonusStatIndex takes integer id, integer slot, integer index returns nothing
			if slot == 0 or slot == 1 then
				call SaveInteger(HASH,id,INDEX_BONUS_STAT+slot,index)
			endif
		endmethod

		static method addTypeTag takes integer id, integer val returns nothing
			local integer i = 0
			loop
				exitwhen i >= INDEX_ICON_PATH
				if not HaveSavedInteger(HASH,id,i) then
					call SaveInteger(HASH,id,i,val)
					exitwhen true
				endif
				set i = i + 1
			endloop
		endmethod

		static method getTypeTag takes integer id, integer index returns integer
			if HaveSavedInteger(HASH,id,index) and index < INDEX_ICON_PATH then
				return LoadInteger(HASH,id,index)
			else
				return -1
			endif
		endmethod

		static method isTypeIncludeTag takes integer id, integer findtext returns boolean
			local integer i = 0
			loop
				exitwhen getTypeTag(id,i) < 0
				if getTypeTag(id,i) == findtext then
					return true
				endif
				set i = i + 1
			endloop
			return false
		endmethod

		static method onInit takes nothing returns nothing
			local integer i = 0
			loop
				exitwhen i >= TABLE_INDEX_LIMIT
				set TABLE_INDEX[i] = 0
				set i = i + 1
			endloop
		endmethod

		stub method iconClick takes nothing returns nothing
			if getTypeIsWeapon(.id) then
				call .owner.setWeaponAbility(this)
				call UI.THIS[GetPlayerId(.owner.owner)].refreshAbilityIconsTarget()
			endif
		endmethod

		method plusStatValue takes integer v returns nothing
			local integer ind1 = getTypeBonusStatIndex(.id,0)
			local integer ind2 = getTypeBonusStatIndex(.id,1)
			call .owner.plusStatValue(ind1,v*STAT_NORMAL_VALUE[ind1]*getTypeTier(.id)*0.5)
			call .owner.plusStatValue(ind2,v*STAT_NORMAL_VALUE[ind2]*getTypeTier(.id)*0.5)
			set .stat_bonus1 = .stat_bonus1 + v*STAT_NORMAL_VALUE[ind1]*getTypeTier(.id)*0.5
			set .stat_bonus2 = .stat_bonus2 + v*STAT_NORMAL_VALUE[ind2]*getTypeTier(.id)*0.5
		endmethod

		method addLevel takes integer v returns nothing
			set .level = .level + v
			call plusStatValue(v)
		endmethod

		stub method deactivate takes nothing returns nothing

		endmethod

		method onDeath takes nothing returns nothing
			local UI ui = UI.THIS[GetPlayerId(.owner.owner)]
			call .owner.plusStatValue(getTypeBonusStatIndex(id,0),-.stat_bonus1)
			call .owner.plusStatValue(getTypeBonusStatIndex(id,1),-.stat_bonus2)
			call deactivate()
			if ui > 0 then
				call ui.refreshAbilityIconsTarget()
			endif
		endmethod

	endstruct

endlibrary

//! textmacro abilityDataHeader takes id, name, icon, tier, stat1, stat2, isweapon

	globals
		private constant integer ID = '$id$'
		private constant string NAME = "$name$"
		private constant string ICON_PATH = "$icon$"
		private constant integer TIER = $tier$
		private constant integer COST = $tier$
		private constant integer STAT_INDEX1 = $stat1$
		private constant integer STAT_INDEX2 = $stat2$
		private constant boolean IS_WEAPON = $isweapon$
	endglobals
		
//! endtextmacro

//! textmacro abilityDataEnd
	private function act takes nothing returns nothing
		local main a = 0
		if ABILITY_CREATE_ID == ID then
			set a = main.create()
			set a.id = ID
			set a.name = NAME
			set a.icon = ICON_PATH
			set ABILITY_LAST_CREATED = a
		endif
	endfunction

	private function init takes nothing returns nothing
		call TriggerAddCondition(ABILITY_CREATE_TRIGGER,function act)
		call Ability.setTypeIconPath(ID,ICON_PATH)
		call Ability.setTypeName(ID,NAME)
		call Ability.setTypeTier(ID,TIER)
		call Ability.setTypeCost(ID,COST)
		call Ability.setTypeBonusStatIndex(ID,0,STAT_INDEX1)
		call Ability.setTypeBonusStatIndex(ID,1,STAT_INDEX2)
		call Ability.setTypeIsWeapon(ID,IS_WEAPON)
	endfunction
//! endtextmacro 

//! import "AbilityData\\AbilityData.j"
//! import "AbilityData\\Chingho.j"