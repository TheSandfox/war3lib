scope Artifacta000 initializer init
//! runtextmacro artifactHeader("a000", "바람술사의 관", "BTNFire", "ITEMSET_ETERNAL_CYCLONE")
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
//! runtextmacro artifactHeader("a001", "돌풍 정령의 팔찌", "BTNFootman", "ITEMSET_ETERNAL_CYCLONE")
	public struct main extends Artifact
		
	endstruct
//! runtextmacro artifactEnd()
endscope

scope Artifacta002 initializer init
//! runtextmacro artifactHeader("a002", "영혼 와이번의 깃", "BTNRifleman", "ITEMSET_ETERNAL_CYCLONE")
	public struct main extends Artifact
		
	endstruct
//! runtextmacro artifactEnd()
endscope

scope Artifacta003 initializer init
//! runtextmacro artifactHeader("a003", "높이 나는 자의 망토", "BTNKnight", "ITEMSET_ETERNAL_CYCLONE")
	public struct main extends Artifact
		
	endstruct
//! runtextmacro artifactEnd()
endscope