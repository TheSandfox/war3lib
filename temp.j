IncludeFile "UI\FrameDef\UI\EscMenuTemplates.fdf",

Frame "TEXT" "SkillShopButtonTextTemplate" {
	DecorateFileNames,
	FrameFont "EscMenuTextFont", 0.010, "",
	FontJustificationH JUSTIFYCENTER,
	FontJustificationV JUSTIFYMIDDLE,    
	FontJustificationOffset 0.0 0.0,
	FontFlags "FIXEDSIZE",
	FontColor 0.99 0.827 0.0705 1.0,
	FontHighlightColor 1.0 1.0 1.0 1.0,
	FontDisabledColor 0.5 0.5 0.5 1.0,
	FontShadowColor 0.0 0.0 0.0 0.9,	
	FontShadowOffset 0.002 -0.002,	
}

Frame "GLUETEXTBUTTON" "SkillShopBuyButton" {
	ControlStyle "HIGHLIGHTONMOUSEOVER",
	ButtonPushedTextOffset 0.00 0.00,

	ButtonText "SkillShopBuyButtonText",
	Frame "TEXT" "SkillShopBuyButtonText" INHERITS "SkillShopButtonTextTemplate" {

	}

	ControlBackdrop "ButtonBackdropTemplate",
	Frame "BACKDROP" "ButtonBackdropTemplate" INHERITS "EscMenuButtonBackdropTemplate" {
	}

	ControlPushedBackdrop "ButtonPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonPushedBackdropTemplate" INHERITS "EscMenuButtonPushedBackdropTemplate" {
	}

	ControlDisabledBackdrop "ButtonDisabledBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledBackdropTemplate" INHERITS "EscMenuButtonDisabledBackdropTemplate" {
	}

	ControlDisabledPushedBackdrop "ButtonDisabledPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledPushedBackdropTemplate" INHERITS "EscMenuButtonDisabledPushedBackdropTemplate" {
	}

	Frame "BACKDROP" "SkillShopBuyButtonIcon" {
		Height 0.02,
		Width 0.02,
	}

	ControlMouseOverHighlight "ButtonMouseOverHighlightTemplate",
	Frame "HIGHLIGHT" "ButtonMouseOverHighlightTemplate" INHERITS "EscMenuButtonMouseOverHighlightTemplate" {
	}
}

Frame "GLUETEXTBUTTON" "SkillShopRefreshButton" {
	ControlStyle "HIGHLIGHTONMOUSEOVER",
	ButtonPushedTextOffset 0.00 0.00,

	ButtonText "SkillShopRefreshButtonText",
	Frame "TEXT" "SkillShopRefreshButtonText" INHERITS "SkillShopButtonTextTemplate" {

	}

	ControlBackdrop "ButtonBackdropTemplate",
	Frame "BACKDROP" "ButtonBackdropTemplate" INHERITS "EscMenuButtonBackdropTemplate" {
	}

	ControlPushedBackdrop "ButtonPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonPushedBackdropTemplate" INHERITS "EscMenuButtonPushedBackdropTemplate" {
	}

	ControlDisabledBackdrop "ButtonDisabledBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledBackdropTemplate" INHERITS "EscMenuButtonDisabledBackdropTemplate" {
	}

	ControlDisabledPushedBackdrop "ButtonDisabledPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledPushedBackdropTemplate" INHERITS "EscMenuButtonDisabledPushedBackdropTemplate" {
	}

	Frame "BACKDROP" "SkillShopRefreshButtonIcon" {
		Height 0.02,
		Width 0.02,
	}

	ControlMouseOverHighlight "ButtonMouseOverHighlightTemplate",
	Frame "HIGHLIGHT" "ButtonMouseOverHighlightTemplate" INHERITS "EscMenuButtonMouseOverHighlightTemplate" {
	}
}

Frame "GLUETEXTBUTTON" "SkillShopAutoRefreshButton" {
	ControlStyle "HIGHLIGHTONMOUSEOVER",
	ButtonPushedTextOffset 0.00 0.00,

	ButtonText "SkillShopAutoRefreshButtonText",
	Frame "TEXT" "SkillShopAutoRefreshButtonText" INHERITS "SkillShopButtonTextTemplate" {

	}

	ControlBackdrop "ButtonBackdropTemplate",
	Frame "BACKDROP" "ButtonBackdropTemplate" INHERITS "EscMenuButtonBackdropTemplate" {
	}

	ControlPushedBackdrop "ButtonPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonPushedBackdropTemplate" INHERITS "EscMenuButtonPushedBackdropTemplate" {
	}

	ControlDisabledBackdrop "ButtonDisabledBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledBackdropTemplate" INHERITS "EscMenuButtonDisabledBackdropTemplate" {
	}

	ControlDisabledPushedBackdrop "ButtonDisabledPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledPushedBackdropTemplate" INHERITS "EscMenuButtonDisabledPushedBackdropTemplate" {
	}

	ControlMouseOverHighlight "ButtonMouseOverHighlightTemplate",
	Frame "HIGHLIGHT" "ButtonMouseOverHighlightTemplate" INHERITS "EscMenuButtonMouseOverHighlightTemplate" {
	}
}

Frame "GLUETEXTBUTTON" "SkillShopDonateButton" {
	ControlStyle "HIGHLIGHTONMOUSEOVER",
	ButtonPushedTextOffset 0.00 0.00,

	ButtonText "SkillShopDonateButtonText",
	Frame "TEXT" "SkillShopDonateButtonText" INHERITS "SkillShopButtonTextTemplate" {

	}

	ControlBackdrop "ButtonBackdropTemplate",
	Frame "BACKDROP" "ButtonBackdropTemplate" INHERITS "EscMenuButtonBackdropTemplate" {
	}

	ControlPushedBackdrop "ButtonPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonPushedBackdropTemplate" INHERITS "EscMenuButtonPushedBackdropTemplate" {
	}

	ControlDisabledBackdrop "ButtonDisabledBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledBackdropTemplate" INHERITS "EscMenuButtonDisabledBackdropTemplate" {
	}

	ControlDisabledPushedBackdrop "ButtonDisabledPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledPushedBackdropTemplate" INHERITS "EscMenuButtonDisabledPushedBackdropTemplate" {
	}

	Frame "BACKDROP" "SkillShopDonateButtonIcon" {
		Height 0.02,
		Width 0.02,
	}

	ControlMouseOverHighlight "ButtonMouseOverHighlightTemplate",
	Frame "HIGHLIGHT" "ButtonMouseOverHighlightTemplate" INHERITS "EscMenuButtonMouseOverHighlightTemplate" {
	}
}

Frame "GLUETEXTBUTTON" "SlotChangerButton" {
	ControlStyle "HIGHLIGHTONMOUSEOVER",
	ButtonPushedTextOffset 0.00 0.00,

	ButtonText "SlotChangerButtonText",
	Frame "TEXT" "SlotChangerButtonText" INHERITS "SkillShopButtonTextTemplate" {

	}

	ControlBackdrop "ButtonBackdropTemplate",
	Frame "BACKDROP" "ButtonBackdropTemplate" INHERITS "EscMenuButtonBackdropTemplate" {
	}

	ControlPushedBackdrop "ButtonPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonPushedBackdropTemplate" INHERITS "EscMenuButtonPushedBackdropTemplate" {
	}

	ControlDisabledBackdrop "ButtonDisabledBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledBackdropTemplate" INHERITS "EscMenuButtonDisabledBackdropTemplate" {
	}

	ControlDisabledPushedBackdrop "ButtonDisabledPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledPushedBackdropTemplate" INHERITS "EscMenuButtonDisabledPushedBackdropTemplate" {
	}

	ControlMouseOverHighlight "ButtonMouseOverHighlightTemplate",
	Frame "HIGHLIGHT" "ButtonMouseOverHighlightTemplate" INHERITS "EscMenuButtonMouseOverHighlightTemplate" {
	}
}

Frame "GLUETEXTBUTTON" "SlotChangerConfirmButton" {
	ControlStyle "HIGHLIGHTONMOUSEOVER",
	ButtonPushedTextOffset 0.00 0.00,

	ButtonText "SlotChangerConfirmButtonText",
	Frame "TEXT" "SlotChangerConfirmButtonText" INHERITS "SkillShopButtonTextTemplate" {

	}

	ControlBackdrop "ButtonBackdropTemplate",
	Frame "BACKDROP" "ButtonBackdropTemplate" INHERITS "EscMenuButtonBackdropTemplate" {
	}

	ControlPushedBackdrop "ButtonPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonPushedBackdropTemplate" INHERITS "EscMenuButtonPushedBackdropTemplate" {
	}

	ControlDisabledBackdrop "ButtonDisabledBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledBackdropTemplate" INHERITS "EscMenuButtonDisabledBackdropTemplate" {
	}

	ControlDisabledPushedBackdrop "ButtonDisabledPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledPushedBackdropTemplate" INHERITS "EscMenuButtonDisabledPushedBackdropTemplate" {
	}

	ControlMouseOverHighlight "ButtonMouseOverHighlightTemplate",
	Frame "HIGHLIGHT" "ButtonMouseOverHighlightTemplate" INHERITS "EscMenuButtonMouseOverHighlightTemplate" {
	}
}

Frame "GLUETEXTBUTTON" "MakePotionCreateButton" {
	ControlStyle "HIGHLIGHTONMOUSEOVER",
	ButtonPushedTextOffset 0.00 0.00,

	ButtonText "MakePotionCreateButtonText",
	Frame "TEXT" "MakePotionCreateButtonText" INHERITS "SkillShopButtonTextTemplate" {

	}

	ControlBackdrop "ButtonBackdropTemplate",
	Frame "BACKDROP" "ButtonBackdropTemplate" INHERITS "EscMenuButtonBackdropTemplate" {
	}

	ControlPushedBackdrop "ButtonPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonPushedBackdropTemplate" INHERITS "EscMenuButtonPushedBackdropTemplate" {
	}

	ControlDisabledBackdrop "ButtonDisabledBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledBackdropTemplate" INHERITS "EscMenuButtonDisabledBackdropTemplate" {
	}

	ControlDisabledPushedBackdrop "ButtonDisabledPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledPushedBackdropTemplate" INHERITS "EscMenuButtonDisabledPushedBackdropTemplate" {
	}

	Frame "BACKDROP" "MakePotionCreateButtonIcon" {
		Height 0.02,
		Width 0.02,
	}

	ControlMouseOverHighlight "ButtonMouseOverHighlightTemplate",
	Frame "HIGHLIGHT" "ButtonMouseOverHighlightTemplate" INHERITS "EscMenuButtonMouseOverHighlightTemplate" {
	}
}

Frame "GLUETEXTBUTTON" "MakePotionSetButton" {
	ControlStyle "HIGHLIGHTONMOUSEOVER",
	ButtonPushedTextOffset 0.00 0.00,

	ButtonText "MakePotionSetButtonText",
	Frame "TEXT" "MakePotionSetButtonText" INHERITS "SkillShopButtonTextTemplate" {

	}

	ControlBackdrop "ButtonBackdropTemplate",
	Frame "BACKDROP" "ButtonBackdropTemplate" INHERITS "EscMenuButtonBackdropTemplate" {
	}

	ControlPushedBackdrop "ButtonPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonPushedBackdropTemplate" INHERITS "EscMenuButtonPushedBackdropTemplate" {
	}

	ControlDisabledBackdrop "ButtonDisabledBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledBackdropTemplate" INHERITS "EscMenuButtonDisabledBackdropTemplate" {
	}

	ControlDisabledPushedBackdrop "ButtonDisabledPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledPushedBackdropTemplate" INHERITS "EscMenuButtonDisabledPushedBackdropTemplate" {
	}

	Frame "BACKDROP" "MakePotionSetButtonIcon" {
		Height 0.02,
		Width 0.02,
	}

	ControlMouseOverHighlight "ButtonMouseOverHighlightTemplate",
	Frame "HIGHLIGHT" "ButtonMouseOverHighlightTemplate" INHERITS "EscMenuButtonMouseOverHighlightTemplate" {
	}
}

Frame "GLUETEXTBUTTON" "CharacterWidgetButton" {
	ControlStyle "HIGHLIGHTONMOUSEOVER",
	ButtonPushedTextOffset 0.00 0.00,

	ControlBackdrop "ButtonBackdropTemplate",
	Frame "BACKDROP" "ButtonBackdropTemplate" INHERITS "EscMenuButtonBackdropTemplate" {
	}

	ControlPushedBackdrop "ButtonPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonPushedBackdropTemplate" INHERITS "EscMenuButtonPushedBackdropTemplate" {
	}

	ControlDisabledBackdrop "ButtonDisabledBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledBackdropTemplate" INHERITS "EscMenuButtonDisabledBackdropTemplate" {
	}

	ControlDisabledPushedBackdrop "ButtonDisabledPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledPushedBackdropTemplate" INHERITS "EscMenuButtonDisabledPushedBackdropTemplate" {
	}

	Frame "BACKDROP" "CharacterWidgetButtonIcon" {
		Height 0.02,
		Width 0.02,
	}

	ControlMouseOverHighlight "ButtonMouseOverHighlightTemplate",
	Frame "HIGHLIGHT" "ButtonMouseOverHighlightTemplate" INHERITS "EscMenuButtonMouseOverHighlightTemplate" {
	}
}

Frame "GLUETEXTBUTTON" "CharacterSelectConfirmButton" {
	ControlStyle "HIGHLIGHTONMOUSEOVER",
	ButtonPushedTextOffset 0.00 0.00,

	ButtonText "CharacterSelectConfirmButtonText",
	Frame "TEXT" "CharacterSelectConfirmButtonText" INHERITS "SkillShopButtonTextTemplate" {

	}

	ControlBackdrop "ButtonBackdropTemplate",
	Frame "BACKDROP" "ButtonBackdropTemplate" INHERITS "EscMenuButtonBackdropTemplate" {
	}

	ControlPushedBackdrop "ButtonPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonPushedBackdropTemplate" INHERITS "EscMenuButtonPushedBackdropTemplate" {
	}

	ControlDisabledBackdrop "ButtonDisabledBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledBackdropTemplate" INHERITS "EscMenuButtonDisabledBackdropTemplate" {
	}

	ControlDisabledPushedBackdrop "ButtonDisabledPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledPushedBackdropTemplate" INHERITS "EscMenuButtonDisabledPushedBackdropTemplate" {
	}

	ControlMouseOverHighlight "ButtonMouseOverHighlightTemplate",
	Frame "HIGHLIGHT" "ButtonMouseOverHighlightTemplate" INHERITS "EscMenuButtonMouseOverHighlightTemplate" {
	}
}

Frame "GLUETEXTBUTTON" "ChinghoSelectButton" {
	ControlStyle "HIGHLIGHTONMOUSEOVER",
	ButtonPushedTextOffset 0.00 0.00,

	ButtonText "ChinghoSelectButtonText",
	Frame "TEXT" "ChinghoSelectButtonText" INHERITS "SkillShopButtonTextTemplate" {

	}

	ControlBackdrop "ButtonBackdropTemplate",
	Frame "BACKDROP" "ButtonBackdropTemplate" INHERITS "EscMenuButtonBackdropTemplate" {
	}

	ControlPushedBackdrop "ButtonPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonPushedBackdropTemplate" INHERITS "EscMenuButtonPushedBackdropTemplate" {
	}

	ControlDisabledBackdrop "ButtonDisabledBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledBackdropTemplate" INHERITS "EscMenuButtonDisabledBackdropTemplate" {
	}

	ControlDisabledPushedBackdrop "ButtonDisabledPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledPushedBackdropTemplate" INHERITS "EscMenuButtonDisabledPushedBackdropTemplate" {
	}

	ControlMouseOverHighlight "ButtonMouseOverHighlightTemplate",
	Frame "HIGHLIGHT" "ButtonMouseOverHighlightTemplate" INHERITS "EscMenuButtonMouseOverHighlightTemplate" {
	}

	Frame "BACKDROP" "ChinghoSelectButtonIcon1" {
		Height 0.02,
		Width 0.02,
	}

	Frame "BACKDROP" "ChinghoSelectButtonIcon2" {
		Height 0.02,
		Width 0.02,
	}
}

Frame "GLUETEXTBUTTON" "ChinghoSelectPageNextButton" {
	ControlStyle "HIGHLIGHTONMOUSEOVER",
	ButtonPushedTextOffset 0.00 0.00,

	ButtonText "ChinghoSelectPageNextButtonText",
	Frame "TEXT" "ChinghoSelectPageNextButtonText" INHERITS "SkillShopButtonTextTemplate" {

	}

	ControlBackdrop "ButtonBackdropTemplate",
	Frame "BACKDROP" "ButtonBackdropTemplate" INHERITS "EscMenuButtonBackdropTemplate" {
	}

	ControlPushedBackdrop "ButtonPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonPushedBackdropTemplate" INHERITS "EscMenuButtonPushedBackdropTemplate" {
	}

	ControlDisabledBackdrop "ButtonDisabledBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledBackdropTemplate" INHERITS "EscMenuButtonDisabledBackdropTemplate" {
	}

	ControlDisabledPushedBackdrop "ButtonDisabledPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledPushedBackdropTemplate" INHERITS "EscMenuButtonDisabledPushedBackdropTemplate" {
	}

	ControlMouseOverHighlight "ButtonMouseOverHighlightTemplate",
	Frame "HIGHLIGHT" "ButtonMouseOverHighlightTemplate" INHERITS "EscMenuButtonMouseOverHighlightTemplate" {
	}
}

Frame "GLUETEXTBUTTON" "ChinghoSelectPagePrevButton" {
	ControlStyle "HIGHLIGHTONMOUSEOVER",
	ButtonPushedTextOffset 0.00 0.00,

	ButtonText "ChinghoSelectPagePrevButtonText",
	Frame "TEXT" "ChinghoSelectPagePrevButtonText" INHERITS "SkillShopButtonTextTemplate" {

	}

	ControlBackdrop "ButtonBackdropTemplate",
	Frame "BACKDROP" "ButtonBackdropTemplate" INHERITS "EscMenuButtonBackdropTemplate" {
	}

	ControlPushedBackdrop "ButtonPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonPushedBackdropTemplate" INHERITS "EscMenuButtonPushedBackdropTemplate" {
	}

	ControlDisabledBackdrop "ButtonDisabledBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledBackdropTemplate" INHERITS "EscMenuButtonDisabledBackdropTemplate" {
	}

	ControlDisabledPushedBackdrop "ButtonDisabledPushedBackdropTemplate",
	Frame "BACKDROP" "ButtonDisabledPushedBackdropTemplate" INHERITS "EscMenuButtonDisabledPushedBackdropTemplate" {
	}

	ControlMouseOverHighlight "ButtonMouseOverHighlightTemplate",
	Frame "HIGHLIGHT" "ButtonMouseOverHighlightTemplate" INHERITS "EscMenuButtonMouseOverHighlightTemplate" {
	}
}
