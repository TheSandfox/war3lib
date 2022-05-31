library SkillShop requires UI

	globals
		integer array CHANCE_TIER1
		integer array CHANCE_TIER2
		integer array CHANCE_TIER3
		integer array CHANCE_TIER4
		integer array CHANCE_TIER5
		integer array CHANCE_TOTAL
		constant integer CHANCE_LEVEL_MAX = 11
		private integer array MAX_EXP
		constant integer LEVEL_MAX = 11
	endglobals

	struct SkillShopWidget extends IconFrame

		integer id = 0
		trigger btn_trigger = null
		triggercondition btn_cond = null
		framehandle container = null
		framehandle icon = null
		framehandle name = null
		framehandle tag = null
		framehandle btn = null
		framehandle bonus_stat1 = null
		framehandle bonus_stat2 = null

		method setTarget takes integer id returns nothing
			local integer i = 0
			local string s = ""
			set .id = id
			call BlzFrameSetEnable(.btn,id > 0)
			call BlzFrameSetVisible(BlzGetFrameByName("SkillShopBuyButtonIcon",this),id > 0)
			call BlzFrameSetVisible(.bonus_stat1,id > 0)
			call BlzFrameSetVisible(.bonus_stat2,id > 0)
			if id <= 0 then		/*빈칸*/
				call BlzFrameSetTexture(.icon,"ReplaceableTextures\\CommandButtons\\BTNBlackIcon.blp",0,true)
				call BlzFrameSetText(.name,"")
				call BlzFrameSetText(.tag,"")
				call BlzFrameSetPoint(BlzGetFrameByName("SkillShopBuyButtonText",this),FRAMEPOINT_CENTER,.btn,FRAMEPOINT_CENTER,0.,0.)
				call BlzFrameSetText(BlzGetFrameByName("SkillShopBuyButtonText",this),"|c99999999판매됨|r")
			else	/*그 외*/
				call BlzFrameSetTexture(.icon,"ReplaceableTextures\\CommandButtons\\"+Ability.getTypeIconPath(id)+".blp",0,true)
				/*어빌리티 이름*/
				call BlzFrameSetText(.name,TIER_STRING_COLOR[Ability.getTypeTier(id)]+Ability.getTypeName(id)+"|r")
				/*어빌리티태그*/
				set i = 1
				loop
					exitwhen Ability.getTypeTag(id,i) == ""
					if i <= 1 then
						set s = s + Ability.getTypeTag(id,i)
					else
						set s = s + ", " + Ability.getTypeTag(id,i)
					endif
					set i = i + 1
				endloop
				/*간이툴팁*/
				set s = s + "\n\n"+Ability.getTypeTooltip(id)
				/*능력치보너스*/
				set s = s + "\n\n|cff00ffff능력치 보너스 :|r"
				call BlzFrameSetText(.tag,s)
				call BlzFrameSetTexture(.bonus_stat1,STAT_TYPE_ICON[Ability.getTypeBonusStatIndex(id,0)],0,true)
				call BlzFrameSetTexture(.bonus_stat2,STAT_TYPE_ICON[Ability.getTypeBonusStatIndex(id,1)],0,true)
				/*구매버튼*/
				call BlzFrameSetPoint(BlzGetFrameByName("SkillShopBuyButtonText",this),FRAMEPOINT_CENTER,.btn,FRAMEPOINT_CENTER,Math.px2Size(12),0.)
				call BlzFrameSetText(BlzGetFrameByName("SkillShopBuyButtonText",this),"|cffffcc00"+I2S(Ability.getTypeCost(id))+"|r")
			endif
		endmethod

		static method press takes nothing returns nothing
			local player p = GetTriggerPlayer()
			local thistype this = Trigger.getData(GetTriggeringTrigger())
			local Ability i = 0
			local integer ti = 0
			call BlzFrameSetEnable(BlzGetTriggerFrame(),false)
			call BlzFrameSetEnable(BlzGetTriggerFrame(),.id > 0)
			/*클릭 시 스킬 구매*/
			if BlzGetTriggerFrameEvent() == FRAMEEVENT_CONTROL_CLICK then
				/*소지금 검사*/
				if User.getGold(p) >= Ability.getTypeCost(.id) then
					set i = User.getFocusUnit(p).addAbility(.id)
					set ti = i
					/*자리가 있으면*/
					if ti > -1 then
						/*장착중인 무기가 없으면 배운 능력으로*/
						if Ability.getTypeTag(i.id,0) == ABILITY_STRING_WEAPON then
							if i.level == 1 and i.owner.weapon_ability == 0 then
								call i.owner.setWeaponAbility(i)
							endif
						endif
						/*빈 슬롯으로 만들어 주기 전에 골드 차감*/
						call User.addGold(p,-1*Ability.getTypeCost(.id))
						/*빈 슬롯으로 만든 후 리프레시*/
						call setTarget(0)
						call UI.THIS[GetPlayerId(p)].refreshAbilityIconsTarget()
						call SlotChanger.THIS[GetPlayerId(p)].stateDefault()
					/*자리가 없으면*/
					else
						set ERROR_MESSAGE = "더이상 능력을 배울 수 없습니다."
						set ERROR_MESSAGE_PLAYER = p
						call TriggerEvaluate(ERROR_MESSAGE_TRIGGER)
						if GetLocalPlayer() == p then
							call PlaySoundBJ(gg_snd_Error)
						endif
					endif
				/*돈 부족하면*/
				else
					set ERROR_MESSAGE = "금화가 부족합니다."
					set ERROR_MESSAGE_PLAYER = p
					call TriggerEvaluate(ERROR_MESSAGE_TRIGGER)
					if GetLocalPlayer() == p then
						call PlaySoundBJ(gg_snd_Error)
					endif
				endif
			endif
		endmethod

		static method create takes framehandle parent, integer index returns thistype
			local thistype this = allocate()
			set .container = BlzCreateFrameByType("BACKDROP","",parent,"",0)
			call BlzFrameSetPoint(.container,FRAMEPOINT_TOPLEFT,FRAME_SKILL_SHOP,FRAMEPOINT_TOPLEFT,index*BlzFrameGetWidth(FRAME_SKILL_SHOP)/5,0.)
			call BlzFrameSetSize(.container,BlzFrameGetWidth(FRAME_SKILL_SHOP)/5,BlzFrameGetHeight(FRAME_SKILL_SHOP))
			call BlzFrameSetTexture(.container,"Textures\\black32.blp",0,true)
			set .icon = BlzCreateFrameByType("BACKDROP","",.container,"",0)
			call BlzFrameSetPoint(.icon,FRAMEPOINT_TOP,.container,FRAMEPOINT_TOP,0.,-0.01)
			call BlzFrameSetSize(.icon,Math.px2Size(96),Math.px2Size(96))
			set .name = BlzCreateFrame("MyTextLarge",.container,0,0)
			call BlzFrameSetPoint(.name,FRAMEPOINT_TOP,.icon,FRAMEPOINT_BOTTOM,0.,-0.005)
			call BlzFrameSetTextAlignment(.name,TEXT_JUSTIFY_TOP,TEXT_JUSTIFY_CENTER)
			call BlzFrameSetText(.name,"어빌리티 이름")
			set .tag = BlzCreateFrame("MyText",.container,0,0)
			call BlzFrameSetPoint(.tag,FRAMEPOINT_TOP,.name,FRAMEPOINT_BOTTOM,0.,-0.005)
			call BlzFrameSetTextAlignment(.tag,TEXT_JUSTIFY_TOP,TEXT_JUSTIFY_CENTER)
			call BlzFrameSetText(.tag,"|cffffff00어빌리티 태그|r")
			set .btn = BlzCreateFrame("SkillShopBuyButton",.container,0,this)
			call BlzFrameSetPoint(.btn,FRAMEPOINT_BOTTOM,.container,FRAMEPOINT_BOTTOM,0.,0.005)
			call BlzFrameSetSize(.btn,BlzFrameGetWidth(FRAME_SKILL_SHOP)/5-0.02,0.025)
			call BlzFrameClearAllPoints(BlzGetFrameByName("SkillShopBuyButtonText",this))
			call BlzFrameSetPoint(BlzGetFrameByName("SkillShopBuyButtonText",this),FRAMEPOINT_CENTER,.btn,FRAMEPOINT_CENTER,Math.px2Size(12),0.)
			call BlzFrameSetTextAlignment(BlzGetFrameByName("SkillShopBuyButtonText",this),TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
			call BlzFrameSetTexture(BlzGetFrameByName("SkillShopBuyButtonIcon",this),"ui\\widgets\\tooltips\\human\\tooltipgoldicon.blp",0,true)
			call BlzFrameSetPoint(BlzGetFrameByName("SkillShopBuyButtonIcon",this),FRAMEPOINT_RIGHT,BlzGetFrameByName("SkillShopBuyButtonText",this),FRAMEPOINT_LEFT,-0.005,0.)
			call BlzFrameSetSize(BlzGetFrameByName("SkillShopBuyButtonIcon",this),Math.px2Size(24),Math.px2Size(24))
			/*스탯 보너스 아이콘*/
			set .bonus_stat1 = BlzCreateFrameByType("BACKDROP","",.container,"",0)
			call BlzFrameSetPoint(.bonus_stat1,FRAMEPOINT_BOTTOMRIGHT,.btn,FRAMEPOINT_TOP,-0.005,0.0025)
			call BlzFrameSetSize(.bonus_stat1,Math.px2Size(32),Math.px2Size(32))
			set .bonus_stat2 = BlzCreateFrameByType("BACKDROP","",.container,"",0)
			call BlzFrameSetPoint(.bonus_stat2,FRAMEPOINT_BOTTOMLEFT,.btn,FRAMEPOINT_TOP,0.005,0.0025)
			call BlzFrameSetSize(.bonus_stat2,Math.px2Size(32),Math.px2Size(32))
			set .btn_trigger = Trigger.new(this)
			call BlzTriggerRegisterFrameEvent(.btn_trigger,.btn,FRAMEEVENT_CONTROL_CLICK)
			call BlzTriggerRegisterFrameEvent(.btn_trigger,.btn,FRAMEEVENT_MOUSE_LEAVE)
			set .btn_cond = TriggerAddCondition(.btn_trigger,function thistype.press)
			/**/
			call setTarget('0000')
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			//! runtextmacro destroyFrame(".container")
			//! runtextmacro destroyFrame(".icon")
			//! runtextmacro destroyFrame(".name")
			//! runtextmacro destroyFrame(".tag")
			//! runtextmacro destroyFrame(".btn")
			//! runtextmacro destroyFrame(".bonus_stat1")
			//! runtextmacro destroyFrame(".bonus_stat2")
			call TriggerRemoveCondition(.btn_trigger,.btn_cond)
			call Trigger.remove(.btn_trigger)
			set .btn_trigger = null
			set .btn_cond = null
		endmethod

	endstruct

	struct SkillShop extends Closeable

		static constant real EXP_GAUGE_WIDTH = 256-4-32-32	/*아웃라인 말고 내부게이지 기준*/

		integer level = 1
		integer exp = 0
		integer exp_max = 2

		trigger keypress = null
		triggercondition keypress_cond = null
		player owner = null
		framehandle container = null
		framehandle btn_refresh = null
		framehandle btn_autorefresh = null
		framehandle btn_donate = null
		framehandle exp_outline = null
		framehandle exp_backdrop = null
		framehandle exp_fill = null
		framehandle exp_text = null
		framehandle level_backdrop = null
		framehandle level_text = null
		framehandle autorefresh_text_backdrop = null
		framehandle autorefresh_text = null
		framehandle gold_backdrop = null
		framehandle gold_icon = null
		framehandle gold_text = null
		framehandle chance_backdrop = null
		framehandle chance_text = null
		boolean autorefresh = true
		integer autorefresh_time = ROUND_TIME_INITIAL+ROUND_TIME
		integer autorefresh_time_max = ROUND_TIME
		implement ThisUI

		boolean visible_flag = false

		method carculatedTier takes nothing returns integer
			local integer r = 0
			local integer i = 0
			local integer current_chance = 0
			if .level >= 1 and .level <= CHANCE_LEVEL_MAX then
				set r = GetRandomInt(1,CHANCE_TOTAL[.level])
				/**/
				set current_chance = current_chance + CHANCE_TIER1[.level]
				if r <= current_chance then
					return 1
				endif
				set current_chance = current_chance + CHANCE_TIER2[.level]
				if r <= current_chance then
					return 2
				endif
				set current_chance = current_chance + CHANCE_TIER3[.level]
				if r <= current_chance then
					return 3
				endif
				set current_chance = current_chance + CHANCE_TIER4[.level]
				if r <= current_chance then
					return 4
				endif
				set current_chance = current_chance + CHANCE_TIER5[.level]
				if r <= current_chance then
					return 5
				endif
			endif
			return 0
		endmethod

		method refreshChanceText takes nothing returns nothing
			/*확률정보*/
			call BlzFrameSetText(.chance_text,TIER_STRING_COLOR[1]+I2S(R2I(getTierChance(.level,1)*100/CHANCE_TOTAL[.level]))+"%|r    "+/*
			*/TIER_STRING_COLOR[2]+I2S(R2I(getTierChance(.level,2)*100/CHANCE_TOTAL[.level]))+"%|r    "+/*
			*/TIER_STRING_COLOR[3]+I2S(R2I(getTierChance(.level,3)*100/CHANCE_TOTAL[.level]))+"%|r    "+/*
			*/TIER_STRING_COLOR[4]+I2S(R2I(getTierChance(.level,4)*100/CHANCE_TOTAL[.level]))+"%|r    "+/*
			*/TIER_STRING_COLOR[5]+I2S(R2I(getTierChance(.level,5)*100/CHANCE_TOTAL[.level]))+"%|r"/*
			*/)
		endmethod

		method refreshLevelState takes nothing returns nothing
			if .level >= LEVEL_MAX then
				call BlzFrameSetVisible(.exp_fill,true)
				call BlzFrameSetText(.level_text,I2S(LEVEL_MAX))
				call BlzFrameSetText(.exp_text,"MAX")
				call BlzFrameSetPointPixel(.exp_fill,FRAMEPOINT_TOPRIGHT,.exp_backdrop,FRAMEPOINT_TOPRIGHT,0.,0.)
			else
				call BlzFrameSetVisible(.exp_fill,.exp > 0)
				call BlzFrameSetText(.level_text,I2S(.level))
				call BlzFrameSetText(.exp_text,I2S(.exp)+" / "+I2S(.exp_max))
				call BlzFrameSetPointPixel(.exp_fill,FRAMEPOINT_TOPRIGHT,.exp_backdrop,FRAMEPOINT_TOPLEFT,EXP_GAUGE_WIDTH*(I2R(.exp)/I2R(.exp_max)),0.)
			endif
		endmethod

		method setLevel takes integer nv returns nothing
			set .level = nv
			set .exp_max = MAX_EXP[.level]
			call BlzFrameSetVisible(.btn_donate,.level > 1)
			call BlzFrameSetVisible(.btn_refresh,.level > 1)
			call refreshChanceText()
		endmethod

		method addExp takes integer v returns nothing
			set .exp = .exp + v
			loop
				exitwhen .exp < .exp_max or .level == LEVEL_MAX
				if .exp >= .exp_max then
					set .exp = .exp - .exp_max
					call setLevel(.level+1)
				endif
			endloop
			call refreshLevelState()
		endmethod

		static method addLevel takes nothing returns nothing
			local integer i = 0
			loop
				exitwhen i >= PLAYER_MAX
				if THIS[i] > 0 then
					call THIS[i].addExp(2)
				endif
				set i = i + 1
			endloop
		endmethod

		method refreshGold takes nothing returns nothing
			call BlzFrameSetText(.gold_text,"|cffffcc00"+I2S(User.getGold(.owner))+"|r")
		endmethod

		method visibleForPlayer takes boolean flag returns nothing
			set .visible_flag = flag
			if GetLocalPlayer()==.owner then
				call BlzFrameSetVisible(FRAME_SKILL_SHOP_BACKDROP,flag)
			endif
			if .visible_flag then
				call refreshChanceText()
			endif
		endmethod

		method close takes nothing returns boolean
			if .visible_flag then
				call visibleForPlayer(false)
				return true
			else
				return false
			endif
		endmethod

		method isWidgetEmpty takes nothing returns boolean
			local integer i = 0
			local SkillShopWidget sw = 0
			loop
				exitwhen i >= 5
				set sw = UI.getObject(this,UI.INDEX_SKILL_SHOP_WIDGET+i)
				if sw.id > 0 then
					return false
				endif
				set i = i + 1
			endloop
			return true
		endmethod

		method refreshAutoRefresh takes nothing returns nothing
			local string s = "|cffffcc00자동 새로고침|r|cffffffff :|r "
			local integer minitue = .autorefresh_time / 60
			local string second = ""
			if .autorefresh_time - 60*minitue >= 10 then
				set second = I2S(.autorefresh_time - 60*minitue)
			else
				set second = "0"+I2S(.autorefresh_time - 60*minitue)
			endif
			if .autorefresh then
				set s = s + "|cff00ff00활성화|r"
			else
				set s = s + "|cff999999비활성화|r"
			endif
			call BlzFrameSetText(BlzGetFrameByName("SkillShopAutoRefreshButtonText",this),s)
			call BlzFrameSetText(.autorefresh_text,I2S(minitue)+":"+second)
		endmethod

		method setAutoRefreshState takes boolean flag returns nothing
			set .autorefresh = flag
		endmethod

		method refresh takes nothing returns nothing
			local SkillShopWidget sw = 0
			local integer i = 0
			loop
				exitwhen i >= 5
				set sw = UI.getObject(this,UI.INDEX_SKILL_SHOP_WIDGET+i)
				call sw.setTarget(Ability.getRandomAbility(carculatedTier()))
				set i = i + 1
			endloop
			call refreshChanceText()
			call refreshLevelState()
		endmethod

		static method press takes nothing returns nothing
			local thistype this = Trigger.getData(GetTriggeringTrigger())
			if BlzGetTriggerPlayerKey() == OSKEY_T then
				call visibleForPlayer(not .visible_flag)
			elseif BlzGetTriggerFrame() != null then
				call BlzFrameSetEnable(BlzGetTriggerFrame(),false)
				call BlzFrameSetEnable(BlzGetTriggerFrame(),true)
				if BlzGetTriggerFrameEvent() == FRAMEEVENT_CONTROL_CLICK then
					/*리롤 버튼 클릭 시*/
					if BlzGetTriggerFrame() == .btn_refresh then
						if User.getGold(.owner) >= 2 then
							call refresh()
							call setAutoRefreshState(true)
							call refreshAutoRefresh()
							call User.addGold(.owner,-2)
						/*돈 부족하면*/
						else
							set ERROR_MESSAGE = "금화가 부족합니다."
							set ERROR_MESSAGE_PLAYER = .owner
							call TriggerEvaluate(ERROR_MESSAGE_TRIGGER)
							if GetLocalPlayer() == .owner then
								call PlaySoundBJ(gg_snd_Error)
							endif
						endif
						return
					/*자동리롤 활성화*/
					elseif BlzGetTriggerFrame() == .btn_autorefresh then
						call setAutoRefreshState(not autorefresh)
						call refreshAutoRefresh()
						return
					elseif BlzGetTriggerFrame() == .btn_donate then
						/*TODO donate*/
						if User.getGold(.owner) >= 4 and .level < LEVEL_MAX then
							call addExp(4)
							call User.addGold(.owner,-4)
						/*상점 레벨업 골드 부족*/
						elseif User.getGold(.owner) < 4 then
							set ERROR_MESSAGE = "금화가 부족합니다."
							set ERROR_MESSAGE_PLAYER = .owner
							call TriggerEvaluate(ERROR_MESSAGE_TRIGGER)
							if GetLocalPlayer() == .owner then
								call PlaySoundBJ(gg_snd_Error)
							endif
						/*상점 레벨업 이미 최대레벨*/
						elseif .level >= LEVEL_MAX then
							set ERROR_MESSAGE = "더 이상 기부할 수 없습니다."
							set ERROR_MESSAGE_PLAYER = .owner
							call TriggerEvaluate(ERROR_MESSAGE_TRIGGER)
							if GetLocalPlayer() == .owner then
								call PlaySoundBJ(gg_snd_Error)
							endif
						endif
						return
					endif
				endif
			else
				/*PERIODIC*/
				set .autorefresh_time = .autorefresh_time - 1
				if .autorefresh_time <= 0 then
					if .autorefresh or isWidgetEmpty() then
						call refresh()
						call setAutoRefreshState(true)
					endif
					set .autorefresh_time = .autorefresh_time_max
				endif
				call refreshAutoRefresh()
			endif
		endmethod

		static method create takes player p returns thistype
			local thistype this = allocate()
			local integer i = 0
			set .owner = p
			set .container = BlzCreateFrameByType("FRAME","",FRAME_SKILL_SHOP_BACKDROP,"",0)
			call BlzFrameSetPoint(.container,FRAMEPOINT_TOPLEFT,FRAME_SKILL_SHOP,FRAMEPOINT_TOPLEFT,0.,0.)
			/*스킬위젯*/
			loop
				exitwhen i >= 5
				call UI.setObject(this,UI.INDEX_SKILL_SHOP_WIDGET+i,SkillShopWidget.create(.container,i))
				set i = i + 1
			endloop
			/*자동갱신 활성화*/
			set .btn_autorefresh = BlzCreateFrame("SkillShopAutoRefreshButton",.container,0,this)
			call BlzFrameSetPoint(.btn_autorefresh,FRAMEPOINT_TOPRIGHT,FRAME_SKILL_SHOP_BACKDROP,FRAMEPOINT_BOTTOMRIGHT,0.,0.)
			call BlzFrameSetSizePixel(.btn_autorefresh,240,56)
			call BlzFrameClearAllPoints(BlzGetFrameByName("SkillShopAutoRefreshButtonText",this))
			call BlzFrameSetPoint(BlzGetFrameByName("SkillShopAutoRefreshButtonText",this),FRAMEPOINT_CENTER,.btn_autorefresh,FRAMEPOINT_CENTER,0.,0.)
			call BlzFrameSetTextAlignment(BlzGetFrameByName("SkillShopAutoRefreshButtonText",this),TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
			call refreshAutoRefresh()
			set .autorefresh_text_backdrop = BlzCreateFrame("MyTextBox",.btn_autorefresh,0,0)
			call BlzFrameSetPoint(.autorefresh_text_backdrop,FRAMEPOINT_BOTTOM,.btn_autorefresh,FRAMEPOINT_TOP,0.,-0.0025)
			call BlzFrameSetSize(.autorefresh_text_backdrop,0.045,0.015)
			set .autorefresh_text = BlzCreateFrame("MyText",.autorefresh_text_backdrop,0,0)
			call BlzFrameSetPoint(.autorefresh_text,FRAMEPOINT_CENTER,.autorefresh_text_backdrop,FRAMEPOINT_CENTER,0,0)
			call BlzFrameSetTextAlignment(.autorefresh_text,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
			/*리프레시버튼*/
			set .btn_refresh = BlzCreateFrame("SkillShopRefreshButton",.container,0,this)
			call BlzFrameSetPoint(.btn_refresh,FRAMEPOINT_TOPRIGHT,.btn_autorefresh,FRAMEPOINT_TOPLEFT,0.,0.)
			call BlzFrameSetSizePixel(.btn_refresh,240,56)
			call BlzFrameClearAllPoints(BlzGetFrameByName("SkillShopRefreshButtonText",this))
			call BlzFrameSetPoint(BlzGetFrameByName("SkillShopRefreshButtonText",this),FRAMEPOINT_CENTER,.btn_refresh,FRAMEPOINT_CENTER,Math.px2Size(12),0.)
			call BlzFrameSetTextAlignment(BlzGetFrameByName("SkillShopRefreshButtonText",this),TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
			call BlzFrameSetText(BlzGetFrameByName("SkillShopRefreshButtonText",this),"|cffffcc002|r |cffffffff: 즉시 새로고침|r")
			call BlzFrameSetTexture(BlzGetFrameByName("SkillShopRefreshButtonIcon",this),"ui\\widgets\\tooltips\\human\\tooltipgoldicon.blp",0,true)
			call BlzFrameSetPoint(BlzGetFrameByName("SkillShopRefreshButtonIcon",this),FRAMEPOINT_RIGHT,BlzGetFrameByName("SkillShopRefreshButtonText",this),FRAMEPOINT_LEFT,-0.005,0.)
			call BlzFrameSetSize(BlzGetFrameByName("SkillShopRefreshButtonIcon",this),Math.px2Size(24),Math.px2Size(24))
			/*도네이션*/
			set .btn_donate = BlzCreateFrame("SkillShopDonateButton",.container,0,this)
			call BlzFrameSetPoint(.btn_donate,FRAMEPOINT_TOPLEFT,FRAME_SKILL_SHOP_BACKDROP,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			call BlzFrameSetSizePixel(.btn_donate,256,56)
			call BlzFrameClearAllPoints(BlzGetFrameByName("SkillShopDonateButtonText",this))
			call BlzFrameSetPoint(BlzGetFrameByName("SkillShopDonateButtonText",this),FRAMEPOINT_CENTER,.btn_donate,FRAMEPOINT_CENTER,Math.px2Size(12),0.)
			call BlzFrameSetTextAlignment(BlzGetFrameByName("SkillShopDonateButtonText",this),TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
			call BlzFrameSetText(BlzGetFrameByName("SkillShopDonateButtonText",this),"|cffffcc004|r |cffffffff: 기부하기 (품질 상승)|r")
			call BlzFrameSetTexture(BlzGetFrameByName("SkillShopDonateButtonIcon",this),"ui\\widgets\\tooltips\\human\\tooltipgoldicon.blp",0,true)
			call BlzFrameSetPoint(BlzGetFrameByName("SkillShopDonateButtonIcon",this),FRAMEPOINT_RIGHT,BlzGetFrameByName("SkillShopDonateButtonText",this),FRAMEPOINT_LEFT,-0.005,0.)
			call BlzFrameSetSize(BlzGetFrameByName("SkillShopDonateButtonIcon",this),Math.px2Size(24),Math.px2Size(24))
			/*상점경험치*/
			set .exp_outline = BlzCreateFrameByType("BACKDROP","",.btn_donate,"",0)
			call BlzFrameSetTexture(.exp_outline,"replaceabletextures\\teamcolor\\teamcolor16.blp",0,true)
			set .exp_backdrop = BlzCreateFrameByType("BACKDROP","",.btn_donate,"",0)
			call BlzFrameSetPointPixel(.exp_backdrop,FRAMEPOINT_BOTTOMLEFT,.btn_donate,FRAMEPOINT_TOPLEFT,2+32,2)
			call BlzFrameSetSizePixel(.exp_backdrop,EXP_GAUGE_WIDTH,16-4)
			call BlzFrameSetTexture(.exp_backdrop,"replaceabletextures\\teamcolor\\teamcolor26.blp",0,true)
			call BlzFrameSetAlpha(.exp_backdrop,200)
			set .exp_fill = BlzCreateFrameByType("BACKDROP","",.btn_donate,"",0)
			call BlzFrameSetPoint(.exp_fill,FRAMEPOINT_BOTTOMLEFT,.exp_backdrop,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			call BlzFrameSetTexture(.exp_fill,"replaceabletextures\\teamcolor\\teamcolor23.blp",0,true)
			call BlzFrameSetVisible(.exp_fill,false)
			set .exp_text = BlzCreateFrame("MyText",.btn_donate,0,0)
			call BlzFrameSetPoint(.exp_text,FRAMEPOINT_CENTER,.exp_backdrop,FRAMEPOINT_CENTER,0.,0.)
			call BlzFrameSetPointPixel(.exp_outline,FRAMEPOINT_TOPLEFT,.exp_backdrop,FRAMEPOINT_TOPLEFT,-2,2)
			call BlzFrameSetPointPixel(.exp_outline,FRAMEPOINT_BOTTOMRIGHT,.exp_backdrop,FRAMEPOINT_BOTTOMRIGHT,2,-2)
			set .level_backdrop = BlzCreateFrameByType("BACKDROP","",.btn_donate,"",0)
			call BlzFrameSetSizePixel(.level_backdrop,32,32)
			call BlzFrameSetPoint(.level_backdrop,FRAMEPOINT_BOTTOMRIGHT,.exp_outline,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			call BlzFrameSetTexture(.level_backdrop,"ui\\console\\human\\human-transport-slot.blp",0,true)
			set .level_text = BlzCreateFrame("MyText",.btn_donate,0,0)
			call BlzFrameSetPoint(.level_text,FRAMEPOINT_CENTER,.level_backdrop,FRAMEPOINT_CENTER,0.,0.)
			call BlzFrameSetTextAlignment(.level_text,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
			/*소지금*/
			set .gold_backdrop = BlzCreateFrameByType("BACKDROP","",.container,"",0)
			call BlzFrameSetTexture(.gold_backdrop,"Textures\\black32.blp",0,true)
			call BlzFrameSetAlpha(.gold_backdrop,128)
			set .gold_text = BlzCreateFrame("MyTextLarge",.container,0,0)
			call BlzFrameSetPoint(.gold_text,FRAMEPOINT_TOP,FRAME_SKILL_SHOP_BACKDROP,FRAMEPOINT_BOTTOM,0.0025+Math.px2Size(16),-0.005)
			call BlzFrameSetTextAlignment(.gold_text,TEXT_JUSTIFY_TOP,TEXT_JUSTIFY_CENTER)
			call BlzFrameSetText(.gold_text,"|cffffcc00"+I2S(User.getGold(.owner))+"|r")
			set .gold_icon = BlzCreateFrameByType("BACKDROP","",.container,"",0)
			call BlzFrameSetTexture(.gold_icon,"ui\\widgets\\tooltips\\human\\tooltipgoldicon.blp",0,true)
			call BlzFrameSetPoint(.gold_icon,FRAMEPOINT_RIGHT,.gold_text,FRAMEPOINT_LEFT,-0.005,0.)
			call BlzFrameSetSize(.gold_icon,Math.px2Size(32),Math.px2Size(32))
			/*setPoint*/
			call BlzFrameSetPoint(.gold_backdrop,FRAMEPOINT_TOPRIGHT,.gold_text,FRAMEPOINT_TOPRIGHT,0.005,0.005)
			call BlzFrameSetPoint(.gold_backdrop,FRAMEPOINT_BOTTOMLEFT,.gold_text,FRAMEPOINT_BOTTOMLEFT,-0.005-0.005-Math.px2Size(32),-0.005)
			/*확률정보*/
			set .chance_backdrop = BlzCreateFrame("MyTextBox",.btn_donate,0,0)
			set .chance_text = BlzCreateFrame("MyTextSmall",.btn_donate,0,0)
			call BlzFrameSetPoint(.chance_text,FRAMEPOINT_LEFT,.btn_donate,FRAMEPOINT_RIGHT,0.005+Math.px2Size(16),0.)
			call BlzFrameSetPoint(.chance_backdrop,FRAMEPOINT_TOPLEFT,.chance_text,FRAMEPOINT_TOPLEFT,-0.005,0.005)
			call BlzFrameSetPoint(.chance_backdrop,FRAMEPOINT_BOTTOMRIGHT,.chance_text,FRAMEPOINT_BOTTOMRIGHT,0.005,-0.005)
			/*가시성처리*/
			call BlzFrameSetVisible(.container,GetLocalPlayer()==.owner)
			/*트리거*/
			set .keypress = Trigger.new(this)
			call BlzTriggerRegisterPlayerKeyEvent(.keypress,.owner,OSKEY_T,0,true)
			call BlzTriggerRegisterFrameEvent(.keypress,.btn_refresh,FRAMEEVENT_CONTROL_CLICK)
			call BlzTriggerRegisterFrameEvent(.keypress,.btn_refresh,FRAMEEVENT_MOUSE_LEAVE)
			call BlzTriggerRegisterFrameEvent(.keypress,.btn_autorefresh,FRAMEEVENT_CONTROL_CLICK)
			call BlzTriggerRegisterFrameEvent(.keypress,.btn_autorefresh,FRAMEEVENT_MOUSE_LEAVE)
			call BlzTriggerRegisterFrameEvent(.keypress,.btn_donate,FRAMEEVENT_CONTROL_CLICK)
			call BlzTriggerRegisterFrameEvent(.keypress,.btn_donate,FRAMEEVENT_MOUSE_LEAVE)
			call TriggerRegisterTimerEvent(.keypress,1.0,true)
			set .keypress_cond = TriggerAddCondition(.keypress,function thistype.press)
			/*리프레시 한 번*/
			call setLevel(1)
			call refresh()
			call refreshGold()
			/**/
			set THIS[GetPlayerId(p)] = this
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			local integer i = 0
			local IconFrame ia = 0
			loop
				exitwhen i >= 5
				set ia = UI.getObject(this,UI.INDEX_SKILL_SHOP_WIDGET+i)
				call ia.destroy()
				set i = i + 1
			endloop
			//! runtextmacro destroyFrame(".container")
			//! runtextmacro destroyFrame(".btn_autorefresh")
			//! runtextmacro destroyFrame(".btn_refresh")
			//! runtextmacro destroyFrame(".btn_donate")
			//! runtextmacro destroyFrame(".exp_outline")
			//! runtextmacro destroyFrame(".exp_backdrop")
			//! runtextmacro destroyFrame(".exp_fill")
			//! runtextmacro destroyFrame(".exp_text")
			//! runtextmacro destroyFrame(".level_backdrop")
			//! runtextmacro destroyFrame(".level_text")
			//! runtextmacro destroyFrame(".autorefresh_text_backdrop")
			//! runtextmacro destroyFrame(".autorefresh_text")
			//! runtextmacro destroyFrame(".gold_backdrop")
			//! runtextmacro destroyFrame(".gold_icon")
			//! runtextmacro destroyFrame(".gold_text")
			//! runtextmacro destroyFrame(".chance_backdrop")
			//! runtextmacro destroyFrame(".chance_text")
			/**/
			call TriggerRemoveCondition(.keypress,.keypress_cond)
			call Trigger.remove(.keypress)
			/**/
			set .keypress = null
			set .keypress_cond = null
			set .owner = null
		endmethod

		static method staticRefreshGold takes nothing returns nothing
			local thistype this = THIS[GetPlayerId(GOLD_REFRESH_PLAYER)]
			if this > 0 then
				call refreshGold()
			endif
		endmethod

		static method getTierChance takes integer level, integer tier returns integer
			local integer i = level
			if i > CHANCE_LEVEL_MAX then
				set i = CHANCE_LEVEL_MAX
			endif
			if tier == 1 then
				return CHANCE_TIER1[i]
			elseif tier == 2 then
				return CHANCE_TIER2[i]
			elseif tier == 3 then
				return CHANCE_TIER3[i]
			elseif tier == 4 then
				return CHANCE_TIER4[i]
			elseif tier == 5 then
				return CHANCE_TIER5[i]
			endif
			return 0
		endmethod

		static method initTierChance takes integer level, integer t1, integer t2, integer t3, integer t4, integer t5 returns nothing
			if level < 0 then
				return
			endif
			/*확률치 설정 (레벨기반이라 제로베이스 아님 주의)*/
			set CHANCE_TIER1[level] = t1
			set CHANCE_TIER2[level] = t2
			set CHANCE_TIER3[level] = t3
			set CHANCE_TIER4[level] = t4
			set CHANCE_TIER5[level] = t5
		endmethod

		static method onInit takes nothing returns nothing
			local integer i = 1
			call TriggerAddCondition(GOLD_REFRESH_TRIGGER,function thistype.staticRefreshGold)
			/*확률치 설정 (레벨기반이라 제로베이스 아님 주의)*/
			call initTierChance(1	,80	,20	,0	,0	,0	)
			call initTierChance(2	,75	,25	,0	,0	,0	)
			call initTierChance(3	,70	,25	,5	,0	,0	)
			call initTierChance(4	,60	,30	,10	,0	,0	)
			call initTierChance(5	,55	,30	,10	,5	,0	)
			call initTierChance(6	,54	,25	,15 ,5	,1	)
			call initTierChance(7	,43	,25	,20	,7	,5	)
			call initTierChance(8	,40	,25	,20	,10	,5	)
			call initTierChance(9	,40	,25	,20	,10	,5	)
			call initTierChance(10	,30	,20	,25	,15	,10	)
			call initTierChance(11	,20	,20	,25	,20	,15	)
			/*확률치 합*/
			loop
				/*레벨[~~] 까지*/
				exitwhen i > CHANCE_LEVEL_MAX
				set CHANCE_TOTAL[i] = CHANCE_TIER1[i] + CHANCE_TIER2[i] + CHANCE_TIER3[i] + CHANCE_TIER4[i] + CHANCE_TIER5[i]
				set i = i + 1
			endloop
			/*경험치테이블*/
			set MAX_EXP[1] = 2
			set MAX_EXP[2] = 6
			set MAX_EXP[3] = 10
			set MAX_EXP[4] = 20
			set MAX_EXP[5] = 36
			set MAX_EXP[6] = 56
			set MAX_EXP[7] = 80
			set MAX_EXP[8] = 112
			set MAX_EXP[9] = 144
			set MAX_EXP[10] = 176
			set MAX_EXP[11] = 210
		endmethod

	endstruct

endlibrary