library ItemPrototype

	globals
		public integer SIZE = 6 
		constant integer ERROR_CODE_ALREADY_EQUIPPED = 0
		constant integer ERROR_CODE_NO_SPACE = -1
		private hashtable HASH = InitHashtable()
		private constant integer INDEX_ORIGIN_HANDLE = 0
		private constant integer INDEX_INSTANCE_ID = 1
		private constant integer INDEX_MODEL_PATH = 2
		private trigger ITEM_GET_TRIGGER = CreateTrigger()

		player PLAYER_ITEM = null

		trigger ITEM_PICK_TRIGGER = CreateTrigger()
		integer ITEM_PICK_UNIT = 0
		integer ITEM_PICK_ITEM = 0
	endglobals

	struct Item_prototype

		effect origin_effect = null
		integer count = 1
		string icon = ""
		string name = ""
		integer id = 0
		integer index = -1
		Unit_prototype owner = 0

		static method setTypeModelPath takes integer iid, string path returns nothing
			call SaveStr(HASH,iid,INDEX_MODEL_PATH,path)
		endmethod

		static method getTypeModelPath takes integer iid returns string
			if HaveSavedString(HASH,iid,INDEX_MODEL_PATH) then
				return LoadStr(HASH,iid,INDEX_MODEL_PATH)
			else
				return "Objects\\InventoryItems\\TreasureChest\\treasurechest.mdl"
			endif
		endmethod

		method operator origin_item takes nothing returns unit
			if HaveSavedHandle(HASH,this,INDEX_ORIGIN_HANDLE) then
				return LoadUnitHandle(HASH,this,INDEX_ORIGIN_HANDLE)
			else
				return null
			endif
		endmethod

		method operator origin_item= takes unit it returns nothing
			if .origin_item != null then
				call RemoveSavedInteger(HASH,GetHandleId(.origin_item),INDEX_INSTANCE_ID)
				call RemoveUnit(.origin_item)
			endif
			if it == null then
				call RemoveSavedHandle(HASH,this,INDEX_ORIGIN_HANDLE)
			else
				call SaveUnitHandle(HASH,this,INDEX_ORIGIN_HANDLE,it)
				call SaveInteger(HASH,GetHandleId(it),INDEX_INSTANCE_ID,this)
			endif
		endmethod

		static method get takes unit it returns thistype
			if HaveSavedInteger(HASH,GetHandleId(it),INDEX_INSTANCE_ID) then
				return LoadInteger(HASH,GetHandleId(it),INDEX_INSTANCE_ID)
			else
				return 0
			endif
		endmethod

		stub method onEquip takes nothing returns nothing

		endmethod

		stub method onUnequip takes nothing returns nothing

		endmethod

		method equip takes Unit_prototype owner returns integer
			local integer i = 0
			if owner == .owner then
				/*이미 장비돼있음*/
				return ERROR_CODE_ALREADY_EQUIPPED
			endif
			set i = owner.getItemSpace()
			if i < 0 or i >= SIZE then
				/*공간부족*/
				return ERROR_CODE_NO_SPACE
			endif
			set .owner = owner
			call .owner.setItem(i,this)
			set .index = i
			call onEquip()
			return 1
		endmethod

		method unequip takes nothing returns nothing
			if .owner > 0 then
				call onUnequip()
				call .owner.setItem(.index,0)
			endif
			set .owner = 0
			set .index = -1
		endmethod

		stub method getDropName takes nothing returns string
			return .name
		endmethod

		method drop takes real x, real y returns nothing
			call unequip()
			set .origin_item = CreateUnit(PLAYER_ITEM,'idum',x,y,270.)
			call BlzSetUnitName(.origin_item,getDropName())
			call SetUnitVertexColor(.origin_item,0,0,0,0)
			set .origin_effect = AddSpecialEffect(getTypeModelPath(.id),x,y)
			call BlzSetSpecialEffectYaw(.origin_effect,Deg2Rad(270.))
		endmethod

		method pick takes Unit_prototype u returns nothing
			set .origin_item = null
			if .origin_effect != null then
				call DestroyEffect(.origin_effect)
			endif
			set .origin_effect = null
			set ITEM_PICK_UNIT = u
			set ITEM_PICK_ITEM = this
			call TriggerEvaluate(ITEM_PICK_TRIGGER)
		endmethod

		method onDestroy takes nothing returns nothing
			call unequip()
			if .origin_effect != null then
				call DestroyEffect(.origin_effect)
			endif
			set .origin_item = null
			set .origin_effect = null
		endmethod

		static method itemGet takes nothing returns nothing
			local thistype this = 0
			if GetSpellAbilityId() == 'Axx4' then
				set this = get(GetSpellTargetUnit())
				if this > 0 and Unit_prototype.get(GetTriggerUnit()) > 0 then
					call pick(Unit_prototype.get(GetTriggerUnit()))
				endif
				return
			elseif (GetIssuedOrderIdBJ() == String2OrderIdBJ("smart")) and GetOwningPlayer(GetOrderTargetUnit()) == PLAYER_ITEM then
				call IssueTargetOrder(GetTriggerUnit(),"absorb",GetOrderTargetUnit())
				return
			endif
		endmethod

		static method onInit takes nothing returns nothing
			call TriggerRegisterAnyUnitEventBJ(ITEM_GET_TRIGGER,EVENT_PLAYER_UNIT_SPELL_EFFECT)
			call TriggerRegisterAnyUnitEventBJ(ITEM_GET_TRIGGER,EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
			call TriggerAddCondition(ITEM_GET_TRIGGER,function thistype.itemGet)
		endmethod

	endstruct

endlibrary