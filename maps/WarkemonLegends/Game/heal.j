library Heal requires Profile

	struct Heal

		private static constant real HEAL_RANGE = 300.
		private static constant real HEAL_TICK = 0.3
		private static constant real HEAL_PER_SECOND = 0.125
	
		timer main_timer = null
		Effect effect = 0

		private static method timerAction takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			local integer i = 0
			local Profile pr = 0
			local Monster m = 0
			local integer j = 0
			loop
				exitwhen i >= bj_MAX_PLAYERS
				set pr = Profile.getPlayerProfile(Player(i))
				if pr != 0 and Math.distancePoints(.effect.getX(),.effect.getY(),pr.character.getX(),pr.character.getY()) <= HEAL_RANGE then
					set j = 0
					loop
						exitwhen j >= Party.INDEX_STORAGE
						set m = Party.getMonster(pr,j)
						if m != 0 then
							if not m.alive then
								set m.alive = true
							endif
							if m.hp < m.getBaseStat(STAT_TYPE_MAXHP) then
								set m.hp = m.hp + (m.getBaseStat(STAT_TYPE_MAXHP) * HEAL_PER_SECOND * HEAL_TICK)
								call pr.party_ui.healEffect(j)
								if m.hp > m.getBaseStat(STAT_TYPE_MAXHP) then
									set m.hp = m.getBaseStat(STAT_TYPE_MAXHP)
								endif
							endif
						endif
						set j = j + 1
					endloop
					call pr.party_ui.refresh()
				endif
				set i = i + 1
			endloop
		endmethod

		static method create takes real x, real y returns thistype
			local thistype this = allocate()
			set .effect = Effect.create("buildings\\other\\FountainOfLife\\FountainOfHealth.mdl",x,y,0,270.)
			set .main_timer = Timer.new(this)
			call Timer.start(.main_timer,HEAL_TICK,true,function thistype.timerAction)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call Timer.release(.main_timer)
			set .main_timer = null
			call effect.kill()
		endmethod

		static method init takes nothing returns nothing
			call create(GetRectCenterX(gg_rct_Heal),GetRectCenterY(gg_rct_Heal))
		endmethod

	endstruct

endlibrary