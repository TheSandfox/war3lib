library ItemEx requires Item
globals 
	player ITEM_EVENT_BUYING_PLAYER = null
endglobals
struct ItemEx extends Item

	static constant integer ZAERYO = 200
	static constant integer ZAERYO_COUNT = 300

	static method setTypeZaeryo takes integer iid, integer index, integer zid returns nothing
		call SaveInteger(HASH,iid,ZAERYO+index,zid)
		call SaveInteger(HASH,iid,ZAERYO_COUNT+index,1)
		call SaveInteger(HASH,iid,ZAERYO+index+1,-1)
	endmethod

	static method getTypeZaeryo takes integer iid, integer index returns integer
		return LoadInteger(HASH,iid,ZAERYO+index)
	endmethod

	static method setTypeZaeryoCount takes integer iid, integer index, integer count returns nothing
		call SaveInteger(HASH,iid,ZAERYO_COUNT+index,count)
	endmethod

	static method getTypeZaeryoCount takes integer iid, integer index returns integer
		return LoadInteger(HASH,iid,ZAERYO_COUNT+index)
	endmethod

	static method zohabRequest takes integer iid, player p returns nothing
		local integer i = 0
		local Inventory myinv = Inventory.getByPlayer(p)
		local Item it = 0
		set ITEM_EVENT_BUYING_PLAYER = p
		/*인벤토리 유무 확인*/
		if myinv <= 0 then
			/*인벤토리가 없음*/
			return
		endif
		/*가방에 공간이 있습니까?*/
		if myinv.getSpace() == -1 then
			/*인벤토리에 공간이 없음*/
			return 
		endif
		/*조합재료탐색*/
		loop
			exitwhen getTypeZaeryo(iid,i) == -1
			set it = getItemByType(getTypeZaeryo(iid,i),0,myinv)
			if it == 0 then
				/*필요 재료를 가지고 있지 않음*/
				return
			elseif it.count < getTypeZaeryoCount(iid,i) then
				/*재료의 갯수가 모자람*/
				return
			endif
			set i = i + 1	
		endloop
		/*재료가 전부 있음*/
		set i = 0
		loop
			exitwhen getTypeZaeryo(iid,i) == -1
			set it = getItemByType(getTypeZaeryo(iid,i),0,myinv)
			call it.setCount(it.count-getTypeZaeryoCount(iid,i))
			set i = i + 1
		endloop
		set ITEM_EVENT_ITEM_ID = iid
		call TriggerEvaluate(BUY)
		/**/
		set ITEM_EVENT_BUYING_PLAYER = null
	endmethod

endstruct
endlibrary

//! textmacro newItemHeader takes key
	
library $key$
	
	globals
		private constant integer IID = '$key$'
	endglobals
//! endtextmacro 
//! textmacro registBuyEvent
	static method create takes Unit owner returns thistype
		local thistype this = allocate(IID)
		local integer i = 0
		call onCreate()
		if not goToUnit(owner) then
			call goToInventory(Inventory.getByPlayer(owner.getOwner()))
		endif
		return this
	endmethod

	static method createAtInventory takes Inventory inv returns thistype
		local thistype this = allocate(IID)
		call onCreate()
		call goToInventory(inv)
		return this
	endmethod

	static method add takes nothing returns boolean
		if ITEM_EVENT_ITEM_ID == IID then
			call createAtInventory(Inventory.getByPlayer(ITEM_EVENT_BUYING_PLAYER))
		endif
		return true
	endmethod

	private static method onInit takes nothing returns nothing
		call TriggerAddCondition(Item.BUY,Condition(function thistype.add))
		call initValue()
	endmethod
//! endtextmacro
//! textmacro newItemEnd
endlibrary
//! endtextmacro
//! textmacro itemHeader
	public struct main extends ItemEx
//! endtextmacro
//! textmacro itemEnd
	endstruct
//! endtextmacro