//! import "Heroes.j"
//! import "Creeps.j"

//! textmacro unitDataHeaderEx takes key
struct Data$key$ extends UnitDataEx
private static constant integer id = '$key$'
private static method onInit takes nothing returns nothing
//! endtextmacro

library UnitDataEx requires UnitData
struct UnitDataEx extends UnitData

	static constant integer BASICABILITY = 200
	static constant real BASESTAT_DEFAULT = 20
	static constant real LEVELSTAT_DEFAULT = 2

	static method setBasicAbility takes integer uid, integer index, integer aid returns nothing
		call SaveInteger(HASH,uid,BASICABILITY+index,aid)
	endmethod

	static method getBasicAbility takes integer uid, integer index returns integer
		return LoadInteger(HASH,uid,BASICABILITY+index)
	endmethod

endstruct
endlibrary

library UnitEx requires Unit
struct UnitEx extends Unit

	integer revive_remain = 0

	private static method reviveTimer takes nothing returns nothing
		local thistype this = Timer.getDataEx()
		if not isUnitType(UNIT_TYPE_DEAD) then
			set revive_remain = 0
			call Timer.release(GetExpiredTimer())
		else
			set revive_remain = revive_remain - 1
			if revive_remain <= 0 then
				call ReviveHero(getOrigin(),GetRectCenterX(gg_rct_spawn),GetRectCenterY(gg_rct_spawn),true)
				if GetLocalPlayer() == getOwner() then
					call SelectUnitSingle(getOrigin())
				endif
				call Timer.release(GetExpiredTimer())
			endif
		endif
	endmethod

	method onDeath takes nothing returns nothing
		local integer i = GetPlayerId(getOwner())
		local timer t = null
		if i >= 0 and i < PLAYER_MAX then
			set revive_remain = 20
			set t = Timer.new(this)
			call Timer.start(t,1.0,true,function thistype.reviveTimer)
		endif
		set t = null
	endmethod

	method dataLoadAdditional takes integer id returns nothing
		/*기본스킬 추가*/
		if UnitDataEx.getBasicAbility(id,0) != 0 then
			call Book_buyRequest(this,UnitDataEx.getBasicAbility(id,0),true)
		endif
		if UnitDataEx.getBasicAbility(id,1) != 0 then
			call Book_buyRequest(this,UnitDataEx.getBasicAbility(id,1),true)
		endif
	endmethod

	static method create takes player p, integer uid, real x, real y, real f returns thistype
		local thistype this = allocate(p,uid,x,y,f)
		call dataLoadAdditional(uid)
		return this
	endmethod

endstruct
endlibrary