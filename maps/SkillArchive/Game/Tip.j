library Tip

	struct Tip

		static trigger TRIGGER = CreateTrigger()
		static string array TIPS
		static integer TIP_MAX = 0
		static real TIP_INTERVAL = 60.

		static method act takes nothing returns nothing
			call DisplayTimedTextToPlayer(GetLocalPlayer(),0.,0.,10.,"\n|cffffcc00정보 : |r"+TIPS[GetRandomInt(0,TIP_MAX)])
			call PlaySoundBJ(gg_snd_Hint)
		endmethod

		static method init takes nothing returns nothing
			call TriggerRegisterTimerEvent(TRIGGER,TIP_INTERVAL,true)
			call TriggerAddCondition(TRIGGER,function thistype.act)
			set TIPS[0] = "|cffffcc00스킬 아이콘을 우클릭하여 빠른 시전 설정을 할 수 있습니다.|r"+/*
			*/"\n|cff999999사용 안함|r |cffffcc00-> 사거리 표시 ->|r |cff00ffff즉시 사용|r |cffffcc00순으로 변경됩니다.|r"
			set TIPS[1] = "|cff00ffff스킬 아이콘 클릭|r |cffffcc00액션은|r|cff00ffff Shift + 스킬 단축키 입력|r|cffffcc00으로도 발동시킬 수 있습니다.|r"
			set TIPS[2] = ABILITY_STRING_WEAPON+"|cffffcc00 능력은 한 종류만 사용 가능하며 여러 |r"+ABILITY_STRING_WEAPON+" |cffffcc00능력을 배웠을 경우|r\n|cff00ffff스킬 아이콘 클릭|r|cffffcc00으로 사용할 능력을 설정할 수 있습니다.|r"
			set TIPS[3] = "|cffffcc00능력마다 최소 재사용 대기시간이 존재하며 해당 시간보다 재사용 시간을 적게 줄일 수 없습니다.|r"
			set TIPS[4] = "|cffffcc00캐릭터가 최초로 보유한 능력은 캐릭터의 레벨이 올라갈 때 마다 같이 레벨이 상승합니다."
			set TIP_MAX = 4
		endmethod

	endstruct

endlibrary