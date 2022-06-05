library Chingho

	struct Chingho extends Ability
		

	endstruct

endlibrary

/*C000 칭호_새내기*/
scope AbilityC000 initializer init
	//! runtextmacro abilityDataHeader("C000","새내기","BTNMurgalSlave","0","STAT_TYPE_ATTACK","STAT_TYPE_ATTACK","false")
		
		public struct main extends Chingho

			method init takes nothing returns nothing
				/*call .owner.multiplyStatValue(STAT_TYPE_MAXHP,0.05)
				call .owner.multiplyStatValue(STAT_TYPE_HPREGEN,0.05)
				call .owner.multiplyStatValue(STAT_TYPE_MAXMP,0.05)
				call .owner.multiplyStatValue(STAT_TYPE_MPREGEN,0.05)
				call .owner.multiplyStatValue(STAT_TYPE_ATTACK,0.05)
				call .owner.multiplyStatValue(STAT_TYPE_DEFFENCE,0.05)
				call .owner.multiplyStatValue(STAT_TYPE_MAGICPOWER,0.05)
				call .owner.multiplyStatValue(STAT_TYPE_RESISTANCE,0.05)
				call .owner.multiplyStatValue(STAT_TYPE_ACCURACY,0.05)
				call .owner.multiplyStatValue(STAT_TYPE_EVASION,0.05)*/
			endmethod

			method onDestroy takes nothing returns nothing
				/*call .owner.multiplyStatValue(STAT_TYPE_MAXHP,-0.05)
				call .owner.multiplyStatValue(STAT_TYPE_HPREGEN,-0.05)
				call .owner.multiplyStatValue(STAT_TYPE_MAXMP,-0.05)
				call .owner.multiplyStatValue(STAT_TYPE_MPREGEN,-0.05)
				call .owner.multiplyStatValue(STAT_TYPE_ATTACK,-0.05)
				call .owner.multiplyStatValue(STAT_TYPE_DEFFENCE,-0.05)
				call .owner.multiplyStatValue(STAT_TYPE_MAGICPOWER,-0.05)
				call .owner.multiplyStatValue(STAT_TYPE_RESISTANCE,-0.05)
				call .owner.multiplyStatValue(STAT_TYPE_ACCURACY,-0.05)
				call .owner.multiplyStatValue(STAT_TYPE_EVASION,-0.05)*/
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.setTypeTooltip(ID,"아직은 풋풋한 느낌")
			endmethod

		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

/*C001 칭호_동인천 역가드*/
scope AbilityC001 initializer init
	//! runtextmacro abilityDataHeader("C001","동인천 역가드","BTNSacrifice","0","STAT_TYPE_ATTACK","STAT_TYPE_ATTACK","false")
		
		public struct main extends Chingho

			method init takes nothing returns nothing

			endmethod

			method onDestroy takes nothing returns nothing
				
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.setTypeTooltip(ID,"나의 역가드를 알까?")
			endmethod

		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

/*C002 칭호_가짜광기*/
scope AbilityC002 initializer init
	//! runtextmacro abilityDataHeader("C002","가짜광기","BTNBerserkForTrolls","0","STAT_TYPE_ATTACK","STAT_TYPE_ATTACK","false")
		
		public struct main extends Chingho

			method init takes nothing returns nothing

			endmethod

			method onDestroy takes nothing returns nothing
				
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.setTypeTooltip(ID,"어중간하게 미쳐있는 사람")
			endmethod

		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

/*C003 칭호_꿈나무*/
scope AbilityC003 initializer init
	//! runtextmacro abilityDataHeader("C003","꿈나무","BTNAcorn","0","STAT_TYPE_ATTACK","STAT_TYPE_ATTACK","false")
		
		public struct main extends Chingho

			method init takes nothing returns nothing

			endmethod

			method onDestroy takes nothing returns nothing
				
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.setTypeTooltip(ID,"무럭무럭 자라나는 DreamTree")
			endmethod

		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

/*C004 칭호_아이돌*/
scope AbilityC004 initializer init
	//! runtextmacro abilityDataHeader("C004","아이돌","BTNSorceress","0","STAT_TYPE_ATTACK","STAT_TYPE_ATTACK","false")
		
		public struct main extends Chingho

			method init takes nothing returns nothing

			endmethod

			method onDestroy takes nothing returns nothing
				
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.setTypeTooltip(ID,"어떠한 역경도 이겨낼 준비가 되어있는 자")
			endmethod

		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

/*C005 칭호_정의의 사도*/
scope AbilityC005 initializer init
	//! runtextmacro abilityDataHeader("C005","정의의 사도","BTNRacoon","0","STAT_TYPE_ATTACK","STAT_TYPE_ATTACK","false")
		
		public struct main extends Chingho

			method init takes nothing returns nothing

			endmethod

			method onDestroy takes nothing returns nothing
				
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.setTypeTooltip(ID,"불순한 것들은 전부 내가 처리할테니 안심하라구")
			endmethod

		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

/*C006 칭호_치유계*/
scope AbilityC006 initializer init
	//! runtextmacro abilityDataHeader("C006","치유계","BTNFountainOfLife","0","STAT_TYPE_ATTACK","STAT_TYPE_ATTACK","false")
		
		public struct main extends Chingho

			method init takes nothing returns nothing

			endmethod

			method onDestroy takes nothing returns nothing
				
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.setTypeTooltip(ID,"모두가 어리광부리고싶어하는 스타일")
			endmethod

		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

/*C007 칭호_패셔니스타*/
scope AbilityC007 initializer init
	//! runtextmacro abilityDataHeader("C007","패셔니스타","BTNRobeOfTheMagi","0","STAT_TYPE_ATTACK","STAT_TYPE_ATTACK","false")
		
		public struct main extends Chingho

			method init takes nothing returns nothing

			endmethod

			method onDestroy takes nothing returns nothing
				
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.setTypeTooltip(ID,"최신 유행을 선도하는 자들")
			endmethod

		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope

/*C008 칭호_밤의 일족*/
scope AbilityC008 initializer init
	//! runtextmacro abilityDataHeader("C008","밤의 일족","BTNElunesBlessing","0","STAT_TYPE_ATTACK","STAT_TYPE_ATTACK","false")
		
		public struct main extends Chingho

			method init takes nothing returns nothing

			endmethod

			method onDestroy takes nothing returns nothing
				
			endmethod
	
			static method onInit takes nothing returns nothing
				call Ability.setTypeTooltip(ID,"태양보다 뜨거운 밤의 열기를 만끽하라")
			endmethod

		endstruct
	
	//! runtextmacro abilityDataEnd()
endscope