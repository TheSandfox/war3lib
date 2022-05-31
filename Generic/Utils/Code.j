library Base64 initializer init

	globals
		private constant integer CHARSET_MAX = 16
		private constant integer CHARSET_LENGTH = 64
		private string array CHARSET
	endglobals

	private function init takes nothing returns nothing
		set CHARSET[0] = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+/"
		set CHARSET[1] = "U/tkOV3Kg8Ge1ErHDYPzn4ZbsyxW6RFcISlmjv5L+ioXfA7a2JNw90MCuTpQhqdB"
		set CHARSET[2] = "1/p5Jviq7obXS0COLTfI6FWcYE9gzQe+8DM3kRPunAatwmjUHx2rsBlVZNdhKy4G"
		set CHARSET[3] = "ei6Z/dV4sgThHC5oIvbwKnaQ1709mWDqNO+YRLFkUzlM3St2xuPAJpycEXjfBrG8"
		set CHARSET[4] = "RPab65j7KwY1cQZOu9Xo0DJBMIdTxmAnELzGtShsf/e2pqU8v+VkrgilHy4WCN3F"
		set CHARSET[5] = "K7sXj3OroSTyVx1gBwk8ZQFefnIPA4/iCvUJ5qbatNlm2cEupGHR9WDMLd0z6Y+h"
		set CHARSET[6] = "xuh0CMeFqkNpn+1aXR8IErVYHB5yDfzPjZGw4d3QUcJ6bSWiLtmTs7O9volKA/2g"
		set CHARSET[7] = "5o0tGseFvwNkH2uVRZXISW9JBY7CLyqrmQAdb3EKUTP4Og+Mzni16cp/alfjhx8D"
		set CHARSET[8] = "Ze7iyux0cwlGsjItXJ5BHKmQph2vSORg6a3nPk9LfDbAN8C/o1EVdq4TFz+UMWrY"
		set CHARSET[9] = "+q9kutnzpvUed5cXYNb6Oi7JEVIRTQGC2BWwS0KA/fhHja18xmrlsMy34LgZoFPD"
		set CHARSET[10] = "9gVnOmQf4wusJ1HFoM/eb06cE8iTrCa2jdRBXkpxvKGY573WNUAPzyZq+LthDSIl"
		set CHARSET[11] = "cJau5Awlf3iCsFX7xSgTI+oZDd/qPWM6KE8eUzVmv9HGpyk2b0jhNOnQ1rRtBY4L"
		set CHARSET[12] = "DtFheBcindQj4+ONl/Eakgqz2XsuY50TR7CMKA3Pfvro1G9UbZpHm68yxIJwWVLS"
		set CHARSET[13] = "ADtT5aPYiUMowf6Kj9J0q48hSZdsO/zp1+mQ3ybnICV2LugXlWre7xvkRGEHcFNB"
		set CHARSET[14] = "24nKYGwmXlfzOBgurVRixdQ5vT0opsFj6Letah7ScN+9EHyI1JkZbMPUqAD3CW8/"
		set CHARSET[15] = "sbo8Jr+FWRfLACUv4j7tkig1/eHOTcGPqdYKmEa6npzNw2SVDMBlhu39XxQy0ZI5"
	endfunction

	struct Base64

		private static method powInt takes integer val, integer pow returns integer
			local integer i = 0
			local integer k = 1
			loop
				exitwhen i >= pow
				set k = k * val
				set i = i + 1
			endloop
			return k
		endmethod

		private static method findIndex takes integer charset, string s returns integer
			local integer i = 0
			/*한글자 넣은거 아니면 컷*/
			if StringLength(s) != 1 then
				return -1
			endif
			/*캐릭터셋 값 이상하게 넣었으면 컷*/
			if charset >= CHARSET_MAX or charset < 0 then
				return -1
			endif
			/*찾기*/
			loop
				exitwhen i >= CHARSET_LENGTH
				if SubString(CHARSET[charset],i,i+1) == s then
					return i
				endif
				set i = i + 1
			endloop
			/*캐릭터셋에 없는 문자면 컷*/
			return -1
		endmethod

		static method boolToDec takes string bs returns integer
			local integer i = 0
			local integer size = StringLength(bs)
			local integer newval = 0
			loop
				exitwhen i >= size
				if SubString(bs,i,i+1) == "0" then
				elseif SubString(bs,i,i+1) == "1" then
					set newval = newval + powInt(2,i)
				else
					/*잘못된형식*/
					return -1
				endif
				set i = i + 1
			endloop
			return newval
		endmethod

		static method decToBool takes integer val returns string
			local integer currentval = val
			local string ns = ""
			local integer i = 0
			loop
					set ns = ns + I2S(ModuloInteger(currentval,2))
					set i = i + 1
					set currentval = currentval / 2
					exitwhen currentval < 1 /*(2-1)*/
			endloop
			return ns
		endmethod

		static method decToCode takes integer val returns string
			local string targetcharset = ""
			local string ns = ""
			local integer currentval = val
			local integer charset = GetRandomInt(1,CHARSET_MAX-1)
			/*음수값이면 커트*/
			if val < 0 then
				return ""
			endif
			/*인코딩방식에따른 테이블 로드*/
			set targetcharset = CHARSET[charset]
			/*자릿수 기록*/
			loop
				exitwhen currentval < CHARSET_LENGTH - 1
				set ns = SubString(targetcharset,ModuloInteger(currentval,CHARSET_LENGTH),ModuloInteger(currentval,CHARSET_LENGTH)+1) + ns
				set currentval = currentval/CHARSET_LENGTH
			endloop
			set ns = SubString(targetcharset,currentval,currentval+1) + ns
			/*인코딩 방식 기록*/
			set ns = SubString(CHARSET[0],charset,charset+1) + ns
			return ns
		endmethod

		static method codeToDec takes string targetstring returns integer
			/*인코딩방식 읽기*/
			local integer charset = findIndex(0,SubString(targetstring,0,1))
			local integer newval = 0
			/*자릿수*/
			local integer zarisu = StringLength(targetstring)-1
			local integer i = 0
			local string s = SubString(targetstring,1,StringLength(targetstring))
			/*한글자 이하 넣었으면 컷*/
			/*엉뚱한 문자가 첫글자면 컷*/
			if zarisu < 1 or charset == -1 then
				return -1
			endif
			loop
				exitwhen i >= zarisu
				/*테이블에 없는 문자면 컷*/
				if findIndex(charset,SubString(s,i,i+1)) == -1 then
					return -1
				endif
				set newval = newval + powInt(CHARSET_LENGTH,zarisu-i-1) * findIndex(charset,SubString(s,i,i+1))
				set i = i + 1
			endloop
			return newval
		endmethod

	endstruct

endlibrary