library Tombstone

	struct Tombstone

		static boolean GAME_OVER = false
		static constant string EFFECT_PATH1 = "Doodads\\Northrend\\Props\\NorthrendTombstone\\NorthrendTombstone2.mdl"
		static constant string EFFECT_PATH2 = "Abilities\\Spells\\Orc\\Reincarnation\\ReincarnationTarget.mdl"
		static thistype array THIS
		static constant real TICK = 0.1
		static constant real HEAL_PER_SEC = 0.04

		Effect ef = 0
		Unit owner = 0
		timer main_timer = null
		framehandle text = null

		static method timerAction takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			local real val = 0.
			if GAME_OVER then
				set .owner.hp = 1.
				call BlzFrameSetText(.text,"|cffff0000∞|r")
				call BlzFrameSetScale(.text,2.0)
			else
				call .owner.restoreHP(.owner.maxhp*HEAL_PER_SEC*TICK)
				set val = (.owner.maxhp - .owner.hp) / ( (.owner.maxhp*HEAL_PER_SEC+.owner.hpregen)*.owner.getCarculatedStatValue(STAT_TYPE_HEAL_AMP) )
				call BlzFrameSetText(.text,"|cffff0000"+I2S(R2I(val)+1)+"|r")
			endif
		endmethod

		static method create takes Unit u returns thistype
			local thistype this = 0
			if not u.is_revive then
				return 0
			endif
			set this = allocate()
			set .owner = u
			set .ef = Effect.create(EFFECT_PATH1,.owner.x,.owner.y,0.,270.)
			set .main_timer = Timer.new(this)
			call Timer.start(.main_timer,TICK,true,function thistype.timerAction)
			set .text = BlzCreateFrame("MyTextLarge",FRAME_GAME_UI,0,0)
			call BlzFrameSetPoint(.text,FRAMEPOINT_CENTER,FRAME_PORTRAIT_BACKDROP,FRAMEPOINT_CENTER,0.,0.)
			call BlzFrameSetVisible(.text,GetLocalPlayer() == .owner.owner)
			set THIS[.owner] = this
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			local Effect eff = Effect.create(EFFECT_PATH2,.owner.x,.owner.y,0.,270.).setAnim(ANIM_TYPE_DEATH).setDuration(3.33)
			set eff.want_remove = true
			call Timer.release(.main_timer)
			set .main_timer = null
			set .ef.want_remove = true
			call .ef.destroy()
			set .ef = 0
			//! runtextmacro destroyFrame(".text")
			/**/
			set THIS[.owner] = 0
		endmethod

		static method death takes nothing returns nothing
			if DEATH_UNIT <= 0 then
				return
			endif
			if THIS[DEATH_UNIT] <= 0 then
				call create(DEATH_UNIT)
			endif
		endmethod

		static method revive takes nothing returns nothing
			if REVIVE_UNIT <= 0 then
				return
			endif
			if THIS[REVIVE_UNIT] > 0 then
				call THIS[REVIVE_UNIT].destroy()
			endif
		endmethod

		static method onInit takes nothing returns nothing
			call TriggerAddCondition(DEATH_TRIGGER,function thistype.death)
			call TriggerAddCondition(REVIVE_TRIGGER,function thistype.revive)
		endmethod

	endstruct

endlibrary