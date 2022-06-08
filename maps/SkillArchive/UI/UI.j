library UI

	globals
		private trigger FRAME_BUTTON_TRIGGER = null

		framehandle FRAME_GAME_UI = null
		framehandle FRAME_ORIGIN = null
		framehandle FRAME_MINIMAP = null
		framehandle FRAME_MINIMAP_BACKDROP = null
		framehandle FRAME_PORTRAIT = null
		framehandle FRAME_PORTRAIT_BACKDROP = null
		framehandle FRAME_HP_BAR = null
		framehandle FRAME_MP_BAR = null
		framehandle FRAME_ABILITY_CONTAINER = null
		framehandle FRAME_STAT1	= null
		framehandle FRAME_STAT2	= null
		framehandle FRAME_EXP_BAR = null
		framehandle FRAME_SKILL_SHOP = null
		framehandle FRAME_SKILL_SHOP_BACKDROP = null
		framehandle FRAME_SKILL_SHOP_BUTTON = null
		framehandle FRAME_SLOT_CHANGER = null
		framehandle FRAME_SLOT_CHANGER_BUTTON = null
		framehandle FRAME_INVENTORY_BUTTON = null
		framehandle FRAME_MAKE_POTION = null
		framehandle array FRAME_ABILITY_ICON[10]

		private constant integer MINIMAP_OFFSET_X = 0
		private constant integer MINIMAP_OFFSET_Y = 16	/*FROM BOTTOMLEFT*/
		private constant integer MINIMAP_SIZE = 224
		private constant integer MINIMAP_BORDER = 0
		private constant integer PORTRAIT_SIZE = 96
		private constant integer PORTRAIT_OFFSET_Y = 160
		private constant integer PORTRAIT_OFFSET_X = -360
		private constant integer PORTRAIT_BORDER = 0
		private constant integer BAR_WIDTH = 720
		private constant integer BAR_HEIGHT = 24
		private constant integer HP_BAR_OFFSET_Y = 136
		private constant integer MP_BAR_OFFSET_Y = 112
		private constant integer ABILITY_CONTAINER_WIDTH = 720
		private constant integer ABILITY_CONTAINER_HEIGHT = 96
		private constant integer ABILITY_CONTAINER_OFFSET_Y = 16
		private constant integer ABILITY_ICON_SIZE = 64
		private constant integer ABILITY_TOOLTIP_OFFSET_Y = 160
		private constant integer CHINGHO_HEIGHT = 32
		private constant integer STAT1_WIDTH = 192
		private constant integer EXP_BAR_HEIGHT = 12
		private constant integer SKILL_SHOP_OFFSET_Y = -16	/*FROM TOP*/
		private constant integer SKILL_SHOP_WIDTH = 1280
		private constant integer SKILL_SHOP_HEIGHT = 428
		private constant integer SKILL_SHOP_INSET = 32
		private constant integer ABILITY_ERROR_OFFSET_Y = 268 /*FROM BOTTOM*/
		private constant integer SLOT_CHANGER_WIDTH = (64*10)+16
		private constant integer SLOT_CHANGER_HEIGHT = (64*3)+16
		private constant integer SLOT_CHANGER_OFFSET_Y = -96 /*FROM CENTER*/

	endglobals

	struct ChinghoFrame

		integer id = 0

		framehandle backdrop = null
		framehandle icon1 = null
		framehandle icon2 = null
		framehandle name = null

		method setTarget takes integer cid returns nothing
			set .id = cid
			if cid > 0 then
				call BlzFrameSetTexture(.icon1,"ReplaceableTextures\\CommandButtons\\"+Ability.getTypeIconPath(cid)+".blp",0,true)
				call BlzFrameSetTexture(.icon2,"ReplaceableTextures\\CommandButtons\\"+Ability.getTypeIconPath(cid)+".blp",0,true)
				call BlzFrameSetText(.name,Ability.getTypeName(cid))
			elseif cid < 0 then
				call BlzFrameSetTexture(.icon1,"ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp",0,true)
				call BlzFrameSetTexture(.icon2,"ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp",0,true)
				call BlzFrameSetText(.name,"???")
			else
				call BlzFrameSetTexture(.icon1,"ReplaceableTextures\\CommandButtons\\BTNBlackIcon.blp",0,true)
				call BlzFrameSetTexture(.icon2,"ReplaceableTextures\\CommandButtons\\BTNBlackIcon.blp",0,true)
				call BlzFrameSetText(.name,"")
			endif
		endmethod

		static method create takes framehandle parent, framehandle pivot returns thistype
			local thistype this = allocate()
			set .backdrop = BlzCreateFrameByType("BACKDROP","",parent,"",0)
			call BlzFrameSetPoint(.backdrop,FRAMEPOINT_TOPLEFT,pivot,FRAMEPOINT_TOPLEFT,0.,0.)
			call BlzFrameSetSize(.backdrop,Math.px2Size(STAT1_WIDTH),Math.px2Size(CHINGHO_HEIGHT))
			call BlzFrameSetTexture(.backdrop,"textures\\black32.blp",0,true)
			set .icon1 = BlzCreateFrameByType("BACKDROP","",.backdrop,"",0)
			call BlzFrameSetPoint(.icon1,FRAMEPOINT_TOPLEFT,.backdrop,FRAMEPOINT_TOPLEFT,0.,0.)
			call BlzFrameSetSize(.icon1,Math.px2Size(CHINGHO_HEIGHT),Math.px2Size(CHINGHO_HEIGHT))
			call BlzFrameSetTexture(.icon1,"textures\\black32.blp",0,true)
			set .icon2 = BlzCreateFrameByType("BACKDROP","",.backdrop,"",0)
			call BlzFrameSetPoint(.icon2,FRAMEPOINT_TOPRIGHT,.backdrop,FRAMEPOINT_TOPRIGHT,0.,0.)
			call BlzFrameSetSize(.icon2,Math.px2Size(CHINGHO_HEIGHT),Math.px2Size(CHINGHO_HEIGHT))
			call BlzFrameSetTexture(.icon2,"textures\\black32.blp",0,true)
			set .name = BlzCreateFrame("MyTextSmall",.backdrop,0,0)
			call BlzFrameSetAllPoints(.name,.backdrop)
			call BlzFrameSetTextAlignment(.name,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
			call setTarget(0)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			//! runtextmacro destroyFrame(".backdrop")
			//! runtextmacro destroyFrame(".icon1")
			//! runtextmacro destroyFrame(".icon2")
			//! runtextmacro destroyFrame(".name")
		endmethod

	endstruct

	struct IconFrame

	endstruct

	struct BuffIcon extends IconFrame

	endstruct

	struct AbilityIcon extends IconFrame

		Ability target = 0

		private static constant integer TOOLTIP_SUB_WIDTH = 64
		private static constant integer TOOLTIP_SUB_HEIGHT = 20
		private static constant integer TOOLTIP_HEADER_HEIGHT = 96
		private static constant integer TOOLTIP_ICON_SIZE = 48
		private static constant integer TOOLTIP_STAT_BONUS_HEIGHT = 40

		integer index = 0
		boolean mouse_in = false

		framehandle icon_container		= null
		framehandle icon_backdrop 		= null
		framehandle icon_border			= null
		framehandle nem_backdrop		= null
		framehandle cooldown_backdrop 	= null
		framehandle cooldown_text 		= null
		framehandle cooldown_text_backdrop = null
		framehandle hotkey_backdrop 	= null
		framehandle hotkey_text 		= null
		framehandle gauge_backdrop		= null
		framehandle gauge_fill			= null
		framehandle extra_backdrop		= null
		framehandle extra_text			= null
		framehandle weapon_particle 	= null
		framehandle tooltip_mouseover	= null
		framehandle tooltip_container	= null
		framehandle tooltip_outline		= null
		framehandle tooltip_backdrop	= null
		framehandle tooltip_text		= null
		framehandle tooltip_stat_bonus_icon1 = null
		framehandle tooltip_stat_bonus_icon2 = null
		framehandle tooltip_stat_bonus_text1 = null
		framehandle tooltip_stat_bonus_text2 = null
		framehandle tooltip_header		= null
		framehandle tooltip_icon		= null
		framehandle tooltip_icon_border = null
		framehandle tooltip_icon_weapon = null
		framehandle tooltip_name		= null
		framehandle tooltip_tag			= null
		framehandle tooltip_casttype			= null
		framehandle tooltip_manacost_backdrop	= null
		framehandle tooltip_manacost_text		= null
		framehandle tooltip_cooldown_backdrop	= null
		framehandle tooltip_cooldown_text		= null
		framehandle unique = null

		trigger btn_trigger = null
		triggercondition btn_cond = null

		method refresh takes nothing returns nothing
			if .target > 0 then
				/*쿨타임 백드롭*/
				call BlzFrameSetVisible(.cooldown_text,.target.cooldown_remaining>0. and .target.getCount() == 0)
				call BlzFrameSetVisible(.cooldown_text_backdrop,.target.cooldown_remaining>0. and .target.getCount() == 0)
				call BlzFrameSetVisible(.cooldown_backdrop,.target.cooldown_remaining>0. and .target.getCount() == 0 and .target.getCarculatedMaxCooldown() > 0.)
				call BlzFrameSetText(.cooldown_text,R2SW(.target.cooldown_remaining,1,1))
				if .target.getCarculatedMaxCooldown() > 0. then
					call BlzFrameSetPoint(.cooldown_backdrop,FRAMEPOINT_TOPRIGHT,.icon_backdrop,FRAMEPOINT_BOTTOMRIGHT,/*
						*/0.,Math.px2Size(ABILITY_ICON_SIZE)*(.target.cooldown_remaining/.target.getCarculatedMaxCooldown()))
				endif
				/*마나부족백드롭*/
				call BlzFrameSetVisible(.nem_backdrop,.target.owner.mp < .target.getCarculatedManacost())
				/*엑스트라밸류*/
				call BlzFrameSetVisible(.extra_backdrop,.target.count_max > 1)
				call BlzFrameSetVisible(.extra_text,.target.count_max > 1)
				call BlzFrameSetText(.extra_text,I2S(.target.count))
				/*게이지*/
				call BlzFrameSetVisible(.gauge_backdrop,.target.gauge>0.)
				call BlzFrameSetPoint(.gauge_fill,FRAMEPOINT_BOTTOMRIGHT,.gauge_backdrop,FRAMEPOINT_BOTTOMLEFT,Math.px2Size(ABILITY_ICON_SIZE)*.target.gauge,0)
				/*툴팁텍스트*/
				call BlzFrameSetText(.tooltip_text,.target.relativeTooltip()+"\n\n|cff00ffff능력치 보너스 : |r")
				/*마나코스트 & 쿨다운*/
				if Ability.getTypeIsWeapon(.target.id) then
					call BlzFrameSetText(.tooltip_manacost_text,"|cff00ffff"+I2S(R2I(.target.weapon_range))+"|r")
					call BlzFrameSetText(.tooltip_cooldown_text,"|cffffff99"+R2SW(.target.weapon_delay,2,2)+"|r")
				else
					call BlzFrameSetText(.tooltip_manacost_text,"|cff0099ff"+I2S(R2I(.target.getCarculatedManacost()))+"|r")
					call BlzFrameSetText(.tooltip_cooldown_text,"|cffffff99"+R2SW(.target.getCarculatedMaxCooldown(),2,2)+"|r\n"+/*
						*/"|cff999999/"+R2SW(.target.cooldown_min,2,2)+"|r")
				endif
				/*스탯보너스*/
				call BlzFrameSetText(.tooltip_stat_bonus_text1,STAT_TYPE_NAME[Ability.getTypeBonusStatIndex(.target.id,0)] + " +"+ /*
				*/ConstantString.statStringReal(Ability.getTypeBonusStatIndex(.target.id,0),.target.stat_bonus1,1))
				call BlzFrameSetText(.tooltip_stat_bonus_text2,STAT_TYPE_NAME[Ability.getTypeBonusStatIndex(.target.id,1)] + " +"+ /*
				*/ConstantString.statStringReal(Ability.getTypeBonusStatIndex(.target.id,1),.target.stat_bonus2,1))
			endif
		endmethod

		method setTarget takes Ability na returns nothing
			local integer i = 1
			local string s = ""
			set .target = na
			call BlzFrameSetVisible(.icon_container,.target > 0)
			if .target > 0 then
				/*아이콘바꾸기*/
				call BlzFrameSetTexture(.icon_backdrop,"ReplaceableTextures\\CommandButtons\\"+.target.icon+".blp",0,true)
				if .target.is_active then
					call BlzFrameSetVisible(.icon_border,false)
				else
					call BlzFrameSetVisible(.icon_border,true)
					call BlzFrameSetTexture(.icon_border,"ReplaceableTextures\\CommandButtons\\bm_pasbtn.blp",0,true)
				endif
				call BlzFrameSetTexture(.tooltip_icon,"ReplaceableTextures\\CommandButtons\\"+.target.icon+".blp",0,true)
				call BlzFrameSetTexture(.tooltip_icon_border,"Textures\\ability_border_tier"+I2S(Ability.getTypeTier(.target.id))+".blp",0,true)
				/*툴팁 스킬이름*/
				call BlzFrameSetText(.tooltip_name,TIER_STRING_COLOR[Ability.getTypeTier(.target.id)]+"Lv."+I2S(.target.level)+" "+.target.name+"|r")
				/*단축키색깔(스마트여부)*/
				if Ability.getTypeIsWeapon(.target.id) then
					call BlzFrameSetText(.hotkey_text,"|cffcc0000"+User.oskeyIndex2String(.index)+"|r")
				else
					if .target.smart == 0 then
						call BlzFrameSetText(.hotkey_text,"|cff999999"+User.oskeyIndex2String(.index)+"|r")
					elseif .target.smart == 1 then
						call BlzFrameSetText(.hotkey_text,"|cffffcc00"+User.oskeyIndex2String(.index)+"|r")
					elseif .target.smart == 2 then
						call BlzFrameSetText(.hotkey_text,"|cff00ffff"+User.oskeyIndex2String(.index)+"|r")
					endif
				endif
				/*어빌리티 캐스트타입*/
				call BlzFrameSetText(.tooltip_casttype,Ability.getTypeTag(.target.id,0))
				/*무기어빌리티면 모델프레임 표시*/
				call BlzFrameSetVisible(.weapon_particle,.target == .target.owner.weapon_ability)
				/*무기어빌리티면 마나코스트 아이콘 바꾸기*/
				if Ability.getTypeIsWeapon(.target.id) then
					call BlzFrameSetVisible(.tooltip_icon_weapon,true)
					call BlzFrameSetTexture(.tooltip_manacost_backdrop,STAT_TYPE_ICON[STAT_TYPE_ATTACK_RANGE],0,true)
				else
					call BlzFrameSetVisible(.tooltip_icon_weapon,false)
					call BlzFrameSetTexture(.tooltip_manacost_backdrop,STAT_TYPE_ICON[STAT_TYPE_MAXMP],0,true)
				endif
				/*어빌리티 태그*/
				loop
					exitwhen Ability.getTypeTag(.target.id,i) == ""
					if i > 1 then
						set s = s + ", " + Ability.getTypeTag(.target.id,i)
					else
						set s = s + Ability.getTypeTag(.target.id,i)
					endif
					set i = i + 1
				endloop
				set s = s
				call BlzFrameSetText(.tooltip_tag,s)
				/*스탯보너스*/
				call BlzFrameSetTexture(.tooltip_stat_bonus_icon1,STAT_TYPE_ICON[Ability.getTypeBonusStatIndex(.target.id,0)],0,true)
				call BlzFrameSetTexture(.tooltip_stat_bonus_icon2,STAT_TYPE_ICON[Ability.getTypeBonusStatIndex(.target.id,1)],0,true)
				/*시그니쳐일 경우 텍스트 표시*/
				call BlzFrameSetVisible(.unique,.target.signiture)
				/*최종 리프레시*/
				call refresh()
			endif
		endmethod

		static method click takes nothing returns nothing
			local thistype this = 0 
			call BlzFrameSetEnable(BlzGetTriggerFrame(),false)
			call BlzFrameSetEnable(BlzGetTriggerFrame(),true)
			if BlzGetTriggerFrameEvent() == FRAMEEVENT_CONTROL_CLICK then
				set this = Trigger.getData(GetTriggeringTrigger())
				if .target > 0 then
					call .target.iconClick()
					if GetLocalPlayer() == GetTriggerPlayer() then
						call PlaySoundBJ(gg_snd_BigButtonClick)
					endif
					call setTarget(.target)
				endif
				return
			elseif BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_RIGHT then
				set this = Trigger.getData(GetTriggeringTrigger())
				if .mouse_in and .target > 0 then
					if Ability.getTypeIsWeapon(.target.id) then
						if .target.owner.weapon_ability == .target then
							call .target.owner.setWeaponAbility(0)
						endif
					else
						set .target.smart = .target.smart + 1
						if .target.smart > 2 then
							set .target.smart = 0
						endif
					endif
					call setTarget(.target)
				endif
			elseif BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_ENTER then
				set this = Trigger.getData(GetTriggeringTrigger())
				set .mouse_in = true
			elseif BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_LEAVE then
				set this = Trigger.getData(GetTriggeringTrigger())
				set .mouse_in = false
			endif
		endmethod

		static method create takes integer index, framehandle parent, player owner returns thistype
			local thistype this = allocate()
			local framehandle pivot = FRAME_ABILITY_ICON[index]
			set .index = index
			/*트리거*/
			set .btn_trigger = Trigger.new(this)
			set .btn_cond = TriggerAddCondition(.btn_trigger,function thistype.click)
			/*아이콘 콘테이너*/
			set .icon_container = BlzCreateFrameByType("FRAME","",parent,"",0)
			call BlzFrameSetPoint(.icon_container,FRAMEPOINT_BOTTOMLEFT,pivot,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			set .icon_backdrop = BlzCreateFrameByType("BACKDROP","",.icon_container,"",0)
			call BlzFrameSetAllPoints(.icon_backdrop,pivot)
			call BlzFrameSetTexture(.icon_backdrop,"ReplaceableTextures\\CommandButtons\\BTNBlackIcon.blp",0,true)
			set .icon_border = BlzCreateFrameByType("BACKDROP","",.icon_container,"",0)
			call BlzFrameSetAllPoints(.icon_border,.icon_backdrop)
			call BlzFrameSetTexture(.icon_backdrop,"ReplaceableTextures\\CommandButtons\\bm_btn.blp",0,true)
			call BlzFrameSetVisible(.icon_border,false)
			set .nem_backdrop = BlzCreateFrameByType("BACKDROP","",.icon_container,"",0)
			call BlzFrameSetAllPoints(.nem_backdrop,pivot)
			call BlzFrameSetTexture(.nem_backdrop,"ReplaceableTextures\\teamcolor\\teamcolor14.blp",0,true)
			call BlzFrameSetAlpha(.nem_backdrop,168)
			call BlzFrameSetVisible(.nem_backdrop,false)
			set .cooldown_backdrop = BlzCreateFrameByType("BACKDROP","",.icon_container,"",0)
			call BlzFrameSetPoint(.cooldown_backdrop,FRAMEPOINT_BOTTOMLEFT,pivot,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			call BlzFrameSetPoint(.cooldown_backdrop,FRAMEPOINT_TOPRIGHT,pivot,FRAMEPOINT_BOTTOMLEFT,Math.px2Size(ABILITY_ICON_SIZE),Math.px2Size(ABILITY_ICON_SIZE)/2)
			call BlzFrameSetTexture(.cooldown_backdrop,"Textures\\Black32.blp",0,true)
			call BlzFrameSetAlpha(.cooldown_backdrop,128)
			set .cooldown_text_backdrop = BlzCreateFrameByType("BACKDROP","",.icon_container,"",0)
			call BlzFrameSetTexture(.cooldown_text_backdrop,"Textures\\Black32.blp",0,true)
			call BlzFrameSetAlpha(.cooldown_text_backdrop,128)
			set .cooldown_text = BlzCreateFrame("MyText",.icon_container,0,0)
			call BlzFrameSetPoint(.cooldown_text,FRAMEPOINT_CENTER,.icon_backdrop,FRAMEPOINT_CENTER,0.,0.)
			call BlzFrameSetTextAlignment(.cooldown_text,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
			call BlzFrameSetText(.cooldown_text,"0.00")
			call BlzFrameSetAllPoints(.cooldown_text_backdrop,.cooldown_text)
			set .hotkey_backdrop = BlzCreateFrameByType("BACKDROP","",.icon_container,"",0)
			call BlzFrameSetPoint(.hotkey_backdrop,FRAMEPOINT_TOPLEFT,pivot,FRAMEPOINT_TOPLEFT,0.,0.)
			call BlzFrameSetSize(.hotkey_backdrop,Math.px2Size(20),Math.px2Size(20))
			call BlzFrameSetTexture(.hotkey_backdrop,"ui\\console\\human\\human-transport-slot.blp",0,true)
			call BlzFrameSetAlpha(.hotkey_backdrop,200)
			set .hotkey_text = BlzCreateFrame("MyText",.icon_container,0,0)
			call BlzFrameSetAllPoints(.hotkey_text,.hotkey_backdrop)
			call BlzFrameSetTextAlignment(.hotkey_text,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
			call BlzFrameSetText(.hotkey_text,"|cffffcc00"+User.oskeyIndex2String(.index)+"|r")
			set .gauge_backdrop = BlzCreateFrameByType("BACKDROP","",.icon_container,"",0)
			call BlzFrameSetPoint(.gauge_backdrop,FRAMEPOINT_TOPLEFT,pivot,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			call BlzFrameSetSize(.gauge_backdrop,Math.px2Size(ABILITY_ICON_SIZE),Math.px2Size(8))
			call BlzFrameSetTexture(.gauge_backdrop,"ui\\feedback\\buildprogressbar\\min-hud-human-buildprogressbar-border.blp",0,true)
			set .gauge_fill = BlzCreateFrameByType("BACKDROP","",.gauge_backdrop,"",0)
			call BlzFrameSetPoint(.gauge_fill,FRAMEPOINT_TOPLEFT,.gauge_backdrop,FRAMEPOINT_TOPLEFT,0.,0.)
			call BlzFrameSetSize(.gauge_fill,Math.px2Size(ABILITY_ICON_SIZE/2),Math.px2Size(8))
			call BlzFrameSetTexture(.gauge_fill,"ui\\feedback\\buildprogressbar\\min-hud-human-buildprogressbar-fill.blp",0,true)
			set .extra_backdrop = BlzCreateFrameByType("BACKDROP","",.icon_container,"",0)
			call BlzFrameSetPoint(.extra_backdrop,FRAMEPOINT_BOTTOMRIGHT,pivot,FRAMEPOINT_BOTTOMRIGHT,0.,0.)
			call BlzFrameSetSize(.extra_backdrop,Math.px2Size(20),Math.px2Size(20))
			call BlzFrameSetTexture(.extra_backdrop,"Textures\\black32.blp",0,true)
			call BlzFrameSetAlpha(.extra_backdrop,200)
			set .extra_text = BlzCreateFrame("MyText",.icon_container,0,0)
			call BlzFrameSetAllPoints(.extra_text,.extra_backdrop)
			call BlzFrameSetTextAlignment(.extra_text,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
			call BlzFrameSetText(.extra_text,"Ex")
			/*무기어빌리티 모델프레임*/
			set .weapon_particle = BlzCreateFrameByType("SPRITE","",icon_container,"",0)
			call BlzFrameSetPoint(.weapon_particle,FRAMEPOINT_BOTTOMLEFT,icon_backdrop,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			call BlzFrameSetModel(.weapon_particle,"UI\\Feedback\\ui-weaponabilityparticle.mdl",0)
			call BlzFrameSetSize(.weapon_particle,Math.px2Size(ABILITY_ICON_SIZE),Math.px2Size(ABILITY_ICON_SIZE))
			call BlzFrameSetVisible(.weapon_particle,false)
			/*툴팁*/
			set .tooltip_mouseover = BlzCreateFrameByType("BUTTON","",.icon_container,"",0)
			call BlzFrameSetAllPoints(.tooltip_mouseover,pivot)
			call BlzTriggerRegisterFrameEvent(.btn_trigger,.tooltip_mouseover,FRAMEEVENT_CONTROL_CLICK)
			call BlzTriggerRegisterFrameEvent(.btn_trigger,.tooltip_mouseover,FRAMEEVENT_MOUSE_ENTER)
			call BlzTriggerRegisterFrameEvent(.btn_trigger,.tooltip_mouseover,FRAMEEVENT_MOUSE_LEAVE)
			call TriggerRegisterPlayerEvent(.btn_trigger,owner,EVENT_PLAYER_MOUSE_DOWN)
			set .tooltip_container = BlzCreateFrameByType("FRAME","",.tooltip_mouseover,"",0)
			call BlzFrameSetPoint(.tooltip_container,FRAMEPOINT_BOTTOMLEFT,FRAME_ORIGIN,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			set	.tooltip_outline = BlzCreateFrameByType("BACKDROP","",.tooltip_container,"",0)
			call BlzFrameSetTexture(.tooltip_outline,"replaceabletextures\\teamcolor\\teamcolor16.blp",0,true)
			set .tooltip_backdrop = BlzCreateFrameByType("BACKDROP","",.tooltip_container,"",0)
			call BlzFrameSetTexture(.tooltip_backdrop,"replaceabletextures\\teamcolor\\teamcolor24.blp",0,true)
			set .tooltip_text = BlzCreateFrame("MyAbilTooltip",.tooltip_container,0,0)
			call BlzFrameSetTextAlignment(.tooltip_text,TEXT_JUSTIFY_BOTTOM,TEXT_JUSTIFY_LEFT)
			call BlzFrameSetPoint(.tooltip_text,FRAMEPOINT_BOTTOM,FRAME_ORIGIN,FRAMEPOINT_BOTTOM,0.,Math.px2Size(ABILITY_TOOLTIP_OFFSET_Y+TOOLTIP_STAT_BONUS_HEIGHT)+0.005)
			set .tooltip_header = BlzCreateFrameByType("FRAME","",.tooltip_container,"",0)
			call BlzFrameSetPoint(.tooltip_header,FRAMEPOINT_BOTTOMLEFT,.tooltip_text,FRAMEPOINT_TOPLEFT,0.,0.)
			call BlzFrameSetPoint(.tooltip_header,FRAMEPOINT_TOPRIGHT,.tooltip_text,FRAMEPOINT_TOPRIGHT,0.,Math.px2Size(TOOLTIP_HEADER_HEIGHT))
			set .tooltip_icon = BlzCreateFrameByType("BACKDROP","",.tooltip_container,"",0)
			call BlzFrameSetPoint(.tooltip_icon,FRAMEPOINT_TOPLEFT,.tooltip_header,FRAMEPOINT_TOPLEFT,0.,0.)
			call BlzFrameSetSize(.tooltip_icon,Math.px2Size(TOOLTIP_ICON_SIZE),Math.px2Size(TOOLTIP_ICON_SIZE))
			set .tooltip_icon_border = BlzCreateFrameByType("BACKDROP","",.tooltip_container,"",0)
			call BlzFrameSetAllPoints(.tooltip_icon_border,.tooltip_icon)
			call BlzFrameSetTexture(.tooltip_icon_border,"Textures\\ability_border_tier1.blp",0,true)
			set .tooltip_icon_weapon = BlzCreateFrameByType("BACKDROP","",.tooltip_container,"",0)
			call BlzFrameSetPoint(.tooltip_icon_weapon,FRAMEPOINT_BOTTOMLEFT,.tooltip_icon,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			call BlzFrameSetSizePixel(.tooltip_icon_weapon,20,20)
			call BlzFrameSetVisible(.tooltip_icon_weapon,false)
			call BlzFrameSetTexture(.tooltip_icon_weapon,"ui\\widgets\\tooltips\\human\\tooltipweaponicon.blp",0,true)
			set .tooltip_name = BlzCreateFrame("MyTextLarge",.tooltip_container,0,0)
			call BlzFrameSetPoint(.tooltip_name,FRAMEPOINT_LEFT,.tooltip_icon,FRAMEPOINT_RIGHT,0.01,0.)
			call BlzFrameSetTextAlignment(.tooltip_name,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_LEFT)
			set .tooltip_tag = BlzCreateFrame("MyText",.tooltip_container,0,0)
			call BlzFrameSetPoint(.tooltip_tag,FRAMEPOINT_BOTTOMLEFT,.tooltip_name,FRAMEPOINT_BOTTOMRIGHT,0.01,0)
			set .tooltip_casttype = BlzCreateFrame("MyText",.tooltip_container,0,0)
			call BlzFrameSetPoint(.tooltip_casttype,FRAMEPOINT_BOTTOMLEFT,.tooltip_header,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			call BlzFrameSetPoint(.tooltip_casttype,FRAMEPOINT_TOPRIGHT,.tooltip_icon,FRAMEPOINT_BOTTOMRIGHT,0.5,0)
			call BlzFrameSetTextAlignment(.tooltip_casttype,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_LEFT)
			set .tooltip_manacost_text = BlzCreateFrame("MyText",.tooltip_container,0,0)
			call BlzFrameSetPoint(.tooltip_manacost_text,FRAMEPOINT_TOPRIGHT,.tooltip_header,FRAMEPOINT_TOPRIGHT,0.,0.)
			call BlzFrameSetSize(.tooltip_manacost_text,Math.px2Size(TOOLTIP_SUB_WIDTH),Math.px2Size(TOOLTIP_SUB_HEIGHT))
			call BlzFrameSetTextAlignment(.tooltip_manacost_text,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_RIGHT)
			set .tooltip_manacost_backdrop = BlzCreateFrameByType("BACKDROP","",.tooltip_container,"",0)
			call BlzFrameSetPoint(.tooltip_manacost_backdrop,FRAMEPOINT_TOPRIGHT,.tooltip_manacost_text,FRAMEPOINT_TOPLEFT,0.,0.)
			call BlzFrameSetSize(.tooltip_manacost_backdrop,Math.px2Size(TOOLTIP_SUB_HEIGHT),Math.px2Size(TOOLTIP_SUB_HEIGHT))
			call BlzFrameSetTexture(.tooltip_manacost_backdrop,"ui\\widgets\\tooltips\\human\\tooltipmanaicon.blp",0,true)
			set .tooltip_cooldown_text = BlzCreateFrame("MyText",.tooltip_container,0,0)
			call BlzFrameSetPoint(.tooltip_cooldown_text,FRAMEPOINT_TOPRIGHT,.tooltip_manacost_text,FRAMEPOINT_BOTTOMRIGHT,0.,-0.005)
			call BlzFrameSetSize(.tooltip_cooldown_text,Math.px2Size(TOOLTIP_SUB_WIDTH),Math.px2Size(TOOLTIP_SUB_HEIGHT)*2)
			call BlzFrameSetTextAlignment(.tooltip_cooldown_text,TEXT_JUSTIFY_TOP,TEXT_JUSTIFY_RIGHT)
			set .tooltip_cooldown_backdrop = BlzCreateFrameByType("BACKDROP","",.tooltip_container,"",0)
			call BlzFrameSetPoint(.tooltip_cooldown_backdrop,FRAMEPOINT_TOPRIGHT,.tooltip_cooldown_text,FRAMEPOINT_TOPLEFT,0.,0.)
			call BlzFrameSetSize(.tooltip_cooldown_backdrop,Math.px2Size(TOOLTIP_SUB_HEIGHT),Math.px2Size(TOOLTIP_SUB_HEIGHT))
			call BlzFrameSetTexture(.tooltip_cooldown_backdrop,"ui\\widgets\\tooltips\\human\\tooltipcooldownicon.blp",0,true)
			set .tooltip_stat_bonus_icon1 = BlzCreateFrameByType("BACKDROP","",.tooltip_container,"",0)
			call BlzFrameSetPoint(.tooltip_stat_bonus_icon1,FRAMEPOINT_TOPLEFT,tooltip_text,FRAMEPOINT_BOTTOMLEFT,Math.px2Size(0),Math.px2Size(-8))
			call BlzFrameSetSize(.tooltip_stat_bonus_icon1,Math.px2Size(32),Math.px2Size(32))
			set .tooltip_stat_bonus_icon2 = BlzCreateFrameByType("BACKDROP","",.tooltip_container,"",0)
			call BlzFrameSetPoint(.tooltip_stat_bonus_icon2,FRAMEPOINT_TOPLEFT,tooltip_text,FRAMEPOINT_BOTTOMLEFT,Math.px2Size(0+192),Math.px2Size(-8))
			call BlzFrameSetSize(.tooltip_stat_bonus_icon2,Math.px2Size(32),Math.px2Size(32))
			set .tooltip_stat_bonus_text1 = BlzCreateFrame("MyText",.tooltip_container,0,0)
			call BlzFrameSetPoint(.tooltip_stat_bonus_text1,FRAMEPOINT_LEFT,.tooltip_stat_bonus_icon1,FRAMEPOINT_RIGHT,Math.px2Size(8),0.)
			call BlzFrameSetTextAlignment(.tooltip_stat_bonus_text1,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_LEFT)
			set .tooltip_stat_bonus_text2 = BlzCreateFrame("MyText",.tooltip_container,0,0)
			call BlzFrameSetPoint(.tooltip_stat_bonus_text2,FRAMEPOINT_LEFT,.tooltip_stat_bonus_icon2,FRAMEPOINT_RIGHT,Math.px2Size(8),0.)
			call BlzFrameSetTextAlignment(.tooltip_stat_bonus_text2,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_LEFT)
			set .unique = BlzCreateFrame("MyText",.tooltip_container,0,0)
			call BlzFrameSetText(.unique,"|cffffcc00고유능력|r")
			call BlzFrameSetVisible(.unique,false)
			/*SET POINT*/
			call BlzFrameSetPoint(.tooltip_outline,FRAMEPOINT_BOTTOMLEFT,.tooltip_text,FRAMEPOINT_BOTTOMLEFT,-.005,-.005-Math.px2Size(TOOLTIP_STAT_BONUS_HEIGHT))
			call BlzFrameSetPoint(.tooltip_outline,FRAMEPOINT_TOPRIGHT,.tooltip_header,FRAMEPOINT_TOPRIGHT,.005,.005)
			call BlzFrameSetPoint(.tooltip_backdrop,FRAMEPOINT_BOTTOMLEFT,.tooltip_text,FRAMEPOINT_BOTTOMLEFT,-.004,-.004-Math.px2Size(TOOLTIP_STAT_BONUS_HEIGHT))
			call BlzFrameSetPoint(.tooltip_backdrop,FRAMEPOINT_TOPRIGHT,.tooltip_header,FRAMEPOINT_TOPRIGHT,.004,.004)
			call BlzFrameSetPoint(.unique,FRAMEPOINT_BOTTOMRIGHT,.tooltip_backdrop,FRAMEPOINT_BOTTOMRIGHT,-0.004,0.004)
			/**/
			call BlzFrameSetTooltip(.tooltip_mouseover,.tooltip_container)
			/**/
			set pivot = null
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			//! runtextmacro destroyFrame(".icon_container")
			//! runtextmacro destroyFrame(".icon_backdrop")
			//! runtextmacro destroyFrame(".icon_border")
			//! runtextmacro destroyFrame(".nem_backdrop")
			//! runtextmacro destroyFrame(".cooldown_backdrop")
			//! runtextmacro destroyFrame(".cooldown_text_backdrop")
			//! runtextmacro destroyFrame(".cooldown_text")
			//! runtextmacro destroyFrame(".hotkey_backdrop")
			//! runtextmacro destroyFrame(".hotkey_text")
			//! runtextmacro destroyFrame(".gauge_backdrop")
			//! runtextmacro destroyFrame(".gauge_fill")
			//! runtextmacro destroyFrame(".extra_backdrop")
			//! runtextmacro destroyFrame(".extra_text")
			//! runtextmacro destroyFrame(".weapon_particle")
			//! runtextmacro destroyFrame(".tooltip_container")
			//! runtextmacro destroyFrame(".tooltip_outline")
			//! runtextmacro destroyFrame(".tooltip_backdrop")
			//! runtextmacro destroyFrame(".tooltip_header")
			//! runtextmacro destroyFrame(".tooltip_text")
			//! runtextmacro destroyFrame(".tooltip_icon")
			//! runtextmacro destroyFrame(".tooltip_icon_border")
			//! runtextmacro destroyFrame(".tooltip_icon_weapon")
			//! runtextmacro destroyFrame(".tooltip_name")
			//! runtextmacro destroyFrame(".tooltip_tag")
			//! runtextmacro destroyFrame(".tooltip_casttype")
			//! runtextmacro destroyFrame(".tooltip_manacost_backdrop")
			//! runtextmacro destroyFrame(".tooltip_manacost_text")
			//! runtextmacro destroyFrame(".tooltip_cooldown_backdrop")
			//! runtextmacro destroyFrame(".tooltip_cooldown_text")
			//! runtextmacro destroyFrame(".tooltip_stat_bonus_icon1")
			//! runtextmacro destroyFrame(".tooltip_stat_bonus_icon2")
			//! runtextmacro destroyFrame(".tooltip_stat_bonus_text1")
			//! runtextmacro destroyFrame(".tooltip_stat_bonus_text2")
			//! runtextmacro destroyFrame(".unique")
			call TriggerRemoveCondition(.btn_trigger,.btn_cond)
			call Trigger.remove(.btn_trigger)
			set .btn_trigger = null
			set .btn_cond = null
		endmethod

	endstruct

	struct StatIcon extends IconFrame

			static constant integer HEIGHT = 24
			static constant integer WIDTH = 108
			static constant integer PER_COL = 4

			integer stat_index = 0
			integer format = 0		/*0 int, 1 real, 2 percent*/
			Unit target = 0

			framehandle backdrop 	= null
			framehandle text		= null
			framehandle mouseover	= null
			framehandle tooltip_container 	= null
			framehandle tooltip_backdrop	= null
			framehandle tooltip_text		= null

			method refresh takes nothing returns nothing
				if .format == 0 then
					call BlzFrameSetText(.text,ConstantString.statStringInteger(stat_index,R2I(.target.getCarculatedStatValue(stat_index))))
				elseif .format == 1 then
					call BlzFrameSetText(.text,ConstantString.statStringReal(stat_index,.target.getCarculatedStatValue(stat_index),1))
				elseif .format == 2 then
					call BlzFrameSetText(.text,ConstantString.statStringPercent(stat_index,.target.getCarculatedStatValue(stat_index)))
				endif
			endmethod

			method setTarget takes Unit nt returns nothing
				set .target = nt
			endmethod

			static method create takes framehandle parent, integer index, integer statindex returns thistype
				local thistype this = allocate()
				set .stat_index = statindex
				/*FORMAT*/
				if .stat_index == STAT_TYPE_ATTACK_SPEED or .stat_index == STAT_TYPE_HEAL_AMP then
					set .format = 2
				elseif .stat_index == STAT_TYPE_HPREGEN or .stat_index == STAT_TYPE_MPREGEN or .stat_index == STAT_TYPE_ARMOR_PENET or .stat_index == STAT_TYPE_MAGIC_PENET then
					set .format = 1
				endif
				/**/
				set .backdrop = BlzCreateFrameByType("BACKDROP","",parent,"",0)
				call BlzFrameSetPoint(.backdrop,FRAMEPOINT_TOPLEFT,FRAME_STAT2,FRAMEPOINT_TOPLEFT,/*
					*/Math.px2Size(WIDTH)*(index/PER_COL)+Math.px2Size(2),/*
					*/-Math.px2Size(HEIGHT)*ModuloInteger(index,PER_COL)-Math.px2Size(2))
				call BlzFrameSetTexture(.backdrop,STAT_TYPE_ICON[statindex],0,true)
				call BlzFrameSetSize(.backdrop,Math.px2Size(20),Math.px2Size(20))
				set .text = BlzCreateFrame("MyTextSmall",parent,0,0)
				call BlzFrameSetPoint(.text,FRAMEPOINT_BOTTOMLEFT,.backdrop,FRAMEPOINT_BOTTOMRIGHT,0.005,0.)
				call BlzFrameSetSize(.text,Math.px2Size(WIDTH/2),Math.px2Size(20))
				call BlzFrameSetTextAlignment(.text,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_LEFT)
				set .mouseover = BlzCreateFrameByType("FRAME","",.backdrop,"",0)
				call BlzFrameSetPoint(.mouseover,FRAMEPOINT_BOTTOMRIGHT,.backdrop,FRAMEPOINT_BOTTOMRIGHT,0.,0.)
				call BlzFrameSetSize(.mouseover,Math.px2Size(20),Math.px2Size(20))
				set .tooltip_container = BlzCreateFrameByType("BACKDROP","",.mouseover,"",0)
				call BlzFrameSetPoint(.tooltip_container,FRAMEPOINT_BOTTOMLEFT,FRAME_ORIGIN,FRAMEPOINT_BOTTOMLEFT,0.0,0.0)
				call BlzFrameSetTooltip(.mouseover,.tooltip_container)
				set .tooltip_backdrop = BlzCreateFrameByType("BACKDROP","",.tooltip_container,"",0)
				call BlzFrameSetTexture(.tooltip_backdrop,"replaceabletextures\\teamcolor\\teamcolor27.blp",0,true)
				call BlzFrameSetAlpha(.tooltip_backdrop,200)
				set .tooltip_text = BlzCreateFrame("MyText",.tooltip_container,0,0)
				call BlzFrameSetText(.tooltip_text,STAT_TYPE_COLOR[statindex]+STAT_TYPE_NAME[statindex]+"|r\n\n"+STAT_TYPE_DESCRIPTION[statindex])
				call BlzFrameSetTextAlignment(.tooltip_text,TEXT_JUSTIFY_BOTTOM,TEXT_JUSTIFY_LEFT)
				call BlzFrameSetPoint(.tooltip_text,FRAMEPOINT_BOTTOMLEFT,.mouseover,FRAMEPOINT_BOTTOMRIGHT,0.005,0.005)
				call BlzFrameSetPoint(.tooltip_backdrop,FRAMEPOINT_BOTTOMLEFT,.tooltip_text,FRAMEPOINT_BOTTOMLEFT,-0.005,-0.005)
				call BlzFrameSetPoint(.tooltip_backdrop,FRAMEPOINT_TOPRIGHT,.tooltip_text,FRAMEPOINT_TOPRIGHT,0.005,0.005)
				return this
			endmethod

			method onDestroy takes nothing returns nothing
				//! runtextmacro destroyFrame(".backdrop")
				//! runtextmacro destroyFrame(".mouseover")
				//! runtextmacro destroyFrame(".text")
				//! runtextmacro destroyFrame(".tooltip_container")
				//! runtextmacro destroyFrame(".tooltip_backdrop")
				//! runtextmacro destroyFrame(".tooltip_text")
			endmethod

	endstruct

	struct Closeable

		stub method close takes nothing returns boolean
			return true
		endmethod

	endstruct

	module ThisUI

		static thistype array THIS

	endmodule

	struct UI

		static hashtable HASH = InitHashtable()

		/*UI*/
		static integer INDEX_ABILITY_ICON = 0 		/*SIZE:10*/
		static integer INDEX_STAT_ICON = 0			/*SIZE:16*/
		static integer INDEX_BUFF_ICON = 0			/*SIZE:8*/
		/*SkillShop*/
		static integer INDEX_SKILL_SHOP_WIDGET = 0	/*SIZE:5*/
		/*SlotChanger*/
		static integer INDEX_SLOT_CHANGER_WIDGET = 0 /*SIZE:10*/
		static integer INDEX_SLOT_CHANGER_BUTTON = 0 /*SIZE:10*/
		static integer INDEX_SLOT_CHANGER_ICON = 0 /*SIZE:10*/
		static integer INDEX_SLOT_CHANGER_INDEX = 0 /*SIZE:10*/
		static integer INDEX_SLOT_CHANGER_HOTKEY = 0 /*SIZE:10*/
		

		Unit target = 0

		timer main_timer = null
		framehandle container = null
		framehandle hp_fill = null
		framehandle hp_text = null
		framehandle hp_icon = null
		framehandle mp_fill = null
		framehandle mp_text = null
		framehandle mp_icon = null
		framehandle level_backdrop	= null
		framehandle level_text		= null
		framehandle exp_fill		= null
		framehandle exp_text		= null
		framehandle name			= null
		framehandle ability_error = null
		implement ThisUI
		
		ChinghoFrame chingho		= 0
		
		real ability_error_lifespan = 0.

		static method getObject takes integer instance, integer index returns integer
			return LoadInteger(HASH,instance,index)
		endmethod

		static method setObject takes integer instance, integer index, integer new returns nothing
			call SaveInteger(HASH,instance,index,new)
		endmethod

		method abilityError takes nothing returns nothing
			call BlzFrameSetText(.ability_error,ERROR_MESSAGE)
			set .ability_error_lifespan = 2.0
		endmethod

		static method abilityErrorCondition takes nothing returns nothing
			local thistype A = THIS[GetPlayerId(ERROR_MESSAGE_PLAYER)]
			if A != 0 then
				call A.abilityError()
			endif
		endmethod

		method refreshName takes nothing returns nothing
			call BlzFrameSetVisible(.name,.target > 0)
			call BlzFrameSetText(.name,.target.name)
		endmethod

		method refreshStatIconsTarget takes nothing returns nothing
			local integer i = 0
			local StatIcon sa = 0
			loop
				exitwhen i >= 16
				set sa = getObject(this,INDEX_STAT_ICON+i)
				call sa.setTarget(.target)
				set i = i + 1
			endloop
		endmethod

		method refreshStatIcons takes nothing returns nothing
			local integer i = 0
			local StatIcon sa = 0
			loop
				exitwhen i >= 16
				set sa = getObject(this,INDEX_STAT_ICON+i)
				call sa.refresh()
				set i = i + 1
			endloop
		endmethod

		method refreshAbilityIconsTarget takes nothing returns nothing
			local integer i = 0
			local AbilityIcon ia = 0
			loop
				exitwhen i >= 10
				set ia = getObject(this,INDEX_ABILITY_ICON+i)
				call ia.setTarget(.target.getAbility(i))
				set i = i + 1
			endloop
		endmethod

		method refreshAbilityIcons takes nothing returns nothing
			local AbilityIcon ia = 0
			local integer i = 0
			loop
				exitwhen i >= 10
				set ia = getObject(this,INDEX_ABILITY_ICON+i)
				call ia.refresh()
				set i = i + 1
			endloop
		endmethod

		method refreshPeriodic takes nothing returns nothing
			/*체력바*/
			call BlzFrameSetVisible(.hp_fill,.target.maxhp > 0.)
			call BlzFrameSetPoint(.hp_fill,FRAMEPOINT_TOPRIGHT,FRAME_HP_BAR,FRAMEPOINT_TOPLEFT,Math.px2Size(BAR_WIDTH)*(.target.hp/.target.maxhp),0.)
			call BlzFrameSetVisible(.mp_fill,.target.maxmp > 0.)
			if .target.maxmp > 0. then
				call BlzFrameSetPoint(.mp_fill,FRAMEPOINT_TOPRIGHT,FRAME_MP_BAR,FRAMEPOINT_TOPLEFT,Math.px2Size(BAR_WIDTH)*(.target.mp/.target.maxmp),0.)
			endif
			call BlzFrameSetText(.hp_text,I2S(R2I(.target.hp))+" / "+I2S(R2I(.target.maxhp))+" (+"+R2SW(.target.hpregen,1,1)+")")
			call BlzFrameSetVisible(.mp_text,.target.maxmp > 0.)
			call BlzFrameSetText(.mp_text,I2S(R2I(.target.mp))+" / "+I2S(R2I(.target.maxmp))+" (+"+R2SW(.target.mpregen,1,1)+")")
			/*레벨*/
			call BlzFrameSetText(.level_text," Lv."+I2S(.target.level)+" ")
			/*경험치*/
			call BlzFrameSetVisible(.exp_fill,.target.exp > 0.)
			call BlzFrameSetPoint(.exp_fill,FRAMEPOINT_TOPRIGHT,FRAME_EXP_BAR,FRAMEPOINT_TOPLEFT,Math.px2Size(STAT1_WIDTH)*(I2R(.target.exp)/I2R(.target.exp_max)),0.)
			call BlzFrameSetText(.exp_text,R2SW(I2R(.target.exp)/I2R(.target.exp_max),1,1)+"%")
			/*어빌아이콘*/
			call refreshAbilityIcons()
			/*스탯아이콘*/
			call refreshStatIcons()
			/*어빌리티 에러*/
			if .ability_error_lifespan > 0. then
				set .ability_error_lifespan = .ability_error_lifespan - 0.1
				if .ability_error_lifespan < 0. then
					set .ability_error_lifespan = 0.
					call BlzFrameSetText(.ability_error,"")
				endif
			endif
		endmethod

		method setTarget takes Unit nt returns nothing
			set .target = nt
			call refreshAbilityIconsTarget()
			call refreshStatIconsTarget()
			call refreshName()
			call .chingho.setTarget(.target.chingho.id)
			call refreshPeriodic()
		endmethod

		static method timerAction takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			call refreshPeriodic()
		endmethod

		static method onLevel takes nothing returns nothing
			local Unit u = LEVEL_UNIT
			local thistype this = 0
			if LEVEL_UNIT <= 0 then
				return
			endif
			set this = THIS[GetPlayerId(u.owner)]
			call setTarget(.target)
		endmethod

		static method create takes player p returns thistype
			local thistype this = allocate()
			local integer i = 0
			local AbilityIcon ia = 0
			local StatIcon sa = 0
			set .main_timer = Timer.new(this)
			/*컨테이너*/
			set .container = BlzCreateFrameByType("FRAME","",FRAME_GAME_UI,"",0)
			call BlzFrameSetPoint(.container,FRAMEPOINT_BOTTOMLEFT,FRAME_ORIGIN,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			/*체력바 마나바*/
			set .hp_fill = BlzCreateFrameByType("BACKDROP","",.container,"",0)
			call BlzFrameSetPoint(.hp_fill,FRAMEPOINT_BOTTOMLEFT,FRAME_HP_BAR,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			call BlzFrameSetTexture(.hp_fill,"replaceabletextures\\teamcolor\\teamcolor06.blp",0,true)
			set .hp_text = BlzCreateFrame("MyText",.container,0,0)
			call BlzFrameSetAllPoints(.hp_text,FRAME_HP_BAR)
			call BlzFrameSetTextAlignment(.hp_text,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
			set .hp_icon = BlzCreateFrameByType("BACKDROP","",.container,"",0)
			call BlzFrameSetPoint(.hp_icon,FRAMEPOINT_TOPLEFT,.hp_text,FRAMEPOINT_TOPLEFT,Math.px2Size(BAR_HEIGHT-20)/2,-Math.px2Size(BAR_HEIGHT-20)/2)
			call BlzFrameSetSize(.hp_icon,Math.px2Size(20),Math.px2Size(20))
			call BlzFrameSetTexture(.hp_icon,"ui\\widgets\\tooltips\\human\\tooltiphpicon.blp",0,true)
			set .mp_fill = BlzCreateFrameByType("BACKDROP","",.container,"",0)
			call BlzFrameSetPoint(.mp_fill,FRAMEPOINT_BOTTOMLEFT,FRAME_MP_BAR,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			call BlzFrameSetTexture(.mp_fill,"replaceabletextures\\teamcolor\\teamcolor01.blp",0,true)
			set .mp_text = BlzCreateFrame("MyText",.container,0,0)
			call BlzFrameSetAllPoints(.mp_text,FRAME_MP_BAR)
			call BlzFrameSetTextAlignment(.mp_text,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
			set .mp_icon = BlzCreateFrameByType("BACKDROP","",.container,"",0)
			call BlzFrameSetPoint(.mp_icon,FRAMEPOINT_TOPLEFT,.mp_text,FRAMEPOINT_TOPLEFT,Math.px2Size(BAR_HEIGHT-20)/2,-Math.px2Size(BAR_HEIGHT-20)/2)
			call BlzFrameSetSize(.mp_icon,Math.px2Size(20),Math.px2Size(20))
			call BlzFrameSetTexture(.mp_icon,"ui\\widgets\\tooltips\\human\\tooltipmanaicon.blp",0,true)
			/*칭호*/
			set .chingho = ChinghoFrame.create(.container,FRAME_STAT1)
			/*레벨*/
			set .level_backdrop = BlzCreateFrameByType("BACKDROP","",.container,"",0)
			call BlzFrameSetTexture(.level_backdrop,"ui\\console\\human\\human-transport-slot.blp",0,true)
			set .level_text	= BlzCreateFrame("MyText",.container,0,0)
			call BlzFrameSetPoint(.level_text,FRAMEPOINT_BOTTOMRIGHT,FRAME_EXP_BAR,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			call BlzFrameSetAllPoints(.level_backdrop,.level_text)
			call BlzFrameSetTextAlignment(.level_text,TEXT_JUSTIFY_BOTTOM,TEXT_JUSTIFY_RIGHT)
			/*경험치바*/
			set .exp_fill = BlzCreateFrameByType("BACKDROP","",.container,"",0)
			call BlzFrameSetPoint(.exp_fill,FRAMEPOINT_BOTTOMLEFT,FRAME_EXP_BAR,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			call BlzFrameSetTexture(.exp_fill,"replaceabletextures\\teamcolor\\teamcolor15.blp",0,true)
			call BlzFrameSetPoint(.exp_fill,FRAMEPOINT_TOPRIGHT,FRAME_EXP_BAR,FRAMEPOINT_TOPLEFT,Math.px2Size(STAT1_WIDTH)*0.5,0.)
			set .exp_text = BlzCreateFrame("MyTextSmall",.container,0,0)
			call BlzFrameSetPoint(.exp_text,FRAMEPOINT_BOTTOM,FRAME_EXP_BAR,FRAMEPOINT_BOTTOM,0.,0.)
			call BlzFrameSetTextAlignment(.exp_text,TEXT_JUSTIFY_BOTTOM,TEXT_JUSTIFY_CENTER)
			call BlzFrameSetText(.exp_text,"0%")
			/*유닛이름*/
			set .name = BlzCreateFrame("MyTextLarge",.container,0,0)
			call BlzFrameSetPoint(.name,FRAMEPOINT_TOPLEFT,.chingho.backdrop,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			call BlzFrameSetPoint(.name,FRAMEPOINT_BOTTOMRIGHT,FRAME_EXP_BAR,FRAMEPOINT_TOPRIGHT,0.,0.)
			call BlzFrameSetTextAlignment(.name,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
			/*스탯*/
			set sa = StatIcon.create(.container,0,STAT_TYPE_ATTACK)
			call setObject(this,INDEX_STAT_ICON+0,sa)
			set sa = StatIcon.create(.container,1,STAT_TYPE_MAGICPOWER)
			call setObject(this,INDEX_STAT_ICON+1,sa)
			set sa = StatIcon.create(.container,2,STAT_TYPE_ACCURACY)
			call setObject(this,INDEX_STAT_ICON+2,sa)
			set sa = StatIcon.create(.container,3,STAT_TYPE_LUCK)
			call setObject(this,INDEX_STAT_ICON+3,sa)
			set sa = StatIcon.create(.container,4,STAT_TYPE_DEFFENCE)
			call setObject(this,INDEX_STAT_ICON+4,sa)
			set sa = StatIcon.create(.container,5,STAT_TYPE_RESISTANCE)
			call setObject(this,INDEX_STAT_ICON+5,sa)
			set sa = StatIcon.create(.container,6,STAT_TYPE_EVASION)
			call setObject(this,INDEX_STAT_ICON+6,sa)
			set sa = StatIcon.create(.container,7,STAT_TYPE_ATTACK_SPEED)
			call setObject(this,INDEX_STAT_ICON+7,sa)
			set sa = StatIcon.create(.container,8,STAT_TYPE_HPREGEN)
			call setObject(this,INDEX_STAT_ICON+8,sa)
			set sa = StatIcon.create(.container,9,STAT_TYPE_ARMOR_PENET)
			call setObject(this,INDEX_STAT_ICON+9,sa)
			set sa = StatIcon.create(.container,10,STAT_TYPE_SPELL_BOOST)
			call setObject(this,INDEX_STAT_ICON+10,sa)
			set sa = StatIcon.create(.container,11,STAT_TYPE_ATTACK_RANGE)
			call setObject(this,INDEX_STAT_ICON+11,sa)
			set sa = StatIcon.create(.container,12,STAT_TYPE_MPREGEN)
			call setObject(this,INDEX_STAT_ICON+12,sa)
			set sa = StatIcon.create(.container,13,STAT_TYPE_MAGIC_PENET)
			call setObject(this,INDEX_STAT_ICON+13,sa)
			set sa = StatIcon.create(.container,14,STAT_TYPE_HEAL_AMP)
			call setObject(this,INDEX_STAT_ICON+14,sa)
			set sa = StatIcon.create(.container,15,STAT_TYPE_MOVEMENT_SPEED)
			call setObject(this,INDEX_STAT_ICON+15,sa)
			/*어빌아이콘*/
			loop
				exitwhen i >= 10
				set ia = AbilityIcon.create(i,.container,p)
				call setObject(this,INDEX_ABILITY_ICON+i,ia)
				//call ia.setTarget(target.getAbility(i))
				set i = i + 1
			endloop
			/*어빌리티 에러*/
			set .ability_error = BlzCreateFrame("MyText",.container,0,0)
			call BlzFrameSetPoint(.ability_error,FRAMEPOINT_BOTTOM,FRAME_ORIGIN,FRAMEPOINT_BOTTOM,0.,Math.px2Size(ABILITY_ERROR_OFFSET_Y))
			call BlzFrameSetTextAlignment(.ability_error,TEXT_JUSTIFY_BOTTOM,TEXT_JUSTIFY_CENTER)
			/*타겟리프레시*/
			call setTarget(User.getFocusUnit(p))
			/*가시성처리*/
			call BlzFrameSetVisible(.container,GetLocalPlayer()==p)
			/*타이머*/
			call Timer.start(.main_timer,0.1,true,function thistype.timerAction)
			/*전역변수*/
			set THIS[GetPlayerId(p)] = this
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			local integer i = 0
			local IconFrame ii = 0
			loop
				exitwhen i >= 10
				set ii = getObject(this,INDEX_ABILITY_ICON+i)
				call ii.destroy()
				call RemoveSavedInteger(HASH,this,INDEX_ABILITY_ICON+i)
				set i = i + 1
			endloop
			set i = 0
			loop
				exitwhen i >= 16
				set ii = getObject(this,INDEX_STAT_ICON+i)
				call ii.destroy()
				call RemoveSavedInteger(HASH,this,INDEX_STAT_ICON+i)
				set i = i + 1
			endloop
			if .chingho > 0 then
				call .chingho.destroy()
			endif
			set i = 0
			loop
				exitwhen i >= 8
				set ii = getObject(this,INDEX_BUFF_ICON+i)
				call ii.destroy()
				call RemoveSavedInteger(HASH,this,INDEX_BUFF_ICON+i)
				set i = i + 1
			endloop
			//! runtextmacro destroyFrame(".container")
			//! runtextmacro destroyFrame(".hp_fill")
			//! runtextmacro destroyFrame(".hp_text")
			//! runtextmacro destroyFrame(".hp_icon")
			//! runtextmacro destroyFrame(".mp_fill")
			//! runtextmacro destroyFrame(".mp_text")
			//! runtextmacro destroyFrame(".mp_icon")
			//! runtextmacro destroyFrame(".level_backdrop")
			//! runtextmacro destroyFrame(".level_text")
			//! runtextmacro destroyFrame(".exp_fill")
			//! runtextmacro destroyFrame(".exp_text")
			//! runtextmacro destroyFrame(".name")
			//! runtextmacro destroyFrame(".ability_error")
			call Timer.release(.main_timer)
			set .main_timer = null
		endmethod

		private static method genericButtonAction takes nothing returns nothing
			if GetLocalPlayer() == GetTriggerPlayer() then
				call BlzFrameSetEnable(BlzGetTriggerFrame(),false)
				call BlzFrameSetEnable(BlzGetTriggerFrame(),true)
			endif
			if BlzGetTriggerFrameEvent() != FRAMEEVENT_CONTROL_CLICK then
				return
			endif
			if BlzGetTriggerFrame() == FRAME_SKILL_SHOP_BUTTON then
				call SkillShop.THIS[GetPlayerId(GetTriggerPlayer())].switch()
			elseif BlzGetTriggerFrame() == FRAME_SLOT_CHANGER_BUTTON then
				call SlotChanger.THIS[GetPlayerId(GetTriggerPlayer())].switch()
			elseif BlzGetTriggerFrame() == FRAME_INVENTORY_BUTTON then

			endif
		endmethod

		static method init takes nothing returns nothing
			local framehandle f = null
			local framehandle bf = null
			local integer i = 0
			local real c_inset = Math.px2Size(ABILITY_CONTAINER_HEIGHT-ABILITY_ICON_SIZE)/2.
			local real c_width = Math.px2Size(ABILITY_CONTAINER_WIDTH)-(c_inset*2)
			local real c_cell = c_width/10.
			local real c_padding = c_cell-Math.px2Size(ABILITY_ICON_SIZE)
			local trigger t = null
			set FRAME_ORIGIN = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI,0)
			set FRAME_GAME_UI = BlzCreateFrameByType("FRAME","",FRAME_ORIGIN,"",0)
			/**/
			call BlzFrameSetPoint(FRAME_GAME_UI,FRAMEPOINT_BOTTOMLEFT,FRAME_ORIGIN,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			/*미니맵*/
			set FRAME_MINIMAP = BlzGetOriginFrame(ORIGIN_FRAME_MINIMAP,0)
			call BlzFrameSetVisible(FRAME_MINIMAP,true)
			call BlzFrameClearAllPoints(FRAME_MINIMAP)
			call BlzFrameSetPoint(FRAME_MINIMAP,FRAMEPOINT_BOTTOMLEFT,FRAME_ORIGIN,FRAMEPOINT_BOTTOMLEFT,/*
				*/Math.px2Size(MINIMAP_OFFSET_X+MINIMAP_BORDER),Math.px2Size(MINIMAP_OFFSET_Y+MINIMAP_BORDER))
			call BlzFrameSetPoint(FRAME_MINIMAP,FRAMEPOINT_TOPRIGHT,FRAME_ORIGIN,FRAMEPOINT_BOTTOMLEFT,/*
				*/Math.px2Size(MINIMAP_OFFSET_X+MINIMAP_BORDER+MINIMAP_SIZE),Math.px2Size(MINIMAP_OFFSET_Y+MINIMAP_BORDER+MINIMAP_SIZE))
			set FRAME_MINIMAP_BACKDROP = BlzCreateFrameByType("BACKDROP","",BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME,0),"",0)
			call BlzFrameSetPoint(FRAME_MINIMAP_BACKDROP,FRAMEPOINT_BOTTOMLEFT,FRAME_ORIGIN,FRAMEPOINT_BOTTOMLEFT,/*
				*/Math.px2Size(MINIMAP_OFFSET_X),Math.px2Size(MINIMAP_OFFSET_Y))
			call BlzFrameSetSize(FRAME_MINIMAP_BACKDROP,Math.px2Size(MINIMAP_SIZE+MINIMAP_BORDER*2),Math.px2Size(MINIMAP_SIZE+MINIMAP_BORDER*2))
			call BlzFrameSetTexture(FRAME_MINIMAP_BACKDROP,"ReplaceableTextures\\teamcolor\\teamcolor27.blp",0,true)
			call BlzFrameSetAlpha(FRAME_MINIMAP_BACKDROP,128)
			/*포트레이트*/
			set FRAME_PORTRAIT_BACKDROP = BlzCreateFrameByType("BACKDROP","",BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME,0),"",0)
			call BlzFrameSetPoint(FRAME_PORTRAIT_BACKDROP,FRAMEPOINT_TOPLEFT,FRAME_ORIGIN,FRAMEPOINT_BOTTOM,/*
				*/Math.px2Size(PORTRAIT_OFFSET_X),Math.px2Size(PORTRAIT_OFFSET_Y+PORTRAIT_BORDER+PORTRAIT_SIZE))
			call BlzFrameSetSize(FRAME_PORTRAIT_BACKDROP,Math.px2Size(PORTRAIT_SIZE),Math.px2Size(PORTRAIT_SIZE))
			call BlzFrameSetTexture(FRAME_PORTRAIT_BACKDROP,"ReplaceableTextures\\teamcolor\\teamcolor27.blp",0,true)
			call BlzFrameSetAlpha(FRAME_PORTRAIT_BACKDROP,128)
			set FRAME_PORTRAIT = BlzGetOriginFrame(ORIGIN_FRAME_PORTRAIT,0)
			call BlzFrameSetVisible(FRAME_PORTRAIT,true)
			call BlzFrameClearAllPoints(FRAME_PORTRAIT)
			call BlzFrameSetAbsPoint(FRAME_PORTRAIT,FRAMEPOINT_TOPLEFT,Math.px2Size((1920/2)+PORTRAIT_OFFSET_X)*0.75,Math.px2Size(PORTRAIT_OFFSET_Y+PORTRAIT_BORDER+PORTRAIT_SIZE))
			call BlzFrameSetAbsPoint(FRAME_PORTRAIT,FRAMEPOINT_BOTTOMRIGHT,Math.px2Size((1920/2)+PORTRAIT_SIZE+PORTRAIT_OFFSET_X)*0.75,Math.px2Size(PORTRAIT_OFFSET_Y+PORTRAIT_BORDER))
			/*체력바 마나바*/
			set FRAME_HP_BAR = BlzCreateFrameByType("BACKDROP","",FRAME_GAME_UI,"",0)
			call BlzFrameSetPoint(FRAME_HP_BAR,FRAMEPOINT_BOTTOMLEFT,FRAME_ORIGIN,FRAMEPOINT_BOTTOM,/*
				*/Math.px2Size(-BAR_WIDTH/2),Math.px2Size(HP_BAR_OFFSET_Y))
			call BlzFrameSetSize(FRAME_HP_BAR,Math.px2Size(BAR_WIDTH),Math.px2Size(BAR_HEIGHT))
			call BlzFrameSetTexture(FRAME_HP_BAR,"ReplaceableTextures\\teamcolor\\teamcolor10.blp",0,true)
			call BlzFrameSetAlpha(FRAME_HP_BAR,96)
			set FRAME_MP_BAR = BlzCreateFrameByType("BACKDROP","",FRAME_GAME_UI,"",0)
			call BlzFrameSetPoint(FRAME_MP_BAR,FRAMEPOINT_BOTTOMLEFT,FRAME_ORIGIN,FRAMEPOINT_BOTTOM,/*
				*/Math.px2Size(-BAR_WIDTH/2),Math.px2Size(MP_BAR_OFFSET_Y))
			call BlzFrameSetSize(FRAME_MP_BAR,Math.px2Size(BAR_WIDTH),Math.px2Size(BAR_HEIGHT))
			call BlzFrameSetTexture(FRAME_MP_BAR,"ReplaceableTextures\\teamcolor\\teamcolor13.blp",0,true)
			call BlzFrameSetAlpha(FRAME_MP_BAR,96)
			/*어빌리티박스*/
			set FRAME_ABILITY_CONTAINER = BlzCreateFrameByType("BACKDROP","",FRAME_GAME_UI,"",0)
			call BlzFrameSetPoint(FRAME_ABILITY_CONTAINER,FRAMEPOINT_BOTTOMLEFT,FRAME_ORIGIN,FRAMEPOINT_BOTTOM,/*
				*/Math.px2Size(-ABILITY_CONTAINER_WIDTH/2),Math.px2Size(ABILITY_CONTAINER_OFFSET_Y))
			call BlzFrameSetSize(FRAME_ABILITY_CONTAINER,Math.px2Size(ABILITY_CONTAINER_WIDTH),Math.px2Size(ABILITY_CONTAINER_HEIGHT))
			call BlzFrameSetTexture(FRAME_ABILITY_CONTAINER,"Textures\\Black32.blp",0,true)
			call BlzFrameSetAlpha(FRAME_ABILITY_CONTAINER,128)
			/*어빌아이콘*/
			loop
				exitwhen i >= 10
				set FRAME_ABILITY_ICON[i] = BlzCreateFrameByType("BACKDROP","",FRAME_GAME_UI,"",0)
				call BlzFrameSetPoint(FRAME_ABILITY_ICON[i],FRAMEPOINT_TOPLEFT,FRAME_ABILITY_CONTAINER,FRAMEPOINT_TOPLEFT,/*
					*/c_inset+(c_padding/2.)+(i*c_cell),/*
					*/Math.px2Size(-(ABILITY_CONTAINER_HEIGHT-ABILITY_ICON_SIZE)/2))
				call BlzFrameSetSize(FRAME_ABILITY_ICON[i],Math.px2Size(ABILITY_ICON_SIZE),Math.px2Size(ABILITY_ICON_SIZE))
				call BlzFrameSetTexture(FRAME_ABILITY_ICON[i],"ReplaceableTextures\\CommandButtons\\BTNBlackIcon.blp",0,true)
				set i = i + 1
			endloop
			/*스탯박스1*/
			set FRAME_STAT1 = BlzCreateFrameByType("BACKDROP","",FRAME_GAME_UI,"",0)
			call BlzFrameSetPoint(FRAME_STAT1,FRAMEPOINT_TOPLEFT,FRAME_PORTRAIT_BACKDROP,FRAMEPOINT_TOPRIGHT,0.,0.)
			call BlzFrameSetPoint(FRAME_STAT1,FRAMEPOINT_BOTTOMRIGHT,FRAME_PORTRAIT_BACKDROP,FRAMEPOINT_BOTTOMRIGHT,Math.px2Size(STAT1_WIDTH),0.)
			call BlzFrameSetTexture(FRAME_STAT1,"replaceabletextures\\teamcolor\\teamcolor27.blp",0,true)
			call BlzFrameSetAlpha(FRAME_STAT1,200)
			set FRAME_STAT2 = BlzCreateFrameByType("BACKDROP","",FRAME_GAME_UI,"",0)
			call BlzFrameSetPoint(FRAME_STAT2,FRAMEPOINT_TOPLEFT,FRAME_STAT1,FRAMEPOINT_TOPRIGHT,0.,0.)
			call BlzFrameSetPoint(FRAME_STAT2,FRAMEPOINT_BOTTOMRIGHT,FRAME_HP_BAR,FRAMEPOINT_TOPRIGHT,0.,0.)
			call BlzFrameSetTexture(FRAME_STAT2,"Textures\\Black32.blp",0,true)
			call BlzFrameSetAlpha(FRAME_STAT2,128)
			/*경험치바*/
			set FRAME_EXP_BAR = BlzCreateFrameByType("BACKDROP","",FRAME_GAME_UI,"",0)
			call BlzFrameSetPoint(FRAME_EXP_BAR,FRAMEPOINT_BOTTOMLEFT,FRAME_STAT1,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			call BlzFrameSetPoint(FRAME_EXP_BAR,FRAMEPOINT_TOPRIGHT,FRAME_STAT1,FRAMEPOINT_BOTTOMRIGHT,0.,Math.px2Size(EXP_BAR_HEIGHT))
			call BlzFrameSetTexture(FRAME_EXP_BAR,"replaceabletextures\\teamcolor\\teamcolor03.blp",0,true)
			/*포션제조*/
			set FRAME_MAKE_POTION = BlzCreateFrameByType("FRAME","",FRAME_GAME_UI,"",0)
			call BlzFrameSetPoint(FRAME_MAKE_POTION,FRAMEPOINT_TOPLEFT,FRAME_ORIGIN,FRAMEPOINT_TOPLEFT,0,0)
			/*스킬상점*/
			set FRAME_SKILL_SHOP_BACKDROP = BlzCreateFrame("EMEdge",FRAME_GAME_UI,0,0)
			call BlzFrameSetPoint(FRAME_SKILL_SHOP_BACKDROP,FRAMEPOINT_TOP,FRAME_ORIGIN,FRAMEPOINT_TOP,0.,Math.px2Size(SKILL_SHOP_OFFSET_Y))
			call BlzFrameSetSize(FRAME_SKILL_SHOP_BACKDROP,Math.px2Size(SKILL_SHOP_WIDTH),Math.px2Size(SKILL_SHOP_HEIGHT))
			set f = BlzCreateFrame("MyTextBox",FRAME_SKILL_SHOP_BACKDROP,0,0)
			set bf = f
			set f = BlzCreateFrame("MyTextLarge",FRAME_SKILL_SHOP_BACKDROP,0,0)
			call BlzFrameSetPoint(f,FRAMEPOINT_BOTTOM,FRAME_SKILL_SHOP_BACKDROP,FRAMEPOINT_TOP,0.,-0.0125)
			call BlzFrameSetTextAlignment(f,TEXT_JUSTIFY_BOTTOM,TEXT_JUSTIFY_CENTER)
			call BlzFrameSetText(f,"상점")
			call BlzFrameSetPoint(bf,FRAMEPOINT_BOTTOMLEFT,f,FRAMEPOINT_BOTTOMLEFT,-0.005,-0.005)
			call BlzFrameSetPoint(bf,FRAMEPOINT_TOPRIGHT,f,FRAMEPOINT_TOPRIGHT,0.005,0.005)
			set FRAME_SKILL_SHOP = BlzCreateFrameByType("BACKDROP","",FRAME_GAME_UI,"",0)
			call BlzFrameSetPoint(FRAME_SKILL_SHOP,FRAMEPOINT_TOP,FRAME_SKILL_SHOP_BACKDROP,FRAMEPOINT_TOP,0.,-Math.px2Size(SKILL_SHOP_INSET))
			call BlzFrameSetSize(FRAME_SKILL_SHOP,Math.px2Size(SKILL_SHOP_WIDTH-SKILL_SHOP_INSET*2),Math.px2Size(SKILL_SHOP_HEIGHT-SKILL_SHOP_INSET*2))
			call BlzFrameSetAlpha(FRAME_SKILL_SHOP,0)
			call BlzFrameSetVisible(FRAME_SKILL_SHOP_BACKDROP,false)
			/*슬롯체인저*/
			set FRAME_SLOT_CHANGER = BlzCreateFrame("MBEdge",FRAME_GAME_UI,0,0)
			call BlzFrameSetPoint(FRAME_SLOT_CHANGER,FRAMEPOINT_CENTER,FRAME_ORIGIN,FRAMEPOINT_CENTER,0.,Math.px2Size(SLOT_CHANGER_OFFSET_Y))
			call BlzFrameSetSize(FRAME_SLOT_CHANGER,Math.px2Size(SLOT_CHANGER_WIDTH),Math.px2Size(SLOT_CHANGER_HEIGHT))
			call BlzFrameSetVisible(FRAME_SLOT_CHANGER,false)
			set f = BlzCreateFrame("MyTextBox",FRAME_SLOT_CHANGER,0,0)
			set bf = f
			set f = BlzCreateFrame("MyText",FRAME_SLOT_CHANGER,0,0)
			call BlzFrameSetPoint(f,FRAMEPOINT_BOTTOM,FRAME_SLOT_CHANGER,FRAMEPOINT_TOP,0.,0.)
			call BlzFrameSetTextAlignment(f,TEXT_JUSTIFY_BOTTOM,TEXT_JUSTIFY_CENTER)
			call BlzFrameSetText(f,"단축키 변경")
			call BlzFrameSetPoint(bf,FRAMEPOINT_BOTTOMLEFT,f,FRAMEPOINT_BOTTOMLEFT,-0.005,-0.005)
			call BlzFrameSetPoint(bf,FRAMEPOINT_TOPRIGHT,f,FRAMEPOINT_TOPRIGHT,0.005,0.005)
			/*버튼*/
			set FRAME_INVENTORY_BUTTON = BlzCreateFrame("InventoryUIButton",FRAME_GAME_UI,0,0)
			call BlzFrameSetPointPixel(FRAME_INVENTORY_BUTTON,FRAMEPOINT_BOTTOMLEFT,FRAME_ABILITY_CONTAINER,FRAMEPOINT_BOTTOMRIGHT,16,0)
			call BlzFrameSetSizePixel(FRAME_INVENTORY_BUTTON,192,48)
			set f = BlzGetFrameByName("InventoryUIButtonText",0)
			call BlzFrameSetPointPixel(f,FRAMEPOINT_CENTER,FRAME_INVENTORY_BUTTON,FRAMEPOINT_CENTER,8,0)
			call BlzFrameSetText(f,"|cffffcc00소지품|r |cffffffff(B)|r")
			set FRAME_SLOT_CHANGER_BUTTON = BlzCreateFrame("SlotChangerUIButton",FRAME_GAME_UI,0,0)
			call BlzFrameSetPointPixel(FRAME_SLOT_CHANGER_BUTTON,FRAMEPOINT_BOTTOMLEFT,FRAME_INVENTORY_BUTTON,FRAMEPOINT_TOPLEFT,0,8)
			call BlzFrameSetSizePixel(FRAME_SLOT_CHANGER_BUTTON,192,48)
			set f = BlzGetFrameByName("SlotChangerUIButtonText",0)
			call BlzFrameSetPointPixel(f,FRAMEPOINT_CENTER,FRAME_SLOT_CHANGER_BUTTON,FRAMEPOINT_CENTER,8,0)
			call BlzFrameSetText(f,"|cffffcc00단축키 변경|r |cffffffff(G)|r")
			set FRAME_SKILL_SHOP_BUTTON = BlzCreateFrame("SkillShopUIButton",FRAME_GAME_UI,0,0)
			call BlzFrameSetPointPixel(FRAME_SKILL_SHOP_BUTTON,FRAMEPOINT_BOTTOMLEFT,FRAME_SLOT_CHANGER_BUTTON,FRAMEPOINT_TOPLEFT,0,8)
			call BlzFrameSetSizePixel(FRAME_SKILL_SHOP_BUTTON,192,48)
			set f = BlzGetFrameByName("SkillShopUIButtonText",0)
			call BlzFrameSetPointPixel(f,FRAMEPOINT_CENTER,FRAME_SKILL_SHOP_BUTTON,FRAMEPOINT_CENTER,8,0)
			call BlzFrameSetText(f,"|cffffcc00상점|r |cffffffff(T)|r")
			set FRAME_BUTTON_TRIGGER = CreateTrigger()
			call BlzTriggerRegisterFrameEvent(FRAME_BUTTON_TRIGGER,FRAME_INVENTORY_BUTTON,FRAMEEVENT_CONTROL_CLICK)
			call BlzTriggerRegisterFrameEvent(FRAME_BUTTON_TRIGGER,FRAME_INVENTORY_BUTTON,FRAMEEVENT_MOUSE_LEAVE)
			call BlzTriggerRegisterFrameEvent(FRAME_BUTTON_TRIGGER,FRAME_SLOT_CHANGER_BUTTON,FRAMEEVENT_CONTROL_CLICK)
			call BlzTriggerRegisterFrameEvent(FRAME_BUTTON_TRIGGER,FRAME_SLOT_CHANGER_BUTTON,FRAMEEVENT_MOUSE_LEAVE)
			call BlzTriggerRegisterFrameEvent(FRAME_BUTTON_TRIGGER,FRAME_SKILL_SHOP_BUTTON,FRAMEEVENT_CONTROL_CLICK)
			call BlzTriggerRegisterFrameEvent(FRAME_BUTTON_TRIGGER,FRAME_SKILL_SHOP_BUTTON,FRAMEEVENT_MOUSE_LEAVE)
			call TriggerAddCondition(FRAME_BUTTON_TRIGGER,function thistype.genericButtonAction)
			/*핸들프리*/
			set bf = null
			set f = null
			set t = null
		endmethod

		private static method refreshCond takes nothing returns nothing
			local thistype this = THIS[GetPlayerId(ABILITY_UI_REFRESH_PLAYER)]
			if this > 0 then
				call refreshAbilityIconsTarget()
			endif
		endmethod

		private static method onInit takes nothing returns nothing
			set INDEX_ABILITY_ICON = 0
			set INDEX_STAT_ICON = INDEX_ABILITY_ICON + 10
			set INDEX_BUFF_ICON = INDEX_STAT_ICON + 16
			set INDEX_SKILL_SHOP_WIDGET = INDEX_BUFF_ICON + 8
			set INDEX_SLOT_CHANGER_WIDGET = INDEX_SKILL_SHOP_WIDGET + 5
			set INDEX_SLOT_CHANGER_BUTTON = INDEX_SLOT_CHANGER_WIDGET + 10
			set INDEX_SLOT_CHANGER_ICON	= INDEX_SLOT_CHANGER_BUTTON + 10
			set INDEX_SLOT_CHANGER_INDEX = INDEX_SLOT_CHANGER_ICON + 10
			set INDEX_SLOT_CHANGER_HOTKEY = INDEX_SLOT_CHANGER_INDEX + 10
			call TriggerAddCondition(ERROR_MESSAGE_TRIGGER,function thistype.abilityErrorCondition)
			call TriggerAddCondition(ABILITY_UI_REFRESH,function thistype.refreshCond)
		endmethod

	endstruct

endlibrary

//! import "SkillShop.j"
//! import "CloseUI.j"
//! import "SlotChanger.j"