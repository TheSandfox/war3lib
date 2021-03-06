	//! textmacro MonsterDataHeader takes id
		set ID_CURRENT = $id$
	//! endtextmacro

	//! textmacro MonsterSetData takes prime, value
		set $prime$[ID_CURRENT] = $value$
	//! endtextmacro

/*0 : 숲거미*/
//! runtextmacro MonsterDataHeader("0")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\creeps\\SpiderGreen\\SpiderGreen.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNSpiderGreen.blp\"")
//! runtextmacro MonsterSetData("NAME","\"숲거미\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_SpiderYesAttack101")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_POISON")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_NATURE")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_BUG")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_UNDEFINED")
//! runtextmacro MonsterSetData("ABILITY_ID1","4")
//! runtextmacro MonsterSetData("ABILITY_ID2","1")
//! runtextmacro MonsterSetData("SCALE","0.88")
/**/

/*1 : 나무정령*/
//! runtextmacro MonsterDataHeader("1")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\nightelf\\Ent\\Ent.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNEnt.blp\"")
//! runtextmacro MonsterSetData("NAME","\"나무정령\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_EntYes1")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_NATURE")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_NATURE")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_PLANT")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_UNDEFINED")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("ABILITY_ID2","2")
//! runtextmacro MonsterSetData("SCALE","1.")
/**/

/*2 : 태엽고블린*/
//! runtextmacro MonsterDataHeader("2")
//! runtextmacro MonsterSetData("MODEL_PATH","\"Units\\Creeps\\HeroTinkerRobot\\HeroTinkerRobot.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNClockWerkGoblin.blp\"")
//! runtextmacro MonsterSetData("NAME","\"태엽고블린\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_ClockwerkGoblinYesAttack1")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_METAL")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_NORMAL")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_MECHANIC")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_UNDEFINED")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","1.2")

/*3 : 진흙골렘*/
//! runtextmacro MonsterDataHeader("3")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\creeps\\RockGolem\\RockGolem.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNRockGolem.blp\"")
//! runtextmacro MonsterSetData("NAME","\"진흙골렘\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_RockGolemWhat1")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_EARTH")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_NORMAL")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_MINERAL")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_UNDEFINED")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","0.66")
//! runtextmacro MonsterSetData("COLOR_R","160")
//! runtextmacro MonsterSetData("COLOR_G","86")
//! runtextmacro MonsterSetData("COLOR_B","32")

/*4 : 지옥사냥개*/
//! runtextmacro MonsterDataHeader("4")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\demon\\felhound\\felhound.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNFelHound.blp\"")
//! runtextmacro MonsterSetData("NAME","\"지옥사냥개\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_FelHoundYesAttack2")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_DARK")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_FIRE")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_BEAST")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_DEMON")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","1.")

/*5 : 가고일*/
//! runtextmacro MonsterDataHeader("5")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\undead\\Gargoyle\\Gargoyle.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNGargoyle.blp\"")
//! runtextmacro MonsterSetData("NAME","\"가고일\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_GargoyleYes1")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_DARK")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_WIND")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_BEAST")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_BIRD")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","0.87")
//! runtextmacro MonsterSetData("Z_OFFSET","80.")

/*6 : 요정용*/
//! runtextmacro MonsterDataHeader("6")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\nightelf\\FaerieDragon\\FaerieDragon.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNFaerieDragon.blp\"")
//! runtextmacro MonsterSetData("NAME","\"요정용\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_FaerieDragonReady1")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_LIGHT")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_WIND")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_FAIRY")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_DRAGON")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","0.93")
//! runtextmacro MonsterSetData("Z_OFFSET","65.")

/*7 : 딱정벌레*/
//! runtextmacro MonsterDataHeader("7")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\undead\\scarab\\scarab.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNCarrionScarabs.blp\"")
//! runtextmacro MonsterSetData("NAME","\"딱정벌레\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_ScarabYes1")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_EARTH")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_DARK")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_BUG")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_UNDEFINED")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","1.25")

/*8 : 꽃게*/
//! runtextmacro MonsterDataHeader("8")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\critters\\SpiderCrab\\SpiderCrab.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNSpinyCrab.blp\"")
//! runtextmacro MonsterSetData("NAME","\"꽃게\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_LobstrokkYes2")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_WATER")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_NORMAL")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_BUG")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_FISH")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","1.25")

/*9 : 수리*/
//! runtextmacro MonsterDataHeader("9")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\creeps\\WarEagle\\WarEagle.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNWarEagle.blp\"")
//! runtextmacro MonsterSetData("NAME","\"수리\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_HawkReady1")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_WIND")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_NORMAL")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_BIRD")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_UNDEFINED")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","0.85")
//! runtextmacro MonsterSetData("Z_OFFSET","65.")

/*10 : 불도마뱀*/
//! runtextmacro MonsterDataHeader("10")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\creeps\\ThunderLizardSalamander\\ThunderLizardSalamander.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNThunderLizardSalamander.blp\"")
//! runtextmacro MonsterSetData("NAME","\"불도마뱀\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_KotoBeastWhat3")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_FIRE")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_EARTH")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_BEAST")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_UNDEFINED")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","0.67")


/*11 : 멀록*/
//! runtextmacro MonsterDataHeader("11")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\creeps\\MurgulSlave\\MurgulSlave.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNMurgalSlave.blp\"")
//! runtextmacro MonsterSetData("NAME","\"멀록\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_MurlocYesAttack1")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_WATER")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_NORMAL")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_FISH")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_UNDEFINED")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","1.0")

/*12 : 정글괴수*/
//! runtextmacro MonsterDataHeader("12")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\creeps\\JungleBeast\\JungleBeast.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNJungleBeast.blp\"")
//! runtextmacro MonsterSetData("NAME","\"정글괴수\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_WendigoYes1")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_NATURE")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_EARTH")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_BEAST")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_UNDEFINED")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","0.85")

/*13 : 바위골렘*/
//! runtextmacro MonsterDataHeader("13")
//! runtextmacro MonsterSetData("TIER","2")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\creeps\\RockGolem\\RockGolem.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNRockGolem.blp\"")
//! runtextmacro MonsterSetData("NAME","\"바위골렘\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_RockGolemWhat1")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_EARTH")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_NORMAL")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_MINERAL")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_UNDEFINED")
//! runtextmacro MonsterSetData("SCALE","0.88")

/*14 : 공성거인*/
//! runtextmacro MonsterDataHeader("14")
//! runtextmacro MonsterSetData("TIER","2")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\creeps\\GolemStatue\\GolemStatue.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNArmorGolem.blp\"")
//! runtextmacro MonsterSetData("NAME","\"공성거인\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_RockGolemWhat1")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_METAL")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_NORMAL")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_MINERAL")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_MECHANIC")
//! runtextmacro MonsterSetData("SCALE","0.88")

/*15 : 벌목기*/
//! runtextmacro MonsterDataHeader("15")
//! runtextmacro MonsterSetData("TIER","2")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\creeps\\IronGolem\\IronGolem.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNJunkGolem.blp\"")
//! runtextmacro MonsterSetData("NAME","\"벌목기\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_IronGolemWhat1")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_METAL")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_FIRE")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_MECHANIC")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_UNDEFINED")
//! runtextmacro MonsterSetData("SCALE","0.9")

/*16 : 폭파병*/
//! runtextmacro MonsterDataHeader("16")
//! runtextmacro MonsterSetData("TIER","2")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\creeps\\GoblinSapper\\GoblinSapper.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNGoblinSapper.blp\"")
//! runtextmacro MonsterSetData("NAME","\"폭파병\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_GoblinSapperWhat2")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_NORMAL")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_NORMAL")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_HUMANLIKE")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_UNDEFINED")
//! runtextmacro MonsterSetData("SCALE","1.0")

/*17 : 사막전갈*/
//! runtextmacro MonsterDataHeader("17")
//! runtextmacro MonsterSetData("TIER","2")
//! runtextmacro MonsterSetData("MODEL_PATH","\"Units\\Creeps\\Archnathid\\Archnathid.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNArachnathid.blp\"")
//! runtextmacro MonsterSetData("NAME","\"사막전갈\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_ArachnathidWhat2")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_EARTH")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_POISON")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_BUG")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_UNDEFINED")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","0.92")

/*18 : 지하마귀*/
//! runtextmacro MonsterDataHeader("18")
//! runtextmacro MonsterSetData("TIER","2")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\undead\\CryptFiend\\CryptFiend.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNCryptFiend.blp\"")
//! runtextmacro MonsterSetData("NAME","\"지하마귀\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_CryptFiendYesAttack2")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_NATURE")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_DARK")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_BUG")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_UNDEFINED")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","1.")

/*19 : 네루비안*/
//! runtextmacro MonsterDataHeader("19")
//! runtextmacro MonsterSetData("TIER","2")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\creeps\\Nerubian\\Nerubian.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNNerubian.blp\"")
//! runtextmacro MonsterSetData("NAME","\"네루비안\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_CryptFiendYesAttack1")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_NATURE")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_POISON")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_BUG")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_UNDEFINED")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","1.")

/*20 : 흡혈거미*/
//! runtextmacro MonsterDataHeader("20")
//! runtextmacro MonsterSetData("TIER","2")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\creeps\\SpiderBlack\\SpiderBlack.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNSpider.blp\"")
//! runtextmacro MonsterSetData("NAME","\"흡혈거미\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_SpiderYesAttack101")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_DARK")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_POISON")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_BUG")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_UNDEFINED")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","1.")

/*21 : 시민*/
//! runtextmacro MonsterDataHeader("21")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\critters\\VillagerMan\\VillagerMan.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNVillagerMan.blp\"")
//! runtextmacro MonsterSetData("NAME","\"시민\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_VillagerMAWhat2")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_NORMAL")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_NORMAL")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_HUMANLIKE")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_UNDEFINED")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","1.")

/*22 : 보병*/
//! runtextmacro MonsterDataHeader("22")
//! runtextmacro MonsterSetData("TIER","2")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\human\\Footman\\Footman.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNFootman.blp\"")
//! runtextmacro MonsterSetData("NAME","\"보병\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_FootmanYesAttack3")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_METAL")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_NORMAL")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_HUMANLIKE")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_UNDEFINED")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","1.125")

/*23 : 총잡이*/
//! runtextmacro MonsterDataHeader("23")
//! runtextmacro MonsterSetData("TIER","2")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\human\\Rifleman\\Rifleman.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNRifleman.blp\"")
//! runtextmacro MonsterSetData("NAME","\"총잡이\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_RiflemanYes3")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_NORMAL")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_NORMAL")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_HUMANLIKE")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_UNDEFINED")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","1.125")

/*24 : 사제*/
//! runtextmacro MonsterDataHeader("24")
//! runtextmacro MonsterSetData("TIER","2")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\human\\Priest\\Priest_V1.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNPriest.blp\"")
//! runtextmacro MonsterSetData("NAME","\"사제\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_PriestYesAttack1")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_ARCANE")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_LIGHT")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_HUMANLIKE")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_UNDEFINED")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","1.125")

/*25 : 위습*/
//! runtextmacro MonsterDataHeader("25")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\nightelf\\Wisp\\Wisp.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNWisp.blp\"")
//! runtextmacro MonsterSetData("NAME","\"위습\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_WispWhat3")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_NATURE")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_ARCANE")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_ELEMENTAL")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_GHOST")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","0.75")
//! runtextmacro MonsterSetData("Z_OFFSET","30.")

/*26 : 민물가재*/
//! runtextmacro MonsterDataHeader("26")
//! runtextmacro MonsterSetData("TIER","2")
//! runtextmacro MonsterSetData("MODEL_PATH","\"Units\\Creeps\\Lobstrokkgreen\\Lobstrokkgreen.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNLobstrokkGreen.blp\"")
//! runtextmacro MonsterSetData("NAME","\"민물가재\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_LobstrokkYes2")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_WATER")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_NORMAL")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_BUG")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_FISH")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","0.8")

/*27 : 차원날개용*/
//! runtextmacro MonsterDataHeader("27")
//! runtextmacro MonsterSetData("TIER","2")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\naga\\SnapDragon\\SnapDragon.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNSnapDragon.blp\"")
//! runtextmacro MonsterSetData("NAME","\"차원날개용\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_SnapDragonWhat1")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_WATER")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_POISON")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_FISH")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_DRAGON")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","1.0")

/*28 : 바다거북*/
//! runtextmacro MonsterDataHeader("28")
//! runtextmacro MonsterSetData("TIER","2")
//! runtextmacro MonsterSetData("MODEL_PATH","\"Units\\Creeps\\GiantSeaTurtle\\GiantSeaTurtle.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNSeaTurtleGreen.blp\"")
//! runtextmacro MonsterSetData("NAME","\"바다거북\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_GiantSeaTurtleWhat2")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_WATER")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_NORMAL")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_BEAST")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_FISH")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","0.75")

/*29 : 바다거인*/
//! runtextmacro MonsterDataHeader("29")
//! runtextmacro MonsterSetData("TIER","3")
//! runtextmacro MonsterSetData("MODEL_PATH","\"Units\\Creeps\\SeaGiantGreen\\SeaGiantGreen.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNSeaGiantGreen.blp\"")
//! runtextmacro MonsterSetData("NAME","\"바다거인\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_SeaGiantWhat3")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_WATER")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_NORMAL")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_HUMANLIKE")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_FISH")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","1.")

/*30 : 멀록 싸움꾼*/
//! runtextmacro MonsterDataHeader("30")
//! runtextmacro MonsterSetData("TIER","2")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\creeps\\MurlocMutant\\MurlocMutant_V1.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNMurlocMutant.blp\"")
//! runtextmacro MonsterSetData("NAME","\"멀록 싸움꾼\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_MurlocYesAttack1")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_WATER")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_NORMAL")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_FISH")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_UNDEFINED")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","1.2")

/*31 : 미르미돈*/
//! runtextmacro MonsterDataHeader("31")
//! runtextmacro MonsterSetData("TIER","3")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\naga\\NagaMyrmidon\\NagaMyrmidon.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNNagaMyrmidon.blp\"")
//! runtextmacro MonsterSetData("NAME","\"미르미돈\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_NagaMyrmadonWhat4")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_WATER")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_NORMAL")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_HUMANLIKE")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_FISH")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","1.2")

/*32 : 세이렌*/
//! runtextmacro MonsterDataHeader("32")
//! runtextmacro MonsterSetData("TIER","3")
//! runtextmacro MonsterSetData("MODEL_PATH","\"Units\\Naga\\NagaSummoner\\NagaSummoner.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNNagaSummoner.blp\"")
//! runtextmacro MonsterSetData("NAME","\"세이렌\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_NagaSirenWhat4")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_WATER")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_ARCANE")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_HUMANLIKE")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_FISH")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","1.1")

/*33 : 히드라*/
//! runtextmacro MonsterDataHeader("33")
//! runtextmacro MonsterSetData("TIER","3")
//! runtextmacro MonsterSetData("MODEL_PATH","\"Units\\Creeps\\Hydra\\Hydra.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNGreenHydra.blp\"")
//! runtextmacro MonsterSetData("NAME","\"히드라\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_DragonYesAttack2")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_WATER")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_POISON")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_DRAGON")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_FISH")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","0.9")
//! runtextmacro MonsterSetData("COLOR_R","128")
//! runtextmacro MonsterSetData("COLOR_G","128")
//! runtextmacro MonsterSetData("COLOR_B","255")

/*34 : 모크라쉬*/
//! runtextmacro MonsterDataHeader("34")
//! runtextmacro MonsterSetData("TIER","4")
//! runtextmacro MonsterSetData("MODEL_PATH","\"Units\\Creeps\\SeaGiant\\SeaGiant.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNSeaGiant.blp\"")
//! runtextmacro MonsterSetData("NAME","\"모크라쉬\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_SeaGiantWhat3")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_WATER")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_NORMAL")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_HUMANLIKE")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_FISH")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","1.1")

/*35 : 로얄가드*/
//! runtextmacro MonsterDataHeader("35")
//! runtextmacro MonsterSetData("TIER","4")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\naga\\NagaRoyalGuard\\NagaRoyalGuard.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNNagaMyrmidonRoyalGuard.blp\"")
//! runtextmacro MonsterSetData("NAME","\"로얄가드\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_NagaMyrmadonWhat4")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_WATER")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_NORMAL")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_HUMANLIKE")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_FISH")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","1.32")

/*36 : 고대 히드라*/
//! runtextmacro MonsterDataHeader("36")
//! runtextmacro MonsterSetData("TIER","4")
//! runtextmacro MonsterSetData("MODEL_PATH","\"Units\\Creeps\\Hydra\\Hydra.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNGreenHydra.blp\"")
//! runtextmacro MonsterSetData("NAME","\"고대 히드라\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_DragonYesAttack2")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_WATER")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_POISON")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_DRAGON")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_FISH")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","1.1")

/*37 : 여군주 바쉬*/
//! runtextmacro MonsterDataHeader("37")
//! runtextmacro MonsterSetData("TIER","4")
//! runtextmacro MonsterSetData("MODEL_PATH","\"units\\naga\\HeroNagaSeawitch\\HeroNagaSeawitch.mdl\"")
//! runtextmacro MonsterSetData("ICON_PATH","\"ReplaceableTextures\\CommandButtons\\BTNNagaSeaWitch.blp\"")
//! runtextmacro MonsterSetData("NAME","\"여군주 바쉬\"")
//! runtextmacro MonsterSetData("SOUND","gg_snd_LadyVashjYes4")
//! runtextmacro MonsterSetData("ELEMENT_TYPE1","ELEMENT_TYPE_WATER")
//! runtextmacro MonsterSetData("ELEMENT_TYPE2","ELEMENT_TYPE_ARCANE")
//! runtextmacro MonsterSetData("MONSTER_RACE1","MONSTER_RACE_FISH")
//! runtextmacro MonsterSetData("MONSTER_RACE2","MONSTER_RACE_HUMANLIKE")
//! runtextmacro MonsterSetData("ABILITY_ID1","0")
//! runtextmacro MonsterSetData("SCALE","1.2")