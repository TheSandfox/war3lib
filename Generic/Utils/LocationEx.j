library LocationEx
	
	globals
		private location LOC = Location(0,0)
	endglobals

	struct LocationEx extends array

		static method operator x takes nothing returns real
			return GetLocationX(LOC)
		endmethod

		static method operator y takes nothing returns real
			return GetLocationY(LOC)
		endmethod

		static method operator z takes nothing returns real
			return GetLocationZ(LOC)
		endmethod

		static method move takes real x, real y returns nothing
			call MoveLocation(LOC,x,y)
		endmethod

		static method operator x= takes real nx returns nothing
			call move(nx,.y)
		endmethod

		static method operator y= takes real ny returns nothing
			call move(.x,ny)
		endmethod

		static method getX takes nothing returns real
			return .x
		endmethod

		static method getY takes nothing returns real
			return .y
		endmethod

		static method getZ takes nothing returns real
			return .z
		endmethod

		static method getLocalZ takes real x, real y returns real
			call move(x,y)
			return .z
		endmethod

		static method polarProjection takes real distance, real angle returns nothing
			call move(.x+distance*Cos(angle*bj_DEGTORAD),.y+distance*Sin(angle*bj_DEGTORAD))
		endmethod

		static method collisionProjection takes real x, real y returns real
			local item it = CreateItem('gcel',x,y)
			local real ix = GetItemX(it)
			local real iy = GetItemY(it)
			call move(ix,iy)
			call RemoveItem(it)
			set it = null
			set ix = x - ix
			set iy = y - iy
			return SquareRoot(ix*ix + iy*iy)
		endmethod

	endstruct

	function GetLocalZ takes real x, real y returns real
		call MoveLocation(LOC,x,y)
		return GetLocationZ(LOC)
	endfunction
	
endlibrary