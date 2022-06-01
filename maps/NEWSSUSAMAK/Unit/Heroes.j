library UnitHRxx //더미
	//! runtextmacro unitDataHeaderEx("HRxx")
		call setModelPath(id,"Units\\human\\Footman\\Footman.mdl")
		call setIconPath(id,"ReplaceableTextures\\CommandButtons\\BTNFootman.blp")
		call setValue(id,BASE_ATK,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_ATK,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_DEF,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_DEF,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_MAG,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_MAG,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_RES,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_RES,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_ACC,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_ACC,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_EVA,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_EVA,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_MAXHP,BASESTAT_DEFAULT*10		+8544)
		call setValue(id,LEVEL_MAXHP,LEVELSTAT_DEFAULT*10)
		call setValue(id,BASE_MAXMP,BASESTAT_DEFAULT*5)
		call setValue(id,LEVEL_MAXMP,LEVELSTAT_DEFAULT*5)
		call setValue(id,BASE_HPR,BASESTAT_DEFAULT/10		+45)
		call setValue(id,LEVEL_HPR,LEVELSTAT_DEFAULT/10)
		call setValue(id,BASE_MPR,BASESTAT_DEFAULT/10)
		call setValue(id,LEVEL_MPR,LEVELSTAT_DEFAULT/10)
		call setValue(id,BASE_HEIGHT,0)
		call setValue(id,BASE_MS,1)
		call setValue(id,LEVEL_MS,0)
		call setValue(id,SCALE,1.8)
		call setValue(id,ATTACKDELAY,1.5)
		call setValue(id,RANGE,150)
		call setWeapontype(id,5)
		call setValue(id,ATTACKANIMSPEED,1.)
		call setResourceType(id,RESOURCE_TYPE_MANA)
	//! runtextmacro unitDataEnd()
endlibrary

library UnitHR00 //풋맨
	//! runtextmacro unitDataHeaderEx("HR00")
		call setModelPath(id,"Units\\human\\Footman\\Footman.mdl")
		call setIconPath(id,"ReplaceableTextures\\CommandButtons\\BTNFootman.blp")
		call setValue(id,BASE_ATK,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_ATK,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_DEF,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_DEF,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_MAG,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_MAG,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_RES,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_RES,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_ACC,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_ACC,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_EVA,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_EVA,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_MAXHP,BASESTAT_DEFAULT*10)
		call setValue(id,LEVEL_MAXHP,LEVELSTAT_DEFAULT*10)
		call setValue(id,BASE_MAXMP,BASESTAT_DEFAULT*5)
		call setValue(id,LEVEL_MAXMP,LEVELSTAT_DEFAULT*5)
		call setValue(id,BASE_HPR,BASESTAT_DEFAULT/10)
		call setValue(id,LEVEL_HPR,LEVELSTAT_DEFAULT/10)
		call setValue(id,BASE_MPR,BASESTAT_DEFAULT/10)
		call setValue(id,LEVEL_MPR,LEVELSTAT_DEFAULT/10)
		call setValue(id,BASE_HEIGHT,0)
		call setValue(id,BASE_MS,325)
		call setValue(id,LEVEL_MS,0)
		call setValue(id,SCALE,1.8)
		call setValue(id,ATTACKDELAY,1.5)
		call setValue(id,RANGE,150)
		call setWeapontype(id,5)
		call setValue(id,ATTACKANIMSPEED,1.5)
		call setResourceType(id,RESOURCE_TYPE_MANA)
		call setBasicAbility(id,0,'A000')
		call setBasicAbility(id,1,'P000')
	//! runtextmacro unitDataEnd()
endlibrary

library UnitHR01 //총잡이
	//! runtextmacro unitDataHeaderEx("HR01")
		call setModelPath(id,"Units\\human\\Rifleman\\Rifleman.mdl")
		call setIconPath(id,"ReplaceableTextures\\CommandButtons\\BTNRifleman.blp")
		//
		call setValue(id,BASE_ATK,BASESTAT_DEFAULT		-5)
		call setValue(id,LEVEL_ATK,LEVELSTAT_DEFAULT		-0.5)
		//
		call setValue(id,BASE_DEF,BASESTAT_DEFAULT		-5)
		call setValue(id,LEVEL_DEF,LEVELSTAT_DEFAULT		-0.5)
		//
		call setValue(id,BASE_MAG,BASESTAT_DEFAULT		+3)
		call setValue(id,LEVEL_MAG,LEVELSTAT_DEFAULT		+0.3)
		//
		call setValue(id,BASE_RES,BASESTAT_DEFAULT		)
		call setValue(id,LEVEL_RES,LEVELSTAT_DEFAULT		)
		//
		call setValue(id,BASE_ACC,BASESTAT_DEFAULT		+2)
		call setValue(id,LEVEL_ACC,LEVELSTAT_DEFAULT		+0.2)
		//
		call setValue(id,BASE_EVA,BASESTAT_DEFAULT		+3)
		call setValue(id,LEVEL_EVA,LEVELSTAT_DEFAULT		+0.3)
		//
		call setValue(id,BASE_MAXHP,BASESTAT_DEFAULT*10		)
		call setValue(id,LEVEL_MAXHP,LEVELSTAT_DEFAULT*10	)
		//
		call setValue(id,BASE_MAXMP,BASESTAT_DEFAULT*5		+10)
		call setValue(id,LEVEL_MAXMP,LEVELSTAT_DEFAULT*5	+1)
		//
		call setValue(id,BASE_HPR,BASESTAT_DEFAULT/10		)
		call setValue(id,LEVEL_HPR,LEVELSTAT_DEFAULT/10		)
		//
		call setValue(id,BASE_MPR,BASESTAT_DEFAULT/10		)
		call setValue(id,LEVEL_MPR,LEVELSTAT_DEFAULT/10		)
		call setValue(id,BASE_HEIGHT,0)
		call setValue(id,BASE_MS,325)
		call setValue(id,LEVEL_MS,0)
		call setValue(id,SCALE,1.6)
		call setValue(id,ATTACKDELAY,1.5)
		call setValue(id,RANGE,150)
		call setWeapontype(id,5)
		call setValue(id,ATTACKANIMSPEED,1.)
		call setResourceType(id,RESOURCE_TYPE_MANA)
		call setBasicAbility(id,0,'A400')
		call setBasicAbility(id,1,'P400')
	//! runtextmacro unitDataEnd()
endlibrary

library UnitHR02 //붉은기사
	//! runtextmacro unitDataHeaderEx("HR02")
		call setModelPath(id,"war3mapImported\\RedFootman.mdl")
		call setIconPath(id,"ReplaceableTextures\\CommandButtons\\BTNRedFootman.blp")
		call setValue(id,BASE_ATK,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_ATK,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_DEF,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_DEF,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_MAG,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_MAG,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_RES,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_RES,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_ACC,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_ACC,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_EVA,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_EVA,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_MAXHP,BASESTAT_DEFAULT*10)
		call setValue(id,LEVEL_MAXHP,LEVELSTAT_DEFAULT*10)
		call setValue(id,BASE_MAXMP,BASESTAT_DEFAULT*5)
		call setValue(id,LEVEL_MAXMP,LEVELSTAT_DEFAULT*5)
		call setValue(id,BASE_HPR,BASESTAT_DEFAULT/10)
		call setValue(id,LEVEL_HPR,LEVELSTAT_DEFAULT/10)
		call setValue(id,BASE_MPR,BASESTAT_DEFAULT/10)
		call setValue(id,LEVEL_MPR,LEVELSTAT_DEFAULT/10)
		call setValue(id,BASE_HEIGHT,0)
		call setValue(id,BASE_MS,325)
		call setValue(id,LEVEL_MS,0)
		call setValue(id,SCALE,1.8)
		call setValue(id,ATTACKDELAY,1.5)
		call setValue(id,RANGE,150)
		call setWeapontype(id,5)
		call setValue(id,ATTACKANIMSPEED,1.)
		call setResourceType(id,RESOURCE_TYPE_MANA)
		call setBasicAbility(id,0,'A300')
		call setBasicAbility(id,1,'P020')
	//! runtextmacro unitDataEnd()
endlibrary

library UnitHR03 //해골검사
	//! runtextmacro unitDataHeaderEx("HR03")
		call setModelPath(id,"war3mapImported\\BlackSkeleton.mdl")
		call setIconPath(id,"ReplaceableTextures\\CommandButtons\\BTNBlackSkeleton.blp")
		call setValue(id,BASE_ATK,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_ATK,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_DEF,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_DEF,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_MAG,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_MAG,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_RES,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_RES,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_ACC,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_ACC,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_EVA,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_EVA,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_MAXHP,BASESTAT_DEFAULT*10)
		call setValue(id,LEVEL_MAXHP,LEVELSTAT_DEFAULT*10)
		call setValue(id,BASE_MAXMP,BASESTAT_DEFAULT*5)
		call setValue(id,LEVEL_MAXMP,LEVELSTAT_DEFAULT*5)
		call setValue(id,BASE_HPR,BASESTAT_DEFAULT/10)
		call setValue(id,LEVEL_HPR,LEVELSTAT_DEFAULT/10)
		call setValue(id,BASE_MPR,BASESTAT_DEFAULT/10)
		call setValue(id,LEVEL_MPR,LEVELSTAT_DEFAULT/10)
		call setValue(id,BASE_HEIGHT,0)
		call setValue(id,BASE_MS,325)
		call setValue(id,LEVEL_MS,0)
		call setValue(id,SCALE,1.8)
		call setValue(id,ATTACKDELAY,1.5)
		call setValue(id,RANGE,150)
		call setWeapontype(id,5)
		call setValue(id,ATTACKANIMSPEED,1.)
		call setResourceType(id,RESOURCE_TYPE_MANA)
		call setBasicAbility(id,0,'AX00')
		call setBasicAbility(id,1,'P100')
	//! runtextmacro unitDataEnd()
endlibrary

library UnitHR04 //검투사
	//! runtextmacro unitDataHeaderEx("HR04")
		call setModelPath(id,"units\\human\\HeroPaladin\\HeroPaladin.mdl")
		call setIconPath(id,"ReplaceableTextures\\CommandButtons\\BTNHeroPaladin.blp")
		call setValue(id,BASE_ATK,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_ATK,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_DEF,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_DEF,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_MAG,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_MAG,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_RES,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_RES,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_ACC,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_ACC,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_EVA,BASESTAT_DEFAULT)
		call setValue(id,LEVEL_EVA,LEVELSTAT_DEFAULT)
		call setValue(id,BASE_MAXHP,BASESTAT_DEFAULT*10)
		call setValue(id,LEVEL_MAXHP,LEVELSTAT_DEFAULT*10)
		call setValue(id,BASE_MAXMP,BASESTAT_DEFAULT*5)
		call setValue(id,LEVEL_MAXMP,LEVELSTAT_DEFAULT*5)
		call setValue(id,BASE_HPR,BASESTAT_DEFAULT/10)
		call setValue(id,LEVEL_HPR,LEVELSTAT_DEFAULT/10)
		call setValue(id,BASE_MPR,BASESTAT_DEFAULT/10)
		call setValue(id,LEVEL_MPR,LEVELSTAT_DEFAULT/10)
		call setValue(id,BASE_HEIGHT,0)
		call setValue(id,BASE_MS,325)
		call setValue(id,LEVEL_MS,0)
		call setValue(id,SCALE,1.8)
		call setValue(id,ATTACKDELAY,1.5)
		call setValue(id,RANGE,150)
		call setWeapontype(id,16)
		call setValue(id,ATTACKANIMSPEED,1.)
		call setResourceType(id,RESOURCE_TYPE_MANA)
		call setBasicAbility(id,0,'A000')
		call setBasicAbility(id,1,'P020')
	//! runtextmacro unitDataEnd()
endlibrary

library UnitHR05 //해병
	//! runtextmacro unitDataHeaderEx("HR05")
		call setModelPath(id,"Units\\Critters\\Marine\\Marine.mdl")
		call setIconPath(id,"ReplaceableTextures\\CommandButtons\\BTNMarine.blp")
		//
		call setValue(id,BASE_ATK,BASESTAT_DEFAULT		-5)
		call setValue(id,LEVEL_ATK,LEVELSTAT_DEFAULT		-0.5)
		//
		call setValue(id,BASE_DEF,BASESTAT_DEFAULT		-4)
		call setValue(id,LEVEL_DEF,LEVELSTAT_DEFAULT		-0.4)
		//
		call setValue(id,BASE_MAG,BASESTAT_DEFAULT		+3)
		call setValue(id,LEVEL_MAG,LEVELSTAT_DEFAULT		+0.3)
		//
		call setValue(id,BASE_RES,BASESTAT_DEFAULT		)
		call setValue(id,LEVEL_RES,LEVELSTAT_DEFAULT		)
		//
		call setValue(id,BASE_ACC,BASESTAT_DEFAULT		+2)
		call setValue(id,LEVEL_ACC,LEVELSTAT_DEFAULT		+0.2)
		//
		call setValue(id,BASE_EVA,BASESTAT_DEFAULT		+3)
		call setValue(id,LEVEL_EVA,LEVELSTAT_DEFAULT		+0.3)
		//
		call setValue(id,BASE_MAXHP,BASESTAT_DEFAULT*10		)
		call setValue(id,LEVEL_MAXHP,LEVELSTAT_DEFAULT*10	)
		//
		call setValue(id,BASE_MAXMP,BASESTAT_DEFAULT*5		+10)
		call setValue(id,LEVEL_MAXMP,LEVELSTAT_DEFAULT*5	+1)
		//
		call setValue(id,BASE_HPR,BASESTAT_DEFAULT/10		)
		call setValue(id,LEVEL_HPR,LEVELSTAT_DEFAULT/10		)
		//
		call setValue(id,BASE_MPR,BASESTAT_DEFAULT/10		)
		call setValue(id,LEVEL_MPR,LEVELSTAT_DEFAULT/10		)
		call setValue(id,BASE_HEIGHT,0)
		call setValue(id,BASE_MS,325)
		call setValue(id,LEVEL_MS,0)
		call setValue(id,SCALE,1.6)
		call setValue(id,ATTACKDELAY,1.5)
		call setValue(id,RANGE,150)
		call setWeapontype(id,5)
		call setValue(id,ATTACKANIMSPEED,1.)
		call setResourceType(id,RESOURCE_TYPE_MANA)
		call setBasicAbility(id,0,'A900')
		call setBasicAbility(id,1,'P420')
	//! runtextmacro unitDataEnd()
endlibrary

library UnitHR06 //트롤 광전사
	//! runtextmacro unitDataHeaderEx("HR06")
		call setModelPath(id,"units\\creeps\\ForestTrollTrapper\\ForestTrollTrapper.mdl")
		call setIconPath(id,"ReplaceableTextures\\CommandButtons\\BTNForestTrollTrapper.blp")
		//
		call setValue(id,BASE_ATK,BASESTAT_DEFAULT		-1)
		call setValue(id,LEVEL_ATK,LEVELSTAT_DEFAULT		-0.1)
		//
		call setValue(id,BASE_DEF,BASESTAT_DEFAULT		-5)
		call setValue(id,LEVEL_DEF,LEVELSTAT_DEFAULT		-0.5)
		//
		call setValue(id,BASE_MAG,BASESTAT_DEFAULT		)
		call setValue(id,LEVEL_MAG,LEVELSTAT_DEFAULT		)
		//
		call setValue(id,BASE_RES,BASESTAT_DEFAULT		)
		call setValue(id,LEVEL_RES,LEVELSTAT_DEFAULT		)
		//
		call setValue(id,BASE_ACC,BASESTAT_DEFAULT		+2)
		call setValue(id,LEVEL_ACC,LEVELSTAT_DEFAULT		+0.2)
		//
		call setValue(id,BASE_EVA,BASESTAT_DEFAULT		+3)
		call setValue(id,LEVEL_EVA,LEVELSTAT_DEFAULT		+0.3)
		//
		call setValue(id,BASE_MAXHP,BASESTAT_DEFAULT*10		)
		call setValue(id,LEVEL_MAXHP,LEVELSTAT_DEFAULT*10	)
		//
		call setValue(id,BASE_MAXMP,BASESTAT_DEFAULT*5		+10)
		call setValue(id,LEVEL_MAXMP,LEVELSTAT_DEFAULT*5	+1)
		//
		call setValue(id,BASE_HPR,BASESTAT_DEFAULT/10		)
		call setValue(id,LEVEL_HPR,LEVELSTAT_DEFAULT/10		)
		//
		call setValue(id,BASE_MPR,BASESTAT_DEFAULT/10		)
		call setValue(id,LEVEL_MPR,LEVELSTAT_DEFAULT/10		)
		call setValue(id,BASE_HEIGHT,0)
		call setValue(id,BASE_MS,325)
		call setValue(id,LEVEL_MS,0)
		call setValue(id,SCALE,1.6)
		call setValue(id,ATTACKDELAY,1.5)
		call setValue(id,RANGE,150)
		call setWeapontype(id,5)
		call setValue(id,ATTACKANIMSPEED,1.3)
		call setResourceType(id,RESOURCE_TYPE_MANA)
		call setBasicAbility(id,0,'A310')
		call setBasicAbility(id,1,'P300')
	//! runtextmacro unitDataEnd()
endlibrary

library UnitHR07 //자객
	//! runtextmacro unitDataHeaderEx("HR07")
		call setModelPath(id,"units\\creeps\\assassin\\assassin.mdl")
		call setIconPath(id,"ReplaceableTextures\\CommandButtons\\BTNAssassin.blp")
		//
		call setValue(id,BASE_ATK,BASESTAT_DEFAULT		)
		call setValue(id,LEVEL_ATK,LEVELSTAT_DEFAULT		)
		//
		call setValue(id,BASE_DEF,BASESTAT_DEFAULT		-3)
		call setValue(id,LEVEL_DEF,LEVELSTAT_DEFAULT		-0.3)
		//
		call setValue(id,BASE_MAG,BASESTAT_DEFAULT		)
		call setValue(id,LEVEL_MAG,LEVELSTAT_DEFAULT		)
		//
		call setValue(id,BASE_RES,BASESTAT_DEFAULT		-2)
		call setValue(id,LEVEL_RES,LEVELSTAT_DEFAULT		-0.2)
		//
		call setValue(id,BASE_ACC,BASESTAT_DEFAULT		+2)
		call setValue(id,LEVEL_ACC,LEVELSTAT_DEFAULT		+0.2)
		//
		call setValue(id,BASE_EVA,BASESTAT_DEFAULT		+3)
		call setValue(id,LEVEL_EVA,LEVELSTAT_DEFAULT		+0.3)
		//
		call setValue(id,BASE_MAXHP,BASESTAT_DEFAULT*10		)
		call setValue(id,LEVEL_MAXHP,LEVELSTAT_DEFAULT*10	)
		//
		call setValue(id,BASE_MAXMP,BASESTAT_DEFAULT*5		)
		call setValue(id,LEVEL_MAXMP,LEVELSTAT_DEFAULT*5	)
		//
		call setValue(id,BASE_HPR,BASESTAT_DEFAULT/10		)
		call setValue(id,LEVEL_HPR,LEVELSTAT_DEFAULT/10		)
		//
		call setValue(id,BASE_MPR,BASESTAT_DEFAULT/10		)
		call setValue(id,LEVEL_MPR,LEVELSTAT_DEFAULT/10		)
		call setValue(id,BASE_HEIGHT,0)
		call setValue(id,BASE_MS,325)
		call setValue(id,LEVEL_MS,0)
		call setValue(id,SCALE,1.6)
		call setValue(id,ATTACKDELAY,1.5)
		call setValue(id,RANGE,150)
		call setWeapontype(id,5)
		call setValue(id,ATTACKANIMSPEED,1.3)
		call setResourceType(id,RESOURCE_TYPE_MANA)
		call setBasicAbility(id,0,'A100')
		call setBasicAbility(id,1,'P120')
	//! runtextmacro unitDataEnd()
endlibrary

library UnitHR08 //치유의 정령
	//! runtextmacro unitDataHeaderEx("HR08")
		call setModelPath(id,"war3mapImported\\GoldenElemental.mdl")
		call setIconPath(id,"ReplaceableTextures\\CommandButtons\\BTNSummonWaterElemental.blp")
		//
		call setValue(id,BASE_ATK,BASESTAT_DEFAULT		)
		call setValue(id,LEVEL_ATK,LEVELSTAT_DEFAULT		)
		//
		call setValue(id,BASE_DEF,BASESTAT_DEFAULT		-3)
		call setValue(id,LEVEL_DEF,LEVELSTAT_DEFAULT		-0.3)
		//
		call setValue(id,BASE_MAG,BASESTAT_DEFAULT		)
		call setValue(id,LEVEL_MAG,LEVELSTAT_DEFAULT		)
		//
		call setValue(id,BASE_RES,BASESTAT_DEFAULT		-2)
		call setValue(id,LEVEL_RES,LEVELSTAT_DEFAULT		-0.2)
		//
		call setValue(id,BASE_ACC,BASESTAT_DEFAULT		+2)
		call setValue(id,LEVEL_ACC,LEVELSTAT_DEFAULT		+0.2)
		//
		call setValue(id,BASE_EVA,BASESTAT_DEFAULT		+3)
		call setValue(id,LEVEL_EVA,LEVELSTAT_DEFAULT		+0.3)
		//
		call setValue(id,BASE_MAXHP,BASESTAT_DEFAULT*10		)
		call setValue(id,LEVEL_MAXHP,LEVELSTAT_DEFAULT*10	)
		//
		call setValue(id,BASE_MAXMP,BASESTAT_DEFAULT*5		)
		call setValue(id,LEVEL_MAXMP,LEVELSTAT_DEFAULT*5	)
		//
		call setValue(id,BASE_HPR,BASESTAT_DEFAULT/10		)
		call setValue(id,LEVEL_HPR,LEVELSTAT_DEFAULT/10		)
		//
		call setValue(id,BASE_MPR,BASESTAT_DEFAULT/10		)
		call setValue(id,LEVEL_MPR,LEVELSTAT_DEFAULT/10		)
		call setValue(id,BASE_HEIGHT,0)
		call setValue(id,BASE_MS,325)
		call setValue(id,LEVEL_MS,0)
		call setValue(id,SCALE,1.4)
		call setValue(id,ATTACKDELAY,1.5)
		call setValue(id,RANGE,150)
		call setWeapontype(id,5)
		call setValue(id,ATTACKANIMSPEED,1.3)
		call setResourceType(id,RESOURCE_TYPE_MANA)
		call setBasicAbility(id,0,'A100')
		call setBasicAbility(id,1,'PX00')
	//! runtextmacro unitDataEnd()
endlibrary