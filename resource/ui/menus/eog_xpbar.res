"Resource/UI/menus/eog_xpbar.res"
{
	BarBack
	{
		ControlName				ImagePanel
		xpos 					0
		ypos					0
		wide 					690
		tall 					71
		image 					"../ui/menu/eog/xp_bar_back"
		visible					1
		scaleImage				1
		zpos					106
	}

	BarFillNew
	{
		ControlName				ImagePanel
		xpos 					-54
		ypos					-50
		wide 					582
		tall 					11
		image 					"../ui/menu/eog/xp_bar"
		visible					1
		scaleImage				1
		zpos					107

		pin_to_sibling			BarBack
		pin_corner_to_sibling	7
		pin_to_sibling_corner	0
	}

	BarFillNewColor
	{
		ControlName				ImagePanel
		xpos 					-54
		ypos					-50
		wide 					582
		tall 					11
		image 					"../ui/menu/eog/xp_bar_fill"
		visible					1
		scaleImage				1
		zpos					108

		pin_to_sibling			BarBack
		pin_corner_to_sibling	7
		pin_to_sibling_corner	0
	}

	BarFillPrevious
	{
		ControlName				ImagePanel
		xpos 					-54
		ypos					-50
		wide 					582
		tall 					11
		image 					"../ui/menu/eog/xp_bar"
		visible					1
		scaleImage				1
		zpos					109

		pin_to_sibling			BarBack
		pin_corner_to_sibling	7
		pin_to_sibling_corner	0
	}

	BarFillFlash
	{
		ControlName				ImagePanel
		xpos 					-54
		ypos					-50
		wide 					582
		tall 					11
		image 					"../ui/menu/eog/xp_bar_flash"
		visible					1
		scaleImage				1
		zpos					110

		pin_to_sibling			BarBack
		pin_corner_to_sibling	7
		pin_to_sibling_corner	0
	}

	BarFillShadow
	{
		ControlName				ImagePanel
		xpos 					-54
		ypos					-50
		wide 					582
		tall 					11
		image 					"../ui/menu/eog/xp_bar_shadow"
		visible					1
		scaleImage				1
		zpos					111

		pin_to_sibling			BarBack
		pin_corner_to_sibling	7
		pin_to_sibling_corner	0
	}

	BarFlare
	{
		ControlName				ImagePanel
		xpos					0
		ypos					0
		wide					320
		tall					64
		visible					0
		image 					"../ui/menu/eog/xp_bar_fill_flare"
		scaleImage				1
		zpos					112

		pin_to_sibling				BarFillNewColor
		pin_corner_to_sibling		8
		pin_to_sibling_corner		5
	}

	LevelText
	{
		ControlName				Label
		xpos					56
		ypos					2
		textAlignment			north-west
		auto_wide_tocontents 	1
		tall					30
		visible					1
		font					EOGBarLevelFont
		labelText				"LEVEL XX"
		allcaps					1
		fgcolor_override		"255 133 133 255"
		zpos					113
	}

	XPText
	{
		ControlName				Label
		xpos					58
		ypos					26
		textAlignment			north-west
		wide					300
		tall					25
		visible					1
		font					EOGBarXPFont
		labelText				"XXXX XP REMAINING"
		allcaps					1
		fgcolor_override		"255 133 133 255"
		zpos					114
	}

	GenIcon
	{
		ControlName					ImagePanel
		classname 					"GenIcon"
		xpos 						4
		ypos						0
		zpos						115
		wide						40
		tall						20
		image						"../ui/menu/generation_icons/generation_0"
		visible						0
		scaleImage					1

		pin_to_sibling				LevelText
		pin_corner_to_sibling		7
		pin_to_sibling_corner		5
	}
}