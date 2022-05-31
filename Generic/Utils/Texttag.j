library TextTag requires TimerUtils


	struct InstantText

		static real SIZE = 16.
		static integer R = 255
		static integer G = 255
		static integer B = 255

		static method clearFlag takes nothing returns nothing
			set SIZE = 16.
			set R = 255
			set G = 255
			set B = 255
		endmethod

		static method setColor takes integer r, integer g, integer b returns nothing
			set R = r
			set G = g
			set B = b
		endmethod

		static method createForPlayer takes real x, real y, real z, string val, player forplayer returns nothing
			set bj_lastCreatedTextTag = CreateTextTag()
			call SetTextTagText(bj_lastCreatedTextTag,val,TextTagSize2Height(SIZE))
			call SetTextTagPos(bj_lastCreatedTextTag,x-(StringLength(val)*SIZE),y,z)
			call SetTextTagColor(bj_lastCreatedTextTag,R,G,B,255)
			call SetTextTagPermanent(bj_lastCreatedTextTag,false)
			call SetTextTagVelocity(bj_lastCreatedTextTag,0,0.04)
			call SetTextTagFadepoint(bj_lastCreatedTextTag,0)
			call SetTextTagLifespan(bj_lastCreatedTextTag,1.5)
			call SetTextTagVisibility(bj_lastCreatedTextTag,GetLocalPlayer()==forplayer)
			call clearFlag()
		endmethod

		static method createForBothPlayer takes real x, real y, real z, string val, player forplayer, player forplayer2 returns nothing
			set bj_lastCreatedTextTag = CreateTextTag()
			call SetTextTagText(bj_lastCreatedTextTag,val,TextTagSize2Height(SIZE))
			call SetTextTagPos(bj_lastCreatedTextTag,x-(StringLength(val)*SIZE),y,z)
			call SetTextTagColor(bj_lastCreatedTextTag,R,G,B,255)
			call SetTextTagPermanent(bj_lastCreatedTextTag,false)
			call SetTextTagVelocity(bj_lastCreatedTextTag,0,0.04)
			call SetTextTagFadepoint(bj_lastCreatedTextTag,0)
			call SetTextTagLifespan(bj_lastCreatedTextTag,1.5)
			call SetTextTagVisibility(bj_lastCreatedTextTag,GetLocalPlayer()==forplayer or GetLocalPlayer()==forplayer2)
			call clearFlag()
		endmethod

		static method create takes real x, real y, real z, string val returns thistype
			set bj_lastCreatedTextTag = CreateTextTag()
			call SetTextTagText(bj_lastCreatedTextTag,val,TextTagSize2Height(SIZE))
			call SetTextTagPos(bj_lastCreatedTextTag,x-(StringLength(val)*SIZE),y,z)
			call SetTextTagColor(bj_lastCreatedTextTag,R,G,B,255)
			call SetTextTagPermanent(bj_lastCreatedTextTag,false)
			call SetTextTagVelocity(bj_lastCreatedTextTag,0,0.04)
			call SetTextTagFadepoint(bj_lastCreatedTextTag,0)
			call SetTextTagLifespan(bj_lastCreatedTextTag,1.5)
			call SetTextTagVisibility(bj_lastCreatedTextTag,true)
			call clearFlag()
			return 0
		endmethod
	
	endstruct
	
endlibrary