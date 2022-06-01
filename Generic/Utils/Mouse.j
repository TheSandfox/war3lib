scope Mouse
/*REQUIRES udg_RIGHT_CLICK_EVENT_VALUE*/
globals
	trigger RIGHT_CLICK = CreateTrigger()
	trigger RIGHT_CLICK_RECEIVE = CreateTrigger()
	player RIGHT_CLICK_PLAYER = null
	unit RIGHT_CLICK_UNIT = null
	real RIGHT_CLICK_X = 0.
	real RIGHT_CLICK_Y = 0.
	boolean RIGHT_CLICK_ENABLE = false
endglobals

struct Mouse extends array

	static trigger array MOVE[32]
	static real array X[32]
	static real array Y[32]

	static method customRightClick takes player p, real x, real y returns nothing
		set RIGHT_CLICK_PLAYER = p
		set RIGHT_CLICK_UNIT = null
		set RIGHT_CLICK_X = x
		set RIGHT_CLICK_Y = y
		set RIGHT_CLICK_ENABLE = true
		set udg_EVENT_VALUE = RIGHT_CLICK_EVENT
		set RIGHT_CLICK_PLAYER = null
		set RIGHT_CLICK_UNIT = null
		set RIGHT_CLICK_ENABLE = false
	endmethod

	static method triggerRegisterGenericRightClick takes trigger t returns nothing
		call TriggerRegisterVariableEvent(t,"udg_EVENT_VALUE",EQUAL,RIGHT_CLICK_EVENT)
	endmethod

	static method getX takes player p returns real 
		return X[GetPlayerId(p)]
	endmethod

	static method getVX takes player p returns real 
		return X[GetPlayerId(p)]
	endmethod

	static method getY takes player p returns real
		return Y[GetPlayerId(p)]
	endmethod

	static method getVY takes player p returns real
		return Y[GetPlayerId(p)]
	endmethod

	private static method move takes nothing returns nothing
		local integer i = GetPlayerId(GetTriggerPlayer())
		set X[i] = BlzGetTriggerPlayerMouseX()
		set Y[i] = BlzGetTriggerPlayerMouseY()
	endmethod

	private static method receiveRightClick takes nothing returns nothing
		local string source = ""
		local integer l = 0
		set udg_EVENT_VALUE = 0.
		set source = BlzGetTriggerSyncData()
		set l = StringLength(source)
		set bj_forLoopAIndex = 0
		/*GetPlayer*/
		loop
			exitwhen SubString(source,bj_forLoopAIndex,bj_forLoopAIndex+1) == "!"
			set bj_forLoopAIndex = bj_forLoopAIndex + 1
		endloop
		set RIGHT_CLICK_PLAYER = Player(S2I(SubString(source,0,bj_forLoopAIndex)))
		set RIGHT_CLICK_X = S2I(SubString(source,bj_forLoopAIndex+1,l))
		loop
			exitwhen SubString(source,bj_forLoopAIndex,bj_forLoopAIndex+1) == "@"
			set bj_forLoopAIndex = bj_forLoopAIndex + 1
		endloop
		set RIGHT_CLICK_Y = S2I(SubString(source,bj_forLoopAIndex+1,l))
		loop
			exitwhen SubString(source,bj_forLoopAIndex,bj_forLoopAIndex+1) == "#"
			set bj_forLoopAIndex = bj_forLoopAIndex + 1
		endloop
		set RIGHT_CLICK_UNIT = Agent.H2U(S2I(SubString(source,bj_forLoopAIndex+1,l)))
		call BJDebugMsg(GetPlayerName(RIGHT_CLICK_PLAYER)+", "+R2SW(RIGHT_CLICK_X,1,1)+", "+R2SW(RIGHT_CLICK_Y,1,1)+", "+GetUnitName(RIGHT_CLICK_UNIT))
		set RIGHT_CLICK_ENABLE = true
		/*TODO CHANGE EVENT VAL*/
		set udg_EVENT_VALUE = RIGHT_CLICK_EVENT
		set RIGHT_CLICK_PLAYER = null
		set RIGHT_CLICK_UNIT = null
		set RIGHT_CLICK_ENABLE = false
	endmethod

	private static method sendRightClick takes nothing returns nothing
		if BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_RIGHT then
			if GetLocalPlayer() == GetTriggerPlayer() then
				if BlzGetMouseFocusUnit() != null then
					call BlzSendSyncData("GRM",I2S(GetPlayerId(GetTriggerPlayer()))+"!"+/*
					*/I2S(R2I(BlzGetTriggerPlayerMouseX()))+"@"+I2S(R2I(BlzGetTriggerPlayerMouseY()))+"#"+I2S(GetHandleId(BlzGetMouseFocusUnit())))
				else
					call BlzSendSyncData("GRM",I2S(GetPlayerId(GetTriggerPlayer()))+"!"+/*
					*/I2S(R2I(BlzGetTriggerPlayerMouseX()))+"@"+I2S(R2I(BlzGetTriggerPlayerMouseY()))+"#0")
				endif
			endif
		endif
	endmethod

	static method activateRefresher takes player p returns nothing
		local integer i = GetPlayerId(p)
		set MOVE[i] = null
		set MOVE[i] = CreateTrigger()
		call TriggerRegisterPlayerEvent(MOVE[i],p, EVENT_PLAYER_MOUSE_MOVE)
		call TriggerAddCondition(MOVE[i],function thistype.move)
		set X[i] = 0.
		set Y[i] = 0.
		/*공용우클릭*/
		call TriggerRegisterPlayerEvent(RIGHT_CLICK,p,EVENT_PLAYER_MOUSE_DOWN)
		call BlzTriggerRegisterPlayerSyncEvent(RIGHT_CLICK_RECEIVE,p,"GRM",false)
	endmethod

	static method onInit takes nothing returns nothing
		call TriggerAddCondition(RIGHT_CLICK,function thistype.sendRightClick)
		call TriggerAddCondition(RIGHT_CLICK_RECEIVE,function thistype.receiveRightClick)
	endmethod

endstruct

endscope