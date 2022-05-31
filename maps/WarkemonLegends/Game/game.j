library Game requires SelectStartMonster, Field

	struct Game

		private static method delayedInit takes nothing returns nothing
			call DestroyTrigger(GetTriggeringTrigger())
			/*티오씨*/
			call BlzLoadTOCFile("ui\\framedef\\MyFrames.toc")
			/*몬스터 데이터 초기화*/
			call MonsterData.init()
			/*프로필 만들기*/
			if GetPlayerSlotState(Player(0)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(0)) == MAP_CONTROL_USER then
				call Profile.create(Player(0))
			endif
			if GetPlayerSlotState(Player(1)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(1)) == MAP_CONTROL_USER then
				call Profile.create(Player(1))
			endif
			if GetPlayerSlotState(Player(2)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(2)) == MAP_CONTROL_USER then
				call Profile.create(Player(2))
			endif
			if GetPlayerSlotState(Player(3)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(3)) == MAP_CONTROL_USER then
				call Profile.create(Player(3))
			endif
			/*필드 리젼 초기화*/
			call FieldRegion.init()
			/*몬스터필드 초기화*/
			call Field.initFields()
			/*회복지점*/
			call Heal.init()
			/*상성표*/
			call ElementTypeChart.init()
		endmethod

		private static method onInit takes nothing returns nothing
			local trigger delay = CreateTrigger()
			call TriggerRegisterTimerEvent(delay,0.25,false)
			call TriggerAddAction(delay,function thistype.delayedInit)
			/*미리보기*/
			call BlzChangeMinimapTerrainTex("preview.blp")
			/*마우스 숨기기*/
			call BlzEnableCursor(false)
			/*유닛선택못하게*/
			call BlzEnableSelections(false,false)
			/*프레임 숨기기*/
			call BlzHideOriginFrames(true)
			call BlzFrameClearAllPoints(BlzGetFrameByName("ConsoleUIBackdrop",0))
			/*전장의 안개 끄기*/
			call FogMaskEnable(false)
			call FogEnable(false)
			/*시간 고정시키기*/
			call SetTimeOfDay(12.)
   			call SetTimeOfDayScalePercentBJ(0.)
			set delay = null
		endmethod

	endstruct

endlibrary