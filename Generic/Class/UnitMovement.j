library UnitMovement

	struct UnitMovement extends Movement

		boolean suspend_ensnare = true
		boolean suspend_stun = true
		boolean suspend_silence = false
		boolean suspend_dead = true

		real radius_explosion = 0.
		real radius_wave = 0.
		real radius_target = 0.
		group group_wave = null
		group group_collision = null

		boolean flag_collision 	= false
		boolean flag_wave 		= false

		integer level = 0

		method operator caster takes nothing returns Unit_prototype
			return .actor
		endmethod

		method operator caster= takes Unit_prototype u returns nothing
			set .actor = u
		endmethod

		method operator owner takes nothing returns Unit_prototype
			return .actor
		endmethod

		method operator target takes nothing returns Unit_prototype
			return .target_true
		endmethod

		stub method explosionFilterAdditional takes Unit_prototype target returns boolean
			return true
		endmethod

		stub method executeExplosion takes Unit_prototype target returns nothing
			call damageTarget(target)
		endmethod

		implement WaveModule
		implement ExplosionModule
		implement TargetModule

		stub method suspendFilter takes nothing returns boolean
			return (suspend_stun and .caster.getStatus(STATUS_STUN) > 0) or /*
			*/(suspend_ensnare and .caster.getStatus(STATUS_ENSNARE) > 0) or /*
			*/(suspend_silence and .caster.getStatus(STATUS_SILENCE) > 0) or /*
			*/(suspend_dead and .caster.isUnitType(UNIT_TYPE_DEAD))
		endmethod

		stub method onSuspend takes nothing returns nothing

		endmethod

		stub method onComplete takes nothing returns nothing

		endmethod

		stub method onCollision takes nothing returns nothing

		endmethod

		method periodicAction takes nothing returns nothing
			call moveAction()
			if .friction > 0. then
				set .velo = .velo - (.friction * TIMER_TICK)
				if .velo <= 0. then
					set .duration = 0.
				endif
			endif
			if .flag_collision and not .want_destroy then
				call collisionAction()
			endif
			if .flag_wave and not .want_destroy then
				call waveAction()
			endif
		endmethod

		static method create takes Unit_prototype u, real velo, real angle returns thistype
			local thistype this = allocate(u,velo,angle)
			call .caster.plusStatus(STATUS_CAST)
			if .caster.movement != 0 then
				call .caster.movement.onSuspend()
				call .caster.movement.destroy()
			endif
			set .caster.collision = true
			set .caster.movement = this
			set .group_wave = Group.new()
			set .group_collision = Group.new()
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call .caster.minusStatus(STATUS_CAST)
			if not use_collision then
				call LocationEx.collisionProjection(.caster.x,.caster.y)
				call .caster.move(LocationEx.getX(),LocationEx.getY(),.caster.z)
			endif
			set .caster.gravity = GRAVITY_DEFAULT
			set .caster.collision = false
			set .caster.movement = 0
			call Group.release(.group_wave)
			call Group.release(.group_collision)
			set .group_wave = null
			set .group_collision = null
		endmethod

	endstruct

	struct knockback extends UnitMovement

		static method create takes Unit_prototype u, real velo, real angle returns thistype
			local thistype this = allocate(u,velo,angle)
			set .suspend_stun = false
			return this
		endmethod

	endstruct

endlibrary
