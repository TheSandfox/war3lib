library Hellgate

	private struct actor extends UnitActor

		static constant string EFFECT_PATH1 = "Objects\\Spawnmodels\\Orc\\OrcLargeDeathExplode\\OrcLargeDeathExplode.mdl"
		static constant string EFFECT_PATH2 = "Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl"

		method onComplete takes nothing returns nothing
			set .caster.hp = 1.
			call .caster.plusStatus(STATUS_DEAD)
			call .caster.issueImmediateOrder("stop")
			call Effect.create(EFFECT_PATH1,.caster.x,.caster.y,0.,270.).setDuration(1.5).setScale(2.)
			call Effect.create(EFFECT_PATH2,.caster.x,.caster.y,0.,270.).setDuration(1.5).setScale(2.)
		endmethod

		static method create takes Unit caster, real x, real y returns thistype
			local thistype this = allocate(caster,0,x,y,0,4.,true)
			set .suspend_rclick = true
			set .suspend_stop = true
			set .progress_bar = ProgressBar.create("지옥문을 들여다보기",.caster.owner)
			call SetUnitFacing(.caster.origin_unit,Math.anglePoints(.caster.x,.caster.y,.x,.y))
			return this
		endmethod

	endstruct

	struct Hellgate extends Moolgun

		method onInteract takes Unit caster returns nothing
			call actor.create(caster,.x,.y)
		endmethod

		static method create takes real x, real y, real yaw, integer index returns thistype
			local thistype this = allocate('B000'+index,x,y,yaw)

			return this
		endmethod

		static method init takes nothing returns nothing
			call create(GetRectMinX(gg_rct_GateWest)-128,GetRectCenterY(gg_rct_GateWest),0.,0)
			call create(GetRectMaxX(gg_rct_GateEast)+128,GetRectCenterY(gg_rct_GateEast),180.,2)
			call create(GetRectCenterX(gg_rct_GateNorth),GetRectMaxY(gg_rct_GateNorth)+128,270.,3)
			call create(GetRectCenterX(gg_rct_GateSouth),GetRectMinY(gg_rct_GateSouth)-128,90.,1)
		endmethod

	endstruct

endlibrary