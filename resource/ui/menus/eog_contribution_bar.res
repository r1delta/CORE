"Resource/UI/menus/eog_contribution_bar.res"
{
	PlayerIcon
	{
		ControlName				ImagePanel
		xpos 					0
		ypos 					0
		zpos					1013
		wide					40
		tall					20
		visible					0
		scaleImage				1
		fillcolor				"0 0 0 255"
	}

	PlayerLevel
	{
		ControlName				Label
		zpos					1013
		wide					20
		tall					20
		visible					0
		font					EOGScoreboardFont
		textAlignment			center
		bgcolor_override 		"0 0 0 255"
		paintbackground 		1

		pin_to_sibling			PlayerIcon
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}

	PlayerName
	{
		ControlName				Label
		zpos					1012
		wide					160
		tall					20
		visible					0
		labelText				"[PLAYER NAME]"
		font					EOGScoreboardFont
		textAlignment			west
		textinsetx				11
		fgcolor_override 		"230 230 230 255"
		bgcolor_override 		"255 255 255 255"
		paintbackground 		1

		pin_to_sibling			PlayerLevel
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}

	BarBG
	{
		ControlName				Label
		wide					255
		tall					20
		labelText				""
		visible					1
		bgcolor_override 		"37 27 27 255"
		paintbackground 		1

		pin_to_sibling			PlayerName
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}

	BarFill
	{
		ControlName				ImagePanel
		wide					255
		tall					20
		visible					0
		scaleImage				1
		image 					white

		pin_to_sibling			BarBG
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
}