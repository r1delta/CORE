"Resource/UI/menus/eog_challenge_box.res"
{
	Background
	{
		ControlName					ImagePanel
		xpos						0
		ypos						6
		zpos						108
		wide						320
		tall						75
		visible						1
		image						"../ui/menu/challenges/challenge_box"
		scaleImage					1
	}

	BackgroundSelected
	{
		ControlName					ImagePanel
		xpos						0
		ypos						6
		zpos						109
		wide						320
		tall						75
		visible						0
		image						"../ui/menu/challenges/challenge_box_hover"
		scaleImage					1
	}

	Icon
	{
		ControlName					ImagePanel
		xpos						4
		ypos						15
		zpos						110
		wide						37
		tall						43
		visible						1
		scaleImage					1
		image 						"../ui/menu/challenge_icons/first_strike"
	}

	Name
	{
		ControlName					Label
		xpos						44
		ypos						14
		zpos						111
		wide						270
		tall						18
		visible						1
		font						EOGChallengeName
		labelText					"[CHALLENGE NAME]"
		allcaps						1
		fgcolor_override			"220 220 220 255"
	}

	Description
	{
		ControlName					Label
		xpos						44
		ypos						28
		zpos						111
		wide						270
		tall						30
		visible						1
		font						EOGChallengeDesc
		labelText					"[CHALLENGE DESC]"
		allcaps						0
		wrap						1
		textAlignment				center
		fgcolor_override			"255 133 133 255"
		//bgcolor_override 			"255 255 0 100"
	}

	BarFillNew
	{
		ControlName					ImagePanel
		xpos 						4
		ypos						59
		zpos 						112
		wide 						312
		tall 						14
		image 						"../ui/menu/eog/xp_bar_fill_lightblue"
		visible						0
		scaleImage					1
		zpos						113
	}

	BarFillPrevious
	{
		ControlName					ImagePanel
		xpos 						4
		ypos						59
		zpos 						113
		wide 						312
		tall 						14
		image 						"../ui/menu/eog/xp_bar"
		visible						1
		scaleImage					1
		zpos						114
	}

	BarFillShadow
	{
		ControlName					ImagePanel
		xpos 						4
		ypos						59
		zpos 						114
		wide 						312
		tall 						15
		image 						"../ui/menu/eog/xp_bar_shadow"
		visible						1
		scaleImage					1
		zpos						115
	}

	Progress
	{
		ControlName					Label
		xpos 						6
		ypos						59
		zpos						116
		wide 						271
		tall 						14
		visible						1
		font						EOGChallengeProgress
		labelText					"[CHALLENGE PROGRESS]"
		allcaps						1
		wrap						0
		textAlignment				west
		fgcolor_override			"220 220 220 255"
		//bgcolor_override 			"255 0 0 100"
	}

	Flash
	{
		ControlName					ImagePanel
		xpos						-3
		ypos						0
		zpos						113
		wide						315
		tall						62
		image 						"../ui/menu/eog/xp_bar_flash"
		visible						0
		enable						1
		scaleImage					1

		pin_to_sibling				Background
		pin_corner_to_sibling		7
		pin_to_sibling_corner		7
	}

	CompleteText
	{
		ControlName					Label
		xpos						-80
		ypos						-7
		zpos						118
		wide						200
		tall						16
		visible						0
		font						EOGChallengeDesc
		labelText					"#EOG_CHALLENGE_TIER_COMPLETE"
		allcaps						1
		textAlignment				west
		fgcolor_override			"255 133 133 255"
		//bgcolor_override 			"255 255 0 100"

		pin_to_sibling				Background
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}
	
	TrackedIcon
	{
		ControlName				ImagePanel
		xpos					278
		ypos					15
		zpos					110
		wide					37
		tall					43
		visible					0
		scaleImage				1
		image 					"../ui/menu/challenges/challengeTrackerIcon_big"
	}
}