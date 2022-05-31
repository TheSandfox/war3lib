library Trigger

	//! textmacro destroyTriggerAndCondition takes trig, cond
		call TriggerRemoveCondition($trig$,$cond$)
		call Trigger.remove($trig$)
		set $trig$ = null
		set $cond$ = null
	//! endtextmacro

	globals
		private trigger GENERIC = null
	endglobals

	struct Trigger
	
		private static hashtable HASH = InitHashtable()
	
		static method setData takes trigger t, integer data returns nothing
			call SaveInteger(HASH,GetHandleId(t),0,data)
		endmethod
	
		static method getData takes trigger t returns integer
			return LoadInteger(HASH,GetHandleId(t),0)
		endmethod
	
		static method getDataEx takes nothing returns integer
			return getData(GetTriggeringTrigger())
		endmethod
		
		static method new takes integer data returns trigger
			set GENERIC = null
			set GENERIC = CreateTrigger()
			call setData(GENERIC,data)
			return GENERIC
		endmethod
	
		static method removeData takes trigger t returns nothing
			call RemoveSavedInteger(HASH,GetHandleId(t),0)
		endmethod
	
		static method remove takes trigger t returns nothing
			call removeData(t)
			call DestroyTrigger(t)
		endmethod
	
	endstruct
	
endlibrary 
	