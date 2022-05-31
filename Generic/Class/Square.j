library Line requires TimerUtils
globals
	private hashtable HASH = InitHashtable()
endglobals
private struct Line

	real x = 0.
	real y = 0.
	real z = 0.
	real angle = 0.
	real length = 0.
	real width = 0.
	real r = 1.
	real g = 1.
	real b = 1.
	real a = 1.
	real alpha_max = 1.
	boolean permanent = false
	boolean refresh_color = true
	boolean refresh_position = true
	player visible_player = null
	/*타이머*/
	private timer t = null
	private timer pointtimer = null
	private real angleaxis = 0.
	private real lengthaxis = 0.
	private real widthaxis = 0.
	private real velo = 0.
	private real dir = 0.
	real alphaaxis = 0.
	private real temp_overtime = 0.

	method getLightning takes integer index returns lightning
		return LoadLightningHandle(HASH,this,index)
	endmethod

	method setLightning takes integer index, lightning nl returns nothing
		call SaveLightningHandle(HASH,this,index,nl)
	endmethod

	stub method setColor takes real r, real g, real b ,real a returns thistype
		return this
	endmethod

	stub method setLocalColor takes real r, real g, real b, real a returns nothing

	endmethod

	stub method refreshPosition takes nothing returns nothing

	endmethod

	method setPositionGeneral takes real x, real y, real z, real length, real angle, real width returns nothing
		set .x = x
		set .y = y
		set .z = z
		set .length = length
		set .angle = angle
		set .width = width
		call refreshPosition()
	endmethod

	method setPosition takes real x, real y, real z returns nothing
		set .x = x
		set .y = y
		set .z = z
		call refreshPosition()
	endmethod

	method setAngle takes real nv returns nothing
		set .angle = nv
		call refreshPosition()
	endmethod

	method setLength takes real nv returns nothing
		set .length = nv
		call refreshPosition()
	endmethod

	method setWidth takes real nv returns nothing
		set .width = nv
		call refreshPosition()
	endmethod

	method setVelo takes real nv returns nothing
		set .velo = nv
	endmethod

	method setDirection takes real nv returns nothing
		set .dir = nv
	endmethod

	method setWidthAxis takes real nv returns nothing
		set .widthaxis = nv
	endmethod

	method setLengthAxis takes real nv returns nothing
		set .lengthaxis = nv
	endmethod

	method setAngleAxis takes real nv returns nothing
		set .angleaxis = nv
	endmethod

	method fadeIn takes real overtime returns nothing
		set alphaaxis = 1/overtime
	endmethod

	method fadeOut takes real overtime returns nothing
		set alphaaxis = -1/overtime
	endmethod

	static method pointAction takes nothing returns nothing
		local thistype this = Timer.getDataEx()
		call fadeOut(temp_overtime)
	endmethod

	method setFadeOutPoint takes real fadeat, real overtime returns nothing
		if pointtimer == null then
			set pointtimer = Timer.new(this)
		endif
		set .temp_overtime = overtime
		call Timer.start(pointtimer,fadeat,false,function thistype.pointAction)
	endmethod

	stub method periodicAction takes nothing returns nothing
		/*SetLocalValues*/
	endmethod

	static method tA takes nothing returns nothing
		local real na = 0.
		local thistype this = Timer.getDataEx()
		if .refresh_position then
			call setPositionGeneral(x+velo*Cos(Deg2Rad(dir))*TIMER_TICK,y+velo*Sin(Deg2Rad(dir))*TIMER_TICK,z,length+(lengthaxis*TIMER_TICK),angle+(angleaxis*TIMER_TICK),width+(widthaxis*TIMER_TICK))
		endif
		set .a = .a + alphaaxis*TIMER_TICK
		set na = .a
		if na <= 0. then
			set na = 0.
			set .a = 0.
			set .alphaaxis = 0.
		elseif na >= 1. then
			set na = 1.
			set .a = 1.
			set .alphaaxis = 0.
		endif
		if .refresh_color then
			call setColor(r,g,b,na)
		endif
		call periodicAction()
		if a <= 0. and .alphaaxis < 0. and not .permanent then
			call destroy()
		endif
	endmethod

	static method create takes nothing returns thistype
		local thistype this = allocate()
		set .t = Timer.new(this)
		set .pointtimer = Timer.new(this)
		call Timer.start(.t,TIMER_TICK,true,function thistype.tA)
		return this
	endmethod

	method onDestroy takes nothing returns nothing
		call ReleaseTimer(.t)
		set .t = null
		call ReleaseTimer(.pointtimer)
		set .pointtimer = null
		set .visible_player = null
		//call Effect.create(EF_EXPLOSION,x,y,z,0).setDuration(1.5)
	endmethod

endstruct

struct Square extends Line

	method setLocalColor takes real r, real g, real b, real a returns nothing
		call SetLightningColor(getLightning(0),r,g,b,a*alpha_max)
		call SetLightningColor(getLightning(1),r,g,b,a*alpha_max)
		call SetLightningColor(getLightning(2),r,g,b,a*alpha_max)
		call SetLightningColor(getLightning(3),r,g,b,a*alpha_max)
	endmethod

	method setColor takes real r, real g, real b ,real a returns Line
		set .r = r
		set .g = g
		set .b = b
		set .a = a
		call setLocalColor(r,g,b,a)
		return this
	endmethod

	method refreshPosition takes nothing returns nothing
		if .visible_player == null or GetLocalPlayer() == .visible_player then
			call MoveLightningEx(getLightning(0),true,Math.pPX(x,width,angle+90),Math.pPY(y,width,angle+90),z,/*
			*/Math.pPX(Math.pPX(x,width,angle+90),length,angle),Math.pPY(Math.pPY(y,width,angle+90),length,angle),z)
			call MoveLightningEx(getLightning(1),true,Math.pPX(x,width,angle-90),Math.pPY(y,width,angle-90),z,/*
				*/Math.pPX(Math.pPX(x,width,angle-90),length,angle),Math.pPY(Math.pPY(y,width,angle-90),length,angle),z)
			call MoveLightningEx(getLightning(2),true,Math.pPX(x,width,angle+90),Math.pPY(y,width,angle+90),z,/*
				*/Math.pPX(x,width,angle-90),Math.pPY(y,width,angle-90),z)
			call MoveLightningEx(getLightning(3),true,Math.pPX(Math.pPX(x,width,angle+90),length,angle),Math.pPY(Math.pPY(y,width,angle+90),length,angle),z,/*
				*/Math.pPX(Math.pPX(x,width,angle-90),length,angle),Math.pPY(Math.pPY(y,width,angle-90),length,angle),z)
		else
			call MoveLightningEx(getLightning(0),false,0.,0.,0.,0.,0.,0.)
			call MoveLightningEx(getLightning(1),false,0.,0.,0.,0.,0.,0.)
			call MoveLightningEx(getLightning(2),false,0.,0.,0.,0.,0.,0.)
			call MoveLightningEx(getLightning(3),false,0.,0.,0.,0.,0.,0.)
		endif
		
	endmethod

	static method create takes real x, real y, real z, real length, real angle, real width, player visible_player returns thistype
		local thistype this = allocate()
		set .x = x
		set .y = y
		set .z = z
		set .length = length
		set .angle = angle
		set .width = width
		set .visible_player = visible_player
		call setLightning(0,AddLightningEx("LSER",true,x,y,z,x,y,z))
		call setLightning(1,AddLightningEx("LSER",true,x,y,z,x,y,z))
		call setLightning(2,AddLightningEx("LSER",true,x,y,z,x,y,z))
		call setLightning(3,AddLightningEx("LSER",true,x,y,z,x,y,z))
		call refreshPosition()
		return this
	endmethod

	method onDestroy takes nothing returns nothing
		local integer i = 0
		loop
			exitwhen i >= 4
			call DestroyLightning(getLightning(i))
			call RemoveSavedHandle(HASH,this,i)
			set i = i + 1
		endloop
	endmethod

endstruct

struct DoubleLine extends Line

	method setLocalColor takes real r, real g, real b, real a returns nothing
		call SetLightningColor(getLightning(0),r,g,b,a*alpha_max)
		call SetLightningColor(getLightning(1),r,g,b,a*alpha_max)
	endmethod

	method setColor takes real r, real g, real b ,real a returns Line
		set .r = r
		set .g = g
		set .b = b
		set .a = a
		call setLocalColor(r,g,b,a)
		return this
	endmethod

	method refreshPosition takes nothing returns nothing
		if .visible_player == null or GetLocalPlayer() == .visible_player then
			call MoveLightningEx(getLightning(0),true,Math.pPX(x,width,angle+90),Math.pPY(y,width,angle+90),z,/*
				*/Math.pPX(Math.pPX(x,width,angle+90),length,angle),Math.pPY(Math.pPY(y,width,angle+90),length,angle),z)
			call MoveLightningEx(getLightning(1),true,Math.pPX(x,width,angle-90),Math.pPY(y,width,angle-90),z,/*
				*/Math.pPX(Math.pPX(x,width,angle-90),length,angle),Math.pPY(Math.pPY(y,width,angle-90),length,angle),z)
		else
			call MoveLightningEx(getLightning(0),false,0,0,0,0,0,0)
			call MoveLightningEx(getLightning(1),false,0,0,0,0,0,0)
		endif
	endmethod

	static method create takes real x, real y, real z, real length, real angle, real width, player visible_player returns thistype
		local thistype this = allocate()
		set .x = x
		set .y = y
		set .z = z
		set .length = length
		set .angle = angle
		set .width = width
		set .visible_player = visible_player
		call setLightning(0,AddLightningEx("LSER",true,x,y,z,x,y,z))
		call setLightning(1,AddLightningEx("LSER",true,x,y,z,x,y,z))
		call refreshPosition()
		return this
	endmethod

	method onDestroy takes nothing returns nothing
		local integer i = 0
		loop
			exitwhen i >= 2
			call DestroyLightning(getLightning(i))
			call RemoveSavedHandle(HASH,this,i)
			set i = i + 1
		endloop
	endmethod

endstruct

struct Arrow extends Line

	method refreshPosition takes nothing returns nothing
		if .visible_player == null or GetLocalPlayer() == .visible_player then
			call MoveLightningEx(getLightning(0),true,Math.pPX(x,length,angle),Math.pPY(y,length,angle),z,/*
				*/Math.pPX(Math.pPX(x,length*0.75,angle),width,angle+90),Math.pPY(Math.pPY(y,length*0.75,angle),width,angle+90),z)
			call MoveLightningEx(getLightning(1),true,Math.pPX(x,length,angle),Math.pPY(y,length,angle),z,/*
				*/Math.pPX(Math.pPX(x,length*0.75,angle),width,angle-90),Math.pPY(Math.pPY(y,length*0.75,angle),width,angle-90),z)
			call MoveLightningEx(getLightning(2),true,Math.pPX(x,length*0.25,angle),Math.pPY(y,length*0.25,angle),z,/*
				*/Math.pPX(x,width,angle+90),Math.pPY(y,width,angle+90),z)
			call MoveLightningEx(getLightning(3),true,Math.pPX(x,length*0.25,angle),Math.pPY(y,length*0.25,angle),z,/*
				*/Math.pPX(x,width,angle-90),Math.pPY(y,width,angle-90),z)
			call MoveLightningEx(getLightning(4),true,Math.pPX(Math.pPX(x,length*0.75,angle),width,angle+90),Math.pPY(Math.pPY(y,length*0.75,angle),width,angle+90),z,/*
				*/Math.pPX(x,width,angle+90),Math.pPY(y,width,angle+90),z)
			call MoveLightningEx(getLightning(5),true,Math.pPX(Math.pPX(x,length*0.75,angle),width,angle-90),Math.pPY(Math.pPY(y,length*0.75,angle),width,angle-90),z,/*
				*/Math.pPX(x,width,angle-90),Math.pPY(y,width,angle-90),z)
		else
			call MoveLightningEx(getLightning(0),false,0,0,0,0,0,0)
			call MoveLightningEx(getLightning(1),false,0,0,0,0,0,0)
			call MoveLightningEx(getLightning(2),false,0,0,0,0,0,0)
			call MoveLightningEx(getLightning(3),false,0,0,0,0,0,0)
			call MoveLightningEx(getLightning(4),false,0,0,0,0,0,0)
			call MoveLightningEx(getLightning(5),false,0,0,0,0,0,0)
		endif
	endmethod

	method setLocalColor takes real r, real g, real b, real a returns nothing
		call SetLightningColor(getLightning(0),r,g,b,a*alpha_max)
		call SetLightningColor(getLightning(1),r,g,b,a*alpha_max)
		call SetLightningColor(getLightning(2),r,g,b,a*alpha_max)
		call SetLightningColor(getLightning(3),r,g,b,a*alpha_max)
		call SetLightningColor(getLightning(4),r,g,b,a*alpha_max)
		call SetLightningColor(getLightning(5),r,g,b,a*alpha_max)
	endmethod

	method setColor takes real r, real g, real b ,real a returns Line
		set .r = r
		set .g = g
		set .b = b
		set .a = a
		call setLocalColor(r,g,b,a)
		return this
	endmethod

	static method create takes real x, real y, real z, real length, real angle, real width, player visible_player returns thistype
		local thistype this = allocate()
		set .x = x
		set .y = y
		set .z = z
		set .length = length
		set .angle = angle
		set .width = width
		set .visible_player = visible_player
		call setLightning(0,AddLightningEx("LSER",true,x,y,z,x,y,z))
		call setLightning(1,AddLightningEx("LSER",true,x,y,z,x,y,z))
		call setLightning(2,AddLightningEx("LSER",true,x,y,z,x,y,z))
		call setLightning(3,AddLightningEx("LSER",true,x,y,z,x,y,z))
		call setLightning(4,AddLightningEx("LSER",true,x,y,z,x,y,z))
		call setLightning(5,AddLightningEx("LSER",true,x,y,z,x,y,z))
		call refreshPosition()
		return this
	endmethod

	method onDestroy takes nothing returns nothing
		local integer i = 0
		loop
			exitwhen i >= 6
			call DestroyLightning(getLightning(i))
			call RemoveSavedHandle(HASH,this,i)
			set i = i + 1
		endloop
	endmethod

endstruct

endlibrary