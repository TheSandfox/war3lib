library test initializer init

	globals
		item ITEM = null
		unit UNIT = null
		trigger TRIG = null
	endglobals
	
	private function cond takes nothing returns nothing
		call BlzSetItemName(ITEM,"야호크크루삥뽕")
		call BlzSetItemTooltip(ITEM,"야호크크루삥뽕")
		call BlzSetItemStringField(ITEM,ConvertItemStringField('unam'),"야호크크루삥뽕")
		call BlzSetItemStringField(ITEM,ConvertItemStringField('utip'),"야호크크루삥뽕")
	endfunction
	
	private function init takes nothing returns nothing
		set ITEM = CreateItem('gcel',0,0)
		call BlzSetItemName(ITEM,"야호크크루삥뽕")
		call BlzSetItemTooltip(ITEM,"야호크크루삥뽕")
		call BlzSetItemDescription(ITEM,"야호크크루삥뽕")
		call BlzSetItemExtendedTooltip(ITEM,"야호크크루삥뽕")
		call BlzSetItemStringField(ITEM,ConvertItemStringField('unam'),"야호크크루삥뽕")
		call BlzSetItemStringField(ITEM,ConvertItemStringField('utip'),"야호크크루삥뽕")
		set UNIT = CreateUnit(Player(0),'Hpal',0,0,270)
		call UnitAddItem(UNIT,ITEM)
		call UnitDropItemPoint(UNIT,ITEM,50,50)
		set TRIG = CreateTrigger()
		call TriggerRegisterTimerEvent(TRIG,0.1,false)
		call TriggerAddCondition(TRIG,function cond)
		
	endfunction
endlibrary