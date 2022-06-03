library Movement requires Actor

	struct Movement extends Actor

		Object target_true = 0

		boolean use_collision = false

		real velo 		= 0.	/*초당이동거리*/
		real friction 	= 0.	/*초당감속량*/
		real yaw 		= 0.

		real z_velo = 0.
		real gravity = 0.

		real next_x = 0.
		real next_y = 0.
		real next_z = 0.

		real target_x = 0.
		real target_y = 0.
		real target_z = 0.

		Curve curve_true = 0

		boolean flag_target = false
		boolean flag_target_attatch = false
		boolean flag_curve = false
		boolean flag_target_location = false
		boolean refresh_facing = false

		method operator x takes nothing returns real
			return .actor.x
		endmethod

		method operator y takes nothing returns real
			return .actor.y
		endmethod

		method operator z takes nothing returns real
			return .actor.z
		endmethod

		stub method operator target takes nothing returns Unit_prototype
			return .target_true
		endmethod

		method operator target= takes Object nt returns nothing
			set .target_true = nt
			set .flag_target = nt != 0
		endmethod

		method operator curve takes nothing returns Curve
			return .curve_true
		endmethod

		method operator curve= takes Curve cv returns nothing
			if cv <= 0 then
				if .curve_true > 0 then
					call .curve_true.destroy()
				endif
			endif
			set .curve_true = cv
			set .flag_curve = cv > 0
		endmethod

		method setTargetLocation takes real x, real y, real z returns nothing
			set .flag_target_location = true
			set .target_x = x
			set .target_y = y
			set .target_z = z
		endmethod

		method resetTargetLocation takes nothing returns nothing
			set .flag_target_location = false
		endmethod

		method carculateNextPosition takes nothing returns nothing
			local real np = 0.
			local real ny = 0.
			if .flag_target then
				if .flag_target_attatch then
					set .next_x = .target.x
					set .next_y = .target.y
					set .next_z = .target.z
				elseif .flag_curve then
					set .curve.value = .curve.value + (TIMER_TICK/.curve.overtime)
					call .curve.setX(INDEX_POINT_LAST,.target.x+.target.pivot_x)
					call .curve.setY(INDEX_POINT_LAST,.target.y+.target.pivot_y)
					call .curve.setZ(INDEX_POINT_LAST,.target.z+.target.pivot_z)
					set .next_x = curve.x
					set .next_y = curve.y
					set .next_z = curve.z
					set np = Math.anglePoints2(.actor.x,.actor.y,.actor.z,.next_x,.next_y,.next_z)
					set ny = Math.anglePoints(.actor.x,.actor.y,.next_x,.next_y)
				else
					set np = Math.anglePoints2(.actor.x,.actor.y,.actor.z,.target.x+.target.pivot_x,.target.y+.target.pivot_y,.target.z+.target.pivot_z)
					set ny = Math.anglePoints(.actor.x,.actor.y,.target.x+.target.pivot_x,.target.y+.target.pivot_y)
					set .next_x = Math.pPX(.actor.x,.velo*TIMER_TICK*Cos(Deg2Rad(np)),ny)
					set .next_y = Math.pPY(.actor.y,.velo*TIMER_TICK*Cos(Deg2Rad(np)),ny)
					set .next_z = .actor.z-Sin(Deg2Rad(np))*.velo*TIMER_TICK
				endif
			elseif .flag_target_location then
				if .flag_curve then
					set .curve.value = .curve.value + (TIMER_TICK/.curve.overtime)
					call .curve.setX(INDEX_POINT_LAST,.target_x)
					call .curve.setY(INDEX_POINT_LAST,.target_y)
					call .curve.setZ(INDEX_POINT_LAST,.target_z)
					set .next_x = curve.x
					set .next_y = curve.y
					set .next_z = curve.z
					set np = Math.anglePoints2(.actor.x,.actor.y,.actor.z,.next_x,.next_y,.next_z)
					set ny = Math.anglePoints(.actor.x,.actor.y,.next_x,.next_y)
				else
					set np = Math.anglePoints2(.actor.x,.actor.y,.actor.z,.target_x,.target_y,.target_z)
					set ny = Math.anglePoints(.actor.x,.actor.y,.target_x,.target_y)
					set .next_x = Math.pPX(.actor.x,.velo*TIMER_TICK*Cos(Deg2Rad(np)),ny)
					set .next_y = Math.pPY(.actor.y,.velo*TIMER_TICK*Cos(Deg2Rad(np)),ny)
					set .next_z = .actor.z-Sin(Deg2Rad(np))*.velo*TIMER_TICK
				endif
			elseif .flag_curve then
				set .curve.value = .curve.value + (TIMER_TICK/.curve.overtime)
				set .next_x = curve.x
				set .next_y = curve.y
				set .next_z = curve.z
				set np = Math.anglePoints2(.actor.x,.actor.y,.actor.z,.next_x,.next_y,.next_z)
				set ny = Math.anglePoints(.actor.x,.actor.y,.next_x,.next_y)
			else
				set .next_x = Math.pPX(.actor.x,.velo*TIMER_TICK,.yaw)
				set .next_y = Math.pPY(.actor.y,.velo*TIMER_TICK,.yaw)
				set .next_z = .actor.z + .z_velo * TIMER_TICK
				if .next_z < 0. then
					if .z_velo <= 0. and .gravity > 0. then
						set .next_z = 0.
						set .z_velo = 0.
					endif
				endif
				set .z_velo = .z_velo - .gravity * TIMER_TICK
				set np = Math.anglePoints2(.actor.x,.actor.y,.actor.z,.next_x,.next_y,.next_z)
				set ny = Math.anglePoints(.actor.x,.actor.y,.next_x,.next_y)
			endif
			if .refresh_facing then
				call .actor.setOrientation(ny,np,0.)
			endif
		endmethod

		stub method onSuspend takes nothing returns nothing

		endmethod

		stub method onComplete takes nothing returns nothing

		endmethod

		stub method onCollision takes nothing returns nothing

		endmethod

		stub method moveAction takes nothing returns nothing
			call carculateNextPosition()
			if .use_collision then
				if LocationEx.collisionProjection(.next_x,.next_y) > 3.0 then
					call onCollision()
				endif
				set .next_x = LocationEx.getX()
				set .next_y = LocationEx.getY()
			endif
			call .actor.move(.next_x,.next_y,.next_z)
		endmethod

		stub method suspendFilter takes nothing returns boolean
			return false
		endmethod

		stub method periodicAction takes nothing returns nothing
			call moveAction()
			if .friction > 0. then
				set .velo = .velo - (.friction * TIMER_TICK)
				if .velo <= 0. then
					set .duration = 0.
				endif
			endif
		endmethod

		static method create takes Object actor, real velo, real angle returns thistype
			local thistype this = allocate(actor,0,0,-1.)
			set .velo = velo
			set .yaw = angle
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			if .curve != 0 then
				call .curve.destroy()
				set .curve = 0
			endif
		endmethod

	endstruct

endlibrary