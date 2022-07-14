library User requires UnitPrototype

globals
	constant integer PLAYER_MAX = 4
	/**/
	trigger GOLD_REFRESH_TRIGGER = CreateTrigger()
	player GOLD_REFRESH_PLAYER = null
endglobals

struct User extends array

	static string array ORIGIN_NAME
	static string array BATTLE_TAG
	static string array CURRENT_NAME
	static trigger array KEYPRESS
	static integer array FOCUSUNIT
	static string array TEAMCOLOR_TO_STRING
	static string array OSKEY_INDEX_TO_STRING

	static hashtable HASH = InitHashtable()

	static method oskey2Index takes oskeytype os returns integer
		if 		os == OSKEY_Q then
			return 0
		elseif 	os == OSKEY_W then
			return 1
		elseif 	os == OSKEY_E then
			return 2
		elseif 	os == OSKEY_R then
			return 3
		elseif 	os == OSKEY_D then
			return 4
		elseif 	os == OSKEY_F then
			return 5
		elseif 	os == OSKEY_Z then
			return 6
		elseif 	os == OSKEY_X then
			return 7
		elseif 	os == OSKEY_C then
			return 8
		elseif 	os == OSKEY_V then
			return 9
		elseif	os == OSKEY_LCONTROL then
			return 10
		elseif	os == OSKEY_LSHIFT then
			return 11
		elseif	os == OSKEY_LALT then
			return 12
		else
			return 0
		endif
	endmethod

	static method oskeyIndex2String takes integer index returns string
		return OSKEY_INDEX_TO_STRING[index]
	endmethod

	static method setKeyState takes player p, oskeytype ok, boolean val returns nothing
		call SaveBoolean(HASH,GetPlayerId(p),GetHandleId(ok),val)
	endmethod

	static method getKeyState takes player p, oskeytype ok returns boolean
		return LoadBoolean(HASH,GetPlayerId(p),GetHandleId(ok))
	endmethod

	static method getGold takes player p returns integer
		return GetPlayerState(p,PLAYER_STATE_RESOURCE_GOLD)
	endmethod

	static method addGold takes player p, integer nv returns nothing
		call SetPlayerState(p,PLAYER_STATE_RESOURCE_GOLD,GetPlayerState(p,PLAYER_STATE_RESOURCE_GOLD)+nv)
		set GOLD_REFRESH_PLAYER = null
		set GOLD_REFRESH_PLAYER = p
		call TriggerEvaluate(GOLD_REFRESH_TRIGGER)
	endmethod

	static method getLumber takes player p returns integer
		return GetPlayerState(p,PLAYER_STATE_RESOURCE_LUMBER)
	endmethod

	static method addLumber takes player p, integer nv returns nothing
		call SetPlayerState(p,PLAYER_STATE_RESOURCE_LUMBER,GetPlayerState(p,PLAYER_STATE_RESOURCE_LUMBER)+nv)
	endmethod

	static method teamColorString takes player p, string val returns string
		return TEAMCOLOR_TO_STRING[GetPlayerId(p)] + val + "|r"
	endmethod

	static method refinePlayerName takes player p returns nothing
		local string origin = GetPlayerName(p)
		local integer i = StringLength(origin)
		set ORIGIN_NAME[GetPlayerId(p)] = origin
		loop
			exitwhen i == 0
			if SubString(origin,i-1,i) == "#" then
				set BATTLE_TAG[GetPlayerId(p)] = SubString(origin,i,StringLength(origin))
				set i = i - 1
				exitwhen true
			endif
			set i = i - 1
		endloop
		if i >= 0 then
			call SetPlayerName(p,SubString(origin,0,i))
		endif
	endmethod

	static method getFocusUnit takes player p returns Unit_prototype
		return FOCUSUNIT[GetPlayerId(p)]
	endmethod

	static method setFocusUnit takes player p, integer u returns nothing
		set FOCUSUNIT[GetPlayerId(p)] = u
	endmethod

	static method selectFocusUnit takes player p returns nothing
		call ClearSelectionForPlayer(p)
		if GetLocalPlayer() ==  p then
			call SelectUnit(getFocusUnit(p).origin_unit,true)
		endif
	endmethod

	private static method keyPress takes nothing returns nothing
		local Ability_prototype a = 0
		local Unit_prototype u = getFocusUnit(GetTriggerPlayer())
		if u > 0 then
			set a = u.getAbility(oskey2Index(BlzGetTriggerPlayerKey()))
			if a > 0 then
				if getKeyState(GetTriggerPlayer(),BlzGetTriggerPlayerKey()) != BlzGetTriggerPlayerIsKeyDown() then
					if BlzGetTriggerPlayerIsKeyDown() then
						if BlzGetTriggerPlayerMetaKey() == 1 then
							call a.iconClick()
						else
							if a.is_active then
								call a.press()
							else
								call a.iconClick()
							endif
							call a.onKeyboard()
						endif
					elseif a.smart > 0 then
						call a.release()
					endif
				elseif BlzGetTriggerPlayerIsKeyDown() then
					call a.onKeyboard()
				endif
			endif
		endif
		if BlzGetTriggerPlayerIsKeyDown() != getKeyState(GetTriggerPlayer(),BlzGetTriggerPlayerKey()) then
			call setKeyState(GetTriggerPlayer(),BlzGetTriggerPlayerKey(),BlzGetTriggerPlayerIsKeyDown())
		endif
	endmethod

	static method new takes player p returns nothing
		local integer i = GetPlayerId(p)
		call refinePlayerName(p)
		set KEYPRESS[i] = CreateTrigger()
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_Q,0,true)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_W,0,true)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_E,0,true)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_R,0,true)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_D,0,true)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_F,0,true)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_Z,0,true)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_X,0,true)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_C,0,true)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_V,0,true)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_Q,0,false)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_W,0,false)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_E,0,false)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_R,0,false)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_D,0,false)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_F,0,false)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_Z,0,false)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_X,0,false)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_C,0,false)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_V,0,false)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_Q,1,true)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_W,1,true)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_E,1,true)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_R,1,true)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_D,1,true)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_F,1,true)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_Z,1,true)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_X,1,true)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_C,1,true)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_V,1,true)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_Q,1,false)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_W,1,false)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_E,1,false)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_R,1,false)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_D,1,false)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_F,1,false)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_Z,1,false)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_X,1,false)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_C,1,false)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_V,1,false)
		//metakey
		/*call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_LALT,4,true)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_LALT,0,false)*/
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_LCONTROL,2,true)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_LCONTROL,0,false)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_LCONTROL,1,false)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_LSHIFT,1,true)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_LSHIFT,0,false)
		call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS[i],p,OSKEY_LSHIFT,2,false)
		//
		call setKeyState(p,OSKEY_Q,false)
		call setKeyState(p,OSKEY_W,false)
		call setKeyState(p,OSKEY_E,false)
		call setKeyState(p,OSKEY_R,false)
		call setKeyState(p,OSKEY_D,false)
		call setKeyState(p,OSKEY_F,false)
		call setKeyState(p,OSKEY_Z,false)
		call setKeyState(p,OSKEY_X,false)
		call setKeyState(p,OSKEY_C,false)
		call setKeyState(p,OSKEY_V,false)
		call setKeyState(p,OSKEY_LCONTROL,false)
		call TriggerAddCondition(KEYPRESS[i],function thistype.keyPress)
	endmethod

	static method onInit takes nothing returns nothing
		set TEAMCOLOR_TO_STRING[0] = "|cffff0000"
		set TEAMCOLOR_TO_STRING[1] = "|cff0000ff"
		set TEAMCOLOR_TO_STRING[2] = "|cff1be6ba"
		set TEAMCOLOR_TO_STRING[3] = "|cff550081"
		set TEAMCOLOR_TO_STRING[4] = "|cfffffb00"
		set TEAMCOLOR_TO_STRING[5] = "|cffff8a0d"
		set TEAMCOLOR_TO_STRING[6] = "|cff20bf00"
		set TEAMCOLOR_TO_STRING[7] = "|cffe35baf"
		set TEAMCOLOR_TO_STRING[8] = "|cff949697"
		set TEAMCOLOR_TO_STRING[9] = "|cff7ebff1"
		set TEAMCOLOR_TO_STRING[10] = "|cff106247"
		set TEAMCOLOR_TO_STRING[11] = "|cff4f2b05"
		set TEAMCOLOR_TO_STRING[12] = "|cff9c0000"
		set TEAMCOLOR_TO_STRING[13] = "|cff0000c2"
		set TEAMCOLOR_TO_STRING[14] = "|cff00ebff"
		set TEAMCOLOR_TO_STRING[15] = "|cffbd00ff"
		set TEAMCOLOR_TO_STRING[16] = "|cffeccc86"
		set TEAMCOLOR_TO_STRING[17] = "|cfff7a48b"
		set TEAMCOLOR_TO_STRING[18] = "|cffbfff80"
		set TEAMCOLOR_TO_STRING[19] = "|cffdbb8ec"
		set TEAMCOLOR_TO_STRING[20] = "|cff4f4f55"
		set TEAMCOLOR_TO_STRING[21] = "|cffecf0ff"
		set TEAMCOLOR_TO_STRING[22] = "|cff00781e"
		set TEAMCOLOR_TO_STRING[23] = "|cffa46f34"
		set TEAMCOLOR_TO_STRING[GetPlayerNeutralPassive()] = "|cff2e2e2e"
		set TEAMCOLOR_TO_STRING[GetPlayerNeutralAggressive()] = "|cff2e2e2e"
		set OSKEY_INDEX_TO_STRING[0] = "Q"
		set OSKEY_INDEX_TO_STRING[1] = "W"
		set OSKEY_INDEX_TO_STRING[2] = "E"
		set OSKEY_INDEX_TO_STRING[3] = "R"
		set OSKEY_INDEX_TO_STRING[4] = "D"
		set OSKEY_INDEX_TO_STRING[5] = "F"
		set OSKEY_INDEX_TO_STRING[6] = "Z"
		set OSKEY_INDEX_TO_STRING[7] = "X"
		set OSKEY_INDEX_TO_STRING[8] = "C"
		set OSKEY_INDEX_TO_STRING[9] = "V"
	endmethod

endstruct

	function LocalScope takes player p returns boolean
		return GetLocalPlayer() == p
	endfunction

endlibrary