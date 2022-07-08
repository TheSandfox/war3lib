//! import "ProgressBar.j"

//! textmacro destroyFrame takes name
	call BlzDestroyFrame($name$)
	set $name$ = null
//! endtextmacro 

//! textmacro triggerRegisterFrameEventSimple takes trig, fname
	call BlzTriggerRegisterFrameEvent($trig$,$fname$,FRAMEEVENT_CONTROL_CLICK)
	call BlzTriggerRegisterFrameEvent($trig$,$fname$,FRAMEEVENT_MOUSE_ENTER)
	call BlzTriggerRegisterFrameEvent($trig$,$fname$,FRAMEEVENT_MOUSE_LEAVE)
//! endtextmacro

module GetSetFrame

	method getFrame takes integer index returns framehandle
		if HaveSavedHandle(HASH,this,index) then
			return LoadFrameHandle(HASH,this,index)
		else
			return null
		endif
	endmethod

	method setFrame takes integer index, framehandle nf returns framehandle
		if nf == null then
			call BlzDestroyFrame(LoadFrameHandle(HASH,this,index))
			call RemoveSavedHandle(HASH,this,index)
		endif
		call SaveFrameHandle(HASH,this,index,nf)
		return nf
	endmethod

endmodule

library Frame

	struct Frame

		static method resetFocus takes nothing returns nothing
			if GetLocalPlayer() == GetTriggerPlayer() then
				call BlzFrameSetEnable(BlzGetTriggerFrame(),false)
				call BlzFrameSetEnable(BlzGetTriggerFrame(),true)
			endif
		endmethod

		static method addTooltipSimple takes framepointtype pivot, framehandle target, framepointtype relative, string str, real offset_x, real offset_y returns nothing
			local framehandle container = BlzCreateFrameByType("FRAME","",target,"",0)
			local framehandle backdrop = BlzCreateFrame("MyTextBox",container,0,0)
			local framehandle text = BlzCreateFrame("MyText",container,0,0)
			local real x = 0.
			local real y = 0.
			if pivot == FRAMEPOINT_TOPLEFT then
				set x = 0.005
				set y = -0.005
			elseif pivot == FRAMEPOINT_TOP then
				set y = -0.005
			elseif pivot == FRAMEPOINT_TOPRIGHT then
				set x = -0.005
				set y = -0.005
			elseif pivot == FRAMEPOINT_LEFT then
				set x = 0.005
			elseif pivot == FRAMEPOINT_RIGHT then
				set x = -0.005
			elseif pivot == FRAMEPOINT_BOTTOMLEFT then
				set x = 0.005
				set y = 0.005
			elseif pivot == FRAMEPOINT_BOTTOM then
				set y = 0.005
			elseif pivot == FRAMEPOINT_BOTTOMRIGHT then
				set x = -0.005
				set y = 0.005
			endif
			call BlzFrameSetPoint(text,pivot,target,relative,Math.px2Size(offset_x)+x,Math.px2Size(offset_y)+y)
			call BlzFrameSetPoint(backdrop,FRAMEPOINT_TOPLEFT,text,FRAMEPOINT_TOPLEFT,-0.005,0.005)
			call BlzFrameSetPoint(backdrop,FRAMEPOINT_BOTTOMRIGHT,text,FRAMEPOINT_BOTTOMRIGHT,0.005,-0.005)
			call BlzFrameSetText(text,str)
			call BlzFrameSetTooltip(target,container)
			set container = null
			set backdrop = null
			set text = null
		endmethod

	endstruct

function BlzFrameSetPointPixel takes framehandle frame, framepointtype point, framehandle relative, framepointtype pointrelative, real x, real y returns nothing
	call BlzFrameSetPoint(frame,point,relative,pointrelative,x/1800.,y/1800.)
endfunction

function BlzFrameSetSizePixel takes framehandle frame, real x, real y returns nothing
	call BlzFrameSetSize(frame,x/1800.,y/1800.)
endfunction

function BlzFrameSetAbsPointPixel takes framehandle frame, framepointtype point, real x, real y returns nothing
	call BlzFrameSetAbsPoint(frame,point,x/1800.,y/1800.)
endfunction

endlibrary