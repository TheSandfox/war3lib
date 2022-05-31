library BattleUI requires Character

	//! textmacro setElementTypeIconPath takes num
		if bm.element_type$num$ == ELEMENT_TYPE_MODIFIED1 then
			/*속성변형1*/
			call BlzFrameSetModel(.ability_box_element_type_icon$num$[i].model,ELEMENT_TYPE_ICON_PATH[.display_target.element_type1],0)
		elseif bm.element_type$num$ == ELEMENT_TYPE_MODIFIED2 then
			/*속성변형2*/
			call BlzFrameSetModel(.ability_box_element_type_icon$num$[i].model,ELEMENT_TYPE_ICON_PATH[.display_target.element_type2],0)
		elseif bm.element_type$num$ != ELEMENT_TYPE_UNDEFINED then
			/*그 외*/
			call BlzFrameSetModel(.ability_box_element_type_icon$num$[i].model,ELEMENT_TYPE_ICON_PATH[bm.element_type$num$],0)
		endif
	//! endtextmacro

	//! textmacro setAbilityBoxTexturePath
		if bm.element_type1 == ELEMENT_TYPE_MODIFIED1 then
			/*속성변형1*/
			call BlzFrameSetTexture(.ability_box[i],ABILITY_BOX_TEXTURE_PATH[.display_target.element_type1],0,true)
		elseif bm.element_type1 == ELEMENT_TYPE_MODIFIED2 then
			/*속성변형2*/
			call BlzFrameSetTexture(.ability_box[i],ABILITY_BOX_TEXTURE_PATH[.display_target.element_type2],0,true)
		elseif bm.element_type1 != ELEMENT_TYPE_UNDEFINED then
			/*그 외*/
			call BlzFrameSetTexture(.ability_box[i],ABILITY_BOX_TEXTURE_PATH[bm.element_type1],0,true)
		endif
	//! endtextmacro

	struct BattleUI

		static hashtable HASH = InitHashtable()
		static constant integer STATE_TIME_ELAPSE = 0
		static constant integer STATE_SELECT_ABILITY = 1
		static constant integer STATE_SELECT_TARGET = 2
		/*FROM BOTTOMRIGHT*/
		private static constant integer ABILITY_BOX_X_OFFSET 	= -96
		private static constant integer ABILITY_BOX_Y_OFFSET 	= 18
		private static constant integer ABILITY_BOX_WIDTH 		= 224
		private static constant integer ABILITY_BOX_HEIGHT		= 84
		private static constant integer ABILITY_BOX_PADDING 	= 18
		static constant integer ABILITY_BOX_BOX_PER_ROW = 2

		private static constant integer MONSTER_BOX_ICON_INSET  = 8
		private static constant integer MONSTER_BOX_WIDTH = 640
		private static constant integer MONSTER_BOX_HEIGHT = 88
		private static constant integer MONSTER_BOX_ICON_SIZE = 48
		private static constant integer MONSTER_BOX_ICON_PADDING = 8 
		/*INITIALIZE AT onInit()*/
		private static integer INDEX_MONSTER_BOX_ICON = 0
		private static integer INDEX_MONSTER_BOX_NAME = 0
		private static integer INDEX_MONSTER_BOX_HP_BG = 0
		private static integer INDEX_MONSTER_BOX_HP_FILL = 0
		private static integer INDEX_MONSTER_BOX_HP_TEXT = 0
		private static integer INDEX_MONSTER_BOX_AP_BG = 0
		private static integer INDEX_MONSTER_BOX_AP_FILL = 0
		private static integer INDEX_MONSTER_BOX_TARGET = 0

		private static constant integer AP_GAUGE_Y_OFFSET 		= 8
		private static constant integer AP_GAUGE_HEIGHT 		= 16

		private static constant integer TIME_INDICATOR_SIZE 	= 80
		private static constant integer TIME_INDICATOR_Y_OFFSET = -12	/*FROM TOP_MIDDLE*/

		player owner = null
		framehandle container = null
		framehandle ability_box_container 		= null
		framehandle ability_box_bg 				= null
		framehandle ability_box_tooltip 		= null
		framehandle ability_box_tooltip_text 	= null
		framehandle array ability_box[MONSTER_ABILITY_COUNT_MAX]
		framehandle array ability_box_name[MONSTER_ABILITY_COUNT_MAX]
		framehandle array ability_box_ap_cost_bg[MONSTER_ABILITY_COUNT_MAX]
		framehandle array ability_box_ap_cost_text[MONSTER_ABILITY_COUNT_MAX]
		ElementTypeIcon array ability_box_element_type_icon1[MONSTER_ABILITY_COUNT_MAX]
		ElementTypeIcon array ability_box_element_type_icon2[MONSTER_ABILITY_COUNT_MAX]
		framehandle ability_box_cursor = null
		framehandle array time_indicator[3]
		framehandle name = null

		framehandle monster_box_container = null
		framehandle monster_box_bg1 = null
		framehandle monster_box_bg2 = null
		framehandle monster_box_cursor = null

		integer state = 0		/*0: 대기, 1: 어빌리티 선택*/
		integer array cursor[4]
		integer array cursor_max[4]
		BattleMonster display_target = 0

		method setFrame takes integer i, framehandle f returns framehandle
			if f == null then
				call BlzDestroyFrame(LoadFrameHandle(HASH,this,i))
				call SaveFrameHandle(HASH,this,i,null)
			else
				call SaveFrameHandle(HASH,this,i,f)
			endif
			return f
		endmethod

		method getFrame takes integer i returns framehandle
			return LoadFrameHandle(HASH,this,i)
		endmethod

		method refreshSelectBox takes nothing returns nothing
			local Profile pr = Profile.getPlayerProfile(.owner)
			local Monster m = 0
			local integer i = 0
			loop
				exitwhen i >= Party.PARTY_SIZE
				set m = Party.getMonster(pr,i)
				if m != 0 then
					call BlzFrameSetTexture(getFrame(INDEX_MONSTER_BOX_ICON+i),m.icon_path,0,true)
					call BlzFrameSetText(getFrame(INDEX_MONSTER_BOX_NAME+i),"Lv."+I2S(m.level)+" "+m.name)
				endif
				set i = i + 1
			endloop
		endmethod

		method setStateSelectTarget takes nothing returns nothing
			set .state = STATE_SELECT_TARGET
			call BlzFrameSetVisible(.ability_box_container,false)
		endmethod

		method setStateSelectAbility takes nothing returns nothing
			set .state = STATE_SELECT_ABILITY
			call BlzFrameSetVisible(.ability_box_container,true)
		endmethod

		method setStateNormal takes nothing returns nothing
			set .state = STATE_TIME_ELAPSE
			call BlzFrameSetVisible(.ability_box_container,false)
			call BlzFrameSetVisible(.monster_box_cursor,false)
		endmethod

		method refreshAbilityCursor takes integer index returns nothing
			local BattleMonsterAbility bma = 0
			set .cursor[0] = index
			call BlzFrameSetPoint(.ability_box_cursor,FRAMEPOINT_CENTER,.ability_box[.cursor[0]],FRAMEPOINT_CENTER,0.,0.)
			set bma = .display_target.getBattleMonsterAbility(.cursor[0])
			if bma != 0 then
				call BlzFrameSetText(.ability_box_tooltip_text,bma.name+" ("+ELEMENT_TYPE_NAME[bma.element_type1]+"/"+ELEMENT_TYPE_NAME[bma.element_type2]+")\n\n"+bma.description)
			endif
		endmethod

		method refreshTargetCursor takes integer index returns nothing
			set .cursor[1] = index
		endmethod

		method refreshTimeIndicator takes real value, boolean brighten returns nothing
			/*시간표시기 리프레시*/
			call BlzFrameSetText(.time_indicator[2],R2SW(value,1,1))
			if brighten then
				call BlzFrameSetAlpha(.time_indicator[0],255)
			else
				call BlzFrameSetAlpha(.time_indicator[0],128)
			endif
		endmethod

		method refreshHPGauge takes nothing returns nothing
			local integer i = 0 
			local BattleMonster bm = 0
			local real r = 0.
			loop
				exitwhen  i >= Party.PARTY_SIZE * 2
				set bm = LoadInteger(HASH,this,INDEX_MONSTER_BOX_TARGET+i)
				if bm > 0 then
					set r = bm.hp/bm.getCarculatedStat(STAT_TYPE_MAXHP)
					if r > 1. then
						call BlzFrameSetSize(getFrame(INDEX_MONSTER_BOX_HP_FILL+i),BlzFrameGetWidth(getFrame(INDEX_MONSTER_BOX_HP_BG+i)),Math.px2Size(8))
						call BlzFrameSetVisible(getFrame(INDEX_MONSTER_BOX_HP_FILL+i),true)
					elseif r > 0. then
						call BlzFrameSetSize(getFrame(INDEX_MONSTER_BOX_HP_FILL+i),BlzFrameGetWidth(getFrame(INDEX_MONSTER_BOX_HP_BG+i))*r,Math.px2Size(8))
						call BlzFrameSetVisible(getFrame(INDEX_MONSTER_BOX_HP_FILL+i),true)
					else
						call BlzFrameSetVisible(getFrame(INDEX_MONSTER_BOX_HP_FILL+i),false)
					endif
					if i < Party.PARTY_SIZE then
						call BlzFrameSetText(getFrame(INDEX_MONSTER_BOX_HP_TEXT+i),I2S(R2I(bm.hp))+" / "+I2S(R2I(bm.getCarculatedStat(STAT_TYPE_MAXHP))))
					endif
				endif
				set i = i + 1
			endloop
		endmethod

		method refreshAPGauge takes nothing returns nothing
			local integer i = 0 
			local BattleMonster bm = 0
			local real r = 0.
			loop
				exitwhen  i >= Party.PARTY_SIZE * 2
				set bm = LoadInteger(HASH,this,INDEX_MONSTER_BOX_TARGET+i)
				if bm > 0 then
					set r = bm.ap/100.
					if r >= 1. then
						call BlzFrameSetSize(getFrame(INDEX_MONSTER_BOX_AP_FILL+i),BlzFrameGetWidth(getFrame(INDEX_MONSTER_BOX_AP_BG+i)),Math.px2Size(8))
						call BlzFrameSetVisible(getFrame(INDEX_MONSTER_BOX_AP_FILL+i),true)
						call BlzFrameSetAlpha(getFrame(INDEX_MONSTER_BOX_AP_FILL+i),255)
					elseif r > 0. then
						call BlzFrameSetSize(getFrame(INDEX_MONSTER_BOX_AP_FILL+i),BlzFrameGetWidth(getFrame(INDEX_MONSTER_BOX_AP_BG+i))*r,Math.px2Size(8))
						call BlzFrameSetVisible(getFrame(INDEX_MONSTER_BOX_AP_FILL+i),true)
						call BlzFrameSetAlpha(getFrame(INDEX_MONSTER_BOX_AP_FILL+i),64)
					else
						call BlzFrameSetVisible(getFrame(INDEX_MONSTER_BOX_AP_FILL+i),false)
					endif
				endif
				set i = i + 1
			endloop
		endmethod

		method setMonsterBoxTarget takes BattleMonster m1, BattleMonster m2, BattleMonster m3, BattleMonster m4, BattleMonster m5, boolean flag returns nothing
			local integer i = 0
			local integer j = 0
			local BattleMonster bm = 0
			if flag then
				call SaveInteger(HASH,this,INDEX_MONSTER_BOX_TARGET+0,m1)
				call SaveInteger(HASH,this,INDEX_MONSTER_BOX_TARGET+1,m2)
				call SaveInteger(HASH,this,INDEX_MONSTER_BOX_TARGET+2,m3)
				call SaveInteger(HASH,this,INDEX_MONSTER_BOX_TARGET+3,m4)
				call SaveInteger(HASH,this,INDEX_MONSTER_BOX_TARGET+4,m5)
			else
				call SaveInteger(HASH,this,INDEX_MONSTER_BOX_TARGET+0+Party.PARTY_SIZE,m1)
				call SaveInteger(HASH,this,INDEX_MONSTER_BOX_TARGET+1+Party.PARTY_SIZE,m2)
				call SaveInteger(HASH,this,INDEX_MONSTER_BOX_TARGET+2+Party.PARTY_SIZE,m3)
				call SaveInteger(HASH,this,INDEX_MONSTER_BOX_TARGET+3+Party.PARTY_SIZE,m4)
				call SaveInteger(HASH,this,INDEX_MONSTER_BOX_TARGET+4+Party.PARTY_SIZE,m5)
				set j = Party.PARTY_SIZE
			endif
			loop
				exitwhen i >= Party.PARTY_SIZE
				set bm = LoadInteger(HASH,this,INDEX_MONSTER_BOX_TARGET+i+j)
				if bm > 0 then
					call BlzFrameSetTexture(getFrame(INDEX_MONSTER_BOX_ICON+i+j),bm.icon_path,0,true)
					call BlzFrameSetText(getFrame(INDEX_MONSTER_BOX_NAME+i+j),"Lv."+I2S(bm.level)+"\n"+bm.name)
				else
					call BlzFrameSetVisible(getFrame(INDEX_MONSTER_BOX_NAME+i+j),false)
					call BlzFrameSetVisible(getFrame(INDEX_MONSTER_BOX_ICON+i+j),false)
					call BlzFrameSetVisible(getFrame(INDEX_MONSTER_BOX_HP_FILL+i+j),false)
					call BlzFrameSetVisible(getFrame(INDEX_MONSTER_BOX_AP_FILL+i+j),false)
					if i+j < Party.PARTY_SIZE then
						call BlzFrameSetVisible(getFrame(INDEX_MONSTER_BOX_HP_TEXT+i+j),true)
					endif
				endif
				set i = i + 1
			endloop
		endmethod

		method refreshHighlight takes BattleMonster bm returns nothing
			local BattleMonster m = 0
			local integer i = 0
			/*상단 몬스터박스 하이라이트*/
			loop
				exitwhen i >= Party.PARTY_SIZE * 2
				set m = LoadInteger(HASH,this,INDEX_MONSTER_BOX_TARGET+i)
				if m == bm then
					call BlzFrameSetVisible(.monster_box_cursor,true)
					call BlzFrameSetPoint(.monster_box_cursor,FRAMEPOINT_TOPLEFT,getFrame(INDEX_MONSTER_BOX_ICON+i),FRAMEPOINT_TOPLEFT,Math.px2Size(-MONSTER_BOX_ICON_INSET),Math.px2Size(MONSTER_BOX_ICON_INSET))
					exitwhen true
				endif
				set i = i + 1
			endloop
		endmethod

		method setDisplayTarget takes BattleMonster nt returns nothing
			local integer i = 0
			local BattleMonsterAbility bm = 0
			set .display_target = nt
			/*이름&레벨*/
			call BlzFrameSetText(.name,"Lv."+I2S(.display_target.level)+" "+.display_target.name)
			loop
				exitwhen i >= MONSTER_ABILITY_COUNT_MAX
				set bm = .display_target.getBattleMonsterAbility(i)
				/*속성아이콘 가시성처리*/
				call BlzFrameSetVisible(ability_box_element_type_icon1[i].model, /*
					*/.display_target !=0 and /*
					*/bm != 0 /*
				*/)
				call BlzFrameSetVisible(ability_box_element_type_icon2[i].model, /*
					*/.display_target !=0 and /*
					*/bm != 0 /*
				*/)
				/*속성아이콘 모델 제어*/
				//! runtextmacro setElementTypeIconPath("1")
				//! runtextmacro setElementTypeIconPath("2")
				/*박스 텍스쳐 변경*/
				//! runtextmacro setAbilityBoxTexturePath()
				/*AP코스트 프레임 가시성처리*/
				call BlzFrameSetVisible(.ability_box_ap_cost_text[i],bm!=0)
				call BlzFrameSetVisible(.ability_box_ap_cost_bg[i],bm!=0)
				if bm != 0 then
					/*기술이름 프레임 갱신*/
					call BlzFrameSetText(.ability_box_name[i],bm.name)
					/*AP코스트 프레임 갱신*/
					call BlzFrameSetText(.ability_box_ap_cost_text[i],I2S(R2I(bm.ap_cost)))
				endif
				/**/
				set i = i + 1
			endloop
			/*커서 위치가 빈 어빌리티면 리셋시켜주기*/
			if .display_target == 0 or .display_target.getBattleMonsterAbility(.cursor[0]) == 0 then
				call refreshAbilityCursor(0)
			else
				call refreshAbilityCursor(cursor[0])
			endif
		endmethod

		static method create takes player forplayer returns thistype
			local thistype this = allocate()
			local integer i = 0
			local integer j = 0
			local framehandle f = null
			local framehandle bf = null
			set .owner = forplayer
			set .container = BlzCreateFrameByType("FRAME","",UI.SURFACE_BATTLE_UI,"",0)
			set .ability_box_container = BlzCreateFrameByType("FRAME","",.container,"",0)
			/*커서 초기화*/
			set .cursor[0] = 0
			set .cursor[1] = 0
			set .cursor[2] = 0
			set .cursor[3] = 0
			set .cursor_max[0] = 4
			set .cursor_max[1] = 32
			set .cursor_max[2] = 32
			set .cursor_max[3] = 32
			/*어빌박스 배경*/
			set .ability_box_bg = BlzCreateFrameByType("BACKDROP","",.ability_box_container,"",0)
			call BlzFrameSetTexture(.ability_box_bg,"Textures\\ui_grad1.blp",0,true)
			call BlzFrameSetAlpha(.ability_box_bg,128)
			/*어빌박스 커서*/
			set .ability_box_cursor = BlzCreateFrameByType("BACKDROP","",.ability_box_container,"",0)
			call BlzFrameSetSize(.ability_box_cursor,Math.px2Size(ABILITY_BOX_WIDTH)*0.8,Math.px2Size(ABILITY_BOX_HEIGHT)*0.66)
			call BlzFrameSetTexture(.ability_box_cursor,"Textures\\GenericGlow1.blp",0,true)
			call BlzFrameSetAlpha(.ability_box_cursor,212)
			/*어빌리티박스*/
			loop
				exitwhen i >= MONSTER_ABILITY_COUNT_MAX
				/*어빌박스*/
				set j = MONSTER_ABILITY_COUNT_MAX-1-i /*거꾸로인덱스*/
				set .ability_box[j] = BlzCreateFrameByType("BACKDROP","",.ability_box_container,"",0)
				set f = .ability_box[j]
				call BlzFrameSetPoint(f,FRAMEPOINT_BOTTOMRIGHT,UI.ORIGIN,FRAMEPOINT_BOTTOMRIGHT,/*
					*/Math.px2Size( ABILITY_BOX_X_OFFSET-((ABILITY_BOX_WIDTH+ABILITY_BOX_PADDING)*ModuloInteger(i,ABILITY_BOX_BOX_PER_ROW)) ),/*
					*/Math.px2Size( ABILITY_BOX_Y_OFFSET+((ABILITY_BOX_HEIGHT+ABILITY_BOX_PADDING)*R2I(i/ABILITY_BOX_BOX_PER_ROW)) )/*
				*/)
				call BlzFrameSetSize(f,Math.px2Size(ABILITY_BOX_WIDTH),Math.px2Size(ABILITY_BOX_HEIGHT))
				call BlzFrameSetAlpha(f,144)
				/*타입아이콘*/
				set .ability_box_element_type_icon1[j] = ElementTypeIcon.create("ui\\element_type_icon_hex_normal.mdl", .ability_box_container, f, FRAMEPOINT_TOPRIGHT,-48, -40)
				set .ability_box_element_type_icon2[j] = ElementTypeIcon.create("ui\\element_type_icon_hex_fire.mdl", .ability_box_container, f, FRAMEPOINT_BOTTOMRIGHT, -48, -4)
				/*기술이름*/
				set .ability_box_name[j] = BlzCreateFrame("MyText",.ability_box_container,0,0)
				call BlzFrameSetAllPoints(.ability_box_name[j],.ability_box[j])
				call BlzFrameSetTextAlignment(.ability_box_name[j],TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
				call BlzFrameSetText(.ability_box_name[j],"")
				/*AP 코스트 표시기*/
				set .ability_box_ap_cost_bg[j] = BlzCreateFrameByType("BACKDROP","",.ability_box_container,"",0)
				call BlzFrameSetPoint(.ability_box_ap_cost_bg[j],FRAMEPOINT_TOPLEFT,.ability_box[j],FRAMEPOINT_TOPLEFT,Math.px2Size(0),Math.px2Size(0))
				call BlzFrameSetSize(.ability_box_ap_cost_bg[j],Math.px2Size(80),Math.px2Size(20))
				call BlzFrameSetTexture(.ability_box_ap_cost_bg[j],TEXTURE_YELLOW,0,true)
				call BlzFrameSetAlpha(.ability_box_ap_cost_bg[j],128)
				set .ability_box_ap_cost_text[j] = BlzCreateFrame("MyText",.ability_box_container,0,0)
				call BlzFrameSetAllPoints(.ability_box_ap_cost_text[j],.ability_box_ap_cost_bg[j])
				call BlzFrameSetTextAlignment(.ability_box_ap_cost_text[j],TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
				/**/
				set i = i + 1
			endloop
			/*이름 & 레벨*/
			set .name = BlzCreateFrame("MyTextLarge",.ability_box_container,0,0)
			call BlzFrameSetPoint(.name,FRAMEPOINT_BOTTOMLEFT,.ability_box[0],FRAMEPOINT_TOPLEFT,0.,0.)
			call BlzFrameSetSize(.name,Math.px2Size(320),Math.px2Size(48))
			call BlzFrameSetTextAlignment(.name,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_LEFT)
			/*어빌배경(검은색) 포인트*/
			call BlzFrameSetPoint(.ability_box_bg,FRAMEPOINT_BOTTOM,UI.ORIGIN,FRAMEPOINT_BOTTOM,0.,0.)
			call BlzFrameSetPoint(.ability_box_bg,FRAMEPOINT_RIGHT,.ability_box[3],FRAMEPOINT_RIGHT,Math.px2Size(16),0.)
			call BlzFrameSetPoint(.ability_box_bg,FRAMEPOINT_TOPLEFT,.name,FRAMEPOINT_TOPLEFT,Math.px2Size(-16),0.)
			/*어빌리티 툴팁*/
			set .ability_box_tooltip = BlzCreateFrame("MyTextBox",.ability_box_container,0,0)
			call BlzFrameSetPoint(.ability_box_tooltip,FRAMEPOINT_TOPRIGHT,.ability_box_bg,FRAMEPOINT_TOPLEFT,0,0)
			call BlzFrameSetPoint(.ability_box_tooltip,FRAMEPOINT_BOTTOMLEFT,UI.ORIGIN,FRAMEPOINT_BOTTOMLEFT,0,0)
			set .ability_box_tooltip_text = BlzCreateFrame("MyText",.ability_box_container,0,0)
			call BlzFrameSetPoint(.ability_box_tooltip_text,FRAMEPOINT_TOPRIGHT,.ability_box_tooltip,FRAMEPOINT_TOPRIGHT,Math.px2Size(-16),Math.px2Size(-16))
			call BlzFrameSetPoint(.ability_box_tooltip_text,FRAMEPOINT_BOTTOMLEFT,.ability_box_tooltip,FRAMEPOINT_BOTTOMLEFT,Math.px2Size(16),Math.px2Size(16))
			call BlzFrameSetTextAlignment(.ability_box_tooltip_text,TEXT_JUSTIFY_TOP,TEXT_JUSTIFY_LEFT)
			/*몬스터박스 컨테이너*/
			set .monster_box_container = BlzCreateFrameByType("FRAME","",.container,"",0)
			/*몬스터박스배경*/
			set .monster_box_bg1 = BlzCreateFrameByType("BACKDROP","",.monster_box_container,"",0)
			call BlzFrameSetPoint(.monster_box_bg1,FRAMEPOINT_TOPLEFT,UI.ORIGIN,FRAMEPOINT_TOPLEFT,0,0)
			call BlzFrameSetSize(.monster_box_bg1,Math.px2Size(MONSTER_BOX_WIDTH),/*
				*/Math.px2Size(MONSTER_BOX_HEIGHT))
			call BlzFrameSetTexture(.monster_box_bg1,TEXTURE_BLUE,0,true)
			call BlzFrameSetAlpha(.monster_box_bg1,96)
			set .monster_box_bg2 = BlzCreateFrameByType("BACKDROP","",.monster_box_container,"",0)
			call BlzFrameSetPoint(.monster_box_bg2,FRAMEPOINT_TOPRIGHT,UI.ORIGIN,FRAMEPOINT_TOPRIGHT,0,0)
			call BlzFrameSetSize(.monster_box_bg2,Math.px2Size(MONSTER_BOX_WIDTH),/*
				*/Math.px2Size(MONSTER_BOX_HEIGHT))
			call BlzFrameSetTexture(.monster_box_bg2,TEXTURE_RED,0,true)
			call BlzFrameSetAlpha(.monster_box_bg2,96)
			/*몬스터박스 커서*/
			set .monster_box_cursor = BlzCreateFrameByType("BACKDROP","",.monster_box_container,"",0)
			call BlzFrameSetTexture(.monster_box_cursor,"Textures\\white.blp",0,true)
			call BlzFrameSetSize(.monster_box_cursor,Math.px2Size(MONSTER_BOX_WIDTH/5),Math.px2Size(MONSTER_BOX_HEIGHT))
			call BlzFrameSetAlpha(.monster_box_cursor,128)
			/*몬스터박스*/
			set i = 0
			loop
				/*1P*/
				exitwhen i >= Party.PARTY_SIZE
				set f = setFrame(INDEX_MONSTER_BOX_ICON+i,BlzCreateFrameByType("BACKDROP","",.monster_box_container,"",0))
				call BlzFrameSetPoint(f,FRAMEPOINT_TOPLEFT,.monster_box_bg1,FRAMEPOINT_TOPLEFT,/*
					*/Math.px2Size(MONSTER_BOX_ICON_INSET+i*(MONSTER_BOX_WIDTH/Party.PARTY_SIZE)),Math.px2Size(-MONSTER_BOX_ICON_INSET))
				call BlzFrameSetSize(f,Math.px2Size(MONSTER_BOX_ICON_SIZE),Math.px2Size(MONSTER_BOX_ICON_SIZE))
				call BlzFrameSetTexture(f,TEXTURE_GREEN,0,true)
				set bf = f
				set f = setFrame(INDEX_MONSTER_BOX_NAME+i,BlzCreateFrame("MyText",.monster_box_container,0,0))
				call BlzFrameSetPoint(f,FRAMEPOINT_TOPRIGHT,.monster_box_bg1,FRAMEPOINT_TOPLEFT,Math.px2Size((i+1)*(MONSTER_BOX_WIDTH/Party.PARTY_SIZE)-MONSTER_BOX_ICON_INSET),Math.px2Size(-MONSTER_BOX_ICON_INSET))
				call BlzFrameSetPoint(f,FRAMEPOINT_BOTTOMLEFT,bf,FRAMEPOINT_BOTTOMRIGHT,0,0)
				call BlzFrameSetTextAlignment(f,TEXT_JUSTIFY_TOP,TEXT_JUSTIFY_LEFT)
				call BlzFrameSetText(f,"")
				set i = i + 1
			endloop
			loop
				/*2P*/
				exitwhen i >= Party.PARTY_SIZE * 2
				set f = setFrame(INDEX_MONSTER_BOX_ICON+i,BlzCreateFrameByType("BACKDROP","",.monster_box_container,"",0))
				call BlzFrameSetPoint(f,FRAMEPOINT_TOPLEFT,.monster_box_bg2,FRAMEPOINT_TOPRIGHT,/*
					*/Math.px2Size(MONSTER_BOX_ICON_INSET-(i-4)*(MONSTER_BOX_WIDTH/Party.PARTY_SIZE)),Math.px2Size(-MONSTER_BOX_ICON_INSET))
				call BlzFrameSetSize(f,Math.px2Size(MONSTER_BOX_ICON_SIZE),Math.px2Size(MONSTER_BOX_ICON_SIZE))
				call BlzFrameSetTexture(f,TEXTURE_GREEN,0,true)
				set i = i + 1
			endloop
			set i = 0
			loop
				exitwhen i >=  Party.PARTY_SIZE * 2
				set bf = getFrame(INDEX_MONSTER_BOX_ICON+i)
				set f = setFrame(INDEX_MONSTER_BOX_HP_BG+i,BlzCreateFrameByType("BACKDROP","",.monster_box_container,"",0))
				call BlzFrameSetPoint(f,FRAMEPOINT_TOPLEFT,bf,FRAMEPOINT_BOTTOMLEFT,0.,Math.px2Size(-8))
				call BlzFrameSetSize(f,Math.px2Size((MONSTER_BOX_WIDTH/Party.PARTY_SIZE)-MONSTER_BOX_ICON_INSET*2),Math.px2Size(8))
				call BlzFrameSetTexture(f,TEXTURE_GRAY,0,true)
				set bf = f
				set f = setFrame(INDEX_MONSTER_BOX_HP_FILL+i,BlzCreateFrameByType("BACKDROP","",.monster_box_container,"",0))
				call BlzFrameSetPoint(f,FRAMEPOINT_TOPLEFT,bf,FRAMEPOINT_TOPLEFT,0.,0.)
				call BlzFrameSetSize(f,BlzFrameGetWidth(bf)/2.,Math.px2Size(8))
				call BlzFrameSetTexture(f,TEXTURE_GREEN,0,true)
				call BlzFrameSetAlpha(f,128)
				if i < Party.PARTY_SIZE then
					set f = setFrame(INDEX_MONSTER_BOX_HP_TEXT+i,BlzCreateFrame("MyTextSmall",.monster_box_container,0,0))
					call BlzFrameSetAllPoints(f,bf)
					call BlzFrameSetTextAlignment(f,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
					call BlzFrameSetText(f,"10 / 10")
				endif
				set bf = getFrame(INDEX_MONSTER_BOX_HP_BG+i)
				set f = setFrame(INDEX_MONSTER_BOX_AP_BG+i,BlzCreateFrameByType("BACKDROP","",.monster_box_container,"",0))
				call BlzFrameSetPoint(f,FRAMEPOINT_TOPLEFT,bf,FRAMEPOINT_BOTTOMLEFT,0.,Math.px2Size(-4))
				call BlzFrameSetSize(f,Math.px2Size((MONSTER_BOX_WIDTH/Party.PARTY_SIZE)-MONSTER_BOX_ICON_INSET*2),Math.px2Size(8))
				call BlzFrameSetTexture(f,TEXTURE_GRAY,0,true)
				set bf = f
				set f = setFrame(INDEX_MONSTER_BOX_AP_FILL+i,BlzCreateFrameByType("BACKDROP","",.monster_box_container,"",0))
				call BlzFrameSetPoint(f,FRAMEPOINT_TOPLEFT,bf,FRAMEPOINT_TOPLEFT,0.,0.)
				call BlzFrameSetSize(f,BlzFrameGetWidth(bf)/2.,Math.px2Size(8))
				call BlzFrameSetTexture(f,TEXTURE_YELLOW,0,true)
				call BlzFrameSetAlpha(f,128)
				set i = i + 1
			endloop
			/*시간표시기*/
			set .time_indicator[0] = BlzCreateFrameByType("BACKDROP","",.container,"",0)
			call BlzFrameSetPoint(.time_indicator[0],FRAMEPOINT_TOP,UI.ORIGIN,FRAMEPOINT_TOP,0.,Math.px2Size(TIME_INDICATOR_Y_OFFSET))
			call BlzFrameSetSize(.time_indicator[0],Math.px2Size(TIME_INDICATOR_SIZE),Math.px2Size(TIME_INDICATOR_SIZE))
			call BlzFrameSetTexture(.time_indicator[0],"Textures\\ui_time_indicator_emissive.blp",0,true)
			call BlzFrameSetAlpha(.time_indicator[0],128)
			set .time_indicator[1] = BlzCreateFrameByType("BACKDROP","",.container,"",0)
			call BlzFrameSetPoint(.time_indicator[1],FRAMEPOINT_TOP,.time_indicator[0],FRAMEPOINT_BOTTOM,0.,Math.px2Size(-4))
			call BlzFrameSetSize(.time_indicator[1],Math.px2Size(64),Math.px2Size(20))
			call BlzFrameSetTexture(.time_indicator[1],"Textures\\black32.blp",0,true)
			call BlzFrameSetAlpha(.time_indicator[1],128)
			set .time_indicator[2] = BlzCreateFrame("MyText",.container,0,0)
			call BlzFrameSetAllPoints(.time_indicator[2],.time_indicator[1])
			call BlzFrameSetTextAlignment(.time_indicator[2],TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
			/*디스플레이 타겟 리프레시*/
			call setDisplayTarget(0)
			/*가시성*/
			call BlzFrameSetVisible(.container,GetLocalPlayer()==.owner)
			call setStateNormal()
			set f = null
			set bf = null
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			local integer i = 0
			//! runtextmacro DestroyFrameSimple(".ability_box_tooltip_text")
			//! runtextmacro DestroyFrameSimple(".ability_box_tooltip")
			//! runtextmacro DestroyFrameSimple(".ability_box_cursor")
			//!	runtextmacro DestroyFrameSimple(".ability_box[0]")
			//!	runtextmacro DestroyFrameSimple(".ability_box[1]")
			//!	runtextmacro DestroyFrameSimple(".ability_box[2]")
			//!	runtextmacro DestroyFrameSimple(".ability_box[3]")
			//!	runtextmacro DestroyFrameSimple(".ability_box_name[0]")
			//!	runtextmacro DestroyFrameSimple(".ability_box_name[1]")
			//!	runtextmacro DestroyFrameSimple(".ability_box_name[2]")
			//!	runtextmacro DestroyFrameSimple(".ability_box_name[3]")
			//!	runtextmacro DestroyFrameSimple(".ability_box_ap_cost_text[0]")
			//!	runtextmacro DestroyFrameSimple(".ability_box_ap_cost_text[1]")
			//!	runtextmacro DestroyFrameSimple(".ability_box_ap_cost_text[2]")
			//!	runtextmacro DestroyFrameSimple(".ability_box_ap_cost_text[3]")
			//!	runtextmacro DestroyFrameSimple(".ability_box_ap_cost_bg[0]")
			//!	runtextmacro DestroyFrameSimple(".ability_box_ap_cost_bg[1]")
			//!	runtextmacro DestroyFrameSimple(".ability_box_ap_cost_bg[2]")
			//!	runtextmacro DestroyFrameSimple(".ability_box_ap_cost_bg[3]")
			//! runtextmacro DestroyFrameSimple(".ability_box_container")
			//! runtextmacro DestroyFrameSimple(".ability_box_bg")
			//!	runtextmacro DestroyFrameSimple(".time_indicator[2]")
			//!	runtextmacro DestroyFrameSimple(".time_indicator[1]")
			//!	runtextmacro DestroyFrameSimple(".time_indicator[0]")
			//!	runtextmacro DestroyFrameSimple(".name")
			//!	runtextmacro DestroyFrameSimple(".monster_box_cursor")
			//!	runtextmacro DestroyFrameSimple(".monster_box_bg1")
			//!	runtextmacro DestroyFrameSimple(".monster_box_bg2")
			//!	runtextmacro DestroyFrameSimple(".monster_box_container")
			//! runtextmacro DestroyFrameSimple(".container")
			loop
				/*타입아이콘 객체 제거*/
				exitwhen i >= MONSTER_ABILITY_COUNT_MAX
				call ability_box_element_type_icon1[i].destroy()
				call ability_box_element_type_icon2[i].destroy()
				set i = i + 1
			endloop
			set i = 0
			loop
				exitwhen i >= Party.PARTY_SIZE * 2
				call setFrame(INDEX_MONSTER_BOX_NAME+i,null)
				call setFrame(INDEX_MONSTER_BOX_ICON+i,null)
				call setFrame(INDEX_MONSTER_BOX_HP_BG+i,null)
				call setFrame(INDEX_MONSTER_BOX_HP_FILL+i,null)
				call setFrame(INDEX_MONSTER_BOX_AP_BG+i,null)
				call setFrame(INDEX_MONSTER_BOX_AP_FILL+i,null)
				if i < Party.PARTY_SIZE then
					call setFrame(INDEX_MONSTER_BOX_HP_TEXT+i,null)
				endif
				call RemoveSavedInteger(HASH,this,INDEX_MONSTER_BOX_TARGET+i)
				set i = i + 1
			endloop
			set .owner = null
		endmethod

		static method onInit takes nothing returns nothing
			set INDEX_MONSTER_BOX_ICON = 0 * Party.PARTY_SIZE
			set INDEX_MONSTER_BOX_NAME = 2 * Party.PARTY_SIZE
			set INDEX_MONSTER_BOX_HP_BG = 4 * Party.PARTY_SIZE
			set INDEX_MONSTER_BOX_HP_FILL = 6 * Party.PARTY_SIZE
			set INDEX_MONSTER_BOX_HP_TEXT = 8 * Party.PARTY_SIZE
			set INDEX_MONSTER_BOX_AP_BG = 9 * Party.PARTY_SIZE
			set INDEX_MONSTER_BOX_AP_FILL = 11 * Party.PARTY_SIZE
			set INDEX_MONSTER_BOX_TARGET = 13 * Party.PARTY_SIZE
		endmethod

	endstruct

endlibrary