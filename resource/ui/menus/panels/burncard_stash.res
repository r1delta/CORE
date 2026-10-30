"resource/ui/menus/panels/burncard_stash.res"
{
	BurnCardStashStatus
	{
		ControlName				Label
		//auto_wide_tocontents 	1
		auto_tall_tocontents 	1
		zpos					3 // Needed or clicking on the background can hide this
		font					HudFontMed
		textinsetx				6
		allcaps					0
		fgcolor_override		"255 133 133 255" // "255 85 45 255"
		textAlignment			west
		//activeInputExclusivePaint	gamepad

		visible					0
		wrap					0
		wide					700
		//tall					50
		xpos					25
		ypos					7

		labelText				"26/26"
	}

	BurnCardStashStatus_Icon
	{
		ControlName			ImagePanel
		xpos				0
		ypos				-2
		wide				24
		tall				24
		visible				0
		image				"../vgui/burncards/burncard_icon_deck"
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling			BurnCardStashStatus
		pin_corner_to_sibling	5
		pin_to_sibling_corner	7

		zpos				3
	}
}
