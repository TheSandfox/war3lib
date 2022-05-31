library EvolveData

	struct EvolveData

		static thistype LAST = 0
		static thistype array ROOT[8192]

		integer monster_id = -1 /*진화 원본*/
		integer target_id = -1	/*진화 목표*/
		integer required_level = 1		/*필요 레벨*/
		integer next_data	= -1		/*다음 데이터*/
		integer material_id1 = -1
		integer material_id2 = -1
		integer material_id3 = -1
		integer material_id4 = -1
		integer material_count1 = -1
		integer material_count2 = -1
		integer material_count3 = -1
		integer material_count4 = -1

		static method showEvolveableMonsters takes integer monster_id returns nothing
			local thistype i = ROOT[monster_id]
			local thistype j = 1
			call BJDebugMsg(MonsterData.NAME[monster_id]+"가 진화할 수 있는 몬스터 :")
			loop
				exitwhen i == -1
				call BJDebugMsg(I2S(j)+" : "+MonsterData.NAME[i.target_id])
				set j = j + 1
				set i = i.next_data
			endloop
		endmethod

		method setMaterialData takes integer index, integer mid, integer count returns nothing
			if index == 0 then
				set .material_id1 = mid
				set .material_count1 = count
			elseif index == 1 then
				set .material_id2 = mid
				set .material_count2 = count
			elseif index == 2 then
				set .material_id3 = mid
				set .material_count3 = count
			elseif index == 3 then
				set .material_id4 = mid
				set .material_count4 = count
			endif
		endmethod

		method getMaterialId takes integer index returns integer
			if index == 0 then
				return .material_id1
			elseif index == 1 then
				return .material_id2
			elseif index == 2 then
				return .material_id3
			elseif index == 3 then
				return .material_id4
			endif
			return -1
		endmethod

		method getMaterialCount takes integer index returns integer
			if index == 0 then
				return .material_count1
			elseif index == 1 then
				return .material_count2
			elseif index == 2 then
				return .material_count3
			elseif index == 3 then
				return .material_count4
			endif
			return -1
		endmethod

		static method getRootData takes integer monster_id returns thistype
			return ROOT[monster_id]
		endmethod

		static method create takes integer monster_id, integer target_id, integer required_level returns thistype
			local thistype this = allocate()
			set .monster_id = monster_id
			set .target_id = target_id
			set .required_level = required_level
			if LAST > 0 and LAST.monster_id == monster_id then
				set LAST.next_data = this
			else
				set ROOT[monster_id] = this
			endif
			set LAST = this
			return this
		endmethod

		private static method act takes nothing returns nothing
			/*call showEvolveableMonsters(0)
			call showEvolveableMonsters(2)
			call showEvolveableMonsters(7)
			call showEvolveableMonsters(21)*/
		endmethod

		private static method onInit takes nothing returns nothing
			local trigger t = CreateTrigger()
			/*0숲거미1티어*/
			call create(0,19,16)
			call create(0,18,16)
			call create(0,20,16)
			/*2태엽고블린1티어*/
			call create(2,15,16)
			call create(2,14,16)
			call create(2,16,16)
			/*3진흙골렘1티어*/
			call create(3,13,16)
			call create(3,14,16)
			/*7딱정벌레1티어*/
			call create(7,19,16)
			call create(7,18,16)
			call create(7,17,16)
			/*8꽃게1티어*/
			call create(8,26,16)
			call create(8,28,16)
			/*11멀록1티어*/
			call create(11,27,16)
			call create(11,30,16)
			/*21시민1티어*/
			call create(21,22,16)
			call create(21,23,16)
			call create(21,24,16)
			/*25위습1티어*/
			call create(25,22,16)
			/*26민물가재2티어*/
			call create(26,31,32)
			/*27차원날개용2티어*/
			call create(27,33,32)
			/*28바다거북2티어*/
			call create(28,29,32)
			/*30멀록싸움꾼2티어*/
			call create(30,32,32)
			/*29바다거인3티어*/
			call create(29,34,50)
			/*31미르미돈3티어*/
			call create(31,35,50)
			/*32세이렌3티어*/
			call create(32,37,50)
			/*33히드라3티어*/
			call create(33,36,50)
			/*임시*/
			call TriggerRegisterTimerEvent(t,0.5,false)
			call TriggerAddAction(t,function thistype.act)
		endmethod

	endstruct

endlibrary