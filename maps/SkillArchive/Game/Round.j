library Round

	globals
		constant integer ROUND_TIME_INITIAL = 15//30
		constant integer ROUND_TIME = 90
		integer ROUND_TIME_REMAIN = 0
	endglobals

	struct Round

		static integer ROUND = 0
		static timer TIMER = null

		static framehandle BACKDROP = null
		static framehandle TEXT = null
		static framehandle ICON = null
		static framehandle ROUND_BACKDROP = null
		static framehandle ROUND_TEXT = null

		static method refreshFrame takes nothing returns nothing
			local integer time = ROUND_TIME_REMAIN
			local string minitue = I2S(R2I(time/60.))
			local string second = I2S(ModuloInteger(R2I(time),60))
			if StringLength(minitue) < 2 then
				set minitue = "0"+minitue
			endif
			if StringLength(second) < 2 then
				set second = "0"+second
			endif
			call BlzFrameSetText(TEXT," |r|cffffcc00"+minitue+":"+second+"|r")
			call BlzFrameSetText(ROUND_TEXT,I2S(ROUND))
		endmethod

		static method timerAction takes nothing returns nothing
			set ROUND_TIME_REMAIN = ROUND_TIME_REMAIN - 1
			if ROUND_TIME_REMAIN <= 0 then
				call Wave.spawn()
				if ROUND > 0 then
					call Game.addLevel()
					call Guardians.addLevel()
					call TreeOfLife.addLevel()
					call SkillShop.addLevel()
				endif
				set ROUND = ROUND + 1
				set ROUND_TIME_REMAIN = ROUND_TIME
			endif
			call refreshFrame()
		endmethod

		static method init takes nothing returns nothing
			set TIMER = Timer.new(0)
			set ROUND_TIME_REMAIN = ROUND_TIME_INITIAL
			call Timer.start(TIMER,1.,true,function thistype.timerAction)
			/*라운드타이머*/
			set BACKDROP = BlzCreateFrame("MyTextBox",FRAME_GAME_UI,0,0)
			set TEXT = BlzCreateFrame("MyText",FRAME_GAME_UI,0,0)
			call BlzFrameSetPointPixel(TEXT,FRAMEPOINT_BOTTOMRIGHT,FRAME_PORTRAIT_BACKDROP,FRAMEPOINT_TOPLEFT,-12,16)
			call BlzFrameSetText(TEXT,"|cffffcc0000:"+I2S(ROUND_TIME_REMAIN)+"|r")
			call BlzFrameSetPointPixel(BACKDROP,FRAMEPOINT_TOPLEFT,TEXT,FRAMEPOINT_TOPLEFT,-8,8)
			call BlzFrameSetPointPixel(BACKDROP,FRAMEPOINT_BOTTOMRIGHT,TEXT,FRAMEPOINT_BOTTOMRIGHT,8,-8)
			set ICON = BlzCreateFrameByType("BACKDROP","",FRAME_GAME_UI,"",0)
			call BlzFrameSetPoint(ICON,FRAMEPOINT_BOTTOMRIGHT,BACKDROP,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			call BlzFrameSetSizePixel(ICON,32,32)
			call BlzFrameSetTexture(ICON,"ReplaceableTextures\\Commandbuttons\\BTNGhoul.blp",0,true)
			set ROUND_BACKDROP = BlzCreateFrameByType("BACKDROP","",FRAME_GAME_UI,"",0)
			call BlzFrameSetPoint(ROUND_BACKDROP,FRAMEPOINT_BOTTOMRIGHT,ICON,FRAMEPOINT_BOTTOMLEFT,0.,0.)
			call BlzFrameSetSizePixel(ROUND_BACKDROP,32,32)
			call BlzFrameSetTexture(ROUND_BACKDROP,"ui\\console\\human\\human-transport-slot.blp",0,true)
			set ROUND_TEXT = BlzCreateFrame("MyText",FRAME_GAME_UI,0,0)
			call BlzFrameSetPoint(ROUND_TEXT,FRAMEPOINT_CENTER,ROUND_BACKDROP,FRAMEPOINT_CENTER,0.,0.)
			call BlzFrameSetTextAlignment(ROUND_TEXT,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
			call BlzFrameSetText(ROUND_TEXT,"0")
		endmethod

	endstruct

endlibrary