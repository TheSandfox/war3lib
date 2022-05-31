library String

	globals
		private trigger KEYPRESS = CreateTrigger()
		constant string STRC_CONSTANT = "|cffffff00"
		constant string STRC_MAXHP = "|cff00ff00"
		constant string STRC_HPR = "|cffcc0000"
		constant string STRC_MAXMP = "|cff0099ff"
		constant string STRC_MPR = "|cff0099ff"
		constant string STRC_ATK = "|cffff9900"
		constant string STRC_DEF = "|cffcccccc"
		constant string STRC_MAG = "|cff9999ff"
		constant string STRC_RES = "|cff00ff99"
		constant string STRC_ACC = "|cffff00ff"
		constant string STRC_EVA = "|cff99ccff"
		constant string STRC_CD = "|cff00ffff"
		constant string STRC_CDR = "|cffff99ff"
		constant string STRC_MS = "|cffffff99"
		constant string STRC_AS = "|cffffff99"
		constant string STRC_LHP = "|cffcc0000"
		constant string STRC_EX = "|cff00ffff"
		constant string STRC_NEGATIVE = "|cff00ffff"
		constant string STRC_DISABLED = "|cff999999"
		constant string STRC_LUMBER = "|cff00cc00"
		constant string STRC_ABILLV = "|cffffff00"
		constant string STRC_HEROLV = "|cffffff00"
		constant string STR_LEVEL = STRC_CONSTANT + "레벨|r"
		constant string STR_ABILLV = STRC_ABILLV + "기술 레벨|r"
		constant string STR_HEROLV = STRC_HEROLV + "영웅 레벨|r"
		constant string STR_MAXHP = STRC_MAXHP + "최대체력|r"
		constant string STR_MAXMP = STRC_MAXMP + "최대마나|r"
		constant string STR_ATK = STRC_ATK + "공격력|r"
		constant string STR_DEF = STRC_DEF + "방어력|r"
		constant string STR_ACC = STRC_ACC + "정확도|r"
		constant string STR_EVA = STRC_EVA + "회피|r"
		constant string STR_MAG = STRC_MAG + "주문력|r"
		constant string STR_RES = STRC_RES + "저항력|r"
		constant string STR_CD = STRC_CD + "재사용 대기시간|r"
		constant string STR_MPCOST = STRC_CD + "마나비용|r"
		constant string STR_CDR = STRC_CDR + "주문가속|r"
		constant string STR_MCR = STRC_CDR + "통찰력|r"
		constant string STR_MS = STRC_MS + "이동속도|r"
		constant string STR_AS = STRC_AS + "공격속도|r"
		constant string STR_RANGE = STRC_AS + "사거리|r"
		constant string STR_HPR = STRC_LHP + "체력재생|r"
		constant string STR_MPR = STRC_MAXMP + "마나재생|r"
		constant string STR_PPEN = STRC_ATK + "방어관통|r"
		constant string STR_MPEN = STRC_MAG + "저항관통|r"
		constant string STR_BA = STRC_ATK + "기본공격|r"
		constant string STR_TA = STRC_MAG + "기술공격|r"
		constant string STR_PD = STRC_ATK + "물리피해|r"
		constant string STR_MD = STRC_MAG + "마법피해|r"
		constant string STR_HP = STRC_MAXHP + "체력|r"
		constant string STR_CHP = STRC_MAXHP + "현재체력|r"
		constant string STR_LHP = STRC_LHP + "잃은체력|r"
		constant string STR_MP = STRC_MAXMP + "마나|r"
		constant string STR_CMP = STRC_MAXMP + "현재마나|r"
		constant string STR_LMP = STRC_MAXMP + "잃은마나|r"
		constant string STR_BAVAMP = STRC_ATK + "흡혈|r"
		constant string STR_TAVAMP = STRC_MAG + "주문흡혈|r"
		constant string STR_HEALAMP = STRC_LHP + "받는 회복량|r"
		constant string STR_TARGET_TARGET = STRC_EX + "유닛 목표물|r\n\n"
		constant string STR_TARGET_LOCATION = STRC_EX + "지점 목표물|r\n\n"
		constant string STR_TARGET_NONE = STRC_EX + "즉시 사용|r\n\n"
		constant string STR_STATBONUS = STRC_EX + "속성 보너스|r - "
		constant string STR_PASSIVE = STRC_EX + "지속효과|r"
		constant string STR_ENSNARE = STRC_NEGATIVE + "속박|r"
		constant string STR_STUN = STRC_NEGATIVE + "기절|r"
		constant string STR_LUMBER = STRC_LUMBER + "목재|r"
		constant string STR_FIRE = STRC_ATK + "화염|r"
		constant string STR_IRON = STRC_DEF + "강철|r"
		constant string STR_DARK = STRC_ACC + "어둠|r"
		constant string STR_NATURE = STRC_RES + "자연|r"
		constant string STR_LIGHTNING = STRC_MAG + "번개|r"
		constant string STR_WIND = STRC_EVA + "바람|r"
		constant string STR_ARCANE = STRC_CDR + "신비|r"
		constant string STR_LIGHT = STRC_AS + "빛|r"
		constant string STR_WATER = STRC_MAXMP + "물|r"
		constant string ICON_FIRE = "ReplaceableTextures\\CommandButtons\\BTNOrbOfFire.blp"
		constant string ICON_LIGHTNING = "ReplaceableTextures\\CommandButtons\\BTNOrbOfLightning.blp"
		constant string ICON_IRON = "ReplaceableTextures\\CommandButtons\\BTNAdvStruct.blp"
		constant string ICON_NATURE = "ReplaceableTextures\\CommandButtons\\BTNStone.blp"
		constant string ICON_WATER = "ReplaceableTextures\\CommandButtons\\BTNEnchantedGemstone.blp"
		constant string ICON_DARK = "ReplaceableTextures\\CommandButtons\\BTNOrbOfDarkness.blp"
		constant string ICON_WIND = "ReplaceableTextures\\CommandButtons\\BTNRune.blp"
		constant string ICON_ARCANE = "ReplaceableTextures\\CommandButtons\\BTNHeartOfAszune.blp"
		constant string ICON_LIGHT = "ReplaceableTextures\\CommandButtons\\BTNHolyBolt.blp"
	endglobals
	
	struct String

		static boolean array DETAIL[PLAYER_MAX]
	
		static method statBonus takes string head, integer base, integer perlevel returns string
			return head + STRC_CONSTANT + " +" + I2S(base) + " (+기술 레벨 당 " + I2S(perlevel) +")|r\n"
		endmethod
	
		static method percent takes real v returns string
			return I2S(R2I(v*100)) + "%"
		endmethod
	
		static method second takes real v returns string
			if v == R2I(v) then
				return I2S(R2I(v))
			else
				return R2SW(v,1,2)
			endif
		endmethod
	
		static method extraValue takes string title, string s returns string
			return "\n\n"+STRC_EX+title+"|r - "+STRC_CONSTANT+s+"|R"
		endmethod
	
		static method const takes string s returns string
			return STRC_CONSTANT + s +"|r"
		endmethod
	
		static method disabled takes string s returns string
			return STRC_DISABLED + s +"|r"
		endmethod
	
		static method attack takes string s returns string
			return STRC_ATK + s +"|r"
		endmethod
	
		static method magicPower takes string s returns string
			return STRC_MAG + s +"|r"
		endmethod  
	
		static method r2IS takes real v returns string
			return I2S(R2I(v))
		endmethod
	
		static method sign takes real v returns string
			if v > 0 then
				return "|cff00ff00+"+R2SW(v,1,1)+"|r"
			elseif v < -0.01 then
				return "|cffff0000-"+R2SW(RAbsBJ(v),1,1)+"|r"
			else
				return "|cffffffff+"+R2SW(RAbsBJ(v),1,1)+"|r"
			endif
		endmethod
	
		static method attackBonus takes integer v returns string
			return STR_ATK+String.const(" + "+I2S(v)+" ")
		endmethod
	
		static method deffenceBonus takes integer v returns string
			return STR_DEF+String.const(" + "+I2S(v)+" ")
		endmethod
	
		static method magicPowerBonus takes integer v returns string
			return STR_MAG+String.const(" + "+I2S(v)+" ")
		endmethod
	
		static method resistBonus takes integer v returns string
			return STR_RES+String.const(" + "+I2S(v)+" ")
		endmethod
	
		static method accBonus takes integer v returns string
			return STR_ACC+String.const(" + "+I2S(v)+" ")
		endmethod
	
		static method evaBonus takes integer v returns string
			return STR_EVA+String.const(" + "+I2S(v)+" ")
		endmethod
	
		static method aSBonus takes real v returns string
			return STR_AS+String.const(" + "+String.percent(v)+" ")
		endmethod
	
		static method mSBonus takes integer v returns string
			return STR_MS+String.const(" + "+I2S(v)+" ")
		endmethod
	
		static method maxHPBonus takes integer v returns string
			return STR_MAXHP+String.const(" + "+I2S(v)+" ")
		endmethod
	
		static method maxMPBonus takes integer v returns string
			return STR_MAXMP+String.const(" + "+I2S(v)+" ")
		endmethod
	
		static method pPenBonus takes real v returns string
			return STR_PPEN+String.const(" + "+R2SW(v,1,1)+" ")
		endmethod
	
		static method mPenBonus takes real v returns string
			return STR_MPEN+String.const(" + "+R2SW(v,1,1)+" ")
		endmethod
	
		static method hPRBonus takes real v returns string
			return STR_HPR+String.const(" + "+R2SW(v,1,1)+" ")
		endmethod
	
		static method mPRBonus takes real v returns string
			return STR_MPR+String.const(" + "+R2SW(v,1,1)+" ")
		endmethod
	
		static method cDRBonus takes integer v returns string
			return STR_CDR+String.const(" + "+I2S(v)+" ")
		endmethod
	
		static method mCRBonus takes integer v returns string
			return STR_MCR+String.const(" + "+I2S(v)+" ")
		endmethod

		//! runtextmacro stringValue("attack","ATK")
		//! runtextmacro stringValue("deffence","DEF")
		//! runtextmacro stringValue("magicPower","MAG")
		//! runtextmacro stringValue("resist","RES")
		//! runtextmacro stringValue("acc","ACC")
		//! runtextmacro stringValue("eva","EVA")
		//! runtextmacro stringValue("mS","MS")
		//! runtextmacro stringValue("aS","AS")
		//! runtextmacro stringValue("abilityLevel","ABILLV")
		//! runtextmacro stringValue("heroLevel","HEROLV")
		//! runtextmacro stringValue("maxHP","MAXHP")
		//! runtextmacro stringValue("maxMP","MAXMP")
		//! runtextmacro stringValue("hPR","HPR")
		//! runtextmacro stringValue("mPR","MPR")
	
		private static method setDetail takes nothing returns nothing
			set DETAIL[GetPlayerId(GetTriggerPlayer())] = BlzGetTriggerPlayerIsKeyDown()
		endmethod
	
		private static method onInit takes nothing returns nothing
			local integer i = 0
			loop
				exitwhen i >= PLAYER_MAX
				set DETAIL[i] = false
				call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS,Player(0),OSKEY_V,0,true)
				call BlzTriggerRegisterPlayerKeyEvent(KEYPRESS,Player(0),OSKEY_V,0,false)
				set i = i + 1
			endloop
			call TriggerAddAction(KEYPRESS,function thistype.setDetail)
		endmethod

	endstruct

endlibrary

	//! textmacro stringValue takes key, const
	static method $key$Value takes player p, real v returns string
		if DETAIL[GetPlayerId(p)] then
			return STRC_$const$+R2SW(v,2,2)+"(|r"+STR_$const$+STRC_$const$+"▲)|r"
		else
			return STRC_$const$+I2S(R2I(v))+"|r"
		endif
	endmethod
	//! endtextmacro