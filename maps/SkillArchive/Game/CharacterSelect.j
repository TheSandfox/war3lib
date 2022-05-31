library CharacterSelect requires UnitData

	globals
		public integer array ID
		public integer array CHINGHO_ID
		private boolean array READY

		private trigger MAIN_TRIGGER = null
		private triggercondition MAIN_COND = null
		private integer TIME = 60

		public framehandle BACKGROUND = null
		private framehandle CONTAINER = null
		private framehandle HEADER_BACKDROP = null
		private framehandle HEADER_TEXT = null
		private framehandle CONFIRM = null
		private boolean 	CONFIRM_DISABLE = false	/*local*/
		private framehandle CHINGHO = null
		private framehandle CHINGHO_HEADER_BACKDROP = null
		private framehandle CHINGHO_HEADER_TEXT = null
		private framehandle CHINGHO_PAGE_NEXT = null
		private framehandle CHINGHO_PAGE_PREV = null
		private framehandle PANEL_CONTAINER = null
		private framehandle PANEL_HEADER_BACKDROP = null
		private framehandle PANEL_HEADER_TEXT = null
		private framehandle FADE = null
		private constant integer WIDTH = 768
		private constant integer HEIGHT = 320
		private constant integer OFFSET_X = -128-16/*FROM CENTER*/
		private constant integer OFFSET_Y = 128/*FROM CENTER*/
		private constant integer PER_ROW = 8
		private constant integer WIDGET_INSET = 16
		private constant integer WIDGET_SIZE = 80	/* 16+80 간격으로 배치 */
		private constant integer CHINGHO_WIDTH = 256
		private constant integer CHINGHO_HEIGHT = 640 - 64 + 16

		private integer WIDGET_INDEX = 0
		private integer CHINGHO_WIDGET_INDEX = 0
		private constant integer CHINGHO_PER_PAGE = 8
		private framehandle array CHINGHO_PAGE 
		private integer array CHINGHO_PAGE_INDEX
		private integer CHINGHO_PAGE_MAX = 0

		private trigger PANEL_REFRESH_REQUEST = null
		private player PANEL_REFRESH_PLAYER = null
	endglobals

	struct ChinghoWidget

		integer id = 0
		framehandle btn = null
		trigger main_trigger = null
		triggercondition main_cond = null

		static method click takes nothing returns nothing
			local thistype this = Trigger.getData(GetTriggeringTrigger())
			call BlzFrameSetEnable(BlzGetTriggerFrame(),false)
			call BlzFrameSetEnable(BlzGetTriggerFrame(),true)
			if BlzGetTriggerFrameEvent() == FRAMEEVENT_CONTROL_CLICK then
				set CHINGHO_ID[GetPlayerId(GetTriggerPlayer())] = .id
				set PANEL_REFRESH_PLAYER = GetTriggerPlayer()
				call TriggerEvaluate(PANEL_REFRESH_REQUEST)
				set PANEL_REFRESH_PLAYER = null
			endif
		endmethod

		static method create takes integer index, integer cid, framehandle parent returns thistype
			local thistype this = allocate()
			local framehandle f = null
			set .id = cid
			set .btn = BlzCreateFrame("ChinghoSelectButton",parent,0,this)
			/*SetPoint*/
			call BlzFrameSetPointPixel(.btn,FRAMEPOINT_TOPLEFT,CHINGHO,FRAMEPOINT_TOPLEFT,16,-16-64*ModuloInteger(index,CHINGHO_PER_PAGE))
			call BlzFrameSetSizePixel(.btn,CHINGHO_WIDTH-32,64)
			/*Icon*/
			set f = BlzGetFrameByName("ChinghoSelectButtonIcon1",this)
			call BlzFrameSetPointPixel(f,FRAMEPOINT_TOPLEFT,.btn,FRAMEPOINT_TOPLEFT,8,-8)
			call BlzFrameSetSizePixel(f,64-16,64-16)
			if cid < 0 then
				call BlzFrameSetTexture(f,"ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp",0,true)
			else
				call BlzFrameSetTexture(f,"replaceabletextures\\commandbuttons\\"+Ability.getTypeIconPath(cid)+".blp",0,true)
			endif
			set f = BlzGetFrameByName("ChinghoSelectButtonIcon2",this)
			call BlzFrameSetPointPixel(f,FRAMEPOINT_TOPRIGHT,.btn,FRAMEPOINT_TOPRIGHT,-8,-8)
			call BlzFrameSetSizePixel(f,64-16,64-16)
			if cid < 0 then
				call BlzFrameSetTexture(f,"ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp",0,true)
			else
				call BlzFrameSetTexture(f,"replaceabletextures\\commandbuttons\\"+Ability.getTypeIconPath(cid)+".blp",0,true)
			endif
			/*Name*/
			set f = BlzGetFrameByName("ChinghoSelectButtonText",this)
			call BlzFrameSetPoint(f,FRAMEPOINT_CENTER,.btn,FRAMEPOINT_CENTER,0.,0.)
			if cid < 0 then
				call BlzFrameSetText(f,"???")
			else
				call BlzFrameSetText(f,Ability.getTypeName(cid))
			endif
			/*Trigger*/
			set .main_trigger = Trigger.new(this)
			call BlzTriggerRegisterFrameEvent(.main_trigger,.btn,FRAMEEVENT_CONTROL_CLICK)
			call BlzTriggerRegisterFrameEvent(.main_trigger,.btn,FRAMEEVENT_MOUSE_LEAVE)
			set .main_cond = TriggerAddCondition(.main_trigger,function thistype.click)
			/**/
			set f = null
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			//! runtextmacro destroyTriggerAndCondition(".main_trigger",".main_cond")
			//! runtextmacro destroyFrame(".btn")
		endmethod

	endstruct

	struct CharacterWidget

		integer id = 0
		framehandle btn = null
		trigger	main_trigger = null
		triggercondition main_cond = null

		static method click takes nothing returns nothing
			local thistype this = Trigger.getData(GetTriggeringTrigger())
			call BlzFrameSetEnable(BlzGetTriggerFrame(),false)
			call BlzFrameSetEnable(BlzGetTriggerFrame(),true)
			if BlzGetTriggerFrameEvent() == FRAMEEVENT_CONTROL_CLICK then
				set ID[GetPlayerId(GetTriggerPlayer())] = .id
				set PANEL_REFRESH_PLAYER = GetTriggerPlayer()
				call TriggerEvaluate(PANEL_REFRESH_REQUEST)
				set PANEL_REFRESH_PLAYER = null
			endif
		endmethod

		static method create takes integer index, integer uid returns thistype
			local thistype this = allocate()
			local framehandle f = null
			set .id = uid
			set .btn = BlzCreateFrame("CharacterWidgetButton",CONTAINER,0,this)
			/*SetPoint*/
			call BlzFrameSetPoint(.btn,FRAMEPOINT_TOPLEFT,CONTAINER,FRAMEPOINT_TOPLEFT,/*
			*/Math.px2Size((WIDGET_INSET+WIDGET_SIZE)*ModuloInteger(index,PER_ROW)+WIDGET_INSET/2),/*
			*/Math.px2Size((WIDGET_INSET+WIDGET_SIZE)*-R2I(index/PER_ROW)-WIDGET_INSET/2))
			call BlzFrameSetSize(.btn,Math.px2Size(WIDGET_SIZE),Math.px2Size(WIDGET_SIZE))
			/*Icon*/
			set f = BlzGetFrameByName("CharacterWidgetButtonIcon",this)
			call BlzFrameSetPoint(f,FRAMEPOINT_CENTER,.btn,FRAMEPOINT_CENTER,0.,0.)
			call BlzFrameSetSize(f,Math.px2Size(WIDGET_SIZE-WIDGET_INSET),Math.px2Size(WIDGET_SIZE-WIDGET_INSET))
			if uid < 0 then
				call BlzFrameSetTexture(f,"ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp",0,true)
			else
				call BlzFrameSetTexture(f,"replaceabletextures\\commandbuttons\\"+UnitData.getIconPath(uid)+".blp",0,true)
			endif
			/*Trigger*/
			set .main_trigger = Trigger.new(this)
			call BlzTriggerRegisterFrameEvent(.main_trigger,.btn,FRAMEEVENT_CONTROL_CLICK)
			call BlzTriggerRegisterFrameEvent(.main_trigger,.btn,FRAMEEVENT_MOUSE_LEAVE)
			set .main_cond = TriggerAddCondition(.main_trigger,function thistype.click)
			/**/
			set f = null
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			//! runtextmacro destroyTriggerAndCondition(".main_trigger",".main_cond")
			//! runtextmacro destroyFrame(".btn")
		endmethod

	endstruct

	struct CharacterInfoPanel

		framehandle container = null
		framehandle character = null
		framehandle a1 = null
		framehandle a2 = null
		framehandle a_title = null
		framehandle name = null
		framehandle tool_backdrop = null
		framehandle tool_text = null

		ChinghoFrame cf = 0

		method setChinghoTarget takes integer cid returns nothing
			call .cf.setTarget(cid)
			if cid < 0 then
				call BlzFrameSetText(.tool_text,"???")
			elseif cid > 0 then
				call BlzFrameSetText(.tool_text,Ability.getTypeTooltip(cid))
			else
				call BlzFrameSetText(.tool_text,"")
			endif
		endmethod

		method setTarget takes integer uid returns nothing
			if uid < 0 then
				call BlzFrameSetTexture(.character,"ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp",0,true)
				call BlzFrameSetTexture(.a1,"ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp",0,true)
				call BlzFrameSetTexture(.a2,"ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp",0,true)
				call BlzFrameSetText(.name,"???")
			elseif uid > 0 then
				call BlzFrameSetTexture(.character,"replaceableTextures\\commandbuttons\\"+UnitData.getIconPath(uid)+".blp",0,true)
				call BlzFrameSetTexture(.a1,"replaceableTextures\\commandbuttons\\"+/*
				*/Ability.getTypeIconPath(UnitData.getInitialAbility(uid,0))+/*
				*/".blp",0,true)
				call BlzFrameSetTexture(.a2,"replaceableTextures\\commandbuttons\\"+/*
				*/Ability.getTypeIconPath(UnitData.getInitialAbility(uid,1))+/*
				*/".blp",0,true)
				call BlzFrameSetText(.name,GetObjectName(uid))
			else
				call BlzFrameSetTexture(.character,"ReplaceableTextures\\CommandButtons\\BTNBlackIcon.blp",0,true)
				call BlzFrameSetTexture(.a1,"ReplaceableTextures\\CommandButtons\\BTNBlackIcon.blp",0,true)
				call BlzFrameSetTexture(.a2,"ReplaceableTextures\\CommandButtons\\BTNBlackIcon.blp",0,true)
				call BlzFrameSetText(.name,"")
			endif
		endmethod

		static method create takes player owner returns thistype
			local thistype this = allocate()
			set .container  = BlzCreateFrameByType("FRAME","",PANEL_CONTAINER,"",0)
			set .character 	= BlzCreateFrameByType("BACKDROP","",.container,"",0)
			set .a1			= BlzCreateFrameByType("BACKDROP","",.container,"",0)
			set .a2			= BlzCreateFrameByType("BACKDROP","",.container,"",0)
			call BlzFrameSetPointPixel(.character,FRAMEPOINT_TOPLEFT,PANEL_CONTAINER,FRAMEPOINT_TOPLEFT,32,-32)
			call BlzFrameSetSizePixel(.character,64,64)
			call BlzFrameSetTexture(.character,"replaceableTextures\\commandbuttons\\btnblackicon.blp",0,true)
			call BlzFrameSetPointPixel(.a1,FRAMEPOINT_BOTTOMLEFT,PANEL_CONTAINER,FRAMEPOINT_BOTTOMLEFT,32,32)
			call BlzFrameSetSizePixel(.a1,64,64)
			call BlzFrameSetTexture(.a1,"replaceableTextures\\commandbuttons\\btnblackicon.blp",0,true)
			call BlzFrameSetPointPixel(.a2,FRAMEPOINT_BOTTOMLEFT,.a1,FRAMEPOINT_BOTTOMRIGHT,16,0)
			call BlzFrameSetSizePixel(.a2,64,64)
			call BlzFrameSetTexture(.a2,"replaceableTextures\\commandbuttons\\btnblackicon.blp",0,true)
			set .name = BlzCreateFrame("MyTextLarge",.container,0,0)
			call BlzFrameSetPointPixel(.name,FRAMEPOINT_LEFT,.character,FRAMEPOINT_RIGHT,8,0)
			set .a_title = BlzCreateFrame("MyText",.container,0,0)
			call BlzFrameSetPoint(.a_title,FRAMEPOINT_BOTTOMLEFT,.a1,FRAMEPOINT_TOPLEFT,0.,0.005)
			call BlzFrameSetText(.a_title,"보유 능력 : ")
			/*칭호툴팁*/
			set .tool_backdrop = BlzCreateFrame("MyTextBox",.container,0,0)
			call BlzFrameSetPointPixel(.tool_backdrop,FRAMEPOINT_TOP,PANEL_CONTAINER,FRAMEPOINT_TOP,0,-96)
			call BlzFrameSetPointPixel(.tool_backdrop,FRAMEPOINT_LEFT,.a2,FRAMEPOINT_RIGHT,32,0)
			call BlzFrameSetPointPixel(.tool_backdrop,FRAMEPOINT_BOTTOMRIGHT,PANEL_CONTAINER,FRAMEPOINT_BOTTOMRIGHT,-16,16)
			set .tool_text = BlzCreateFrame("MyText",.container,0,0)
			call BlzFrameSetPoint(.tool_text,FRAMEPOINT_TOPLEFT,.tool_backdrop,FRAMEPOINT_TOPLEFT,0.005,-0.005)
			call BlzFrameSetPoint(.tool_text,FRAMEPOINT_BOTTOMRIGHT,.tool_backdrop,FRAMEPOINT_BOTTOMRIGHT,-0.005,0.005)
			call BlzFrameSetTextAlignment(.tool_text,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
			/*칭호프레임*/
			set .cf = ChinghoFrame.create(.container,.tool_backdrop)
			call BlzFrameClearAllPoints(.cf.backdrop)
			call BlzFrameSetPointPixel(.cf.backdrop,FRAMEPOINT_BOTTOM,.tool_backdrop,FRAMEPOINT_TOP,0,16)
			call BlzFrameSetScale(.cf.backdrop,1.5)
			call setTarget(-2)
			call setChinghoTarget(-2)
			/*가시성처리*/
			call BlzFrameSetVisible(.container,GetLocalPlayer() == owner)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			//! runtextmacro destroyFrame(".container")
			//! runtextmacro destroyFrame(".character")
			//! runtextmacro destroyFrame(".a1")
			//! runtextmacro destroyFrame(".a2")
			//! runtextmacro destroyFrame(".a_title")
			//! runtextmacro destroyFrame(".name")
			//! runtextmacro destroyFrame(".tool_backdrop")
			//! runtextmacro destroyFrame(".tool_text")
			call .cf.destroy()
		endmethod

	endstruct

	struct CharacterSelect extends array

		static CharacterWidget array WIDGET
		static ChinghoWidget array CHINGHO_WIDGET
		static CharacterInfoPanel array PANEL

		static method giveRandomHero takes nothing returns nothing
			local integer i = 0
			loop
				exitwhen i >= PLAYER_MAX
				if ID[i] < 0 then
					/*GiveRandomHero*/
					set ID[i] = WIDGET[GetRandomInt(1,WIDGET_INDEX-1)].id
				endif
				if CHINGHO_ID[i] < 0 then
					/*GiveRandomChingho*/
					set CHINGHO_ID[i] = CHINGHO_WIDGET[GetRandomInt(1,CHINGHO_WIDGET_INDEX-1)].id
				endif
				set i = i + 1
			endloop
		endmethod

		static method playerSetChinghoPage takes player p, integer index returns nothing
			local integer i = 0
			if index < 0 then
				set CHINGHO_PAGE_INDEX[GetPlayerId(p)] = 0
			elseif index > CHINGHO_PAGE_MAX then
				set CHINGHO_PAGE_INDEX[GetPlayerId(p)] = CHINGHO_PAGE_MAX
			else
				set CHINGHO_PAGE_INDEX[GetPlayerId(p)] = index
			endif
			loop
				exitwhen i > CHINGHO_PAGE_MAX
				if GetLocalPlayer() == p then
					call BlzFrameSetVisible(CHINGHO_PAGE[i],i == CHINGHO_PAGE_INDEX[GetPlayerId(p)])
				endif
				set i = i + 1
			endloop
		endmethod

		static method disableWidgetsForPlayer takes player p returns nothing
			local integer i = 0
			loop
				exitwhen i >= WIDGET_INDEX
				if WIDGET[i] > 0 then
					if GetLocalPlayer() == p then
						call BlzFrameSetEnable(WIDGET[i].btn,false)
					endif
				endif
				set i = i + 1
			endloop
		endmethod

		static method panelRefresh takes nothing returns nothing
			if PANEL_REFRESH_PLAYER == null then
				return
			endif
			call PANEL[GetPlayerId(PANEL_REFRESH_PLAYER)].setTarget(ID[GetPlayerId(PANEL_REFRESH_PLAYER)])
			call PANEL[GetPlayerId(PANEL_REFRESH_PLAYER)].setChinghoTarget(CHINGHO_ID[GetPlayerId(PANEL_REFRESH_PLAYER)])
		endmethod

		static method checkReadyState takes nothing returns boolean
			local integer i = 0
			loop
				exitwhen i >= PLAYER_MAX
				if not READY[i] then
					return false
				endif
				set i = i + 1
			endloop
			return true
		endmethod

		static method leavePlayer takes integer pid returns nothing
			if PANEL[pid] > 0 then
				call PANEL[pid].destroy()
			endif
			set PANEL[pid] = 0
			set ID[pid] = 0
			set READY[pid] = true
			if checkReadyState() then
				call finish()
			endif
		endmethod

		static method createWidget takes integer uid returns nothing
			set WIDGET[WIDGET_INDEX] = CharacterWidget.create(WIDGET_INDEX,uid)
			set WIDGET_INDEX = WIDGET_INDEX + 1
		endmethod

		static method createChinghoWidget takes integer cid returns nothing
			if CHINGHO_PAGE[R2I(CHINGHO_WIDGET_INDEX/CHINGHO_PER_PAGE)] == null then 
				set CHINGHO_PAGE[R2I(CHINGHO_WIDGET_INDEX/CHINGHO_PER_PAGE)] = BlzCreateFrameByType("FRAME","",CHINGHO,"",0)
				call BlzFrameSetVisible(CHINGHO_PAGE[R2I(CHINGHO_WIDGET_INDEX/CHINGHO_PER_PAGE)],false)
			endif
			set CHINGHO_WIDGET[CHINGHO_WIDGET_INDEX] = ChinghoWidget.create(CHINGHO_WIDGET_INDEX,cid,CHINGHO_PAGE[R2I(CHINGHO_WIDGET_INDEX/CHINGHO_PER_PAGE)])
			set CHINGHO_PAGE_MAX = R2I(CHINGHO_WIDGET_INDEX/CHINGHO_PER_PAGE)
			set CHINGHO_WIDGET_INDEX = CHINGHO_WIDGET_INDEX + 1
		endmethod

		static method removeFade takes nothing returns nothing
			//! runtextmacro destroyFrame("FADE")
			call DestroyTrigger(GetTriggeringTrigger())
		endmethod

		/*REPLACE DESTROY()*/
		static method end takes nothing returns nothing
			local integer i = 0
			local trigger t = CreateTrigger()
			call giveRandomHero()
			//! runtextmacro destroyFrame("BACKGROUND")
			//! runtextmacro destroyFrame("CONTAINER")
			//! runtextmacro destroyFrame("CONFIRM")
			//! runtextmacro destroyFrame("CHINGHO_HEADER_BACKDROP")
			//! runtextmacro destroyFrame("CHINGHO_HEADER_TEXT")
			//! runtextmacro destroyFrame("CHINGHO_PAGE_NEXT")
			//! runtextmacro destroyFrame("CHINGHO_PAGE_PREV")
			//! runtextmacro destroyFrame("PANEL_CONTAINER")
			//! runtextmacro destroyFrame("PANEL_HEADER_BACKDROP")
			//! runtextmacro destroyFrame("PANEL_HEADER_TEXT")
			loop
				exitwhen i > CHINGHO_PAGE_MAX
				//! runtextmacro destroyFrame("CHINGHO_PAGE[i]")
				set i = i + 1
			endloop
			set i = 0
			loop
				exitwhen i >= WIDGET_INDEX
				if WIDGET[i] > 0 then
					call WIDGET[i].destroy()
				endif
				set i = i + 1
			endloop
			set i = 0
			loop
				exitwhen i >= CHINGHO_WIDGET_INDEX
				if CHINGHO_WIDGET[i] > 0 then
					call CHINGHO_WIDGET[i].destroy()
				endif
				set i = i + 1
			endloop
			set i = 0
			loop
				exitwhen i >= PLAYER_MAX
				if PANEL[i] > 0 then
					call PANEL[i].destroy()
				endif
				set i = i + 1
			endloop
			call Game.endSelect()
			call DestroyTrigger(GetTriggeringTrigger())
			call TriggerRegisterTimerEvent(t,2.,false)
			call TriggerAddCondition(t,function thistype.removeFade)
			set t = null
		endmethod

		static method finish takes nothing returns nothing
			local trigger t = CreateTrigger()
			//! runtextmacro destroyTriggerAndCondition("MAIN_TRIGGER","MAIN_COND")
			call TriggerRegisterTimerEvent(t,2.,false)
			call TriggerAddCondition(t,function thistype.end)
			set FADE = BlzCreateFrameByType("SPRITE","",BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI,0),"",0)
			call BlzFrameSetModel(FADE,"ui\\characterselectfade.mdl",0)
			call BlzFrameSetAbsPoint(FADE,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			call BlzFrameSetSize(FADE,1.,1.)
			set t = null
		endmethod

		static method cond takes nothing returns nothing
			/*탈주*/
			if GetTriggerEventId() == EVENT_PLAYER_LEAVE then
				call leavePlayer(GetPlayerId(GetTriggerPlayer()))
				return
			/*타이머이벤트*/
			elseif GetTriggerEventId() == EVENT_GAME_TIMER_EXPIRED then
				set TIME = TIME - 1
				if TIME <= 0 then
					call finish()
				else
					call BlzFrameSetText(HEADER_TEXT,"캐릭터 선택 ("+I2S(TIME)+")")
				endif
				return
			/*컨펌버튼*/
			elseif BlzGetTriggerFrame() == CONFIRM then
				if GetLocalPlayer() == GetTriggerPlayer() then
					if not CONFIRM_DISABLE then
						call BlzFrameSetEnable(CONFIRM,false)
						call BlzFrameSetEnable(CONFIRM,true)
					endif
				endif
				if BlzGetTriggerFrameEvent() == FRAMEEVENT_CONTROL_CLICK then
					if ID[GetPlayerId(GetTriggerPlayer())] != 0 then
						set READY[GetPlayerId(GetTriggerPlayer())] = true
						if GetLocalPlayer() == GetTriggerPlayer() then
							call BlzFrameSetEnable(CONFIRM,false)
							set CONFIRM_DISABLE = true
						endif
						call disableWidgetsForPlayer(GetTriggerPlayer())
						if checkReadyState() then
							call finish()
						endif
					endif
				endif
				return
			/*칭호 넥스트*/
			elseif BlzGetTriggerFrame() == CHINGHO_PAGE_NEXT then
				if GetLocalPlayer() == GetTriggerPlayer() then
					call BlzFrameSetEnable(BlzGetTriggerFrame(),false)
					call BlzFrameSetEnable(BlzGetTriggerFrame(),true)
				endif
				if BlzGetTriggerFrameEvent() == FRAMEEVENT_CONTROL_CLICK then
					call playerSetChinghoPage(GetTriggerPlayer(),CHINGHO_PAGE_INDEX[GetPlayerId(GetTriggerPlayer())]+1)
				endif
				return
			/*칭호 이전*/
			elseif BlzGetTriggerFrame() == CHINGHO_PAGE_PREV then
				if GetLocalPlayer() == GetTriggerPlayer() then
					call BlzFrameSetEnable(BlzGetTriggerFrame(),false)
					call BlzFrameSetEnable(BlzGetTriggerFrame(),true)
				endif
				if BlzGetTriggerFrameEvent() == FRAMEEVENT_CONTROL_CLICK then
					call playerSetChinghoPage(GetTriggerPlayer(),CHINGHO_PAGE_INDEX[GetPlayerId(GetTriggerPlayer())]-1)
				endif
				return
			endif
		endmethod

		static method init takes nothing returns nothing
			local integer i = 0
			local framehandle origin = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI,0)
			local framehandle f = null
			/*CreateContainer*/
			set CONTAINER = BlzCreateFrame("MBEdge",origin,0,0)
			call BlzFrameSetAbsPoint(CONTAINER,FRAMEPOINT_CENTER,Math.px2Size((1920-480)*0.5+OFFSET_X)/*Math.px2Size(OFFSET_X)*/,Math.px2Size(560+OFFSET_Y)/*Math.px2Size()*/)
			call BlzFrameSetSize(CONTAINER,Math.px2Size(WIDTH),Math.px2Size(HEIGHT))
			set HEADER_BACKDROP = BlzCreateFrame("MyTextBox",CONTAINER,0,0)
			set HEADER_TEXT = BlzCreateFrame("MyTextLarge",CONTAINER,0,0)
			call BlzFrameSetPoint(HEADER_TEXT,FRAMEPOINT_BOTTOMLEFT,CONTAINER,FRAMEPOINT_TOPLEFT,0.,0.)
			call BlzFrameSetText(HEADER_TEXT,"캐릭터 선택 ("+I2S(TIME)+")")
			call BlzFrameSetPoint(HEADER_BACKDROP,FRAMEPOINT_BOTTOMLEFT,HEADER_TEXT,FRAMEPOINT_BOTTOMLEFT,-0.005,-0.005)
			call BlzFrameSetPoint(HEADER_BACKDROP,FRAMEPOINT_TOPRIGHT,HEADER_TEXT,FRAMEPOINT_TOPRIGHT,0.005,0.005)
			/*initTrigger*/
			set MAIN_TRIGGER = CreateTrigger()
			set MAIN_COND = TriggerAddCondition(MAIN_TRIGGER,function thistype.cond)
			call TriggerRegisterTimerEvent(MAIN_TRIGGER,1.,true)
			set PANEL_REFRESH_REQUEST = CreateTrigger()
			call TriggerAddCondition(PANEL_REFRESH_REQUEST,function thistype.panelRefresh)
			/*CreateWidget*/
			call createWidget(-2)
			call createWidget('HR00')
			call createWidget('HR09')
			call createWidget('HR07')
			call createWidget('U000')
			call createWidget('U001')
			call createWidget('U002')
			call createWidget('U003')
			call createWidget('U004')
			/*CreateChinghoSelect*/
			set CHINGHO = BlzCreateFrame("MBEdge",CONTAINER,0,0)
			call BlzFrameSetPoint(CHINGHO,FRAMEPOINT_TOPLEFT,CONTAINER,FRAMEPOINT_TOPRIGHT,Math.px2Size(32),0.)
			call BlzFrameSetSize(CHINGHO,Math.px2Size(CHINGHO_WIDTH),Math.px2Size(CHINGHO_HEIGHT))
			set CHINGHO_HEADER_BACKDROP = BlzCreateFrame("MyTextBox",CHINGHO,0,0)
			set CHINGHO_HEADER_TEXT = BlzCreateFrame("MyTextLarge",CHINGHO,0,0)
			call BlzFrameSetPoint(CHINGHO_HEADER_TEXT,FRAMEPOINT_BOTTOMLEFT,CHINGHO,FRAMEPOINT_TOPLEFT,0.,0.)
			call BlzFrameSetText(CHINGHO_HEADER_TEXT,"칭호 선택")
			call BlzFrameSetPoint(CHINGHO_HEADER_BACKDROP,FRAMEPOINT_BOTTOMLEFT,CHINGHO_HEADER_TEXT,FRAMEPOINT_BOTTOMLEFT,-0.005,-0.005)
			call BlzFrameSetPoint(CHINGHO_HEADER_BACKDROP,FRAMEPOINT_TOPRIGHT,CHINGHO_HEADER_TEXT,FRAMEPOINT_TOPRIGHT,0.005,0.005)
			set CHINGHO_PAGE_NEXT = BlzCreateFrame("ChinghoSelectPageNextButton",CHINGHO,0,0)
			call BlzFrameSetPointPixel(CHINGHO_PAGE_NEXT,FRAMEPOINT_BOTTOMRIGHT,CHINGHO,FRAMEPOINT_BOTTOMRIGHT,-16,16)
			call BlzFrameSetSizePixel(CHINGHO_PAGE_NEXT,48,48)
			set f = BlzGetFrameByName("ChinghoSelectPageNextButtonText",0)
			call BlzFrameSetPoint(f,FRAMEPOINT_CENTER,CHINGHO_PAGE_NEXT,FRAMEPOINT_CENTER,0.,0.)
			call BlzFrameSetText(f,"▶")
			call BlzTriggerRegisterFrameEvent(MAIN_TRIGGER,CHINGHO_PAGE_NEXT,FRAMEEVENT_CONTROL_CLICK)
			call BlzTriggerRegisterFrameEvent(MAIN_TRIGGER,CHINGHO_PAGE_NEXT,FRAMEEVENT_MOUSE_LEAVE)
			set CHINGHO_PAGE_PREV = BlzCreateFrame("ChinghoSelectPagePrevButton",CHINGHO,0,0)
			call BlzFrameSetPointPixel(CHINGHO_PAGE_PREV,FRAMEPOINT_BOTTOMRIGHT,CHINGHO_PAGE_NEXT,FRAMEPOINT_BOTTOMLEFT,-16,0)
			call BlzFrameSetSizePixel(CHINGHO_PAGE_PREV,48,48)
			set f = BlzGetFrameByName("ChinghoSelectPagePrevButtonText",0)
			call BlzFrameSetPoint(f,FRAMEPOINT_CENTER,CHINGHO_PAGE_PREV,FRAMEPOINT_CENTER,0.,0.)
			call BlzFrameSetText(f,"◀")
			call BlzTriggerRegisterFrameEvent(MAIN_TRIGGER,CHINGHO_PAGE_PREV,FRAMEEVENT_CONTROL_CLICK)
			call BlzTriggerRegisterFrameEvent(MAIN_TRIGGER,CHINGHO_PAGE_PREV,FRAMEEVENT_MOUSE_LEAVE)
			/*CreateChinghoWidget*/
			call createChinghoWidget(-2)
			call createChinghoWidget('C000')
			call createChinghoWidget('C001')
			call createChinghoWidget('C002')
			call createChinghoWidget('C003')
			call createChinghoWidget('C004')
			call createChinghoWidget('C005')
			call createChinghoWidget('C006')
			call createChinghoWidget('C007')
			call createChinghoWidget('C008')
			/*PanelContainer*/
			set PANEL_CONTAINER = BlzCreateFrame("MBEdge",CONTAINER,0,0)
			call BlzFrameSetPoint(PANEL_CONTAINER,FRAMEPOINT_TOPLEFT,CONTAINER,FRAMEPOINT_BOTTOMLEFT,0.,Math.px2Size(-32))
			call BlzFrameSetSize(PANEL_CONTAINER,Math.px2Size(WIDTH),Math.px2Size(CHINGHO_HEIGHT-32-HEIGHT))
			set PANEL_HEADER_BACKDROP = BlzCreateFrame("MyTextBox",PANEL_CONTAINER,0,0)
			set PANEL_HEADER_TEXT = BlzCreateFrame("MyTextLarge",PANEL_CONTAINER,0,0)
			call BlzFrameSetPoint(PANEL_HEADER_TEXT,FRAMEPOINT_BOTTOMLEFT,PANEL_CONTAINER,FRAMEPOINT_TOPLEFT,0.,0.)
			call BlzFrameSetText(PANEL_HEADER_TEXT,"캐릭터&칭호")
			call BlzFrameSetPoint(PANEL_HEADER_BACKDROP,FRAMEPOINT_BOTTOMLEFT,PANEL_HEADER_TEXT,FRAMEPOINT_BOTTOMLEFT,-0.005,-0.005)
			call BlzFrameSetPoint(PANEL_HEADER_BACKDROP,FRAMEPOINT_TOPRIGHT,PANEL_HEADER_TEXT,FRAMEPOINT_TOPRIGHT,0.005,0.005)
			/*CreateConfirmButton*/
			set CONFIRM = BlzCreateFrame("CharacterSelectConfirmButton",CONTAINER,0,0)
			call BlzFrameSetPoint(CONFIRM,FRAMEPOINT_BOTTOM,origin,FRAMEPOINT_BOTTOM,0.,0.025)
			call BlzFrameSetSize(CONFIRM,Math.px2Size(128),Math.px2Size(48))
			set f = BlzGetFrameByName("CharacterSelectConfirmButtonText",0)
			call BlzFrameSetPoint(f,FRAMEPOINT_CENTER,CONFIRM,FRAMEPOINT_CENTER,0.,0.)
			call BlzFrameSetText(f,"결정")
			call BlzFrameSetScale(CONFIRM,1.5)
			call BlzTriggerRegisterFrameEvent(MAIN_TRIGGER,CONFIRM,FRAMEEVENT_CONTROL_CLICK)
			call BlzTriggerRegisterFrameEvent(MAIN_TRIGGER,CONFIRM,FRAMEEVENT_MOUSE_LEAVE)
			/*initPlayerProperty*/
			loop
				exitwhen i >= PLAYER_MAX
				set CHINGHO_PAGE_INDEX[i] = 0
				if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(i)) == MAP_CONTROL_USER then
					set CHINGHO_ID[i] = -2
					set ID[i] = -2
					set READY[i] = false
					set PANEL[i] = CharacterInfoPanel.create(Player(i))
					
					call TriggerRegisterPlayerEventLeave(MAIN_TRIGGER,Player(i))
					call playerSetChinghoPage(Player(i),0)
				else
					set CHINGHO_ID[i] = 'C000'
					set ID[i] = 0
					set PANEL[i] = 0
					set READY[i] = true
				endif				
				set i = i + 1
			endloop
			/**/
			set origin = null
			set f = null
		endmethod

	endstruct

endlibrary