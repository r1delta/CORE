Resource/UI/LoadingProgress.res
{
	LoadingProgress
	{
		ControlName				Frame
		xpos					0
		ypos					0
		wide					f0
		tall					f0
		visible					1
		enabled					1
		tabPosition				0
	}

	LoadingMapName
	{
		ControlName				Label
		xpos					64
		ypos					280
		auto_wide_tocontents 	1
		auto_tall_tocontents	1
		labelText				""
		font					LoadScreenMapNameFont
		fgcolor_override 		"207 248 249 255"
		allcaps					1
		visible					0
	}

	LoadingGameMode
	{
		ControlName				Label
		pin_to_sibling			LoadingMapName
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
		ypos 					0
		auto_wide_tocontents 	1
		auto_tall_tocontents	1
		labelText				"<Game Mode>"
		font					LoadScreenGameModeFont
		fgcolor_override 		"175 231 235 255"
		allcaps					1
		visible					0
	}

	LoadingTeamLogo
	{
		ControlName				ImagePanel
		pin_to_sibling			LoadingGameMode
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
		ypos					12
		wide					48
		tall					48
		image					"../ui/temp"
		scaleImage				1
		visible					0
	}

	LoadingMapDesc
	{
		ControlName				Label
		pin_to_sibling			LoadingGameMode
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
		xpos					-54
		ypos					12
		wide					616 [$WIDESCREEN_16_9]
		wide					535 [!$WIDESCREEN_16_9]
		tall 					48
		labelText				""
		textalign				"north-west"
		font					LoadScreenMapDesc
		wrap 					1
		fgcolor_override 		"207 248 249 255"
		visible					0
	}

	ProgressBarAnchor
	{
		ControlName				Label
		xpos					0
		ypos					409
		wide					1
		tall					1
		visible					0
		enabled					1
		tabPosition				0
	}

	LoadingTip
	{
		ControlName				Label
		pin_to_sibling			LoadingTeamLogo
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
		ypos					14
		wide					525 [$WIDESCREEN_16_9]
		wide					441 [!$WIDESCREEN_16_9]
		auto_tall_tocontents	1
		labelText				""
		textalign				"north-west"
		font					LoadScreenTip
		wrap 					1
		fgcolor_override 		"215 121 48 255"
		visible					0
	}

	WorkingAnim
	{
		ControlName				ImagePanel
		xpos					r112
		ypos					r124
		wide					48
		tall					48
		visible					0
		enabled					1
		tabPosition				0
		scaleImage				1
		image					"spinner"
		frame					0
	}

    ProgressLabel
    {
        ControlName             Label
        font					LoadScreenTip
        pin_to_sibling          WorkingAnim
        ypos 12
        xpos 60
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
        textAlignment           "east"
        auto_wide_tocontents    1
        auto_tall_tocontents	1
		labelText				""
        fgcolor_override 		"207 248 249 255"
		visible					1
    }
}