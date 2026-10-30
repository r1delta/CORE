"Resource/UI/menus/map_stars_details_row.res"
{
	Highlight
	{
		ControlName				ImagePanel
		xpos 					0
		ypos 					0
		zpos 					101
		wide					493
		tall					20
		visible					0
		scaleImage				1
		image					"../ui/menu/lobby/map_stars_details_highlight"
	}

	Star0
	{
		ControlName				ImagePanel
		xpos 					40
		ypos					2
		zpos 					102
		wide					16
		tall					16
		visible					1
		scaleImage				1
		image					"../ui/menu/lobby/map_star_empty"
	}

	Star1
	{
		ControlName				ImagePanel
		xpos 					0
		ypos					0
		zpos 					102
		wide					16
		tall					16
		visible					1
		scaleImage				1
		image					"../ui/menu/lobby/map_star_empty"
		pin_to_sibling			Star0
		pin_corner_to_sibling	7
		pin_to_sibling_corner	5
	}

	Star2
	{
		ControlName				ImagePanel
		xpos 					0
		ypos					0
		zpos 					102
		wide					16
		tall					16
		visible					1
		scaleImage				1
		image					"../ui/menu/lobby/map_star_empty"
		pin_to_sibling			Star1
		pin_corner_to_sibling	7
		pin_to_sibling_corner	5
	}

	ModeName
	{
		ControlName				Label
		xpos 					115
		ypos					0
		zpos 					102
		tall 					20
		wide 					165
		visible					1
		labelText				"[GAME MODE NAME]"
		textinsetx 				4
		font					MapStarsGamemodesFont
		allcaps					1
		fgcolor_override		"255 133 133 255"
	}

	ScoreTypeIcon
	{
		ControlName				ImagePanel
		xpos 					0
		ypos 					0
		zpos					102
		wide 					20
		tall					20
		visible					1
		scaleImage				1
		image 					"../ui/menu/scoreboard/sb_icon_pilot_kills"
		pin_to_sibling			ModeName
		pin_corner_to_sibling	7
		pin_to_sibling_corner	5
	}

	ModeRequirements
	{
		ControlName				Label
		xpos 					0
		ypos					0
		zpos 					102
		tall 					20
		wide 					110
		visible					1
		labelText				"#MAP_STARS_REQ_VALUES"
		textinsetx 				4
		font					MapStarsGamemodesFont
		allcaps					1
		fgcolor_override		"255 133 133 255"
		pin_to_sibling			ScoreTypeIcon
		pin_corner_to_sibling	7
		pin_to_sibling_corner	5
	}

	Best
	{
		ControlName				Label
		xpos 					0
		ypos					0
		zpos 					102
		tall 					20
		wide 					50
		visible					1
		labelText				"?"
		textinsetx 				4
		font					MapStarsGamemodesFont
		allcaps					1
		fgcolor_override		"255 133 133 255"
		pin_to_sibling			ModeRequirements
		pin_corner_to_sibling	7
		pin_to_sibling_corner	5
	}
}