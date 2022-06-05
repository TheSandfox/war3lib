library Effect requires TimerUtils

	globals
		constant real HEIGHT_DEFAULT = 95
		constant string EF_SLASH = "Abilities\\Weapons\\SentinelMissile\\SentinelMissile.mdl"
		constant string EF_BLOOD = "Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl"
		constant string EF_ROCK = "Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl"
		constant string EF_ARROW = "Abilities\\Weapons\\Arrow\\ArrowMissile.mdl"
		constant string EF_EXPLOSION = "Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl"
	endglobals

	struct EffectDecay
	
		effect origin_effect
		timer t
	
		static method decay takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			call DestroyEffect(.origin_effect)
			call ReleaseTimer(t)
			set .origin_effect = null
			set t = null
			call destroy()
		endmethod
	
		static method create takes effect ef returns thistype
			local thistype this = allocate()
			set .origin_effect = ef
			set .t = Timer.new(this)
			call BlzPlaySpecialEffect(.origin_effect,ANIM_TYPE_DEATH)
			call Timer.start(.t,1.0,false, function thistype.decay)
			return this	
		endmethod	
	
	endstruct
	
	struct Effect extends Agent
	
		private timer decay_timer = null
		private real scale_true
		private real r_true
		private real g_true
		private real b_true
		private real a_true
		
		boolean want_remove
		boolean permanant
		boolean refresh_position = true
		boolean refresh_orientation = true

		method operator origin_effect takes nothing returns effect
			return LoadEffectHandle(HASH,GetHandleId(.origin_agent),INDEX_ORIGIN_HANDLE)
		endmethod
	
		method initializeOffset takes nothing returns nothing
			set .offset_x = 0
			set .offset_y = 0
			set .offset_z = 0
			set .offset_yaw = 0
			set .offset_pitch = 0
			set .offset_roll = 0
		endmethod
		
		method refreshZ takes nothing returns nothing
			if .refresh_position then
				call BlzSetSpecialEffectZ(.origin_effect,z_true+offset_z_true)
			endif
		endmethod
	
		method refreshX takes nothing returns nothing
			if .refresh_position then
				call BlzSetSpecialEffectX(.origin_effect,x_true+offset_x_true)
				call refreshZ()
			endif
		endmethod
	
		method refreshY takes nothing returns nothing
			if .refresh_position then
				call BlzSetSpecialEffectY(.origin_effect,y_true+offset_y_true)	
				call refreshZ()
			endif
		endmethod
	
		method refreshYaw takes nothing returns nothing
			if .refresh_orientation then
				call BlzSetSpecialEffectYaw(.origin_effect,Deg2Rad(yaw_true+offset_yaw_true))
			endif
		endmethod	
	
		method refreshRoll takes nothing returns nothing
			if .refresh_orientation then
				call BlzSetSpecialEffectRoll(.origin_effect,Deg2Rad(roll_true+offset_roll_true))
			endif
		endmethod	
	
		method refreshPitch takes nothing returns nothing
			if Cos(Deg2Rad(pitch_true+offset_pitch_true)) < 0. then
				call BlzSetSpecialEffectPitch(.origin_effect,Deg2Rad(pitch_true+offset_pitch_true))
				call BlzSetSpecialEffectPitch(.origin_effect,Deg2Rad(pitch_true+offset_pitch_true))
			else
				call BlzSetSpecialEffectPitch(.origin_effect,Deg2Rad(pitch_true+offset_pitch_true))
			endif
		endmethod

		//! runtextmacro effectGetter("X","x")
		//! runtextmacro effectGetter("Y","y")
		//! runtextmacro effectGetter("Z","z")
		//! runtextmacro effectGetter("Yaw","yaw")
		//! runtextmacro effectGetter("Pitch","pitch")
		//! runtextmacro effectGetter("Roll","roll")
		//! runtextmacro effectSetter("X","x")
		//! runtextmacro effectSetter("Y","y")
		//! runtextmacro effectSetter("Z","z")
		//! runtextmacro effectSetter("Yaw","yaw")
		/*//! runtextmacro effectSetter("Pitch","pitch")*/
		method operator pitch= takes real nv returns nothing
			if Cos(Deg2Rad(.pitch_true+.offset_pitch_true)) < 0. then
				call BlzSetSpecialEffectPitch(.origin_effect,Deg2Rad(nv+.offset_pitch_true))
				call BlzSetSpecialEffectPitch(.origin_effect,Deg2Rad(nv+.offset_pitch_true))
			else
				call BlzSetSpecialEffectPitch(.origin_effect,Deg2Rad(nv+.offset_pitch_true))
			endif
			set .pitch_true = nv
		endmethod
	
		method operator offset_pitch= takes real nv returns nothing
			if Cos(Deg2Rad(.pitch_true+.offset_pitch_true)) < 0. then
				call BlzSetSpecialEffectPitch(.origin_effect,Deg2Rad(.pitch_true+nv))
				call BlzSetSpecialEffectPitch(.origin_effect,Deg2Rad(.pitch_true+nv))
			else
				call BlzSetSpecialEffectPitch(.origin_effect,Deg2Rad(.pitch_true+nv))
			endif
			set .offset_pitch_true = nv
		endmethod

		method setPitch takes real nv returns thistype
			set .pitch = nv
			return this
		endmethod

		method setOffsetPitch takes real nv returns thistype
			set .offset_pitch = nv
			return this
		endmethod
		//! runtextmacro effectSetter("Roll","roll")
	
		method getScale takes nothing returns real
			return scale_true
		endmethod
	
		method getR takes nothing returns real
			return r_true
		endmethod
	
		method getG takes nothing returns real
			return g_true
		endmethod
	
		method getB takes nothing returns real
			return b_true
		endmethod
	
		method getAlpha takes nothing returns real
			return a_true
		endmethod
	
		method setScale takes real ns returns thistype
			set scale_true = ns
			if ns < 0 then
				call BlzSetSpecialEffectScale(.origin_effect,0)
			else
				call BlzSetSpecialEffectScale(.origin_effect,ns)
			endif
			return this
		endmethod

		method setMatrixScale takes real nx, real ny, real nz returns thistype
			call BlzSetSpecialEffectMatrixScale(.origin_effect,nx,ny,nz)
			return this
		endmethod
	
		private method colorRefresh takes nothing returns nothing
			local real array color
			local integer i = 0
			set color[0] = r_true
			set color[1] = g_true
			set color[2] = b_true
			loop
				if color[i] > 255 then
					set color[i] = 255
				elseif color[i] < 0 then
					set color[i] = 0
				endif
				set i = i+1
				exitwhen i == 3
			endloop
			call BlzSetSpecialEffectColor(.origin_effect,R2I(color[0]),R2I(color[1]),R2I(color[2]))
		endmethod
	
		method setR takes real nv returns thistype
			set r_true = nv
			call colorRefresh()
			return this
		endmethod
	
		method setG takes real nv returns thistype
			set g_true = nv
			call colorRefresh()
			return this
		endmethod
	
		method setB takes real nv returns thistype
			set b_true = nv
			call colorRefresh()
			return this
		endmethod
	
		method setAlpha takes real nv returns thistype
			set a_true = nv
			call BlzSetSpecialEffectAlpha(.origin_effect,R2I(nv))
			return this
		endmethod
	
		method setColor takes real r, real g, real b returns thistype
			set r_true = r
			set g_true = g
			set b_true = b
			call colorRefresh()
			return this
		endmethod
	
		method setPosition takes real nx, real ny, real nz returns thistype
			set .x = nx
			set .y = ny
			set .z = nz
			return this
		endmethod

		private static method timeout takes nothing returns nothing
			local thistype this = GetTimerData(GetExpiredTimer())
			call destroy()
		endmethod
	
		method operator duration= takes real timeout returns nothing
			if .decay_timer == null then
				set .decay_timer = Timer.new(this)
			endif
			call TimerStart(.decay_timer,timeout,false,function thistype.timeout)
		endmethod

		method setDuration takes real timeout returns thistype
			set .duration = timeout
			return this
		endmethod
	
		method kill takes nothing returns nothing
			if not permanant then
				set want_remove = false
				call destroy()
			endif
		endmethod
	
		method remove takes nothing returns nothing
			if not permanant then
				set want_remove = true
				call destroy()
			endif
		endmethod
	
		method setAnim takes animtype at returns thistype
			call BlzPlaySpecialEffect(.origin_effect,at)
			return this
		endmethod
	
		method setSubAnim takes subanimtype at returns thistype
			call BlzSpecialEffectAddSubAnimation( .origin_effect, at )
			return this
		endmethod

		method clearSubAnim takes nothing returns thistype
			call BlzSpecialEffectClearSubAnimations(.origin_effect)
			return this
		endmethod
	
		method setAnimSpeed takes real sp returns thistype
			call BlzSetSpecialEffectTimeScale(.origin_effect,sp)
			return this
		endmethod
	
		method setTeamColor takes player p returns thistype
			call BlzSetSpecialEffectColorByPlayer(.origin_effect,p)
			return this
		endmethod 
	
		method clear takes nothing returns thistype
			call BlzSpecialEffectClearSubAnimations( .origin_effect )
			return this
		endmethod

		method setLocalScale takes real ns returns nothing
			call BlzSetSpecialEffectScale(.origin_effect,ns)
		endmethod

		method setLocalAlpha takes integer nv returns nothing
			call BlzSetSpecialEffectAlpha(.origin_effect,nv)
		endmethod
	
		method setLocalColor takes integer r, integer g, integer b returns nothing
			call BlzSetSpecialEffectColor(.origin_effect,r,g,b)
		endmethod
	
		method setLocalPosition takes real nx, real ny, real nz returns nothing
			call BlzSetSpecialEffectPosition(.origin_effect,nx,ny,nz)
		endmethod

		static method create takes string path, real x, real y, real z, real ya returns thistype
			local thistype this = allocate(AddSpecialEffect(path,x,y))
			set .decay_timer = null
			call initializeOffset()
			set .x = x
			set .y = y
			set .z = z
			call setScale(1.)
			call setYaw(ya)
			call setPitch(0)
			call setRoll(0)
			call setR(255)
			call setG(255)
			call setB(255)
			call setAlpha(255)
			set want_remove = false
			set permanant = false
			return this
		endmethod
	
		static method createAttatched takes string path, widget target, string attatch returns thistype
			local thistype this = allocate(AddSpecialEffectTarget(path, target, attatch))
			call setR(255)
			call setG(255)
			call setB(255)
			call setAlpha(255)
			set .decay_timer = null
			set want_remove = false
			set permanant = false
			return this
		endmethod
	
		method onDestroy takes nothing returns nothing
			if .decay_timer != null then
				call ReleaseTimer(.decay_timer)
			endif
			if want_remove then
				call DestroyEffect(.origin_effect)
			else	
				call EffectDecay.create(.origin_effect)
			endif
			set .decay_timer = null
		endmethod
	
	endstruct
	
	endlibrary
	
	//! textmacro effectGetter takes prime, lower
	
		method operator $lower$ takes nothing returns real
			return .$lower$_true
		endmethod
	
		method operator offset_$lower$ takes nothing returns real
			return .offset_$lower$_true
		endmethod
	
		method getCarculated$prime$ takes nothing returns real
			return .$lower$_true + .offset_$lower$_true
		endmethod

		method get$prime$ takes nothing returns real
			return .$lower$
		endmethod

		method getOffset$prime$ takes nothing returns real
			return .offset_$lower$
		endmethod
	
	//! endtextmacro
	//! textmacro effectSetter takes prime, lower
	
		method operator $lower$= takes real nv returns nothing
			set .$lower$_true = nv
			call refresh$prime$()
		endmethod
	
		method operator offset_$lower$= takes real nv returns nothing
			set .offset_$lower$_true = nv
			call refresh$prime$()
		endmethod

		method set$prime$ takes real nv returns thistype
			set .$lower$ = nv
			return this
		endmethod

		method setOffset$prime$ takes real nv returns thistype
			set .offset_$lower$ = nv
			return this
		endmethod
	
	//! endtextmacro