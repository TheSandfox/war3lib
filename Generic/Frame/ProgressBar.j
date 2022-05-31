library ProgressBar

	struct ProgressBar

		private static constant integer OFFSET_Y = 300
		private static constant integer WIDTH = 640
		private static constant integer HEIGHT = 32

		framehandle backdrop	= null
		framehandle fill 		= null
		framehandle text		= null
		real value_true = 0.		/*0.0~1.0*/
		boolean reverse = false

		method operator value takes nothing returns real
			return .value_true
		endmethod

		method operator value= takes real nv returns nothing
			local real v = nv
			set .value_true = v
			if .reverse then
				set v = 1. - v
			endif
			call BlzFrameSetVisible(.fill,v > 0.05 and v <= 1.)
			call BlzFrameClearAllPoints(.fill)
			call BlzFrameSetPoint(.fill,FRAMEPOINT_BOTTOMLEFT,.backdrop,FRAMEPOINT_BOTTOMLEFT,0.005,0.005)
			call BlzFrameSetPoint(.fill,FRAMEPOINT_TOPRIGHT,.backdrop,FRAMEPOINT_BOTTOMLEFT,(Math.px2Size(WIDTH)-0.01)*v,Math.px2Size(HEIGHT)-0.005)
		endmethod

		static method create takes string name, player forplayer returns thistype
			local thistype this = allocate()
			local framehandle origin = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI,0)
			set .backdrop = BlzCreateFrame("MyTextBox",origin,0,this)
			call BlzFrameSetPoint(.backdrop,FRAMEPOINT_BOTTOM,origin,FRAMEPOINT_BOTTOM,0.,Math.px2Size(OFFSET_Y))
			call BlzFrameSetSize(.backdrop,Math.px2Size(WIDTH),Math.px2Size(HEIGHT))
			set .fill = BlzCreateFrameByType("BACKDROP","",.backdrop,"",this)
			call BlzFrameSetPoint(.fill,FRAMEPOINT_BOTTOMLEFT,.backdrop,FRAMEPOINT_BOTTOMLEFT,0.005,0.005)
			call BlzFrameSetPoint(.fill,FRAMEPOINT_TOPRIGHT,.backdrop,FRAMEPOINT_TOPRIGHT,-0.005,-0.005)
			call BlzFrameSetTexture(.fill,"ReplaceableTextures\\teamcolor\\teamcolor10.blp",0,true)
			call BlzFrameSetVisible(.fill,false)
			set .text = BlzCreateFrame("MyText",.backdrop,0,0)
			call BlzFrameSetAllPoints(.text,.backdrop)
			call BlzFrameSetTextAlignment(.text,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
			call BlzFrameSetText(.text,name)
			call BlzFrameSetVisible(.backdrop,GetLocalPlayer() == forplayer)
			set origin = null
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			//! runtextmacro destroyFrame(".backdrop")
			//! runtextmacro destroyFrame(".fill")
			//! runtextmacro destroyFrame(".text")
		endmethod

	endstruct

endlibrary