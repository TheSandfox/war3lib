//TIER1==============================================================================

//! runtextmacro materialHeader("m000", "철", "BTNMaterial_Primary0","1")
//! runtextmacro materialHeader("m001", "돌", "BTNMaterial_Secondary0","1")
//! runtextmacro materialHeader("m010", "비늘", "BTNMaterial_Primary1","1")
//! runtextmacro materialHeader("m011", "생선살", "BTNMaterial_Secondary1","1")
//! runtextmacro materialHeader("m020", "가죽", "BTNMaterial_Primary2","1")
//! runtextmacro materialHeader("m021", "짐승고기", "BTNMaterial_Secondary2","1")
//! runtextmacro materialHeader("m030", "깃털", "BTNMaterial_Primary3","1")
//! runtextmacro materialHeader("m031", "새고기", "BTNMaterial_Secondary3","1")
//! runtextmacro materialHeader("m040", "목재", "BTNMaterial_Primary4","1")
//! runtextmacro materialHeader("m041", "나무열매", "BTNMaterial_Secondary4","1")

//TIER2==============================================================================

//! runtextmacro materialHeader("m100", "대지의 원소", "BTNMaterial_Elemental0","2")
//! runtextmacro materialHeader("m110", "물의 원소", "BTNMaterial_Elemental1","2")
//! runtextmacro materialHeader("m120", "불의 원소", "BTNMaterial_Elemental2","2")
//! runtextmacro materialHeader("m130", "바람의 원소", "BTNMaterial_Elemental3","2")
//! runtextmacro materialHeader("m140", "자연의 원소", "BTNMaterial_Elemental4","2")
//! runtextmacro materialHeader("m101", "황색 마법가루", "BTNMaterial_Dust0","2")
//! runtextmacro materialHeader("m111", "청색 마법가루", "BTNMaterial_Dust1","2")
//! runtextmacro materialHeader("m121", "적색 마법가루", "BTNMaterial_Dust2","2")
//! runtextmacro materialHeader("m131", "청록색 마법가루", "BTNMaterial_Dust3","2")
//! runtextmacro materialHeader("m141", "녹색 마법가루", "BTNMaterial_Dust4","2")

scope MixResult1 initializer init
private function init takes nothing returns nothing
	//! textmacro mixResult1 takes r1, r2, result
	call Material.setMixResult('$r1$','$r1$','$result$')
	call Material.setMixResult('$r1$','$r2$','$result$')
	call Material.setMixResult('$r2$','$r2$','$result$')
	call Material.setMixResultCount('$result$',2)
	//! endtextmacro
	
	//! runtextmacro mixResult1("m000","m001","m101")
	//! runtextmacro mixResult1("m010","m011","m111")
	//! runtextmacro mixResult1("m020","m021","m121")
	//! runtextmacro mixResult1("m030","m031","m131")
	//! runtextmacro mixResult1("m040","m041","m141")
endfunction
endscope

//TIER3==============================================================================

//! runtextmacro materialHeader("m200", "토파즈", "BTNMaterial_0_0","3")
//! runtextmacro materialHeader("m201", "사파이어", "BTNMaterial_0_1","3")
//! runtextmacro materialHeader("m202", "루비", "BTNMaterial_0_2","3")
//! runtextmacro materialHeader("m203", "터키석", "BTNMaterial_0_3","3")
//! runtextmacro materialHeader("m204", "에메랄드", "BTNMaterial_0_4","3")
//! runtextmacro materialHeader("m210", "황색 잉크", "BTNMaterial_1_0","3")
//! runtextmacro materialHeader("m211", "청색 잉크", "BTNMaterial_1_1","3")
//! runtextmacro materialHeader("m212", "적색 잉크", "BTNMaterial_1_2","3")
//! runtextmacro materialHeader("m213", "청록색 잉크", "BTNMaterial_1_3","3")
//! runtextmacro materialHeader("m214", "녹색 잉크", "BTNMaterial_1_4","3")
//! runtextmacro materialHeader("m220", "황색 마력결정", "BTNMaterial_2_0","3")
//! runtextmacro materialHeader("m221", "청색 마력결정", "BTNMaterial_2_1","3")
//! runtextmacro materialHeader("m222", "적색 마력결정", "BTNMaterial_2_2","3")
//! runtextmacro materialHeader("m223", "청록색 마력결정", "BTNMaterial_2_3","3")
//! runtextmacro materialHeader("m224", "녹색 마력결정", "BTNMaterial_2_4","3")
//! runtextmacro materialHeader("m230", "대지의 룬", "BTNMaterial_3_0","3")
//! runtextmacro materialHeader("m231", "물의 룬", "BTNMaterial_3_1","3")
//! runtextmacro materialHeader("m232", "불의 룬", "BTNMaterial_3_2","3")
//! runtextmacro materialHeader("m233", "바람의 룬", "BTNMaterial_3_3","3")
//! runtextmacro materialHeader("m234", "자연의 룬", "BTNMaterial_3_4","3")
//! runtextmacro materialHeader("m240", "황색 두루마리", "BTNMaterial_4_0","3")
//! runtextmacro materialHeader("m241", "청색 두루마리", "BTNMaterial_4_1","3")
//! runtextmacro materialHeader("m242", "적색 두루마리", "BTNMaterial_4_2","3")
//! runtextmacro materialHeader("m243", "청록색 두루마리", "BTNMaterial_4_3","3")
//! runtextmacro materialHeader("m244", "녹색 두루마리", "BTNMaterial_4_4","3")

scope MixResult2 initializer init
private function init takes nothing returns nothing
	//! textmacro elementalMix takes base
		call Material.setMixResult('m1$base$0','m000','m2$base$0')
		call Material.setMixResult('m1$base$0','m001','m2$base$0')

		call Material.setMixResult('m1$base$0','m010','m2$base$1')
		call Material.setMixResult('m1$base$0','m011','m2$base$1')

		call Material.setMixResult('m1$base$0','m020','m2$base$2')
		call Material.setMixResult('m1$base$0','m021','m2$base$2')

		call Material.setMixResult('m1$base$0','m030','m2$base$3')
		call Material.setMixResult('m1$base$0','m031','m2$base$3')

		call Material.setMixResult('m1$base$0','m040','m2$base$4')
		call Material.setMixResult('m1$base$0','m041','m2$base$4')

		call Material.setMixResultCount('m2$base$0',1)
		call Material.setMixResultCount('m2$base$1',1)
		call Material.setMixResultCount('m2$base$2',1)
		call Material.setMixResultCount('m2$base$3',1)
		call Material.setMixResultCount('m2$base$4',1)
	//! endtextmacro
	//! runtextmacro elementalMix("0")
	//! runtextmacro elementalMix("1")
	//! runtextmacro elementalMix("2")
	//! runtextmacro elementalMix("3")
	//! runtextmacro elementalMix("4")
endfunction
endscope