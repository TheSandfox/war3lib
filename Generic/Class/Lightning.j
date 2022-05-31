library Lightning requires TimerUtils, LocationEx

	struct Lightning extends Object
	
		timer t
		real duration
		real fade
		lightning l
		string type
		Object t1 = 0
		Object t2 = 0
		real x1
		real y1
		real z1
		real x2
		real y2
		real z2
		real ox1
		real oy1
		real oz1
		real ox2
		real oy2
		real oz2
		real r = 1 /* 0.0 ~ 1.0 */
		real g = 1
		real b = 1
		real alpha = 1
	
		method getX takes nothing returns real
			return x1
		endmethod
		method getY takes nothing returns real
			return y1
		endmethod
		method getZ takes nothing returns real
			return z1
		endmethod
		method getYaw takes nothing returns real
			return Math.anglePoints(x1,y1,x2,y2)
		endmethod
		method getPitch takes nothing returns real
			return Math.anglePoints(0,z1,Math.distancePoints(x1,y1,x2,y2),z2)*-1
		endmethod
		method getRoll takes nothing returns real
			return 0.
		endmethod
		method setPosition takes real x, real y, real z returns nothing
			set x1 = x
			set y1 = y
			set z1 = z
		endmethod
		method setPosition2 takes real x, real y, real z returns nothing
			set x2 = x
			set y2 = y
			set z2 = z
		endmethod
		method refreshPosition takes nothing returns nothing
			local real tx1
			local real ty1
			local real tz1
			local real tx2
			local real ty2
			local real tz2	
			if t1 ==  0 then
				set tx1 = x1 + ox1
				set ty1 = y1 + oy1
				set tz1 = z1 + oz1
			else
				set x1 = t1.x
				set y1 = t1.y
				set z1 = t1.z
				set tx1 = x1 + ox1
				set ty1 = y1 + oy1
				set tz1 = z1 + oz1
			endif
			if t2 == 0 then
				set tx2 = x2 + ox2
				set ty2 = y2 + oy2
				set tz2 = z2 + oz2
			else
				set x2 = t2.x
				set y2 = t2.y
				set z2 = t2.z
				set tx2 = x2 + ox2
				set ty2 = y2 + oy2
				set tz2 = z2 + oz2
			endif
			call MoveLightningEx(l,true,tx1,ty1,tz1,tx2,ty2,tz2)
		endmethod
	
		method setTarget1 takes Object nt returns nothing
			set t1 = nt
			call refreshPosition()
		endmethod
	
		method setTarget2 takes Object nt returns nothing
			set t2 = nt
			call refreshPosition()
		endmethod
	
		private static method timeraction takes nothing returns nothing
			local thistype this = GetTimerData(GetExpiredTimer())
			call refreshPosition()
			if alpha-fade*TIMER_TICK > 0 then
				set alpha = alpha-fade*TIMER_TICK
			else
				set alpha = 0
			endif
			call SetLightningColor(l,r,g,b,alpha)
			if .duration > 0. then
				set .duration = .duration - TIMER_TICK
				if .duration <= 0. then
					call destroy()
				endif
			endif
		endmethod
	
		static method create takes string s, real ax, real ay, real az, real bx, real by, real bz returns thistype
			local thistype this = allocate()
			set type = s
			set t = Timer.new(this)
			set .duration = 0.
			set l = AddLightningEx(s,true,ax,ay,GetLocalZ(ax,ay)+az,bx,by,GetLocalZ(bx,by)+bz)
			set x1 = ax
			set y1 = ay
			set z1 = az
			set x2 = bx
			set y2 = by
			set z2 = bz
			set ox1 = 0
			set oy1 = 0
			set oz1 = 0
			set ox2 = 0
			set oy2 = 0
			set oz2 = 0
			set fade = 0
			call Timer.start(t,TIMER_TICK,true,function thistype.timeraction)
			call refreshPosition()
			return this
		endmethod
			
		static method createOO takes string s, Object o1, Object o2 returns thistype
			local thistype this = create(s,o1.x,o1.y,o1.z,o2.x,o2.y,o2.z)
			set x1 = 0
			set y1 = 0
			set z1 = 0
			set x2 = 0
			set y2 = 0
			set z2 = 0
			set ox1 = 0
			set oy1 = 0
			set oz1 = 0
			set ox2 = 0
			set oy2 = 0
			set oz2 = 0
			set t1 = o1
			set t2 = o2
			call refreshPosition()
			return this
		endmethod 
	
		method setDuration takes real time returns thistype
			set .duration = time
			return this
		endmethod
		
		method setFade takes real v returns thistype
			set .fade = v
			return this
		endmethod
	
		method onDestroy takes nothing returns nothing
			call ReleaseTimer(t)
			call DestroyLightning(l)
			set t = null
			set l = null
		endmethod
	
	endstruct
	
	endlibrary