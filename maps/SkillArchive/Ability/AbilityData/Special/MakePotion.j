/*0010 물약제조*//*0011 폭발, 0012 맹독*/
scope Ability0010 initializer init
	//! runtextmacro abilityDataHeader("0010","물약 제조","BTNVialEmpty","2","STAT_TYPE_HPREGEN","STAT_TYPE_MPREGEN","false")
	
		globals
			private constant integer ID2 = '0011'
			private constant integer ID3 = '0012'
			private constant real CHANNELING = 3.
			private constant real DELAY = 0.2
			private constant real DAMAGE_BASE = 80
			private constant real DAMAGE_PER_LEVEL = 0.2
			private constant real HEAL_BAESU = 0.65
			private constant real MANA_RESTORE = 20
			private constant real MANA_RESTORE_PER_LEVEL = 2
			private constant real BACKSWING = 0.15
			private constant real EXPRAD = 175.
			private constant real RANGE = 600.
			private constant real FLIGHT_DURATION = 0.5
			private constant integer MANACOST2 = 20
			private constant integer POTION_MAX = 10
			private constant integer POTION_MAX_PER_LEVEL = 2
			private constant string EFFECT_PATH1 = "Effects\\ThrowingHealthPotion.mdl"
			private constant string EFFECT_PATH2 = "Effects\\ThrowingManaPotion.mdl"
			private constant string EFFECT_PATH3 = "Abilities\\Weapons\\BatTrollMissile\\BatTrollMissile.mdl"
			private constant string EFFECT_PATH4 = "Abilities\\Spells\\Other\\AcidBomb\\BottleMissile.mdl"
			private constant string EFFECT_PATH5 = "Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl"
			private constant string EFFECT_PATH6 = "Abilities\\Weapons\\Mortar\\MortarMissile.mdl"
			private constant string EFFECT_PATH7 = "Abilities\\Spells\\Undead\\ReplenishMana\\ReplenishManaCaster.mdl"
			private constant string EFFECT_PATH8 = "Abilities\\Spells\\Items\\AIma\\AImaTarget.mdl"
			private constant string EFFECT_PATH9 = "Objects\\Spawnmodels\\Other\\ToonBoom\\ToonBoom.mdl"
			private constant string EFFECT_PATH10 = "Abilities\\Spells\\Undead\\ReplenishHealth\\ReplenishHealthCaster.mdl"
			private constant string EFFECT_PATH11 = "Abilities\\Spells\\Human\\Heal\\HealTarget.mdl"
			private constant string EFFECT_PATH12 = "Abilities\\Weapons\\ChimaeraAcidMissile\\ChimaeraAcidMissile.mdl"
			/**/
			private trigger POTION_ADD_TRIGGER = CreateTrigger()
			private integer POTION_ADD_ABILITY = 0		/*어떤 어빌리티에게 추가할 것인가*/
			private integer POTION_ADD_INDEX = 0		/*어떤 종류의 물약을 추가할 것인가*/
		endglobals

		public struct potion extends Missile

			integer potion_index = 0
			integer level = 0
			real tx = 0.
			real ty = 0.

			method executeExplosion takes Unit_prototype target returns nothing
				if .potion_index == 0 then
					call target.restoreHP(.damage*HEAL_BAESU)
				elseif .potion_index == 1 then
					call target.restoreMP(MANA_RESTORE+MANA_RESTORE_PER_LEVEL*(.level-1))
				elseif .potion_index == 2 or .potion_index == 3 then
					call damageTarget(target)
				endif
			endmethod

			method beforeExplosion takes nothing returns nothing
				set .x = .tx
				set .y = .ty
			endmethod

			method afterExplosion takes nothing returns nothing
				local Circle c = Circle.create(.x,.y,5.,EXPRAD)
				local real rd = 0.
				local real ra = 0.
				local integer i = 0
				/*힐링*/
				if .potion_index == 0 then
					call c.setColor(0,255,0)
					call Effect.create(EFFECT_PATH10,.x,.y,5.,270.).setScale(1.65).setDuration(0.75)
					call Effect.create(EFFECT_PATH11,.x,.y,5.,270.).setScale(1.65).setDuration(1.5)
				/*마나*/
				elseif .potion_index == 1 then
					call c.setColor(0,153,255)
					call Effect.create(EFFECT_PATH7,.x,.y,5.,270.).setScale(1.65).setDuration(0.75)
					call Effect.create(EFFECT_PATH8,.x,.y,5.,270.).setScale(1.65).setDuration(1.5)
				/*폭발*/
				elseif .potion_index == 2 then
					call c.setColor(255,153,0)
					call Effect.create(EFFECT_PATH5,.x,.y,5.,270.).setScale(1.25).setDuration(1.5)
					call Effect.create(EFFECT_PATH6,.x,.y,5.,270.).setScale(1.25).setAnimSpeed(0.66).kill()
				/*맹독*/
				elseif .potion_index == 3 then
					call c.setColor(0,153,0)
					call Effect.create(EFFECT_PATH12,.x,.y,5.,270.).setScale(1.65).kill()
				endif
				call setScale(1.75)
				call c.setFadeOutPoint(0,1.25)
			endmethod

			static method create takes Unit caster, real x, real y, integer level, integer potion_index returns thistype
				local thistype this = 0
				/*힐링물약*/
				if potion_index == 0 then
					set this = allocate(caster,EFFECT_PATH1,caster.x,caster.y,0.,Math.anglePoints(caster.x,caster.y,x,y))
					set .affect_ally = true
					set .affect_enemy = false
					set .affect_invincible = true
					set .affect_self = true
				/*마나물약*/
				elseif potion_index == 1 then
					set this = allocate(caster,EFFECT_PATH2,caster.x,caster.y,0.,Math.anglePoints(caster.x,caster.y,x,y))
					set .affect_ally = true
					set .affect_enemy = false
					set .affect_invincible = true
				/*폭발물약*/
				elseif potion_index == 2 then
					set this = allocate(caster,EFFECT_PATH3,caster.x,caster.y,0.,Math.anglePoints(caster.x,caster.y,x,y))
					set .damage_id = ID2
					call damageFlagTemplatePhysicalExplosion()
				/*맹독물약*/
				elseif potion_index == 3 then
					set this = allocate(caster,EFFECT_PATH4,caster.x,caster.y,0.,Math.anglePoints(caster.x,caster.y,x,y))
					set .damage_id = ID3
					call damageFlagTemplateMagicalExplosion()
				endif
				set .damage = DAMAGE_BASE * (1+(.level-1)*DAMAGE_PER_LEVEL)
				set .velo = Math.distancePoints(.owner.x,.owner.y,x,y)/FLIGHT_DURATION
				set .z_velo = 2250.
				set .gravity = (2250.*2)/FLIGHT_DURATION
				set .potion_index = potion_index
				set .level = level
				set .tx = x
				set .ty = y
				call setExplosion(EXPRAD)
				call setDuration(5.)
				return this
			endmethod

		endstruct

		public struct make extends UnitActor

			Effect ef = 0

			real mp = 0.

			integer potion_index = 0

			method periodicAction takes nothing returns nothing
				call .ef.setPosition(.caster.x,.caster.y,25.)
			endmethod

			method onComplete takes nothing returns nothing
				local Ability ta = .caster.getAbilityById(ID)
				if ta > 0 then
					call Effect.create(EFFECT_PATH9,.caster.x,.caster.y,0.,270.).setDuration(1.5)
					set POTION_ADD_ABILITY = ta
					set POTION_ADD_INDEX = .potion_index
					call TriggerEvaluate(POTION_ADD_TRIGGER)
				else

				endif
			endmethod

			method onSuspend takes nothing returns nothing
				set .caster.mp = .caster.mp + .mp
			endmethod

			static method create takes Unit caster, integer potion_index, real mp returns thistype
				local thistype this = allocate(caster,0,0.,0.,0,CHANNELING,true)
				set .potion_index = potion_index
				set .mp = mp
				set .suspend_rclick = true
				set .suspend_stop = true
				set .progress_bar = ProgressBar.create(NAME,.caster.owner)
				set .caster.mp = .caster.mp - .mp
				set .ef = Effect.create("Effects\\CircleIndicator00.mdl",.caster.x,.caster.y,25.,0.)
				call .ef.setScale(0.66)
				call .ef.setAnimSpeed(1./3.)
				if potion_index == 0 then
					call .ef.setColor(0,255,0)
				elseif potion_index == 1 then
					call .ef.setColor(0,153,255)
				elseif potion_index == 2 then
					call .ef.setColor(255,153,0)
				elseif potion_index == 3 then
					call .ef.setColor(200,0,200)
				endif
				return this
			endmethod

			method onDestroy takes nothing returns nothing
				call .ef.destroy()
			endmethod

		endstruct

		public struct actor extends UnitActor
	
			integer potion_index

			method onComplete takes nothing returns nothing
				call potion.create(.caster,.x,.y,.level,.potion_index)
				call UnitActor.create(.caster,0,0.,0.,0,BACKSWING,true)
			endmethod
	
			method onSuspend takes nothing returns nothing
				local potion p = potion.create(.caster,.caster.x,.caster.y,.level,.potion_index)
				set p.want_kill = true
			endmethod

			static method create takes Unit u, real x, real y, real delay, integer level, integer potion_index returns thistype
				local thistype this = allocate(u,0,x,y,level,delay,true)
				call .caster.setAnim("attack")
				call .caster.setAnimSpeed(1.66)
				set .potion_index = potion_index
				call SetUnitFacing(.caster.origin_unit,Math.anglePoints(.caster.x,.caster.y,x,y))
				set .progress_bar = ProgressBar.create("물약 투척",.caster.owner)
				return this
			endmethod

			method onDestroy takes nothing returns nothing
				call .caster.queueAnim("stand ready")
				call .caster.setAnimSpeed(1.)
			endmethod
	
		endstruct
	
		private struct ind extends AbilityIndicator

			Effect c = 0

			method refresh takes nothing returns nothing
				call .c.setPosition(Mouse.getVX(.owner),Mouse.getVY(.owner),2.)
			endmethod

			method show takes boolean flag returns nothing
				if flag then
					if GetLocalPlayer() == .owner then
						call .c.setLocalAlpha(192)
					endif
				else
					call .c.setLocalAlpha(0)
				endif
			endmethod

			static method create takes Ability_prototype abil, player owner returns thistype
				local thistype this = allocate(abil,owner)
				set .c = Effect.create("Effects\\RCircle.mdl",0.,0.,2.,270.)
				call .c.setScale(EXPRAD/100.)
				call .c.setLocalAlpha(0)
				return this
			endmethod

			method onDestroy takes nothing returns nothing
				call .c.destroy()
			endmethod

		endstruct

		public struct main extends Ability

			private static constant integer POTION_TYPE_MAX = 4
			private static integer INDEX_BTN_CREATE = 0
			private static integer INDEX_BTN_SET	= 0
			private static integer INDEX_POTION_COUNT = 0
			private static integer INDEX_COUNT_TEXT = 0
			private static integer INDEX_TOOLTIP_BACKDROP = 0
			private static integer INDEX_TOOLTIP_TEXT = 0
			private static integer INDEX_TOOLTIP_CONTAINER = 0
			private static string array POTION_ICON_PATH
			private static string array POTION_NAME

			integer potion_index = 0
			boolean visible_flag = false

			framehandle container = null

			trigger keypress = null
			triggercondition keypress_cond = null

			private static hashtable HASH = InitHashtable()
			implement GetSetFrame

			method refreshTooltip takes nothing returns nothing
				call BlzFrameSetText(getFrame(INDEX_TOOLTIP_TEXT+0),"|cffffff00"+POTION_NAME[0]+"|r\n\n범위 내 아군의 체력을 "+STRING_COLOR_CONSTANT+/*
				*/R2SW(DAMAGE_BASE * (1+(.level-1)*DAMAGE_PER_LEVEL) * HEAL_BAESU,1,1)+"|r 회복시킵니다.")
				call BlzFrameSetText(getFrame(INDEX_TOOLTIP_TEXT+1),"|cffffff00"+POTION_NAME[1]+"|r\n\n범위 내 아군의 마나를 "+STRING_COLOR_CONSTANT+/*
				*/R2SW(MANA_RESTORE+MANA_RESTORE_PER_LEVEL*(.level-1),1,1)+"|r 회복시킵니다.\n\n|cffff0000시전자에게는 효과가 없습니다.|r")
				call BlzFrameSetText(getFrame(INDEX_TOOLTIP_TEXT+2),"|cffffff00"+POTION_NAME[2]+"|r\n\n범위 내 적들에게 "+/*
				*/STRING_COLOR_CONSTANT+R2SW(DAMAGE_BASE * (1+(.level-1)*DAMAGE_PER_LEVEL),1,1)+"|r의 "+/*
				*/ABILITY_TAG_DRUG+", "+ABILITY_TAG_FIRE+"계열 "+DAMAGE_STRING_PHYSICAL+"를 입힙니다.")
				call BlzFrameSetText(getFrame(INDEX_TOOLTIP_TEXT+3),"|cffffff00"+POTION_NAME[3]+"|r\n\n범위 내 적들에게 "+/*
				*/STRING_COLOR_CONSTANT+R2SW(DAMAGE_BASE * (1+(.level-1)*DAMAGE_PER_LEVEL),1,1)+"|r의 "+/*
				*/ABILITY_TAG_DRUG+", "+ABILITY_TAG_POISON+"계열 "+DAMAGE_STRING_MAGICAL+"를 입힙니다.")
			endmethod

			method refreshButton takes nothing returns nothing
				local integer i = 0
				loop
					exitwhen i >= POTION_TYPE_MAX
					if i == .potion_index then
						call BlzFrameSetVisible(getFrame(INDEX_COUNT_TEXT+i),true)
					else
						call BlzFrameSetVisible(getFrame(INDEX_COUNT_TEXT+i),false)
					endif
					call BlzFrameSetText(BlzGetFrameByName("MakePotionCreateButtonText",this*POTION_TYPE_MAX+i),/*
						*/"|cff00cc00"+I2S(LoadInteger(HASH,this,INDEX_POTION_COUNT+i))+"|r")
					set i = i + 1
				endloop
				call refreshTooltip()
			endmethod

			private method switchUI takes nothing returns nothing
				/*켜져있으면 숨기기*/
				if .visible_flag then
					call BlzFrameSetVisible(.container,false)
				/*안켜져있으면 열기*/
				else
					call BlzFrameSetVisible(.container,GetLocalPlayer()==.owner.owner)
				endif
				set .visible_flag = not .visible_flag
			endmethod

			method iconClick takes nothing returns nothing
				call switchUI()
			endmethod

			method relativeTooltip takes nothing returns string
				return "|cff00ffff아이콘 클릭 : |r물약 제조 UI를 열거나 닫습니다. 숫자가 표시된 버튼을 클릭하면 해당 물약을 제조하며, 물약 아이콘을 클릭하면 사용할 물약 종류를 해당 물약으로 설정합니다.\n"+/*
				*/"물약 제조에는 "+STRING_COLOR_CONSTANT+I2S(MANACOST2)+"|r의 마나와 "+STRING_COLOR_CONSTANT+R2SW(CHANNELING,1,1)+"초|r의 정신집중이 필요합니다.\n"+/*
				*/"총 물약 소지 개수는 "+STRING_COLOR_CONSTANT+I2S(POTION_MAX+POTION_MAX_PER_LEVEL*(.level-1))+"개|r를 초과할 수 없습니다.\n\n|cff00ffff사용 시 : |r"+/*
				*/"물약 제조 UI에서 선택된 물약을 대상 지점으로 투척합니다. 물약 투척이 방해받으면 시전자의 위치에서 폭발합니다."
			endmethod
	
			method useFilterAdditional takes nothing returns boolean
				if LoadInteger(HASH,this,INDEX_POTION_COUNT+.potion_index) > 0 then
					return true
				else
					set ERROR_MESSAGE = "선택된 종류의 물약을 가지고 있지 않습니다."
					return false
				endif
			endmethod

			method execute takes nothing returns nothing
				call actor.create(.owner,.command_x,.command_y,.cast_delay,level,.potion_index)
				call SaveInteger(HASH,this,INDEX_POTION_COUNT+.potion_index,LoadInteger(HASH,this,INDEX_POTION_COUNT+.potion_index)-1)
				call refreshButton()
			endmethod

			method makeFilter takes nothing returns boolean
				local integer i = 0
				local integer j = 0
				loop
					exitwhen i >= POTION_TYPE_MAX
					set j = j + LoadInteger(HASH,this,INDEX_POTION_COUNT+i)
					set i = i + 1
				endloop
				if POTION_MAX+POTION_MAX_PER_LEVEL*(.level-1) > j then
					return true
				else
					set ERROR_MESSAGE = "더 이상 물약을 제조할 수 없습니다."
					return false
				endif
			endmethod
	
			private static method click takes nothing returns nothing
				local thistype this = 0
				local integer i = 0
				call BlzFrameSetEnable(BlzGetTriggerFrame(),false)
				call BlzFrameSetEnable(BlzGetTriggerFrame(),true)
				if BlzGetTriggerFrameEvent() == FRAMEEVENT_CONTROL_CLICK then
					/*물약제조*/
					set this = Trigger.getData(GetTriggeringTrigger())
					loop
						exitwhen i >= POTION_TYPE_MAX
						if BlzGetTriggerFrame() == getFrame(INDEX_BTN_CREATE+i) then
							/*TODO CREATE*/
							set .manacost = MANACOST2
							set ERROR_MESSAGE = ""
							if enableFilter() and costFilter() and castFilter() and makeFilter() then
								call make.create(.owner,i,getCarculatedManacost())
							else
								call sendError()
							endif
							set .manacost = 0
							call refreshButton()
							return 
						endif
						set i = i + 1
					endloop
					set i = 0
					/*사용할 물약 선택*/
					loop
						exitwhen i >= POTION_TYPE_MAX
						if BlzGetTriggerFrame() == getFrame(INDEX_BTN_SET+i) then
							set .potion_index = i
							call refreshButton()
							return 
						endif
						set i = i + 1
					endloop
				endif
			endmethod

			method update takes nothing returns nothing
				call refreshTooltip()
			endmethod

			method init takes nothing returns nothing
				local integer i = 0
				local framehandle f = null
				local framehandle bf = null
				set .is_active = true
				set .preserve_order = false
				set .cooldown_max = 0.5
				set .cooldown_min = 0.5
				set .cast_delay = DELAY
				set .cast_range = RANGE
				set .manacost = 0
				set .indicator = ind.create(this,.owner.owner)
				call plusStatValue(5)
				/*INIT EXTRA*/
				/*트리거*/
				set .keypress = Trigger.new(this)
				set .keypress_cond = TriggerAddCondition(.keypress,function thistype.click)
				/*컨테이너*/
				set .container = BlzCreateFrame("MBEdge",FRAME_MAKE_POTION,0,0)
				call BlzFrameSetPoint(.container,FRAMEPOINT_BOTTOMRIGHT,FRAME_STAT2,FRAMEPOINT_TOPRIGHT,0.,0.)
				call BlzFrameSetSize(.container,Math.px2Size((80*POTION_TYPE_MAX)+16),Math.px2Size(144))
				call BlzFrameSetVisible(.container,false)
				/*생성버튼&선택버튼*/
				loop
					exitwhen i >= POTION_TYPE_MAX
					/*물약갯수초기화*/
					call SaveInteger(HASH,this,INDEX_POTION_COUNT+i,0)
					/*선택*/
					set f = setFrame(INDEX_BTN_SET+i,BlzCreateFrame("MakePotionSetButton",.container,0,this*POTION_TYPE_MAX+i))
					call BlzFrameSetPoint(f,FRAMEPOINT_TOPLEFT,.container,FRAMEPOINT_TOPLEFT,Math.px2Size(16+80*i),Math.px2Size(-16))
					call BlzFrameSetSize(f,Math.px2Size(64),Math.px2Size(64))
					call BlzTriggerRegisterFrameEvent(.keypress,f,FRAMEEVENT_CONTROL_CLICK)
					call BlzTriggerRegisterFrameEvent(.keypress,f,FRAMEEVENT_MOUSE_LEAVE)
					set bf = f
					set f = BlzGetFrameByName("MakePotionSetButtonIcon",this*POTION_TYPE_MAX+i)
					call BlzFrameSetPoint(f,FRAMEPOINT_CENTER,bf,FRAMEPOINT_CENTER,0.,0.)
					call BlzFrameSetSize(f,Math.px2Size(48),Math.px2Size(48))
					call BlzFrameSetTexture(f,POTION_ICON_PATH[i],0,true)
					/*생성*/
					set f = setFrame(INDEX_BTN_CREATE+i,BlzCreateFrame("MakePotionCreateButton",.container,0,this*POTION_TYPE_MAX+i))
					call BlzFrameSetPoint(f,FRAMEPOINT_TOP,bf,FRAMEPOINT_BOTTOM,0.,0.)
					call BlzFrameSetSize(f,Math.px2Size(48),Math.px2Size(48))
					call BlzTriggerRegisterFrameEvent(.keypress,f,FRAMEEVENT_CONTROL_CLICK)
					call BlzTriggerRegisterFrameEvent(.keypress,f,FRAMEEVENT_MOUSE_LEAVE)
					set bf = f
					set f = BlzGetFrameByName("MakePotionCreateButtonText",this*POTION_TYPE_MAX+i)
					call BlzFrameSetPoint(f,FRAMEPOINT_CENTER,.container,FRAMEPOINT_CENTER,0.,0.)
					call BlzFrameSetTextAlignment(f,TEXT_JUSTIFY_CENTER,TEXT_JUSTIFY_CENTER)
					call BlzFrameSetText(f,"|cff00cc000|r")
					set bf = f
					/*뒷텍스트*/
					set f = setFrame(INDEX_COUNT_TEXT+i,BlzCreateFrame("MyText",.container,0,this*POTION_TYPE_MAX+i))
					call BlzFrameSetPoint(f,FRAMEPOINT_BOTTOM,getFrame(INDEX_BTN_SET+i),FRAMEPOINT_TOP,0.,0.)
					call BlzFrameSetTextAlignment(f,TEXT_JUSTIFY_BOTTOM,TEXT_JUSTIFY_CENTER)
					call BlzFrameSetText(f,"|cffff0000▼|r")
					call BlzFrameSetVisible(f,false)
					/*툴팁 컨테이너*/
					set f = setFrame(INDEX_TOOLTIP_CONTAINER+i,BlzCreateFrameByType("FRAME","",getFrame(INDEX_BTN_SET+i),"",0))
					call BlzFrameSetAbsPoint(f,FRAMEPOINT_TOPLEFT,0.,0.)
					call BlzFrameSetTooltip(getFrame(INDEX_BTN_SET+i),f)
					set bf = f
					/*툴팁 백드롭*/
					set f = setFrame(INDEX_TOOLTIP_BACKDROP+i,BlzCreateFrameByType("BACKDROP","",bf,"",0))
					call BlzFrameSetTexture(f,"Textures\\black32.blp",0,true)
					call BlzFrameSetAlpha(f,128)
					set bf = f
					/*툴팁 텍스트*/
					set f = setFrame(INDEX_TOOLTIP_TEXT+i,BlzCreateFrame("MyText",getFrame(INDEX_TOOLTIP_CONTAINER+i),0,0))
					call BlzFrameSetPoint(f,FRAMEPOINT_BOTTOM,.container,FRAMEPOINT_TOP,0.,0.005)
					call BlzFrameSetTextAlignment(f,TEXT_JUSTIFY_BOTTOM,TEXT_JUSTIFY_CENTER)
					call BlzFrameSetPoint(bf,FRAMEPOINT_TOPRIGHT,f,FRAMEPOINT_TOPRIGHT,0.005,0.005)
					call BlzFrameSetPoint(bf,FRAMEPOINT_BOTTOMLEFT,f,FRAMEPOINT_BOTTOMLEFT,-0.005,-0.005)
					/**/
					set i = i + 1
				endloop
				/*버튼 리프레시*/
				call refreshButton()
				/**/
				set f = null
				set bf = null
			endmethod
	
			method deactivate takes nothing returns nothing
				local integer i = 0
				loop
					exitwhen i >= POTION_TYPE_MAX
					call setFrame(INDEX_BTN_CREATE+i,null)
					call setFrame(INDEX_BTN_SET+i,null)
					call setFrame(INDEX_TOOLTIP_BACKDROP+i,null)
					call setFrame(INDEX_TOOLTIP_TEXT+i,null)
					call RemoveSavedInteger(HASH,this,INDEX_POTION_COUNT+i)
					set i = i + 1
				endloop
				//! runtextmacro destroyFrame(".container")
				call TriggerRemoveCondition(.keypress,.keypress_cond)
				call Trigger.remove(.keypress)
				set .keypress = null
				set .keypress_cond = null
			endmethod

			private static method potionAddRequest takes nothing returns nothing
				local thistype this = POTION_ADD_ABILITY
				call SaveInteger(HASH,this,INDEX_POTION_COUNT+POTION_ADD_INDEX,LoadInteger(HASH,this,INDEX_POTION_COUNT+POTION_ADD_INDEX)+1)
				call refreshButton()
				set POTION_ADD_ABILITY = 0
				set POTION_ADD_INDEX = 0
			endmethod

			static method onInit takes nothing returns nothing
				call Ability.addTypeTag(ID,ABILITY_STRING_TARGET_LOCATION)
				call Ability.addTypeTag(ID,ABILITY_TAG_PRODUCT)
				call Ability.addTypeTag(ID,ABILITY_TAG_DRUG)
				/**/
				call Ability.addTypeTag(ID2,ABILITY_STRING_TARGET_LOCATION)
				call Ability.addTypeTag(ID2,ABILITY_TAG_FIRE)
				call Ability.addTypeTag(ID2,ABILITY_TAG_DRUG)
				/**/
				call Ability.addTypeTag(ID3,ABILITY_STRING_TARGET_LOCATION)
				call Ability.addTypeTag(ID3,ABILITY_TAG_POISON)
				call Ability.addTypeTag(ID3,ABILITY_TAG_DRUG)
				/**/
				call Ability.setTypeTooltip(ID,"여러 가지 물약 제조\n및 투척")
				/*INIT EXTRA*/
				set INDEX_BTN_CREATE = 0 * POTION_TYPE_MAX
				set INDEX_BTN_SET	= 1 * POTION_TYPE_MAX	
				set INDEX_POTION_COUNT = 2 * POTION_TYPE_MAX	
				set INDEX_COUNT_TEXT = 3 * POTION_TYPE_MAX	
				set INDEX_TOOLTIP_BACKDROP = 4 * POTION_TYPE_MAX	
				set INDEX_TOOLTIP_TEXT = 5 * POTION_TYPE_MAX	
				set INDEX_TOOLTIP_CONTAINER = 6 * POTION_TYPE_MAX	
				set POTION_ICON_PATH[0] = "ReplaceableTextures\\CommandButtons\\BTNPotionGreen.blp"
				set POTION_ICON_PATH[1] = "ReplaceableTextures\\CommandButtons\\BTNPotionBlueBig.blp"
				set POTION_ICON_PATH[2] = "ReplaceableTextures\\CommandButtons\\BTNLiquidFire.blp"
				set POTION_ICON_PATH[3] = "ReplaceableTextures\\CommandButtons\\BTNAcidBomb.blp"
				set POTION_NAME[0] = "치유 물약"
				set POTION_NAME[1] = "마나 물약"
				set POTION_NAME[2] = "폭발 물약"
				set POTION_NAME[3] = "산성 물약"
				call TriggerAddCondition(POTION_ADD_TRIGGER,function thistype.potionAddRequest)
			endmethod
	
		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope