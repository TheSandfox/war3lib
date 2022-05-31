library MonsterAbility requires MonsterData

	globals
		constant integer MONSTER_ABILITY_MAX = 256
	endglobals

	//! textmacro initializeAbilityStatsById takes sub, prime
		set .$sub$ = MonsterAbilityData.$prime$[id]
	//! endtextmacro

	//! textmacro copyAbilityStats takes sub
		set .$sub$ = ma.$sub$
	//! endtextmacro

	struct MonsterAbilityData

		private static integer ID_CURRENT = 0

		static string array NAME[MONSTER_ABILITY_MAX]
		static string array DESCRIPTION[MONSTER_ABILITY_MAX]
		static real array AP_COST[MONSTER_ABILITY_MAX]
		static integer array RANGED[MONSTER_ABILITY_MAX]
		static integer array ELEMENT_TYPE1[MONSTER_ABILITY_MAX]
		static integer array ELEMENT_TYPE2[MONSTER_ABILITY_MAX]
		static integer array MAX_TARGET[MONSTER_ABILITY_MAX]
		static boolean array DISPERSIBLE[MONSTER_ABILITY_MAX]
		static boolean array REFRACTILE[MONSTER_ABILITY_MAX]
		static real array VALUE1[MONSTER_ABILITY_MAX]
		static real array VALUE2[MONSTER_ABILITY_MAX]
		static real array VALUE3[MONSTER_ABILITY_MAX]
		static real array VALUE4[MONSTER_ABILITY_MAX]
		static real array VALUE5[MONSTER_ABILITY_MAX]
		static real array VALUE6[MONSTER_ABILITY_MAX]
		static real array VALUE7[MONSTER_ABILITY_MAX]
		static real array VALUE8[MONSTER_ABILITY_MAX]

		/*BattleMonsterAbilityOnly*/
		static integer array ACTOR_ID1[MONSTER_ABILITY_MAX]
		static integer array ACTOR_ID2[MONSTER_ABILITY_MAX]
		static integer array ACTOR_ID3[MONSTER_ABILITY_MAX]
		static integer array ACTOR_ID4[MONSTER_ABILITY_MAX]

		private static method onInit takes nothing returns nothing
			/*DEFINE DEFAULTS*/
			local integer i = 0
			loop
				exitwhen i >= MONSTER_ABILITY_MAX
				set NAME[i]					= ""
				set DESCRIPTION[i]			= ""
				set AP_COST[i]				= 100.
				set RANGED[i]				= 0 
				set ELEMENT_TYPE1[i]		= ELEMENT_TYPE_NORMAL
				set ELEMENT_TYPE2[i]		= ELEMENT_TYPE_NORMAL
				set MAX_TARGET[i]			= 1
				set DISPERSIBLE[i]			= false
				set REFRACTILE[i]			= true
				set VALUE1[i]				= 0.
				set VALUE2[i]				= 0.
				set VALUE3[i]				= 0.
				set VALUE4[i]				= 0.
				set VALUE5[i]				= 0.
				set VALUE6[i]				= 0.
				set VALUE7[i]				= 0.
				set VALUE8[i]				= 0.
				set ACTOR_ID1[i]			= '0000'
				set ACTOR_ID2[i]			= 0
				set ACTOR_ID3[i]			= 0
				set ACTOR_ID4[i]			= 0
				set i = i + 1
			endloop
			//! import "monsterabilitydata.j"
		endmethod

	endstruct

	struct MonsterAbility

		integer id 				= 0

		string name				= ""
		string description 		= ""
		real ap_cost			= 100.
		integer ranged 			= 0
		integer element_type1 	= ELEMENT_TYPE_NORMAL
		integer element_type2 	= ELEMENT_TYPE_NORMAL
		integer max_target 		= 1
		boolean dispersible		= false
		boolean refractile		= true
		real value1				= 0.
		real value2				= 0.
		real value3				= 0.
		real value4				= 0.
		real value5				= 0.
		real value6				= 0.
		real value7				= 0.
		real value8				= 0.

		method initializeStatsByData takes integer id returns nothing
			//! runtextmacro initializeAbilityStatsById("name","NAME")
			//! runtextmacro initializeAbilityStatsById("description","DESCRIPTION")
			//! runtextmacro initializeAbilityStatsById("ap_cost","AP_COST")
			//! runtextmacro initializeAbilityStatsById("ranged","RANGED")
			//! runtextmacro initializeAbilityStatsById("element_type1","ELEMENT_TYPE1")
			//! runtextmacro initializeAbilityStatsById("element_type2","ELEMENT_TYPE2")
			//! runtextmacro initializeAbilityStatsById("max_target","MAX_TARGET")
			//! runtextmacro initializeAbilityStatsById("dispersible","DISPERSIBLE")
			//! runtextmacro initializeAbilityStatsById("refractile","REFRACTILE")
			//! runtextmacro initializeAbilityStatsById("value1","VALUE1")
			//! runtextmacro initializeAbilityStatsById("value2","VALUE2")
			//! runtextmacro initializeAbilityStatsById("value3","VALUE3")
			//! runtextmacro initializeAbilityStatsById("value4","VALUE4")
			//! runtextmacro initializeAbilityStatsById("value5","VALUE5")
			//! runtextmacro initializeAbilityStatsById("value6","VALUE6")
			//! runtextmacro initializeAbilityStatsById("value7","VALUE7")
			//! runtextmacro initializeAbilityStatsById("value8","VALUE8")
		endmethod

		static method create takes integer id returns thistype
			local thistype this = allocate()
			set .id = id
			if .id > -1 then
				call initializeStatsByData(.id)
			endif
			return this
		endmethod

	endstruct

endlibrary

library BattleMonsterAbility requires Character

	struct BattleMonsterAbility extends MonsterAbility

		integer actor_id1 = 0
		integer actor_id2 = 0
		integer actor_id3 = 0
		integer actor_id4 = 0

		private method initializeStatsByData2 takes integer id returns nothing
			//! runtextmacro initializeAbilityStatsById("actor_id1","ACTOR_ID1")
			//! runtextmacro initializeAbilityStatsById("actor_id2","ACTOR_ID2")
			//! runtextmacro initializeAbilityStatsById("actor_id3","ACTOR_ID3")
			//! runtextmacro initializeAbilityStatsById("actor_id4","ACTOR_ID4")
		endmethod

		private method copyStats takes MonsterAbility ma returns nothing
			//! runtextmacro copyAbilityStats("name")
			//! runtextmacro copyAbilityStats("description")
			//! runtextmacro copyAbilityStats("ap_cost")
			//! runtextmacro copyAbilityStats("ranged")
			//! runtextmacro copyAbilityStats("element_type1")
			//! runtextmacro copyAbilityStats("element_type2")
			//! runtextmacro copyAbilityStats("max_target")
			//! runtextmacro copyAbilityStats("dispersible")
			//! runtextmacro copyAbilityStats("refractile")
			//! runtextmacro copyAbilityStats("value1")
			//! runtextmacro copyAbilityStats("value2")
			//! runtextmacro copyAbilityStats("value3")
			//! runtextmacro copyAbilityStats("value4")
			//! runtextmacro copyAbilityStats("value5")
			//! runtextmacro copyAbilityStats("value6")
			//! runtextmacro copyAbilityStats("value7")
			//! runtextmacro copyAbilityStats("value8")
		endmethod

		static method create takes MonsterAbility ma returns thistype
			local thistype this = allocate(-1)
			call initializeStatsByData2(ma.id)
			call copyStats(ma)
			return this
		endmethod

		static method createInstant takes integer id returns thistype
			local thistype this = allocate(id)
			call initializeStatsByData2(id)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			
		endmethod

	endstruct

endlibrary