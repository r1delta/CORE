"resource/ui/menus/panels/matchmaking_status.res"
{
	Screen
	{
		ControlName		ImagePanel
		wide			%100
		tall			%100
		visible			1
		scaleImage		1
		fillColor		"0 0 0 0"
		drawColor		"0 0 0 0"
	}

	SearchText
	{
		ControlName				Label
		classname				SearchTextClass
		pin_to_sibling			Screen
		pin_corner_to_sibling	3
		pin_to_sibling_corner	1
		xpos					-55
		ypos					-44
		auto_wide_tocontents 	1
		auto_tall_tocontents	1
		visible					0
		font					MenuTitleSmallFont
		allcaps					1
		fgcolor_override		"255 133 133 255"
		labelText				""
	}

	SearchIcon
	{
		ControlName				ImagePanel
		classname 				SearchIconClass
		pin_to_sibling			Screen
		pin_corner_to_sibling	1
		pin_to_sibling_corner	1
		xpos					-49
		ypos					-38
		wide					30
		tall					30
		visible					0
		scaleImage				1
		image					"../ui/icon_processing"
	}

	MatchStartCountdown
	{
		ControlName				Label
		classname				MatchStartCountdownClass
		pin_to_sibling			Screen
		pin_corner_to_sibling	3
		pin_to_sibling_corner	1
		xpos					-54
		ypos					-68
		auto_wide_tocontents 	1
		auto_tall_tocontents	1
		visible					1
		font					MenuTitleFont
		allcaps					1
		fgcolor_override		"255 133 133 255"
		labelText				""
	}

	MMDevString
	{
		ControlName				Label
		classname				MMDevStringClass
		xpos					60
		ypos					30
		auto_wide_tocontents 	1
		auto_tall_tocontents	1
		visible					1
		font					MenuTitleSmallFont
		allcaps					0
		fgcolor_override		"255 133 133 255"
		labelText				""
	}

}