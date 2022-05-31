library MonsterData requires String

	globals

		constant integer PLAYER_MAX = 4

		constant integer MONSTER_MAX	= 256
		constant integer MONSTER_ABILITY_COUNT_MAX = 4

		constant real AP_PER_SECOND	= 40.	/*초당 행동력재생 표준치*/

		/*경험치 상수*/
		constant integer EXP_BASE = 50
		constant integer EXP_PER_LEVEL = 20
		constant integer EXP_PER_LEVEL_PER_LEVEL = 10

		/*데미지 타입*/
		constant integer DAMAGE_TYPE_PHYSICAL 		= 0
		constant integer DAMAGE_TYPE_MAGICAL		= 1
		constant integer DAMAGE_TYPE_TRUE			= 2

		integer DAMAGE_FLAG_RANGED 					= 0

		/*능력치 레이블*/
		constant integer STAT_TYPE_MAXHP			= 0
		constant integer STAT_TYPE_ATTACK 			= 1
		constant integer STAT_TYPE_DEFFENCE			= 2
		constant integer STAT_TYPE_MAGICPOWER		= 3
		constant integer STAT_TYPE_RESISTANCE		= 4
		constant integer STAT_TYPE_SPEED			= 5
		constant integer STAT_TYPE_SIZE				= 6
		/*능력치 인덱스 레이블*/
		constant integer STAT_INDEX_BASE			= 0
		constant integer STAT_INDEX_LEVEL			= 1
		constant integer STAT_INDEX_INDIVISUAL 		= 3
		constant integer STAT_INDEX_MULTIFLY 		= 4
		constant integer STAT_INDEX_DEVIDE 			= 5
		constant integer STAT_INDEX_PLUS 			= 6
		constant integer STAT_INDEX_MINUS 			= 7
		constant integer STAT_INDEX_SIZE 			= 8

		/*속성 레이블*/
		constant integer ELEMENT_TYPE_NORMAL	= 0		
		constant integer ELEMENT_TYPE_FIRE		= 1		
		constant integer ELEMENT_TYPE_WATER		= 2		
		constant integer ELEMENT_TYPE_NATURE	= 3		
		constant integer ELEMENT_TYPE_EARTH		= 4		
		constant integer ELEMENT_TYPE_WIND		= 5		
		constant integer ELEMENT_TYPE_FROST		= 6		
		constant integer ELEMENT_TYPE_POISON	= 7		
		constant integer ELEMENT_TYPE_ELECTRIC	= 8		
		constant integer ELEMENT_TYPE_METAL		= 9		
		constant integer ELEMENT_TYPE_LIGHT		= 10	
		constant integer ELEMENT_TYPE_DARK		= 11	
		constant integer ELEMENT_TYPE_ARCANE	= 12	
		constant integer ELEMENT_TYPE_SIZE		= 13

		/*어빌리티 전용*/
		constant integer ELEMENT_TYPE_MODIFIED1 = -1
		constant integer ELEMENT_TYPE_MODIFIED2 = -2
		constant integer ELEMENT_TYPE_UNDEFINED = -3

		/*종족 레이블*/
		constant integer MONSTER_RACE_BEAST		= 0
		constant integer MONSTER_RACE_BIRD		= 1
		constant integer MONSTER_RACE_BUG		= 2
		constant integer MONSTER_RACE_FISH		= 3
		constant integer MONSTER_RACE_HUMANLIKE	= 4
		constant integer MONSTER_RACE_GHOST		= 5
		constant integer MONSTER_RACE_UNDEAD	= 6
		constant integer MONSTER_RACE_DEMON		= 7
		constant integer MONSTER_RACE_MINERAL	= 8
		constant integer MONSTER_RACE_PLANT		= 9
		constant integer MONSTER_RACE_ELEMENTAL = 10
		constant integer MONSTER_RACE_DRAGON	= 11
		constant integer MONSTER_RACE_MECHANIC	= 12
		constant integer MONSTER_RACE_FAIRY		= 13
		constant integer MONSTER_RACE_DIVINE	= 14
		constant integer MONSTER_RACE_UNKNOWN	= 15
		constant integer MONSTER_RACE_SIZE		= 16

		constant integer MONSTER_RACE_UNDEFINED = -1

		/*상성배수 레이블*/
		constant integer ELEMENT_TYPE_VALUE_VERY_WEAK	= 0
		constant integer ELEMENT_TYPE_VALUE_WEAK		= 1
		constant integer ELEMENT_TYPE_VALUE_NORMAL		= 2
		constant integer ELEMENT_TYPE_VALUE_STRONG		= 3
		constant integer ELEMENT_TYPE_VALUE_VERY_STRONG	= 4
		constant integer ELEMENT_TYPE_VALUE_SIZE		= 5

		/*이름*/
		string array STAT_TYPE_NAME[STAT_TYPE_SIZE]			/*초기화는 MonsterData.onInit()*/
		string array ELEMENT_TYPE_NAME[ELEMENT_TYPE_SIZE]	/*초기화는 MonsterData.onInit()*/	
		string array MONSTER_RACE_NAME[MONSTER_RACE_SIZE]	/*초기화는 MonsterData.onInit()*/

		/*상성배수 실제값*/
		real array ELEMENT_TYPE_VALUE[ELEMENT_TYPE_VALUE_SIZE]				/*초기화는 MonsterData.onInit()*/

		/*속성텍스쳐&모델 경로*/
		string array ELEMENT_TYPE_ICON_PATH[ELEMENT_TYPE_SIZE]			/*초기화는 MonsterData.onInit()*/
		string array ABILITY_BOX_TEXTURE_PATH[ELEMENT_TYPE_SIZE]		/*초기화는 MonsterData.onInit()*/

		/*속성배수 아이콘 경로*/
		string array ELEMENT_TYPE_VALUE_ICON_PATH[ELEMENT_TYPE_VALUE_SIZE]	/*초기화는 MonsterData.onInit()*/

		/*스탯 최소값보정여부*/
		boolean array STAT_TYPE_CLAMP[STAT_TYPE_SIZE]		/*초기화는 MonsterData.onInit()*/

	endglobals

	//! textmacro MonsterDataStatArray takes prime
		static real array $prime$_BASE[MONSTER_MAX]
		static real array $prime$_LEVEL[MONSTER_MAX]
	//! endtextmacro

	//! textmacro MonsterDataStatDefault takes prime, value1, value2
		set $prime$_BASE[i] 	= $value1$
		set $prime$_LEVEL[i] 	= $value2$
	//! endtextmacro

	//! textmacro MonsterCopyStatsByData takes prime
		call setStatValue(STAT_TYPE_$prime$,STAT_INDEX_BASE,MonsterData.$prime$_BASE[id])
		call setStatValue(STAT_TYPE_$prime$,STAT_INDEX_LEVEL,MonsterData.$prime$_LEVEL[id])
		call setStatValue(STAT_TYPE_$prime$,STAT_INDEX_INDIVISUAL,0.)
	//! endtextmacro

	//! textmacro MonsterDataDataDefault takes prime, value
		set $prime$[i]		= $value$
	//! endtextmacro

	//! textmacro MonsterCopyDataByData	takes prime, sub
		set .$sub$ = MonsterData.$prime$[id]
	//! endtextmacro

	//! textmacro MonsterCopyAbility takes num
		if MonsterData.ABILITY_ID$num$[id] > -1 then
			call addAbility(MonsterData.ABILITY_ID$num$[id])
		endif
	//! endtextmacro

	struct MonsterData

		static integer ID_CURRENT = 0
		static hashtable ELEMENT_TYPE_CHART = InitHashtable()

		static integer array 	TIER[MONSTER_MAX]
		static integer array 	ELEMENT_TYPE1[MONSTER_MAX]
		static integer array 	ELEMENT_TYPE2[MONSTER_MAX]
		static integer array 	MONSTER_RACE1[MONSTER_MAX]
		static integer array 	MONSTER_RACE2[MONSTER_MAX]
		static string array 	MODEL_PATH[MONSTER_MAX]
		static string array 	ICON_PATH[MONSTER_MAX]
		static string array 	NAME[MONSTER_MAX]
		static sound array 		SOUND[MONSTER_MAX]
		static real array 		SCALE[MONSTER_MAX]
		static real array		Z_OFFSET[MONSTER_MAX]
		static boolean array	MODEL_ALTERNATIVE[MONSTER_MAX]
		static integer array		COLOR_R[MONSTER_MAX]
		static integer array 		COLOR_G[MONSTER_MAX]
		static integer array		COLOR_B[MONSTER_MAX]
		static integer array		COLOR_A[MONSTER_MAX]
		static integer array 	ABILITY_ID1[MONSTER_MAX]
		static integer array 	ABILITY_ID2[MONSTER_MAX]
		static integer array 	ABILITY_ID3[MONSTER_MAX]
		static integer array 	ABILITY_ID4[MONSTER_MAX]
		/*스탯*/
		//! runtextmacro MonsterDataStatArray("MAXHP")
		//! runtextmacro MonsterDataStatArray("ATTACK")
		//! runtextmacro MonsterDataStatArray("DEFFENCE")
		//! runtextmacro MonsterDataStatArray("MAGICPOWER")
		//! runtextmacro MonsterDataStatArray("RESISTANCE")
		//! runtextmacro MonsterDataStatArray("SPEED")

		static method getSound takes integer id returns sound
			return SOUND[id]
		endmethod

		static method getModelPath takes integer id returns string
			return MODEL_PATH[id]
		endmethod

		static method getName takes integer id returns string
			return NAME[id]
		endmethod

		static method init takes nothing returns nothing
			local integer i = 0
			loop
				/*DEFINE DEFAULTS*/
				exitwhen i >= MONSTER_MAX
				//! runtextmacro MonsterDataDataDefault("TIER","1")
				//! runtextmacro MonsterDataDataDefault("ELEMENT_TYPE1","ELEMENT_TYPE_NORMAL")
				//! runtextmacro MonsterDataDataDefault("ELEMENT_TYPE2","ELEMENT_TYPE_NORMAL")
				//! runtextmacro MonsterDataDataDefault("MONSTER_RACE1","MONSTER_RACE_UNKNOWN")
				//! runtextmacro MonsterDataDataDefault("MONSTER_RACE2","MONSTER_RACE_UNDEFINED")
				//! runtextmacro MonsterDataDataDefault("MODEL_PATH","\"\"")
				//! runtextmacro MonsterDataDataDefault("ICON_PATH","\"\"")
				//! runtextmacro MonsterDataDataDefault("NAME","\"\"")
				//! runtextmacro MonsterDataDataDefault("SOUND","null")
				//! runtextmacro MonsterDataDataDefault("SCALE","1.0")
				//! runtextmacro MonsterDataDataDefault("Z_OFFSET","0.")
				//! runtextmacro MonsterDataDataDefault("MODEL_ALTERNATIVE","false")
				//! runtextmacro MonsterDataDataDefault("COLOR_R","255")
				//! runtextmacro MonsterDataDataDefault("COLOR_G","255")
				//! runtextmacro MonsterDataDataDefault("COLOR_B","255")
				//! runtextmacro MonsterDataDataDefault("COLOR_A","255")
				//! runtextmacro MonsterDataStatDefault("MAXHP","100.","10.")
				//! runtextmacro MonsterDataStatDefault("ATTACK","20.","2.")
				//! runtextmacro MonsterDataStatDefault("DEFFENCE","20.","2.")
				//! runtextmacro MonsterDataStatDefault("MAGICPOWER","20.","2.")
				//! runtextmacro MonsterDataStatDefault("RESISTANCE","20.","2.")
				//! runtextmacro MonsterDataStatDefault("SPEED","20.","2.")
				//! runtextmacro MonsterDataDataDefault("ABILITY_ID1","0")
				//! runtextmacro MonsterDataDataDefault("ABILITY_ID2","-1")
				//! runtextmacro MonsterDataDataDefault("ABILITY_ID3","-1")
				//! runtextmacro MonsterDataDataDefault("ABILITY_ID4","-1")
				set i = i + 1
			endloop
			//! import "monsterdata.j"
		endmethod

		static method getTypeValueIndex takes integer attack, integer deffence returns integer
			return LoadInteger(ELEMENT_TYPE_CHART,attack,deffence)
		endmethod

		private static method setTypeValueIndex takes integer attack, integer deffence, integer valueindex returns nothing
			call SaveInteger(ELEMENT_TYPE_CHART,attack,deffence,valueindex)
		endmethod

		static method onInit takes nothing returns nothing
			/*스탯 이름*/
			set STAT_TYPE_NAME[STAT_TYPE_MAXHP] 			= "최대체력"
			set STAT_TYPE_NAME[STAT_TYPE_ATTACK] 			= "공격력"
			set STAT_TYPE_NAME[STAT_TYPE_DEFFENCE]			= "방어력"
			set STAT_TYPE_NAME[STAT_TYPE_MAGICPOWER]		= "마력"
			set STAT_TYPE_NAME[STAT_TYPE_RESISTANCE]		= "저항력"
			set STAT_TYPE_NAME[STAT_TYPE_SPEED]				= "민첩성"
			/*속성 이름*/
			set ELEMENT_TYPE_NAME[ELEMENT_TYPE_NORMAL]		= "|cffdddddd일반	|r"
			set ELEMENT_TYPE_NAME[ELEMENT_TYPE_FIRE]		= "|cffff3333화염	|r"
			set ELEMENT_TYPE_NAME[ELEMENT_TYPE_WATER]		= "|cff0099ff물	|r"
			set ELEMENT_TYPE_NAME[ELEMENT_TYPE_NATURE]		= "|cff00cc00자연	|r"
			set ELEMENT_TYPE_NAME[ELEMENT_TYPE_EARTH]		= "|cffbb8866대지	|r"
			set ELEMENT_TYPE_NAME[ELEMENT_TYPE_WIND]		= "|cff7788dd바람	|r"
			set ELEMENT_TYPE_NAME[ELEMENT_TYPE_FROST]		= "|cffbbeeff냉기	|r"
			set ELEMENT_TYPE_NAME[ELEMENT_TYPE_POISON]		= "|cff446611독	|r"
			set ELEMENT_TYPE_NAME[ELEMENT_TYPE_ELECTRIC]	= "|cff00e1ff전기	|r"
			set ELEMENT_TYPE_NAME[ELEMENT_TYPE_METAL]		= "|cff999988금속	|r"
			set ELEMENT_TYPE_NAME[ELEMENT_TYPE_LIGHT]		= "|cffffff66빛	|r"
			set ELEMENT_TYPE_NAME[ELEMENT_TYPE_DARK]		= "|cff440000암흑	|r"
			set ELEMENT_TYPE_NAME[ELEMENT_TYPE_ARCANE]		= "|cffee00ff비전	|r"
			/*종족 이름*/
			set MONSTER_RACE_NAME[MONSTER_RACE_BEAST]		= "야수"
			set MONSTER_RACE_NAME[MONSTER_RACE_BIRD]		= "비행"
			set MONSTER_RACE_NAME[MONSTER_RACE_FISH]		= "수중"
			set MONSTER_RACE_NAME[MONSTER_RACE_BUG]			= "벌레"
			set MONSTER_RACE_NAME[MONSTER_RACE_HUMANLIKE]	= "인간형"
			set MONSTER_RACE_NAME[MONSTER_RACE_GHOST]		= "유령"
			set MONSTER_RACE_NAME[MONSTER_RACE_UNDEAD]		= "언데드"
			set MONSTER_RACE_NAME[MONSTER_RACE_DEMON]		= "악마"
			set MONSTER_RACE_NAME[MONSTER_RACE_MINERAL]		= "광물"
			set MONSTER_RACE_NAME[MONSTER_RACE_PLANT]		= "식물"
			set MONSTER_RACE_NAME[MONSTER_RACE_ELEMENTAL]	= "정령"
			set MONSTER_RACE_NAME[MONSTER_RACE_DRAGON]		= "용"
			set MONSTER_RACE_NAME[MONSTER_RACE_MECHANIC]	= "기계"
			set MONSTER_RACE_NAME[MONSTER_RACE_FAIRY]		= "요정"
			set MONSTER_RACE_NAME[MONSTER_RACE_DIVINE]		= "성물"
			set MONSTER_RACE_NAME[MONSTER_RACE_UNKNOWN]		= "불명"
			/*상성배수 실제값*/
			set ELEMENT_TYPE_VALUE[ELEMENT_TYPE_VALUE_VERY_WEAK]	= 0.5
			set ELEMENT_TYPE_VALUE[ELEMENT_TYPE_VALUE_WEAK]			= 0.8
			set ELEMENT_TYPE_VALUE[ELEMENT_TYPE_VALUE_NORMAL]		= 1.0
			set ELEMENT_TYPE_VALUE[ELEMENT_TYPE_VALUE_STRONG]		= 1.25
			set ELEMENT_TYPE_VALUE[ELEMENT_TYPE_VALUE_VERY_STRONG]	= 2.
			/*상성배수*/
			//! import "definetypevalue.j"
			/*속성아이콘*/
			set ELEMENT_TYPE_ICON_PATH[ELEMENT_TYPE_NORMAL]		= "ui\\element_type_icon_hex_normal.mdl"
			set ELEMENT_TYPE_ICON_PATH[ELEMENT_TYPE_FIRE]		= "ui\\element_type_icon_hex_fire.mdl"
			set ELEMENT_TYPE_ICON_PATH[ELEMENT_TYPE_WATER]		= "ui\\element_type_icon_hex_water.mdl"
			set ELEMENT_TYPE_ICON_PATH[ELEMENT_TYPE_NATURE]		= "ui\\element_type_icon_hex_nature.mdl"
			set ELEMENT_TYPE_ICON_PATH[ELEMENT_TYPE_EARTH]		= "ui\\element_type_icon_hex_earth.mdl"
			set ELEMENT_TYPE_ICON_PATH[ELEMENT_TYPE_WIND]		= "ui\\element_type_icon_hex_wind.mdl"
			set ELEMENT_TYPE_ICON_PATH[ELEMENT_TYPE_FROST]		= "ui\\element_type_icon_hex_frost.mdl"
			set ELEMENT_TYPE_ICON_PATH[ELEMENT_TYPE_POISON]		= "ui\\element_type_icon_hex_poison.mdl"
			set ELEMENT_TYPE_ICON_PATH[ELEMENT_TYPE_ELECTRIC]	= "ui\\element_type_icon_hex_electric.mdl"
			set ELEMENT_TYPE_ICON_PATH[ELEMENT_TYPE_METAL]		= "ui\\element_type_icon_hex_metal.mdl"
			set ELEMENT_TYPE_ICON_PATH[ELEMENT_TYPE_LIGHT]		= "ui\\element_type_icon_hex_light.mdl"
			set ELEMENT_TYPE_ICON_PATH[ELEMENT_TYPE_DARK]		= "ui\\element_type_icon_hex_dark.mdl"
			set ELEMENT_TYPE_ICON_PATH[ELEMENT_TYPE_ARCANE]		= "ui\\element_type_icon_hex_arcane.mdl"
			/*어빌박스 텍스쳐*/
			set ABILITY_BOX_TEXTURE_PATH[ELEMENT_TYPE_NORMAL]		= "textures\\ability_box_normal.mdl"
			set ABILITY_BOX_TEXTURE_PATH[ELEMENT_TYPE_FIRE]			= "textures\\ability_box_fire.mdl"
			set ABILITY_BOX_TEXTURE_PATH[ELEMENT_TYPE_WATER]		= "textures\\ability_box_water.mdl"
			set ABILITY_BOX_TEXTURE_PATH[ELEMENT_TYPE_NATURE]		= "textures\\ability_box_nature.mdl"
			set ABILITY_BOX_TEXTURE_PATH[ELEMENT_TYPE_EARTH]		= "textures\\ability_box_earth.mdl"
			set ABILITY_BOX_TEXTURE_PATH[ELEMENT_TYPE_WIND]			= "textures\\ability_box_wind.mdl"
			set ABILITY_BOX_TEXTURE_PATH[ELEMENT_TYPE_FROST]		= "textures\\ability_box_frost.mdl"
			set ABILITY_BOX_TEXTURE_PATH[ELEMENT_TYPE_POISON]		= "textures\\ability_box_poison.mdl"
			set ABILITY_BOX_TEXTURE_PATH[ELEMENT_TYPE_ELECTRIC]		= "textures\\ability_box_electric.mdl"
			set ABILITY_BOX_TEXTURE_PATH[ELEMENT_TYPE_METAL]		= "textures\\ability_box_metal.mdl"
			set ABILITY_BOX_TEXTURE_PATH[ELEMENT_TYPE_LIGHT]		= "textures\\ability_box_light.mdl"
			set ABILITY_BOX_TEXTURE_PATH[ELEMENT_TYPE_DARK]			= "textures\\ability_box_dark.mdl"
			set ABILITY_BOX_TEXTURE_PATH[ELEMENT_TYPE_ARCANE]		= "textures\\ability_box_arcane.mdl"
			/*상성배수 아이콘*/
			set ELEMENT_TYPE_VALUE_ICON_PATH[ELEMENT_TYPE_VALUE_VERY_WEAK]		= "ui\\element_type_value_icon_very_weak.mdl"
			set ELEMENT_TYPE_VALUE_ICON_PATH[ELEMENT_TYPE_VALUE_WEAK]			= "ui\\element_type_value_icon_weak.mdl"
			set ELEMENT_TYPE_VALUE_ICON_PATH[ELEMENT_TYPE_VALUE_NORMAL]			= "ui\\element_type_value_icon_normal.mdl"
			set ELEMENT_TYPE_VALUE_ICON_PATH[ELEMENT_TYPE_VALUE_STRONG]			= "ui\\element_type_value_icon_strong.mdl"
			set ELEMENT_TYPE_VALUE_ICON_PATH[ELEMENT_TYPE_VALUE_VERY_STRONG]	= "ui\\element_type_value_icon_very_strong.mdl"
			/*스탯최소값보정여부*/
			set STAT_TYPE_CLAMP[STAT_TYPE_MAXHP] 		= true
			set STAT_TYPE_CLAMP[STAT_TYPE_ATTACK] 		= true
			set STAT_TYPE_CLAMP[STAT_TYPE_DEFFENCE] 	= false
			set STAT_TYPE_CLAMP[STAT_TYPE_MAGICPOWER] 	= true
			set STAT_TYPE_CLAMP[STAT_TYPE_RESISTANCE] 	= false
			set STAT_TYPE_CLAMP[STAT_TYPE_SPEED] 		= true
		endmethod

	endstruct

endlibrary

library Character requires Effect, KeyInput, BattleRequest, MonsterAbility, FieldRegion

	struct Character extends Effect

		boolean move_success	= false

		method move takes real x, real y, real z returns nothing
			call LocationEx.collisionProjection(x,y)
			set .move_success = RAbsBJ(x-LocationEx.getX()) + RAbsBJ(y-LocationEx.getY()) < 3.
			if .move_success then
				call setX(LocationEx.getX())
				call setY(LocationEx.getY())
				call setZ(LocationEx.getZ()+z)
			endif
		endmethod

		static method create takes string modelpath, real x, real y, real z, real yaw returns thistype
			local thistype this = allocate(modelpath,x,y,0.,yaw)
			call setOffsetZ(z)
			return this
		endmethod

	endstruct

	struct PlayerCharacter extends Character

		private static constant string PLAYER_CHARACTER_MODEL_PATH 	= "units\\human\\Peasant\\Peasant.mdl"
		private static constant real MOVE_SPEED 					= 450.
		private static constant real ROTATION_SPEED 				= 1.35

		private static thistype array LIST[32]

		private KeyInput input 		= 0
		player owner 				= null
		private timer work_timer 	= null
		private real move_speed 	= 0.
		private boolean walk 		= false
		boolean onbattle 			= false
		real encounter_ignore		= 0.
		integer region_current		= HOMETOWN
		boolean suspend				= false
		EnteranceUI enterance_ui	= 0

		private method adjustCurrentRegion takes nothing returns nothing
			local boolean changed = false
			local integer afield = FieldRegion.adjust(getX(),getY())
			if afield != -1 and .region_current != afield then
				set .region_current = afield
				call .enterance_ui.showMapEnterance(Field.FIELD[.region_current])
				call Field.FIELD[.region_current].awake()
			endif
		endmethod

		static method getPlayerCharacter takes player p returns thistype
			return LIST[GetPlayerId(p)]
		endmethod

		private static method b2I takes boolean b returns integer
			if b then
				return 1
			else
				return 0
			endif
		endmethod

		method pauseWorkTimer takes nothing returns nothing
			call Timer.pause(work_timer)
			if .walk then
				call setAnim(ANIM_TYPE_STAND)
			endif
			set .walk = false
		endmethod

		static method workTimer takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			local integer x_vec = b2I(.input.getKeyState(KEY_INPUT_RIGHT))	-b2I(.input.getKeyState(KEY_INPUT_LEFT))
			local integer y_vec = b2I(.input.getKeyState(KEY_INPUT_UP))		-b2I(.input.getKeyState(KEY_INPUT_DOWN))
			local real angle = 0.
			if x_vec != 0 or y_vec != 0 and not .suspend then
				set angle = Atan2(y_vec,x_vec)
				call move(getX()+(MOVE_SPEED*TIMER_TICK)*Cos(angle),getY()+(MOVE_SPEED*TIMER_TICK)*Sin(angle),0.)
				/*이동구문 이후에 현재 로케이션 탐색*/
				call adjustCurrentRegion()
				/*걷기 애니메이션 재생*/
				if not .walk then
					call setAnim(ANIM_TYPE_WALK)
				endif
				set .walk = true
				/*방향 회전*/
				call setYaw(Rad2Deg(angle))
			else
				/*서있기 애니메이션 재생*/
				if .walk then
					call setAnim(ANIM_TYPE_STAND)
				endif
				set .walk = false
			endif
			/*인카운터 면역*/
			if .encounter_ignore > 0. then
				set .encounter_ignore = .encounter_ignore - TIMER_TICK
				if .encounter_ignore < 0. then
					set .encounter_ignore = 0.
					call setAlpha(255)
				endif
			endif
		endmethod

		method startWorkTimer takes nothing returns nothing
			call Timer.start(.work_timer,TIMER_TICK,true,function thistype.workTimer)
		endmethod

		static method create takes player p returns thistype
			local thistype this = 0
			if LIST[GetPlayerId(p)] == 0 then
				set this = allocate(PLAYER_CHARACTER_MODEL_PATH,/*
					*/GetRectCenterX(gg_rct_spawn)+GetRandomInt(-128,128),GetRectCenterY(gg_rct_spawn)+GetRandomInt(-128,128),0,GetRandomReal(0.,360.))
				set .owner 		= p
				set .input 		= KeyInput.create(.owner)
				set .work_timer = Timer.new(this)
				set .move_speed = MOVE_SPEED
				set .enterance_ui = EnteranceUI.create(.owner)
				call startWorkTimer()
				call setTeamColor(.owner)
				set LIST[GetPlayerId(p)] = this
				return this
			else
				return LIST[GetPlayerId(p)]
			endif
		endmethod

		private method onDestroy takes nothing returns nothing
			call .input.destroy()
			call Timer.release(.work_timer)
			set .work_timer = null
			set .owner 		= null
			set .input 		= 0
			call .enterance_ui.destroy()
		endmethod

	endstruct

	struct MonsterCharacter extends Character

		private static constant real ACTION_PERIOD_MIN = 1.5
		private static constant real ACTION_PERIOD_MAX = 3.5
		private static constant real MOVE_SPEED_WONDERING_MIN = 75.
		private static constant real MOVE_SPEED_WONDERING_MAX = 175.
		private static constant real MOVE_SPEED_AGGRESSIVE = 350.
		private static constant real MOVE_DEBUG_TIMEOUT = 2.
		private static constant string MOVE_DEBUG_EFFECT_PATH1 = "Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl"
		private static constant string MOVE_DEBUG_EFFECT_PATH2 = "Abilities\\Spells\\NightElf\\Blink\\BlinkTarget.mdl"
		private static constant string AGGRESSIVE_EFFECT_PATH = "Effects\\MonsterAggressiveRed.mdl"
		private static constant real AGGRESSIVE_DELAY = 0.75

		integer monster_id 		= 0
		integer field_id		= 0
		real origin_x 			= 0.
		real origin_y 			= 0.
		real target_x 			= 0.
		real target_y 			= 0.
		real wondering_range 	= 350.
		real move_speed 		= 250.
		real move_debug			= 0.	/*끼어서 못움직이면 디버그*/
		boolean walk 			= false
		real timer_elapsed 		= 0.
		real action_period 		= 3.5
		real collision_radius 	= 75.
		boolean aggressive 		= true
		real aggressive_range 	= 250.
		real aggressive_max_range = 475.
		real aggressive_stun 	= 0.
		boolean onbattle		= false
		real encounter_ignore	= 0.

		PlayerCharacter target_character = 0
		Effect effect_aggressive = 0

		timer work_timer = null
		sound aggressive_sound = null

		method pauseWorkTimer takes nothing returns nothing
			call Timer.pause(.work_timer)
			if .walk then
				call setAnim(ANIM_TYPE_STAND)
			endif
			call .effect_aggressive.setAnim(ANIM_TYPE_STAND)
			set .walk = false
		endmethod

		method encounter takes player p returns nothing
			call BattleRequest.request(PlayerCharacter.getPlayerCharacter(p),this,Field.FIELD[PlayerCharacter.getPlayerCharacter(p).region_current])
		endmethod

		method executeMove takes nothing returns nothing
			local real ra = 0.
			set .move_success = false
			/*이동액션&도달 시 정지&애니메이션 스테이트 제어*/
			if Math.distancePoints(getX(),getY(),.target_x,.target_y) <= move_speed * TIMER_TICK then
				call move(.target_x,.target_y,0.)
				if .walk then
					call setAnim(ANIM_TYPE_STAND)
					set .walk = false
				endif
			else
				set ra = Math.anglePoints(getX(),getY(),.target_x,.target_y)
				call move(Math.pPX(getX(),move_speed*TIMER_TICK,ra),Math.pPY(getY(),move_speed*TIMER_TICK,ra),0.)
				call setYaw(ra)
				if not .walk then
					call setAnim(ANIM_TYPE_WALK)
					set .walk = true
				endif
			endif
			/*무빙 디버그게이지*/
			if .move_success then
				set .move_debug = .move_debug - TIMER_TICK*0.5
				if .move_debug < 0. then
					set .move_debug = 0.
				endif
			else
				set .move_debug = .move_debug + TIMER_TICK
				if .move_debug >= MOVE_DEBUG_TIMEOUT then
					/*타겟 해제, 원좌표 복귀*/
					call Effect.create(MOVE_DEBUG_EFFECT_PATH1,getX(),getY(),0,0).setDuration(1.5)
					set .target_character = 0
					call .effect_aggressive.setAnim(ANIM_TYPE_STAND)
					call setX(.origin_x)
					call setY(.origin_y)
					set .target_x = .origin_x
					set .target_y = .origin_y
					set .move_debug = 0.
					call Effect.create(MOVE_DEBUG_EFFECT_PATH2,getX(),getY(),0,0).setDuration(1.5)
				endif
			endif
			/*어그로이펙트 위치 동기화*/
			call .effect_aggressive.setPosition(getX(),getY(),getZ())
		endmethod
		
		private static method workTimer takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			local real ra = 0.
			local real rd = 0.
			local integer i = 0
			local PlayerCharacter pc = 0
			if .target_character == 0 then
			/*타겟이 없을 때*/
				/*무빙 or NOT*/
				set .timer_elapsed = .timer_elapsed + TIMER_TICK
				if .timer_elapsed >= .action_period then
					/*이동좌표 설정*/
					set ra = GetRandomReal(0.,360.)
					set rd = GetRandomReal(0.,.wondering_range)
					set .target_x = Math.pPX(.origin_x,rd,ra)
					set .target_y = Math.pPY(.origin_y,rd,ra)
					set .timer_elapsed = .timer_elapsed - .action_period
					set .action_period = GetRandomReal(ACTION_PERIOD_MIN,ACTION_PERIOD_MAX)
					set .move_speed = GetRandomReal(MOVE_SPEED_WONDERING_MIN,MOVE_SPEED_WONDERING_MAX)
					if not .walk then
						call setAnim(ANIM_TYPE_WALK)
						set .walk = true
					endif
				else	
					call executeMove()
				endif
			else
			/*타겟이 있을 때*/
				if Math.distancePoints(getX(),getY(),.target_character.getX(),.target_character.getY()) > .aggressive_max_range or .target_character.onbattle then
					/*멀어지거나 이미 인카운트 된 대상이면 추적 종료*/
					set .target_character = 0
					call .effect_aggressive.setAnim(ANIM_TYPE_STAND)
					set .target_x = .origin_x
					set .target_y = .origin_y
				else
					set .target_x = .target_character.getX()
					set .target_y = .target_character.getY()
					/*최초발견 경직상태일때는 일단 정지*/
					if .aggressive_stun > 0. then
						set .aggressive_stun = .aggressive_stun - TIMER_TICK
						if .aggressive_stun < 0. then
							set .aggressive_stun = 0.
						endif
						call setYaw(Math.anglePoints(getX(),getY(),.target_character.getX(),.target_character.getY()))
					else
						/*경직게이지 없을때에만 대상을 향해 이동*/
						call executeMove()
					endif
				endif
			endif
			/*플레이어 인식*/
			loop
				exitwhen i >= PLAYER_MAX
				set pc = PlayerCharacter.getPlayerCharacter(Player(i))
				if pc != 0 then
					set rd = Math.distancePoints(getX(),getY(),pc.getX(),pc.getY())
					if not .onbattle and not pc.onbattle and pc.encounter_ignore == 0. and .encounter_ignore == 0. then
						/*캐릭터가 배틀상태가 아닐때&플레이어가 인카운터 무적이 아닐때*/
						if rd <= .collision_radius then
							/*충돌범위에 닿으면 인카운터*/
							call encounter(Player(i))
							exitwhen true
						elseif rd <= .aggressive_range and .target_character == 0 and .aggressive then
							/*인식범위에 닿으면 타겟설정(기존 타겟이 없을때만)*/
							set .target_character = pc
							set .move_speed = MOVE_SPEED_AGGRESSIVE
							call .effect_aggressive.setAnim(ANIM_TYPE_WALK)
							set .aggressive_stun = AGGRESSIVE_DELAY
							if GetLocalPlayer() == Player(i) then
								/*효과음 재생*/
								call PlaySoundBJ(.aggressive_sound)
							endif
							exitwhen true
						endif
					endif
				endif
				set i = i + 1
			endloop
			/*인카운터무시 게이지가 0 보다 높을때*/
			if .encounter_ignore > 0. then
				set .encounter_ignore = .encounter_ignore - TIMER_TICK
				if .encounter_ignore <= 0. then
					call setAlpha(MonsterData.COLOR_A[.monster_id])
					set .encounter_ignore = 0.
				endif
			endif
		endmethod

		method startWorkTimer takes nothing returns nothing
			call Timer.start(.work_timer,TIMER_TICK,true,function thistype.workTimer)
		endmethod

		static method create takes integer id, real x, real y, real yaw returns thistype
			local thistype this = allocate(MonsterData.getModelPath(id),x,y,MonsterData.Z_OFFSET[id],yaw)
			set .origin_x = x
			set .origin_y = y
			set .target_x = x
			set .target_y = y
			set .monster_id = id
			set .work_timer = Timer.new(this)
			set .wantremove = true
			set .effect_aggressive = Effect.create(AGGRESSIVE_EFFECT_PATH,getX(),getY(),0,270)
			set .aggressive_sound = MonsterData.getSound(id)
			set .encounter_ignore = 4.
			call setScale(MonsterData.SCALE[id])
			call setColor(MonsterData.COLOR_R[id],MonsterData.COLOR_G[id],MonsterData.COLOR_B[id],R2I(0.5*MonsterData.COLOR_A[.monster_id]))
			call setTeamColor(Player(PLAYER_NEUTRAL_AGGRESSIVE))
			call startWorkTimer()
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call Timer.release(.work_timer)
			set .work_timer = null
			set .aggressive_sound = null
		endmethod

	endstruct

	struct Monster

		static hashtable HASH = InitHashtable()
		/*데이터에서 로드해야하는 것들*/
		integer tier = 1
		integer element_type1 = ELEMENT_TYPE_NORMAL		/*속성*/
		integer element_type2 = ELEMENT_TYPE_NORMAL
		integer monster_race1 = MONSTER_RACE_UNKNOWN	/*종족*/
		integer monster_race2 = MONSTER_RACE_UNKNOWN
		string model_path = ""
		string icon_path = ""
		string name = ""
		sound sound = null
		real scale = 1.0
		real z_offset = 0.
		boolean model_alternative = false

		/*MonsterAbility array monster_ability[MONSTER_ABILITY_COUNT_MAX]*/
		integer id		= -1	/*몹 종류*/
		integer level 	= 1		/*레벨*/
		real hp			= 1.
		integer	exp		= 0
		boolean alive = true						/*생존여부*/
		boolean onbattle = false					/*전투여부*/
		boolean front = true						/*진형배치*/

		method setLevel takes integer i returns nothing
			local real hp_ratio = .hp/getBaseStat(STAT_TYPE_MAXHP)
			if i > .level then
				set .level = i
			endif
			set .hp = getBaseStat(STAT_TYPE_MAXHP) * hp_ratio
			if .exp < getTotalMinExp() then
				set .exp = getTotalMinExp()
			endif
		endmethod

		static method getTotalMaxExpByInteger takes integer i returns integer
			return EXP_BASE + (EXP_PER_LEVEL + EXP_PER_LEVEL_PER_LEVEL * i ) * i
		endmethod

		/**/
		static method getTotalMinExpByInteger takes integer i returns integer
			if i < 1 then
				return 0
			else
				return EXP_BASE + (EXP_PER_LEVEL + EXP_PER_LEVEL_PER_LEVEL * (i-1) ) * (i-1)
			endif
		endmethod

		static method getCarculatedMaxExpByInteger takes integer i returns integer
			return getTotalMaxExpByInteger(i)-getTotalMinExpByInteger(i)
		endmethod

		method getTotalMaxExp takes nothing returns integer
			return getTotalMaxExpByInteger(.level)
		endmethod

		method getTotalMinExp takes nothing returns integer
			return getTotalMinExpByInteger(.level)
		endmethod

		method getCarculatedMaxExp takes nothing returns integer
			return getCarculatedMaxExpByInteger(.level)
		endmethod

		method getCarculatedExp takes nothing returns integer
			return .exp - getTotalMinExp()
		endmethod

		method addExp takes integer i returns nothing
			if i > 0 then
				set .exp = .exp + i
				loop
					exitwhen .exp < getTotalMaxExp()
					call setLevel(.level+1)
				endloop
			endif
		endmethod

		method getMonsterAbility takes integer i returns MonsterAbility
			if HaveSavedInteger(HASH,this,i+2000) then
				return LoadInteger(HASH,this,i+2000)
			else
				return 0
			endif
		endmethod

		method setMonsterAbility takes integer i, MonsterAbility na returns nothing
			if na <= 0 then
				call RemoveSavedInteger(HASH,this,i+2000)
			else
				call SaveInteger(HASH,this,i+2000,na)
			endif
		endmethod

		method getStatValue takes integer stattype, integer indextype returns real
			return LoadReal(HASH,this,stattype+(indextype*STAT_INDEX_SIZE))
		endmethod

		method setStatValue takes integer stattype, integer indextype, real value returns nothing
			call SaveReal(HASH,this,stattype+(indextype*STAT_INDEX_SIZE),value)
		endmethod

		method getBaseStat takes integer index returns real
			return getStatValue(index,STAT_INDEX_BASE) + getStatValue(index,STAT_INDEX_INDIVISUAL) + getStatValue(index,STAT_INDEX_LEVEL) * (.level-1)
		endmethod

		method removeAbility takes integer index returns nothing
			local integer i = index
			if getMonsterAbility(index) != 0 then
				call getMonsterAbility(index).destroy()
			endif
			call setMonsterAbility(index,0)
			loop
				if i >= MONSTER_ABILITY_COUNT_MAX - 1  then
					call setMonsterAbility(index,0)
					exitwhen true
				else
					call setMonsterAbility(index,getMonsterAbility(index+1))
				endif
				set i = i + 1
			endloop
		endmethod

		method addAbility takes integer id returns integer
			local integer i = 0
			loop
				exitwhen i >= MONSTER_ABILITY_COUNT_MAX
				if getMonsterAbility(i) ==  0 then
					call setMonsterAbility(i,MonsterAbility.create(id))
					return 1
				endif
				set i = i + 1
			endloop
			return 0
		endmethod

		private method initializeAbilityByDaya takes integer id returns nothing
			/*어빌리티의 경우는 다른 함수를 써서 복사*/
			//! runtextmacro MonsterCopyAbility("1")
			//! runtextmacro MonsterCopyAbility("2")
			//! runtextmacro MonsterCopyAbility("3")
			//! runtextmacro MonsterCopyAbility("4")
		endmethod

		private method initializeStatsByData takes integer id returns nothing
			//! runtextmacro MonsterCopyDataByData("TIER","tier")
			//! runtextmacro MonsterCopyDataByData("ELEMENT_TYPE1","element_type1")
			//! runtextmacro MonsterCopyDataByData("ELEMENT_TYPE2","element_type2")
			//! runtextmacro MonsterCopyDataByData("MONSTER_RACE1","monster_race1")
			//! runtextmacro MonsterCopyDataByData("MONSTER_RACE2","monster_race2")
			//! runtextmacro MonsterCopyDataByData("MODEL_PATH","model_path")
			//! runtextmacro MonsterCopyDataByData("ICON_PATH","icon_path")
			//! runtextmacro MonsterCopyDataByData("NAME","name")
			//! runtextmacro MonsterCopyDataByData("SOUND","sound")
			//! runtextmacro MonsterCopyDataByData("SCALE","scale")
			//! runtextmacro MonsterCopyDataByData("Z_OFFSET","z_offset")
			//! runtextmacro MonsterCopyDataByData("MODEL_ALTERNATIVE","model_alternative")
			//! runtextmacro MonsterCopyStatsByData("MAXHP")
			//! runtextmacro MonsterCopyStatsByData("ATTACK")
			//! runtextmacro MonsterCopyStatsByData("DEFFENCE")
			//! runtextmacro MonsterCopyStatsByData("MAGICPOWER")
			//! runtextmacro MonsterCopyStatsByData("RESISTANCE")
			//! runtextmacro MonsterCopyStatsByData("SPEED")
			/**/
		endmethod

		method evolve takes integer target_id returns nothing
			set .id = target_id
			set .tier = MonsterData.TIER[.id]
			call initializeStatsByData(target_id)
		endmethod

		static method create takes integer id returns thistype
			local thistype this = allocate()
			set .id = id
			if id > -1 then
				call initializeStatsByData(id)
				call initializeAbilityByDaya(id)
			endif
			set .hp = getBaseStat(STAT_TYPE_MAXHP)
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			local integer i = 0
			/**/
			set .sound = null
			loop
				exitwhen i >= MONSTER_ABILITY_MAX
				if getMonsterAbility(i) != 0 then
					call getMonsterAbility(i).destroy()
					call setMonsterAbility(i,0)
				endif
				set i = i + 1
			endloop
		endmethod

	endstruct

	//! textmacro BattleMonsterCopyStats takes sub
		set .$sub$ = tm.$sub$
	//! endtextmacro

	struct BattleMonster extends Monster

		player owner = null
		real ap = 0.								/*행동력게이지*/
		boolean catched = false						/*잡혔는지 여부*/
		Monster origin_monster = 0

		integer color_r = 255
		integer color_g = 255
		integer color_b = 255
		integer color_a = 255

		/*제거해줘야함*/
		/*BattleMonsterAbility array battle_monster_ability[MONSTER_ABILITY_COUNT_MAX]*/
		Effect effect = 0

		method getBattleMonsterAbility takes integer i returns BattleMonsterAbility
			if HaveSavedInteger(Monster.HASH,this,i+4000) then
				return LoadInteger(Monster.HASH,this,i+4000)
			else
				return 0
			endif
		endmethod

		method setBattleMonsterAbility takes integer i, BattleMonsterAbility na returns nothing
			if na <= 0 then
				call RemoveSavedInteger(Monster.HASH,this,i+4000)
			else
				call SaveInteger(Monster.HASH,this,i+4000,na)
			endif
		endmethod

		private method clamp takes integer index, real value returns real
			if STAT_TYPE_CLAMP[index] and value <= 0.1 then
				return 0.1
			else
				return value
			endif
		endmethod

		method getCarculatedStat takes integer index returns real
			return clamp(index,( ( ( getBaseStat(index) + getStatValue(index,STAT_INDEX_PLUS) ) * /*
				*/getStatValue(index,STAT_INDEX_MULTIFLY) ) / getStatValue(index,STAT_INDEX_DEVIDE) ) - getStatValue(index,STAT_INDEX_MINUS))
		endmethod

		method multiplyStat takes integer index, real val returns nothing
			local real hp_ratio = 0.
			if index == STAT_TYPE_MAXHP then
				set hp_ratio = .hp / getCarculatedStat(STAT_TYPE_MAXHP)
				call setStatValue(index,STAT_INDEX_MULTIFLY,getStatValue(index,STAT_INDEX_MULTIFLY)+val)
				set .hp = getCarculatedStat(STAT_TYPE_MAXHP)
			else
				call setStatValue(index,STAT_INDEX_MULTIFLY,getStatValue(index,STAT_INDEX_MULTIFLY)+val)
			endif
		endmethod

		method addAP takes nothing returns nothing
			set .ap = .ap + AP_PER_SECOND * TIMER_TICK * ((100.+getCarculatedStat(STAT_TYPE_SPEED))/100.)
		endmethod

		method kill takes nothing returns nothing
			if .alive then
				set .alive = false
				set .origin_monster.alive = false
				call .effect.setAnim(ANIM_TYPE_DEATH)
			endif
		endmethod

		method revive takes nothing returns nothing
			if not .alive then
				set .alive = true
				set .origin_monster.alive = true
				call .effect.setAnim(ANIM_TYPE_STAND)
			endif
		endmethod

		method damageToTarget takes thistype target, integer t1, integer t2, integer dt, real damage returns real
			local real value = damage
			local real hp_reduced = 0.
			local real armor = 0.
			if dt == DAMAGE_TYPE_TRUE then
			else
				if dt == DAMAGE_TYPE_PHYSICAL then
					set armor = target.getCarculatedStat(STAT_TYPE_DEFFENCE)
				elseif dt == DAMAGE_TYPE_MAGICAL then
					set armor = target.getCarculatedStat(STAT_TYPE_RESISTANCE)
				endif
				/*1차가공(방어력)*/
				if armor >= 0. then
					set value = value * 100./(100.+armor*0.01)
				else
					set value = value * 1.+(-armor)*0.01
				endif
			endif
			/*2차가공(속성)*/
			set value = value * /*
				*/ELEMENT_TYPE_VALUE[MonsterData.getTypeValueIndex(t1,target.element_type1)] */*
				*/ELEMENT_TYPE_VALUE[MonsterData.getTypeValueIndex(t1,target.element_type2)] */*
				*/ELEMENT_TYPE_VALUE[MonsterData.getTypeValueIndex(t2,target.element_type1)] */*
				*/ELEMENT_TYPE_VALUE[MonsterData.getTypeValueIndex(t2,target.element_type2)]
			/*데미지텍스트*/
			call InstantText.create(target.effect.getX(),target.effect.getY(),target.effect.getZ()+100,I2S(R2I(value)))
			/*죽었는지 판별&체력감소*/
			if value >= target.hp then
				set hp_reduced = target.hp
				set target.hp = 0.
				call target.kill()
			else
				set hp_reduced = value
				set target.hp = target.hp - value
			endif
			return hp_reduced
		endmethod

		private method initialize takes nothing returns nothing
			/*몹 종류에 관계없이 동일하게 수행되는 함수*/
			local integer i = 0
			loop
				exitwhen i >= STAT_TYPE_SIZE
				call setStatValue(i,STAT_INDEX_MULTIFLY,1.)
				call setStatValue(i,STAT_INDEX_DEVIDE,1.)
				call setStatValue(i,STAT_INDEX_PLUS,0.)
				call setStatValue(i,STAT_INDEX_MINUS,0.)
				set i = i + 1
			endloop
			/*모델 생성&크기, 고도 조정*/
			set .effect = Effect.create(.model_path,0,0,0,0).setScale(.scale)
			call .effect.setOffsetZ(.z_offset)
			call .effect.setScale(.scale)
			call .effect.setColor(.color_r,.color_g,.color_b,.color_a)
			if .model_alternative then
				call .effect.setSubAnim(SUBANIM_TYPE_ALTERNATE_EX)
			endif
		endmethod

		private method copyStats takes Monster tm returns nothing
			local integer i = 0
			/*원본몹에게서 기본능력치 복사*/
			loop
				exitwhen i >= STAT_TYPE_SIZE
				call setStatValue(i,STAT_INDEX_BASE,tm.getStatValue(i,STAT_INDEX_BASE))
				call setStatValue(i,STAT_INDEX_LEVEL,tm.getStatValue(i,STAT_INDEX_LEVEL))
				call setStatValue(i,STAT_INDEX_INDIVISUAL,tm.getStatValue(i,STAT_INDEX_INDIVISUAL))
				set i = i + 1
			endloop
			/*그 외 능력치 복사*/
			//! runtextmacro BattleMonsterCopyStats("tier")
			//! runtextmacro BattleMonsterCopyStats("id")
			//! runtextmacro BattleMonsterCopyStats("level")
			//! runtextmacro BattleMonsterCopyStats("hp")
			//! runtextmacro BattleMonsterCopyStats("exp")
			//! runtextmacro BattleMonsterCopyStats("model_path")
			//! runtextmacro BattleMonsterCopyStats("icon_path")
			//! runtextmacro BattleMonsterCopyStats("name")
			//! runtextmacro BattleMonsterCopyStats("sound")
			//! runtextmacro BattleMonsterCopyStats("scale")
			//! runtextmacro BattleMonsterCopyStats("z_offset")
			//! runtextmacro BattleMonsterCopyStats("model_alternative")
			//! runtextmacro BattleMonsterCopyStats("element_type1")
			//! runtextmacro BattleMonsterCopyStats("element_type2")
			//! runtextmacro BattleMonsterCopyStats("monster_race1")
			//! runtextmacro BattleMonsterCopyStats("monster_race2")
			//! runtextmacro BattleMonsterCopyStats("front")
			/*배틀몬스터 전용 능력치*/
			//! runtextmacro MonsterCopyDataByData("COLOR_R","color_r")
			//! runtextmacro MonsterCopyDataByData("COLOR_G","color_g")
			//! runtextmacro MonsterCopyDataByData("COLOR_B","color_b")
			//! runtextmacro MonsterCopyDataByData("COLOR_A","color_a")
			/*어빌리티 복사*/
			set  i = 0
			loop
				exitwhen i >= 4
				if tm.getMonsterAbility(i) != 0 then
					call setBattleMonsterAbility(i,BattleMonsterAbility.create(tm.getMonsterAbility(i)))
				endif
				set i = i + 1
			endloop
			/**/
			
		endmethod

		static method create takes Monster tm, player owner returns thistype
			/*원본 필요*/
			local thistype this = allocate(-1)
			set .origin_monster = tm
			set .owner = owner
			call copyStats(.origin_monster)
			call initialize()
			return this
		endmethod

		/*static method createInstant takes integer id, integer level returns thistype
			/*원본 불필요*/
			local thistype this = allocate(id)
			set .level = level
			call initialize()
			return this
		endmethod*/

		method onDestroy takes nothing returns nothing
			local integer i = 0
			/*어빌리티 제거*/
			loop
				exitwhen i >= MONSTER_ABILITY_COUNT_MAX
				if getBattleMonsterAbility(i) != 0 then
					call getBattleMonsterAbility(i).destroy()
					call setBattleMonsterAbility(i,0)
				endif
				set i = i + 1
			endloop
			/*이펙트 제거*/
			if .effect != 0 then
				set effect.wantremove = true
				call effect.destroy()
			endif
			set .owner = null
		endmethod

	endstruct

endlibrary