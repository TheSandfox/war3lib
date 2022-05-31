library Curve requires Object

	globals
		constant integer INDEX_POSITION_X = 0
		constant integer INDEX_POSITION_Y = 1
		constant integer INDEX_POSITION_Z = 2
		constant integer INDEX_POSITION_SIZE = 3
		constant integer INDEX_POINT_ORIGIN = 0
		constant integer INDEX_POINT_LAST = 1
		constant integer INDEX_POINT_MIDDLE = 2
		private hashtable HASH = InitHashtable()
	endglobals

	struct Curve extends Object

		real value = 0.
		real overtime = 1.
		integer index_max = 0

		stub method getCarculatedX takes real v returns real
			return .x_true
		endmethod

		stub method getCarculatedY takes real v returns real
			return .y_true
		endmethod

		stub method getCarculatedZ takes real v returns real
			return .z_true
		endmethod

		method operator x takes nothing returns real
			return getCarculatedX(.value)
		endmethod

		method operator y takes nothing returns real
			return getCarculatedY(.value)
		endmethod
		
		method operator z takes nothing returns real
			return getCarculatedZ(.value)
		endmethod

		method setX takes integer index, real nv returns nothing
			if index > .index_max then
				set .index_max = index
			endif
			call SaveReal(HASH,this,(INDEX_POSITION_SIZE*index)+INDEX_POSITION_X,nv)
		endmethod

		method setY takes integer index, real nv returns nothing
			if index > .index_max then
				set .index_max = index
			endif
			call SaveReal(HASH,this,(INDEX_POSITION_SIZE*index)+INDEX_POSITION_Y,nv)
		endmethod

		method setZ takes integer index, real nv returns nothing
			if index > .index_max then
				set .index_max = index
			endif
			call SaveReal(HASH,this,(INDEX_POSITION_SIZE*index)+INDEX_POSITION_Z,nv)
		endmethod

		method getX takes integer index returns real
			if HaveSavedReal(HASH,this,(INDEX_POSITION_SIZE*index)+INDEX_POSITION_X) then
				return LoadReal(HASH,this,(INDEX_POSITION_SIZE*index)+INDEX_POSITION_X)
			else
				return 0.
			endif
		endmethod

		method getY takes integer index returns real
			if HaveSavedReal(HASH,this,(INDEX_POSITION_SIZE*index)+INDEX_POSITION_Y) then
				return LoadReal(HASH,this,(INDEX_POSITION_SIZE*index)+INDEX_POSITION_Y)
			else
				return 0.
			endif
		endmethod

		method getZ takes integer index returns real
			if HaveSavedReal(HASH,this,(INDEX_POSITION_SIZE*index)+INDEX_POSITION_Z) then
				return LoadReal(HASH,this,(INDEX_POSITION_SIZE*index)+INDEX_POSITION_Z)
			else
				return 0.
			endif
		endmethod

		static method create takes real x, real y, real z returns thistype
			local thistype this = allocate()
			call setX(0,x)
			call setY(0,y)
			call setZ(0,z)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			local integer i = 0
			loop
				exitwhen i > .index_max
				call RemoveSavedReal(HASH,this,(INDEX_POSITION_SIZE*i)+INDEX_POSITION_X)
				call RemoveSavedReal(HASH,this,(INDEX_POSITION_SIZE*i)+INDEX_POSITION_Y)
				call RemoveSavedReal(HASH,this,(INDEX_POSITION_SIZE*i)+INDEX_POSITION_Z)
				set i = i + 1
			endloop
		endmethod

	endstruct

	struct Bezier extends Curve

		method setProjectedControlPoint takes integer index, real dist, real radius, real ta returns nothing
			local real angle = ta - 90
			local real yaw = bj_RADTODEG * Atan2(getY(INDEX_POINT_LAST)-getY(INDEX_POINT_ORIGIN), getX(INDEX_POINT_LAST)-getX(INDEX_POINT_ORIGIN))
			local real pitch = bj_RADTODEG * Atan2(getZ(INDEX_POINT_LAST)-getZ(INDEX_POINT_ORIGIN), SquareRoot((getX(INDEX_POINT_LAST)-getX(INDEX_POINT_ORIGIN)) * (getX(INDEX_POINT_LAST)-getX(INDEX_POINT_ORIGIN)) + (getY(INDEX_POINT_LAST)-getY(INDEX_POINT_ORIGIN)) * (getY(INDEX_POINT_LAST)-getY(INDEX_POINT_ORIGIN))))
			call setX(INDEX_POINT_MIDDLE+index,getX(INDEX_POINT_ORIGIN) + dist * Cos(Deg2Rad(yaw)) * Cos(Deg2Rad(pitch)) + radius * Cos(Deg2Rad(angle)) * Cos(Deg2Rad(pitch+90))*Cos(Deg2Rad(yaw)) - radius * Sin(Deg2Rad(angle)) * Sin(Deg2Rad(yaw)))
			call setY(INDEX_POINT_MIDDLE+index,getY(INDEX_POINT_ORIGIN) + dist * Sin(Deg2Rad(yaw)) * Cos(Deg2Rad(pitch)) + radius * Cos(Deg2Rad(angle)) * Cos(Deg2Rad(pitch+90))*Sin(Deg2Rad(yaw)) + radius * Sin(Deg2Rad(angle)) * Cos(Deg2Rad(yaw)))
			call setZ(INDEX_POINT_MIDDLE+index,getZ(INDEX_POINT_ORIGIN) + dist * Sin(Deg2Rad(pitch)) + radius * Cos(Deg2Rad(pitch)) * Cos(Deg2Rad(-angle)))
		endmethod

		static method create takes real x1, real y1, real z1, real x2, real y2, real z2 returns thistype
			local thistype this = allocate(x1,y1,z1)
			call setX(INDEX_POINT_LAST,x2)
			call setY(INDEX_POINT_LAST,y2)
			call setZ(INDEX_POINT_LAST,z2)
			return this
		endmethod

	endstruct

	struct Bezier2 extends Bezier
	
		method getCarculatedX takes real v returns real
			local real x1 = getX(INDEX_POINT_ORIGIN) 	+ ( getX(INDEX_POINT_MIDDLE+0) 	- getX(INDEX_POINT_ORIGIN) ) 	* v
			local real x2 = getX(INDEX_POINT_MIDDLE+0) 	+ ( getX(INDEX_POINT_LAST) 		- getX(INDEX_POINT_MIDDLE+0) ) 	* v
			return x1 + (x2 - x1) * v + .offset_x
		endmethod
	
		method getCarculatedY takes real v returns real
			local real y1 = getY(INDEX_POINT_ORIGIN) 	+ ( getY(INDEX_POINT_MIDDLE+0) 	- getY(INDEX_POINT_ORIGIN) ) 	* v
			local real y2 = getY(INDEX_POINT_MIDDLE+0) 	+ ( getY(INDEX_POINT_LAST) 		- getY(INDEX_POINT_MIDDLE+0) ) 	* v
			return y1 + (y2 - y1) * v + .offset_y
		endmethod
	
		method getCarculatedZ takes real v returns real
			local real z1 = getZ(INDEX_POINT_ORIGIN) 	+ ( getZ(INDEX_POINT_MIDDLE+0) 	- getZ(INDEX_POINT_ORIGIN) ) 	* v
			local real z2 = getZ(INDEX_POINT_MIDDLE+0) 	+ ( getZ(INDEX_POINT_LAST) 		- getZ(INDEX_POINT_MIDDLE+0) ) 	* v
			return z1 + (z2 - z1) * v + .offset_z
		endmethod
	
	endstruct

	struct Bezier3 extends Bezier
	
		method getCarculatedX takes real v returns real
			local real hx1 = getX(INDEX_POINT_ORIGIN) 	+ ( getX(INDEX_POINT_MIDDLE+0) 	- getX(INDEX_POINT_ORIGIN) ) 	* v
			local real hx2 = getX(INDEX_POINT_MIDDLE+0) + ( getX(INDEX_POINT_MIDDLE+1) 	- getX(INDEX_POINT_MIDDLE+0) ) 	* v
			local real hx3 = getX(INDEX_POINT_MIDDLE+1) + ( getX(INDEX_POINT_LAST) 		- getX(INDEX_POINT_MIDDLE+1) ) 	* v
			local real x1 = hx1 + ( hx2 - hx1 ) * v
			local real x2 = hx2 + ( hx3 - hx2 ) * v
			return x1 + (x2 - x1) * v + .offset_x
		endmethod
	
		method getCarculatedY takes real v returns real
			local real hy1 = getY(INDEX_POINT_ORIGIN) 	+ ( getY(INDEX_POINT_MIDDLE+0) 	- getY(INDEX_POINT_ORIGIN) ) 	* v
			local real hy2 = getY(INDEX_POINT_MIDDLE+0) + ( getY(INDEX_POINT_MIDDLE+1) 	- getY(INDEX_POINT_MIDDLE+0) ) 	* v
			local real hy3 = getY(INDEX_POINT_MIDDLE+1) + ( getY(INDEX_POINT_LAST) 		- getY(INDEX_POINT_MIDDLE+1) ) 	* v
			local real y1 = hy1 + ( hy2 - hy1 ) * v
			local real y2 = hy2 + ( hy3 - hy2 ) * v
			return y1 + (y2 - y1) * v + .offset_y
		endmethod
	
		method getCarculatedZ takes real v returns real
			local real hz1 = getZ(INDEX_POINT_ORIGIN) 	+ ( getZ(INDEX_POINT_MIDDLE+0) 	- getZ(INDEX_POINT_ORIGIN) ) 	* v
			local real hz2 = getZ(INDEX_POINT_MIDDLE+0) + ( getZ(INDEX_POINT_MIDDLE+1) 	- getZ(INDEX_POINT_MIDDLE+0) ) 	* v
			local real hz3 = getZ(INDEX_POINT_MIDDLE+1) + ( getZ(INDEX_POINT_LAST) 		- getZ(INDEX_POINT_MIDDLE+1) ) 	* v
			local real z1 = hz1 + ( hz2 - hz1 ) * v
			local real z2 = hz2 + ( hz3 - hz2 ) * v
			return z1 + (z2 - z1) * v + .offset_z
		endmethod
	
	endstruct

endlibrary