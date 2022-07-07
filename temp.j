library Class initializer init

	struct Class

		boolean exist = true

		static method exists takes thistype c returns boolean
			if c <= 0 then
				return false
			endif
			return c.exist
		endmethod

		method onDestroy takes nothing returns nothing
			set .exist = false
		endmethod

	endstruct

	private function dmsg takes boolean b returns nothing
		if b then
			call BJDebugMsg("있어")
		else
			call BJDebugMsg("없어")
		endif
	endfunction

	private function init takes nothing returns nothing
		local Class c = Class.create()
		/*제대로 생성된 인스턴스*/
		call dmsg(Class.exists(c))
		call c.destroy()
		/*만들었다가 제거한 인스턴스*/
		call dmsg(Class.exists(c))
		/*아직 할당되지 않은 인스턴스*/
		call dmsg(Class.exists(300))
	endfunction

endlibrary
