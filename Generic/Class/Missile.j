library Missile requires Effect

	struct Missile extends Effect

		timer main_timer = null
		Unit_prototype owner = 0
		Unit_prototype target_true = 0

		boolean want_kill = false
		boolean want_destroy = false

		boolean flag_collision = false
		boolean flag_wave = false
		boolean flag_explosion = false

		//group group_generic = null
		group group_wave = null
		group group_collision = null
		MissileGroup group_link = 0

		real radius_wave_true = 0.
		real radius_explosion_true = 0.
		real radius_target = 16.

		real wave_timeout = 0.
		real wave_interval = 0.
		
		method operator curve takes nothing returns Curve
			return .movement.curve
		endmethod

		method operator curve= takes Curve cv returns nothing
			set .movement.curve = cv
		endmethod

		method operator flag_target takes nothing returns boolean
			return .movement.flag_target
		endmethod

		method operator flag_target_location takes nothing returns boolean
			return .movement.flag_target_location
		endmethod

		method operator flag_curve takes nothing returns boolean
			return .movement.flag_curve
		endmethod

		method operator velo takes nothing returns real
			return .movement.velo
		endmethod

		method operator velo= takes real nv returns nothing
			set .movement.velo = nv
		endmethod

		method setCollision takes real v returns nothing
			set .radius_target = v
			set .flag_collision = true
		endmethod

		method operator radius_wave takes nothing returns real
			return .radius_wave_true
		endmethod

		method operator radius_wave= takes real nv returns nothing
			set .flag_wave = nv > 0.
			set .radius_wave_true = nv
		endmethod

		method setWave takes real rad returns nothing
			set .radius_wave = rad
		endmethod

		method operator radius_explosion takes nothing returns real
			return .radius_explosion_true
		endmethod

		method operator radius_explosion= takes real nv returns nothing
			set .flag_explosion = nv > 0.
			set .radius_explosion_true = nv
		endmethod

		method setExplosion takes real rad returns nothing
			set .radius_explosion = rad
		endmethod

		method operator z_velo takes nothing returns real
			return .movement.z_velo
		endmethod

		method operator z_velo= takes real nv returns nothing
			set .movement.z_velo = nv
		endmethod

		method operator gravity takes nothing returns real
			return .movement.gravity
		endmethod

		method operator gravity= takes real nv returns nothing
			set .movement.gravity = nv
		endmethod

		method operator target_x takes nothing returns real
			return .movement.target_x
		endmethod

		method operator target_y takes nothing returns real
			return .movement.target_y
		endmethod

		method operator target_z takes nothing returns real
			return .movement.target_z
		endmethod

		method setTargetLocation takes real x, real y, real z returns nothing
			call .movement.setTargetLocation(x,y,z)
		endmethod

		method resetTargetLocation takes nothing returns nothing
			call .movement.resetTargetLocation()
		endmethod

		method operator target takes nothing returns Unit_prototype
			return .target_true
		endmethod

		method operator target= takes Unit_prototype nt returns nothing
			set .target_true = nt
			set .movement.target = nt
		endmethod

		method setTarget takes Unit_prototype nt returns nothing
			set .target = nt
		endmethod

		stub method explosionFilterAdditional takes Unit_prototype target returns boolean
			return true
		endmethod

		stub method executeExplosion takes Unit_prototype target returns nothing
			call damageTarget(target)
		endmethod

		implement ExplosionModule
		implement WaveModule
		implement TargetModule

		stub method killFilter takes nothing returns boolean
			return true
		endmethod

		method killRequest takes nothing returns nothing
			if not .want_destroy then
				set .want_destroy = killFilter()
				set .want_kill = .want_destroy
			endif
		endmethod

		stub method onBound takes nothing returns nothing
			set .want_kill = true
		endmethod

		stub method beforeExplosion takes nothing returns nothing

		endmethod

		stub method afterExplosion takes nothing returns nothing

		endmethod

		stub method beforeWave takes nothing returns nothing

		endmethod

		stub method afterWave takes nothing returns nothing

		endmethod

		stub method periodicAction takes nothing returns nothing

		endmethod

		method missileAction takes nothing returns nothing
			if .want_kill then
				return 
			endif
			if .target != 0 then
				call setDirection3D(.x,.y,.z,.target.x+.target.pivot_x,.target.y+.target.pivot_y,.target.z+.target.pivot_z)
				if targetAction() then
					set .want_kill = true
				endif
			else
				if .movement.z_velo < 0. and .z <= 0. then
					call onBound()
				endif
			endif
			if .want_kill then
				return
			endif
			if .flag_target_location then
				if Math.distancePoints3D(.x,.y,.z,.target_x,.target_y,.target_z) <= (.velo * TIMER_TICK)/2. then
					set .want_kill = true
				endif
			endif
			if .flag_collision then
				if collisionAction() then
					set .want_kill = true
				endif
			endif
			if .want_kill then
				return
			endif
			if .flag_wave  then
				set .wave_timeout = .wave_timeout + TIMER_TICK
				if .wave_timeout >= .wave_interval or .wave_interval <= 0. then
					call beforeWave()
					call waveAction()
					call afterWave()
					set .wave_timeout = .wave_timeout - .wave_interval
				endif
			endif
		endmethod

		static method timerAction takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			call missileAction()
			call periodicAction()
			if .want_kill then
				if .flag_explosion then
					call beforeExplosion()
					call explosionAction()
					call afterExplosion()
				endif
				call killRequest()
			endif
			if .want_destroy then
				if .want_kill then
					call kill()
				else
					call remove()
				endif
			endif
		endmethod

		static method create takes Unit_prototype owner, string path, real x, real y, real z, real yaw returns thistype
			local thistype this = allocate(path,x,y,z,yaw)
			set .movement = Movement.create(this,0.,yaw)
			set .owner = owner
			set .main_timer = Timer.new(this)
			//set .group_generic 		= Group.new()
			set .group_wave 		= Group.new()
			set .group_collision 	= Group.new()
			call Timer.start(.main_timer,TIMER_TICK,true,function thistype.timerAction)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call Timer.release(.main_timer)
			/*미사일 링크 돼있을 때*/
			if .group_link > 0 then
				call .group_link.remove(this)
			/*안돼있을 때*/
			else
				/*안됐으면 웨이브그룹 릴리즈*/
				if .group_wave != null then
					call Group.release(.group_wave)
				endif 
			endif
			//call Group.release(.group_generic)
			call Group.release(.group_collision)
			set .main_timer = null
			//set .group_generic 		= null
			set .group_wave 		= null
			set .group_collision 	= null
			set .group_link = 0
		endmethod

	endstruct

endlibrary

//! import "MissileGroup.j"