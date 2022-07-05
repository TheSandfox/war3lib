scope Artifacta000 initializer init
//! runtextmacro artifactHeader("a000", "바람술사의 관", "BTNBrilliance", "ITEMSET_ETERNAL_CYCLONE")
	public struct main extends Artifact

		method activate takes nothing returns nothing
			call .owner.plusStatValue(STAT_TYPE_ATTACK,10.)
		endmethod

		method deactivate takes nothing returns nothing
			call .owner.plusStatValue(STAT_TYPE_ATTACK,-10.)
		endmethod

	endstruct
//! runtextmacro artifactEnd()
endscope

scope Artifacta001 initializer init
//! runtextmacro artifactHeader("a001", "돌풍 정령의 팔찌", "BTNBlizzard", "ITEMSET_ETERNAL_CYCLONE")
	public struct main extends Artifact
		
	endstruct
//! runtextmacro artifactEnd()
endscope

scope Artifacta002 initializer init
//! runtextmacro artifactHeader("a002", "영혼 와이번의 깃", "BTNDarkRitual", "ITEMSET_ETERNAL_CYCLONE")
	public struct main extends Artifact
		
	endstruct
//! runtextmacro artifactEnd()
endscope

scope Artifacta003 initializer init
//! runtextmacro artifactHeader("a003", "높이 나는 자의 망토", "BTNGlacier", "ITEMSET_ETERNAL_CYCLONE")
	public struct main extends Artifact
		
	endstruct
//! runtextmacro artifactEnd()
endscope

scope Artifacta010 initializer init
//! runtextmacro artifactHeader("a010", "불 아티팩트1", "BTNFire", "ITEMSET_CLEANSING_FIRE")
	public struct main extends Artifact

	endstruct
//! runtextmacro artifactEnd()
endscope

scope Artifacta011 initializer init
//! runtextmacro artifactHeader("a011", "불 아티팩트2", "BTNWallOfFire", "ITEMSET_CLEANSING_FIRE")
	public struct main extends Artifact
		
	endstruct
//! runtextmacro artifactEnd()
endscope

scope Artifacta012 initializer init
//! runtextmacro artifactHeader("a012", "불 아티팩트3", "BTNFireRocks", "ITEMSET_CLEANSING_FIRE")
	public struct main extends Artifact
		
	endstruct
//! runtextmacro artifactEnd()
endscope

scope Artifacta013 initializer init
//! runtextmacro artifactHeader("a013", "불 아티팩트4", "BTNMagicLariet", "ITEMSET_CLEANSING_FIRE")
	public struct main extends Artifact
		
	endstruct
//! runtextmacro artifactEnd()
endscope