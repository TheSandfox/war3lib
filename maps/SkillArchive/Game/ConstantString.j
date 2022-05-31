library ConstantString

	globals
		
		constant string DAMAGE_STRING_PHYSICAL = "|cffff9900물리피해|r"
		constant string DAMAGE_STRING_MAGICAL = "|cff9999ff마법피해|r"
		constant string ATTACK_STRING_BASIC = "|cffff9900기본공격|r"
		constant string ATTACK_STRING_SPELL = "|cff9999ff기술공격|r"
		constant string STRING_COLOR_ATTACK = "|cffff9900"
		constant string STRING_COLOR_MAGICPOWER = "|cff9999ff"
		constant string STRING_COLOR_DEFFENCE = "|cff999999"
		constant string STRING_COLOR_RESISTANCE = "|cff00ffcc"
		constant string STRING_COLOR_ACCURACY = "|cffff00ff"
		constant string STRING_COLOR_EVASION = "|cff99ccff"
		constant string STRING_COLOR_CONSTANT = "|cffffff00"

		string array STAT_TYPE_COLOR
		string array STAT_TYPE_ICON
		string array STAT_TYPE_DESCRIPTION
		string array TIER_STRING_COLOR
	endglobals

	struct ConstantString

		static method statString takes integer index, string s returns string
			return STAT_TYPE_COLOR[index]+s+"|r"
		endmethod

		static method statStringReal takes integer index, real v, integer jom returns string
			return STAT_TYPE_COLOR[index]+R2SW(v,jom,jom)+"|r"
		endmethod

		static method statStringPercent takes integer index, real v returns string
			return STAT_TYPE_COLOR[index]+I2S(R2I(v*100.))+"%|r"
		endmethod

		static method statStringInteger takes integer index, integer v returns string
			return STAT_TYPE_COLOR[index]+I2S(v)+"|r"
		endmethod

		static method onInit takes nothing returns nothing
			set TIER_STRING_COLOR[0] = "|cff999999"
			set TIER_STRING_COLOR[1] = "|cffffffff"
			set TIER_STRING_COLOR[2] = "|cff00ff00"
			set TIER_STRING_COLOR[3] = "|cff0099ff"
			set TIER_STRING_COLOR[4] = "|cffcc00ff"
			set TIER_STRING_COLOR[5] = "|cffff9900" 
			set STAT_TYPE_NAME[STAT_TYPE_MAXHP] 			= "체력"
			set STAT_TYPE_NAME[STAT_TYPE_MAXMP] 			= "마나"
			set STAT_TYPE_NAME[STAT_TYPE_ATTACK]			= "공격력"
			set STAT_TYPE_NAME[STAT_TYPE_DEFFENCE] 			= "방어력"
			set STAT_TYPE_NAME[STAT_TYPE_MAGICPOWER]		= "주문력"
			set STAT_TYPE_NAME[STAT_TYPE_RESISTANCE]		= "저항력"
			set STAT_TYPE_NAME[STAT_TYPE_ACCURACY]			= "정확도"
			set STAT_TYPE_NAME[STAT_TYPE_EVASION]			= "회피치"
			set STAT_TYPE_NAME[STAT_TYPE_ARMOR_PENET]		= "방어관통"
			set STAT_TYPE_NAME[STAT_TYPE_MAGIC_PENET]		= "저항관통"
			set STAT_TYPE_NAME[STAT_TYPE_SPELL_BOOST]		= "주문가속"
			set STAT_TYPE_NAME[STAT_TYPE_HEAL_AMP]			= "받는 회복량"
			set STAT_TYPE_NAME[STAT_TYPE_MOVEMENT_SPEED] 	= "이동속도"
			set STAT_TYPE_NAME[STAT_TYPE_ATTACK_SPEED]		= "공격속도"
			set STAT_TYPE_NAME[STAT_TYPE_LUCK]				= "행운"
			set STAT_TYPE_NAME[STAT_TYPE_ATTACK_RANGE] 		= "공격 사거리"
			set STAT_TYPE_NAME[STAT_TYPE_HPREGEN]			= "체력재생"
			set STAT_TYPE_NAME[STAT_TYPE_MPREGEN]			= "마나재생"
			set STAT_TYPE_COLOR[STAT_TYPE_MAXHP] 			= "|cff00ff00"
			set STAT_TYPE_COLOR[STAT_TYPE_MAXMP] 			= "|cff0099ff"
			set STAT_TYPE_COLOR[STAT_TYPE_ATTACK]			= "|cffff9900"
			set STAT_TYPE_COLOR[STAT_TYPE_DEFFENCE] 		= "|cff999999"
			set STAT_TYPE_COLOR[STAT_TYPE_MAGICPOWER]		= "|cff9999ff"
			set STAT_TYPE_COLOR[STAT_TYPE_RESISTANCE]		= "|cff00ff99"
			set STAT_TYPE_COLOR[STAT_TYPE_ACCURACY]			= "|cffff00ff"
			set STAT_TYPE_COLOR[STAT_TYPE_EVASION]			= "|cff99ccff"
			set STAT_TYPE_COLOR[STAT_TYPE_ARMOR_PENET]		= "|cffff9900"
			set STAT_TYPE_COLOR[STAT_TYPE_MAGIC_PENET]		= "|cff9999ff"
			set STAT_TYPE_COLOR[STAT_TYPE_SPELL_BOOST]		= "|cffff99ff"
			set STAT_TYPE_COLOR[STAT_TYPE_HEAL_AMP]			= "|cffff3333"
			set STAT_TYPE_COLOR[STAT_TYPE_MOVEMENT_SPEED] 	= "|cffffff99"
			set STAT_TYPE_COLOR[STAT_TYPE_ATTACK_SPEED]		= "|cffffff99"
			set STAT_TYPE_COLOR[STAT_TYPE_LUCK]				= "|cff00cc00"
			set STAT_TYPE_COLOR[STAT_TYPE_ATTACK_RANGE] 	= "|cff00ffff"
			set STAT_TYPE_COLOR[STAT_TYPE_HPREGEN]			= "|cff00ff00"
			set STAT_TYPE_COLOR[STAT_TYPE_MPREGEN]			= "|cff0099ff"
			set STAT_TYPE_ICON[STAT_TYPE_MAXHP] 			= "ui\\widgets\\tooltips\\human\\tooltiphpicon.blp"
			set STAT_TYPE_ICON[STAT_TYPE_MAXMP] 			= "ui\\widgets\\tooltips\\human\\tooltipmanaicon.blp"
			set STAT_TYPE_ICON[STAT_TYPE_ATTACK]			= "ui\\widgets\\tooltips\\human\\tooltipattackicon.blp"
			set STAT_TYPE_ICON[STAT_TYPE_DEFFENCE] 			= "ui\\widgets\\tooltips\\human\\tooltipdeffenceicon.blp"
			set STAT_TYPE_ICON[STAT_TYPE_MAGICPOWER]		= "ui\\widgets\\tooltips\\human\\tooltipmagicpowericon.blp"
			set STAT_TYPE_ICON[STAT_TYPE_RESISTANCE]		= "ui\\widgets\\tooltips\\human\\tooltipresistanceicon.blp"
			set STAT_TYPE_ICON[STAT_TYPE_ACCURACY]			= "ui\\widgets\\tooltips\\human\\tooltipaccuracyicon.blp"
			set STAT_TYPE_ICON[STAT_TYPE_EVASION]			= "ui\\widgets\\tooltips\\human\\tooltipevasionicon.blp"
			set STAT_TYPE_ICON[STAT_TYPE_ARMOR_PENET]		= "ui\\widgets\\tooltips\\human\\tooltiparmorpeneticon.blp"
			set STAT_TYPE_ICON[STAT_TYPE_MAGIC_PENET]		= "ui\\widgets\\tooltips\\human\\tooltipmagicpeneticon.blp"
			set STAT_TYPE_ICON[STAT_TYPE_SPELL_BOOST]		= "ui\\widgets\\tooltips\\human\\tooltipspellboosticon.blp"
			set STAT_TYPE_ICON[STAT_TYPE_HEAL_AMP]			= "ui\\widgets\\tooltips\\human\\tooltiphealampicon.blp"
			set STAT_TYPE_ICON[STAT_TYPE_MOVEMENT_SPEED] 	= "ui\\widgets\\tooltips\\human\\tooltipmovementspeedicon.blp"
			set STAT_TYPE_ICON[STAT_TYPE_ATTACK_SPEED]		= "ui\\widgets\\tooltips\\human\\tooltipattackspeedicon.blp"
			set STAT_TYPE_ICON[STAT_TYPE_LUCK]				= "ui\\widgets\\tooltips\\human\\tooltipluckicon.blp"
			set STAT_TYPE_ICON[STAT_TYPE_ATTACK_RANGE] 		= "ui\\widgets\\tooltips\\human\\tooltipattackrangeicon.blp"
			set STAT_TYPE_ICON[STAT_TYPE_HPREGEN]			= "ui\\widgets\\tooltips\\human\\tooltiphpregenicon.blp"
			set STAT_TYPE_ICON[STAT_TYPE_MPREGEN]			= "ui\\widgets\\tooltips\\human\\tooltipmpregenicon.blp"
			set STAT_TYPE_DESCRIPTION[STAT_TYPE_MAXHP] 			= ""
			set STAT_TYPE_DESCRIPTION[STAT_TYPE_MAXMP] 			= ""
			set STAT_TYPE_DESCRIPTION[STAT_TYPE_ATTACK]			= "일부 무기와 기술의 피해량을 상승시킵니다."
			set STAT_TYPE_DESCRIPTION[STAT_TYPE_DEFFENCE] 		= "해당 수치가 높을수록 받는 물리피해가 감소합니다."
			set STAT_TYPE_DESCRIPTION[STAT_TYPE_MAGICPOWER]		= "일부 무기와 기술의 피해량을 상승시킵니다."
			set STAT_TYPE_DESCRIPTION[STAT_TYPE_RESISTANCE]		= "해당 수치가 높을수록 받는 마법피해가 감소합니다."
			set STAT_TYPE_DESCRIPTION[STAT_TYPE_ACCURACY]		= "해당 수치에 비례해 적에게 가할 수 있는\n최소 피해량이 증가합니다."
			set STAT_TYPE_DESCRIPTION[STAT_TYPE_EVASION]		= "해당 수치에 비례해 적에게 받을 수 있는\n최소 피해량이 감소합니다."
			set STAT_TYPE_DESCRIPTION[STAT_TYPE_ARMOR_PENET]	= "물리피해를 가할 때 해당 수치만큼\n대상의 방어력을 무시합니다."
			set STAT_TYPE_DESCRIPTION[STAT_TYPE_MAGIC_PENET]	= "마법피해를 가할 때 해당 수치만큼\n대상의 저항력을 무시합니다."
			set STAT_TYPE_DESCRIPTION[STAT_TYPE_SPELL_BOOST]	= "해당 수치에 비례해 기술의 재사용 대기시간이 감소합니다."
			set STAT_TYPE_DESCRIPTION[STAT_TYPE_HEAL_AMP]		= "현재 받는 회복량을 나타냅니다."
			set STAT_TYPE_DESCRIPTION[STAT_TYPE_MOVEMENT_SPEED] = "초당 이동거리를 나타내며 실 적용 수치는 최대 522입니다."
			set STAT_TYPE_DESCRIPTION[STAT_TYPE_ATTACK_SPEED]	= "해당 수치가 높을 수록 공격 주기가 빨라집니다.\n일부 무기는 공격 주기가 해당 수치로 결정되지 않습니다."
			set STAT_TYPE_DESCRIPTION[STAT_TYPE_LUCK]			= "무슨 좋은 일이 일어날까요?"
			set STAT_TYPE_DESCRIPTION[STAT_TYPE_ATTACK_RANGE] 	= "현재 무기의 공격사거리를 나타냅니다."
			set STAT_TYPE_DESCRIPTION[STAT_TYPE_HPREGEN]		= "매 초 해당 수치만큼 체력을 회복합니다."
			set STAT_TYPE_DESCRIPTION[STAT_TYPE_MPREGEN]		= "매 초 해당 수치만큼 마나를 회복합니다."
		endmethod

	endstruct

endlibrary