"Resource/UI/menus/map_stars_details_row.res"
{
	Highlight
	{
		ControlName				ImagePanel
		xpos 					0
		ypos 					0
		zpos 					101
		wide					357
		tall					12
		visible					0
		scaleImage				1
		image					"../ui/menu/lobby/map_stars_details_highlight"
	}

	Star0
	{
		ControlName				ImagePanel
		xpos 					10
		ypos					2
		zpos 					102
		wide					12
		tall					12
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
		wide					12
		tall					12
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
		wide					12
		tall					12
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
		xpos 					55
		ypos					0
		zpos 					102
		tall 					14
		wide 					120
		visible					1
		labelText				"[GAME MODE NAME]"
		textinsetx 				4
		font					MapStarsGamemodesSmallFont
		allcaps					1
		fgcolor_override		"255 133 133 255"
	}

	ScoreTypeIcon
	{
		ControlName				ImagePanel
		xpos 					0
		ypos 					0
		zpos					102
		wide 					14
		tall					14
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
		tall 					14
		wide 					111
		visible					1
		labelText				"#MAP_STARS_REQ_VALUES"
		textinsetx 				4
		font					MapStarsGamemodesSmallFont
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
		tall 					14
		wide 					58
		visible					1
		labelText				"?"
		textinsetx 				4
		font					MapStarsGamemodesSmallFont
		allcaps					1
		fgcolor_override		"255 133 133 255"
		pin_to_sibling			ModeRequirements
		pin_corner_to_sibling	7
		pin_to_sibling_corner	5
	}
}