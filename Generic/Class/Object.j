library Object

	struct Object

		real x_true = 0.
		real offset_x_true = 0.
		real y_true = 0.
		real offset_y_true = 0.
		real z_true = 0.
		real offset_z_true = 0.
		real yaw_true = 0.
		real offset_yaw_true = 0.
		real pitch_true = 0.
		real offset_pitch_true = 0.
		real roll_true = 0.
		real offset_roll_true = 0.
		real pivot_x = 0.
		real pivot_y = 0.
		real pivot_z = 55.

		Movement movement = 0

		stub method operator x takes nothing returns real
			return .x_true
		endmethod

		stub method operator y takes nothing returns real
			return .y_true
		endmethod

		stub method operator z takes nothing returns real
			return .z_true
		endmethod

		stub method operator yaw takes nothing returns real
			return .yaw_true
		endmethod

		stub method operator pitch takes nothing returns real
			return .pitch_true
		endmethod

		stub method operator roll takes nothing returns real
			return .roll_true
		endmethod

		stub method operator x= takes real nv returns nothing
			set .x_true = nv
		endmethod

		stub method operator y= takes real nv returns nothing
			set .y_true = nv
		endmethod

		stub method operator z= takes real nv returns nothing
			set .z_true = nv
		endmethod

		stub method operator yaw= takes real nv returns nothing
			set .yaw_true = nv
		endmethod

		stub method operator pitch= takes real nv returns nothing
			set .pitch_true = nv
		endmethod

		stub method operator roll= takes real nv returns nothing
			set .roll_true = nv
		endmethod

		stub method operator offset_x takes nothing returns real
			return .offset_x_true
		endmethod

		stub method operator offset_y takes nothing returns real
			return .offset_y_true
		endmethod

		stub method operator offset_z takes nothing returns real
			return .offset_z_true
		endmethod

		stub method operator offset_yaw takes nothing returns real
			return .offset_yaw_true
		endmethod

		stub method operator offset_pitch takes nothing returns real
			return .offset_pitch_true
		endmethod

		stub method operator offset_roll takes nothing returns real
			return .offset_roll_true
		endmethod

		stub method operator offset_x= takes real nv returns nothing
			set .offset_x_true = nv
		endmethod

		stub method operator offset_y= takes real nv returns nothing
			set .offset_y_true = nv
		endmethod

		stub method operator offset_z= takes real nv returns nothing
			set .offset_z_true = nv
		endmethod

		stub method operator offset_yaw= takes real nv returns nothing
			set .offset_yaw_true = nv
		endmethod

		stub method operator offset_pitch= takes real nv returns nothing
			set .offset_pitch_true = nv
		endmethod

		stub method operator offset_roll= takes real nv returns nothing
			set .offset_roll_true = nv
		endmethod

		stub method setOrientation takes real yaw, real pitch, real roll returns nothing
			set .yaw = yaw
			set .pitch = pitch
			set .roll = roll
		endmethod

		stub method move takes real x, real y, real z returns nothing
			set .x = x
			set .y = y
			set .z = z
		endmethod

		method setDirection3D takes real x1, real y1, real z1, real x2, real y2, real z2 returns thistype
			set .yaw = Math.anglePoints(x1,y1,x2,y2)
			set .pitch = Math.anglePoints(0,0,Math.distancePoints(x1,y1,x2,y2),z2-z1)*-1
			return this
		endmethod
	
		method move3DFromOrigin takes real ox, real oy, real oz, real dist, real ny, real nv returns nothing
			call move(Math.pPX(ox,dist*Cos(Deg2Rad(nv)),ny),Math.pPY(oy,dist*Cos(Deg2Rad(nv)),ny),oz-Sin(Deg2Rad(nv))*dist)
		endmethod
	
		method move3D takes real dist, real ny, real nv returns nothing
			call move(Math.pPX(.x,dist*Cos(Deg2Rad(nv)),ny),Math.pPY(.y,dist*Cos(Deg2Rad(nv)),ny),.z-Sin(Deg2Rad(nv))*dist)
		endmethod

		method onDestroy takes nothing returns nothing
			if .movement != 0 then
				call .movement.destroy()
			endif
		endmethod

	endstruct
	
	module AffectFlag

		boolean affect_enemy = true
		boolean affect_ally = false
		boolean affect_invincible = false
		boolean affect_evasion = false
		boolean affect_self = false

		method affectFilter takes Unit_prototype target returns boolean
			if (not .affect_enemy and target.isEnemy(.owner.owner)) then
				return false
			elseif (not .affect_ally and target.isAlly(.owner.owner)) then
				return false
			elseif (not .affect_invincible and target.getStatus(STATUS_INVINCIBLE) > 0) then
				return false
			elseif (not .affect_evasion and target.getStatus(STATUS_EVASION) > 0) then
				return false
			elseif (not .affect_self and target == .owner) then
				return false
			elseif target.isUnitType(UNIT_TYPE_DEAD) then
				return false
			else
				return true
			endif
		endmethod

	endmodule

	module RangeFilterModule

		stub method rangeFilter takes Unit_prototype target returns boolean
			return target.inRange(.x,.y,.radius_explosion)
		endmethod

	endmodule

	module ExplosionModule

		implement DamageFlag
		implement AffectFlag
		implement RangeFilterModule

		/*stub method explosionFilterAdditional takes Unit_prototype target returns boolean
			return true
		endmethod

		stub method executeExplosion takes Unit_prototype target returns nothing
			call damageTarget(target)
		endmethod*/

		stub method explosionFillUnits takes group g returns nothing
			call Group.fillUnitsInRange(g,.x,.y,.radius_explosion)
		endmethod

		method explosionFilter takes Unit_prototype target returns boolean
			if not affectFilter(target) then
				return false
			elseif not rangeFilter(target) then
				return false
			elseif not explosionFilterAdditional(target) then
				return false
			else
				return true
			endif
		endmethod

		method explosionAction takes nothing returns nothing
			local integer i = 0
			local unit u = null
			local group g = Group.new()
			call explosionFillUnits(g)
			loop
				set u = BlzGroupUnitAt(g,i)
				exitwhen u == null
				if not IsUnitType(u,UNIT_TYPE_DEAD) then
					if Unit_prototype.get(u) > 0 then
						if explosionFilter(Unit_prototype.get(u)) then
							call executeExplosion(Unit_prototype.get(u))
							call GroupAddUnit(.group_wave,u)
						endif
					endif
				endif
				set i = i + 1
			endloop
			call Group.release(g)
			set g = null
			set u = null
		endmethod

	endmodule

	module WaveModule

		implement DamageFlag
		implement AffectFlag
		implement RangeFilterModule

		stub method waveFilterAdditional takes Unit_prototype target returns boolean
			return true
		endmethod

		stub method waveRangeFilter takes Unit_prototype target returns boolean
			return target.inRange(.x,.y,.radius_wave)
		endmethod

		method waveFilter takes Unit_prototype target returns boolean
			if not affectFilter(target) then
				return false
			elseif not waveRangeFilter(target) then
				return false
			elseif not waveFilterAdditional(target) then
				return false
			else
				return true
			endif
		endmethod

		stub method executeWave takes Unit_prototype target returns nothing
			call damageTarget(target)
		endmethod

		method waveAction takes nothing returns nothing
			local integer i = 0
			local unit u = null
			local group g = Group.new()
			call Group.fillUnitsInRange(g,.x,.y,.radius_wave)
			loop
				set u = BlzGroupUnitAt(g,i)
				exitwhen u == null
				if not IsUnitType(u,UNIT_TYPE_DEAD) then
					if Unit_prototype.get(u) > 0 then
						if waveFilter(Unit_prototype.get(u)) and not IsUnitInGroup(u,.group_wave) then
							call executeWave(Unit_prototype.get(u))
							call GroupAddUnit(.group_wave,u)
						endif
					endif
				endif
				set i = i + 1
			endloop
			call Group.release(g)
			set g = null
			set u = null
		endmethod

	endmodule

	module TargetModule

		implement DamageFlag
		implement AffectFlag

		stub method collisionFilterAdditional takes Unit_prototype target returns boolean
			return true
		endmethod

		method collisionFilter takes Unit_prototype target returns boolean
			if not affectFilter(target) then
				return false
			elseif not collisionFilterAdditional(target) then
				return false
			else
				return true
			endif
		endmethod

		stub method targetFilterAdditional takes Unit_prototype target returns boolean
			return true
		endmethod

		method targetFilter takes Unit_prototype target returns boolean
			if not affectFilter(target) then
				return false
			elseif not targetFilterAdditional(target) then
				return false
			else
				return true
			endif
		endmethod

		stub method executeTarget takes Unit_prototype target returns nothing
			call damageTarget(target)
		endmethod

		method collisionAction takes nothing returns boolean
			local integer i = 0
			local unit u = null
			local Unit_prototype uu = 0
			local boolean b = false
			local group g = Group.new()
			call Group.clear(.group_collision)
			call Group.fillUnitsInRange(g,.x,.y,.radius_target)
			loop
				set u = BlzGroupUnitAt(g,i)
				exitwhen u == null
				set uu = Unit_prototype.get(u)
				if uu > 0 then
					if collisionFilter(uu) and Math.distancePoints(.x,.y,uu.x+uu.pivot_x,uu.y+uu.pivot_y) <= .radius_target + BlzGetUnitCollisionSize(u) then
						call GroupAddUnit(.group_collision,u)
					endif
				endif
				set i = i + 1
			endloop
			set u = Group.getNearest(.group_collision,.x,.y,null)
			if u != null then
				if targetFilter(Unit_prototype.get(u)) then
					call executeTarget(Unit_prototype.get(u))
				endif
				call GroupAddUnit(.group_wave,u)
				set b = true
			endif
			call Group.release(g)
			set g = null
			set u = null
			return b
		endmethod

		method targetLocationAction takes nothing returns boolean
			local boolean b = false
			if Math.distancePoints3D(.x,.y,.z,.target_x,.target_y,.target_z) <= .velo*TIMER_TICK*0.5 then
				set b = true
			endif
			return b
		endmethod

		method targetAction takes nothing returns boolean
			local boolean b = false
			if Math.distancePoints3D(.x,.y,.z,.target.x+.target.pivot_x,.target.y+.target.pivot_y,.target.z+.target.pivot_z) <= .radius_target then
				if targetFilter(.target) then
					call executeTarget(.target)
					call GroupAddUnit(.group_wave,.target.origin_unit)
				endif
				set b = true
			endif
			return b
		endmethod

	endmodule

endlibrary