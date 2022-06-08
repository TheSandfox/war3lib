library Waygate

	private struct warp extends UnitActor

		static constant string EFFECT_PATH1 = "Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTo.mdl"
		static constant string EFFECT_PATH2 = "Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTarget.mdl"

		Effect ef = 0
		real angle = 0.

		method onComplete takes nothing returns nothing
			set .caster.x = Math.pPX(.x,200,.angle)
			set .caster.y = Math.pPY(.y,200,.angle)
			call Effect.create(EFFECT_PATH2,.caster.x,.caster.y,0.,270.).setDuration(2.)
			call .caster.issueImmediateOrder("stop")
		endmethod

		static method create takes Unit caster, real x, real y, real angle returns thistype
			local thistype this = allocate(caster,0,x,y,0,3.,true)
			set .angle = angle
			set .suspend_rclick = true
			set .suspend_stop = true
			set .ef = Effect.create(EFFECT_PATH1,.caster.x,.caster.y,.0,270.)
			set .progress_bar = ProgressBar.create("차원문 이동",.caster.owner)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call .ef.kill()
		endmethod

	endstruct

	struct Waygate extends Moolgun

		rect target_rect = null

		method onInteract takes Unit caster returns nothing
			call warp.create(caster,GetRectCenterX(.target_rect),GetRectCenterY(.target_rect),Math.anglePoints(.x,.y,GetRectCenterX(.target_rect),GetRectCenterY(.target_rect)))
		endmethod

		static method create takes real x, real y, rect target returns thistype
			local thistype this = allocate('B004',x,y,0.)
			call setAnim("Stand Alternate")
			set .target_rect = target
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			set .target_rect = null
		endmethod

		static method init takes nothing returns nothing
			call create(GetRectCenterX(gg_rct_Waygate1),GetRectCenterY(gg_rct_Waygate1),gg_rct_Warp1)
			call create(GetRectCenterX(gg_rct_Waygate2),GetRectCenterY(gg_rct_Waygate2),gg_rct_Warp2)
			call create(GetRectCenterX(gg_rct_Waygate3),GetRectCenterY(gg_rct_Waygate3),gg_rct_Warp3)
			call create(GetRectCenterX(gg_rct_Waygate4),GetRectCenterY(gg_rct_Waygate4),gg_rct_Warp4)
			call create(GetRectCenterX(gg_rct_Warp1),GetRectCenterY(gg_rct_Warp1),gg_rct_Waygate1)
			call create(GetRectCenterX(gg_rct_Warp2),GetRectCenterY(gg_rct_Warp2),gg_rct_Waygate2)
			call create(GetRectCenterX(gg_rct_Warp3),GetRectCenterY(gg_rct_Warp3),gg_rct_Waygate3)
			call create(GetRectCenterX(gg_rct_Warp4),GetRectCenterY(gg_rct_Warp4),gg_rct_Waygate4)
		endmethod

	endstruct

endlibrary