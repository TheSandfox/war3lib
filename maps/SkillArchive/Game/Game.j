//! import "Camera.j"
//! import "ConstantString.j"
//! import "Tip.j"
//! import "CharacterSelect.j"
//! import "Wave.j"
//! import "Guardians.j"
//! import "Round.j"
//! import "TreeOfLife.j"

library Game requires Unit, UI

	globals
		constant boolean TEST = true

		player PLAYER_UNDEAD = Player(20)
		player PLAYER_MONSTER = Player(23)
		player PLAYER_GUARDIANS = Player(21)
		player PLAYER_SYSTEM = Player(24)

		private trigger LEAVE_TRIGGER = CreateTrigger()
		
	endglobals

	struct Game

		/*TEST ONLY*/
		private static method spawnDummy takes nothing returns nothing
			local integer i = 0
			local Unit u = 0
			loop
				exitwhen i >= 10
				set u = Unit.create(PLAYER_UNDEAD,'HR00',1024,0,0)
				call u.plusStatus(STATUS_CAST)
				//call u.plusStatValue(STAT_TYPE_HPREGEN,100.)
				set i = i + 1
			endloop
		endmethod

		static method playerLeave takes nothing returns nothing
			if SkillShop.THIS[GetPlayerId(GetTriggerPlayer())] > 0 then
				call SkillShop.THIS[GetPlayerId(GetTriggerPlayer())].destroy()
			endif
			if UI.THIS[GetPlayerId(GetTriggerPlayer())] > 0 then
				call UI.THIS[GetPlayerId(GetTriggerPlayer())].destroy()
			endif
			if SlotChanger.THIS[GetPlayerId(GetTriggerPlayer())] > 0 then
				call SlotChanger.THIS[GetPlayerId(GetTriggerPlayer())].destroy()
			endif
			if Inventory.THIS[GetPlayerId(GetTriggerPlayer())] > 0 then
				call Inventory.THIS[GetPlayerId(GetTriggerPlayer())].destroy()
			endif
			if User.getFocusUnit(GetTriggerPlayer()) > 0 then
				set User.getFocusUnit(GetTriggerPlayer()).is_revive = false
				call User.setFocusUnit(GetTriggerPlayer(),0)
			endif
		endmethod

		static method defeat takes nothing returns nothing
			local integer i = 0
			local Unit u = 0
			set Tombstone.GAME_OVER = true
			call Guardians.kill()
			loop
				exitwhen i >= 4
				set u = User.getFocusUnit(Player(i))
				call u.kill()
				set u.hp = 1.
				set i = i + 1
			endloop
			call Timer.pause(Round.TIMER)
		endmethod

		static method systemMessage takes string msg returns nothing
			call BlzDisplayChatMessage(PLAYER_SYSTEM,0,msg)
		endmethod

		static method addLevel takes nothing returns nothing
			local integer i = 0
			local Unit u = 0
			loop
				exitwhen i >= 4
				call User.addGold(Player(i),5)
				set u = User.getFocusUnit(Player(i))
				call Effect.createAttatched("Abilities\\Spells\\Other\\Levelup\\LevelupCaster.mdl",u.origin_unit,"origin").setDuration(1.5)
				if u > 0 then
					set u.level = u.level + 1
				endif
				set i = i + 1
			endloop
		endmethod

		private static method initForPlayer takes player p, integer uid, integer chingho returns nothing
			local Unit u = Unit.create(p,uid,Math.pPX(GetRectCenterX(gg_rct_spawn),512,GetRandomReal(235,315)),Math.pPY(GetRectCenterY(gg_rct_spawn),512,GetRandomReal(235,315)),270.)
			set u.is_revive = true
			/*카메라*/
			call FixCamSetup(p,gg_cam_Cam00,true)
			call FixCamResetPosition(p)
			call PanCameraToForPlayer(p,u.x,u.y)
			/*마우스 리프레셔 작동*/
			call Mouse.activateRefresher(p)
			/*프로필 초기화*/
			call User.new(p)
			call User.setFocusUnit(p,u)
			call User.selectFocusUnit(p)
			/*칭호 추가*/
			call u.setChingho(chingho)
			/*메인 UI*/
			call UI.create(p)
			call SkillShop.create(p)
			call SlotChanger.create(p)
			call CloseUI.create(p)
			call Inventory.create(p)
			/*초기소지금*/
			if TEST then
				call User.addGold(p,5000)
			else
				call User.addGold(p,5)
			endif
			set u.level = 5
		endmethod

		static method endSelect takes nothing returns nothing
			local integer i = 0
			/*꿀팁 활성화*/
			call Tip.init()
			/*프레임관련*/
			call UI.init()
			/*플레이어별 초기화*/
			loop
				exitwhen i >= PLAYER_MAX
				if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(i)) == MAP_CONTROL_USER then
					call initForPlayer(Player(i),CharacterSelect_ID[i],CharacterSelect_CHINGHO_ID[i])
					call TriggerRegisterPlayerEventLeave(LEAVE_TRIGGER,Player(i))
				endif
				set i = i + 1
			endloop
			/*생명의 나무*/
			call TreeOfLife.init()
			/*수호자 초기화*/
			call Guardians.init()
			/*웨이브 가동*/
			call Round.init()
			/*상호작용물*/
			call Interactive.init()
			/*탈주트리거*/
			call TriggerAddCondition(LEAVE_TRIGGER,function thistype.playerLeave)
		endmethod

		private static method start takes nothing returns nothing
			local Unit u = 0
			local trigger t = null
			local integer i = 0
			if TEST then
				/*꿀팁 활성화*/
				//call Tip.init()
				/*프레임관련*/
				call UI.init()
				/*플레이어별 초기화*/
				call initForPlayer(Player(0),'U000','C000')
				//call initForPlayer(Player(1),'HR09','C000')
				/*생명의 나무*/
				call TreeOfLife.init()
				/*/*수호자 초기화*/
				call Guardians.init()
				/*웨이브 가동*/
				call Round.init()*/
				/*상호작용물*/
				call Interactive.init()
				/*임시*/
				call spawnDummy()
				call SkillShop.THIS[0].setLevel(10)
				set t = CreateTrigger()
				call BlzTriggerRegisterPlayerKeyEvent(t,Player(0),OSKEY_O,0,true)
				call TriggerAddCondition(t,function thistype.spawnDummy)
				/**/
			else
				/*캐릭터셀렉트*/
				call CharacterSelect.init()
			endif
			call DestroyTrigger(GetTriggeringTrigger())
			set t = null
		endmethod

		static method initAlly takes nothing returns nothing
			local integer i = 0
			loop
				exitwhen i >= PLAYER_MAX
				call SetPlayerAllianceStateBJ(Player(i),PLAYER_GUARDIANS,bj_ALLIANCE_ALLIED_VISION)
				call SetPlayerAllianceStateBJ(PLAYER_GUARDIANS,Player(i),bj_ALLIANCE_ALLIED_VISION)
				set i = i + 1
			endloop
			call SetPlayerAllianceStateBJ(PLAYER_MONSTER,PLAYER_UNDEAD,bj_ALLIANCE_ALLIED_VISION)
			call SetPlayerAllianceStateBJ(PLAYER_UNDEAD,PLAYER_MONSTER,bj_ALLIANCE_ALLIED_VISION)
		endmethod

		private static method onInit takes nothing returns nothing
			/*시간차 init*/
			local trigger t = CreateTrigger()
			call TriggerRegisterTimerEvent(t,0.5,false)
			call TriggerAddAction(t,function thistype.start)
			/*기본 게임설정*/
			call BlzLoadTOCFile("ui\\framedef\\myframes\\MyFrames.toc")
			/*프레임 숨기기*/
			call BlzHideOriginFrames(true)
			call BlzFrameClearAllPoints(BlzGetFrameByName("ConsoleUIBackdrop",0))
			/*명령창 포인트 클리어*/
			call BlzFrameClearAllPoints(BlzGetFrameByName("CommandBarFrame",0))
			call BlzFrameClearAllPoints(BlzFrameGetParent(BlzGetFrameByName("CommandBarFrame",0)))
			/*디버그창*/
			call BlzFrameSetAbsPoint(BlzGetOriginFrame(ORIGIN_FRAME_UNIT_MSG,0),FRAMEPOINT_BOTTOMLEFT,0.,0.185)
			call BlzFrameSetSize(BlzGetOriginFrame(ORIGIN_FRAME_UNIT_MSG,0),1,1)
			/*채팅창 살리기*/
			call BlzFrameSetAbsPoint(BlzGetOriginFrame(ORIGIN_FRAME_CHAT_MSG,0),FRAMEPOINT_BOTTOMLEFT,0.,0.135)
			call BlzFrameSetSize(BlzGetOriginFrame(ORIGIN_FRAME_CHAT_MSG,0),1,1)
			/*유닛선택못하게*/
			call BlzEnableSelections(false,false)
			/*전장의 안개 끄기*/
			call FogMaskEnable(false)
			call FogEnable(false)
			/*시간 고정시키기*/
			call SetTimeOfDay(12.)
   			call SetTimeOfDayScalePercentBJ(0.)
			/*카메라*/
			call Camera.init()
			/*플레이어 이름 설정*/
			call SetPlayerName(PLAYER_GUARDIANS,"수호자")
			call SetPlayerName(PLAYER_MONSTER,"숲의 괴물들")
			call SetPlayerName(PLAYER_UNDEAD,"언데드 침략자")
			call SetPlayerName(PLAYER_SYSTEM,"|cffffcc00시스템|r")
			/*동맹설정*/
			call initAlly()
			/*백그라운드*/
			if not TEST then
				/*CreateBackground*/
				set CharacterSelect_BACKGROUND = BlzCreateFrameByType("SPRITE","",BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI,0),"",0)
				call BlzFrameSetModel(CharacterSelect_BACKGROUND,"ui\\characterselectbackground.mdl",0)
				call BlzFrameSetAbsPoint(CharacterSelect_BACKGROUND,FRAMEPOINT_BOTTOMLEFT,0.,0.)
				call BlzFrameSetSize(CharacterSelect_BACKGROUND,1,1)
			endif
			/**/
			set t = null
		endmethod

	endstruct

endlibrary