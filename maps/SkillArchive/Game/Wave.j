library Wave requires Undead

	globals
		private rect array RECT
		private hashtable HASH = InitHashtable()
	endglobals

	private struct spawner

		timer main_timer = null
		integer index = 0
		integer level = 0
		integer position = 0

		integer count = 0

		static method timerAction takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			local Unit u = 0
			if not HaveSavedInteger(HASH,.index,.count) then
				call destroy()
				return
			endif
			set u = Undead.new(LoadInteger(HASH,.index,.count),GetRectCenterX(RECT[.position]),GetRectCenterY(RECT[.position]),.position)
			if Guardians.GUARDIAN[.position].getStatus(STATUS_DEAD) <= 0 then
				call u.issueTargetOrder("attack",Guardians.GUARDIAN[.position].origin_unit)
			else
				call u.issuePointOrder("attack",TreeOfLife.X,TreeOfLife.Y)
			endif
			set u.level = .level
			set .count = .count + 1
		endmethod

		static method create takes integer index, integer level, integer position returns thistype
			local thistype this = allocate()
			set .main_timer = Timer.new(this)
			set .index = index
			set .level = level
			set .position = position
			call PingMinimapEx(GetRectCenterX(RECT[.position]),GetRectCenterY(RECT[.position]),2.5,0,0,0,true)
			call Timer.start(.main_timer,0.75,true,function thistype.timerAction)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call Timer.release(.main_timer)
			set .main_timer = null
		endmethod

	endstruct

	struct Wave extends array

		static integer INDEX = 0
		static integer LAST_INDEX = 0
		static integer MAX_INDEX = 0

		static method spawn takes nothing returns nothing
			local integer i = 0
			local integer j = 0
			local integer random = GetRandomInt(0,MAX_INDEX)
			local Undead u = 0
			call spawner.create(random,Round.ROUND+1,0)
			call spawner.create(random,Round.ROUND+1,1)
			call spawner.create(random,Round.ROUND+1,2)
			call spawner.create(random,Round.ROUND+1,3)
		endmethod

		static method addWaveData takes integer index, integer uid returns nothing
			if index > MAX_INDEX then
				set MAX_INDEX = index
			endif
			if LAST_INDEX != index then
				set INDEX = 0
			endif
			set LAST_INDEX = index
			call SaveInteger(HASH,index,INDEX,uid)
			set INDEX = INDEX + 1
		endmethod

		static method initWaveData takes nothing returns nothing
			call addWaveData(0,'U000')
			call addWaveData(0,'U000')
			call addWaveData(0,'U000')
			call addWaveData(0,'U000')
			call addWaveData(0,'U000')
			//
			call addWaveData(1,'U000')
			call addWaveData(1,'U000')
			call addWaveData(1,'U001')
			call addWaveData(1,'U001')
			call addWaveData(1,'U001')
			//
			call addWaveData(2,'U000')
			call addWaveData(2,'U000')
			call addWaveData(2,'U003')
			call addWaveData(2,'U003')
			call addWaveData(2,'U003')
			//
			call addWaveData(3,'U002')
			call addWaveData(3,'U002')
			call addWaveData(3,'U002')
			call addWaveData(3,'U002')
			call addWaveData(3,'U002')
			//
			call addWaveData(4,'U004')
			call addWaveData(4,'U004')
			call addWaveData(4,'U004')
			call addWaveData(4,'U004')
			call addWaveData(4,'U004')
			//
			call addWaveData(5,'U004')
			call addWaveData(5,'U004')
			call addWaveData(5,'U004')
			call addWaveData(5,'U002')
			call addWaveData(5,'U002')
			//
			call addWaveData(6,'U004')
			call addWaveData(6,'U004')
			call addWaveData(6,'U002')
			call addWaveData(6,'U002')
			call addWaveData(6,'U002')
			//
			call addWaveData(7,'U000')
			call addWaveData(7,'U000')
			call addWaveData(7,'U000')
			call addWaveData(7,'U000')
			call addWaveData(7,'U001')
			//
			call addWaveData(8,'U000')
			call addWaveData(8,'U000')
			call addWaveData(8,'U000')
			call addWaveData(8,'U001')
			call addWaveData(8,'U001')
			//
			call addWaveData(9,'U004')
			call addWaveData(9,'U004')
			call addWaveData(9,'U004')
			call addWaveData(9,'U004')
			call addWaveData(9,'U002')
			//
			call addWaveData(10,'U004')
			call addWaveData(10,'U002')
			call addWaveData(10,'U002')
			call addWaveData(10,'U002')
			call addWaveData(10,'U002')
			//
			call addWaveData(11,'U000')
			call addWaveData(11,'U000')
			call addWaveData(11,'U000')
			call addWaveData(11,'U000')
			call addWaveData(11,'U003')
			//
			call addWaveData(12,'U000')
			call addWaveData(12,'U000')
			call addWaveData(12,'U000')
			call addWaveData(12,'U003')
			call addWaveData(12,'U003')
			/*미정의*/
			call addWaveData(13,'U000')
			call addWaveData(13,'U000')
			call addWaveData(13,'U000')
			call addWaveData(13,'U000')
			call addWaveData(13,'U000')
			//
			call addWaveData(14,'U000')
			call addWaveData(14,'U000')
			call addWaveData(14,'U000')
			call addWaveData(14,'U000')
			call addWaveData(14,'U000')
			//
			call addWaveData(15,'U000')
			call addWaveData(15,'U000')
			call addWaveData(15,'U000')
			call addWaveData(15,'U000')
			call addWaveData(15,'U000')
			//
			call addWaveData(16,'U000')
			call addWaveData(16,'U000')
			call addWaveData(16,'U000')
			call addWaveData(16,'U000')
			call addWaveData(16,'U000')
			//
			call addWaveData(17,'U000')
			call addWaveData(17,'U000')
			call addWaveData(17,'U000')
			call addWaveData(17,'U000')
			call addWaveData(17,'U000')
			//
			call addWaveData(18,'U000')
			call addWaveData(18,'U000')
			call addWaveData(18,'U000')
			call addWaveData(18,'U000')
			call addWaveData(18,'U000')
			//
			call addWaveData(19,'U000')
			call addWaveData(19,'U000')
			call addWaveData(19,'U000')
			call addWaveData(19,'U000')
			call addWaveData(19,'U000')
			//
		endmethod

		static method onInit takes nothing returns nothing
			call initWaveData()
			set RECT[0] = gg_rct_GateNorth
			set RECT[1] = gg_rct_GateWest
			set RECT[2] = gg_rct_GateEast
			set RECT[3] = gg_rct_GateSouth
		endmethod

	endstruct

endlibrary