library FieldRegion

	globals
		region array REGION
		integer HOMETOWN = 0
		integer SPIDER_FOREST = 1
		integer VILLAGE = 2
		integer SILENT_LAKE = 3
		constant integer REGION_SIZE = 4

		integer HANDLE_MAX = 0
	endglobals

	struct FieldRegion extends array

		static method adjust takes real x, real y returns integer
			local integer i = 0
			loop
				exitwhen i >= REGION_SIZE
				if IsPointInRegion(REGION[i],x,y) then
					return i
				endif
				set i = i + 1
			endloop
			return -1
		endmethod

		static method init takes nothing returns nothing
			set REGION[HOMETOWN] = CreateRegion()
			set REGION[SPIDER_FOREST] = CreateRegion()
			set REGION[VILLAGE]	=	CreateRegion()
			set REGION[SILENT_LAKE]	=	CreateRegion()
			/**/
			call RegionAddRect(REGION[HOMETOWN],gg_rct_EnteranceHometown01)
			call RegionAddRect(REGION[HOMETOWN],gg_rct_EnteranceHometown02)
			call RegionAddRect(REGION[HOMETOWN],gg_rct_EnteranceHometown03)
			call RegionAddRect(REGION[HOMETOWN],gg_rct_EnteranceHometown04)
			call RegionAddRect(REGION[SPIDER_FOREST],gg_rct_EnteranceSpiderForest01)
			call RegionAddRect(REGION[SPIDER_FOREST],gg_rct_EnteranceSpiderForest02)
			call RegionAddRect(REGION[VILLAGE],gg_rct_EnteranceVillage01)
			call RegionAddRect(REGION[VILLAGE],gg_rct_EnteranceVillage02)
			call RegionAddRect(REGION[SILENT_LAKE],gg_rct_EnteranceSilentLake01)
			/**/
		endmethod

	endstruct

endlibrary

library Field requires Character

	globals
		private integer INDEX_MONSTER = 0
		private integer INDEX_SPAWN_X = 0
		private integer INDEX_SPAWN_Y = 0
		private integer INDEX_MONSTER_ID = 0
		private integer INDEX_MONSTER_CHANCE = 0
		private constant integer ARRAY_SIZE = 32
	endglobals

	struct Field

		static thistype array FIELD[REGION_SIZE]

		private static hashtable HASH = InitHashtable()

		/*현존하는 몬스터들*/
		integer spawn_size = 0

		/*스폰테이블*/
		integer chance_sum = 0
		integer max_index = -1

		/*필드파라메터*/
		integer id			= 0
		integer level_min = 0
		integer level_max = 0
		string name = ""
		string name_subfix = ""
		string model = ""
		boolean sleep = false	/*유저가 장시간 안들어오면 수면상태에 돌입해야함*/

		/*제거해줘야함*/
		timer regen_timer = null
		timer sleep_timer = null

		method getRandomMonsterId takes nothing returns integer
			local integer ri = GetRandomInt(0,chance_sum - 1)
			local integer current_chance = 0
			local integer i = 0
			loop
				exitwhen i > .max_index
				if ri >= current_chance and ri <= current_chance + LoadInteger(HASH,this,INDEX_MONSTER_CHANCE+i) - 1 then
					/*확률정수를 만족하면*/
					return LoadInteger(HASH,this,INDEX_MONSTER_ID+i)
				else
					set current_chance = current_chance + LoadInteger(HASH,this,INDEX_MONSTER_CHANCE+i)
				endif
				set i = i + 1
			endloop
			return 0
		endmethod

		method fillMonsters takes nothing returns nothing
			local integer i = 0
			loop
				exitwhen i >= .spawn_size
				if LoadInteger(HASH,this,INDEX_MONSTER+i) == 0 then
					call SaveInteger(HASH,this,INDEX_MONSTER+i,MonsterCharacter.create(getRandomMonsterId(),LoadReal(HASH,this,INDEX_SPAWN_X+i),LoadReal(HASH,this,INDEX_SPAWN_Y+i),GetRandomReal(0,360)))
				endif
				set i = i + 1
			endloop
		endmethod

		private static method regenTimer takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			call fillMonsters()
		endmethod

		method removeMonster takes MonsterCharacter tm returns nothing
			local integer i = 0
			local Monster m = 0
			loop
				exitwhen i >= .spawn_size
				set m = LoadInteger(HASH,this,INDEX_MONSTER+i)
				if m == tm and tm != 0 then
					call tm.destroy()
					call SaveInteger(HASH,this,INDEX_MONSTER+i,0)
					call Timer.start(.regen_timer,10.,false,function thistype.regenTimer)
				endif
				set i = i + 1
			endloop
		endmethod

		method addSpawnData takes real x, real y returns nothing
			call SaveReal(HASH,this,INDEX_SPAWN_X+.spawn_size,x)
			call SaveReal(HASH,this,INDEX_SPAWN_Y+.spawn_size,y)
			set .spawn_size = .spawn_size + 1
		endmethod

		method addSpawnDataByRect takes rect r returns nothing
			call addSpawnData(GetRectCenterX(r),GetRectCenterY(r))
		endmethod

		method addMonsterData takes integer id, integer chance returns nothing
			set .max_index = .max_index + 1
			if .max_index < ARRAY_SIZE then
				call SaveInteger(HASH,this,INDEX_MONSTER_ID		+.max_index,id)
				call SaveInteger(HASH,this,INDEX_MONSTER_CHANCE	+.max_index,chance)
				set .chance_sum 					= .chance_sum + chance
			else
				set .max_index = .max_index - 1
			endif
		endmethod

		private static method sleepAction takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			local integer j = 0
			local integer i = 0
			local PlayerCharacter pc = 0
			local MonsterCharacter m = 0
			loop
				exitwhen i >= PLAYER_MAX
				set pc = PlayerCharacter.getPlayerCharacter(Player(i))
				if pc != 0 then
					if pc.region_current == .id then
						set j = j + 1
					endif
				endif
				set i = i + 1
			endloop
			if j <= 0 then
				if not .sleep then
					set i = 0
					loop
						exitwhen i >= .spawn_size
						set m = LoadInteger(HASH,this,INDEX_MONSTER+i)
						if m != 0 and not m.onbattle then
							call m.pauseWorkTimer()
							//call BJDebugMsg("슬립")
						endif
						set i = i + 1
					endloop
					call Timer.pause(.sleep_timer)
					set .sleep = true
				endif
			endif
		endmethod

		method awake takes nothing returns nothing
			local integer i = 0
			local MonsterCharacter m = 0
			if .sleep then
				loop
					exitwhen i >= .spawn_size
					set m = LoadInteger(HASH,this,INDEX_MONSTER+i)
					if m != 0 and not m.onbattle then
						call m.startWorkTimer()
					endif
					set i = i + 1
				endloop
				call Timer.start(.sleep_timer,2.5,true,function thistype.sleepAction)
			endif
			set .sleep = false
		endmethod

		static method create takes integer id returns thistype
			local thistype this = allocate()
			set .id = id
			set .regen_timer = Timer.new(this)
			set .sleep_timer = Timer.new(this)
			call Timer.start(.sleep_timer,2.5,true,function thistype.sleepAction)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call Timer.release(.sleep_timer)
			call Timer.release(.regen_timer)
			set .regen_timer = null
			set .sleep_timer = null
		endmethod

		static method initFields takes nothing returns nothing
			/*인덱스*/
			set INDEX_MONSTER 				= 0 * ARRAY_SIZE
			set INDEX_SPAWN_X 				= 1 * ARRAY_SIZE
			set INDEX_SPAWN_Y 				= 2 * ARRAY_SIZE
			set INDEX_MONSTER_ID 			= 3 * ARRAY_SIZE
			set INDEX_MONSTER_CHANCE 		= 4 * ARRAY_SIZE
			/*홈타운*/
			set FIELD[HOMETOWN] = create(HOMETOWN)
			set FIELD[HOMETOWN].level_min = 0
			set FIELD[HOMETOWN].level_max = 0
			set FIELD[HOMETOWN].name = "안식처"
			set FIELD[HOMETOWN].name_subfix = "로"
			set FIELD[HOMETOWN].model = "ui\\battlestage_hometown.mdl"
			/*거미숲*/
			set FIELD[SPIDER_FOREST] = create(SPIDER_FOREST)
			call FIELD[SPIDER_FOREST].addSpawnDataByRect(gg_rct_SpawnSpiderForest01)
			call FIELD[SPIDER_FOREST].addSpawnDataByRect(gg_rct_SpawnSpiderForest02)
			call FIELD[SPIDER_FOREST].addSpawnDataByRect(gg_rct_SpawnSpiderForest03)
			call FIELD[SPIDER_FOREST].addSpawnDataByRect(gg_rct_SpawnSpiderForest04)
			call FIELD[SPIDER_FOREST].addSpawnDataByRect(gg_rct_SpawnSpiderForest05)
			call FIELD[SPIDER_FOREST].addSpawnDataByRect(gg_rct_SpawnSpiderForest06)
			call FIELD[SPIDER_FOREST].addSpawnDataByRect(gg_rct_SpawnSpiderForest07)
			call FIELD[SPIDER_FOREST].addSpawnDataByRect(gg_rct_SpawnSpiderForest08)
			call FIELD[SPIDER_FOREST].addSpawnDataByRect(gg_rct_SpawnSpiderForest09)
			call FIELD[SPIDER_FOREST].addSpawnDataByRect(gg_rct_SpawnSpiderForest10)
			call FIELD[SPIDER_FOREST].addSpawnDataByRect(gg_rct_SpawnSpiderForest11)
			call FIELD[SPIDER_FOREST].addSpawnDataByRect(gg_rct_SpawnSpiderForest12)
			call FIELD[SPIDER_FOREST].addSpawnDataByRect(gg_rct_SpawnSpiderForest13)
			call FIELD[SPIDER_FOREST].addSpawnDataByRect(gg_rct_SpawnSpiderForest14)
			call FIELD[SPIDER_FOREST].addMonsterData(0,1)
			call FIELD[SPIDER_FOREST].addMonsterData(1,1)
			call FIELD[SPIDER_FOREST].addMonsterData(5,1)
			call FIELD[SPIDER_FOREST].fillMonsters()
			set FIELD[SPIDER_FOREST].level_min = 2
			set FIELD[SPIDER_FOREST].level_max = 4
			set FIELD[SPIDER_FOREST].name = "거미숲"
			set FIELD[SPIDER_FOREST].name_subfix = "으로"
			set FIELD[SPIDER_FOREST].model = "ui\\battlestage_spiderforest.mdl"
			/*빌리지*/
			set FIELD[VILLAGE] = create(VILLAGE)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage01)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage02)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage03)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage04)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage05)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage06)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage07)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage08)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage09)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage10)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage11)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage12)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage13)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage14)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage15)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage16)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage17)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage18)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage19)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage20)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage21)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage22)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage23)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage24)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage25)
			call FIELD[VILLAGE].addSpawnDataByRect(gg_rct_SpawnVillage26)
			call FIELD[VILLAGE].addMonsterData(0,1)
			call FIELD[VILLAGE].addMonsterData(1,1)
			call FIELD[VILLAGE].addMonsterData(2,1)
			call FIELD[VILLAGE].addMonsterData(3,1)
			call FIELD[VILLAGE].addMonsterData(4,1)
			call FIELD[VILLAGE].addMonsterData(10,1)
			call FIELD[VILLAGE].fillMonsters()
			set FIELD[VILLAGE].name = "공허한 도시"
			set FIELD[VILLAGE].name_subfix = "로"
			set FIELD[VILLAGE].level_min = 5
			set FIELD[VILLAGE].level_max = 7
			set FIELD[VILLAGE].model = "ui\\battlestage_village.mdl"
			/*고요한 호수*/
			set FIELD[SILENT_LAKE] = create(SILENT_LAKE)
			set FIELD[SILENT_LAKE].level_min = 0
			set FIELD[SILENT_LAKE].level_max = 0
			set FIELD[SILENT_LAKE].name = "고요한 호숫가"
			set FIELD[SILENT_LAKE].name_subfix = "로"
			set FIELD[SILENT_LAKE].model = "ui\\battlestage_hometown.mdl"
		endmethod

	endstruct

endlibrary