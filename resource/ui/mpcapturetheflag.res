Resource/UI/MPCapturePoint.res
{

//---------------------------------
//		  WORLD INDICATORS
//---------------------------------

	FlagAnchor
	{
		ControlName			ImagePanel
		xpos				0
		ypos				-50
		wide				0
		tall				0
		visible				1
		scaleImage			1
		drawColor			"0 0 0 0"

		pin_to_sibling				SafeArea
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4
		zpos						220
	}

	FriendlyFlagArrow
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				32
		tall				32
		visible				0
		enable				1
		image				offscreen_arrow
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				1
	}

	EnemyFlagArrow
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				32
		tall				32
		visible				0
		enable				1
		image				offscreen_arrow
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				1
	}

	FriendlyFlagIcon
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				32
		tall				32
		visible				0
		enable				1
		image				HUD/ctf_flag_friendly_notext
		drawColor			"255 255 255 255"
		scaleImage			1

		zpos				1
	}

	FriendlyFlagLabel
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				256
		tall				12
		visible				0
		font				HudFontSmall
		labelText			"STATUS"
		allcaps				1
		textAlignment		center
		fgcolor_override 	"255 255 255 255"

		pin_to_sibling				FriendlyFlagIcon
		pin_corner_to_sibling		6
		pin_to_sibling_corner		4

		zpos				1
	}

	EnemyFlagIcon
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				32
		tall				32
		visible				0
		enable				1
		image				HUD/ctf_flag_enemy_notext
		drawColor			"255 255 255 255"
		scaleImage			1

		zpos				1
	}

	EnemyFlagPingIcon
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				32
		tall				32
		visible				0
		enable				1
		image				HUD/mfd_pro_callout
		drawColor			"255 255 255 255"
		scaleImage			1

		pin_to_sibling				EnemyFlagIcon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8

		zpos				1
	}

	EnemyFlagPing2Icon
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				32
		tall				32
		visible				0
		enable				1
		image				HUD/mfd_pro_callout
		drawColor			"255 255 255 255"
		scaleImage			1

		pin_to_sibling				EnemyFlagIcon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8

		zpos				1
	}

	EnemyFlagLabel
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				256
		tall				12
		visible				0
		font				HudFontSmall
		labelText			"STATUS"
		allcaps				1
		textAlignment		center
		fgcolor_override 	"255 255 255 255"

		pin_to_sibling				EnemyFlagIcon
		pin_corner_to_sibling		6
		pin_to_sibling_corner		4

		zpos				1
	}

	HomeBaseIcon
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				32
		tall				32
		visible				0
		enable				1
		image				HUD/ctf_flag_friendly_missing
		drawColor			"255 255 255 255"
		scaleImage			1

		zpos				1
	}

	HomeBaseLabel
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				256
		tall				12
		visible				0
		font				HudFontSmall
		labelText			"STATUS"
		allcaps				0
		textAlignment		center
		fgcolor_override 	"192 192 192 255"
		zpos				1
	}

	HomeBaseArrow
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				32
		tall				32
		visible				0
		enable				1
		image				offscreen_arrow
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				1
	}

	EnemyBaseIcon
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				32
		tall				32
		visible				0
		enable				1
		image				HUD/ctf_flag_friendly_missing
		drawColor			"255 255 255 255"
		scaleImage			1

		zpos				1
	}

	EnemyBaseArrow
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				32
		tall				32
		visible				0
		enable				1
		image				offscreen_arrow
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				1
	}

	EnemyBaseLabel
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				256
		tall				12
		visible				0
		font				HudFontSmall
		labelText			"STATUS"
		allcaps				0
		textAlignment		center
		fgcolor_override 	"192 192 192 255"
		zpos				1
	}

	//TODO: Shouldn't be in CaptureTheFlag.res, put in scavenger specific file if we decide to make this real
	PlayerOreCarryingLabel0
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				256
		tall				12
		visible				0
		font				HudFontSmall
		labelText			"STATUS"
		allcaps				0
		textAlignment		center
		fgcolor_override 	"192 192 192 255"
		zpos				1
	}

	//TODO: Shouldn't be in CaptureTheFlag.res, put in scavenger specific file if we decide to make this real
	PlayerOreCarryingLabel1
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				256
		tall				12
		visible				0
		font				HudFontSmall
		labelText			"STATUS"
		allcaps				0
		textAlignment		center
		fgcolor_override 	"192 192 192 255"
		zpos				1
	}

	//TODO: Shouldn't be in CaptureTheFlag.res, put in scavenger specific file if we decide to make this real
	PlayerOreCarryingLabel2
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				256
		tall				12
		visible				0
		font				HudFontSmall
		labelText			"STATUS"
		allcaps				0
		textAlignment		center
		fgcolor_override 	"192 192 192 255"
		zpos				1
	}

	//TODO: Shouldn't be in CaptureTheFlag.res, put in scavenger specific file if we decide to make this real
	PlayerOreCarryingLabel3
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				256
		tall				12
		visible				0
		font				HudFontSmall
		labelText			"STATUS"
		allcaps				0
		textAlignment		center
		fgcolor_override 	"192 192 192 255"
		zpos				1
	}

	//TODO: Shouldn't be in CaptureTheFlag.res, put in scavenger specific file if we decide to make this real
	PlayerOreCarryingLabel4
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				256
		tall				12
		visible				0
		font				HudFontSmall
		labelText			"STATUS"
		allcaps				0
		textAlignment		center
		fgcolor_override 	"192 192 192 255"
		zpos				1
	}

	//TODO: Shouldn't be in CaptureTheFlag.res, put in scavenger specific file if we decide to make this real
	PlayerOreCarryingLabel5
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				256
		tall				12
		visible				0
		font				HudFontSmall
		labelText			"STATUS"
		allcaps				0
		textAlignment		center
		fgcolor_override 	"192 192 192 255"
		zpos				1
	}

	//TODO: Shouldn't be in CaptureTheFlag.res, put in scavenger specific file if we decide to make this real
	PlayerOreCarryingLabel6
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				256
		tall				12
		visible				0
		font				HudFontSmall
		labelText			"STATUS"
		allcaps				0
		textAlignment		center
		fgcolor_override 	"192 192 192 255"
		zpos				1
	}

	//TODO: Shouldn't be in CaptureTheFlag.res, put in scavenger specific file if we decide to make this real
	PlayerOreCarryingLabel7
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				256
		tall				12
		visible				0
		font				HudFontSmall
		labelText			"STATUS"
		allcaps				0
		textAlignment		center
		fgcolor_override 	"192 192 192 255"
		zpos				1
	}

	//TODO: Shouldn't be in CaptureTheFlag.res, put in scavenger specific file if we decide to make this real
	PlayerOreCarryingLabel8
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				256
		tall				12
		visible				0
		font				HudFontSmall
		labelText			"STATUS"
		allcaps				0
		textAlignment		center
		fgcolor_override 	"192 192 192 255"
		zpos				1
	}

	//TODO: Shouldn't be in CaptureTheFlag.res, put in scavenger specific file if we decide to make this real
	PlayerOreCarryingLabel9
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				256
		tall				12
		visible				0
		font				HudFontSmall
		labelText			"STATUS"
		allcaps				0
		textAlignment		center
		fgcolor_override 	"192 192 192 255"
		zpos				1
	}

	//TODO: Shouldn't be in CaptureTheFlag.res, put in scavenger specific file if we decide to make this real
	PlayerOreCarryingLabel10
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				256
		tall				12
		visible				0
		font				HudFontSmall
		labelText			"STATUS"
		allcaps				0
		textAlignment		center
		fgcolor_override 	"192 192 192 255"
		zpos				1
	}

	//TODO: Shouldn't be in CaptureTheFlag.res, put in scavenger specific file if we decide to make this real
	PlayerOreCarryingLabel11
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				256
		tall				12
		visible				0
		font				HudFontSmall
		labelText			"STATUS"
		allcaps				0
		textAlignment		center
		fgcolor_override 	"192 192 192 255"
		zpos				1
	}

	//TODO: Shouldn't be in CaptureTheFlag.res, put in scavenger specific file if we decide to make this real
	PlayerOreCarryingLabel12
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				256
		tall				12
		visible				0
		font				HudFontSmall
		labelText			"STATUS"
		allcaps				0
		textAlignment		center
		fgcolor_override 	"192 192 192 255"
		zpos				1
	}

	//TODO: Shouldn't be in CaptureTheFlag.res, put in scavenger specific file if we decide to make this real
	PlayerOreCarryingLabel13
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				256
		tall				12
		visible				0
		font				HudFontSmall
		labelText			"STATUS"
		allcaps				0
		textAlignment		center
		fgcolor_override 	"192 192 192 255"
		zpos				1
	}

	//TODO: Shouldn't be in CaptureTheFlag.res, put in scavenger specific file if we decide to make this real
	PlayerOreCarryingLabel14
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				256
		tall				12
		visible				0
		font				HudFontSmall
		labelText			"STATUS"
		allcaps				0
		textAlignment		center
		fgcolor_override 	"192 192 192 255"
		zpos				1
	}

	//TODO: Shouldn't be in CaptureTheFlag.res, put in scavenger specific file if we decide to make this real
	PlayerOreCarryingLabel15
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				256
		tall				12
		visible				0
		font				HudFontSmall
		labelText			"STATUS"
		allcaps				0
		textAlignment		center
		fgcolor_override 	"192 192 192 255"
		zpos				1``
	}
}