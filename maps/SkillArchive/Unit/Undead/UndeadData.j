library UndeadData

	/* U000: 구울 */ 
	//! runtextmacro undeadHeader("U000")
		method periodicAction takes nothing returns nothing
			local Ability a = 0
			local real dist = 0.
			if getTarget() > 0 then
				set dist = Math.distancePoints(.x,.y,.target.x,.target.y)
				set a = getAbility(0)
				if a.count > 0 and dist <= a.cast_range and dist > 100. then
					set a.ai_target = .target.origin_unit
					if a.pressRequest() then
						return
					endif
				endif
				set a = getAbility(1)
				if a.count > 0 and dist <= .attack_range + 100. then
					if a.pressRequest() then
						return
					endif
				endif
				set a = getAbility(0)
				if a.count > 0 and dist <= a.cast_range then
					set a.ai_target = .target.origin_unit
					if a.pressRequest() then
						return
					endif
				endif
			endif
		endmethod
	//! runtextmacro undeadEnd()

	/* U001: 핀드 */ 
	//! runtextmacro undeadHeader("U001")
		method init takes nothing returns nothing
			set .acquire_range = 750.
		endmethod
	//! runtextmacro undeadEnd()

	/* U002: 가고일 */ 
	//! runtextmacro undeadHeader("U002")
		method init takes nothing returns nothing
			set .acquire_range = 750.
		endmethod
	//! runtextmacro undeadEnd()

	/* U003: 강령술사 */ 
	//! runtextmacro undeadHeader("U003")
		method init takes nothing returns nothing
			set .acquire_range = 750.
		endmethod
	//! runtextmacro undeadEnd()

	/* U004: 누더기골렘 */ 
	//! runtextmacro undeadHeader("U004")

	//! runtextmacro undeadEnd()

endlibrary