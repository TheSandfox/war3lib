//! textmacro MonsterAbilityDataHeader takes id
	set ID_CURRENT = $id$
//! endtextmacro

//! textmacro MonsterAbilitySetData takes prime, value
	set $prime$[ID_CURRENT] = $value$
//! endtextmacro

/*후려치기*/
	//! runtextmacro MonsterAbilityDataHeader("0")
	//! runtextmacro MonsterAbilitySetData("NAME","\"후려치기\"")
	set DESCRIPTION[ID_CURRENT] = "있는 힘껏 대상을 후려쳐 "+STAT_TYPE_NAME[STAT_TYPE_ATTACK]+"에 비례한 "+String.PHYSICAL_DAMAGE+"를 입힙니다."
	//! runtextmacro MonsterAbilitySetData("VALUE1","1.0")
	//! runtextmacro MonsterAbilitySetData("ACTOR_ID1","'0000'")
/*독침*/
	//! runtextmacro MonsterAbilityDataHeader("1")
	//! runtextmacro MonsterAbilitySetData("NAME","\"독침\"")
	set DESCRIPTION[ID_CURRENT] = "대상에게 독침을 쏘아 "+STAT_TYPE_NAME[STAT_TYPE_ATTACK]+"에 비례한 "+String.PHYSICAL_DAMAGE+"를 입힙니다."
	//! runtextmacro MonsterAbilitySetData("ELEMENT_TYPE1","ELEMENT_TYPE_POISON")
	//! runtextmacro MonsterAbilitySetData("VALUE1","0.75")
	//! runtextmacro MonsterAbilitySetData("AP_COST","75.")
	//! runtextmacro MonsterAbilitySetData("ACTOR_ID1","'0010'")
/*나무주먹*/
	//! runtextmacro MonsterAbilityDataHeader("2")
	//! runtextmacro MonsterAbilitySetData("NAME","\"나무주먹\"")
	set DESCRIPTION[ID_CURRENT] = "대상을 나무주먹으로 후려쳐 "+STAT_TYPE_NAME[STAT_TYPE_ATTACK]+"에 비례한 "+String.PHYSICAL_DAMAGE+"를 입힙니다."
	//! runtextmacro MonsterAbilitySetData("ELEMENT_TYPE1","ELEMENT_TYPE_NATURE")
	//! runtextmacro MonsterAbilitySetData("VALUE1","1.")
	//! runtextmacro MonsterAbilitySetData("AP_COST","100.")
	//! runtextmacro MonsterAbilitySetData("ACTOR_ID1","'0020'")
/*철벽*/
	//! runtextmacro MonsterAbilityDataHeader("3")
	//! runtextmacro MonsterAbilitySetData("NAME","\"철벽\"")
	set DESCRIPTION[ID_CURRENT] = "방어태세를 취하여 일정 시간동안 "+STAT_TYPE_NAME[STAT_TYPE_DEFFENCE]+"를 증가시킵니다."
	//! runtextmacro MonsterAbilitySetData("ELEMENT_TYPE1","ELEMENT_TYPE_METAL")
	//! runtextmacro MonsterAbilitySetData("ELEMENT_TYPE2","ELEMENT_TYPE_METAL")
	//! runtextmacro MonsterAbilitySetData("VALUE1","0.25")
	//! runtextmacro MonsterAbilitySetData("VALUE2","7.")
	//! runtextmacro MonsterAbilitySetData("AP_COST","100.")
	//! runtextmacro MonsterAbilitySetData("ACTOR_ID1","'0030'")
/*갑각 찌르기*/
	//! runtextmacro MonsterAbilityDataHeader("4")
	//! runtextmacro MonsterAbilitySetData("NAME","\"갑각 찌르기\"")
	set DESCRIPTION[ID_CURRENT] = "단단한 껍질로 대상을 두 번 찔러 "+STAT_TYPE_NAME[STAT_TYPE_ATTACK]+"에 비례한 "+String.PHYSICAL_DAMAGE+"를 입힙니다."
	//! runtextmacro MonsterAbilitySetData("ELEMENT_TYPE1","ELEMENT_TYPE_NATURE")
	//! runtextmacro MonsterAbilitySetData("ELEMENT_TYPE2","ELEMENT_TYPE_WIND")
	//! runtextmacro MonsterAbilitySetData("VALUE1","0.8/2.")
	//! runtextmacro MonsterAbilitySetData("AP_COST","75.")
	//! runtextmacro MonsterAbilitySetData("ACTOR_ID1","'0040'")
	//! runtextmacro MonsterAbilitySetData("ACTOR_ID2","'0041'")