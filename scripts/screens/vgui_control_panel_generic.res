// 164x124
control_panel_generic_screen.res
{
	Background
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				164
		tall				124
		visible				1
		image				HUD/titan_screen_bg
		scaleImage			1
		drawColor			"128 128 128 255"

		zpos				0
	}

	Foreground
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				164
		tall				124
		visible				1
		image				HUD/titan_screen_fg
		scaleImage			1
		drawColor			"128 128 128 255"

		zpos				1000
	}

	State
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				164
		tall				20
		visible				1
		font				CapturePointStatusHUD
		labelText			"#CONTROL_PANEL_DISABLED"
		textAlignment		center

		fgcolor_override 	"164 233 108 160"

		zpos				200

		pin_to_sibling				Background
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	ControlledItem
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				164
		tall				50
		visible				1
		font				CapturePointStatusHUD
		labelText			"----------"
		textAlignment		center

		fgcolor_override 	"164 233 108 160"

		zpos				200

		pin_to_sibling				Background
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4
	}
}
