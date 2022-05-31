library Sound requires TimerUtils

	struct Sound3D

		static method createInstant takes string path, real x, real y, real z returns nothing
			local sound ns = CreateSound(path, false, true, true, 12700, 12700, "")
			//call SetSoundChannel(ns,11)
			call SetSoundPosition(ns,x,y,z)
			//call KillSoundWhenDone(ns)
			call StartSound(ns)
			call BJDebugMsg("하으읏")
			set ns = null
		endmethod

		private static method test takes nothing returns nothing
			call createInstant("abilities\\weapons\\ancientprotectormissile\\ancientprotectormissilehit1.flac",0.,0.,0.)
		endmethod

		private static method onInit takes nothing returns nothing
			local trigger t = CreateTrigger()
			call TriggerRegisterPlayerChatEvent(t,Player(0),"d",true)
			call TriggerAddAction(t,function thistype.test)
		endmethod

	endstruct

endlibrary