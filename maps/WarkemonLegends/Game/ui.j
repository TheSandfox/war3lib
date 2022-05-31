library UI requires TimerUtils

	globals
		constant string TEXTURE_RED		= "ReplaceableTextures\\teamcolor\\teamcolor00.blp"
		constant string TEXTURE_BLUE	= "ReplaceableTextures\\teamcolor\\teamcolor01.blp"
		constant string TEXTURE_PURPLE	= "ReplaceableTextures\\teamcolor\\teamcolor03.blp"
		constant string TEXTURE_YELLOW 	= "ReplaceableTextures\\teamcolor\\teamcolor04.blp"
		constant string TEXTURE_GREEN	= "ReplaceableTextures\\teamcolor\\teamcolor06.blp"
		constant string TEXTURE_LIGHT_GRAY = "ReplaceableTextures\\teamcolor\\teamcolor08.blp"
		constant string TEXTURE_GRAY	= "ReplaceableTextures\\teamcolor\\teamcolor27.blp"
		constant string TEXTURE_BLACK	= "Textures\\black32.blp"
	endglobals

	//! textmacro DestroyFrameSimple takes key
		call BlzDestroyFrame($key$)
		set $key$ = null
	//! endtextmacro

	struct UI

		static framehandle ORIGIN			= null

		static framehandle SURFACE_UI		= null
			static framehandle SURFACE_BATTLE_UI 	= null
			static framehandle SURFACE_TYPECHART	= null
			static framehandle SURFACE_DIALOG 		= null

		static framehandle SURFACE_OVERLAY 	= null
		
		private static method onInit takes nothing returns nothing
			set ORIGIN 			= BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI,0)
			/*UI*/
			set SURFACE_UI 		= BlzCreateFrameByType("FRAME","",ORIGIN,"",0)
				set SURFACE_BATTLE_UI	= BlzCreateFrameByType("FRAME","",SURFACE_UI,"",0)
				set SURFACE_TYPECHART	= BlzCreateFrameByType("FRAME","",SURFACE_UI,"",0)
				set SURFACE_DIALOG		= BlzCreateFrameByType("FRAME","",SURFACE_UI,"",0)
			/*OVERLAY*/
			set SURFACE_OVERLAY = BlzCreateFrameByType("FRAME","",ORIGIN,"",0)
		endmethod

	endstruct

	struct SimpleModelFrame

		framehandle dummy	= null
		framehandle model	= null

		method setModel takes string path returns nothing
			call BlzFrameSetModel(.model,path,0)
		endmethod

		method setPoint takes framehandle target, framepointtype pt, real xoffset, real yoffset returns nothing
			call BlzFrameSetPoint(.dummy,FRAMEPOINT_BOTTOMLEFT,target,pt,xoffset,yoffset)
		endmethod

		static method create takes string path, framehandle parent returns thistype
			local thistype this = allocate()
			set .dummy = BlzCreateFrameByType("BACKDROP","",UI.SURFACE_UI,"",0)
			set .model = BlzCreateFrameByType("SPRITE","",parent,"",0)
			call BlzFrameSetSize(.dummy,0.01,0.01)
			call BlzFrameSetVisible(.dummy,false)
			call BlzFrameSetModel(.model,path,0)
			call BlzFrameSetSize(.model,0.01,0.01)
			call BlzFrameSetPoint(.model,FRAMEPOINT_BOTTOMLEFT,.dummy,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call BlzDestroyFrame(.dummy)
			call BlzDestroyFrame(.model)
			set .dummy = null
			set .model = null
		endmethod

	endstruct

	struct ElementTypeIcon extends SimpleModelFrame

		static method create takes string path, framehandle parent, framehandle pivot, framepointtype pointtype, integer xoffset, integer yoffset returns thistype
			local thistype this = allocate(path, parent)
			call BlzFrameSetScale(.model,1./2700.)
			call BlzFrameSetPoint(.dummy,FRAMEPOINT_BOTTOMLEFT,pivot,pointtype,Math.px2Size(xoffset),Math.px2Size(yoffset))
			return this
		endmethod

	endstruct

	struct FadeIn

		timer main_timer	= null
		framehandle frame	= null

		private static method endTimer takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			call destroy()
		endmethod

		static method create takes string path, real lifespan, player forplayer returns thistype
			local thistype this = allocate()
			set .frame = BlzCreateFrameByType("SPRITE","",UI.SURFACE_OVERLAY,"",0)
			call BlzFrameSetModel(.frame,path,0)
			call BlzFrameSetPoint(.frame,FRAMEPOINT_BOTTOMLEFT,UI.ORIGIN,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			call BlzFrameSetSize(.frame,1.,1.)
			call BlzFrameSetVisible(.frame,GetLocalPlayer()==forplayer)
			set .main_timer = Timer.new(this)
			call Timer.start(.main_timer,lifespan,false,function thistype.endTimer)
			return this
		endmethod

		private method onDestroy takes nothing returns nothing
			call BlzDestroyFrame(.frame)
			call Timer.release(.main_timer)
			set .frame = null
			set .main_timer = null
		endmethod

	endstruct

endlibrary

library ElementTypeChart requires Character, UI

	struct ElementTypeChart

		private static constant integer ICON_SIZE = 60
		private static constant integer ICON_INSET = 6
		private static framehandle BACKDROP = null

		method show takes player forplayer, boolean flag returns nothing
			if GetLocalPlayer() == forplayer then
				call BlzFrameSetVisible(UI.SURFACE_TYPECHART,flag)
			endif
		endmethod

		static method init takes nothing returns nothing
			local integer i_max = ELEMENT_TYPE_SIZE + 1
			local integer j_max = ELEMENT_TYPE_SIZE + 1
			local integer i = 1
			local integer j = 1
			local ElementTypeIcon f = 0
			set BACKDROP = BlzCreateFrameByType("BACKDROP","",UI.SURFACE_TYPECHART,"",0)
			call BlzFrameSetTexture(BACKDROP,"Textures\\black32.blp",0,true)
			call BlzFrameSetAlpha(BACKDROP,128)
			call BlzFrameSetPoint(BACKDROP,FRAMEPOINT_CENTER,UI.ORIGIN,FRAMEPOINT_CENTER,0.,0.)
			call BlzFrameSetSize(BACKDROP,Math.px2Size(i_max*ICON_SIZE),Math.px2Size(j_max*ICON_SIZE))
			loop
				exitwhen i >= i_max
				set f = ElementTypeIcon.create(ELEMENT_TYPE_ICON_PATH[i-1],UI.SURFACE_TYPECHART,BACKDROP,FRAMEPOINT_TOPLEFT,i*ICON_SIZE+ICON_INSET,-ICON_SIZE+ICON_INSET)
				set i = i + 1
			endloop
			set i = 1
			loop
				exitwhen i >= i_max
				set f = ElementTypeIcon.create(ELEMENT_TYPE_ICON_PATH[i-1],UI.SURFACE_TYPECHART,BACKDROP,FRAMEPOINT_TOPLEFT,ICON_INSET,-ICON_SIZE*(i+1)+ICON_INSET)
				set i = i + 1
			endloop
			set i = 0
			set j = 0
			loop
				/*세로(i) : 공격, 가로(j) : 방어*/
				exitwhen i >= ELEMENT_TYPE_SIZE
				set j = 0
				loop
					exitwhen j >= ELEMENT_TYPE_SIZE
					set f = ElementTypeIcon.create(ELEMENT_TYPE_VALUE_ICON_PATH[MonsterData.getTypeValueIndex(i,j)],UI.SURFACE_TYPECHART,BACKDROP,FRAMEPOINT_TOPLEFT,/*
						*/ICON_SIZE+(ICON_SIZE*j)+ICON_INSET,-ICON_SIZE-(ICON_SIZE*(i+1))+ICON_INSET)
					set j = j + 1
				endloop
				set i = i + 1
			endloop
			/*숨김(임시)*/
			call BlzFrameSetVisible(UI.SURFACE_TYPECHART,false)
		endmethod

	endstruct

endlibrary