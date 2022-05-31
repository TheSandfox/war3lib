library Math

	struct Math
	
		static method distancePoints takes real x1, real y1, real x2, real y2 returns real
			local real dx = x2 - x1
			local real dy = y2 - y1
			return SquareRoot(dx * dx + dy * dy)
		endmethod
	
		static method distancePoints3D takes real x1, real y1, real z1, real x2, real y2, real z2 returns real
			local real dx = x2 - x1
			local real dy = y2 - y1
			local real dz = z2 - z1
			return SquareRoot(dx*dx + dy*dy + dz*dz)	
		endmethod
	
		static method pPX takes real x, real dist, real angle returns real
		return x+dist*Cos(angle*bj_DEGTORAD)
		endmethod
	
		static method pPY takes real y, real dist, real angle returns real
		return y+dist*Sin(angle*bj_DEGTORAD)
		endmethod
	
		static method anglePoints takes real x1, real y1, real x2, real y2 returns real
		return bj_RADTODEG * Atan2(y2-y1, x2-x1)
		endmethod
	
		static method anglePoints2 takes real x1, real y1, real z1, real x2, real y2, real z2 returns real
		return bj_RADTODEG * Atan2(z2-z1, distancePoints(x1,y1,x2,y2)) *-1
		endmethod
		
		static method inBox takes real x1, real y1, real x2, real y2, real width, real height returns boolean
			return x1 >= x2 and x1 <= x2+width and y1 <= y2 and y1 >= y2-height	
		endmethod
	
		static method sign takes real v returns integer
			if v > 0 then
				return 1
			elseif v < 0 then
				return -1
			else
				return 0
			endif
		endmethod
	
		static method reduceRate takes real v returns real
			if v >= 0. then
				return 1-(1/(1+v*0.01))
			else
				return (v*0.01)
			endif
		endmethod
	
		static method distanceLP takes real lx1,real ly1,real lx2,real ly2,real tx,real ty returns real
			local real rad = Atan2(ly2-ly1,lx2-lx1)
			local real ltx = ((lx2-lx1)*Cos(-rad))-((ly2-ly1)*Sin(-rad))
			local real lty = ((lx2-lx1)*Sin(-rad))+((ly2-ly1)*Cos(-rad))
			local real ttx = ((tx-lx1)*Cos(-rad))-((ty-ly1)*Sin(-rad))
			local real tty = ((tx-lx1)*Sin(-rad))+((ty-ly1)*Cos(-rad))
			if ttx <= 0 then /*LEFT SIDE*/
				return Math.distancePoints(ttx,tty,0,0)
			elseif ttx >=ltx then /*RIGHT SIDE*/
				return Math.distancePoints(ttx,tty,ltx,lty)
			else /*INNER SIDE*/
				return RAbsBJ(lty-tty)
			endif
		endmethod
	
		static method px2Size takes real px returns real
			return px/1800.
		endmethod

	endstruct
	
	/*=================================
	
	boolean IsUnitInLine(대상유닛, x1, y1, x2, y2, 반지름값)
	
	:반지름값을 0으로 하면 그냥 직선이 되며 값을 크게 할수록 알약모양에 가까워집니다.)
	
	=================================*/
	/*=================================
	
	boolean IsUnitInSector(대상유닛, 부채꼴원점x, y, 반지름, 부채꼴중심각, 부채꼴너비각)
	
	:부채꼴 너비각에 90을 넣으면 원을 4등분(180 넣으면 2등분)한 부채꼴이 나온다 생각하시면 됩니다.
	
	=================================*/
	/*=================================
	
	boolean IsUnitEnemyEx(대상유닛, 플레이어)
	
	:조건식 여러개 쓰기 귀찮아서 하나로 합친 함수입니다.
	
	=================================*/
	
	scope CollisionFunc
	
		function IsUnitInLine takes unit u, real lx1, real ly1, real lx2, real ly2, real size returns boolean
			return Math.distanceLP(lx1,ly1,lx2,ly2,GetUnitX(u),GetUnitY(u)) <= BlzGetUnitCollisionSize(u)+size
		endfunction
	
		function IsUnitInSector takes unit u, real ox, real oy, real dist, real dir, real width returns boolean
			if IsUnitInRangeXY(u,ox,oy,dist) and Cos(Deg2Rad(Math.anglePoints(ox,oy,GetUnitX(u),GetUnitY(u))-dir)) >= Cos(Deg2Rad(width/2)) then
				return true
			elseif IsUnitInLine(u,ox,oy,Math.pPX(ox,dist,dir+(width/2)),Math.pPY(oy,dist,dir+(width/2)),0) then
				return true
			elseif IsUnitInLine(u,ox,oy,Math.pPX(ox,dist,dir-(width/2)),Math.pPY(oy,dist,dir-(width/2)),0) then
				return true
			else
				return false
			endif
		endfunction
	
	endscope

	endlibrary
	
