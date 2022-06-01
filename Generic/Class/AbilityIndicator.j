library AbilityIndicator

	struct AbilityIndicator


		static string CIRCLE_PATH = "Effects\\CastRangeCircle.mdl"
		static string CURSOR_PATH = "Effects\\CastRangeCircle.mdl"

		static effect CURSOR = null

		Ability_prototype abil = 0
		Effect circle = 0
		player owner = null
		real alpha = 0.75

		stub method setColor takes integer r, integer g, integer b returns nothing
			call .circle.setColor(r,g,b)
		endmethod

		stub method refresh takes nothing returns nothing

		endmethod

		method refreshEssencial takes nothing returns nothing
			call .circle.setPosition(.abil.owner.x,.abil.owner.y,2.)
			if .abil.cast_range > 0. then
				call .circle.setScale(.abil.cast_range/100.)
				if GetLocalPlayer() == .owner then
					call .circle.setLocalAlpha(R2I(255*.alpha))
				endif
			endif
			/*if GetLocalPlayer() == .owner then
				call BlzSetSpecialEffectPosition(CURSOR,Mouse.getX(.owner),Mouse.getY(.owner),2.)
			endif*/
		endmethod

		stub method show takes boolean flag returns nothing

		endmethod

		method showEssencial takes boolean flag returns nothing
			if flag then
				if .abil.cast_range > 0. then
					call .circle.setScale(.abil.cast_range/100.)
					if GetLocalPlayer() == .owner then
						call .circle.setLocalAlpha(R2I(255*.alpha))
					endif
				endif
				/*if GetLocalPlayer() == .owner then
					call BlzSetSpecialEffectAlpha(CURSOR,255)
				endif*/
			else
				call .circle.setLocalAlpha(0)
				/*if GetLocalPlayer() == .owner then
					call BlzSetSpecialEffectAlpha(CURSOR,0)
				endif*/
			endif
		endmethod

		static method create takes Ability_prototype abil, player owner returns thistype
			local thistype this = allocate()
			set .abil = abil
			set .owner = owner
			set .circle = Effect.create(CIRCLE_PATH,0.,0.,2.,270.)
			call .circle.setAlpha(0)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			set .owner = null
			call .circle.destroy()
		endmethod

		static method onInit takes nothing returns nothing
			/*set CURSOR = AddSpecialEffect(CURSOR_PATH,0.,0.)
			call BlzSetSpecialEffectAlpha(CURSOR,0)*/
		endmethod

	endstruct

	struct LineIndicator extends AbilityIndicator

		Effect ef = 0
		real yaw = 0.
		real range = 0.
		real width = 0.
		real x = 0.
		real y = 0.

		stub method beforeRefresh takes nothing returns nothing

		endmethod

		method refresh takes nothing returns nothing
			call beforeRefresh()
			set .ef.yaw = .yaw
			call .ef.setPosition(.x,.y,2.)
			call BlzSetSpecialEffectMatrixScale(.ef.origin_effect,.range/100.,.width/50.,1.)
		endmethod

		method show takes boolean flag returns nothing
			if flag then
				call refresh()
				if GetLocalPlayer() == .owner then
					call .ef.setLocalAlpha(R2I(255*.alpha))
				endif
			else
				call .ef.setLocalAlpha(0)
			endif
		endmethod

		static method create takes Ability_prototype abil, player owner returns thistype
			local thistype this = allocate(abil,owner)
			set .ef = Effect.create("Effects\\RLine.mdl",0.,0.,2.,0.)
			call .ef.setLocalAlpha(0)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call .ef.destroy()
		endmethod

	endstruct

	struct SectorIndicator extends AbilityIndicator

		Effect ef = 0
		real yaw = 0.
		real range = 0.
		real x = 0.
		real y = 0.

		stub method beforeRefresh takes nothing returns nothing

		endmethod

		method refresh takes nothing returns nothing
			call beforeRefresh()
			set .ef.yaw = .yaw
			call .ef.setPosition(.x,.y,2.)
			call .ef.setScale(.range/100.)
		endmethod

		method show takes boolean flag returns nothing
			if flag then
				call refresh()
				if GetLocalPlayer() == .owner then
					call .ef.setLocalAlpha(R2I(255*.alpha))
				endif
			else
				call .ef.setLocalAlpha(0)
			endif
		endmethod

		static method create takes Ability_prototype abil, player owner, string width returns thistype
			local thistype this = allocate(abil,owner)
			set .ef = Effect.create("Effects\\RSector"+width+".mdl",0.,0.,2.,0.)
			call .ef.setLocalAlpha(0)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call .ef.destroy()
		endmethod

	endstruct

endlibrary