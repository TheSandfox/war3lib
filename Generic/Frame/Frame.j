//! import "ProgressBar.j"

//! textmacro destroyFrame takes name
	call BlzDestroyFrame($name$)
	set $name$ = null
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