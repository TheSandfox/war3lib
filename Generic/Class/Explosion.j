library Explosion

	struct Explosion

		Unit_prototype owner = 0

		real x = 0.
		real y = 0.
		real radius_explosion = 0.

		integer count = 1
		real interval = 0.

		timer main_timer = null
		group group_wave = null

		real max_distance = -1.
		real min_distance = -1.
		Unit_prototype nearest = 0
		Unit_prototype furthest = 0

		boolean activate_initial = true

		implement ExplosionModule

		method clearDistanceValue takes nothing returns nothing
			set .max_distance = -1.
			set .min_distance = -1.
			set .nearest = 0
			set .furthest = 0
		endmethod

		method adjustNearest takes Unit_prototype target, Unit_prototype except returns nothing
			if target == except then
				return
			endif
			/*최소거리가 음수값(최초)일 때*/
			if .min_distance < 0. then
				set .min_distance = Math.distancePoints(.x,.y,target.x,target.y)
				set .nearest = target
			/*기록된 값이 있으면 거리비교*/
			elseif .min_distance > Math.distancePoints(.x,.y,target.x,target.y) then
				set .min_distance = Math.distancePoints(.x,.y,target.x,target.y)
				set .nearest = target
			endif
		endmethod

		method adjustFurthest takes Unit_prototype target, Unit_prototype except returns nothing
			if target == except then
				return
			endif
			/*최소거리가 음수값(최초)일 때*/
			if .max_distance < 0. then
				set .max_distance = Math.distancePoints(.x,.y,target.x,target.y)
				set .furthest = target
			/*기록된 값이 있으면 거리비교*/
			elseif .max_distance < Math.distancePoints(.x,.y,target.x,target.y) then
				set .max_distance = Math.distancePoints(.x,.y,target.x,target.y)
				set .furthest = target
			endif
		endmethod

		stub method beforeExplosion takes nothing returns nothing

		endmethod

		stub method afterExplosion takes nothing returns nothing

		endmethod

		stub method explosionFilterAdditional takes Unit_prototype target returns boolean
			return true
		endmethod

		stub method executeExplosion takes Unit_prototype target returns nothing
			call damageTarget(target)
		endmethod

		method execute takes nothing returns nothing
			call setDamagePosition(.x,.y)
			call beforeExplosion()
			call explosionAction()
			call afterExplosion()
			if .count > 0 then
				set .count = .count - 1
				if .count == 0 then
					call destroy()
				endif
			endif
		endmethod

		static method timerAction takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			call execute()
		endmethod

		method activate takes nothing returns nothing
			if .interval > 0. then
				call Timer.start(.main_timer,.interval,true,function thistype.timerAction)
			endif
			if .activate_initial then
				call execute()
			endif
		endmethod

		static method create takes Unit_prototype owner, real x, real y, real radius returns thistype
			local thistype this = allocate()
			set .owner = owner
			set .x = x
			set .y = y
			set .radius_explosion = radius
			set .main_timer = Timer.new(this)
			set .group_wave = Group.new()
			call damageFlagTemplateMagicalExplosion()
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call Timer.release(.main_timer)
			set .main_timer = null
			call Group.release(.group_wave)
			set .group_wave = null
		endmethod

	endstruct

	struct LineExplosion extends Explosion

		real x2 = 0.
		real y2 = 0.

		method explosionFillUnits takes group g returns nothing
			call Group.fillUnitsInRange(g,.x,.y,Math.distancePoints(.x,.y,.x2,.y2))
		endmethod
 
		method rangeFilter takes Unit_prototype target returns boolean
			return target.inLine(.x,.y,.x2,.y2,.radius_explosion) 
		endmethod

		static method create takes Unit_prototype owner, real x, real y, real x2, real y2, real radius returns thistype
			local thistype this = allocate(owner,x,y,radius)
			set .x2 = x2
			set .y2 = y2
			return this
		endmethod

	endstruct

	struct SectorExplosion extends Explosion

		real angle = 0.
		real width = 0.

		method rangeFilter takes Unit_prototype target returns boolean
			return target.inSector(.x,.y,.radius_explosion,.angle,.width)
		endmethod

		static method create takes Unit_prototype owner, real x, real y, real radius, real angle, real width returns thistype
			local thistype this = allocate(owner,x,y,radius)
			set .angle = angle
			set .width = width
			return this
		endmethod

	endstruct

endlibrary