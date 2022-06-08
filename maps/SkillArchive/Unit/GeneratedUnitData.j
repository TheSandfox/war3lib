scope UnitHR00 initializer init
//! runtextmacro unitDataHeader("HR00","BTNFootman")
	call UnitData.setInitialAbility(0,'0000')
	call UnitData.setInitialAbility(1,'0013')
//! runtextmacro unitDataEnd()
endscope

scope UnitHR09 initializer init
//! runtextmacro unitDataHeader("HR09","BTNVillagerMan1")
	call UnitData.setInitialAbility(0,'0006')
	call UnitData.setInitialAbility(1,'0014')
//! runtextmacro unitDataEnd()
endscope

scope UnitHR07 initializer init
//! runtextmacro unitDataHeader("HR07","BTNAssassin")
	call UnitData.setInitialAbility(0,'0007')
	call UnitData.setInitialAbility(1,'0016')
//! runtextmacro unitDataEnd()
endscope

scope UnitG000 initializer init
//! runtextmacro unitDataHeader("G000","BTNArmorGolem")
	call UnitData.setInitialAbility(0,'0000')
	call UnitData.setInitialAbility(1,'0009')
//! runtextmacro unitDataEnd()
endscope

scope UnitG001 initializer init
//! runtextmacro unitDataHeader("G001","BTNTreeOfEternity")
	call UnitData.setStatValue(STAT_TYPE_MAXHP,	10000.,	1000.)
	call UnitData.setStatValue(STAT_TYPE_HPREGEN,	40.,	4.)
//! runtextmacro unitDataEnd()
endscope

scope UnitU000 initializer init
//! runtextmacro unitDataHeader("U000","BTNGhoul")
	call UnitData.setInitialAbility(0,'u000')
	call UnitData.setInitialAbility(1,'u010')
//! runtextmacro unitDataEnd()
endscope

scope UnitU001 initializer init
//! runtextmacro unitDataHeader("U001","BTNCryptFiend")
	call UnitData.setInitialAbility(0,'u001')
//! runtextmacro unitDataEnd()
endscope

scope UnitU002 initializer init
//! runtextmacro unitDataHeader("U002","BTNGargoyle")
	//call UnitData.setInitialAbility(0,'u001')
//! runtextmacro unitDataEnd()
endscope

scope UnitU003 initializer init
//! runtextmacro unitDataHeader("U003","BTNNecromancer")
	//call UnitData.setInitialAbility(0,'u001')
//! runtextmacro unitDataEnd()
endscope

scope UnitU004 initializer init
//! runtextmacro unitDataHeader("U004","BTNAbomination")
	call UnitData.setInitialAbility(0,'u011')
//! runtextmacro unitDataEnd()
endscope