library Actor requires Object

	struct Actor

		Object actor = 0
		ProgressBar progress_bar = 0

		integer stage = 0
		real timeout = 0.
		real duration = 0.
		real duration_max = 0.
		timer main_timer = null

		boolean want_destroy = false

		real x_true = 0.
		real y_true = 0.
		real x2 = 0.
		real y2 = 0.

		stub method operator x takes nothing returns real
			return x_true
		endmethod

		stub method operator x= takes real nv returns nothing
			set .x_true = nv
		endmethod

		stub method operator y takes nothing returns real
			return y_true
		endmethod

		stub method operator y= takes real nv returns nothing
			set .y_true = nv
		endmethod

		stub method onSuspend takes nothing returns nothing

		endmethod

		stub method onComplete takes nothing returns nothing

		endmethod

		stub method periodicAction takes nothing returns nothing

		endmethod

		stub method suspendFilter takes nothing returns boolean
			return false
		endmethod

		stub method killFilter takes nothing returns boolean
			return true
		endmethod

		method stageNext takes nothing returns nothing
			set .stage = .stage + 1
			set .timeout = 0.
		endmethod

		static method timerAction takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			set .timeout = .timeout + TIMER_TICK
			if not suspendFilter() then
				call periodicAction()
				if .duration > 0. then
					set .duration = .duration - TIMER_TICK
					if .duration <= 0. then
						call onComplete()
						if killFilter() then
							set .want_destroy = true
						endif
					endif
				endif
			else
				call onSuspend()
				set .want_destroy = true
			endif
			if .progress_bar != 0 then
				if .duration_max > 0. then
					set .progress_bar.value = .timeout / .duration_max
				else
					set .progress_bar.value = 0.
				endif
			endif
			if .want_destroy then
				call destroy()
			endif
		endmethod

		static method create takes Object actor, real x, real y, real duration returns thistype
			local thistype this = allocate()
			set .actor = actor
			set .x = x
			set .y = y
			set .duration = duration
			set .duration_max = duration
			set .main_timer = Timer.new(this)
			call Timer.start(.main_timer,TIMER_TICK,true,function thistype.timerAction)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call Timer.release(.main_timer)
			set .main_timer = null
			if .progress_bar != 0 then
				call .progress_bar.destroy()
			endif
		endmethod

	endstruct

endlibrary