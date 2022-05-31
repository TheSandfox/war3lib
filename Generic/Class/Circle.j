library Circle requires Effect

	struct Circle extends Effect

		private static string PATH_TEMP = "Effects\\RCircle.mdl"

		timer main_timer = null
		real timeout = 0.
		real fadepoint = -1.
		real fade = 0.
		real alpha = 1. /*0~1*/
		real alpha_max = 1.
		real overtime = 0.

		static method timerAction takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			local boolean want_kill = false
			set .timeout = .timeout + TIMER_TICK
			if .timeout >= .fadepoint and .fadepoint >= 0. then
				if .overtime > 0. then
					set .fade = -1./.overtime
					set .fadepoint = -1.
				else
					set want_kill = true
				endif
			endif
			set .alpha = .alpha + .fade*TIMER_TICK
			if .alpha > 1 and .fade > 0. then
				set .alpha = 1.
			endif
			if .alpha*.alpha_max > 1. then
				call setAlpha(255)
			elseif .alpha*.alpha_max < 0. then
				call setAlpha(0)
			else
				call setAlpha(R2I(.alpha*255*.alpha_max))
			endif
			if .alpha < .0 and .fade < 0. then
				set want_kill = true
			endif
			if want_kill then
				call destroy()
			endif
		endmethod

		method setFadeOutPoint takes real point, real overtime returns nothing
			set .timeout = 0.
			set .fadepoint = point
			set .overtime = overtime
		endmethod

		method fadeIn takes real overtime returns nothing
			if overtime > 0. then
				set .timeout = 0.
				set .alpha = 0.
				call setAlpha(0)
				set .fade = 1./overtime
			else
				call setAlpha(255)
				set .fade = 0.
				set .alpha = 1.
				set .timeout = 0.
			endif
		endmethod

		static method create takes real x, real y, real z, real radius returns thistype
			local thistype this = allocate(PATH_TEMP,x,y,z,270.)
			call setScale(radius/100.)
			set .main_timer = Timer.new(this)
			call Timer.start(.main_timer,TIMER_TICK,true,function thistype.timerAction)
			set PATH_TEMP = "Effects\\RCircle.mdl"
			return this
		endmethod

		static method createSpecific takes string path, real x, real y, real z, real radius returns thistype
			set PATH_TEMP = path
			return create(x,y,z,radius)
		endmethod

		method onDestroy takes nothing returns nothing
			call Timer.release(.main_timer)
			set .main_timer = null
		endmethod

	endstruct

	struct TargetCircle extends Effect

		player owner = null

		static method create takes Unit_prototype target, player owner returns thistype
			local thistype this = allocate("UI\\Feedback\\Target\\Target.mdl",target.x,target.y,target.z+2.0,270.)
			set .movement = Movement.create(this,0,0)
			set .movement.target = target
			set .movement.flag_target_attatch = true
			call setScale(1.5)
			call setDuration(1.5)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			set .owner = null
		endmethod

	endstruct

endlibrary