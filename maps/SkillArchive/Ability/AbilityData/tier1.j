/*0000 후려치기*/
scope Ability0000 initializer init
	//! runtextmacro abilityDataHeader("0000","후려치기","BTNSteelMelee","1","STAT_TYPE_ATTACK","STAT_TYPE_ARMOR_PENET")
	
		globals
			private constant real CHARGE_DURATION = 0.25
			private constant real CHARGE_SPEED = 1250.
			private constant real KNOCKBACK_DISTANCE = 100.
			private constant real KNOCKABCK_DURATION = 0.5
			private constant real DAMAGE_PER_ATTACK = 1.5
			private constant real DAMAGE_PER_LEVEL = 0.05
			private constant real DAMAGE_PER_ATTACK_ALTERNATE = 2.0
			private constant real BACKSWING = 0.15
			private constant real COLRAD = 75.
		endglobals
	
		public struct mv extends UnitMovement
	
			method executeExplosion takes Unit_prototype target returns nothing
				local knockback kn = knockback.create(target,KNOCKBACK_DISTANCE/KNOCKABCK_DURATION,.caster.yaw)
				set kn.z_velo = 300.
				set kn.gravity = (300.*2)/KNOCKABCK_DURATION
				set kn.duration = KNOCKABCK_DURATION
				set .damage_id = ID
				call damageFlagTemplatePhysicalExplosion()
				if target == .target then
					set .damage = ( .caster.attack * DAMAGE_PER_ATTACK_ALTERNATE ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) )
				else
					set .damage = ( .caster.attack * DAMAGE_PER_ATTACK ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) )
				endif
				call damageTarget(target)
				call Effect.create(EF_ROCK,target.x,target.y,target.z+target.pivot_z,0).setScale(2.5).kill()
				call Buff.add(0,target,'Stun',0.5)
			endmethod
	
			method executeTarget takes Unit_prototype target returns nothing
				set .target = target
				call explosionAction()
				set .want_destroy = true
				call UnitActor.create(.caster,0,0.,0.,0,BACKSWING,true)
			endmethod
	
			static method create takes Unit u, real yaw, integer level returns thistype
				local thistype this = allocate(u,CHARGE_SPEED,yaw)
				set .use_collision = true
				set .duration  = CHARGE_DURATION
				set .refresh_facing = false
				set .level = level
				set .flag_collision = true
				set .radius_target = COLRAD
				set .radius_explosion = 125.
				call .caster.setAnimSpeed(1.0*.caster.attack_speed)
				call .caster.queueAnim("stand")
				call Effect.create(EF_ROCK,u.x,u.y,u.z,0).setPitch(-90).kill()
				return this
			endmethod
	
			method onDestroy takes nothing returns nothing
				call .caster.setAnimSpeed(1.0)
			endmethod
	
		endstruct
	
		public struct actor extends UnitActor
	
			real angle = 0.

			method periodicAction takes nothing returns nothing
			endmethod
	
			method onComplete takes nothing returns nothing
				call mv.create(.caster,.angle,level)
			endmethod
	
			static method create takes Unit u, real x, real y, real delay, integer level returns thistype
				local thistype this = allocate(u,0,x,y,level,delay,true)
				set .angle = Math.anglePoints(.caster.x,.caster.y,.x,.y)
				call .caster.setAnim("attack")
				call .caster.setAnimSpeed(.caster.attack_speed)
				call SetUnitFacing(.caster.origin_unit,.angle)
				set .suspend_ensnare = true
				set .progress_bar = ProgressBar.create(NAME,.caster.owner)
				return this
			endmethod
	
		endstruct

		private struct ind extends LineIndicator

			method beforeRefresh takes nothing returns nothing
				set .x = .abil.owner.x
				set .y = .abil.owner.y
				set .yaw = Math.anglePoints(.x,.y,Mouse.getVX(owner),Mouse.getVY(owner))
				set .range = (CHARGE_SPEED*CHARGE_DURATION)
				set .width = COLRAD
			endmethod

			static method create takes Ability_prototype abil, player owner returns thistype
				local thistype this = allocate(abil,owner)
				call .ef.setColor(255,R2I(0.65*255),0)
				return this
			endmethod

		endstruct
	
		public struct main extends Ability
	
			method relativeTooltip takes nothing returns string
				return "지정한 방향으로 약진하여 충돌하는 대상과 대상 주변의 적들에게 "+/*
				*/ConstantString.statStringReal(STAT_TYPE_ATTACK,( .owner.attack * DAMAGE_PER_ATTACK ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ),1)+/*
				*/"의 "+DAMAGE_STRING_PHYSICAL+"를 입히고 밀쳐냅니다.\n가장 가까운 적은 "+/*
				*/ConstantString.statStringReal(STAT_TYPE_ATTACK,( .owner.attack * DAMAGE_PER_ATTACK_ALTERNATE ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ),1)+/*
				*/"의 피해량이 대신 적용됩니다."
			endmethod
	
			method execute takes nothing returns nothing
				call actor.create(.owner,.command_x,.command_y,getCarculatedCastDelayByAttackSpeed(),level)
			endmethod
	
			method init takes nothing returns nothing
				set .manacost = 25
				set .is_active = true
				set .useable_ensnare = false
				set .preserve_order = false
				set .cooldown_max = 8.
				set .cooldown_min = 2.
				set .cast_delay = 0.25
				set .indicator = ind.create(this,.owner.owner)
				call plusStatValue(5)
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.addTypeTag(ID,ABILITY_STRING_TARGET_LOCATION)
				call Ability.addTypeTag(ID,ABILITY_TAG_IRON)
				call Ability.setTypeTooltip(ID,"단거리 돌진,\n충돌 시 범위피해")
			endmethod
	
		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope
	
/*0001 쌍극의 번개*/
scope Ability0001 initializer init
	//! runtextmacro abilityDataHeader("0001","쌍극의 번개","btn-ability-protoss-doubleshieldrecharge","1","STAT_TYPE_MAGICPOWER","STAT_TYPE_MAGIC_PENET")
	
		globals
			private constant real DELAY = 0.65
			private constant real CAST = 0.25
			private constant real BALL_UP = 0.3
			private constant real BALL_HEIGHT = 85.
			private constant real BALL_DISTANCE = 350.
			private constant real BALL_RADIUS = 55.
			private constant real RANGE = 500.
			private constant string EFFECT_PATH1 = "Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl"
			private constant string EFFECT_PATH2 = "Abilities\\Weapons\\ChimaeraLightningMissile\\ChimaeraLightningMissile.mdl"
			private constant real DAMAGE_PER_MAGICPOWER = 2.25
			private constant real DAMAGE_PER_LEVEL = 0.05
		endglobals

		public struct explosion extends LineExplosion

			method executeExplosion takes Unit_prototype target returns nothing
				set .damage_id = ID
				call damageTarget(target)
				call Effect.createAttatched(EFFECT_PATH2,target.origin_unit,"origin").kill()
			endmethod

		endstruct
	
		public struct a2 extends UnitActor
			
			Effect effect_1 = 0
			Effect effect_2 = 0
			Square sq = 0
			real angle = 0.

			method onComplete takes nothing returns nothing
				local Lightning lh = Lightning.create("CLSB",.effect_1.x,.effect_1.y,.effect_1.z,.effect_2.x,.effect_2.y,.effect_2.z)
				local LineExplosion lex = explosion.create(.owner,.effect_1.x,.effect_1.y,.effect_2.x,.effect_2.y,BALL_RADIUS)
				call lh.setDuration(0.25)
				set lh.fade = 3.
				set lex.damage = ( .caster.magic_power * DAMAGE_PER_MAGICPOWER ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) )
				call lex.activate()
			endmethod

			method periodicAction takes nothing returns nothing
				if .stage == 0 then
					if .caster.isAlly(GetLocalPlayer()) then
						call .sq.setLocalColor(0.,1.,0.,.sq.a)
					else
						call .sq.setLocalColor(1.,0.,0.,.sq.a)
					endif
					set .effect_1.z = .effect_1.z + (BALL_HEIGHT/BALL_UP) * TIMER_TICK
					set .effect_2.z = .effect_1.z
					call .effect_1.setAlpha(R2I((.timeout/BALL_UP)*255))
					call .effect_2.setAlpha(R2I((.timeout/BALL_UP)*255))
					if .timeout >= BALL_UP then
						call .effect_1.setAlpha(255)
						call .effect_2.setAlpha(255)
						set .effect_1.z = BALL_HEIGHT
						set .effect_2.z = .effect_1.z
						call stageNext()
					endif
				endif
			endmethod

			static method create takes Unit caster, real x, real y, real angle, integer level returns thistype
				local thistype this = allocate(caster,0,x,y,level,DELAY,false)
				set .sq = Square.create(Math.pPX(x,-BALL_RADIUS,angle),Math.pPY(y,-BALL_RADIUS,angle),0.,BALL_DISTANCE+BALL_RADIUS*2,angle,BALL_RADIUS,null)
				set .effect_1 = Effect.create(EFFECT_PATH1,x,y,0.,270.)
				set .effect_2 = Effect.create(EFFECT_PATH1,Math.pPX(x,BALL_DISTANCE,angle),Math.pPY(y,BALL_DISTANCE,angle),0.,270.)
				call .effect_1.setAlpha(0)
				call .effect_2.setAlpha(0)
				set .angle = angle
				set .sq.alpha_max = 0.5
				set .sq.refresh_color = false
				set .sq.permanent = true
				call .sq.setColor(0,0.3,1.,0.)
				call .sq.fadeIn(BALL_UP)
				call .sq.setFadeOutPoint(DELAY,0.25)
				return this
			endmethod

			method onDestroy takes nothing returns nothing
				call .effect_1.kill()
				call .effect_2.kill()
				call .sq.destroy()
			endmethod
	
		endstruct
	
		public struct actor extends UnitActor
	
			method onComplete takes nothing returns nothing
				call a2.create(.caster,.x,.y,Math.anglePoints(.x,.y,.x2,.y2),level)
			endmethod
	
			static method create takes Unit caster, real x, real y, real x2, real y2, integer level returns thistype
				local thistype this = allocate(caster,0,x,y,level,CAST,true)
				set .x2 = x2
				set .y2 = y2
				call SetUnitFacing(.caster.origin_unit,Math.anglePoints(.caster.x,.caster.y,x,y))
				call .caster.setAnim("attack")
				call .caster.setAnimSpeed(2.)
				set .progress_bar = ProgressBar.create(NAME,.caster.owner)
				return this
			endmethod

			method onDestroy takes nothing returns nothing
				call .caster.queueAnim("stand ready")
				call .caster.setAnimSpeed(1.)
			endmethod

		endstruct

		private struct ind extends LineIndicator

			method beforeRefresh takes nothing returns nothing
				set .yaw = Math.anglePoints(.abil.command_x_temp,.abil.command_y_temp,Mouse.getVX(owner),Mouse.getVY(owner))
				set .x = Math.pPX(.abil.command_x_temp,-BALL_RADIUS,.yaw)
				set .y = Math.pPY(.abil.command_y_temp,-BALL_RADIUS,.yaw)
				set .range = BALL_DISTANCE+BALL_RADIUS*2
				set .width = BALL_RADIUS
			endmethod

			static method create takes Ability_prototype abil, player owner returns thistype
				local thistype this = allocate(abil,owner)
				call .ef.setColor(0,R2I(0.3*255),255)
				call .circle.setColor(0,R2I(0.3*255),255)
				return this
			endmethod

		endstruct
	
		public struct main extends Ability
	
			method relativeTooltip takes nothing returns string
				return "직선 범위 내의 적들에게 "+ConstantString.statStringReal(STAT_TYPE_MAGICPOWER,( .owner.magic_power * DAMAGE_PER_MAGICPOWER ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ),1)+"의 "+DAMAGE_STRING_MAGICAL+"를 입힙니다."
			endmethod

			method execute takes nothing returns nothing
				call actor.create(.owner,.command_x,.command_y,.command_x2,.command_y2,level)
			endmethod

			method init takes nothing returns nothing
				set .manacost = 27
				set .is_active = true
				set .cast_range = RANGE
				set .cooldown_max = 6.7
				set .cooldown_min = 0.5
				set .preserve_order = false
				set .drag_to_use = true
				set .indicator = ind.create(this,.owner.owner)
				call plusStatValue(5)
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.addTypeTag(ID,ABILITY_STRING_DRAG_TO_USE)
				call Ability.addTypeTag(ID,ABILITY_TAG_MAGIC)
				call Ability.addTypeTag(ID,ABILITY_TAG_LIGHTNING)
				call Ability.setTypeTooltip(ID,"직선영역 범위피해\n ")
			endmethod

		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

/*0002 고정사격*/
scope Ability0002 initializer init
	//! runtextmacro abilityDataHeader("0002","고정사격","BTNDwarvenLongRifle","1","STAT_TYPE_ACCURACY","STAT_TYPE_ARMOR_PENET")
	
		globals
			private constant real DELAY = 2.
			private constant real BACKSWING = 0.25
			private constant real STARTAT = 45.
			private constant string EFFECT_PATH1 = "Abilities\\Weapons\\Mortar\\MortarMissile.mdl"
			private constant real DAMAGE_PER_ATTACK = 2.65
			private constant real DAMAGE_PER_LEVEL = 0.05
			private constant real VELO = 1875.
		endglobals
	
		public struct actor extends UnitActor
	
			boolean play = false

			method suspendFilterAdditional takes nothing returns boolean
				return .target.isUnitType(UNIT_TYPE_DEAD)
			endmethod

			method onComplete takes nothing returns nothing
				local real nx = Math.pPX(.caster.x,STARTAT,.caster.yaw)
				local real ny = Math.pPY(.caster.y,STARTAT,.caster.yaw)
				local Missile ms = Missile.create(.caster,EFFECT_PATH1,nx,ny,.caster.z+.caster.pivot_z,.caster.yaw)
				set ms.damage_id = ID
				set ms.damage = (.owner.attack * DAMAGE_PER_ATTACK) * (1+DAMAGE_PER_LEVEL*(.level-1) * .owner.attack_speed)
				set ms.attack_type = ATTACK_TYPE_SPELL
				set ms.radius_target = VELO*TIMER_TICK*0.5
				set ms.velo = VELO
				call ms.setTarget(.target)
				call UnitActor.create(.caster,0,0.,0.,0,BACKSWING,true)
			endmethod

			method periodicAction takes nothing returns nothing
				call SetUnitFacing(.caster.origin_unit,Math.anglePoints(.caster.x,.caster.y,.target.x,.target.y))
				if .duration_max - .timeout < 0.25 and not .play then
					call .caster.setAnim("attack")
					set .play = true
				endif
			endmethod
	
			static method create takes Unit caster, Unit target, integer level returns thistype
				local thistype this = allocate(caster,target,0.,0.,level,DELAY,true)
				set .progress_bar = ProgressBar.create(NAME,.caster.owner)
				set .suspend_rclick = true
				return this
			endmethod

			method onDestroy takes nothing returns nothing
				call .caster.queueAnim("stand ready")
				call .caster.setAnimSpeed(1.)
			endmethod

		endstruct
	
		public struct main extends Ability

			method relativeTooltip takes nothing returns string
				return "정신집중 후 대상에게 강력한 탄환을 발사하여 "+/*
				*/ConstantString.statStringReal(STAT_TYPE_ATTACK,(.owner.attack * DAMAGE_PER_ATTACK) * (1+DAMAGE_PER_LEVEL*(.level-1) * .owner.attack_speed) ,1)+/*
				*/"의 "+DAMAGE_STRING_PHYSICAL+"를 입힙니다."
			endmethod

			method basicAttack takes Unit target returns nothing
				local actor ac = actor.create(.owner,target,.level)
			endmethod

			method init takes nothing returns nothing
				set .weapon_delay = 1.
				set .weapon_range = 650.
				set .cast_delay = DELAY
				call plusStatValue(5)
			endmethod

			static method onInit takes nothing returns nothing
				call Ability.addTypeTag(ID,ABILITY_STRING_WEAPON)
				call Ability.addTypeTag(ID,ABILITY_TAG_FIREARM)
				call Ability.addTypeTag(ID,ABILITY_TAG_SHOOTING)
				call Ability.setTypeTooltip(ID,"정신 집중 후\n단일 대상 공격")
			endmethod
	
		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

/*0003 화염구*/
scope Ability0003 initializer init
	//! runtextmacro abilityDataHeader("0003","화염구","BTNFireBolt","1","STAT_TYPE_MAGICPOWER","STAT_TYPE_SPELL_BOOST")
	
		globals
			private constant real DELAY = 0.2
			private constant real DAMAGE_PER_MAGICPOWER = 2.25
			private constant real DAMAGE_PER_LEVEL = 0.05
			private constant real BACKSWING = 0.15
			private constant real STARTAT = 32.5
			private constant real COLRAD = 65.
			private constant real EXPRAD = 145.
			private constant real VELO = 1100.
			private constant real RANGE = 750.
			private constant string EFFECT_PATH1 = "Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl"
			private constant string EFFECT_PATH2 = "Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl"
		endglobals
	
		private struct ball extends Missile

			Circle l = 0

			method periodicAction takes nothing returns nothing
				call .l.setPosition(.x,.y,5.)
			endmethod

			method executeTarget takes Unit target returns nothing
				call DoNothing()
			endmethod

			method afterExplosion takes nothing returns nothing
				local Circle c = Circle.create(.x,.y,5.,EXPRAD)
				call c.setColor(255,153,0)
				set c.alpha = 0.66
				call c.setFadeOutPoint(0.25,0.75)
				call Effect.create(EFFECT_PATH2,.x,.y,0.,0.).setDuration(1.5)
				call .l.destroy()
				set .l = 0
			endmethod

			static method create takes Unit owner, real x, real y, real z, real yaw, integer level returns thistype
				local thistype this = allocate(owner,EFFECT_PATH1,x,y,z,yaw)
				set .velo = VELO
				set .damage = ( .owner.magic_power * DAMAGE_PER_MAGICPOWER ) * ( 1+DAMAGE_PER_LEVEL*(level-1) )
				set .damage_id = ID
				call setCollision(COLRAD)
				call setExplosion(EXPRAD)
				call setDuration((RANGE-STARTAT)/VELO)
				call damageFlagTemplateMagicalExplosion()
				set .l = Circle.create(x,y,5.,COLRAD)
				call .l.setColor(255,153,0)
				set .l.alpha = 0.5
				return this
			endmethod

			method onDestroy takes nothing returns nothing
				if .l != 0 then
					call .l.setFadeOutPoint(0.,1.5)
					set .l = 0
				endif
			endmethod

		endstruct

		public struct actor extends UnitActor
	
			real angle = 0.

			method onComplete takes nothing returns nothing
				local ball ms = ball.create(.caster,/*
				*/Math.pPX(.caster.x,STARTAT,Math.anglePoints(.caster.x,.caster.y,.x,.y)),/*
				*/Math.pPY(.caster.y,STARTAT,Math.anglePoints(.caster.x,.caster.y,.x,.y)),.caster.z+.caster.pivot_z,/*
				*/.angle,.level)
				call UnitActor.create(.caster,0,0.,0.,0,BACKSWING,true)
			endmethod
	
			static method create takes Unit u, real x, real y, real delay, integer level returns thistype
				local thistype this = allocate(u,0,x,y,level,delay,true)
				set .angle = Math.anglePoints(.caster.x,.caster.y,.x,.y)
				call .caster.setAnim("attack")
				call .caster.setAnimSpeed(1.66)
				call SetUnitFacing(.caster.origin_unit,Math.anglePoints(.caster.x,.caster.y,x,y))
				set .progress_bar = ProgressBar.create(NAME,.caster.owner)
				return this
			endmethod

			method onDestroy takes nothing returns nothing
				call .caster.queueAnim("stand ready")
				call .caster.setAnimSpeed(1.)
			endmethod
	
		endstruct
	
		private struct ind extends LineIndicator

			method beforeRefresh takes nothing returns nothing
				set .x = .abil.owner.x
				set .y = .abil.owner.y
				set .yaw = Math.anglePoints(.x,.y,Mouse.getVX(owner),Mouse.getVY(owner))
				set .range = RANGE+COLRAD
				set .width = COLRAD
			endmethod

			static method create takes Ability_prototype abil, player owner returns thistype
				local thistype this = allocate(abil,owner)
				call .ef.setColor(255,R2I(0.65*255),0)
				call .circle.setColor(255,R2I(0.65*255),0)
				return this
			endmethod

		endstruct

		public struct main extends Ability
	
			method relativeTooltip takes nothing returns string
				return "지정한 방향으로 화염구를 발사하여 적과 닿으면 범위 내의 적들에게 "+/*
				*/ConstantString.statStringReal(STAT_TYPE_MAGICPOWER,( .owner.magic_power * DAMAGE_PER_MAGICPOWER ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ),1)+/*
				*/"의 "+DAMAGE_STRING_MAGICAL+"를 입힙니다."
			endmethod
	
			method execute takes nothing returns nothing
				call actor.create(.owner,.command_x,.command_y,.cast_delay,level)
			endmethod
	
			method init takes nothing returns nothing
				set .is_active = true
				set .preserve_order = false
				set .cooldown_max = 5.5
				set .cooldown_min = 0.5
				set .cast_delay = DELAY
				set .manacost = 25
				set .indicator = ind.create(this,.owner.owner)
				call plusStatValue(5)
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.addTypeTag(ID,ABILITY_STRING_TARGET_LOCATION)
				call Ability.addTypeTag(ID,ABILITY_TAG_MAGIC)
				call Ability.addTypeTag(ID,ABILITY_TAG_FIRE)
				call Ability.setTypeTooltip(ID,"범위피해 투사체 발사\n ")
			endmethod
	
		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

/*0004 연쇄번개*/
scope Ability0004 initializer init
	//! runtextmacro abilityDataHeader("0004","연쇄번개","btn-ability-swarm-kerrigan-chainreaction","1","STAT_TYPE_MAGICPOWER","STAT_TYPE_ACCURACY")
	
		globals
			private constant real DELAY = 0.2
			private constant real DAMAGE_PER_MAGICPOWER = 1.55
			private constant real DAMAGE_PER_ACCURACY = 0.85
			private constant real DAMAGE_PER_LEVEL = 0.05
			private constant real BACKSWING = 0.15
			private constant real INTERVAL = 0.15
			private constant real RANGE = 575.
			private constant real RANGE_SECOND = 315.
			private constant integer TARGET_MAX = 4
			private constant string EFFECT_PATH1 = "Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl"
		endglobals

		private struct chain extends UnitActor

			Unit target_previous = 0
			integer count = 0

			real radius_explosion = RANGE_SECOND
			group group_wave = null
			group already = null

			implement ExplosionModule

			method explosionFilterAdditional takes Unit_prototype target returns boolean
				return not IsUnitInGroup(target.origin_unit,.already)
			endmethod
	
			method executeExplosion takes Unit_prototype target returns nothing
				call DoNothing()
			endmethod

			method killFilter takes nothing returns boolean
				if .count <= 0 then
					return true
				else
					/*다음타겟 변경*/
					set .target_previous = .target
					set .target = Unit_prototype.get(Group.getNearest(.group_wave,.x,.y,null))
					/*다음 타겟이 있으면*/
					if .target != 0 then
						set .timeout = 0.
						set .duration = INTERVAL
						set .x = .target.x
						set .y = .target.y
						return false
					/*다음 타겟이 없으면*/
					else
						return true
					endif
				endif
			endmethod

			method onComplete takes nothing returns nothing
				/*광원생성*/
				local Lightning l = Lightning.createOO("CLPB",.target_previous,.target)
				set l.oz1 = .target_previous.pivot_z
				set l.oz2 = .target.pivot_z
				set l.duration = 0.45
				set l.alpha = 1.5
				set l.fade = 1.
				/*데미지주기*/
				call damageTarget(.target)
				set .damage = ( .owner.magic_power * DAMAGE_PER_MAGICPOWER ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) )
				/*대상에게 이펙트*/
				call Effect.createAttatched(EFFECT_PATH1,.target.origin_unit,"chest").kill()
				/*최초실행 시 프로그레스바 제거*/
				if .progress_bar != 0 then
					call .progress_bar.destroy()
					set .progress_bar = 0
				endif
				/*카운트 감소*/
				set .count = count - 1
				/*타겟을 이미맞은놈 그룹에 추가*/
				call GroupAddUnit(.already,.target.origin_unit)
				/*wave그룹 채우기*/
				call GroupClear(.group_wave)
				call explosionAction()
			endmethod

			static method create takes Unit caster, Unit target, integer level, integer count returns thistype
				local thistype this = allocate(caster,target,target.x,target.y,level,INTERVAL,false)
				call Effect.createAttatched(EFFECT_PATH1,.caster.origin_unit,"chest").kill()
				set .progress_bar = ProgressBar.create(NAME,.caster.owner)
				set .target_previous = .caster
				set .group_wave = Group.new()
				set .already = Group.new()
				set .count = count
				set .damage = ( .owner.magic_power * DAMAGE_PER_MAGICPOWER ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ) + /*
				*/( .owner.accuracy * DAMAGE_PER_ACCURACY ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) )
				call damageFlagTemplateTargetMagic()
				set .damage_id = ID
				set .weapon_type = WEAPON_TYPE_METAL_LIGHT_CHOP
				call suspendFree()
				return this
			endmethod

			method onDestroy takes nothing returns nothing
				call Group.release(.group_wave)
				call Group.release(.already)
				set .group_wave = null
				set .already = null
			endmethod

		endstruct

		public struct actor extends UnitActor
	
			static method create takes Unit u, Unit target, real delay, integer level returns thistype
				local thistype this = allocate(u,target,0.,0.,level,delay+BACKSWING,true)
				call .caster.setAnim("attack")
				call .caster.setAnimSpeed(1.66)
				call SetUnitFacing(.caster.origin_unit,Math.anglePoints(.caster.x,.caster.y,.target.x,.target.y))
				call chain.create(u,target,level,TARGET_MAX)
				return this
			endmethod

			method onDestroy takes nothing returns nothing
				call .caster.queueAnim("stand ready")
				call .caster.setAnimSpeed(1.)
			endmethod
	
		endstruct
	
		public struct main extends Ability
	
			method relativeTooltip takes nothing returns string
				return "대상을 포함한 최대 "+STRING_COLOR_CONSTANT+I2S(TARGET_MAX)+"기|r의 적들에게 "+/*
				*/ConstantString.statStringReal(STAT_TYPE_MAGICPOWER,( .owner.magic_power * DAMAGE_PER_MAGICPOWER ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ),1)+/*
				*/"의 "+DAMAGE_STRING_MAGICAL+"를 입힙니다.\n첫 대상에게는 피해량이 "+/*
				*/ConstantString.statStringReal(STAT_TYPE_ACCURACY,( .owner.accuracy * DAMAGE_PER_ACCURACY ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ),1)+" 만큼 증가합니다."
			endmethod
	
			method execute takes nothing returns nothing
				call actor.create(.owner,Unit_prototype.get(.command_target),.cast_delay,level)
			endmethod
	
			method init takes nothing returns nothing
				set .manacost = 22
				set .is_active = true
				set .is_target = true
				set .cast_range = RANGE
				set .preserve_order = false
				set .cooldown_max = 5.3
				set .cooldown_min = 0.5
				set .cast_delay = INTERVAL
				set .indicator = AbilityIndicator.create(this,.owner.owner)
				call plusStatValue(5)
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.addTypeTag(ID,ABILITY_STRING_TARGET_UNIT)
				call Ability.addTypeTag(ID,ABILITY_TAG_MAGIC)
				call Ability.addTypeTag(ID,ABILITY_TAG_LIGHTNING)
				call Ability.setTypeTooltip(ID,"다수의 적 연쇄공격\n ")
			endmethod
	
		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

/*0005 신성의 빛*/
scope Ability0005 initializer init
	//! runtextmacro abilityDataHeader("0005","신성의 빛","BTNHolyBolt","1","STAT_TYPE_MAGICPOWER","STAT_TYPE_MAXHP")
	
		globals
			private constant real DELAY = 0.2
			private constant real HEAL_PER_MAGICPOWER = 0.85
			private constant real HEAL_PER_MAXHP = 0.025
			private constant real DAMAGE_PER_LEVEL = 0.05
			private constant real BACKSWING = 0.15
			private constant real RANGE = 600.
			private constant string EFFECT_PATH1 = "Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl"
		endglobals

		public struct actor extends UnitActor
	
			method onComplete takes nothing returns nothing
				call .target.restoreHP(/*
				*/(( .owner.magic_power * HEAL_PER_MAGICPOWER ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) )) + /*
				*/(( .owner.maxhp * HEAL_PER_MAXHP ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ))/*
				*/)
				call Effect.createAttatched(EFFECT_PATH1,.target.origin_unit,"origin").setDuration(1.5)
			endmethod

			static method create takes Unit u, Unit target, real delay, integer level returns thistype
				local thistype this = allocate(u,target,0.,0.,level,delay+BACKSWING,true)
				call .caster.setAnim("attack")
				call .caster.setAnim("spell")
				call .caster.setAnimSpeed(1.25)
				if .caster != .target then
					call SetUnitFacing(.caster.origin_unit,Math.anglePoints(.caster.x,.caster.y,.target.x,.target.y))
				endif
				return this
			endmethod

			method onDestroy takes nothing returns nothing
				call .caster.queueAnim("stand ready")
				call .caster.setAnimSpeed(1.)
			endmethod
	
		endstruct
	
		public struct main extends Ability
	
			method relativeTooltip takes nothing returns string
				return "대상 아군 유닛의 체력을 "+/*
				*/ConstantString.statStringReal(STAT_TYPE_MAGICPOWER,( .owner.magic_power * HEAL_PER_MAGICPOWER ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ),1)+"+"+/*
				*/ConstantString.statStringReal(STAT_TYPE_MAXHP,( .owner.maxhp * HEAL_PER_MAXHP ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ),1)+" 만큼 회복시킵니다."
			endmethod

			method targetFilterAdditional takes Unit_prototype target returns boolean
				if target.hp < target.maxhp then
					return true
				else
					set ERROR_MESSAGE = "대상의 체력이 가득 찼습니다."
					return false
				endif
			endmethod

			method execute takes nothing returns nothing
				call actor.create(.owner,Unit_prototype.get(.command_target),.cast_delay,level)
			endmethod
	
			method init takes nothing returns nothing
				set .target_useable_enemy = false
				set .target_useable_ally = true
				set .target_useable_self = true
				set .manacost = 35
				set .is_active = true
				set .is_target = true
				set .cast_range = RANGE
				set .preserve_order = false
				set .cooldown_max = 8.
				set .cooldown_min = 2.
				set .cast_delay = DELAY
				set .indicator = AbilityIndicator.create(this,.owner.owner)
				call plusStatValue(5)
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.addTypeTag(ID,ABILITY_STRING_TARGET_UNIT)
				call Ability.addTypeTag(ID,ABILITY_TAG_MAGIC)
				call Ability.addTypeTag(ID,ABILITY_TAG_DIVINE)
				call Ability.setTypeTooltip(ID,"단일대상 회복\n ")
			endmethod
	
		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

/*0006 점멸*/
scope Ability0006 initializer init
	//! runtextmacro abilityDataHeader("0006","점멸","BTNBlink","1","STAT_TYPE_EVASION","STAT_TYPE_ACCURACY")
	
		globals
			private constant real RANGE_MAX = 600.
			private constant real CDR_PER_LEVEL = 0.1
			private constant string EFFECT_PATH1 = "Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl"
			private constant string EFFECT_PATH2 = "Abilities\\Spells\\NightElf\\Blink\\BlinkTarget.mdl"
		endglobals

		public struct main extends Ability
	
			method getMaxCooldown takes nothing returns real
				return getMaxCooldownBySpellBoost() / (1+(.level-1)*CDR_PER_LEVEL)
			endmethod

			method relativeTooltip takes nothing returns string
				return "선택한 지점으로 순간이동합니다.\n\n|cff999999다른 행동 중에 사용할 수 있습니다.|r"
			endmethod

			method beforePress takes nothing returns nothing
				set .cast_range = RANGE_MAX
			endmethod

			method beforeRelease takes nothing returns nothing
				set .cast_range = -1.
			endmethod
	
			method execute takes nothing returns nothing
				local real d = Math.distancePoints(.owner.x,.owner.y,.command_x,.command_y)
				local real a = Math.anglePoints(.owner.x,.owner.y,.command_x,.command_y)
				call Effect.create(EFFECT_PATH1,.owner.x,.owner.y,5.,270.).setDuration(1.5)
				if d > RANGE_MAX then
					set .command_x = Math.pPX(.owner.x,RANGE_MAX,a)
					set .command_y = Math.pPY(.owner.y,RANGE_MAX,a)
				endif
				call LocationEx.collisionProjection(.command_x,.command_y)
				set .command_x = LocationEx.getX()
				set .command_y = LocationEx.getY()
				set .owner.x = .command_x
				set .owner.y = .command_y
				call Effect.create(EFFECT_PATH2,.command_x,.command_y,5.,270.).setDuration(1.5)
			endmethod
	
			method init takes nothing returns nothing
				set .manacost = 20
				set .is_active = true
				set .useable_ensnare = false
				set .useable_cast = true
				set .preserve_order = true
				set .cooldown_max = 30.
				set .cooldown_min = 0.
				set .indicator = AbilityIndicator.create(this,.owner.owner)
				call plusStatValue(5)
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.addTypeTag(ID,ABILITY_STRING_TARGET_LOCATION)
				call Ability.addTypeTag(ID,ABILITY_TAG_MAGIC)
				call Ability.setTypeTooltip(ID,"순간이동\n ")
			endmethod
	
		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

/*0007 순보*/
scope Ability0007 initializer init
	//! runtextmacro abilityDataHeader("0007","순보","BTNSavageStrike","1","STAT_TYPE_ATTACK","STAT_TYPE_ACCURACY")
	
		globals
			private constant real RANGE_MAX = 500.
			private constant real DAMAGE_PER_ATTACK = 1.25
			private constant real DAMAGE_PER_ACCURACY = 0.3
			private constant real DAMAGE_PER_LEVEL = 0.1
			private constant integer MANA_RESTORE = 24
			private constant real EXPRAD = 65
			private constant string EFFECT_PATH1 = "Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl"
			private constant string EFFECT_PATH2 = "Effects\\WindSlash.mdl"
			private constant string EFFECT_PATH3 = "Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl"
		endglobals

		private struct exp extends LineExplosion

			boolean b = false

			method executeExplosion takes Unit target returns nothing
				local Effect ef = Effect.create(EFFECT_PATH2,target.x,target.y,target.z+target.pivot_z,270.)
				call ef.setScale(2.)
				call ef.setRoll(45.)
				call ef.setColor(255,0,255)
				call ef.setDuration(1.0)
				set ef = Effect.createAttatched(EFFECT_PATH3,target.origin_unit,"chest").setDuration(1.5)
				call damageTarget(target)
				if not .b then
					call .owner.restoreMP(MANA_RESTORE)
					set .b = true
				endif
			endmethod

			static method create takes Unit caster, real x1, real y1, real x2, real y2, integer level returns thistype
				local thistype this = allocate(caster,x1,y1,x2,y2,EXPRAD)
				local Effect ef = 0
				set .count = 1
				set .damage_id = ID
				set .damage = ( .owner.attack * DAMAGE_PER_ATTACK ) * ( 1+DAMAGE_PER_LEVEL*(level-1) ) + /*
					*/( .owner.accuracy * DAMAGE_PER_ACCURACY ) * ( 1+DAMAGE_PER_LEVEL*(level-1) )
				set .weapon_type = WEAPON_TYPE_METAL_MEDIUM_SLICE
				call damageFlagTemplatePhysicalExplosion()
				/*이펙트*/
				set ef = Effect.create(EFFECT_PATH1,x1,y1,55,.owner.yaw)
				set ef.pitch = -90
				call ef.setMatrixScale(1,1,0.5)
				call ef.setAnimSpeed(2.)
				call ef.setDuration(1.5)
				set ef = Effect.create(EFFECT_PATH1,x2,y2,55,.owner.yaw)
				set ef.pitch = -90
				call ef.setMatrixScale(1,1,2.5)
				call ef.setAnimSpeed(2.)
				call ef.setDuration(1.5)
				return this
			endmethod

		endstruct

		private struct ind extends LineIndicator

			method beforeRefresh takes nothing returns nothing
				set .x = .abil.owner.x
				set .y = .abil.owner.y
				set .yaw = Math.anglePoints(.x,.y,Mouse.getVX(owner),Mouse.getVY(owner))
				set .range = RANGE_MAX
				set .width = EXPRAD
			endmethod

			static method create takes Ability_prototype abil, player owner returns thistype
				local thistype this = allocate(abil,owner)
				call .ef.setColor(255,0,255)
				call .circle.setColor(255,0,255)
				return this
			endmethod

		endstruct

		public struct main extends Ability

			method relativeTooltip takes nothing returns string
				return "지정한 방향으로 짧은 거리 순간이동하며 경로 상의 적들에게 "+/*
				*/ConstantString.statStringReal(STAT_TYPE_ATTACK,( .owner.attack * DAMAGE_PER_ATTACK ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ),1)+"+"+/*
				*/ConstantString.statStringReal(STAT_TYPE_ACCURACY,( .owner.accuracy * DAMAGE_PER_ACCURACY ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ),1)+/*
				*/"의 "+DAMAGE_STRING_PHYSICAL+"를 입힙니다. 한 기 이상의 적에게 적중하면 마나를 "+STRING_COLOR_CONSTANT+I2S(MANA_RESTORE)+"|r 회복합니다."
			endmethod

			method beforePress takes nothing returns nothing
				set .cast_range = RANGE_MAX
			endmethod

			method beforeRelease takes nothing returns nothing
				set .cast_range = -1.
			endmethod
	
			method execute takes nothing returns nothing
				local real d = Math.distancePoints(.owner.x,.owner.y,.command_x,.command_y)
				local real a = Math.anglePoints(.owner.x,.owner.y,.command_x,.command_y)
				local real bx = .owner.x
				local real by = .owner.y
				local Explosion ex = 0
				if d > RANGE_MAX then
					set .command_x = Math.pPX(.owner.x,RANGE_MAX,a)
					set .command_y = Math.pPY(.owner.y,RANGE_MAX,a)
				endif
				call LocationEx.collisionProjection(.command_x,.command_y)
				set .command_x = LocationEx.getX()
				set .command_y = LocationEx.getY()
				set .owner.x = .command_x
				set .owner.y = .command_y
				set .owner.yaw = Math.anglePoints(bx,by,.owner.x,.owner.y)
				/*라인익스플로전*/
				set ex = exp.create(.owner,bx,by,.owner.x,.owner.y,.level)
				call ex.activate()
			endmethod
	
			method init takes nothing returns nothing
				set .manacost = 40
				set .is_active = true
				set .useable_ensnare = false
				set .preserve_order = false
				set .cooldown_max = 6.
				set .cooldown_min = 0.5
				set .indicator = ind.create(this,.owner.owner)
				call plusStatValue(5)
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.addTypeTag(ID,ABILITY_STRING_TARGET_LOCATION)
				call Ability.addTypeTag(ID,ABILITY_TAG_ASSASSINATE)
				call Ability.setTypeTooltip(ID,"순간이동 및\n직선 범위공격")
			endmethod
	
		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

/*0008 다중사격*/
scope Ability0008 initializer init
	//! runtextmacro abilityDataHeader("0008","다중사격","BTNMultishot","1","STAT_TYPE_ATTACK","STAT_TYPE_ACCURACY")
	
		globals
			private constant real DELAY = 0.2
			private constant real DAMAGE_PER_ATTACK = 1.75
			private constant real DAMAGE_PER_LEVEL = 0.05
			private constant real DAMAGE_ADDITIONAL = 0.15
			private constant real BACKSWING = 0.15
			private constant real STARTAT = 32.5
			private constant real COLRAD = 32.5
			private constant real VELO = 1100.
			private constant real RANGE = 725.
			private constant integer COUNT = 5
			private constant real WIDTH = 30.
			private constant string EFFECT_PATH1 = "Abilities\\Weapons\\GuardTowerMissile\\GuardTowerMissile.mdl"
		endglobals
	
		private struct arrow extends Missile

			method executeTarget takes Unit target returns nothing
				if IsUnitInGroup(target.origin_unit,.group_wave) then
					/*약한데미지*/
					set .damage = .damage * DAMAGE_ADDITIONAL
					set .is_onhit = false
				endif
				call damageTarget(target)
			endmethod

			static method create takes Unit owner, real x, real y, real z, real yaw, integer level returns thistype
				local thistype this = allocate(owner,EFFECT_PATH1,x,y,z,yaw)
				set .velo = VELO
				set .damage = ( .owner.attack * DAMAGE_PER_ATTACK ) * ( 1+DAMAGE_PER_LEVEL*(level-1) )
				set .damage_id = ID
				call setCollision(COLRAD)
				call setDuration((RANGE-STARTAT)/VELO)
				call damageFlagTemplateTargetMagic()
				set .damage_type = DAMAGE_TYPE_PHYSICAL
				set .weapon_type = WEAPON_TYPE_METAL_MEDIUM_BASH
				return this
			endmethod

		endstruct

		public struct actor extends UnitActor
	
			real angle = 0.

			method onComplete takes nothing returns nothing
				local integer i = 0
				local arrow ms = 0
				local real a = 0.
				local MissileGroup mg = MissileGroup.create()
				loop
					exitwhen i >= COUNT
					set a = .angle - (WIDTH/2) + (WIDTH*i)/(COUNT-1)
					set ms = arrow.create(.caster,/*
					*/Math.pPX(.caster.x,STARTAT,a),/*
					*/Math.pPY(.caster.y,STARTAT,a),.caster.z+.caster.pivot_z,/*
					*/a,.level)
					call mg.add(ms)
					set i = i + 1
				endloop
				call UnitActor.create(.caster,0,0.,0.,0,BACKSWING,true)
			endmethod
	
			static method create takes Unit u, real x, real y, real delay, integer level returns thistype
				local thistype this = allocate(u,0,x,y,level,delay,true)
				set .angle = Math.anglePoints(.caster.x,.caster.y,.x,.y)
				call .caster.setAnim("attack")
				call .caster.setAnimSpeed(1.66)
				call SetUnitFacing(.caster.origin_unit,Math.anglePoints(.caster.x,.caster.y,x,y))
				set .progress_bar = ProgressBar.create(NAME,.caster.owner)
				return this
			endmethod

			method onDestroy takes nothing returns nothing
				call .caster.queueAnim("stand ready")
				call .caster.setAnimSpeed(1.)
			endmethod
	
		endstruct
	
		private struct ind extends LineIndicator

			method beforeRefresh takes nothing returns nothing
				set .x = .abil.owner.x
				set .y = .abil.owner.y
				set .yaw = Math.anglePoints(.x,.y,Mouse.getVX(owner),Mouse.getVY(owner))
				set .range = RANGE+COLRAD
				set .width = COLRAD
			endmethod

			static method create takes Ability_prototype abil, player owner returns thistype
				local thistype this = allocate(abil,owner)
				call .ef.setColor(255,R2I(0.65*255),0)
				call .circle.setColor(255,R2I(0.65*255),0)
				return this
			endmethod

		endstruct

		public struct main extends Ability
	
			method relativeTooltip takes nothing returns string
				return "전방으로 "+STRING_COLOR_CONSTANT+I2S(COUNT)+"개|r의 화살을 일제히 발사합니다. 각 화살은 "+/*
				*/ConstantString.statStringReal(STAT_TYPE_ATTACK,( .owner.attack * DAMAGE_PER_ATTACK ) * ( 1+DAMAGE_PER_LEVEL*(.level-1) ),1)+/*
				*/"의 "+DAMAGE_STRING_PHYSICAL+"를 입힙니다.\n\n - 이미 적중한 대상에게는 "+STRING_COLOR_CONSTANT+I2S(R2I(DAMAGE_ADDITIONAL*100))+"%|r의 피해를 입힙니다."
			endmethod
	
			method execute takes nothing returns nothing
				call actor.create(.owner,.command_x,.command_y,.cast_delay,level)
			endmethod
	
			method init takes nothing returns nothing
				set .is_active = true
				set .preserve_order = false
				set .cooldown_max = 3.5
				set .cooldown_min = 0.5
				set .cast_delay = DELAY
				set .manacost = 15
				set .indicator = ind.create(this,.owner.owner)
				call plusStatValue(5)
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.addTypeTag(ID,ABILITY_STRING_TARGET_LOCATION)
				call Ability.addTypeTag(ID,ABILITY_TAG_ARCHERY)
				call Ability.addTypeTag(ID,ABILITY_TAG_SHOOTING)
				call Ability.setTypeTooltip(ID,"다수의 투사체 발사\n")
			endmethod
	
		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

/*u000 뛰어들기*/
scope Abilityu000 initializer init
	//! runtextmacro abilityDataHeader("u000","뛰어들기","BTNGhoulFrenzy","1","STAT_TYPE_ATTACK","STAT_TYPE_ARMOR_PENET")
	
		globals
			private constant real DAMAGE_PER_ATTACK = 2.
			private constant real DAMAGE_PER_LEVEL = 0.05
			private constant real BACKSWING = 0.15
			private constant real RANGE = 500.
			private constant real RANGE_ADDITIONAL = 100.
			private constant real VELO = 1500.
		endglobals

		public struct actor extends UnitMovement

			Unit ability_target = 0

			method onComplete takes nothing returns nothing
				call damageTarget(.ability_target)
				call .caster.issueTargetOrder("attack",.ability_target.origin_unit)
			endmethod
			
			static method create takes Unit caster, Unit target, integer level returns thistype
				local thistype this = allocate(caster,VELO,Math.anglePoints(caster.x,caster.y,target.x,target.y))
				set .ability_target = target
				set .duration = (Math.distancePoints(caster.x,caster.y,target.x,target.y)+RANGE_ADDITIONAL)/VELO
				set .z_velo = 800.
				set .gravity = 1600./.duration
				set .level = level
				set .use_collision = false
				set .ability_target = target
				set .damage_id = ID
				call damageFlagTemplateTargetMagic()
				set .damage_type = DAMAGE_TYPE_PHYSICAL
				set .damage = (.caster.attack * DAMAGE_PER_ATTACK) * (1+DAMAGE_PER_LEVEL*(.level-1))
				set .weapon_type = WEAPON_TYPE_METAL_HEAVY_CHOP
				call .caster.setAnim("attack")
				call .caster.setAnimSpeed(1.5)
				call .caster.queueAnim("stand ready")
				return this
			endmethod

			method onDestroy takes nothing returns nothing
				call .caster.setAnimSpeed(1.0)
			endmethod

		endstruct
	
		public struct main extends Ability
	
			method relativeTooltip takes nothing returns string
				return "대상에게 뛰어들어 "+/*
				*/ConstantString.statStringReal(STAT_TYPE_ATTACK,(.owner.attack * DAMAGE_PER_ATTACK) * (1+DAMAGE_PER_LEVEL*(.level-1)),1)+/*
				*/"의 "+DAMAGE_STRING_PHYSICAL+"를 입힙니다."
			endmethod
	
			method execute takes nothing returns nothing
				call actor.create(.owner,Unit_prototype.get(.command_target),level)
			endmethod
	
			method init takes nothing returns nothing
				set .manacost = 20
				set .is_active = true
				set .is_target = true
				set .useable_ensnare = false
				set .cast_range = RANGE
				set .preserve_order = false
				set .cooldown_max = 6.5
				set .cooldown_min = 0.5
				set .indicator = AbilityIndicator.create(this,.owner.owner)
				call plusStatValue(5)
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.addTypeTag(ID,ABILITY_STRING_TARGET_UNIT)
				call Ability.addTypeTag(ID,ABILITY_TAG_BRAWL)
				call Ability.addTypeTag(ID,ABILITY_TAG_UNDEAD)
				call Ability.setTypeTooltip(ID,"대상에게 돌진\n ")
			endmethod
	
		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

/*u001 끈적거미(버프)*/
scope Buffu001 initializer init
	//! runtextmacro buffHeader("끈적거미","u001","0","BTNMonsterSpiderCarapace_01")

	public struct main extends Buff

		static constant real SLOW = 5.
		static constant string EFFECT_PATH1 = "Abilities\\Weapons\\CryptFiendMissile\\CryptFiendMissile.mdl"
		real val = 0.

		private method addValue takes nothing returns nothing
			set .val = .val + SLOW
			call .target.minusStatValue(STAT_TYPE_MOVEMENT_SPEED,SLOW)
		endmethod

		method update takes nothing returns nothing
			call addValue()
		endmethod

		method init takes nothing returns nothing
			call addValue()
			call addEffect(Effect.createAttatched(EFFECT_PATH1,.target.origin_unit,"chest"))
		endmethod

		method onDestroy takes nothing returns nothing
			call .target.minusStatValue(STAT_TYPE_MOVEMENT_SPEED,-.val)
		endmethod

	endstruct

	//! runtextmacro buffEnd()
endscope

/*u001 끈적거미*/
scope Abilityu001 initializer init
	//! runtextmacro abilityDataHeader("u001","끈적거미","BTNMonsterSpiderCarapace_01","1","STAT_TYPE_ACCURACY","STAT_TYPE_ATTACK")
	
		globals
			private constant real BACKSWING = 0.25
			private constant real STARTAT = 25.
			private constant string EFFECT_PATH1 = "Abilities\\Weapons\\CryptFiendMissile\\CryptFiendMissile.mdl"
			private constant real DAMAGE_PER_ATTACK = 1.05
			private constant real DAMAGE_PER_LEVEL = 0.05
			private constant real VELO = 900
			private constant real DURATION = 4.
		endglobals

		private struct mss extends Missile

			method executeTarget takes Unit target returns nothing
				if damageTarget(target) > 0. then
					call Buff.add(.owner,target,ID,DURATION)
				endif
			endmethod

			static method create takes Unit caster, Unit target, real x, real y, real z, real yaw, integer level returns thistype
				local thistype this = allocate(caster,EFFECT_PATH1,x,y,z,yaw)
				call setTarget(target)
				set .velo = VELO
				set .damage_id = ID
				set .damage = (.owner.attack * DAMAGE_PER_ATTACK) * (1+DAMAGE_PER_LEVEL*(level-1))
				call damageFlagTemplateRangedAttack()
				return this
			endmethod

		endstruct
	
		public struct actor extends MeleeAttack

			method onComplete takes nothing returns nothing
				local real a = Math.anglePoints(.caster.x,.caster.y,.target.x,.target.y)
				local mss ms = mss.create(.caster,.target,Math.pPX(.caster.x,STARTAT,a),Math.pPY(.caster.y,STARTAT,a),.caster.z+.caster.pivot_z,a,.level)
				call Backswing.create(.caster)
			endmethod
	
			static method create takes Unit caster, Unit target, integer level returns thistype
				local thistype this = allocate(caster,target)
				set .level = level
				return this
			endmethod

		endstruct
	
		public struct main extends Ability

			method relativeTooltip takes nothing returns string
				return "대상에게 "+/*
				*/ConstantString.statStringReal(STAT_TYPE_ATTACK,(.owner.attack * DAMAGE_PER_ATTACK) * (1+DAMAGE_PER_LEVEL*(.level-1)),1)+/*
				*/"의 "+DAMAGE_STRING_PHYSICAL+"를 입히고 "+STRING_COLOR_CONSTANT+R2SW(DURATION,1,1)+"초|r 동안 "+/*
				*/STAT_TYPE_NAME[STAT_TYPE_MOVEMENT_SPEED]+"를 "+STRING_COLOR_CONSTANT+I2S(R2I(Buffu001_main.SLOW))+"|r 감소시키는 거미떼를 날려보냅니다.\n\n"+/*
				*/"|cff999999이동속도 감소효과는 중첩됩니다.|r"
			endmethod

			method basicAttack takes Unit target returns nothing
				local actor ac = actor.create(.owner,target,level)
			endmethod

			method init takes nothing returns nothing
				set .weapon_delay = 1.5
				set .weapon_range = 500.
				set .count = 0
				call plusStatValue(5)
			endmethod

			static method onInit takes nothing returns nothing
				call Ability.addTypeTag(ID,ABILITY_STRING_WEAPON)
				call Ability.addTypeTag(ID,ABILITY_TAG_BUG)
				call Ability.addTypeTag(ID,ABILITY_TAG_UNDEAD)
				call Ability.setTypeTooltip(ID,"거미떼 공격,\n대상 이동속도 감소")
			endmethod
	
		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

scope AddRandomAbility1 initializer init

	private function init takes nothing returns nothing
		call Ability.addRandomAbility('0000',1)
		call Ability.addRandomAbility('0001',1)
		call Ability.addRandomAbility('0002',1)
		call Ability.addRandomAbility('0003',1)
		call Ability.addRandomAbility('0004',1)
		call Ability.addRandomAbility('0005',1)
		call Ability.addRandomAbility('0006',1)
		call Ability.addRandomAbility('0007',1)
		call Ability.addRandomAbility('0008',1)
	endfunction

endscope