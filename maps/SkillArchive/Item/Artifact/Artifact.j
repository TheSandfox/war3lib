//! import "ArtifactData.j"

library Artifact requires Item

	globals
		private constant integer STAT_SIZE = 4

		trigger ARTIFACT_UI_REFRESH = CreateTrigger()
		player ARTIFACT_UI_REFRESH_PLAYER = null
		private hashtable HASH = InitHashtable()
		private integer array LEVEL_REQUIRE

		private integer array ARTIFACT_MAX_EXP
	endglobals

	struct ItemSetAbility

		Unit owner = 0
		integer setnum = -1

		stub method init takes nothing returns nothing

		endmethod

		static method create takes Unit owner, integer setnum returns thistype
			local thistype this = 0
			if HaveSavedInteger(HASH,owner,setnum) then
				set this = LoadInteger(HASH,owner,setnum)
			else
				set this = allocate()
				call SaveInteger(HASH,owner,setnum,this)
			endif
			set .owner = owner
			set .setnum = setnum
			return this
		endmethod

		method onDestroy takes nothing returns nothing
			call RemoveSavedInteger(HASH,.owner,.setnum)
		endmethod

		static method new takes thistype a returns thistype
			call a.init()
			return a
		endmethod

	endstruct

	struct Artifact extends Item

		private static hashtable HASH = InitHashtable()
		private static constant integer INDEX_BACKDROP = 0
		private static constant integer INDEX_TEXT = 4
		private static constant integer INDEX_STAT_TYPE = 8
		private static constant integer INDEX_STAT_BONUS = 12
		private static constant integer INDEX_STAT_VALUE = 16

		integer level = 1
		integer exp = 0
		framehandle exp_text = null

		stub method getDialogText takes nothing returns string
			return "|cffffcc00알림|r\n\n아티팩트 장착 시 |cffff0000해제가 불가능|r합니다.\n장착하시겠습니까?"
		endmethod

		method getBackdrop takes integer index returns framehandle
			return LoadFrameHandle(HASH,this,INDEX_BACKDROP+index)
			//return BACKDROP[this*STAT_SIZE+index]
		endmethod

		method setBackdrop takes integer index, framehandle f returns nothing
			if f == null and HaveSavedHandle(HASH,this,INDEX_BACKDROP+index) then
				call BlzDestroyFrame(LoadFrameHandle(HASH,this,INDEX_BACKDROP+index))
				call RemoveSavedHandle(HASH,this,INDEX_BACKDROP+index)
			endif
			call SaveFrameHandle(HASH,this,INDEX_BACKDROP+index,f)
		endmethod

		method getText takes integer index returns framehandle
			return LoadFrameHandle(HASH,this,INDEX_TEXT+index)
		endmethod

		method setText takes integer index, framehandle f returns nothing
			if f == null and HaveSavedHandle(HASH,this,INDEX_TEXT+index) then
				call BlzDestroyFrame(LoadFrameHandle(HASH,this,INDEX_TEXT+index))
				call RemoveSavedHandle(HASH,this,INDEX_TEXT+index)
			endif
			call SaveFrameHandle(HASH,this,INDEX_TEXT+index,f)
		endmethod

		method getStatType takes integer index returns integer
			return LoadInteger(HASH,this,INDEX_STAT_TYPE+index)
		endmethod

		method setStatType takes integer index, integer newval returns nothing
			call SaveInteger(HASH,this,INDEX_STAT_TYPE+index,newval)
		endmethod

		method getStatBonus takes integer index returns real
			return LoadReal(HASH,this,INDEX_STAT_BONUS+index)
		endmethod

		method setStatBonus takes integer index, real newval returns nothing
			call SaveReal(HASH,this,INDEX_STAT_BONUS+index,newval)
		endmethod

		method getStatValue takes integer index returns real
			return LoadReal(HASH,this,INDEX_STAT_VALUE+index)
		endmethod

		method setStatValue takes integer index, real newval returns nothing
			call SaveReal(HASH,this,INDEX_STAT_VALUE+index,newval)
		endmethod

		method registArtifact takes Unit owner, integer aid, boolean flag returns nothing
			call SaveBoolean(HASH,owner,aid,flag)
		endmethod

		method isArtifactRegisted takes Unit owner, integer aid returns boolean
			if not HaveSavedBoolean(HASH,owner,aid) then
				return false
			else
				return LoadBoolean(HASH,owner,aid)
			endif
		endmethod

		method addExp takes integer v returns nothing
			set .exp = .exp + v
			loop
				exitwhen .exp < ARTIFACT_MAX_EXP[.level] or .level == 4
				set .exp = .exp - ARTIFACT_MAX_EXP[.level]
				set .level = .level + 1
			endloop
			if .level == 4 then
				call BlzFrameSetText(.exp_text,"|cffffcc00Lv.MAX|r")
			else
				call BlzFrameSetText(.exp_text,"|cffffcc00Lv."+I2S(.level)+" ("+I2S(.exp)+" / "+I2S(ARTIFACT_MAX_EXP[.level])+")|r")
			endif
		endmethod

		method refreshStatIcon takes integer index returns nothing
			local integer st = getStatType(index)
			if st < 0 then
				call BlzFrameSetTexture(getBackdrop(index),"Icons\\btnblackicon.blp",0,true)
				call BlzFrameSetText(getText(index),"|cff999999Lv."+I2S(LEVEL_REQUIRE[index])+" 달성 시 개방")
			else
				call BlzFrameSetTexture(getBackdrop(index),STAT_TYPE_ICON[st],0,true)
				call BlzFrameSetText(getText(index),STAT_TYPE_COLOR[st]+STAT_TYPE_NAME[st]+"|r|cffffff00 +"+R2SW(getStatBonus(index),1,1)+"|r")
			endif
		endmethod

		method applyStatValue takes integer i returns nothing
			if .owner <= 0 then
				return
			endif
			if getStatType(i) >= 0 then
				call .owner.plusStatValue(getStatType(i),getStatBonus(i))
				call setStatValue(i,getStatBonus(i))
			endif
		endmethod

		method applyAllStatValue takes nothing returns nothing
			local integer i = 0
			loop
				exitwhen i >= STAT_SIZE
				call applyStatValue(i)
				set i = i + 1
			endloop
		endmethod

		method resetStatValue takes integer i returns nothing
			if .owner <= 0 then
				return
			endif
			if getStatType(i) >= 0 then
				call .owner.plusStatValue(getStatType(i),-getStatValue(i))
				call setStatValue(i,0.)
			endif
		endmethod

		method resetAllStatValue takes nothing returns nothing
			local integer i = 0
			loop
				exitwhen i >= STAT_SIZE
				call resetStatValue(i)
				set i = i + 1
			endloop
		endmethod

		method changeStatValue takes integer index, integer stattype, real statbonus returns nothing
			call resetStatValue(index)
			call setStatType(index,stattype)
			call setStatBonus(index,statbonus*STAT_NORMAL_VALUE[stattype])
			call refreshStatIcon(index)
			call applyStatValue(index)
		endmethod

		method getExtraText takes nothing returns string
			return "+"+I2S(.level)
		endmethod

		method getDropName takes nothing returns string
			return TIER_STRING_COLOR[.tier]+.name +"|r"
		endmethod

		stub method activate takes nothing returns nothing
		
		endmethod

		stub method deactivate takes nothing returns nothing

		endmethod

		method onEquip takes nothing returns nothing
			call applyAllStatValue()
			call registArtifact(.owner,.id,true)
			call Item.setUnitSetNum(.owner,getTypeSetNum(.id),getUnitSetNum(.owner,getTypeSetNum(.id))+1)
			call activate()
		endmethod

		method onUnequip takes nothing returns nothing
			call Item.setUnitSetNum(.owner,getTypeSetNum(.id),getUnitSetNum(.owner,getTypeSetNum(.id))-1)
			call registArtifact(.owner,.id,false)
			call deactivate()
			call resetAllStatValue()
		endmethod

		method onRightClick takes nothing returns boolean
			local Unit u = User.getFocusUnit(INVENTORY_ITEM_USE_PLAYER)
			local integer result = 0
			if u > 0 then
				if u.getItemById(.id) > 0 then
					return false
				else
					set result = equip(u)
					if result == 1 then
						call UI.THIS[GetPlayerId(INVENTORY_ITEM_USE_PLAYER)].refreshArtifactIcons()
						return true
					else
						return false
					endif
				endif
			else
				return false
			endif
		endmethod

		method initialize takes nothing returns nothing
			local integer i = 0
			call Shuffle.shuffleRandomStat()
			set .tooltip_width = 480
			set .tooltip_inset_top = .tooltip_inset_top + 112 + 32
			call initTooltip()
			set .exp_text = BlzCreateFrame("MyText",.tooltip_container,0,0)
			call BlzFrameSetPointPixel(.exp_text,FRAMEPOINT_TOPLEFT,.tooltip_icon,FRAMEPOINT_BOTTOMLEFT,0,-8)
			loop
				exitwhen i >= STAT_SIZE
				call setStatType(i,-1)
				call setStatBonus(i,0.)
				call setStatValue(i,0.)
				call setBackdrop(i,BlzCreateFrameByType("BACKDROP","",.tooltip_container,"",0))
				call BlzFrameSetPointPixel(getBackdrop(i),FRAMEPOINT_TOPLEFT,.tooltip_outline,FRAMEPOINT_TOPLEFT,8,-96-24*i)
				call BlzFrameSetSizePixel(getBackdrop(i),24,24)
				call setText(i,BlzCreateFrame("MyText",.tooltip_container,0,0))
				call BlzFrameSetPointPixel(getText(i),FRAMEPOINT_LEFT,getBackdrop(i),FRAMEPOINT_RIGHT,4,0.)
				call refreshStatIcon(i)
				set i = i + 1
			endloop
			call addExp(0)
			call changeStatValue(0,Shuffle.pick(),10.)
		endmethod

		method relativeTooltip takes nothing returns string
			local integer setnum = getTypeSetNum(.id)
			local string s = "|cffffcc00<"+ITEMSET_NAME[setnum]+">|r\n"
			local integer i = 0
			loop
				exitwhen i >= 4
				if .owner <= 0 then
					set s = s+"|cffffffff"
				elseif not isArtifactRegisted(.owner,Item.getItemsetItem(setnum,i)) then
					set s = s+"|cff999999"
				else
					set s = s+"|cff00ff00"
				endif
				set s = s + Item.getTypeName(Item.getItemsetItem(setnum,i)) +"|r\n"
				set i = i + 1
			endloop
			set s = s + "\n"
			if .owner <= 0 then
				set s = s + "(2):" + Item.getItemsetDesc(setnum,0) + "\n(4):" + Item.getItemsetDesc(setnum,1)
			else
				if Item.getUnitSetNum(.owner,setnum) >= 2 then
					set s = s + "|cff00ff00(2):" + Item.getItemsetDesc(setnum,0) + "\n"
					if Item.getUnitSetNum(.owner,setnum) >= 4 then
						set s = s + "|cff00ff00(4):" + Item.getItemsetDesc(setnum,1) + "|r"
					else
						set s = s + "|cff999999(4):" + Item.getItemsetDesc(setnum,1) + "|r"
					endif
				else
					/*세트효과없음*/
					set s = s + "|cff999999(2):" + Item.getItemsetDesc(setnum,0) + "\n(4):" + Item.getItemsetDesc(setnum,1) + "|r"
				endif
			endif
			return s
		endmethod

		method onDestroy takes nothing returns nothing
			local integer i = 0
			loop
				exitwhen i >= 4
				call setBackdrop(i,null)
				call setText(i,null)
				set i = i + 1
			endloop
			//! runtextmacro destroyFrame(".exp_text")
		endmethod

		static method onInit takes nothing returns nothing
			set LEVEL_REQUIRE[0] = 1
			set LEVEL_REQUIRE[1] = 2
			set LEVEL_REQUIRE[2] = 3
			set LEVEL_REQUIRE[3] = 4
			//
			/*제로베이스아님*/
			set ARTIFACT_MAX_EXP[1] = 10
			set ARTIFACT_MAX_EXP[2] = 20
			set ARTIFACT_MAX_EXP[3] = 30
			set ARTIFACT_MAX_EXP[4] = 40
		endmethod

	endstruct

endlibrary

//! textmacro artifactHeader takes setnum, partnum, name

	globals
		private constant integer ID = 'a$setnum$$partnum$'
		private constant string NAME = "$name$"
		private constant string ICON_PATH = "Icons\\Items\\Artifacts\\Artifact_$setnum$_$partnum$.blp"
		private constant integer SETNUM = $setnum$
		private constant trigger CREATE_TRIGGER = CreateTrigger()
	endglobals

//! endtextmacro

//! textmacro artifactEnd

	private function act takes nothing returns nothing
		local main a = 0
		set a = main.create()
		if a > 0 then
			set a.id = ID
			set a.name = NAME
			set a.icon = ICON_PATH
		endif
		set Item.LAST_CREATED = a
	endfunction

	private function init takes nothing returns nothing
		call Item.genericConfiguration(ID,CREATE_TRIGGER,function act,NAME)
		call Item.artifactConfiguration(ID,SETNUM,ICON_PATH)
	endfunction

//! endtextmacro