"Resource/UI/menus/stats_progress_bar.res"
{
	Title
	{
		ControlName					Label
		xpos						0
		ypos						0
		zpos						201
		wide						280
		tall						12
		visible						1
		font						StatsProgressBarTitle
		labelText					"Stat Bar Name"
		allcaps						1
		wrap 						0
		textAlignment				west
		fgcolor_override 			"255 133 133 255"
		//bgcolor_override 			"0 255 0 100"
	}

	ProgressText
	{
		ControlName					Label
		xpos						0
		ypos						0
		zpos						202
		wide						280
		tall						12
		visible						1
		font						StatsProgressBarNumbers
		labelText					"0 / 0"
		allcaps						1
		textAlignment				west
		fgcolor_override 			"255 133 133 255"
		//bgcolor_override 			"255 0 0 100"

		pin_to_sibling				Title
		pin_corner_to_sibling		0
		pin_to_sibling_corner		2
	}

	BarBackground
	{
		ControlName					ImagePanel
		xpos 						8
		ypos						-5
		zpos						203
		wide 						294
		tall 						21
		image 						"../ui/menu/personal_stats/ps_bar_back"
		visible						1
		scaleImage					1

		pin_to_sibling				ProgressText
		pin_corner_to_sibling		0
		pin_to_sibling_corner		2
	}

	BarFill
	{
		ControlName					ImagePanel
		xpos 						-1
		ypos						1
		zpos						204
		wide 						178
		tall 						8
		image 						"../ui/menu/eog/xp_bar"
		visible						1
		scaleImage					1

		pin_to_sibling				ProgressText
		pin_corner_to_sibling		0
		pin_to_sibling_corner		2
	}

	BarFillShadow
	{
		ControlName					ImagePanel
		xpos 						-1
		ypos						1
		zpos						205
		wide 						178
		tall 						8
		image 						"../ui/menu/eog/xp_bar_shadow"
		visible						1
		scaleImage					1

		pin_to_sibling				ProgressText
		pin_corner_to_sibling		0
		pin_to_sibling_corner		2
	}
}