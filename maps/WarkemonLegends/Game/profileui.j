library ProfileUI initializer init requires UI, Party

	globals
		private hashtable HASH = InitHashtable()
		private integer PARTY_MONSTER_CONTAINER 			= 0		/*콘테이너프레임 주소*/
		private integer PARTY_MONSTER_ICON 					= 0		/*아이콘프레임 주소*/
		private integer PARTY_MONSTER_NAME 					= 0
		private integer PARTY_MONSTER_HP_BG 				= 0		/*체력바 배경 주소*/
		private integer PARTY_MONSTER_HP_FILL				= 0 	/*체력바 게이지*/
		private integer PARTY_MONSTER_HP_TEXT   			= 0		/*체력바 텍스트*/
		private integer PARTY_MONSTER_EXP_BG				= 0
		private integer PARTY_MONSTER_EXP_FILL				= 0
		private integer PARTY_MONSTER_EXP_TEXT				= 0 
		private integer PARTY_MONSTER_ELEMENT_TYPE_ICON1	= 0
		private integer PARTY_MONSTER_ELEMENT_TYPE_ICON2	= 0
		private integer PARTY_MONSTER_DISPLAY_TARGET		= 0
		private integer PARTY_MONSTER_HEAL_EFFECT			= 0
		private integer PARTY_MONSTER_HEAL_TIME_REMAIN		= 0
		private constant integer PARTY_MONSTER_ARRAY_SIZE			= 5		/*표시할 몬스터 마릿수*/
		private integer STORAGE_MONSTER_ICON				= 0
		private constant integer STORAGE_MONSTER_ARRAY_SIZE 		= 32
	endglobals

	private struct FrameGetterSetter

		method getFrame takes integer ft, integer index returns framehandle
			return LoadFrameHandle(HASH,this,ft+index)
		endmethod

		method setFrame takes integer ft, integer index, framehandle nf returns framehandle
			call SaveFrameHandle(HASH,this,ft+index,nf)
			return nf
		endmethod

		method removeFrame takes integer ft, integer index returns nothing
			call BlzDestroyFrame(getFrame(ft,index))
			call setFrame(ft,index,null)
		endmethod

	endstruct

	struct EnteranceUI extends FrameGetterSetter

		/*FROM TOP*/
		private static constant integer MAP_ENTERANCE_Y_OFFSET = -256

		private static constant integer MAP_ENTERANCE_HEIGHT = 64

		private static constant real MAP_ENTERANCE_DISPLAY_DURATION = 4.

		player owner = null
		framehandle container = null
		framehandle map_enterance_title = null
		framehandle map_enterance_field_level = null

		timer main_timer = null

		private static method hideMapEnterance takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			call BlzFrameSetVisible(.map_enterance_title,false)
			call BlzFrameSetVisible(.map_enterance_field_level,false)
		endmethod

		method showMapEnterance takes Field f returns nothing
			call BlzFrameSetText(.map_enterance_title,"|cffb34231"+f.name+f.name_subfix+" 이동|r")
			if f.level_min > 0 then
				call BlzFrameSetText(.map_enterance_field_level,"|cffb34231지역레벨 "+I2S(f.level_min)+" - "+I2S(f.level_max)+"|r")
				call BlzFrameSetVisible(.map_enterance_field_level,true)
			else
				call BlzFrameSetVisible(.map_enterance_field_level,false)
			endif
			call BlzFrameSetVisible(.map_enterance_title,true)
			call Timer.start(.main_timer,MAP_ENTERANCE_DISPLAY_DURATION,false,function thistype.hideMapEnterance)
		endmethod

		static method create takes player for returns thistype
			local thistype this = allocate()
			set .owner = for
			set .main_timer = Timer.new(this)
			set .container = BlzCreateFrameByType("FRAME","",UI.ORIGIN,"",0)
			/*맵 입장 타이틀*/
			set .map_enterance_title = BlzCreateFrame("MyKodia",.container,0,0)
			call BlzFrameSetPoint(.map_enterance_title,FRAMEPOINT_CENTER,UI.ORIGIN,FRAMEPOINT_TOP,0,Math.px2Size(MAP_ENTERANCE_Y_OFFSET))
			call BlzFrameSetSize(.map_enterance_title,1.0,Math.px2Size(MAP_ENTERANCE_HEIGHT))
			call BlzFrameSetTextAlignment(.map_enterance_title,TEXT_JUSTIFY_TOP,TEXT_JUSTIFY_CENTER)
			call BlzFrameSetVisible(.map_enterance_title,false)
			set .map_enterance_field_level = BlzCreateFrame("MyKodiaSmall",.container,0,0)
			call BlzFrameSetPoint(.map_enterance_field_level,FRAMEPOINT_TOP,map_enterance_title,FRAMEPOINT_BOTTOM,0,0)
			call BlzFrameSetSize(.map_enterance_field_level,1.0,Math.px2Size(MAP_ENTERANCE_HEIGHT))
			call BlzFrameSetTextAlignment(.map_enterance_field_level,TEXT_JUSTIFY_TOP,TEXT_JUSTIFY_CENTER)
			call BlzFrameSetVisible(.map_enterance_field_level,false)
			/**/
			/**/
			call BlzFrameSetVisible(.container,GetLocalPlayer()==.owner)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call Timer.release(.main_timer)
			set .main_timer = null
			set .owner = null
			//! runtextmacro DestroyFrameSimple(".map_enterance_title")
			//! runtextmacro DestroyFrameSimple(".map_enterance_field_level")
			//! runtextmacro DestroyFrameSimple(".container")
		endmethod

	endstruct

	struct PartyUI extends FrameGetterSetter

		private static constant integer MONSTER_CONTAINER_WIDTH = 256
		private static constant integer MONSTER_CONTAINER_HEIGHT = 128
		private static constant integer MONSTER_CONTAINER_X_OFFSET = 32		/*From BOTTOMLEFT*/
		private static constant integer MONSTER_CONTAINER_Y_OFFSET = 16
		private static constant integer MONSTER_CONTAINER_PADDING = 16

		private static constant integer MONSTER_ICON_SIZE = 64
		private static constant integer MONSTER_ICON_INSET = 8

		private static constant integer GAUGE_WIDTH = 240 /* MONSTER_CONTAINER_WIDTH-GAUGE_INSET*2 */
		private static constant integer GAUGE_HEIGHT = 8
		private static constant integer GAUGE_INSET = 8

		private static constant string HEAL_EFFECT_PATH = "ui\\ui_heal_effect1.mdl"

		framehandle container = null
		framehandle help = null
		player owner = null
		boolean visible = true

		timer heal_timer = null

		method show takes boolean flag returns thistype
			set .visible = flag
			call BlzFrameSetVisible(.container,.visible and GetLocalPlayer() == .owner)
			return this
		endmethod

		method getDisplayTarget takes integer index returns Monster
			if HaveSavedInteger(HASH,this,PARTY_MONSTER_DISPLAY_TARGET+index) then
				return LoadInteger(HASH,this,PARTY_MONSTER_DISPLAY_TARGET+index)
			else
				return 0
			endif
		endmethod

		static method healTimer takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			local integer i = 0
			local integer j = 0
			loop
				exitwhen i >= PARTY_MONSTER_ARRAY_SIZE
				if LoadReal(HASH,this,PARTY_MONSTER_HEAL_TIME_REMAIN+i) > 0. then
					call SaveReal(HASH,this,PARTY_MONSTER_HEAL_TIME_REMAIN+i,LoadReal(HASH,this,PARTY_MONSTER_HEAL_TIME_REMAIN+i)-TIMER_TICK)
					if LoadReal(HASH,this,PARTY_MONSTER_HEAL_TIME_REMAIN+i) <= 0. then
						call BlzFrameSetVisible(getFrame(PARTY_MONSTER_HEAL_EFFECT,i),false)
						call SaveReal(HASH,this,PARTY_MONSTER_HEAL_TIME_REMAIN+i,0.)
						set j = j + 1
					endif
				else
					set j = j + 1
				endif
				set i = i + 1
			endloop
			if j == PARTY_MONSTER_ARRAY_SIZE then
				call Timer.pause(.heal_timer)
			endif
		endmethod

		method healEffect takes integer index returns nothing
			call SaveReal(HASH,this,PARTY_MONSTER_HEAL_TIME_REMAIN+index,1.5)
			call BlzFrameSetVisible(getFrame(PARTY_MONSTER_HEAL_EFFECT,index),true)
			call Timer.start(.heal_timer,TIMER_TICK,true,function thistype.healTimer)
		endmethod

		method setDisplayTarget takes integer index, Monster m returns Monster
			call SaveInteger(HASH,this,PARTY_MONSTER_DISPLAY_TARGET+index,m)
			return m
		endmethod

		method refresh takes nothing returns nothing
			local integer i = 0
			local framehandle f = null
			local Monster m = 0
			local real r = 0.
			local Profile pr = 0
			set pr = Profile.getPlayerProfile(.owner)
			call setDisplayTarget(0,Party.getMonster(pr,0))
			call setDisplayTarget(1,Party.getMonster(pr,1))
			call setDisplayTarget(2,Party.getMonster(pr,2))
			call setDisplayTarget(3,Party.getMonster(pr,3))
			call setDisplayTarget(4,Party.getMonster(pr,4))
			loop
				exitwhen i >= PARTY_MONSTER_ARRAY_SIZE
				set m = getDisplayTarget(i)
				if m != 0 then
					/*타겟이 0이 아니면*/
					/*아이콘*/
					set f = getFrame(PARTY_MONSTER_ICON,i)
					call BlzFrameSetTexture(f,m.icon_path,0,true)
					/*이름*/
					set f = getFrame(PARTY_MONSTER_NAME,i)
					call BlzFrameSetText(f,"Lv."+I2S(m.level)+" "+m.name)
					/*경험치*/
					set f = getFrame(PARTY_MONSTER_EXP_FILL,i)
					set r = I2R(m.getCarculatedExp()) / I2R(m.getCarculatedMaxExp())
					if r > 1. then
						set r = 1.
					elseif r < 0. then
						set r = 0.
					endif
					call BlzFrameSetVisible(f,r>0.)
					call BlzFrameSetPoint(f,FRAMEPOINT_TOPRIGHT,getFrame(PARTY_MONSTER_EXP_BG,i),FRAMEPOINT_BOTTOMLEFT,Math.px2Size(GAUGE_WIDTH)*r,Math.px2Size(GAUGE_HEIGHT))
					set f = getFrame(PARTY_MONSTER_EXP_TEXT,i)
					call BlzFrameSetText(f,I2S(m.getCarculatedExp())+" / "+I2S(m.getCarculatedMaxExp())+" ("+R2SW(r*100.,1,1)+"%)")
					/*체력*/
					set f = getFrame(PARTY_MONSTER_HP_FILL,i)
					set r = m.hp / m.getBaseStat(STAT_TYPE_MAXHP)
					if r > 1. then
						set r = 1.
					elseif r < 0. then
						set r = 0.
					endif
					call BlzFrameSetVisible(f,r>0.)
					call BlzFrameSetPoint(f,FRAMEPOINT_TOPRIGHT,getFrame(PARTY_MONSTER_HP_BG,i),FRAMEPOINT_BOTTOMLEFT,Math.px2Size(GAUGE_WIDTH)*r,Math.px2Size(GAUGE_HEIGHT))
					set f = getFrame(PARTY_MONSTER_HP_TEXT,i)
					call BlzFrameSetText(f,I2S(R2I(m.hp))+" / "+I2S(R2I(m.getBaseStat(STAT_TYPE_MAXHP))) )
					/*속성아이콘*/
					call getIcon(PARTY_MONSTER_ELEMENT_TYPE_ICON1,i).setModel(ELEMENT_TYPE_ICON_PATH[m.element_type1])
					call getIcon(PARTY_MONSTER_ELEMENT_TYPE_ICON2,i).setModel(ELEMENT_TYPE_ICON_PATH[m.element_type2])
				else
					/*타겟이 비어있으면*/
					/*아이콘*/
					set f = getFrame(PARTY_MONSTER_ICON,i)
					call BlzFrameSetTexture(f,TEXTURE_BLACK,0,true)
					/*이름*/
					set f = getFrame(PARTY_MONSTER_NAME,i)
					call BlzFrameSetText(f,"")
					/*경험치*/
					set f = getFrame(PARTY_MONSTER_EXP_FILL,i)
					call BlzFrameSetVisible(f,false)
					call BlzFrameSetPoint(f,FRAMEPOINT_TOPRIGHT,getFrame(PARTY_MONSTER_EXP_BG,i),FRAMEPOINT_BOTTOMLEFT,0.,0.)
					set f = getFrame(PARTY_MONSTER_EXP_TEXT,i)
					call BlzFrameSetText(f,"")
					/*체력*/
					set f = getFrame(PARTY_MONSTER_HP_FILL,i)
					call BlzFrameSetVisible(f,false)
					call BlzFrameSetPoint(f,FRAMEPOINT_TOPRIGHT,getFrame(PARTY_MONSTER_EXP_BG,i),FRAMEPOINT_BOTTOMLEFT,0.,0.)
					set f = getFrame(PARTY_MONSTER_HP_TEXT,i)
					call BlzFrameSetText(f,"")
					/*속성아이콘*/
					call getIcon(PARTY_MONSTER_ELEMENT_TYPE_ICON1,i).setModel("")
					call getIcon(PARTY_MONSTER_ELEMENT_TYPE_ICON2,i).setModel("")
				endif
				set i = i + 1
			endloop
			set f = null
		endmethod

		method getIcon takes integer ft, integer index returns ElementTypeIcon
			if HaveSavedInteger(HASH,this,ft+index) then
				return LoadInteger(HASH,this,ft+index)
			else
				return 0
			endif
		endmethod

		method setIcon takes integer ft, integer index, ElementTypeIcon newicon returns ElementTypeIcon
			call SaveInteger(HASH,this,ft+index,newicon)
			return newicon
		endmethod

		method removeIcon takes integer ft, integer index returns nothing
			local ElementTypeIcon ic = getIcon(ft,index)
			if ic != 0 then
				call ic.destroy()
			endif
			call setIcon(ft,index,0)
		endmethod

		static method create takes player forplayer returns thistype
			/*생성자*/
			local thistype this = allocate()
			local framehandle bf = null
			local framehandle cf = null
			local integer i = 0
			local ElementTypeIcon ci = 0
			local ElementTypeIcon bi = 0
			set .owner = forplayer
			/*컨테이너*/
			set .container = BlzCreateFrameByType("FRAME","",UI.SURFACE_UI,"",0)
			loop
				exitwhen i >= PARTY_MONSTER_ARRAY_SIZE
				/*컨테이너박스*/
				set cf = setFrame(PARTY_MONSTER_CONTAINER,i,BlzCreateFrameByType("BACKDROP","",.container,"",0))
				call BlzFrameSetPoint(cf,FRAMEPOINT_BOTTOMLEFT,UI.ORIGIN,FRAMEPOINT_BOTTOMLEFT,/*
					*/Math.px2Size(MONSTER_CONTAINER_X_OFFSET+((MONSTER_CONTAINER_WIDTH+MONSTER_CONTAINER_PADDING)*i)),/*
					*/Math.px2Size(MONSTER_CONTAINER_Y_OFFSET+((MONSTER_CONTAINER_HEIGHT+MONSTER_CONTAINER_PADDING)*0/*임시*/))/*
				*/)
				call BlzFrameSetSize(cf,Math.px2Size(MONSTER_CONTAINER_WIDTH),Math.px2Size(MONSTER_CONTAINER_HEIGHT))
				call BlzFrameSetTexture(cf,TEXTURE_BLACK,0,true)
				call BlzFrameSetAlpha(cf,128)
				/*아이콘*/
				set bf = getFrame(PARTY_MONSTER_CONTAINER,i)
				set cf = setFrame(PARTY_MONSTER_ICON,i,BlzCreateFrameByType("BACKDROP","",.container,"",0))
				call BlzFrameSetPoint(cf,FRAMEPOINT_TOPLEFT,bf,FRAMEPOINT_TOPLEFT,Math.px2Size(MONSTER_ICON_INSET),Math.px2Size(-MONSTER_ICON_INSET))
				call BlzFrameSetSize(cf,Math.px2Size(MONSTER_ICON_SIZE),Math.px2Size(MONSTER_ICON_SIZE))
				call BlzFrameSetTexture(cf,TEXTURE_BLACK,0,true)
				/*힐이펙트 셋 포인트*/
				/*힐이펙트*/
				set bf = cf
				set cf = setFrame(PARTY_MONSTER_HEAL_EFFECT,i,BlzCreateFrameByType("SPRITE","",.container,"",0))
				call BlzFrameSetModel(cf,HEAL_EFFECT_PATH,0)
				call BlzFrameSetSize(cf,0.01,0.01)
				call BlzFrameSetVisible(cf,false)
				call BlzFrameSetPoint(getFrame(PARTY_MONSTER_HEAL_EFFECT,i),FRAMEPOINT_BOTTOMLEFT,bf,FRAMEPOINT_BOTTOMLEFT,0.,0.)
				/*텍스트*/
				set bf = getFrame(PARTY_MONSTER_ICON,i)
				set cf = setFrame(PARTY_MONSTER_NAME,i,BlzCreateFrame("MyText",.container,0,0))
				call BlzFrameSetPoint(cf,FRAMEPOINT_TOPLEFT,bf,FRAMEPOINT_TOPRIGHT,Math.px2Size(MONSTER_ICON_INSET),0)
				set bf = getFrame(PARTY_MONSTER_CONTAINER,i)
				call BlzFrameSetPoint(cf,FRAMEPOINT_BOTTOMRIGHT,bf,FRAMEPOINT_TOPRIGHT,Math.px2Size(-MONSTER_ICON_INSET),Math.px2Size(-MONSTER_ICON_INSET-64))
				call BlzFrameSetTextAlignment(cf,TEXT_JUSTIFY_TOP,TEXT_JUSTIFY_LEFT)
				/*경험치바*/
				set bf = getFrame(PARTY_MONSTER_CONTAINER,i)
				set cf = setFrame(PARTY_MONSTER_EXP_BG,i,BlzCreateFrameByType("BACKDROP","",.container,"",0))
				call BlzFrameSetPoint(cf,FRAMEPOINT_BOTTOMLEFT,bf,FRAMEPOINT_BOTTOMLEFT,Math.px2Size(GAUGE_INSET),Math.px2Size(GAUGE_INSET))
				call BlzFrameSetSize(cf,Math.px2Size(GAUGE_WIDTH),Math.px2Size(GAUGE_HEIGHT))
				call BlzFrameSetAlpha(cf,200)
				call BlzFrameSetTexture(cf,TEXTURE_BLACK,0,true)
				set bf = cf
				set cf = setFrame(PARTY_MONSTER_EXP_FILL,i,BlzCreateFrameByType("BACKDROP","",.container,"",0))
				call BlzFrameSetPoint(cf,FRAMEPOINT_BOTTOMLEFT,bf,FRAMEPOINT_BOTTOMLEFT,0,0)
				call BlzFrameSetSize(cf,Math.px2Size(GAUGE_WIDTH)/2.,Math.px2Size(GAUGE_HEIGHT))
				call BlzFrameSetAlpha(cf,200)
				call BlzFrameSetTexture(cf,TEXTURE_PURPLE,0,true)
				set bf = getFrame(PARTY_MONSTER_EXP_BG,i)
				set cf = setFrame(PARTY_MONSTER_EXP_TEXT,i,BlzCreateFrame("MyTextSmall",.container,0,0))
				call BlzFrameSetPoint(cf,FRAMEPOINT_CENTER,bf,FRAMEPOINT_CENTER,0.,0.)
				call BlzFrameSetSize(cf,0.12,0.04)
				call BlzFrameSetTextAlignment(cf,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
				call BlzFrameSetText(cf,"")
				/*체력바*/
				set bf = getFrame(PARTY_MONSTER_EXP_BG,i)
				set cf = setFrame(PARTY_MONSTER_HP_BG,i,BlzCreateFrameByType("BACKDROP","",.container,"",0))
				call BlzFrameSetPoint(cf,FRAMEPOINT_BOTTOMLEFT,bf,FRAMEPOINT_TOPLEFT,0.,Math.px2Size(GAUGE_HEIGHT)*2)
				call BlzFrameSetSize(cf,Math.px2Size(GAUGE_WIDTH),Math.px2Size(GAUGE_HEIGHT))
				call BlzFrameSetTexture(cf,TEXTURE_BLACK,0,true)
				call BlzFrameSetAlpha(cf,200)
				set bf = cf
				set cf = setFrame(PARTY_MONSTER_HP_FILL,i,BlzCreateFrameByType("BACKDROP","",.container,"",0))
				call BlzFrameSetPoint(cf,FRAMEPOINT_BOTTOMLEFT,bf,FRAMEPOINT_BOTTOMLEFT,0,0)
				call BlzFrameSetSize(cf,Math.px2Size(GAUGE_WIDTH)/2.,Math.px2Size(GAUGE_HEIGHT))
				call BlzFrameSetAlpha(cf,200)
				call BlzFrameSetTexture(cf,TEXTURE_GREEN,0,true)
				set bf = getFrame(PARTY_MONSTER_HP_BG,i)
				set cf = setFrame(PARTY_MONSTER_HP_TEXT,i,BlzCreateFrame("MyTextSmall",.container,0,0))
				call BlzFrameSetPoint(cf,FRAMEPOINT_CENTER,bf,FRAMEPOINT_CENTER,0.,0.)
				call BlzFrameSetSize(cf,0.12,0.04)
				call BlzFrameSetTextAlignment(cf,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
				call BlzFrameSetText(cf,"")
				/*속성아이콘*/
				set bf = getFrame(PARTY_MONSTER_ICON,i)
				set ci = setIcon(PARTY_MONSTER_ELEMENT_TYPE_ICON1,i,/*
					*/ElementTypeIcon.create(ELEMENT_TYPE_ICON_PATH[ELEMENT_TYPE_NORMAL], .container, bf, FRAMEPOINT_BOTTOMRIGHT, MONSTER_ICON_INSET, 0)/*
				*/)
				set bi = ci
				set ci = setIcon(PARTY_MONSTER_ELEMENT_TYPE_ICON2,i,/*
					*/ElementTypeIcon.create(ELEMENT_TYPE_ICON_PATH[ELEMENT_TYPE_NORMAL], .container, bf, FRAMEPOINT_BOTTOMRIGHT, MONSTER_ICON_INSET+48, 0)/*
				*/)
				/*루프인덱스*/
				set i = i + 1
			endloop
			/*힐 이펙트 타이머*/
			set .heal_timer = Timer.new(this)
			call SaveReal(HASH,this,PARTY_MONSTER_HEAL_TIME_REMAIN+0,0.)
			call SaveReal(HASH,this,PARTY_MONSTER_HEAL_TIME_REMAIN+1,0.)
			call SaveReal(HASH,this,PARTY_MONSTER_HEAL_TIME_REMAIN+2,0.)
			call SaveReal(HASH,this,PARTY_MONSTER_HEAL_TIME_REMAIN+3,0.)
			call SaveReal(HASH,this,PARTY_MONSTER_HEAL_TIME_REMAIN+4,0.)
			/*도움말(임시)*/
			set .help = BlzCreateFrame("MyText",.container,0,0)
			call BlzFrameSetPoint(.help,FRAMEPOINT_BOTTOMRIGHT,getFrame(PARTY_MONSTER_CONTAINER,4),FRAMEPOINT_TOPRIGHT,0,0.01)
			call BlzFrameSetSize(.help,0.45,0.45)
			call BlzFrameSetTextAlignment(.help,TEXT_JUSTIFY_BOTTOM,TEXT_JUSTIFY_RIGHT)
			call BlzFrameSetText(.help,"방향키 : 이동\nA: 포획 시도 (배틀 내에서)\nS : 창고 열기/닫기\nZ : 기술 사용 (배틀 내에서)")
			/*가시성처리*/
			call show(true)
			set bf = null
			set cf = null
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			local integer i = 0
			loop
				exitwhen i >= PARTY_MONSTER_ARRAY_SIZE
				call removeFrame(PARTY_MONSTER_EXP_TEXT,i)
				call removeFrame(PARTY_MONSTER_EXP_FILL,i)
				call removeFrame(PARTY_MONSTER_EXP_BG,i)
				call removeFrame(PARTY_MONSTER_HP_TEXT,i)
				call removeFrame(PARTY_MONSTER_HP_FILL,i)
				call removeFrame(PARTY_MONSTER_HP_BG,i)
				call removeFrame(PARTY_MONSTER_ICON,i)
				call removeIcon(PARTY_MONSTER_ELEMENT_TYPE_ICON1,i)
				call removeIcon(PARTY_MONSTER_ELEMENT_TYPE_ICON2,i)
				call removeFrame(PARTY_MONSTER_NAME,i)
				call removeFrame(PARTY_MONSTER_CONTAINER,i)
				call removeFrame(PARTY_MONSTER_HEAL_EFFECT,i)
				set i = i + 1
			endloop
			//! runtextmacro DestroyFrameSimple(".help")
			//! runtextmacro DestroyFrameSimple(".container")
		endmethod

	endstruct

	struct StorageUI extends FrameGetterSetter

		private static constant integer ICON_SIZE = 50
		private static constant integer ICON_INSET = 16
		private static constant integer ICON_PADDING = 4
		static constant integer ICON_PER_ROW = 8

		PartyUI party_ui = 0
		player owner = null
		framehandle container = null
		framehandle bg				= null
		framehandle cursor_frame = null
		framehandle help = null
		boolean visible = false
		integer cursor = 0

		method refresh takes nothing returns nothing
			local integer i = 0
			local Profile pr = 0
			local Monster m = 0
			set pr = Profile.getPlayerProfile(.owner)
			loop
				exitwhen i >= 32
				set m = Party.getMonster(pr,i+5)
				if m != 0 then
					call BlzFrameSetTexture(getFrame(STORAGE_MONSTER_ICON,i),m.icon_path,0,true)
				else
					call BlzFrameSetTexture(getFrame(STORAGE_MONSTER_ICON,i),TEXTURE_LIGHT_GRAY,0,true)
				endif
				set i = i + 1
			endloop
			call BlzFrameSetPoint(.cursor_frame,FRAMEPOINT_TOPLEFT,.bg,FRAMEPOINT_TOPLEFT,/*
				*/Math.px2Size(ICON_INSET+(ICON_SIZE+ICON_PADDING)*ModuloInteger(cursor,ICON_PER_ROW)),/*
				*/Math.px2Size(-ICON_INSET-(ICON_SIZE+ICON_PADDING)*R2I(cursor/ICON_PER_ROW))/*
			*/)
		endmethod

		method show takes boolean flag returns nothing
			set .visible = flag
			call BlzFrameSetVisible(.container,.visible and GetLocalPlayer()==.owner)
			if .visible then
				call refresh()
			endif
		endmethod

		static method create takes PartyUI ui returns thistype
			local thistype this = allocate()
			local integer i = 0
			local framehandle f = null
			local framehandle bf = null
			set .party_ui = ui
			set .owner = ui.owner
			set .container = BlzCreateFrameByType("FRAME","",UI.ORIGIN,"",0)
			call BlzFrameSetPoint(.container,FRAMEPOINT_TOPLEFT,UI.ORIGIN,FRAMEPOINT_TOPLEFT,Math.px2Size(0),Math.px2Size(-64))
			set .bg = BlzCreateFrameByType("BACKDROP","",.container,"",0)
			call BlzFrameSetPoint(.bg,FRAMEPOINT_CENTER,UI.ORIGIN,FRAMEPOINT_CENTER,0.,0.)
			call BlzFrameSetSize(.bg,Math.px2Size(ICON_SIZE*ICON_PER_ROW+ICON_PADDING*(ICON_PER_ROW-1)+ICON_INSET*2),/*
				*/Math.px2Size(ICON_SIZE*ICON_PER_ROW+ICON_PADDING*(ICON_PER_ROW-1)+ICON_INSET*2))
			call BlzFrameSetTexture(.bg,TEXTURE_BLACK,0,true)
			call BlzFrameSetAlpha(.bg,128)
			loop
				exitwhen i >= 32
				set f = setFrame(STORAGE_MONSTER_ICON,i,BlzCreateFrameByType("BACKDROP","",.container,"",0))
				call BlzFrameSetPoint(f,FRAMEPOINT_TOPLEFT,.bg,FRAMEPOINT_TOPLEFT,/*
					*/Math.px2Size(ICON_INSET+(ICON_SIZE+ICON_PADDING)*ModuloInteger(i,ICON_PER_ROW)),/*
					*/Math.px2Size(-ICON_INSET-(ICON_SIZE+ICON_PADDING)*R2I(i/ICON_PER_ROW))/*
				*/)
				call BlzFrameSetTexture(f,TEXTURE_LIGHT_GRAY,0,true)
				call BlzFrameSetSize(f,Math.px2Size(ICON_SIZE),Math.px2Size(ICON_SIZE))
				set i = i + 1
			endloop
			/*커서*/
			set .cursor_frame = BlzCreateFrameByType("BACKDROP","",.container,"",0)
			call BlzFrameSetPoint(.cursor_frame,FRAMEPOINT_TOPLEFT,.bg,FRAMEPOINT_TOPLEFT,/*
				*/Math.px2Size(ICON_INSET+(ICON_SIZE+ICON_PADDING)*ModuloInteger(cursor,ICON_PER_ROW)),/*
				*/Math.px2Size(-ICON_INSET-(ICON_SIZE+ICON_PADDING)*R2I(cursor/ICON_PER_ROW))/*
			*/)
			call BlzFrameSetSize(.cursor_frame,Math.px2Size(ICON_SIZE),Math.px2Size(ICON_SIZE))
			call BlzFrameSetTexture(.cursor_frame,TEXTURE_YELLOW,0,true)
			call BlzFrameSetAlpha(.cursor_frame,200)
			/*도움말(임시)*/
			set .help = BlzCreateFrame("MyText",.container,0,0)
			call BlzFrameSetPoint(.help,FRAMEPOINT_TOPLEFT,.bg,FRAMEPOINT_BOTTOMLEFT,0,-0.01)
			call BlzFrameSetSize(.help,0.45,0.12)
			call BlzFrameSetTextAlignment(.help,TEXT_JUSTIFY_TOP,TEXT_JUSTIFY_LEFT)
			call BlzFrameSetText(.help,"1~5 : 해당 커서에 있는 몬스터의 위치를 파티와 교체\nS, X : 창고 닫기")
			/**/
			call show(false)
			set f = null
			set bf = null
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			local integer i = 0
			loop
				exitwhen i >= STORAGE_MONSTER_ARRAY_SIZE
				call removeFrame(STORAGE_MONSTER_ICON,i)
				set i = i + 1
			endloop
			//! runtextmacro DestroyFrameSimple(".help")
			//! runtextmacro DestroyFrameSimple(".cursor_frame")
			//! runtextmacro DestroyFrameSimple(".bg")
			//! runtextmacro DestroyFrameSimple(".container")
			set .owner = null
		endmethod

	endstruct

	private function init takes nothing returns nothing
		local integer i = 0
			set PARTY_MONSTER_CONTAINER 			= 0		* PARTY_MONSTER_ARRAY_SIZE
			set PARTY_MONSTER_ICON 					= 1		* PARTY_MONSTER_ARRAY_SIZE	
			set PARTY_MONSTER_HP_BG 				= 2		* PARTY_MONSTER_ARRAY_SIZE
			set PARTY_MONSTER_HP_FILL				= 3		* PARTY_MONSTER_ARRAY_SIZE
			set PARTY_MONSTER_HP_TEXT   			= 4		* PARTY_MONSTER_ARRAY_SIZE
			set PARTY_MONSTER_EXP_BG				= 5		* PARTY_MONSTER_ARRAY_SIZE
			set PARTY_MONSTER_EXP_FILL				= 6		* PARTY_MONSTER_ARRAY_SIZE
			set PARTY_MONSTER_ELEMENT_TYPE_ICON1	= 7		* PARTY_MONSTER_ARRAY_SIZE
			set PARTY_MONSTER_ELEMENT_TYPE_ICON2	= 8		* PARTY_MONSTER_ARRAY_SIZE
			set PARTY_MONSTER_DISPLAY_TARGET		= 9		* PARTY_MONSTER_ARRAY_SIZE
			set PARTY_MONSTER_NAME 					= 10 	* PARTY_MONSTER_ARRAY_SIZE
			set PARTY_MONSTER_EXP_TEXT				= 11	* PARTY_MONSTER_ARRAY_SIZE
			set PARTY_MONSTER_HEAL_EFFECT			= 12	* PARTY_MONSTER_ARRAY_SIZE
			set PARTY_MONSTER_HEAL_TIME_REMAIN		= 13	* PARTY_MONSTER_ARRAY_SIZE
			set i = PARTY_MONSTER_HEAL_TIME_REMAIN + PARTY_MONSTER_ARRAY_SIZE
			set STORAGE_MONSTER_ICON = i + 0 * STORAGE_MONSTER_ARRAY_SIZE
	endfunction

endlibrary