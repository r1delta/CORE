"Resource/UI/menus/button_locked_tooltip.res"
{
	Image
	{
		ControlName				ImagePanel
		xpos					0
		ypos					0
		wide					200
		tall					30
		visible					1
		scaleImage				1
		image 					"../ui/menu/common/button_locked_tooltip"
	}

	Label
	{
		ControlName				Label
		xpos					12
		ypos					7
		zpos					300
		wide					180
		tall					14
		visible					1
		font					DefaultButtonFont
		labelText				"#UNLOCKED_AT_LEVEL"
		allcaps					1
		textAlignment			center
		fgcolor_override 		"38 28 28 255"
		//bgcolor_override 		"0 0 0 200"
	}
}