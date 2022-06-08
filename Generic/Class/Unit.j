library UnitPrototype

	globals
		constant integer STAT_TYPE_MAXHP 			= 0
		constant integer STAT_TYPE_MAXMP 			= 1
		constant integer STAT_TYPE_ATTACK			= 2
		constant integer STAT_TYPE_DEFFENCE 		= 3
		constant integer STAT_TYPE_MAGICPOWER		= 4
		constant integer STAT_TYPE_RESISTANCE		= 5
		constant integer STAT_TYPE_ACCURACY			= 6
		constant integer STAT_TYPE_EVASION			= 7
		constant integer STAT_TYPE_ARMOR_PENET		= 8
		constant integer STAT_TYPE_MAGIC_PENET		= 9
		constant integer STAT_TYPE_SPELL_BOOST		= 10
		constant integer STAT_TYPE_MOVEMENT_SPEED 	= 11
		constant integer STAT_TYPE_ATTACK_SPEED		= 12
		constant integer STAT_TYPE_LUCK				= 13
		constant integer STAT_TYPE_ATTACK_RANGE 	= 14
		constant integer STAT_TYPE_HPREGEN			= 15
		constant integer STAT_TYPE_MPREGEN			= 16
		constant integer STAT_TYPE_HEAL_AMP			= 17
		constant integer STAT_TYPE_SIZE				= 18

		constant integer STAT_INDEX_BASE			= 0
		constant integer STAT_INDEX_LEVEL			= 1
		constant integer STAT_INDEX_MULTIPLY		= 2
		constant integer STAT_INDEX_DIVIDE			= 3
		constant integer STAT_INDEX_PLUS			= 4
		constant integer STAT_INDEX_MINUS			= 5
		constant integer STAT_INDEX_SIZE			= 6

		boolean array STAT_TYPE_CLAMP[STAT_TYPE_SIZE]
		string array STAT_TYPE_NAME[STAT_TYPE_SIZE]
		real array STAT_NORMAL_VALUE[STAT_TYPE_SIZE]

		constant integer ABILITY_SIZE		= 10

		constant integer ITEM_SIZE			= 6

		constant integer STATUS_STUN			= 0
		constant integer STATUS_ENSNARE			= 1
		constant integer STATUS_DISARM			= 2
		constant integer STATUS_CAST			= 3
		constant integer STATUS_INVINCIBLE		= 4
		constant integer STATUS_SILENCE			= 5
		constant integer STATUS_EVASION			= 6
		constant integer STATUS_BLIND			= 7
		constant integer STATUS_GRABBED			= 8
		constant integer STATUS_DEAD			= 9
		constant integer STATUS_UNSTOP			= 10
		constant integer STATUS_SIZE			= 11

		constant real GRAVITY_DEFAULT = 600.

		integer INDEX_STAT = 0
		integer INDEX_ABILITY = 0
		integer INDEX_ITEM = 0
		integer INDEX_STATUS = 0
		integer INDEX_LAST = 0

		trigger DEATH_TRIGGER = CreateTrigger()
		integer DEATH_UNIT = 0
		integer DEATH_KILLER = 0

		trigger LEVEL_TRIGGER = CreateTrigger()
		integer LEVEL_UNIT = 0
		integer LEVEL_LEVEL = 0

		trigger REVIVE_TRIGGER = CreateTrigger()
		integer REVIVE_UNIT = 0

		trigger ABILITY_TRIGGER = CreateTrigger()
		integer ABILITY_ABILITY = 0
		integer ABILITY_CASTER = 0
		integer ABILITY_TARGET = 0
		real ABILITY_POSITION_X = 0.
		real ABILITY_POSITION_Y = 0.

		trigger UNREGISTER_GROUP = CreateTrigger()
		unit UNREGISTER_GROUP_UNIT = null

		trigger WEAPON_CHANGE_TRIGGER = CreateTrigger()
		integer WEAPON_CHANGE_UNIT = 0
		integer WEAPON_CHANGE_OLD = 0
		integer WEAPON_CHANGE_NEW = 0

		public group GROUP = null

	endglobals

	struct Unit_prototype extends Agent
		static trigger TRIGGER_DAMAGE = CreateTrigger()
		static trigger TRIGGER_ORDER_IMMEDIATE = CreateTrigger()
		static trigger TRIGGER_ORDER_POINT = CreateTrigger()
		static trigger TRIGGER_ORDER_TARGET = CreateTrigger()

		timer main_timer = null
		timer decay_timer = null
		Effect facing_circle = 0

		string class = "Unit_prototype"
		string origin_name = ""
		player origin_player = null
		integer level_true = 1
		integer exp = 0
		integer exp_max = 1
		boolean is_revive = false

		real z_velo = 0.
		real gravity = GRAVITY_DEFAULT
		integer collision_true = 1
		private integer avul = 0

		Ability_prototype weapon_ability = 0

		method operator origin_unit takes nothing returns unit
			return LoadUnitHandle(HASH,GetHandleId(.origin_agent),INDEX_ORIGIN_HANDLE)
		endmethod

		unit mover_unit = null

		method operator level takes nothing returns integer
			return .level_true
		endmethod

		method operator level= takes integer v returns nothing
			local integer diff = 0
			if v <= .level_true then
				return
			endif
			set diff = v - .level_true
			set .level_true = v
			if IsUnitType(.origin_unit,UNIT_TYPE_HERO) then
				call SetHeroLevel(.origin_unit,v,false)
			endif
			call refreshLevelStatValue()
			set LEVEL_UNIT = this
			set LEVEL_LEVEL = diff
			call TriggerEvaluate(LEVEL_TRIGGER)
			set LEVEL_UNIT = 0
			set LEVEL_LEVEL = 0
		endmethod

		method refreshAttackSpeed takes real v returns nothing
			local integer i = R2I(v/0.05)
			if i <= 0 then
				set  i = 1
			endif
			if i > 100 then
				set i = 100
			endif
			call SetUnitAbilityLevel(.origin_unit,'Axx0',i)
		endmethod

		method refreshAttackSpeedRequest takes real v returns nothing
			if .weapon_ability > 0 then
				call refreshAttackSpeed(.weapon_ability.getAttackSpeedValue(v))
			else
				call refreshAttackSpeed(v)
			endif
		endmethod

		method getStatValue takes integer stattype, integer statindex returns real
			return LoadReal(HASH,this,INDEX_STAT+(stattype*STAT_INDEX_SIZE)+statindex)
		endmethod

		method getCarculatedStatValue takes integer stattype returns real
			local real nv = ( ( ( getStatValue(stattype,STAT_INDEX_BASE) + getStatValue(stattype,STAT_INDEX_LEVEL) * (.level-1) + getStatValue(stattype,STAT_INDEX_PLUS) ) */*
			*/getStatValue(stattype,STAT_INDEX_MULTIPLY) ) / getStatValue(stattype,STAT_INDEX_DIVIDE) ) - getStatValue(stattype,STAT_INDEX_MINUS)
			if STAT_TYPE_CLAMP[stattype] then
				if nv <= 0. then
					if stattype != STAT_TYPE_MAXHP then
						return 0.
					else
						return 0.01
					endif
				else
					return nv
				endif
			else
				return nv
			endif
		endmethod

		method refreshStatValue takes integer stattype returns nothing
			/*리프레시*/
			if stattype == STAT_TYPE_ATTACK_RANGE then
				set attack_range = getCarculatedStatValue(stattype)
			elseif stattype == STAT_TYPE_MAXHP then
				set .maxhp = getCarculatedStatValue(STAT_TYPE_MAXHP)
			elseif stattype == STAT_TYPE_MAXMP then
				set .maxmp = getCarculatedStatValue(STAT_TYPE_MAXMP)
			elseif stattype == STAT_TYPE_MOVEMENT_SPEED then
				if getStatus(STATUS_ENSNARE) > 0 then
					set .movement_speed = 1.
				else
					set .movement_speed = getCarculatedStatValue(STAT_TYPE_MOVEMENT_SPEED)
				endif
			elseif stattype == STAT_TYPE_ATTACK_SPEED then
				call refreshAttackSpeedRequest(getCarculatedStatValue(STAT_TYPE_ATTACK_SPEED))
			endif
		endmethod

		method refreshLevelStatValue takes nothing returns nothing
			call refreshStatValue(STAT_TYPE_MAXHP)
			call refreshStatValue(STAT_TYPE_MAXMP)
		endmethod

		method setStatValue takes integer stattype, integer statindex, real newval returns nothing
			/*능력치값 변경*/
			call SaveReal(HASH,this,INDEX_STAT+(stattype*STAT_INDEX_SIZE)+statindex,newval)
		endmethod

		method plusStatValue takes integer stattype, real val returns nothing
			call setStatValue(stattype,STAT_INDEX_PLUS,getStatValue(stattype,STAT_INDEX_PLUS)+val)
			call refreshStatValue(stattype)
		endmethod

		method minusStatValue takes integer stattype, real val returns nothing
			call setStatValue(stattype,STAT_INDEX_MINUS,getStatValue(stattype,STAT_INDEX_MINUS)+val)
			call refreshStatValue(stattype)
		endmethod

		method multiplyStatValue takes integer stattype, real val returns nothing
			call setStatValue(stattype,STAT_INDEX_MULTIPLY,getStatValue(stattype,STAT_INDEX_MULTIPLY)+val)
			call refreshStatValue(stattype)
		endmethod

		method divideStatValue takes integer stattype, real val returns nothing
			call setStatValue(stattype,STAT_INDEX_DIVIDE,getStatValue(stattype,STAT_INDEX_DIVIDE)+val)
			call refreshStatValue(stattype)
		endmethod

		method initStatValue takes nothing returns nothing
			local integer i = 0
			local integer j = 0
			loop
				exitwhen i >= STAT_TYPE_SIZE
				call setStatValue(i,STAT_INDEX_DIVIDE,1.)
				call setStatValue(i,STAT_INDEX_MULTIPLY,1.)
				call setStatValue(i,STAT_INDEX_BASE,0.)
				call setStatValue(i,STAT_INDEX_LEVEL,0.)
				call setStatValue(i,STAT_INDEX_PLUS,0.)
				call setStatValue(i,STAT_INDEX_MINUS,0.)
				set i = i + 1
			endloop
			call setStatValue(STAT_TYPE_MAXHP,STAT_INDEX_BASE,1.)
			call refreshStatValue(STAT_TYPE_MAXHP)
			call setStatValue(STAT_TYPE_MOVEMENT_SPEED,STAT_INDEX_BASE,300.)
			call refreshStatValue(STAT_TYPE_MOVEMENT_SPEED)
			call setStatValue(STAT_TYPE_ATTACK_SPEED,STAT_INDEX_BASE,1.)
			call refreshStatValue(STAT_TYPE_ATTACK_SPEED)
			call setStatValue(STAT_TYPE_ATTACK_RANGE,STAT_INDEX_BASE,100.)
			call refreshStatValue(STAT_TYPE_ATTACK_RANGE)
			call setStatValue(STAT_TYPE_HEAL_AMP,STAT_INDEX_BASE,1.)
		endmethod

		method operator owner takes nothing returns player
			return GetOwningPlayer(.origin_unit)
		endmethod

		method operator id takes nothing returns integer
			return GetUnitTypeId(.origin_unit)
		endmethod

		method operator x takes nothing returns real
			return GetUnitX(.origin_unit)
		endmethod

		method operator y takes nothing returns real
			return GetUnitY(.origin_unit)
		endmethod

		method operator z takes nothing returns real
			return .z_true
		endmethod

		method operator yaw takes nothing returns real
			return GetUnitFacing(.origin_unit)
		endmethod

		method operator x= takes real np returns nothing
			call SetUnitX(.origin_unit,np)
			call SetUnitX(.mover_unit,np)
		endmethod

		method operator y= takes real np returns nothing
			call SetUnitY(.origin_unit,np)
			call SetUnitY(.mover_unit,np)
		endmethod

		method operator z= takes real np returns nothing
			set .z_true = np
			call SetUnitFlyHeight(.origin_unit,.z+.offset_z,0.)
		endmethod

		method operator yaw= takes real np returns nothing
			call BlzSetUnitFacingEx(.origin_unit,np+.offset_yaw)
		endmethod

		method operator offset_z= takes real np returns nothing
			set .offset_z_true = np
			call SetUnitFlyHeight(.origin_unit,.z+.offset_z,0.)
		endmethod

		method operator name takes nothing returns string
			return GetUnitName(.origin_unit)
		endmethod

		method operator hp takes nothing returns real
			return GetUnitState(.origin_unit,UNIT_STATE_LIFE)
		endmethod

		method operator hp= takes real np returns nothing
			if np >= 0. then
				call SetUnitState(.origin_unit,UNIT_STATE_LIFE,np)
				if hp == maxhp then
					if getStatus(STATUS_DEAD) > 0 and .is_revive then
						call minusStatus(STATUS_DEAD)
					endif
				endif
			else
				call SetUnitState(.origin_unit,UNIT_STATE_LIFE,np)
				//call KillUnit(.origin_unit)
			endif
		endmethod

		method operator hpregen takes nothing returns real
			return getCarculatedStatValue(STAT_TYPE_HPREGEN)
		endmethod

		method restoreHP takes real nv returns nothing
			set .hp = .hp + (nv*getCarculatedStatValue(STAT_TYPE_HEAL_AMP))
		endmethod

		method operator maxhp takes nothing returns real
			return GetUnitState(.origin_unit,UNIT_STATE_MAX_LIFE)
		endmethod

		method operator maxhp=  takes real np returns nothing
			local real v = .hp /.maxhp
			if np <= 1. then
				call BlzSetUnitMaxHP(.origin_unit,R2I(1.))
			else
				call BlzSetUnitMaxHP(.origin_unit,R2I(np))
			endif
			set .hp = .maxhp * v
		endmethod

		method operator mp takes nothing returns real
			return GetUnitState(.origin_unit,UNIT_STATE_MANA)
		endmethod

		method operator mp= takes real np returns nothing
			call SetUnitState(.origin_unit,UNIT_STATE_MANA,np)
		endmethod

		method operator mpregen takes nothing returns real
			return getCarculatedStatValue(STAT_TYPE_MPREGEN)
		endmethod

		method restoreMP takes real nv returns nothing
			set .mp = .mp + nv
		endmethod

		method operator maxmp takes nothing returns real
			return GetUnitState(.origin_unit,UNIT_STATE_MAX_MANA)
		endmethod

		method operator maxmp= takes real np returns nothing
			local real v = 0.
			if .maxmp > 0. then
				set v = .mp /.maxmp
			endif
			call BlzSetUnitMaxMana(.origin_unit,R2I(np))
			set .mp = .maxmp * v
		endmethod

		method operator attack takes nothing returns real
			return getCarculatedStatValue(STAT_TYPE_ATTACK)
		endmethod

		method operator attack_speed takes nothing returns real
			local real v = getCarculatedStatValue(STAT_TYPE_ATTACK_SPEED)
			if v >= 5. then
				return 5.
			else
				return v
			endif
		endmethod

		method operator attack_delay takes nothing returns real
			return BlzGetUnitAttackCooldown(.origin_unit,0)
		endmethod

		method operator attack_delay= takes real np returns nothing
			call BlzSetUnitAttackCooldown(.origin_unit,np,0)
		endmethod

		method operator attack_range takes nothing returns real
			return getCarculatedStatValue(STAT_TYPE_ATTACK_RANGE)
		endmethod

		method operator attack_range= takes real np returns nothing
			local real a = BlzGetUnitWeaponRealField(.origin_unit,UNIT_WEAPON_RF_ATTACK_RANGE,1)
			local real r = BlzGetUnitWeaponRealField(.origin_unit,UNIT_WEAPON_RF_ATTACK_RANGE,0)
			call BlzSetUnitWeaponRealFieldBJ(.origin_unit,UNIT_WEAPON_RF_ATTACK_RANGE,1,np-r+a)
		endmethod

		method operator magic_power takes nothing returns real
			return getCarculatedStatValue(STAT_TYPE_MAGICPOWER)
		endmethod

		method operator movement_speed takes nothing returns real
			return getCarculatedStatValue(STAT_TYPE_MOVEMENT_SPEED)
		endmethod

		method operator movement_speed= takes real np returns nothing
			local real nv = 0.
			if np > 1000. then
				set nv = 1000.
			elseif np <= 1. then
				set nv = 1.
			else
				set nv = np
			endif
			call SetUnitMoveSpeed(.origin_unit,nv)
		endmethod

		method operator accuracy takes nothing returns real
			return getCarculatedStatValue(STAT_TYPE_ACCURACY)
		endmethod

		method operator evasion takes nothing returns real
			return getCarculatedStatValue(STAT_TYPE_EVASION)
		endmethod

		method operator collision= takes boolean b returns nothing
			if b then
				set .collision_true = .collision_true + 1
			else
				set .collision_true = .collision_true - 1
			endif
			call SetUnitPathing(.origin_unit,.collision_true>0)
		endmethod

		method damageTarget takes thistype target, real damage, weapontype wt returns real
			return Damage.unitDamageTarget(this,target,damage,wt)
		endmethod

		static method decay takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			call destroy()
		endmethod

		method setWeaponAbility takes Ability_prototype wa returns nothing
			set WEAPON_CHANGE_OLD = .weapon_ability
			set WEAPON_CHANGE_NEW = wa
			set WEAPON_CHANGE_UNIT = this
			if wa > 0 then
				call setStatValue(STAT_TYPE_ATTACK_RANGE,STAT_INDEX_BASE,wa.weapon_range)
				call refreshStatValue(STAT_TYPE_ATTACK_RANGE)
				set .attack_delay = wa.weapon_delay
			else
				call setStatValue(STAT_TYPE_ATTACK_RANGE,STAT_INDEX_BASE,100.)
				call refreshStatValue(STAT_TYPE_ATTACK_RANGE)
				set .attack_delay = 1.5
			endif
			call refreshAttackSpeedRequest(getCarculatedStatValue(STAT_TYPE_ATTACK_SPEED))
			set .weapon_ability = wa
			set ABILITY_UI_REFRESH_PLAYER = .owner
			call TriggerEvaluate(ABILITY_UI_REFRESH)
			set ABILITY_UI_REFRESH_PLAYER = null
			call TriggerEvaluate(WEAPON_CHANGE_TRIGGER)
			call Event.reset()
			call Event.activate(WEAPON_CHANGE_EVENT)
			set WEAPON_CHANGE_OLD = 0
			set WEAPON_CHANGE_NEW = 0
			set WEAPON_CHANGE_UNIT = 0
		endmethod

		method getAbility takes integer index returns Ability_prototype
			if HaveSavedInteger(HASH,this,INDEX_ABILITY+index) then
				return LoadInteger(HASH,this,INDEX_ABILITY+index)
			else
				return 0
			endif
		endmethod

		method getAbilityById takes integer id returns Ability_prototype
			local Ability_prototype ta = 0
			local integer i = 0
			local boolean space_exist = false
			loop
				exitwhen i >= ABILITY_SIZE
				set ta = getAbility(i)
				if ta != 0 and ta.id == id then
					return ta
				elseif ta == 0 then
					set space_exist = true
				endif
				set i = i + 1
			endloop
			if space_exist then
				return 0
			else
				return -1
			endif
		endmethod

		method setAbility takes integer index, Ability_prototype na returns nothing
			call SaveInteger(HASH,this,INDEX_ABILITY+index,na)
		endmethod

		method killAbility takes integer index returns nothing
			local Ability_prototype ta = getAbility(index)
			call setAbility(index,0)
			if ta > 0 then
				if ta == .weapon_ability then
					call setWeaponAbility(0)
				endif
				call ta.kill()
			endif
		endmethod

		method addAbility takes integer aid returns Ability_prototype
			local integer i = 0
			local Ability_prototype na = getAbilityById(aid)
			if na == 0 then
				/*신규*/
				set na = Ability_prototype.new(aid)
				if na > 0 then
					loop
						exitwhen i >= ABILITY_SIZE
						if getAbility(i) == 0 then
							call setAbility(i,na)
							set na.owner = this
							call na.essentialInit()
							call na.init()
							return na
						endif
						set i = i + 1
					endloop
				endif
			elseif na == -1 then
				/*공간없음*/

			else
				/*레벨업*/
				call na.addLevel(1)
				call na.update()
			endif
			return na	
		endmethod

		method clearAbility takes nothing returns nothing
			local integer i = 0
			local Ability_prototype a = 0
			loop
				exitwhen i >= ABILITY_SIZE
				set a = getAbility(i)
				if a != 0 then
					call a.kill()
				endif
				call RemoveSavedInteger(HASH,this,INDEX_ABILITY+i)
				set i = i + 1
			endloop
		endmethod

		method cancleAbilityReservation takes nothing returns nothing
			local integer i = 0
			local Ability_prototype a =0
			loop
				exitwhen i >= ABILITY_SIZE
				set a = getAbility(i)
				if a != 0 then
					call a.cancleReservation()
				endif
				set i = i + 1
			endloop
		endmethod

		method cancleAbilityFollow takes nothing returns nothing
			local integer i = 0
			local Ability_prototype a =0
			loop
				exitwhen i >= ABILITY_SIZE
				set a = getAbility(i)
				if a != 0 then
					call a.cancleFollow()
				endif
				set i = i + 1
			endloop
		endmethod

		method getItem takes integer index returns Item_prototype
			if HaveSavedInteger(HASH,this,INDEX_ITEM+index) then
				return LoadInteger(HASH,this,INDEX_ITEM+index)
			else
				return 0
			endif
		endmethod
		
		method setItem takes integer index, Item_prototype na returns nothing
			call SaveInteger(HASH,this,INDEX_ITEM+index,na)
		endmethod
		
		method clearItem takes nothing returns nothing
			local integer i = 0
			local Item_prototype it = 0
			loop
				exitwhen i >= ITEM_SIZE
				set it = getItem(i)
				if it != 0 then
					call it.destroy()
				endif
				call RemoveSavedInteger(HASH,this,INDEX_ITEM+i)
				set i = i + 1
			endloop
		endmethod

		method getStatus takes integer index returns integer
			if HaveSavedInteger(HASH,this,INDEX_STATUS+index) then
				return LoadInteger(HASH,this,INDEX_STATUS+index)
			else
				return 0
			endif
		endmethod

		method plusAvul takes nothing returns nothing
			set .avul = .avul + 1
			if .avul == 1 then
				call UnitAddAbility(.origin_unit,'Avul')
			endif
		endmethod

		method minusAvul takes nothing returns nothing
			set .avul = .avul - 1
			if .avul == 0 then
				call UnitRemoveAbility(.origin_unit,'Avul')
			endif
		endmethod
		
		method setStatus takes integer index, integer nv returns nothing
			call SaveInteger(HASH,this,INDEX_STATUS+index,nv)
		endmethod
		
		method plusStatus takes integer index returns nothing
			call setStatus(index,getStatus(index)+1)
			if index == STATUS_STUN then
				call BlzPauseUnitEx(.origin_unit,true)
			elseif index == STATUS_CAST then
				call BlzPauseUnitEx(.origin_unit,true)
			elseif index == STATUS_GRABBED then
				call BlzPauseUnitEx(.origin_unit,true)
			elseif index == STATUS_INVINCIBLE then
				call plusAvul()
			elseif index == STATUS_DEAD then
				call BlzPauseUnitEx(.origin_unit,true)
				if getStatus(index) == 1 then
					call .facing_circle.setAlpha(0)
					if .is_revive then
						call plusAvul()
						call SetUnitVertexColor(.origin_unit,0,0,0,255)
					else
						/*set UNREGISTER_GROUP_UNIT = .origin_unit
						call TriggerEvaluate(UNREGISTER_GROUP)
						set UNREGISTER_GROUP_UNIT = null*/
						set .hp = -1
						if .decay_timer == null then
							set .decay_timer = Timer.new(this)
						endif
						call Timer.start(.decay_timer,10.,false,function thistype.decay)
					endif
					/*TODO ONDEATH*/
					set DEATH_UNIT = this
					call TriggerEvaluate(DEATH_TRIGGER)
					set DEATH_UNIT = 0
					set DEATH_KILLER = 0
				endif
				call resetAnim()
				call setAnim("death")
			elseif index == STATUS_ENSNARE then
				call refreshStatValue(STAT_TYPE_MOVEMENT_SPEED)
			endif
		endmethod
		
		method minusStatus takes integer index returns nothing
			if getStatus(index) > 0 then
				call setStatus(index,getStatus(index)-1)
				if index == STATUS_STUN then
					call BlzPauseUnitEx(.origin_unit,false)
				elseif index == STATUS_CAST then
					call BlzPauseUnitEx(.origin_unit,false)
				elseif index == STATUS_GRABBED then
					call BlzPauseUnitEx(.origin_unit,false)
				elseif index == STATUS_INVINCIBLE then
					call minusAvul()
				elseif index == STATUS_DEAD then
					call BlzPauseUnitEx(.origin_unit,false)
					if getStatus(index) == 0 then
						call setAnim("stand")
						call queueAnim("stand")
						call .facing_circle.setAlpha(255)
						call minusAvul()
						call SetUnitVertexColor(.origin_unit,255,255,255,255)
						set REVIVE_UNIT = this
						call TriggerEvaluate(REVIVE_TRIGGER)
						set REVIVE_UNIT = 0
					endif
				elseif index == STATUS_ENSNARE then
					call refreshStatValue(STAT_TYPE_MOVEMENT_SPEED)
				endif
			endif
		endmethod
		
		method clearStatus takes nothing returns nothing
			local integer i = 0
			loop
				exitwhen i >= STATUS_SIZE
				call RemoveSavedInteger(HASH,this,INDEX_STATUS+i)
				set i = i + 1
			endloop
		endmethod

		method kill takes nothing returns nothing
			if getStatus(STATUS_DEAD) <= 0 then
				call plusStatus(STATUS_DEAD)
			endif
		endmethod

		private static method syncMoverImmediate takes nothing returns nothing
			local thistype this = get(GetTriggerUnit())
			if this > 0 then
				call SetUnitX(.mover_unit,.x)
				call SetUnitY(.mover_unit,.y)
				call IssueImmediateOrder(.mover_unit,"stop")
			endif
		endmethod

		private static method syncMoverPoint takes nothing returns nothing
			local thistype this = get(GetTriggerUnit())
			if this > 0 and (GetIssuedOrderIdBJ() == String2OrderIdBJ("smart") or GetIssuedOrderIdBJ() == String2OrderIdBJ("attack")) then
				call SetUnitX(.mover_unit,.x)
				call SetUnitY(.mover_unit,.y)
				call IssuePointOrder(.mover_unit,"move",GetOrderPointX(),GetOrderPointY())
			endif
		endmethod

		private static method syncMoverTarget takes nothing returns nothing
			local thistype this = get(GetTriggerUnit())
			if this > 0 then
				call SetUnitX(.mover_unit,.x)
				call SetUnitY(.mover_unit,.y)
				call IssueImmediateOrder(.mover_unit,"stop")
				//call IssueTargetOrder(.mover_unit,"smart",GetOrderTarget())
			endif
		endmethod

		private static method basicAttack takes nothing returns nothing
			local thistype attacker = 0
			local thistype target = 0
			local integer i = ABILITY_SIZE - 1
			local Ability_prototype a = 0
			if BlzGetEventIsAttack() then
				call BlzSetEventDamage(0.)
				set attacker = get(GetEventDamageSource())
				set target = get(GetTriggerUnit())
				if attacker > 0 and target > 0 then
					if attacker.weapon_ability > 0 then
						call attacker.weapon_ability.basicAttack(target)
					else
						call MeleeAttack.create(attacker,target)
					endif
				endif
			endif
		endmethod

		method gravityAction takes nothing returns nothing
			if .movement == 0 then
				if .z <= 0. and .z_velo <= 0. then
					set .z = 0.
					set .z_velo = 0.
				else
					set .z = .z + .z_velo * TIMER_TICK
					set .z_velo = .z_velo - .gravity * TIMER_TICK
				endif
			else
				set .z_velo = 0.
			endif
		endmethod

		private static method timerAction takes nothing returns nothing
			local thistype this = Timer.getData(GetExpiredTimer())
			call .facing_circle.setPosition(.x,.y,0.)
			set .facing_circle.yaw = .yaw
			call gravityAction()
			call restoreHP(getCarculatedStatValue(STAT_TYPE_HPREGEN)*TIMER_TICK)
			call restoreMP(getCarculatedStatValue(STAT_TYPE_MPREGEN)*TIMER_TICK)
		endmethod

		method resetAnim takes nothing returns nothing
			call ResetUnitAnimation(.origin_unit)
		endmethod

		method setAnim takes string anim returns nothing
			if getStatus(STATUS_DEAD) <= 0 or anim == "death" then
				call SetUnitAnimation(.origin_unit,anim)
			endif
		endmethod

		method queueAnim takes string anim returns nothing
			if getStatus(STATUS_DEAD) <= 0 or anim == "death" then
				call QueueUnitAnimation(.origin_unit,anim)
			endif
		endmethod

		method setAnimSpeed takes real nv returns nothing
			call SetUnitTimeScale(.origin_unit,nv)
		endmethod

		method isMoveable takes nothing returns boolean
			return getStatus(STATUS_STUN) <= 0 and /*
			*/getStatus(STATUS_ENSNARE) <= 0 and /*
			*/getStatus(STATUS_GRABBED) <= 0
		endmethod

		method inRange takes real x, real y, real radius returns boolean
			return IsUnitInRangeXY(.origin_unit,x,y,radius)
		endmethod

		method inLine takes real x1, real y1, real x2, real y2, real radius returns boolean
			return IsUnitInLine(.origin_unit,x1,y1,x2,y2,radius)
		endmethod

		method inSector takes real x, real y, real radius, real angle, real width returns boolean
			return IsUnitInSector(.origin_unit,x,y,radius,angle,width)
		endmethod

		method isVisible takes player p returns boolean
			return IsUnitVisible(.origin_unit,p)
		endmethod

		method isEnemy takes player p returns boolean
			return IsUnitEnemy(.origin_unit,p)
		endmethod

		method isAlly takes player p returns boolean
			return IsUnitAlly(.origin_unit,p)
		endmethod

		method isUnitType takes unittype ut returns boolean
			if ut == UNIT_TYPE_DEAD then
				return getStatus(STATUS_DEAD) > 0 or IsUnitType(.origin_unit,UNIT_TYPE_DEAD)
			else
				return IsUnitType(.origin_unit,ut)
			endif
		endmethod

		method issueTargetOrder takes string order, widget t returns nothing
			call IssueTargetOrder(.origin_unit,order,t)
		endmethod

		method issuePointOrder takes string order, real x, real y returns nothing
			call IssuePointOrder(.origin_unit,order,x,y)
		endmethod

		method issueImmediateOrder takes string order returns nothing
			call IssueImmediateOrder(.origin_unit,order)
		endmethod

		static method get takes unit u returns thistype
			if HaveSavedInteger(HASH,GetHandleId(u),INDEX_INSTANCE_ID) and u != null then
				return LoadInteger(HASH,GetHandleId(u),INDEX_INSTANCE_ID)
			else
				return 0
			endif
		endmethod

		private method essentialInit takes nothing returns nothing
			set .origin_name = GetUnitName(.origin_unit)
			call UnitAddAbility(.origin_unit,'Arav')
			call UnitRemoveAbility(.origin_unit,'Arav')
			call UnitAddAbility(.origin_unit,'Axx0')
			call UnitAddAbility(.origin_unit,'Axx1')
			call UnitAddAbility(.origin_unit,'Axx2')
			call SetUnitAbilityLevel(.origin_unit,'Axx0',20)
			call BlzUnitDisableAbility(.origin_unit,'Apat',true,true)
			call BlzSetUnitWeaponRealFieldBJ(.origin_unit,UNIT_WEAPON_RF_ATTACK_DAMAGE_POINT,0,0.01)
    		call BlzSetUnitWeaponRealFieldBJ(.origin_unit,UNIT_WEAPON_RF_ATTACK_BACKSWING_POINT,0,0.01)
			call BlzSetUnitWeaponIntegerFieldBJ(.origin_unit,UNIT_WEAPON_IF_ATTACK_WEAPON_SOUND,0,0)
			set .attack_delay = 1.5
			set .offset_z = GetUnitFlyHeight(.origin_unit)
		endmethod

		static method create takes player p, integer uid, real x, real y, real facing returns thistype
			local thistype this = allocate(CreateUnit(p,uid,x,y,facing))
			set .origin_player = p
			set .main_timer = Timer.new(this)
			call GroupAddUnit(GROUP,.origin_unit)
			call essentialInit()
			call initStatValue()
			call Timer.start(.main_timer,TIMER_TICK,true,function thistype.timerAction)
			/*무버*/
			set .mover_unit = CreateUnit(p,'dumm',x,y,facing)
			if not UnitAddAbility(.mover_unit,'Axx3') then
				call BJDebugMsg("|cffff0000어빌리티 'Axx3'(윈드워크) 이/가 정의되지 않았습니다.")
			endif
			call IssueImmediateOrder(.mover_unit,"windwalk")
			call UnitAddAbility(.mover_unit,'Axx1')
			call ShowUnit(.mover_unit,false)
			call SetUnitMoveSpeed(.mover_unit,10.)
			/*페이싱 서클*/
			set .facing_circle = Effect.create("Effects\\FacingCircle.mdl",x,y,0.,facing)
			call .facing_circle.setScale(BlzGetUnitCollisionSize(.origin_unit)/100.)
			if GetLocalPlayer() == .owner then
				
			elseif isEnemy(GetLocalPlayer()) then
				call .facing_circle.setColor(255,0,0)
			elseif isAlly(GetLocalPlayer()) then
				call .facing_circle.setColor(0,255,0)
			else
				call .facing_circle.setColor(255,255,0)
			endif
			set .facing_circle.want_remove = true
			/**/
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			//if .is_revive then
				set UNREGISTER_GROUP_UNIT = .origin_unit
				call TriggerEvaluate(UNREGISTER_GROUP)
				set UNREGISTER_GROUP_UNIT = null
			//endif
			call clearAbility()
			call clearItem()
			call clearStatus()
			call Buff.unitDestroyBuffs(this)
			call .facing_circle.destroy()
			if Mover.getUnitMover(this) > 0 then
				call Mover.getUnitMover(this).destroy()
			endif
			if .movement != 0 then
				call .movement.destroy()
			endif
			if .main_timer != null then
				call Timer.release(.main_timer)
			endif
			if .decay_timer != null then
				call Timer.release(.decay_timer)
			endif
			set .main_timer = null
			set .decay_timer = null
			set .origin_player = null
			call RemoveUnit(.mover_unit)
			set .mover_unit = null
			call RemoveUnit(.origin_unit)
		endmethod

		private static method unregister takes nothing returns nothing
			if UNREGISTER_GROUP_UNIT == null then
				return
			else
				call GroupRemoveUnit(GROUP,UNREGISTER_GROUP_UNIT)
			endif
		endmethod

		private static method initLabel takes nothing returns nothing
			set INDEX_STAT 	 	= 0
			set INDEX_ABILITY 	= INDEX_STAT + STAT_TYPE_SIZE * STAT_INDEX_SIZE
			set INDEX_ITEM		= INDEX_ABILITY + ABILITY_SIZE
			set INDEX_STATUS	= INDEX_ITEM + ITEM_SIZE
			set INDEX_LAST		= INDEX_STATUS + STATUS_SIZE
		endmethod

		private static method initTrigger takes nothing returns nothing
			call TriggerRegisterAnyUnitEventBJ(TRIGGER_DAMAGE,EVENT_PLAYER_UNIT_DAMAGING)
			call TriggerAddCondition(TRIGGER_DAMAGE,function thistype.basicAttack)
			//
			call TriggerRegisterAnyUnitEventBJ(TRIGGER_ORDER_IMMEDIATE,EVENT_PLAYER_UNIT_ISSUED_ORDER)
			call TriggerAddCondition(TRIGGER_ORDER_IMMEDIATE,function thistype.syncMoverImmediate)
			//
			call TriggerRegisterAnyUnitEventBJ(TRIGGER_ORDER_POINT,EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
			call TriggerAddCondition(TRIGGER_ORDER_POINT,function thistype.syncMoverPoint)
			//
			call TriggerRegisterAnyUnitEventBJ(TRIGGER_ORDER_TARGET,EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
			call TriggerAddCondition(TRIGGER_ORDER_TARGET,function thistype.syncMoverTarget)
			//
			call TriggerAddCondition(UNREGISTER_GROUP,function thistype.unregister)
		endmethod

		static method onInit takes nothing returns nothing
			local integer i = 0 
			set GROUP = Group.new()
			loop
				exitwhen i >= STAT_TYPE_SIZE
				set STAT_TYPE_CLAMP[i] = false
				set STAT_NORMAL_VALUE[i] = 1.
				set i = i + 1
			endloop
			set STAT_TYPE_CLAMP[STAT_TYPE_MAXHP] = true
			set STAT_TYPE_CLAMP[STAT_TYPE_MAXMP] = true
			set STAT_TYPE_CLAMP[STAT_TYPE_ATTACK] = true
			set STAT_TYPE_CLAMP[STAT_TYPE_MAGICPOWER] = true
			set STAT_TYPE_CLAMP[STAT_TYPE_ACCURACY] = true
			set STAT_TYPE_CLAMP[STAT_TYPE_EVASION] = true
			set STAT_TYPE_CLAMP[STAT_TYPE_MOVEMENT_SPEED] = true
			set STAT_TYPE_CLAMP[STAT_TYPE_ATTACK_RANGE] = true
			set STAT_TYPE_CLAMP[STAT_TYPE_ARMOR_PENET] = true
			set STAT_TYPE_CLAMP[STAT_TYPE_MAGIC_PENET] = true
			set STAT_TYPE_CLAMP[STAT_TYPE_HPREGEN] = true
			/**/
			set STAT_NORMAL_VALUE[STAT_TYPE_MAXHP] = 20.
			set STAT_NORMAL_VALUE[STAT_TYPE_MAXMP] = 10.
			set STAT_NORMAL_VALUE[STAT_TYPE_ARMOR_PENET] = 0.5
			set STAT_NORMAL_VALUE[STAT_TYPE_MAGIC_PENET] = 0.5
			set STAT_NORMAL_VALUE[STAT_TYPE_HPREGEN] = 0.2
			set STAT_NORMAL_VALUE[STAT_TYPE_MPREGEN] = 0.1
			/**/
			call initLabel()
			/**/
			call initTrigger()			
		endmethod

	endstruct

endlibrary