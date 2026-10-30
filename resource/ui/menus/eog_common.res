"Resource/UI/menus/eog_common.res"
{
	MenuTitle
	{
		ControlName				Label
		InheritProperties		MenuTitle
		labelText				"#GAME_SUMMARY"
	}

	MenuCommon
	{
		ControlName				CNestedPanel
		xpos					0
		ypos					0
		wide					f0
		tall					f0
		visible					1
		controlSettingsFile		"resource/ui/menus/panels/menu_common.res"
	}

	MatchmakingStatus
	{
		ControlName				CNestedPanel
		xpos					0
		ypos					0
		wide					f0
		tall					f0
		visible					1
		controlSettingsFile		"resource/ui/menus/panels/matchmaking_status.res"
	}

	ImgTopBar
	{
		ControlName				ImagePanel
		InheritProperties		MenuTopBar
	}

	ImgBottomBar
	{
		ControlName				ImagePanel
		InheritProperties		MenuBottomBar
	}

	ImgTitanfallLogoSmall
	{
		ControlName				ImagePanel
		InheritProperties		TitanfallLogoSmall
	}

	Frame
	{
		ControlName		ImagePanel
		xpos 			c-345
		ypos					c-167
		wide 					690
		tall 					354
		image 					"../ui/menu/eog/eog_frame"
		visible			1
		scaleImage		1
		drawColor		"255 255 255 255"
	}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	BtnEOGPage0
	{
		ControlName				BaseModHybridButton
		InheritProperties		EOGPageButton
		classname 				BtnEOGPage0
		xpos 					c-0
		ypos					c-162
		scriptID				0
		labelText				""
		visible					1
	}

	BtnEOGPage1
	{
		ControlName				BaseModHybridButton
		InheritProperties		EOGPageButton
		classname 				BtnEOGPage1
		scriptID				1
		labelText				""
		visible					1

		pin_to_sibling			BtnEOGPage0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}

	BtnEOGPage2
	{
		ControlName				BaseModHybridButton
		InheritProperties		EOGPageButton
		classname 				BtnEOGPage2
		scriptID				2
		labelText				""
		visible					1

		pin_to_sibling			BtnEOGPage1
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}

	BtnEOGPage3
	{
		ControlName				BaseModHybridButton
		InheritProperties		EOGPageButton
		classname 				BtnEOGPage3
		scriptID				3
		labelText				""
		visible					0

		pin_to_sibling			BtnEOGPage2
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}

	BtnEOGPage4
	{
		ControlName				BaseModHybridButton
		InheritProperties		EOGPageButton
		classname 				BtnEOGPage4
		scriptID				4
		labelText				""
		visible					0

		pin_to_sibling			BtnEOGPage3
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}

	BtnEOGPage5
	{
		ControlName				BaseModHybridButton
		InheritProperties		EOGPageButton
		classname 				BtnEOGPage5
		scriptID				5
		labelText				""
		visible					0

		pin_to_sibling			BtnEOGPage4
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}

	BtnEOGPage6
	{
		ControlName				BaseModHybridButton
		InheritProperties		EOGPageButton
		classname 				BtnEOGPage6
		scriptID				6
		labelText				""
		visible					0

		pin_to_sibling			BtnEOGPage5
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	EOGPageTitle
	{
		ControlName				Label
		xpos					c-250
		ypos					c-138
		zpos					500
		wide 					500
		tall					30
		textAlignment			center
		labelText				"EOG PAGE TITLE"
		font					EOGSummaryPageTitleFont
		allcaps					1
		visible					1
		fgcolor_override		"255 133 133 255"
	}

	BtnPrevPage
	{
		ControlName					BaseModHybridButton
		InheritProperties			MenuArrowButtonLeft
		xpos						0
		ypos						2
		zpos						500
		activeInputExclusivePaint	keyboard
		visible						0

		pin_to_sibling				BtnEOGPage0
		pin_corner_to_sibling		3
		pin_to_sibling_corner		2
	}

	EOGPrevPageGamepadHint
	{
		ControlName					Label
		xpos						0
		ypos						0
		zpos						500
		wide 						200
		tall						24
		textAlignment				east
		labelText					"#EOG_BUTTON_PREV_GAMEPAD_HINT"
		font						EOGSummaryPrevNextFont
		allcaps						1
		visible						0
		fgcolor_override			"255 133 133 128"
		activeInputExclusivePaint	gamepad

		pin_to_sibling				BtnEOGPage0
		pin_corner_to_sibling		5
		pin_to_sibling_corner		7
	}

	EOGPrevPageTitle
	{
		ControlName					Label
		xpos						30
		ypos						0
		zpos						500
		wide 						200
		tall						24
		textAlignment				east
		labelText					""
		font						EOGSummaryPrevNextFont
		allcaps						1
		visible						0
		fgcolor_override			"255 133 133 128"

		pin_to_sibling				BtnEOGPage0
		pin_corner_to_sibling		5
		pin_to_sibling_corner		7
	}

	BtnNextPage
	{
		ControlName					BaseModHybridButton
		InheritProperties			MenuArrowButtonRight
		xpos						0
		ypos						2
		zpos						500
		activeInputExclusivePaint	keyboard
		visible						0

		pin_to_sibling				BtnEOGPage6
		pin_corner_to_sibling		2
		pin_to_sibling_corner		3
	}

	EOGNextPageGamepadHint
	{
		ControlName					Label
		xpos						0
		ypos						0
		zpos						500
		wide 						200
		tall						24
		textAlignment				west
		labelText					"#EOG_BUTTON_NEXT_GAMEPAD_HINT"
		font						EOGSummaryPrevNextFont
		allcaps						1
		visible						0
		fgcolor_override			"255 133 133 128"
		activeInputExclusivePaint	gamepad

		pin_to_sibling				BtnEOGPage6
		pin_corner_to_sibling		7
		pin_to_sibling_corner		5
	}

	EOGNextPageTitle
	{
		ControlName					Label
		xpos						30
		ypos						0
		zpos						500
		wide 						200
		tall						24
		textAlignment				west
		labelText					""
		font						EOGSummaryPrevNextFont
		allcaps						1
		visible						0
		fgcolor_override			"255 133 133 128"

		pin_to_sibling				BtnEOGPage6
		pin_corner_to_sibling		7
		pin_to_sibling_corner		5
	}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	FooterButtons
	{
		ControlName				CNestedPanel
		xpos					0
		ypos					r53
		wide					f0
		tall					16
		visible					1
		controlSettingsFile		"resource/ui/menus/panels/footer_buttons.res"
	}
}