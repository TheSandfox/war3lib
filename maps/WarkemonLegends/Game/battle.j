//! import "battleui.j"

library BattleRequest

	struct BattleRequest

		static trigger REQUEST_TRIGGER 				= CreateTrigger()
		static integer EVENT_PLAYER_CHARACTER 		= 0
		static integer EVENT_MONSTER_CHARACTER 		= 0
		static integer EVENT_FIELD					= 0

		static method request takes integer pc, integer mc, integer f returns nothing
			/*라이브러리 선행관계로인해 트리거로 우회하여 격발*/
			set EVENT_PLAYER_CHARACTER = pc
			set EVENT_MONSTER_CHARACTER = mc
			set EVENT_FIELD = f
			call TriggerExecute(REQUEST_TRIGGER)
		endmethod

	endstruct

endlibrary

library Battle requires Field, Profile, BattleUI, MonsterAbilityActorRequest

	globals
		private constant integer PLAYER_MAX					= 2
		private constant integer BATTLE_MONSTER_PER_PLAYER 	= 5
		private constant integer BATTLE_MONSTER_PER_BATTLE 	= 10	/* BATTLE_MONSTER_PER_PLAYER x 2 */
		private constant integer ACTOR_REQUEST_SIZE			= 256
	endglobals

	struct Battle

		private static hashtable REQUEST_HASH = InitHashtable()

		private static real array X_OFFSET_FROM_CENTER[2]
		private static real array Y_OFFSET_FROM_CENTER[2]
		private static real array FACING[2]
		private static constant real Z_OFFSET 		= 5.
		private static constant real FORMATION_WIDTH = 750.
		private static constant real FORMATION_HEIGHT = 250.

		private static constant string EFFECT_PATH 		= "Effects\\BattleEffectOverhead.mdl"
		private static constant real EFFECT_Z_OFFSET	= 125.
		private static constant real INIT_DELAY1		= 0.5
		private static constant real INIT_DELAY2		= 2.5
		private static constant real ENCOUNTER_IGNORE	= 5.

		private static constant integer STATE_TIME_ELAPSE 	= 0		/*시간경과중*/
		private static constant integer STATE_WAIT_ORDER	= 1		/*행동선택중*/
		private static constant integer STATE_PLAY_ACTOR	= 2		/*행위자 재생중*/
		private static constant integer STATE_END_BATTLE	= 3		/*배틀이 끝났다*/
		private static constant integer STATE_SELECT_TARGET = 4		/*능력 대상 지정 중*/

		static rect array RECT[4]					/*배틀스페이스*/
		private static boolean array OCCUPIED[4]				/*배틀스페이스 점유여부*/
		private static integer BATTLE_MONSTER_REMAINING_1P = -1		/*몇마리남았나(임시변수)*/
		private static integer BATTLE_MONSTER_REMAINING_2P = -1		/*몇마리남았나(임시변수)*/
		private static BattleMonster array TIEBREAK1[BATTLE_MONSTER_PER_BATTLE]	/*타이브레이크용 몬스터배열(임시)*/
		private static BattleMonster array TIEBREAK2[BATTLE_MONSTER_PER_BATTLE]	/*타이브레이크용 몬스터배열(임시)*/

		PlayerCharacter player_character1 	= 0
		PlayerCharacter player_character2	= 0
		MonsterCharacter monster_character	= 0
		Field field							= 0
		BattleMonster battle_monster_wait_order		= 0
		BattleMonsterAbility ability_current 		= 0
		
		/*제거해줘야함*/
		//MonsterAbilityActorRequest array actor_request[ACTOR_REQUEST_SIZE]
		BattleMonster array battle_monster[BATTLE_MONSTER_PER_BATTLE]
		BattleUI array battle_ui[PLAYER_MAX]
		Effect effect1			= 0
		Effect effect2			= 0
		Effect bg				= 0
		timer main_timer		= null	/*턴 넘어오기전까지 계속 돌아가는 타이머*/
		timer end_timer			= null
		trigger keypress		= null

		player array battle_player[PLAYER_MAX]

		integer slot			= -1	/*해당 인스턴스가 몇 번째 칸을 쓰고있는지*/
		integer init_stage 		= 0		/*시간차 초기화를 위한 단계변수*/
		real time_elapsed		= 0.	/*경과시간*/
		integer state			= 0		/*상태변수*/

		private method convertPlayerIndex takes player p returns integer
			if p != null then
				if p == .battle_player[0] then
					return 0
				elseif p == .battle_player[1] then
					return 1
				endif
			endif
			return -1
		endmethod

		method getMonsterAbilityActorRequest takes integer i returns MonsterAbilityActorRequest
			return LoadInteger(REQUEST_HASH,this,i)
		endmethod

		method setMonsterAbilityActorRequest takes integer i, integer v returns nothing
			call SaveInteger(REQUEST_HASH,this,i,v)
		endmethod

		method getLastMonsterAbilityActorRequestIndex takes nothing returns integer
			local integer i = 0
			loop
				exitwhen i == ACTOR_REQUEST_SIZE
				if getMonsterAbilityActorRequest(i) == -1 then
					return i
				endif
				set i = i + 1
			endloop
			return -1
		endmethod

		method getNextMonsterAbilityMainActorRequestIndex takes integer index returns integer
			/*다음 메인액트가 있는 인덱스를 반환*/
			local integer i = index
			loop
				exitwhen i == ACTOR_REQUEST_SIZE
				if getMonsterAbilityActorRequest(i) == -1 then
					exitwhen true
				elseif getMonsterAbilityActorRequest(i) == MonsterAbilityActorRequest.TYPE_MAIN then
					return i
				endif
				set i = i + 1
			endloop
			return -1
		endmethod

		method pushMonsterAbilityActorRequest takes integer index, integer id, integer oa, integer caster, integer target, integer t returns nothing
			/*특정 위치에 액터 배치(뒤로 밀어내면서)*/
			local integer j = getLastMonsterAbilityActorRequestIndex()
			if j == -1 then
				return
			elseif j < ACTOR_REQUEST_SIZE - 1 then
				call setMonsterAbilityActorRequest(j+1,-1)
			elseif j == ACTOR_REQUEST_SIZE then
				call getMonsterAbilityActorRequest(j).destroy()
			endif
			loop
				exitwhen j <= 0 or j <= index
				call setMonsterAbilityActorRequest(j,getMonsterAbilityActorRequest(j-1))
				set j = j - 1
			endloop
			call setMonsterAbilityActorRequest(index,MonsterAbilityActorRequest.create(this,id,oa,caster,target,t))
		endmethod

		method removeMonsterAbilityActorRequest takes integer index returns nothing
			/*특정 위치의 액터 삭제(당겨오면서)*/
			local integer i = index
			if getMonsterAbilityActorRequest(i) != 0 and getMonsterAbilityActorRequest(i) != -1 then
				call getMonsterAbilityActorRequest(i).destroy()
			endif
			loop
				exitwhen i >= ACTOR_REQUEST_SIZE
				if i < ACTOR_REQUEST_SIZE - 1 then
					if getMonsterAbilityActorRequest(i) == -1 then
						exitwhen true
					else
						call setMonsterAbilityActorRequest(i,getMonsterAbilityActorRequest(i+1))
					endif
				else
					call setMonsterAbilityActorRequest(i,-1)
				endif
				set i = i + 1
			endloop
		endmethod

		method addMonsterAbilityActorRequest takes integer id, integer oa, integer caster, integer target, integer t returns nothing
			/*배열의 제일 끝에 액터 생성*/
			local integer i = 0
			loop
				exitwhen i >= ACTOR_REQUEST_SIZE
				if getMonsterAbilityActorRequest(i) == -1 then
					call setMonsterAbilityActorRequest(i,MonsterAbilityActorRequest.create(this,id,oa,caster,target,t))
					if i < ACTOR_REQUEST_SIZE - 1 then
						call setMonsterAbilityActorRequest(i+1,-1)
					endif
					exitwhen true
				endif
				set i = i + 1
			endloop
		endmethod

		private method getBattleMonsterIndex takes BattleMonster bm returns integer
			local integer i = 0
			loop
				exitwhen i >= BATTLE_MONSTER_PER_BATTLE
				if .battle_monster[i] == bm and bm != 0 then
					return i
				endif
				set i = i + 1
			endloop
			return -1
		endmethod

		method executeBattleMonsterAbility takes BattleMonster bm, BattleMonsterAbility bma, BattleMonster target returns nothing
			local integer index = getBattleMonsterIndex(bm)
			local integer i = 0
			local integer j = 0
			if target == 0 then
				/*NULL TARGET을 인풋으로 받았으면*/
				if index < BATTLE_MONSTER_PER_PLAYER then
					set j = 0
				else
					set j = 5
				endif
				loop
					exitwhen i >= BATTLE_MONSTER_PER_PLAYER
					if .battle_monster[i+j] != 0 and .battle_monster[i+j].alive then
						set target = .battle_monster[i+j]
						exitwhen true
					endif
					set i = i + 1
				endloop
			endif
			if bma != 0 then
				call addMonsterAbilityActorRequest(bma.actor_id1,bma,bm,target,0)
			endif
			set bm.ap = bm.ap - bma.ap_cost
			if .battle_ui[0] != 0 then
				call .battle_ui[0].refreshAPGauge()
			endif
			if .battle_ui[1] != 0 then
				call .battle_ui[1].refreshAPGauge()
			endif
			call setStatePlayActor()
		endmethod

		method setStateSelectTarget takes BattleMonster bm, BattleMonsterAbility bma returns nothing
			local integer i = getBattleMonsterIndex(bm)
			set .state = STATE_SELECT_TARGET
			set .ability_current = bma
			if i < BATTLE_MONSTER_PER_PLAYER then
				if .battle_ui[0] != 0 then
					call .battle_ui[0].setStateSelectTarget()
				endif
			else
				if .battle_ui[1] != 0 then
					call .battle_ui[1].setStateSelectTarget()
				endif
			endif
		endmethod

		method countRemainingMonsters takes nothing returns integer
			/*총 마릿수를 반환하는 함수, 1P2P 마릿수는 정적변수에 저장해둠*/
			local integer i = 0
			local integer j = 0
			set BATTLE_MONSTER_REMAINING_1P = 0
			set BATTLE_MONSTER_REMAINING_2P = 0
			loop
				exitwhen i >= BATTLE_MONSTER_PER_PLAYER
				if .battle_monster[i] != 0 and .battle_monster[i].alive and not .battle_monster[i].catched then
					set BATTLE_MONSTER_REMAINING_1P = BATTLE_MONSTER_REMAINING_1P + 1
					set j = j + 1
				endif
				if .battle_monster[i+BATTLE_MONSTER_PER_PLAYER] != 0 /*
					*/and .battle_monster[i+BATTLE_MONSTER_PER_PLAYER].alive /*
					*/and not .battle_monster[i+BATTLE_MONSTER_PER_PLAYER].catched then
					set BATTLE_MONSTER_REMAINING_2P = BATTLE_MONSTER_REMAINING_2P + 1
					set j = j + 1
				endif
				set i = i + 1
			endloop
			return j
		endmethod

		private method getFastestBattleMonster takes nothing returns BattleMonster
			local integer i = 0
			local integer j = 0
			local BattleMonster fastest = 0			/*현재 가장 빠른 몬스터*/
			local BattleMonster bm = 0
			local real value_max = 0.
			local integer tiebreak1 = 0		/*행동력이 똑같은 몬스터가 있는지 여부*/
			local integer tiebreak2 = 0		/*스피드가 똑같은 몬스터가 있는지 여부*/
			/*타이브레이크용 AP중복 몬스터 배열 초기화*/
			loop
				exitwhen i >= BATTLE_MONSTER_PER_BATTLE
				set TIEBREAK1[i] = 0
				set TIEBREAK2[i] = 0
				set i = i + 1
			endloop
			/*AP가 가장 높은 몬스터 색출*/
			set i = 0
			loop
				exitwhen i >= BATTLE_MONSTER_PER_BATTLE
				set bm = .battle_monster[i]
				if bm != 0 and bm.alive then
					/*최초일 경우*/
					if i == 0 then
						set value_max = bm.ap
						set fastest = bm
						/*해당 몬스터를 일단 등록*/
						set TIEBREAK1[tiebreak1] = bm
						set tiebreak1 = tiebreak1 + 1
					else
						/*기록 갱신이 됐으면*/
						if bm.ap > value_max then
							set value_max = bm.ap
							set fastest = bm
							/*타이브레이크 배열을 비우고*/
							set j = 0
							loop
								exitwhen j >= tiebreak1
								set TIEBREAK1[j] = 0
								set j = j + 1
							endloop
							set tiebreak1 = 0
							/*해당 몬스터를 일단 등록*/
							set TIEBREAK1[tiebreak1] = bm
							set tiebreak1 = tiebreak1 + 1
						/*기존 신기록과 똑같으면 타이브레이크 배열에 등록*/
						elseif bm.ap == value_max then
							set TIEBREAK1[tiebreak1] = bm
							set tiebreak1 = tiebreak1 + 1
						endif
					endif
				endif
				set i = i + 1
			endloop
			/*최대AP 보유자가 1명 초과일 경우*/
			if tiebreak1 > 1 then
				/*스피드가 가장 높은 몬스터 색출*/
				set i = 0
				loop
					exitwhen i >= tiebreak1
					set bm = TIEBREAK1[i]
					/*최초일 경우*/
					if i == 0 then
						set value_max = bm.getCarculatedStat(STAT_TYPE_SPEED)
						set fastest = bm
						/*해당 몬스터를 일단 등록*/
						set TIEBREAK2[tiebreak2] = bm
						set tiebreak2 = tiebreak2 + 1
					else
						/*기록 갱신이 됐으면*/
						if bm.getCarculatedStat(STAT_TYPE_SPEED) > value_max then
							set value_max = bm.getCarculatedStat(STAT_TYPE_SPEED)
							set fastest = bm
							/*타이브레이크 배열을 비우고*/
							set j = 0
							loop
								exitwhen j >= tiebreak2
								set TIEBREAK2[j] = 0
								set j = j + 1
							endloop
							set tiebreak2 = 0
							/*해당 몬스터를 일단 등록*/
							set TIEBREAK2[tiebreak2] = bm
							set tiebreak2 = tiebreak2 + 1
						/*기존 신기록과 똑같으면*/
						elseif bm.getCarculatedStat(STAT_TYPE_SPEED) == value_max then
							/*해당 몬스터를 일단 등록*/
							set TIEBREAK2[tiebreak2] = bm
							set tiebreak2 = tiebreak2 + 1
						endif
					endif
					set i = i + 1
				endloop
			endif
			/*스피드 마저 똑같으면...*/
			if tiebreak2 > 1 then
				/*모르겠다 랜덤*/
				set fastest = TIEBREAK2[GetRandomInt(0,tiebreak2-1)]
			endif
			return fastest
		endmethod

		method checkMonstersAP takes nothing returns integer
			/*행동 가능한 몬스터의 마릿수를 반환*/
			local integer i = 0
			local integer j = 0
			local BattleMonster bm = 0
			loop
				exitwhen i >= BATTLE_MONSTER_PER_BATTLE
				set bm = .battle_monster[i]
				if bm != 0 and bm.ap >= 100. and bm.alive then
					set j = j + 1
				endif
				set i = i + 1
			endloop
			return j
		endmethod

		method setStateWaitOrder takes BattleMonster bm returns nothing
			local integer index = 0
			local integer j = 0
			local boolean is_cpu = false
			/**/
			/*명령대기모드로 전환&움직여야할 몬스터 지정*/
			set .state = STATE_WAIT_ORDER
			set .battle_monster_wait_order = bm
			set index = getBattleMonsterIndex(.battle_monster_wait_order)
			/*UI 리프레시*/
			if .battle_ui[0] != 0 then
				call .battle_ui[0].refreshAPGauge()
				call .battle_ui[0].refreshTimeIndicator(.time_elapsed,false)
				call .battle_ui[0].refreshHighlight(bm)
			endif
			if .battle_ui[1] != 0 then
				call .battle_ui[1].refreshAPGauge()
				call .battle_ui[1].refreshTimeIndicator(.time_elapsed,false)
				call .battle_ui[1].refreshHighlight(bm)
			endif
			if index > -1 then
				/*해당 몹이 1피꺼면*/
				if index < BATTLE_MONSTER_PER_PLAYER then
					if .battle_ui[0] != 0 then
						call .battle_ui[0].setDisplayTarget(.battle_monster_wait_order)
						call .battle_ui[0].setStateSelectAbility()
					else
						set is_cpu = true
					endif
				/*해당 몹이 2피꺼면*/
				else
					if .battle_ui[1] != 0 then
						call .battle_ui[1].setDisplayTarget(.battle_monster_wait_order)
						call .battle_ui[1].setStateSelectAbility()
					else
						set is_cpu = true
					endif
				endif
			endif
			/*몬스터 ai*/
			if is_cpu then
				set index = 0
				set j = 0
				loop
					exitwhen index >= MONSTER_ABILITY_COUNT_MAX 
					if .battle_monster_wait_order.getBattleMonsterAbility(index) != 0 then
						set j = j + 1
					else
						exitwhen true
					endif
					set index = index + 1
				endloop
				if j > 0 then
					set index = GetRandomInt(0,BATTLE_MONSTER_PER_PLAYER-1)
					call executeBattleMonsterAbility(.battle_monster_wait_order,.battle_monster_wait_order.getBattleMonsterAbility(GetRandomInt(0,j-1)),/*
						*/.battle_monster[index])
					call BJDebugMsg(I2S(index))
				else
					set .battle_monster_wait_order.ap = .battle_monster_wait_order.ap - 100.
					call setStateTimeElapse()
				endif
			endif
		endmethod

		private static method endBattle takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			if .init_stage == 0 then
				set .init_stage = 1
				/*CreateFade*/
				/*페이드 최대치 달성시점 1.*/
				/*페이드생성 후 2.초 시점에서 1.초에 걸쳐 페이드아웃*/
				/*총 존속시간 3.초*/
				if .battle_player[0] != null then
					call FadeIn.create("ui\\ui_trans2.mdl",3.,.battle_player[0])
				endif
				if .battle_player[1] != null then
					call FadeIn.create("ui\\ui_trans2.mdl",3.,.battle_player[1])
				endif
				call Timer.start(.end_timer,1.5,false,function thistype.endBattle)
			else
				call destroy()
			endif
		endmethod

		private static method timeElapse takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			local integer i = 0
			local BattleMonster bm = 0
			set .time_elapsed = .time_elapsed + TIMER_TICK
			/**/
			loop
				exitwhen i >= BATTLE_MONSTER_PER_BATTLE
				set bm = .battle_monster[i]
				if bm != 0 and bm.alive then
					/*행동력게이지 충전*/
					call bm.addAP()
				endif
				set i = i + 1
			endloop
			/*UI 리프레시*/
			if .battle_ui[0] != 0 then
				call .battle_ui[0].refreshAPGauge()
				call .battle_ui[0].refreshTimeIndicator(.time_elapsed,true)
			endif
			if .battle_ui[1] != 0 then
				call .battle_ui[1].refreshAPGauge()
				call .battle_ui[1].refreshTimeIndicator(.time_elapsed,true)
			endif
			/*행동 가능한 몬스터가 있으면 일단 타이머 정지*/
			if checkMonstersAP() >= 1 then
				call Timer.release(.main_timer)
				set .main_timer = null
				call setStateWaitOrder(getFastestBattleMonster())
			endif
		endmethod

		method setStateTimeElapse takes nothing returns nothing
			/*타임일랩스모드로 전환*/
			set .state = STATE_TIME_ELAPSE
			if checkMonstersAP() >= 1 then
				call Timer.release(.main_timer)
				set .main_timer = null
				call setStateWaitOrder(getFastestBattleMonster())
			else
				if .main_timer == null then
					set .main_timer = Timer.new(this)
				endif
				call Timer.start(.main_timer,TIMER_TICK,true,function thistype.timeElapse)
			endif
		endmethod

		method getRemainingPartyMonsters takes player p returns integer
			local integer j = 0
			local integer i = 0
			local Monster m = 0
			local Profile pr = 0
			if p != null then
				set pr = Profile.getPlayerProfile(p)
			else
				return 0
			endif
			loop
				exitwhen i >= BATTLE_MONSTER_PER_PLAYER
				set m = Party.getMonster(pr,i)
				if m != 0 and m.alive and not m.onbattle then
					set j = j + 1
				endif
				set i = i + 1
			endloop
			return j
		endmethod

		method setStateBattleEnd takes nothing returns nothing
			set .state = STATE_END_BATTLE
			set .init_stage = 0
			call Timer.start(.end_timer,2.,false,function thistype.endBattle)
		endmethod

		method setStatePlayActor takes nothing returns nothing
			local boolean endbattle = false
			set .state = STATE_PLAY_ACTOR
			/*UI갱신*/
			if .battle_ui[0] != 0 then
				call .battle_ui[0].refreshHPGauge()
			endif
			if .battle_ui[1] != 0 then
				call .battle_ui[1].refreshHPGauge()
			endif
			/*각 팀 남은 몬스터 계수*/
			call countRemainingMonsters() 
			if BATTLE_MONSTER_REMAINING_1P == 0 or BATTLE_MONSTER_REMAINING_2P == 0 then
				call setStateBattleEnd()
			else
				if getMonsterAbilityActorRequest(0) > 0 then
					call getMonsterAbilityActorRequest(0).request()
					call removeMonsterAbilityActorRequest(0)
				else
					/*UI갱신*/
					if .battle_ui[0] != 0 then
						call .battle_ui[0].setStateNormal()
					endif
					if .battle_ui[1] != 0 then
						call .battle_ui[1].setStateNormal()
					endif
					call setStateTimeElapse()
				endif
			endif
		endmethod

		method tryCatchMonster takes BattleMonster bm returns nothing
			set bm.ap = bm.ap - 100.
			call addMonsterAbilityActorRequest('xxx0',0,bm,.battle_monster[BATTLE_MONSTER_PER_PLAYER],0)
			if .battle_ui[0] != 0 then
				call .battle_ui[0].refreshAPGauge()
			endif
			if .battle_ui[1] != 0 then
				call .battle_ui[1].refreshAPGauge()
			endif
			call setStatePlayActor()
		endmethod

		private method readyPhase takes nothing returns nothing
			local integer i = 0
			/*배틀UI 초기화&효과음 재생*/
			loop
				exitwhen i >= PLAYER_MAX
				if .battle_player[i] != null then
					set .battle_ui[i] = BattleUI.create(.battle_player[i])
					call PlaySoundBJ(gg_snd_GoodJob)
				endif
				set i = i + 1
			endloop
			/*메인타이머 작동 시작*/
			call Timer.start(main_timer,TIMER_TICK,true,function thistype.timeElapse)
			/**/
			if .battle_ui[0] != 0 then
				call .battle_ui[0].setDisplayTarget(.battle_monster[0])
				call .battle_ui[0].setMonsterBoxTarget(.battle_monster[0],.battle_monster[1],.battle_monster[2],.battle_monster[3],.battle_monster[4],true)
				call .battle_ui[0].setMonsterBoxTarget(.battle_monster[Party.PARTY_SIZE],.battle_monster[Party.PARTY_SIZE+1],.battle_monster[Party.PARTY_SIZE+2],.battle_monster[Party.PARTY_SIZE+3],.battle_monster[Party.PARTY_SIZE+4],false)
				call .battle_ui[0].refreshHPGauge()
				call .battle_ui[0].refreshAPGauge()
			endif
			if .battle_ui[1] != 0 then
				call .battle_ui[1].setDisplayTarget(.battle_monster[Party.PARTY_SIZE])
				call .battle_ui[1].setMonsterBoxTarget(.battle_monster[Party.PARTY_SIZE],.battle_monster[Party.PARTY_SIZE+1],.battle_monster[Party.PARTY_SIZE+2],.battle_monster[Party.PARTY_SIZE+3],.battle_monster[Party.PARTY_SIZE+4],true)
				call .battle_ui[1].setMonsterBoxTarget(.battle_monster[0],.battle_monster[1],.battle_monster[2],.battle_monster[3],.battle_monster[4],false)
				call .battle_ui[1].refreshHPGauge()
				call .battle_ui[1].refreshAPGauge()
			endif
		endmethod

		method pressASZX takes nothing returns nothing
			local BattleMonsterAbility target_ability = 0
			local integer bm_index = 0
			local integer target = 0
			if .state == STATE_WAIT_ORDER then
				/*명령대기*/
				if BlzGetTriggerPlayerKey() == OSKEY_Z then
					call setStateSelectTarget(.battle_monster_wait_order,.battle_monster_wait_order.getBattleMonsterAbility(.battle_ui[convertPlayerIndex(GetTriggerPlayer())].cursor[0]))
				endif
			elseif .state == STATE_SELECT_TARGET then
				/*타겟 정하는 로직 나중에 짤 것*/
				if BlzGetTriggerPlayerKey() == OSKEY_Z then
					set bm_index = getBattleMonsterIndex(.battle_monster_wait_order)
					if bm_index < BATTLE_MONSTER_PER_PLAYER then
						set target = .battle_monster[BATTLE_MONSTER_PER_PLAYER]
					else
						set target = .battle_monster[0]
					endif
					call executeBattleMonsterAbility(.battle_monster_wait_order,.ability_current,target)
				elseif BlzGetTriggerPlayerKey() == OSKEY_X then
					call setStateWaitOrder(.battle_monster_wait_order)
				endif
			endif
		endmethod

		method pressArrow takes nothing returns nothing
			local integer i = convertPlayerIndex(GetTriggerPlayer())
			local integer result = 0
			/*배틀UI의 커서 움직여주기*/
			if .state == STATE_WAIT_ORDER then
				if .battle_ui[i].state == BattleUI.STATE_SELECT_ABILITY then
					if BlzGetTriggerPlayerKey() == OSKEY_UP then
						set result = .battle_ui[i].cursor[0] - BattleUI.ABILITY_BOX_BOX_PER_ROW
					elseif BlzGetTriggerPlayerKey() == OSKEY_DOWN then
						set result = .battle_ui[i].cursor[0] + BattleUI.ABILITY_BOX_BOX_PER_ROW
					elseif BlzGetTriggerPlayerKey() == OSKEY_LEFT then
						set result = .battle_ui[i].cursor[0] - 1
					elseif BlzGetTriggerPlayerKey() == OSKEY_RIGHT then
						set result = .battle_ui[i].cursor[0] + 1
					endif
					if result >= 0 and result < MONSTER_ABILITY_COUNT_MAX then
						if .battle_ui[i].display_target.getBattleMonsterAbility(result) != 0 then
							call .battle_ui[i].refreshAbilityCursor(result)
						endif
					endif
				endif
			elseif .state == STATE_SELECT_TARGET then
				if .battle_ui[i].state == BattleUI.STATE_SELECT_TARGET then
					if BlzGetTriggerPlayerKey() == OSKEY_UP then
						set result = .battle_ui[i].cursor[1] + 1
					elseif BlzGetTriggerPlayerKey() == OSKEY_DOWN then
						set result = .battle_ui[i].cursor[1] - 1
					elseif BlzGetTriggerPlayerKey() == OSKEY_LEFT then
						set result = .battle_ui[i].cursor[1] + 1
					elseif BlzGetTriggerPlayerKey() == OSKEY_RIGHT then
						set result = .battle_ui[i].cursor[1] - 1
					endif
					if result >= 0 and result < MONSTER_ABILITY_COUNT_MAX then
						if .battle_ui[i].display_target.getBattleMonsterAbility(result) != 0 then
							call .battle_ui[i].refreshAbilityCursor(result)
						endif
					endif
				endif
			endif
		endmethod

		private static method keyPress takes nothing returns nothing
			local thistype this = Trigger.getData(GetTriggeringTrigger())
			if .battle_monster_wait_order.owner == GetTriggerPlayer() then
				/*본인 몹의 턴이 왔을 때에만 조종이 가능하게*/
				if BlzGetTriggerPlayerKey() == OSKEY_Z then
					call pressASZX()
				elseif BlzGetTriggerPlayerKey() == OSKEY_X then
					call pressASZX()
				elseif BlzGetTriggerPlayerKey() == OSKEY_A then
					call pressASZX()
				elseif BlzGetTriggerPlayerKey() == OSKEY_S then
					call pressASZX()
				else
					call pressArrow()
				endif
			endif
		endmethod

		private static method delayedInit takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			local Profile pr = 0
			/*키프레스 트리거*/
			set .keypress = Trigger.new(this)
			call TriggerAddCondition(.keypress,function thistype.keyPress)
			if .init_stage == 0 then
				/*지형 숨김*/
				if GetLocalPlayer() == .battle_player[0] or GetLocalPlayer() == .battle_player[1] then
					call BlzShowTerrain(false)
				endif
				/*페이드 걸린 사이에 카메라 이동, 키프레스 트리거*/
				if .battle_player[0] != null then
					set pr = Profile.getPlayerProfile(.battle_player[0])
					set pr.cam_current = gg_cam_BATTLECAM1
					call SetUnitPosition(pr.cam_unit,GetRectCenterX(RECT[.slot]),GetRectCenterY(RECT[.slot]))
					call BlzTriggerRegisterPlayerKeyEvent(.keypress,.battle_player[0],OSKEY_UP,0,true)
					call BlzTriggerRegisterPlayerKeyEvent(.keypress,.battle_player[0],OSKEY_DOWN,0,true)
					call BlzTriggerRegisterPlayerKeyEvent(.keypress,.battle_player[0],OSKEY_LEFT,0,true)
					call BlzTriggerRegisterPlayerKeyEvent(.keypress,.battle_player[0],OSKEY_RIGHT,0,true)
					call BlzTriggerRegisterPlayerKeyEvent(.keypress,.battle_player[0],OSKEY_Z,0,true)
					call BlzTriggerRegisterPlayerKeyEvent(.keypress,.battle_player[0],OSKEY_X,0,true)
					call BlzTriggerRegisterPlayerKeyEvent(.keypress,.battle_player[0],OSKEY_A,0,true)
					call BlzTriggerRegisterPlayerKeyEvent(.keypress,.battle_player[0],OSKEY_S,0,true)
				endif
				if .battle_player[1] != null then
					set pr = Profile.getPlayerProfile(.battle_player[1])
					set pr.cam_current = gg_cam_BATTLECAM2
					call SetUnitPosition(pr.cam_unit,GetRectCenterX(RECT[.slot]),GetRectCenterY(RECT[.slot]))
					call BlzTriggerRegisterPlayerKeyEvent(.keypress,.battle_player[1],OSKEY_UP,0,true)
					call BlzTriggerRegisterPlayerKeyEvent(.keypress,.battle_player[1],OSKEY_DOWN,0,true)
					call BlzTriggerRegisterPlayerKeyEvent(.keypress,.battle_player[1],OSKEY_LEFT,0,true)
					call BlzTriggerRegisterPlayerKeyEvent(.keypress,.battle_player[1],OSKEY_RIGHT,0,true)
					call BlzTriggerRegisterPlayerKeyEvent(.keypress,.battle_player[1],OSKEY_Z,0,true)
					call BlzTriggerRegisterPlayerKeyEvent(.keypress,.battle_player[1],OSKEY_X,0,true)
					call BlzTriggerRegisterPlayerKeyEvent(.keypress,.battle_player[1],OSKEY_A,0,true)
					call BlzTriggerRegisterPlayerKeyEvent(.keypress,.battle_player[1],OSKEY_S,0,true)
				endif
				set .init_stage = .init_stage + 1
				call Timer.start(GetExpiredTimer(),INIT_DELAY2,false,function thistype.delayedInit)
			elseif .init_stage == 1 then
				call readyPhase()
			endif
		endmethod

		method killMonster takes nothing returns nothing
			if .field != 0 and .monster_character != 0 then
				call .field.removeMonster(.monster_character)
			endif
		endmethod

		method battleResult takes nothing returns boolean
			return BATTLE_MONSTER_REMAINING_1P > BATTLE_MONSTER_REMAINING_2P
		endmethod

		private method startCharacters takes nothing returns nothing
			if .player_character1 != 0 then
				call .player_character1.startWorkTimer()
				set .player_character1.onbattle = false
				set .player_character1.encounter_ignore = ENCOUNTER_IGNORE
				call .player_character1.setAlpha(128)
			endif
			if .player_character2 != 0 then
				call .player_character2.startWorkTimer()
				set .player_character2.onbattle = false
				set .player_character2.encounter_ignore = ENCOUNTER_IGNORE
				call .player_character2.setAlpha(128)
			endif
			if .monster_character != 0 then
				call .monster_character.startWorkTimer()
				set .monster_character.onbattle = false
				set .monster_character.target_character = 0
			endif
		endmethod

		private method pauseCharacters takes nothing returns nothing
			if .player_character1 != 0 then
				call .player_character1.pauseWorkTimer()
				set .player_character1.onbattle = true
			endif
			if .player_character2 != 0 then
				call .player_character2.pauseWorkTimer()
				set .player_character2.onbattle = true
			endif
			if .monster_character != 0 then
				call .monster_character.pauseWorkTimer()
				set .monster_character.onbattle = true
			endif
		endmethod

		private method initialize takes nothing returns nothing
			local integer i = 0
			local integer j = 0
			local integer k = 0
			local Monster m = 0
			local Profile pr = 0
			local BattleMonster bm = 0
			local integer front = 0
			local integer back = 0
			/*배틀존 점유*/
			loop
				exitwhen i >= 4
				if not OCCUPIED[i] then
					set .slot = i
					set OCCUPIED[i] = true
					exitwhen true
				endif
				set i = i + 1
			endloop
			/*페이드인*/
			call FadeIn.create("ui\\ui_trans1.mdl",INIT_DELAY1+INIT_DELAY2,.battle_player[0])
			call FadeIn.create("ui\\ui_trans1.mdl",INIT_DELAY1+INIT_DELAY2,.battle_player[1])
			/*전투시작 효과음 출력*/
			if GetLocalPlayer() == .battle_player[0] or GetLocalPlayer() == .battle_player[1] then
				call PlaySoundBJ(gg_snd_ArrangedTeamInvitation)
			endif
			/*배경 생성*/
			set .bg = Effect.create(field.model,GetRectCenterX(RECT[.slot]),GetRectCenterY(RECT[.slot]),0,270)
			/*캐릭터 정지*/
			call pauseCharacters()
			/*프로필 UI 숨기기*/
			if .battle_player[0] != null then
				call Profile.getPlayerProfile(.battle_player[0]).setState(1)
			endif
			if .battle_player[1] != null then
				call Profile.getPlayerProfile(.battle_player[1]).setState(1)
			endif
			/*몬스터 배열 초기화*/
			set i = 0
			loop
				exitwhen i >= BATTLE_MONSTER_PER_BATTLE
				set .battle_monster[i] = 0
				set i = i + 1
			endloop
			/*야생몹과 조우시 임시 파티*/
			if .monster_character != 0 then
				call Party.clearTemp()
				call Party.addMonster(0,Monster.create(.monster_character.monster_id))
			endif
			/*파티에서 배틀몬스터 복사*/
			set k = 0
			loop
				exitwhen k >= 2
				set i = 0
				set j = 0
				set front = 0
				set back = 0
				loop
					exitwhen i >= BATTLE_MONSTER_PER_PLAYER
					/*프로필에서 파티 가져오기*/
					set pr = Profile.getPlayerProfile(.battle_player[k])
					set bm = 0
					if pr != 0 then
						set m = Party.getMonster(pr,i)
						if m != 0 and m.alive then
							set .battle_monster[j+(k*BATTLE_MONSTER_PER_PLAYER)] = BattleMonster.create(m,.battle_player[k])
							set bm = .battle_monster[j+(k*BATTLE_MONSTER_PER_PLAYER)]
							set j = j + 1
						endif
					else
						/*야생몹과 조우했을때*/
						set m = Party.getMonster(0,i)
						if m != 0 then
							set .battle_monster[j+(k*BATTLE_MONSTER_PER_PLAYER)] = BattleMonster.create(m,.battle_player[k])
							set bm = .battle_monster[j+(k*BATTLE_MONSTER_PER_PLAYER)]
							call .battle_monster[j+(k*BATTLE_MONSTER_PER_PLAYER)].setLevel(GetRandomInt(.field.level_min,.field.level_max))
							set j = j + 1
						endif
					endif
					if bm != 0 then
						/*마지막으로 배치된 배틀몬스터가 전위인지 후위인지 계수*/
						if bm.front then
							set front = front + 1
						else
							set back = back + 1
						endif
					endif
					set i = i + 1
				endloop
				set i = 0
				loop
					exitwhen i >= j 
					/*가져온 파티캐릭터의 좌표설정*/
					set bm = .battle_monster[i+(k*BATTLE_MONSTER_PER_PLAYER)]
					if bm != 0 then
						if bm.front then
							call bm.effect.setPosition(/*
								*/Math.pPX(GetRectCenterX(RECT[.slot])+X_OFFSET_FROM_CENTER[k],((i+1)*((FORMATION_WIDTH)/(front+1)))-(FORMATION_WIDTH/2),FACING[k]-90.),/*
								*/Math.pPY(GetRectCenterY(RECT[.slot])+Y_OFFSET_FROM_CENTER[k],((i+1)*((FORMATION_WIDTH)/(front+1)))-(FORMATION_WIDTH/2),FACING[k]-90.),/*
							*/Z_OFFSET)
						else
							call bm.effect.setPosition(/*
								*/Math.pPX(GetRectCenterX(RECT[.slot])+1.25*X_OFFSET_FROM_CENTER[k],(((i+1)*FORMATION_WIDTH)/(back+1))-(FORMATION_WIDTH/2),FACING[k]-90.),/*
								*/Math.pPY(GetRectCenterY(RECT[.slot])+1.25*Y_OFFSET_FROM_CENTER[k],(((i+1)*FORMATION_WIDTH)/(back+1))-(FORMATION_WIDTH/2),FACING[k]-90.),/*
							*/Z_OFFSET)
						endif
						call bm.effect.setYaw(FACING[k])
						call bm.effect.setTeamColor(Player(PLAYER_NEUTRAL_AGGRESSIVE))
						if .battle_player[k] != null then
							call bm.effect.setTeamColor(.battle_player[k])
						endif
					endif
					set i = i + 1
				endloop
				set k = k + 1
			endloop
			/*액터 리퀘스트 배열 첫번째 자리를 -1로 초기화*/
			call setMonsterAbilityActorRequest(0,-1)
			/*초기화 타이머 작동*/
			set .main_timer = Timer.new(this)
			set .end_timer	= Timer.new(this)
			call Timer.start(.main_timer,INIT_DELAY1,false,function thistype.delayedInit)
		endmethod

		static method createPVP takes player p1, player p2 returns thistype
			local thistype this = allocate()
			set .player_character1 = PlayerCharacter.getPlayerCharacter(p1)
			set .player_character2 = PlayerCharacter.getPlayerCharacter(p2)
			set .battle_player[0] = p1
			set .battle_player[1] = p2
			set .effect1 = Effect.create(EFFECT_PATH,.player_character1.getX(),.player_character1.getY(),.player_character1.getZ()+EFFECT_Z_OFFSET,270)
			set .effect2 = Effect.create(EFFECT_PATH,.player_character2.getX(),.player_character2.getY(),.player_character2.getZ()+EFFECT_Z_OFFSET,270)
			call initialize()
			return this
		endmethod

		static method create takes PlayerCharacter pc, MonsterCharacter mc, Field f returns thistype
			/*배틀 초기화*/
			local thistype this = allocate()
			set .player_character1 	= pc
			set .monster_character 	= mc
			set .field 				= f
			set .battle_player[0]				= pc.owner
			set .battle_player[1]				= null
			set .effect1 = Effect.create(EFFECT_PATH,.player_character1.getX(),.player_character1.getY(),.player_character1.getZ()+EFFECT_Z_OFFSET,270)
			set .effect2 = Effect.create(EFFECT_PATH,.monster_character.getX(),.monster_character.getY(),.monster_character.getZ()+EFFECT_Z_OFFSET,270)
			call initialize()
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			/*소멸자*/
			local Profile pr = 0
			local Monster m = 0
			local integer i = 0
			local boolean pvp = false
			set OCCUPIED[.slot] = false
			/*지형 다시보이기*/
			if GetLocalPlayer() == .battle_player[0] or GetLocalPlayer() == .battle_player[1] then
				call BlzShowTerrain(true)
			endif
			/*카메라 원상복구*/
			if .battle_player[0] != null then
				set pr = Profile.getPlayerProfile(.battle_player[0])
				set pr.cam_current = gg_cam_DEFAULT
				call pr.pauseCamTimer()
				call pr.startCamTimer()
			endif
			if .battle_player[1] != null then
				set pr = Profile.getPlayerProfile(.battle_player[1])
				set pr.cam_current = gg_cam_DEFAULT
				call pr.pauseCamTimer()
				call pr.startCamTimer()
			endif
			/**/
			set pvp = .battle_player[0] != null and .battle_player[1] != null
			if pvp then
				/*PVP*/
			else
				/*몬스터*/
				if battleResult() then
					/*승리 시*/
					call killMonster()
				else
					/*패배 시*/
					call PlayerCharacter.getPlayerCharacter(.battle_player[0]).move(GetRectCenterX(gg_rct_spawn),GetRectCenterY(gg_rct_spawn),0.)
				endif
			endif
			/*배틀몬스터 제거*/
			set i = 0
			loop
				exitwhen i >= BATTLE_MONSTER_PER_BATTLE
				if .battle_monster[i] != 0 then
					set .battle_monster[i].origin_monster.onbattle = false
					/*야생몹과의 배틀이면 체력상태 보존& 경험치 주기*/
					if not pvp and i < BATTLE_MONSTER_PER_PLAYER then
						if .battle_monster[i].origin_monster != 0 then
							set .battle_monster[i].origin_monster.alive = .battle_monster[i].alive
							set .battle_monster[i].origin_monster.hp = .battle_monster[i].origin_monster.getBaseStat(STAT_TYPE_MAXHP) * (.battle_monster[i].hp/.battle_monster[i].getCarculatedStat(STAT_TYPE_MAXHP))
							if battleResult() then
								/*이겼을 때만 경험치 주기*/
								call .battle_monster[i].origin_monster.addExp(.field.level_max*7)
							else
								/*야생몹한테 패배 시 몬스터 부활*/
								set .battle_monster[i].origin_monster.alive = true
								set .battle_monster[i].origin_monster.hp = 1
							endif
						endif
					endif
					call .battle_monster[i].destroy()
				endif
				set i = i + 1
			endloop
			/*리퀘스트 클리어*/
			set i = 0
			loop
				exitwhen i >= ACTOR_REQUEST_SIZE
				if getMonsterAbilityActorRequest(i) == -1 then
					exitwhen true
				else
					call getMonsterAbilityActorRequest(i).destroy()
					call setMonsterAbilityActorRequest(i,0)
				endif
				set i = i + 1
			endloop
			/*얼음땡 해주기*/
			call startCharacters()
			/*이펙트 킬*/
			call .effect1.kill()
			call .effect2.kill()
			call .bg.kill()
			/*배틀UI 제거*/
			if .battle_ui[0] != 0 then
				call .battle_ui[0].destroy()
			endif
			if .battle_ui[1] != 0 then
				call .battle_ui[1].destroy()
			endif
			/*프로필 UI 다시 보여주기*/
			if .battle_player[0] != null then
				call Profile.getPlayerProfile(.battle_player[0]).setState(0)
			endif
			if .battle_player[1] != null then
				call Profile.getPlayerProfile(.battle_player[1]).setState(0)
			endif
			/*타이머제거*/
			call Timer.release(.main_timer)
			call Timer.release(.end_timer)
			/*트리거 제거*/
			call Trigger.remove(.keypress)
			/*핸들프리*/
			set .battle_player[0] = null
			set .battle_player[1] = null
			set .main_timer		= null
			set .end_timer		= null
			set .keypress = null
			/**/
		endmethod

		private static method battleRequest takes nothing returns nothing
			call create(BattleRequest.EVENT_PLAYER_CHARACTER,BattleRequest.EVENT_MONSTER_CHARACTER,BattleRequest.EVENT_FIELD)
		endmethod

		private static method onInit takes nothing returns nothing
			call TriggerAddAction(BattleRequest.REQUEST_TRIGGER, function thistype.battleRequest)
			set RECT[0] 		= gg_rct_BattleSpace1
			set RECT[1] 		= gg_rct_BattleSpace2
			set RECT[2] 		= gg_rct_BattleSpace3
			set RECT[3] 		= gg_rct_BattleSpace4
			set OCCUPIED[0]	= false
			set OCCUPIED[1]	= false
			set OCCUPIED[2]	= false
			set OCCUPIED[3]	= false
			set X_OFFSET_FROM_CENTER[0] = -350.
			set Y_OFFSET_FROM_CENTER[0] = 0.
			set X_OFFSET_FROM_CENTER[1] = 350.
			set Y_OFFSET_FROM_CENTER[1] = 0.
			set FACING[0] = 0.
			set FACING[1] = 180.
		endmethod

	endstruct

endlibrary