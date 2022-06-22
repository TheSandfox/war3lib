library ItemPrototype

	globals
		public integer SIZE = 6 
		constant integer ERROR_CODE_ALREADY_EQUIPPED = 0
		constant integer ERROR_CODE_NO_SPACE = -1
	endglobals

	struct Item_prototype

		string icon = ""
		string name = ""
		integer id = 0
		integer index = -1
		Unit_prototype owner = 0

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

		method onDestroy takes nothing returns nothing
			call unequip()
		endmethod

	endstruct

endlibrary