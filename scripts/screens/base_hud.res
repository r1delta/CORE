// 848 480
base_hud.res
{
	dpadIconBG
	{
		ControlName		ImagePanel
		xpos			20
		ypos			-8
		wide			72
		tall			66
		visible			1
		image			HUD/hud_hex_bg_right
		scaleImage		1
		drawColor		"255 255 255 255"

		zpos			80

		pin_to_sibling				SafeArea
		pin_corner_to_sibling		3
		pin_to_sibling_corner		3
	}

	dpadIconBG_Tutorial_Outline
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				83
		tall				74
		image				HUD/hud_hex_callout
		visible				0
		scaleImage			1
		drawColor			"255 234 0 255"

		zpos				101

		pin_to_sibling				dpadIconBG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	dpadIcon
	{
		ControlName		ImagePanel
		xpos			20
		ypos			-8
		wide			72
		tall			66
		visible			1
		image			HUD/hud_hex_right
		scaleImage		1
		drawColor		"255 255 255 255"

		zpos			90

		pin_to_sibling				SafeArea
		pin_corner_to_sibling		3
		pin_to_sibling_corner		3
	}

	dpadSideBG
	{
		ControlName		ImagePanel
		xpos			0
		ypos			0
		wide			108
		tall			66
		visible			1
		image			HUD/hud_hex_line_bg_right
		scaleImage		1
		drawColor		"255 255 255 255"

		zpos			80

		pin_to_sibling				dpadIconBG
		pin_corner_to_sibling		1
		pin_to_sibling_corner		0
	}

	dpadSide
	{
		ControlName		ImagePanel
		xpos			0
		ypos			0
		wide			108
		tall			66
		visible			1
		image			HUD/hud_hex_line_right
		scaleImage		1
		drawColor		"255 255 255 255"

		zpos			90

		pin_to_sibling				dpadIcon
		pin_corner_to_sibling		1
		pin_to_sibling_corner		0
	}

	dpadRightIconBG
	{
		ControlName			ImagePanel
		xpos				2
		ypos				0
		wide				40
		tall				40
		visible				1
		image				HUD/hud_icons_bg
		scaleImage			1
		drawColor			"255 255 255 0"

		pin_to_sibling				dpadIcon
		pin_corner_to_sibling		7
		pin_to_sibling_corner		5

		zpos				240
	}

	dpadRightIconAlert
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				40
		tall				40
		visible				0
		image				HUD/hud_icon_alert
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				dpadRightIconBG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8

		zpos				245
	}

	dpadRightIcon
	{
		ControlName			ImagePanel
		xpos				2
		ypos				0
		wide				40
		tall				40
		visible				0
		image				HUD/empty
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				dpadIcon
		pin_corner_to_sibling		7
		pin_to_sibling_corner		5

		zpos				250
	}

	dpadRightIconHint
	{
		ControlName			Label
		xpos				-6
		ypos				0
		wide				80
		tall				32
		labelText			"%scriptCommand4%"
		font				HudFontMedPlain
		visible				0
		drawColor			"255 255 255 255"

		zpos				400

		pin_to_sibling				dpadRightIcon
		pin_corner_to_sibling		7
		pin_to_sibling_corner		5

		activeInputExclusivePaint	keyboard
	}

	dpadRightTitle
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				128
		tall				40
		visible				0
		font				HudFontMed
		labelText			"[RIGHT TITLE]"
		textAlignment		north

		fgcolor_override 	"255 255 255 255"

		zpos				260

		pin_to_sibling				dpadRightIcon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	dpadRightDesc
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				128
		tall				40
		visible				0
		font				HudFontSmall
		labelText			"[RIGHT DESC]"
		textAlignment		south

		fgcolor_override 	"255 255 255 255"

		zpos				260

		pin_to_sibling				dpadRightIcon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}


	dpadLeftIconBG
	{
		ControlName			ImagePanel
		xpos				-8
		ypos				-4
		wide				28
		tall				28
		visible				1
		image				HUD/hud_icons_bg
		scaleImage			1
		drawColor			"255 255 255 0"

		pin_to_sibling				dpadSideBG
		pin_corner_to_sibling		2
		pin_to_sibling_corner		6

		zpos				240
	}

	dpadLeftIconAlert
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				28
		tall				28
		visible				0
		image				HUD/hud_icon_alert
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				dpadLeftIconBG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8

		zpos				245
	}

	dpadLeftIcon
	{
		ControlName			ImagePanel
		xpos				0
		ypos				-2
		wide				36
		tall				36
		visible				0
		image				HUD/empty
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				dpadLeftIconBG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8

		zpos				250
	}

	dpadLeftIconHint
	{
		ControlName			Label
		xpos				6
		ypos				2
		wide				80
		tall				28
		labelText			"%weaponSelectOrdnance%"
		font				HudFontMedPlain
		textAlignment		east
		textinsety			0
		visible				0
		drawColor			"255 255 255 255"

		zpos				400

		pin_to_sibling				dpadLeftIconBG
		pin_corner_to_sibling		1
		pin_to_sibling_corner		0
	}

	dpadLeftTitle
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				128
		tall				40
		visible				0
		font				HudFontMed
		labelText			"[LEFT TITLE]"
		textAlignment		north

		fgcolor_override 	"255 255 255 0"

		zpos				260

		pin_to_sibling				dpadLeftIcon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	dpadLeftDesc
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				128
		tall				40
		visible				0
		font				HudFontSmall
		labelText			"[LEFT DESC]"
		textAlignment		south

		fgcolor_override 	"255 255 255 0"

		zpos				260

		pin_to_sibling				dpadLeftIcon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}


	dpadUpIconBG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				-4
		wide				28
		tall				28
		visible				1
		image				HUD/hud_icons_bg
		scaleImage			1
		drawColor			"255 255 255 0"

		pin_to_sibling				dpadSideBG
		pin_corner_to_sibling		2
		pin_to_sibling_corner		6

		zpos				240
	}

	dpadUpIconAlert
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				28
		tall				28
		visible				0
		image				HUD/hud_icon_alert
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				dpadUpIconBG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8

		zpos				245
	}

	dpadUpIcon
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				28
		tall				28
		visible				0
		image				HUD/empty
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				dpadUpIconBG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8

		zpos				250
	}

	dpadUpIconHint
	{
		ControlName			Label
		xpos				0
		ypos				2
		wide				80
		tall				28
		labelText			"%scriptCommand1%"
		font				HudFontMedPlain
		textAlignment		east
		visible				0
		drawColor			"255 255 255 255"

		zpos				400

		pin_to_sibling				dpadUpIconBG
		pin_corner_to_sibling		1
		pin_to_sibling_corner		0
	}

	dpadUpTitle
	{
		ControlName			Label
		xpos				0
		ypos				-8
		wide				128
		tall				40
		visible				0
		font				HudFontMed
		labelText			"[UP TITLE]"
		textAlignment		north

		fgcolor_override 	"255 255 255 0"

		zpos				260

		pin_to_sibling				dpadUpIcon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	dpadUpDesc
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				128
		tall				40
		visible				0
		font				HudFontSmall
		labelText			"[UP DESC]"
		textAlignment		south

		fgcolor_override 	"255 255 255 0"

		zpos				260

		pin_to_sibling				dpadUpIcon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	dpadDownIconBG
	{
		ControlName			CHudProgressBar
		xpos				0
		ypos				0
		wide				72
		tall				66
		visible				1
		fg_image			HUD/hud_hex_progress_timer
		fgcolor_override	"0 0 0 220"
		//bg_image			HUD/hud_hex_progress_hollow_round_bg
		//bgcolor_override	"0 0 0 220"
		CircularEnabled 	1
		CircularClockwise	0
		ProgressDirection	0

		pin_to_sibling				dpadIcon
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0

		zpos				260
	}

	dpadDownIconProgressBar
	{
		ControlName			CHudProgressBar
		xpos				0
		ypos				0
		wide				72
		tall				66
		visible				1
		fg_image			HUD/hud_hex_progress_hollow_round
		fgcolor_override	"132 156 175 128"
		bg_image			HUD/hud_hex_progress_hollow_round_bg
		bgcolor_override	"255 255 255 16"
		CircularEnabled 	1
		CircularClockwise	1
		ProgressDirection	0

		pin_to_sibling				dpadIcon
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0

		zpos				261
	}

	dpadDownIconAlert
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				60
		tall				60
		visible				0
		image				HUD/hud_icon_alert
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				dpadDownIconBG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8

		zpos				270
	}

	dpadDownIcon
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				60
		tall				60
		visible				0
		image				HUD/titan_build_icon_5
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				dpadDownIconBG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8

		zpos				255
	}

	dpadDownIconHint
	{
		ControlName			Label
		xpos				-28
		ypos				-11
		//xpos				0
		//ypos				-3
		wide				80
		tall				18
		labelText			"%ability 1%"
		textAlignment		center
		font				HudFontMedPlain
		visible				0
		drawColor			"255 255 255 255"

		zpos				280

		pin_to_sibling				dpadDownIconBG
		pin_corner_to_sibling		6
		pin_to_sibling_corner		6
	}

	dpadDownTitle
	{
		ControlName			Label
		xpos				0
		ypos				-8
		wide				128
		tall				40
		visible				0
		font				HudFontMed
		labelText			"[DOWN Title]"
		textAlignment		north

		fgcolor_override 	"255 255 255 0"

		zpos				260

		pin_to_sibling				dpadDownIcon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	dpadDownDesc
	{
		ControlName			Label
		xpos				0
		ypos				3
		wide				128
		tall				128
		visible				0
		font				HudFontSmall
		labelText			"[DOWN DESC]"
		textAlignment		south
		textinsety			-6

		fgcolor_override 	"255 255 255 255"

		zpos				280

		pin_to_sibling				dpadDownIconBG
		pin_corner_to_sibling		6
		pin_to_sibling_corner		6
	}


	GameInfoBG
	{
		ControlName		ImagePanel
		xpos			20
		ypos			-8
		wide			72
		tall			66
		visible			1
		image			HUD/hud_hex_bg_left
		scaleImage		1
		drawColor		"255 255 255 255"

		zpos			90

		pin_to_sibling				SafeArea
		pin_corner_to_sibling		2
		pin_to_sibling_corner		2
	}

	GameInfoFG
	{
		ControlName		ImagePanel
		xpos			20
		ypos			-8
		wide			72
		tall			66
		visible			1
		image			HUD/hud_hex_left
		scaleImage		1
		drawColor		"255 255 255 255"

		zpos			100

		pin_to_sibling				SafeArea
		pin_corner_to_sibling		2
		pin_to_sibling_corner		2
	}

	GameInfoTeamIcon
	{
		ControlName		ImagePanel
		xpos			0
		ypos			0
		wide			56
		tall			56
		visible			1
		image			../ui/scoreboard_imc_logo
		scaleImage		1
		drawColor		"255 255 255 255"

		zpos			100

		pin_to_sibling				GameInfoBG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	GameInfoLabel
	{
		ControlName			Label
		xpos				16
		ypos				0
		wide				110
		tall				12
		visible				1
		font				HudFontMedSmall
		labelText			"#PILOT_HUNTER"
		allcaps				1
		textAlignment		center
		fgcolor_override 	"255 255 255 255"
		//bgcolor_override 	"255 255 255 255"

		zpos				150

		pin_to_sibling				GameInfoBG
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}

	GameModeLabel
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				200
		tall				12
		visible				1
		font				HudFontSmall
		labelText			"Game Mode Text Here"
		textAlignment		west
		textinsetx			0
		allcaps				1
		fgcolor_override 	"255 255 255 180"

		zpos				150

		pin_to_sibling				GameInfoBG
		pin_corner_to_sibling		2
		pin_to_sibling_corner		1
	}

	RankedHud
	{
		ControlName			CNestedPanel
		xpos			-1
		ypos			0
		wide			72
		tall			66
		visible				1

		zpos				4000

		controlSettingsFile	"resource/UI/HudRanked.res"

		pin_to_sibling				GameInfoBG
		pin_corner_to_sibling		7
		pin_to_sibling_corner		7
	}

	ScoresBG
	{
		ControlName		ImagePanel
		xpos			0
		ypos			0
		wide			108
		tall			66
		visible			1
		image			HUD/hud_hex_line_bg_left
		drawColor		"255 255 255 255"
		scaleImage		1

		zpos			90

		pin_to_sibling				GameInfoBG
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	ScoresFG
	{
		ControlName		ImagePanel
		xpos			0
		ypos			0
		wide			108
		tall			66
		visible			1
		image			HUD/hud_hex_line_left
		drawColor		"255 255 255 255"
		scaleImage		1

		zpos			110

		pin_to_sibling				GameInfoFG
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	ScorePopupLabel
	{
		ControlName			Label
		xpos				-24
		ypos				0
		wide				64
		tall				12
		visible				0
		font				HudFontMed
		labelText			"#ATTRITION_POINT_POPUP"
		textAlignment		west
		fgcolor_override 	"255 255 255 180"

		zpos				151

		pin_to_sibling				ScoresFriendly
		pin_corner_to_sibling		2
		pin_to_sibling_corner		1
	}

	ScoresFriendly
	{
		ControlName			CHudProgressBar
		xpos				0
		ypos				0
		wide				108
		tall				33
		visible				1
		fg_image			HUD/hud_score_strip_blue
		bg_image			HUD/hud_score_strip_bg_blue
		fgcolor_override	"255 255 255 255"
		bgcolor_override	"255 255 255 255"
		SegmentSize			108
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			2

		pin_to_sibling				ScoresBG
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0

		zpos 120
	}

	ScoresLabelFriendly
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				108
		tall				33
		visible				1
		font				HudFontMedSmallPlain
		labelText			"#TEAM_IMC"
		textAlignment		south-east
		textinsetx			20
		fgcolor_override 	"255 255 255 180"

		zpos				150

		pin_to_sibling				ScoresFriendly
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	ScoresTeamLabelFriendly
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				108
		tall				33
		visible				1
		font				HudFontMedSmallPlain
		labelText			"#TEAM_IMC"
		textAlignment		south-west
		textinsetx			8
		fgcolor_override 	"255 255 255 180"

		zpos				150

		pin_to_sibling				ScoresFriendly
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	ScoresEnemy
	{
		ControlName			CHudProgressBar
		xpos				0
		ypos				0
		wide				108
		tall				33
		visible				1
		fg_image			HUD/hud_score_strip_orange
		bg_image			HUD/hud_score_strip_bg_orange
		fgcolor_override	"255 255 255 255"
		bgcolor_override	"255 255 255 255"
		SegmentSize			108
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			2

		pin_to_sibling				ScoresBG
		pin_corner_to_sibling		2
		pin_to_sibling_corner		2

		zpos 120
	}

	ScoresLabelEnemy
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				108
		tall				33
		visible				1
		font				HudFontSmallPlain
		labelText			"#TEAM_MCOR"
		textAlignment		north-east
		textinsetx			20
		textinsety			4
		fgcolor_override 	"255 255 255 180"

		zpos				150

		pin_to_sibling				ScoresEnemy
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	ScoresTeamLabelEnemy
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				108
		tall				33
		visible				1
		font				HudFontSmallPlain
		labelText			"#TEAM_MCOR"
		textAlignment		north-west
		textinsetx			8
		textinsety			4
		fgcolor_override 	"255 255 255 180"

		zpos				150

		pin_to_sibling				ScoresEnemy
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}



	ScoresGameInfoAnchor
	{
		ControlName		ImagePanel
		xpos			-20
		ypos			10
		wide			116
		tall			64
		visible			1
		drawColor		"255 255 255 0"
		image			HUD/white
		scaleImage		1

		zpos			110

		pin_to_sibling				GameInfoBG
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}

//	ScoreObjectiveText
//	{
//		ControlName			Label
//		xpos				0
//		ypos				-8
//		wide				256
//		tall				20
//		visible				0
//		font				HudFontMed
//		labelText			"Last Titan standing wins"
//		textAlignment		center
//		fgcolor_override 	"255 255 255 180"
//
//		zpos				151
//
//		pin_to_sibling				ScoresGameInfoAnchor
//		pin_corner_to_sibling		4
//		pin_to_sibling_corner		6
//	}
//
//	ScoreObjectiveSubText
//	{
//		ControlName			Label
//		xpos				0
//		ypos				6
//		wide				256
//		tall				20
//		visible				0
//		font				HudFontSmall
//		labelText			"Grace period ends in: 0:89:42"
//		textAlignment		center
//		fgcolor_override 	"255 255 255 180"
//
//		zpos				151
//
//		pin_to_sibling				ScoresGameInfoAnchor
//		pin_corner_to_sibling		4
//		pin_to_sibling_corner		6
//	}

	ScoresHardpointBg_B
	{
		ControlName		ImagePanel
		xpos			-22
		ypos			-4
		wide			20
		tall			20
		visible			0
		image			HUD/capture_point_status_icons_bg
		drawColor		"255 255 255 255"
		scaleImage		1

		zpos			110

		pin_to_sibling				ScoresGameInfoAnchor
		pin_corner_to_sibling		2
		pin_to_sibling_corner		2
	}

	ScoresHardpointFg_B
	{
		ControlName		ImagePanel
		xpos			-22
		ypos			-4
		wide			20
		tall			20
		visible			0
		image			HUD/capture_point_status_b
		drawColor		"255 255 255 255"
		scaleImage		1

		zpos			130

		pin_to_sibling				ScoresGameInfoAnchor
		pin_corner_to_sibling		2
		pin_to_sibling_corner		2
	}

	ScoresHardpointFill_B
	{
		ControlName		ImagePanel
		xpos			-22
		ypos			-4
		wide			20
		tall			20
		visible			0
		image			HUD/capture_point_status_orange_b
		drawColor		"255 255 255 255"
		scaleImage		1

		zpos			120

		pin_to_sibling				ScoresGameInfoAnchor
		pin_corner_to_sibling		2
		pin_to_sibling_corner		2
	}

	ScoresHardpointBg_A
	{
		ControlName		ImagePanel
		xpos			2
		ypos			0
		wide			20
		tall			20
		visible			0
		image			HUD/capture_point_status_icons_bg
		drawColor		"255 255 255 255"
		scaleImage		1

		zpos			110

		pin_to_sibling				ScoresHardpointBg_B
		pin_corner_to_sibling		5
		pin_to_sibling_corner		7
	}

	ScoresHardpointFg_A
	{
		ControlName		ImagePanel
		xpos			2
		ypos			0
		wide			20
		tall			20
		visible			0
		image			HUD/capture_point_status_a
		drawColor		"255 255 255 255"
		scaleImage		1

		zpos			130

		pin_to_sibling				ScoresHardpointBg_B
		pin_corner_to_sibling		5
		pin_to_sibling_corner		7
	}

	ScoresHardpointFill_A
	{
		ControlName		ImagePanel
		xpos			2
		ypos			0
		wide			20
		tall			20
		visible			0
		image			HUD/capture_point_status_orange_a
		drawColor		"255 255 255 255"
		scaleImage		1

		zpos			120

		pin_to_sibling				ScoresHardpointBg_B
		pin_corner_to_sibling		5
		pin_to_sibling_corner		7
	}

	ScoresHardpointBg_C
	{
		ControlName		ImagePanel
		xpos			2
		ypos			0
		wide			20
		tall			20
		visible			0
		image			HUD/capture_point_status_icons_bg
		drawColor		"255 255 255 255"
		scaleImage		1

		zpos			110

		pin_to_sibling				ScoresHardpointBg_B
		pin_corner_to_sibling		7
		pin_to_sibling_corner		5
	}

	ScoresHardpointFg_C
	{
		ControlName		ImagePanel
		xpos			2
		ypos			0
		wide			20
		tall			20
		visible			0
		image			HUD/capture_point_status_c
		drawColor		"255 255 255 255"
		scaleImage		1

		zpos			130

		pin_to_sibling				ScoresHardpointBg_B
		pin_corner_to_sibling		7
		pin_to_sibling_corner		5
	}

	ScoresHardpointFill_C
	{
		ControlName		ImagePanel
		xpos			2
		ypos			0
		wide			20
		tall			20
		visible			0
		image			HUD/capture_point_status_blue_c
		drawColor		"255 255 255 255"
		scaleImage		1

		zpos			120

		pin_to_sibling				ScoresHardpointBg_B
		pin_corner_to_sibling		7
		pin_to_sibling_corner		5
	}

	CaptureBarAnchor
	{
		ControlName			ImagePanel
		xpos				0
		ypos				-80
		wide				160
		tall				40
		visible				1
		scaleImage			1
		drawColor			"0 0 0 0"

		pin_to_sibling				SafeAreaCenter
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4
		zpos						220
	}

	FriendlyFlag
	{
		ControlName		ImagePanel
		xpos			0
		ypos			0
		wide			20
		tall			20
		visible			0
		image			HUD/ctf_flag_neutral
		drawColor		"134 199 254 255"
		scaleImage		1

		zpos			110

		pin_to_sibling				EnemyFlag
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}

	FriendlyFlagLabel
	{
		ControlName			Label
		xpos				4
		ypos				0
		wide				80
		tall				20
		visible				0
		font				HudFontSmall
		labelText			"Home"
		textAlignment		west
		fgcolor_override 	"255 255 255 180"

		zpos				150

		pin_to_sibling				FriendlyFlag
		pin_corner_to_sibling		7
		pin_to_sibling_corner		5
	}

	EnemyFlag
	{
		ControlName		ImagePanel
		xpos			0
		ypos			0
		wide			20
		tall			20
		visible			0
		image			HUD/ctf_flag_neutral
		drawColor		"241 169 126 255"
		scaleImage		1

		zpos			110

		pin_to_sibling				ScoresGameInfoAnchor
		pin_corner_to_sibling		2
		pin_to_sibling_corner		2
	}

	EnemyFlagLabel
	{
		ControlName			Label
		xpos				4
		ypos				0
		wide				80
		tall				20
		visible				0
		font				HudFontSmall
		labelText			"Home"
		textAlignment		west
		fgcolor_override 	"255 255 255 180"

		zpos				150

		pin_to_sibling				EnemyFlag
		pin_corner_to_sibling		7
		pin_to_sibling_corner		5
	}

	FriendlyTitanCount
	{
		ControlName			CHudProgressBar
		xpos				0
		ypos				-4
		wide				96
		tall				12
		visible				1
		fg_image			"../ui/icon_status_titan_friendly"
		fgcolor_override	"255 255 255 255"
		SegmentSize			12
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			3

		zpos				120

		pin_to_sibling				ScoresFriendly
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	FriendlyBurnTitanCount
	{
		ControlName			CHudProgressBar
		xpos				0
		ypos				-4
		wide				96
		tall				12
		visible				1
		fg_image			"../ui/icon_status_burncard_friendly"
		fgcolor_override	"255 255 255 255"
		SegmentSize			12
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			3

		zpos				115

		pin_to_sibling				ScoresFriendly
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	FriendlyTitanReadyCount
	{
		ControlName			CHudProgressBar
		xpos				0
		ypos				-4
		wide				96
		tall				12
		visible				1
		fg_image			"../ui/icon_status_titan_neutral"
		fgcolor_override	"128 128 128 255"
		SegmentSize			12
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			3

		zpos				118

		pin_to_sibling				ScoresFriendly
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}


	EnemyTitanCount
	{
		ControlName			CHudProgressBar
		xpos				0
		ypos				-4
		wide				96
		tall				12
		visible				1
		fg_image			"../ui/icon_status_titan_enemy"
		fgcolor_override	"255 255 255 255"
		SegmentSize			12
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			3

		zpos				120

		pin_to_sibling				ScoresEnemy
		pin_corner_to_sibling		2
		pin_to_sibling_corner		2
	}

	EnemyBurnTitanCount
	{
		ControlName			CHudProgressBar
		xpos				0
		ypos				-4
		wide				96
		tall				12
		visible				1
		fg_image			"../ui/icon_status_burncard_enemy"
		fgcolor_override	"255 255 255 255"
		SegmentSize			12
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			3

		zpos				115

		pin_to_sibling				ScoresEnemy
		pin_corner_to_sibling		2
		pin_to_sibling_corner		2
	}

	MinimapBG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				166
		tall				166
		visible				1
		image				HUD/minimap_bg
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				4

		pin_to_sibling				Minimap
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	MinimapBGCoop
	{
		ControlName			ImagePanel
		xpos				0
		ypos				-4
		wide				166
		tall				172
		visible				0
		image				HUD/minimap_bg
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				4

		pin_to_sibling				Minimap
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	MinimapFG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				166
		tall				166
		visible				1
		image				HUD/minimap_shape
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				16

		pin_to_sibling				Minimap
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	MinimapOverlay
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				166
		tall				166
		visible				0
		image				HUD/minimap_overlay
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				17

		pin_to_sibling				Minimap
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	MinimapCompass
	{
		ControlName			ImagePanel
		xpos				0
		ypos				9
		wide				120
		tall				16
		visible				1
		image				HUD/compass_ticker
		scaleImage			1
		drawColor			"165 205 233 255"

		zpos				10

		pin_to_sibling				Minimap
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4
	}

	MinimapCompassCoop
	{
		ControlName			ImagePanel
		xpos				0
		ypos				7
		wide				120
		tall				10
		visible				0
		image				HUD/compass_ticker_coop
		scaleImage			1
		drawColor			"165 205 233 255"

		zpos				10

		pin_to_sibling				Minimap
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4
	}

	MinimapSatelliteLabel
	{
		ControlName			Label
		xpos				0
		ypos				2
		wide				120
		tall				8
		visible				0
		font				HudFontSmall
		labelText			"#COOP_MINIMAP_SATELLITE_VIEW"
		allCaps				1
		textAlignment		center
		fgcolor_override 	"200 230 255 255"

		zpos				10

		pin_to_sibling				MinimapCompassCoop
		pin_corner_to_sibling		6
		pin_to_sibling_corner		4
	}

	weaponLabel
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				100
		tall				14
		visible				1
		font				HudFontSmall
		labelText			""
		textAlignment		west
		textinsetx			0
		fgcolor_override 	"255 255 255 255"

		zpos				150

		pin_to_sibling				weaponAmmoBar
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}

	weaponAmmoCount
	{
		ControlName				Label
		xpos					0
		ypos					-1
		wide					80
		tall					14
		visible					1
		font					HudFontMedPlain
		auto_wide_tocontents	1
		labelText				"∞"
		textAlignment			east
		textinsety				0
		fgcolor_override 		"255 255 255 255"

		zpos					150

		pin_to_sibling				dpadSideBG
		pin_corner_to_sibling		3
		pin_to_sibling_corner		5
	}

	weaponMagLabel
	{
		ControlName					Label
		xpos						0
		ypos						-7
		wide						100
		tall						12
		visible						1
		font						HudFontSmall
		auto_wide_tocontents		1
		labelText					""
		textAlignment				east
		fgcolor_override 			"255 255 255 140"

		zpos						150

		pin_to_sibling				dpadSideBG
		pin_corner_to_sibling		1
		pin_to_sibling_corner		1
	}

	weaponAmmoMag
	{
		ControlName			ImagePanel
		xpos				-2
		ypos				0
		wide				12
		tall				12
		visible				1
		image				HUD/weaponinfo_clip
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				weaponMagLabel
		pin_corner_to_sibling		5
		pin_to_sibling_corner		7

		zpos				150
	}

	weaponAmmoBar
	{
		ControlName			CHudProgressBar
		xpos				-14
		ypos				-2
		wide				65
		tall				6
		visible				1
		fg_image			"HUD/hud_bar_small"
		bg_image			"HUD/white"
		fgcolor_override	"128 128 128 255"
		bgcolor_override	"0 0 0 123"
		SegmentSize			65
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			2

		pin_to_sibling				dpadSideBG
		pin_corner_to_sibling		2
		pin_to_sibling_corner		7

		zpos 140
	}

	chargeAmmoBar
	{
		ControlName			CHudProgressBar
		xpos				-14
		ypos				-2
		wide				65
		tall				6
		visible				1
		fg_image			"HUD/hud_bar_small"
		bg_image			"HUD/white"
		fgcolor_override	"255 255 255 255"
		bgcolor_override	"0 0 0 123"
		SegmentSize			65
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			2

		pin_to_sibling				dpadSideBG
		pin_corner_to_sibling		2
		pin_to_sibling_corner		7

		zpos 140
	}

	activeTrap0
	{
		ControlName			ImagePanel
		xpos				0
		ypos				-8
		wide				12
		tall				12
		visible				1
		image				HUD/dpad_satchel
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				dpadSideBG
		pin_corner_to_sibling		3
		pin_to_sibling_corner		1
	}

	activeTrap1
	{
		ControlName			ImagePanel
		xpos				2
		ypos				0
		wide				12
		tall				12
		visible				1
		image				HUD/dpad_satchel
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				activeTrap0
		pin_corner_to_sibling		5
		pin_to_sibling_corner		7
	}

	activeTrap2
	{
		ControlName			ImagePanel
		xpos				2
		ypos				0
		wide				12
		tall				12
		visible				1
		image				HUD/dpad_satchel
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				activeTrap1
		pin_corner_to_sibling		5
		pin_to_sibling_corner		7
	}

	activeTrap3
	{
		ControlName			ImagePanel
		xpos				2
		ypos				0
		wide				12
		tall				12
		visible				1
		image				HUD/dpad_satchel
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				activeTrap2
		pin_corner_to_sibling		5
		pin_to_sibling_corner		7
	}

	activeTrap4
	{
		ControlName			ImagePanel
		xpos				2
		ypos				0
		wide				12
		tall				12
		visible				1
		image				HUD/dpad_satchel
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				activeTrap3
		pin_corner_to_sibling		5
		pin_to_sibling_corner		7
	}


	inGameBurnCardIcon
	{
		ControlName			ImagePanel
		xpos				-15
		ypos				0
		zpos				101

		wide				18
		tall				18

		visible				0
		image				burncards/burncard_icon_spectre_virus
		scaleImage			1
		drawColor			"246 134 40 255"

		pin_to_sibling				dpadIconBG
		pin_corner_to_sibling		3
		pin_to_sibling_corner		1
	}

	inGameBurnCardIconShadow
	{
		ControlName			ImagePanel
		xpos				2
		ypos				2
		zpos				98

		wide				19
		tall				19

		visible				0
		image				burncards/burncard_icon_spectre_virus
		scaleImage			1
		drawColor			"0 0 0 155"

		pin_to_sibling				inGameBurnCardIcon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	inGameBurnCard_label
	{
		ControlName			Label
		xpos				0
		ypos				0
		zpos				100
		wide				200
		tall				24
		labelText			"Burn card title"
		textAlignment		east
		font				HudFontSmall
		visible				0
		zpos 				1000
		fgcolor_override	"246 134 40 255"

		pin_to_sibling				inGameBurnCardIcon
		pin_corner_to_sibling		5
		pin_to_sibling_corner		7
	}

	inGameBurnCard2Icon
	{
		ControlName			ImagePanel
		xpos				-15
		ypos				20
		zpos				101

		wide				18
		tall				18

		visible				0
		image				burncards/burncard_icon_spectre_virus
		scaleImage			1
		drawColor			"246 134 40 255"

		pin_to_sibling				dpadIconBG
		pin_corner_to_sibling		3
		pin_to_sibling_corner		1
	}

	inGameBurnCardIcon2Shadow
	{
		ControlName			ImagePanel
		xpos				2
		ypos				2
		zpos				98

		wide				19
		tall				19

		visible				0
		image				burncards/burncard_icon_spectre_virus
		scaleImage			1
		drawColor			"0 0 0 155"

		pin_to_sibling				inGameBurnCard2Icon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	inGameBurnCard2_label
	{
		ControlName			Label
		xpos				0
		ypos				0
		zpos				100
		wide				200
		tall				24
		labelText			"Burn card title"
		textAlignment		east
		font				HudFontSmall
		visible				0
		zpos 				1000
		fgcolor_override	"246 134 40 255"

		pin_to_sibling				inGameBurnCard2Icon
		pin_corner_to_sibling		5
		pin_to_sibling_corner		7
	}

	killStreak_background
	{
		ControlName			ImagePanel
		xpos				-10
		ypos				-4
		zpos				100
		wide				40
		tall				24
		visible				1
		image				burncards/burncard_icon_bg
		scaleImage			1
		drawColor			"255 255 255 0"
		zpos 				99

		pin_to_sibling				dpadSideBG
		pin_corner_to_sibling		3
		pin_to_sibling_corner		1
	}

	killStreak_label
	{
		ControlName			Label
		xpos				0
		ypos				0
		zpos				100
		wide				40
		tall				24
		labelText			"x4"
		textAlignment		east
		font				HudFontSmall
		visible				1
		zpos 				1000
		fgcolor_override	"255 255 255 0"

		pin_to_sibling				killStreak_background
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}


	EquipmentBG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				56
		tall				32
		image				HUD/rb_bg
		visible				0
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				100

		pin_to_sibling				EquipmentIcon
		pin_corner_to_sibling		1
		pin_to_sibling_corner		1
	}
	EquipmentIcon
	{
		ControlName			ImagePanel
		xpos				0
		ypos				5
		wide				28
		tall				28
		image				HUD/empty
		visible				0
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				450

		pin_to_sibling				Offhand1Icon
		pin_corner_to_sibling		6
		pin_to_sibling_corner		4
	}

	EquipmentHint
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				50
		tall				24
		labelText			"%+scriptCommand1%"
		textAlignment		east
		font				HudFontSmallPlain
		visible				0
		fgcolor_override	"255 255 255 255"

		zpos				400

		pin_to_sibling				EquipmentIcon
		pin_corner_to_sibling		3
		pin_to_sibling_corner		2
	}

	EquipmentAlert
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				28
		tall				28
		image				HUD/empty
		visible				0
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				440

		pin_to_sibling				EquipmentIcon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	EquipmentCount
	{
		ControlName			Label
		xpos				0
		ypos				-6
		wide				24
		tall				8
		visible				0
		font				HudFontSmall
		labelText			"x4"
		textAlignment		west
		fgcolor_override 	"255 255 255 180"

		zpos				460

		pin_to_sibling				EquipmentIcon
		pin_corner_to_sibling		1
		pin_to_sibling_corner		3
	}
	EquipmentDot0
	{
		ControlName			ImagePanel
		xpos				-2
		ypos				0
		wide				6
		tall				6
		image				"../vgui/HUD/coop/small_dot"
		visible				0
		scaleImage			1
		drawColor			"255 255 255 200"

		zpos				460

		pin_to_sibling				EquipmentIcon
		pin_corner_to_sibling		3
		pin_to_sibling_corner		1
	}
	EquipmentDot1
	{
		ControlName			ImagePanel
		xpos				3
		ypos				0
		wide				6
		tall				6
		image				"../vgui/HUD/coop/small_dot"
		visible				0
		scaleImage			1
		drawColor			"255 255 255 200"

		zpos				460

		pin_to_sibling				EquipmentDot0
		pin_corner_to_sibling		1
		pin_to_sibling_corner		0
	}
	EquipmentDot2
	{
		ControlName			ImagePanel
		xpos				3
		ypos				0
		wide				6
		tall				6
		image				"../vgui/HUD/coop/small_dot"
		visible				0
		scaleImage			1
		drawColor			"255 255 255 200"

		zpos				460

		pin_to_sibling				EquipmentDot1
		pin_corner_to_sibling		1
		pin_to_sibling_corner		0
	}

	EquipmentBar
	{
		ControlName			CHudProgressBar
		xpos				-2
		ypos				-2
		wide				44
		tall				4
		visible				0
		fg_image			"HUD/hud_bar_small"
		bg_image			"HUD/white"
		fgcolor_override	"255 255 255 255"
		bgcolor_override	"0 0 0 123"
		SegmentSize			64
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			2

		pin_to_sibling				EquipmentIcon
		pin_corner_to_sibling		1
		pin_to_sibling_corner		3

		zpos				460
	}


	Offhand1BG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				56
		tall				32
		image				HUD/rb_bg
		visible				1
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				100

		pin_to_sibling				Offhand1Icon
		pin_corner_to_sibling		1
		pin_to_sibling_corner		1
	}

	Offhand1_Tutorial_Outline
	{
		ControlName			ImagePanel
		xpos				-2
		ypos				0
		wide				84
		tall				50
		image				HUD/lb_rb_callout
		visible				0
		scaleImage			1
		drawColor			"255 234 0 255"

		zpos				101

		pin_to_sibling				Offhand1BG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	Offhand1Icon
	{
		ControlName			ImagePanel
		xpos				-200
		ypos				-16
		wide				28
		tall				28
		image				HUD/empty
		visible				0
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				450

		pin_to_sibling				SafeAreaCenter
		pin_corner_to_sibling		2
		pin_to_sibling_corner		2
	}

	Offhand1Hint
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				50
		tall				24
		labelText			"%offhand2%"
		textAlignment		east
		font				HudFontSmallPlain
		visible				1
		fgcolor_override	"255 255 255 255"

		zpos				400

		pin_to_sibling				Offhand1Icon
		pin_corner_to_sibling		3
		pin_to_sibling_corner		2
	}

	Offhand1Alert
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				28
		tall				28
		image				HUD/empty
		visible				0
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				440

		pin_to_sibling				Offhand1Icon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	Offhand1Count
	{
		ControlName			Label
		xpos				0
		ypos				-6
		wide				24
		tall				8
		visible				0
		font				HudFontSmall
		labelText			"x4"
		textAlignment		west
		fgcolor_override 	"255 255 255 180"

		zpos				460

		pin_to_sibling				Offhand1Icon
		pin_corner_to_sibling		1
		pin_to_sibling_corner		3
	}

	Offhand1Bar
	{
		ControlName			CHudProgressBar
		xpos				-2
		ypos				-2
		wide				44
		tall				4
		visible				0
		fg_image			"HUD/hud_bar_small"
		bg_image			"HUD/white"
		fgcolor_override	"255 255 255 255"
		bgcolor_override	"0 0 0 123"
		SegmentSize			64
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			2

		pin_to_sibling				Offhand1Icon
		pin_corner_to_sibling		1
		pin_to_sibling_corner		3

		zpos				460
	}

	Offhand0BG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				56
		tall				32
		image				HUD/lb_bg
		visible				1
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				100

		pin_to_sibling				Offhand0Icon
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	Offhand0Icon
	{
		ControlName			ImagePanel
		xpos				-200
		ypos				-16
		wide				28
		tall				28
		image				HUD/empty
		visible				0
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				450

		pin_to_sibling				SafeAreaCenter
		pin_corner_to_sibling		3
		pin_to_sibling_corner		3
	}

	Offhand0_Tutorial_Outline
	{
		ControlName			ImagePanel
		xpos				17
		ypos				3
		wide				84
		tall				50
		image				HUD/lb_rb_callout
		visible				0
		scaleImage			1
		drawColor			"255 234 0 255"

		zpos				101

		pin_to_sibling				Offhand0Icon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	Offhand0Hint
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				50
		tall				24
		labelText			"%offhand1%"
		font				HudFontSmallPlain
		visible				0
		fgcolor_override	"255 255 255 255"

		zpos				400

		pin_to_sibling				Offhand0Icon
		pin_corner_to_sibling		2
		pin_to_sibling_corner		3
	}

	Offhand0Alert
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				28
		tall				28
		image				HUD/empty
		visible				0
		scaleImage			1
		drawColor			"255 255 255 255"

		zpos				440

		pin_to_sibling				Offhand0Icon
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	Offhand0Count
	{
		ControlName			Label
		xpos				0
		ypos				-6
		wide				24
		tall				8
		visible				0
		font				HudFontSmall
		labelText			"x4"
		textAlignment		east
		fgcolor_override 	"255 255 255 180"

		zpos				460

		pin_to_sibling				Offhand0Icon
		pin_corner_to_sibling		0
		pin_to_sibling_corner		2
	}

	Offhand0Bar
	{
		ControlName			CHudProgressBar
		xpos				-2
		ypos				-2
		wide				44
		tall				4
		visible				0
		fg_image			"HUD/hud_bar_small"
		bg_image			"HUD/white"
		fgcolor_override	"255 255 255 255"
		bgcolor_override	"0 0 0 123"
		SegmentSize			64
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			2

		pin_to_sibling				Offhand0Icon
		pin_corner_to_sibling		0
		pin_to_sibling_corner		2

		zpos				460
	}

	TargetOverheadHealthBar
	{
		ControlName			CHudProgressBar
		xpos				0
		ypos				0
		wide				30
		tall				4
		visible				0
		bg_image			HUD/white
		fg_image			HUD/hud_bar
		fgcolor_override	"255 255 255 255"
		bgcolor_override	"0 0 0 123"
		SegmentSize			20
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			2
	}

	TargetOverheadDoomedHealthBar
	{
		ControlName			CHudProgressBar
		xpos				0
		ypos				0
		wide				30
		tall				4
		visible				0
		bg_image			HUD/white
		fg_image			HUD/hud_bar
		fgcolor_override	"255 128 0 255"
		bgcolor_override	"0 0 0 123"
		SegmentSize			20
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			2
	}

	TargetHealthBarSmall
	{
		ControlName			CHudProgressBar
		xpos				88
		ypos				-86
		wide				94
		tall				12
		visible				0
		bg_image			HUD/shieldbar_bg
		fg_image			HUD/target_shieldbar_health
		change_image		HUD/target_shieldbar_health_change
		fgcolor_override	"255 255 255 255"
		bgcolor_override	"255 255 255 255"
		SegmentSize			94
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			2
		ChangeStyle			1
		ChangeTime			0.25
		ChangeDir			0
		//ChangeColor			"255 128 64 255"

		zpos 200

		pin_to_sibling				SafeAreaCenter
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4
	}

	TargetHealthBarBurnCardIndicator
	{
		ControlName			ImagePanel
		xpos				120
		ypos				-96
		wide				20
		tall				20
		visible				0
		image				HUD/overhead_shieldbar_burn_card_indicator
		scaleImage			1.0

		zpos 199

		pin_to_sibling				SafeAreaCenter
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4
	}
	TargetHealthBarSubClass
	{
		ControlName			ImagePanel
		xpos				145
		ypos				-82
		wide				20
		tall				20
		visible				0
		image				HUD/overhead_shieldbar_burn_card_indicator
		scaleImage			1.0

		zpos 199

		pin_to_sibling				SafeAreaCenter
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4
	}

	TargetShieldBarSmall
	{
		ControlName			CHudProgressBar
		xpos				88
		ypos				-86
		wide				94
		tall				12
		visible				0
		fg_image			HUD/target_shieldbar_shield
		change_image		HUD/target_shieldbar_shield_change
		fgcolor_override	"255 255 255 255"
		bgcolor_override	"255 255 255 0"
		SegmentSize			94
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			2
		ChangeStyle			1
		ChangeTime			0.25
		ChangeDir			0
		//ChangeColor			"255 128 64 255"

		zpos 201

		pin_to_sibling				SafeAreaCenter
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4
	}

	TargetDoomedHealthBarSmall
	{
		ControlName			CHudProgressBar
		xpos				88
		ypos				-86
		wide				94
		tall				10
		visible				0
		bg_image			HUD/titan_doomedbar_bg
		fg_image			HUD/titan_doomedbar_fill
		fgcolor_override	"255 255 255 255"
		bgcolor_override	"255 255 255 160"
		SegmentSize			284
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			1

		pin_to_sibling				SafeAreaCenter
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4
	}

	TargetSmall_ConnectingLine
	{
		ControlName			ImagePanel
		xpos				c
		ypos				c
		wide				16
		tall				16
		visible				0
		image				HUD/flyout_line_fade
		scaleImage			1

		zpos				200
	}

	EpilogueAnchor
	{
		ControlName		Label
		xpos			0
		ypos			0
		wide			2
		tall			2
		visible			1
		font			HudFontLarge
		labelText		""
		fgcolor_override 	"255 255 255 0"
		textAlignment	center

		zpos			100

		pin_to_sibling				SafeAreaCenter
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4
	}

	EpilogueText
	{
		ControlName		Label
		xpos			0
		ypos			0
		wide			256
		tall			32
		visible			0
		font			HudFontLarge
		labelText		"#EOG_XPTYPE_CATEGORY_EPILOGUE"
		fgcolor_override 	"255 255 255 180"
		allCaps			1
		textAlignment	center

		zpos			100

		pin_to_sibling				EpilogueAnchor
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4
	}
	EpilogueBarShapeLeft
	{
		ControlName		ImagePanel
		xpos			0
		ypos			-7
		wide			80
		tall			62
		visible			0
		image			HUD/scorebar_shape_left
		scaleImage		1
		drawColor		"255 255 255 255"

		zpos			90

		pin_to_sibling				EpilogueAnchor
		pin_corner_to_sibling		5
		pin_to_sibling_corner		4
	}
	EpilogueBarBGShapeLeft
	{
		ControlName		ImagePanel
		xpos			0
		ypos			-7
		wide			80
		tall			62
		visible			0
		image			HUD/scorebar_bg_shape_left
		scaleImage		1
		drawColor		"255 255 255 255"

		zpos			80

		pin_to_sibling				EpilogueAnchor
		pin_corner_to_sibling		5
		pin_to_sibling_corner		4
	}
	EpilogueBarShapeRight
	{
		ControlName		ImagePanel
		xpos			0
		ypos			-7
		wide			80
		tall			62
		visible			0
		image			HUD/scorebar_shape_right
		scaleImage		1
		drawColor		"255 255 255 255"

		zpos			90

		pin_to_sibling				EpilogueAnchor
		pin_corner_to_sibling		7
		pin_to_sibling_corner		4
	}
	EpilogueBarBGShapeRight
	{
		ControlName		ImagePanel
		xpos			0
		ypos			-7
		wide			80
		tall			62
		visible			0
		image			HUD/scorebar_bg_shape_right
		scaleImage		1
		drawColor		"255 255 255 255"

		zpos			80

		pin_to_sibling				EpilogueAnchor
		pin_corner_to_sibling		7
		pin_to_sibling_corner		4
	}

	ObjectiveAnchor
	{
		ControlName		Label
		xpos			0
		ypos			-20
		wide			2
		tall			2
		visible			1
		font			HudFontLarge
		labelText		""
		fgcolor_override 	"255 255 255 0"
		textAlignment	center

		zpos			100

		pin_to_sibling				SafeArea
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4
	}

	ObjectiveTitle
	{
		ControlName			Label
		xpos				0
		ypos				24
		wide				400
		tall				32
		visible				0
		font				HudFontMed
		labelText			"Objective Title"
		textAlignment		center

		pin_to_sibling				ObjectiveAnchor
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4

		fgcolor_override 	"255 204 51 255"//"255 255 255 180"

		zpos				200
	}

	ObjectiveDesc
	{
		ControlName			Label
		xpos				0
		ypos				6
		wide				400
		tall				32
		visible				0
		font				HudFontSmall
		labelText			"Objective Description goes here"
		textAlignment		center

		pin_to_sibling				ObjectiveAnchor
		pin_corner_to_sibling		4
		pin_to_sibling_corner		4

		fgcolor_override 	"255 255 255 180"

		zpos				200
	}

	ObjectiveBarShapeLeft
	{
		ControlName		ImagePanel
		xpos			0
		ypos			0
		wide			128
		tall			62
		visible			0
		image			HUD/scorebar_shape_left_fat
		scaleImage		1
		drawColor		"255 255 255 255"

		zpos			90

		pin_to_sibling				ObjectiveAnchor
		pin_corner_to_sibling		5
		pin_to_sibling_corner		4
	}
	ObjectiveBarBGShapeLeft
	{
		ControlName		ImagePanel
		xpos			0
		ypos			0
		wide			128
		tall			62
		visible			0
		image			HUD/scorebar_bg_shape_left_fat
		scaleImage		1
		drawColor		"255 255 255 255"

		zpos			80

		pin_to_sibling				ObjectiveAnchor
		pin_corner_to_sibling		5
		pin_to_sibling_corner		4
	}
	ObjectiveBarShapeRight
	{
		ControlName		ImagePanel
		xpos			0
		ypos			0
		wide			128
		tall			62
		visible			0
		image			HUD/scorebar_shape_right_fat
		scaleImage		1
		drawColor		"255 255 255 255"

		zpos			90

		pin_to_sibling				ObjectiveAnchor
		pin_corner_to_sibling		7
		pin_to_sibling_corner		4
	}
	ObjectiveBarBGShapeRight
	{
		ControlName		ImagePanel
		xpos			0
		ypos			0
		wide			128
		tall			62
		visible			0
		image			HUD/scorebar_bg_shape_right_fat
		scaleImage		1
		drawColor		"255 255 255 255"

		zpos			80

		pin_to_sibling				ObjectiveAnchor
		pin_corner_to_sibling		7
		pin_to_sibling_corner		4
	}

	XPBarFill
	{
		ControlName			CHudProgressBar
		ypos				-4
		wide				340
		tall				4
		visible				0
		bg_image			HUD/black
		fg_image			HUD/xpbar_fill
		//fgcolor_override	"255 255 255 255"
		bgcolor_override	"255 255 255 127"
		SegmentSize			340
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			2

		pin_to_sibling				SafeAreaCenter
		pin_corner_to_sibling		6
		pin_to_sibling_corner		6
	}

	XPBarPastFill
	{
		ControlName			CHudProgressBar
		ypos				-4
		wide				340
		tall				4
		visible				0
		bg_image			HUD/empty
		fg_image			HUD/xpbar_pastfill
		//segment_bg_image	HUD/dpad_bg_shape
		//fgcolor_override	"0 0 255 255"
		//bgcolor_override	"255 255 255 160"
		SegmentSize			340
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			2

		zpos				105

		pin_to_sibling				SafeAreaCenter
		pin_corner_to_sibling		6
		pin_to_sibling_corner		6
	}



	LockonDetector_CenterBox
	{
		ControlName			ImagePanel
		xpos				0
		ypos				20
		wide				128
		tall				64
		visible				0
		enable				1
		image				HUD/lock_indicator_text_box
		scaleImage			1
		zpos				105

		pin_to_sibling				SafeArea
		pin_corner_to_sibling		4
		pin_to_sibling_corner		8
	}

	LockonDetector_CenterBox_Label
	{
		ControlName			Label
		xpos				0
		ypos				2
		wide				128
		tall				64
		visible				0
		font				HudFontSmall
		labelText			"SCANNING..."
		textAlignment		center
		fgcolor_override	"255 255 255 225"
		//fgcolor_override 	"64 119 163 255"  // BLUE
		//fgcolor_override 	"255 122 56 255"  // RED
		zpos				106

		pin_to_sibling 	LockonDetector_CenterBox
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	LockonDetector_ArrowForward
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				128
		tall				64
		visible				0
		enable				1
		image				HUD/lock_indicator_up
		scaleImage			1
		zpos				105

		pin_to_sibling 	LockonDetector_CenterBox
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	LockonDetector_ArrowBack
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				128
		tall				64
		visible				0
		enable				1
		image				HUD/lock_indicator_down
		scaleImage			1
		zpos				105

		pin_to_sibling 	LockonDetector_CenterBox
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	LockonDetector_ArrowLeft
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				128
		tall				64
		visible				0
		enable				1
		image				HUD/lock_indicator_left
		scaleImage			1
		zpos				105

		pin_to_sibling 	LockonDetector_CenterBox
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	LockonDetector_ArrowRight
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		wide				128
		tall				64
		visible				0
		enable				1
		image				HUD/lock_indicator_right
		scaleImage			1
		zpos				105

		pin_to_sibling 	LockonDetector_CenterBox
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	MFDEnemyMark
	{
		ControlName		ImagePanel
		xpos			0
		ypos			0
		wide			20
		tall			20
		visible			0
		image			HUD/mfd_enemy
		drawColor		"255 255 255 255"
		scaleImage		1

		zpos			110

		pin_to_sibling				ScoresGameInfoAnchor
		pin_corner_to_sibling		2
		pin_to_sibling_corner		2
	}

	MFDFriendlyMark
	{
		ControlName		ImagePanel
		xpos			0
		ypos			0
		wide			20
		tall			20
		visible			0
		image			HUD/mfd_friendly
		drawColor		"255 255 255 255"
		scaleImage		1

		zpos			110

		pin_to_sibling				MFDEnemyMark
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}

	CoopCharFrame
	{
		ControlName		ImagePanel
		xpos			0
		ypos			0
		wide			50
		tall			50
		visible			0
		image			../ui/scoreboard_imc_logo
		scaleImage		1
		drawColor		"255 255 255 255"

		zpos			102

		pin_to_sibling				GameInfoBG
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}
	CoopCharIcon
	{
		ControlName		ImagePanel
		xpos			0
		ypos			0
		wide			50
		tall			50
		visible			0
		image			HUD/coop/coop_char_brp_m
		scaleImage		1
		drawColor		"255 255 255 255"

		zpos			101

		pin_to_sibling				CoopCharFrame
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}


	ScoresCoop
	{
		ControlName			CHudProgressBar
		xpos				0
		ypos				1
		wide				105
		tall				33
		visible				0
		fg_image			HUD/coop/hud_score_strip_coop
		bg_image			HUD/coop/hud_score_strip_bg_coop
		fgcolor_override	"255 255 255 255"
		bgcolor_override	"255 255 255 128"
		SegmentSize			105
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			2

		pin_to_sibling				ScoresBG
		pin_corner_to_sibling		7
		pin_to_sibling_corner		7

		zpos 120
	}

	ScoresCoopStored
	{
		ControlName			CHudProgressBar
		xpos				0
		ypos				1
		wide				105
		tall				33
		visible				0
		fg_image			HUD/coop/hud_score_strip_coop
		bg_image			HUD/coop/hud_score_strip_bg_coop
		fgcolor_override	"255 255 255 128"
		bgcolor_override	"255 255 255 0"
		SegmentSize			105
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			2

		pin_to_sibling				ScoresCoop
		pin_corner_to_sibling		7
		pin_to_sibling_corner		7

		zpos 120
	}

	ScoresCountCoop
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				108
		tall				16
		visible				0
		font				HudFontSmallPlain
		labelText			""
		textAlignment		east
		textinsetx			10
		textinsety			0
		fgcolor_override 	"255 255 255 180"

		zpos				150

		pin_to_sibling				ScoresCoop
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	ScoresLabelCoop
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				108
		tall				16
		visible				0
		font				HudFontSmallPlain
		labelText			"#COOP_TEAM_SCORE_LABEL"
		textAlignment		west
		textinsetx			10
		textinsety			0
		fgcolor_override 	"255 255 255 180"

		zpos				150

		pin_to_sibling				ScoresCoop
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	GeneratorHealthDesc
	{
		ControlName			Label
		xpos				0
		ypos				6
		wide				198
		tall				10
		visible				0
		font				HudFontSmall
		labelText			"Shield Health: %s1"
		textAlignment		center
		allcaps				1
		fgcolor_override	"255 255 255 255"
//		bgcolor_override	"255 0 0 128"
		auto_wide_tocontents	1

		zpos				150

		pin_to_sibling				GeneratorHealthBar
		pin_corner_to_sibling		6
		pin_to_sibling_corner		4
	}

	GeneratorHealthBar
	{
		ControlName			CHudProgressBar
		xpos				0
		ypos				-2
		wide				198
		tall				17
		visible				0
		bg_image			HUD/shieldbar_bg
		fg_image			HUD/shieldbar_health
		change_image		HUD/shieldbar_health_change
		fgcolor_override	"255 255 255 255"
		bgcolor_override	"255 255 255 255"
		SegmentSize			198
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			2
		ChangeStyle			1
		ChangeTime			0.25
		ChangeDir			0

		zpos 150

		pin_to_sibling				MinimapCoop
		pin_corner_to_sibling		4
		pin_to_sibling_corner		6
	}

	GeneratorShieldBar
	{
		ControlName			CHudProgressBar
		xpos				0
		ypos				0
		wide				198
		tall				17
		visible				0
		bg_image			HUD/shieldbar_bg
		fg_image			HUD/shieldbar_shield
		change_image		HUD/shieldbar_shield_change
		segment_bg_image	HUD/titan_healthbar_segment_bg
		fgcolor_override	"255 255 255 255"
		bgcolor_override	"255 255 255 0"
		SegmentSize			198
		SegmentGap			0
		Inset				0
		Margin				0
		ProgressDirection	0
		SegmentFill			2
		ChangeStyle			1
		ChangeTime			0.25
		ChangeDir			0

		zpos 150

		pin_to_sibling				GeneratorHealthBar
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	GeneratorHealthBarDamageGlow
	{
		ControlName		ImagePanel
		xpos			0
		ypos			0
		wide			222
		tall			51
		visible			0
		image			HUD/coop/coop_generator_healthbar_damage
		scaleImage		1
		drawColor		"255 255 255 120"

		zpos			155

		pin_to_sibling				GeneratorHealthBar
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	WaveDescription
	{
		ControlName			Label
		xpos				-8
		ypos				0
		wide				190
		tall				16
		visible				0
		font				HudFontSmall
		labelText			"incoming"
		textAlignment		west
		fgcolor_override	"255 255 255 255"
//		bgcolor_override	"0 0 0 128"
//		auto_wide_tocontents	1

		zpos				1001

		pin_to_sibling				WaveDescriptionBG
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	WaveDescriptionCount
	{
		ControlName			Label
		xpos				0
		ypos				0
		wide				65
		tall				16
		visible				0
		font				HudFontSmall
		labelText			"incoming"
		textAlignment		west
		fgcolor_override	"255 255 255 255"

		zpos				1001

		pin_to_sibling				WaveDescriptionBG
		pin_corner_to_sibling		1
		pin_to_sibling_corner		1
	}

	WaveDescriptionBG
	{
		ControlName		ImagePanel
		xpos			1
		ypos			1
		wide			198
		tall			16
		visible			0
		image			HUD/shieldbar_bg
		scaleImage		1
		drawColor		"255 255 255 255"

		zpos			-1

		pin_to_sibling				GeneratorHealthBar
		pin_corner_to_sibling		4
		pin_to_sibling_corner		6
	}


	TD_wave_enemy_icon0
	{
		ControlName			ImagePanel
		xpos				2
		ypos				1
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_titan_burn
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				WaveDescription
		pin_corner_to_sibling		0
		pin_to_sibling_corner		2
	}
	TD_wave_enemy_text0
	{
		ControlName			Label
		xpos				0
		ypos				-10
		zpos				1001
		wide				32
		tall				16
		visible				0
		font				HudFontTiny
		labelText			"x 23"
		drawColor			"255 255 255 255"

		pin_to_sibling				TD_wave_enemy_icon0
		pin_corner_to_sibling		0
		pin_to_sibling_corner		6
	}

	TD_wave_enemy_icon1
	{
		ControlName			ImagePanel
		xpos				9
		ypos				0
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_titan_burn
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				TD_wave_enemy_icon0
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}
	TD_wave_enemy_text1
	{
		ControlName			Label
		xpos				0
		ypos				-10
		zpos				1001
		wide				32
		tall				16
		visible				0
		font				HudFontTiny
		labelText			"x 23"
		drawColor			"255 255 255 255"

		pin_to_sibling				TD_wave_enemy_icon1
		pin_corner_to_sibling		0
		pin_to_sibling_corner		6
	}

	TD_wave_enemy_icon2
	{
		ControlName			ImagePanel
		xpos				9
		ypos				0
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_titan_burn
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				TD_wave_enemy_icon1
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}
	TD_wave_enemy_text2
	{
		ControlName			Label
		xpos				0
		ypos				-10
		zpos				1001
		wide				32
		tall				16
		visible				0
		font				HudFontTiny
		labelText			"x 23"
		drawColor			"255 255 255 255"

		pin_to_sibling				TD_wave_enemy_icon2
		pin_corner_to_sibling		0
		pin_to_sibling_corner		6
	}
	TD_wave_enemy_icon3
	{
		ControlName			ImagePanel
		xpos				10
		ypos				0
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_titan_burn
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				TD_wave_enemy_icon2
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}
	TD_wave_enemy_text3
	{
		ControlName			Label
		xpos				0
		ypos				-10
		zpos				1001
		wide				32
		tall				16
		visible				0
		font				HudFontTiny
		labelText			"x 23"
		drawColor			"255 255 255 255"

		pin_to_sibling				TD_wave_enemy_icon3
		pin_corner_to_sibling		0
		pin_to_sibling_corner		6
	}

	TD_wave_enemy_icon4
	{
		ControlName			ImagePanel
		xpos				10
		ypos				0
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_titan_burn
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				TD_wave_enemy_icon3
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}
	TD_wave_enemy_text4
	{
		ControlName			Label
		xpos				0
		ypos				-10
		zpos				1001
		wide				32
		tall				16
		visible				0
		font				HudFontTiny
		labelText			"x 23"
		drawColor			"255 255 255 255"

		pin_to_sibling				TD_wave_enemy_icon4
		pin_corner_to_sibling		0
		pin_to_sibling_corner		6
	}

	TD_wave_enemy_icon5
	{
		ControlName			ImagePanel
		xpos				10
		ypos				0
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_titan_burn
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				TD_wave_enemy_icon4
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}
	TD_wave_enemy_text5
	{
		ControlName			Label
		xpos				0
		ypos				-10
		zpos				1001
		wide				32
		tall				16
		visible				0
		font				HudFontTiny
		labelText			"x 23"
		drawColor			"255 255 255 255"

		pin_to_sibling				TD_wave_enemy_icon5
		pin_corner_to_sibling		0
		pin_to_sibling_corner		6
	}

	TD_wave_enemy_icon6
	{
		ControlName			ImagePanel
		xpos				10
		ypos				0
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_titan_burn
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				TD_wave_enemy_icon5
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}
	TD_wave_enemy_text6
	{
		ControlName			Label
		xpos				0
		ypos				-10
		zpos				1001
		wide				32
		tall				16
		visible				0
		font				HudFontTiny
		labelText			"x 23"
		drawColor			"255 255 255 255"

		pin_to_sibling				TD_wave_enemy_icon6
		pin_corner_to_sibling		0
		pin_to_sibling_corner		6
	}

	TD_wave_enemy_icon7
	{
		ControlName			ImagePanel
		xpos				10
		ypos				0
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_titan_burn
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				TD_wave_enemy_icon6
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}
	TD_wave_enemy_text7
	{
		ControlName			Label
		xpos				0
		ypos				-10
		zpos				1001
		wide				32
		tall				16
		visible				0
		font				HudFontTiny
		labelText			"x 23"
		drawColor			"255 255 255 255"

		pin_to_sibling				TD_wave_enemy_icon7
		pin_corner_to_sibling		0
		pin_to_sibling_corner		6
	}

	TD_wave_enemy_icon8
	{
		ControlName			ImagePanel
		xpos				10
		ypos				0
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_titan_burn
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				TD_wave_enemy_icon7
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}
	TD_wave_enemy_text8
	{
		ControlName			Label
		xpos				0
		ypos				-10
		zpos				1001
		wide				32
		tall				16
		visible				0
		font				HudFontTiny
		labelText			"x 23"
		drawColor			"255 255 255 255"

		pin_to_sibling				TD_wave_enemy_icon8
		pin_corner_to_sibling		0
		pin_to_sibling_corner		6
	}

	Player_Status_BG
	{
		ControlName		ImagePanel
		xpos			-20
		ypos			0
		wide			117
		tall			66
		visible			0
		image			HUD/hud_hex_8v8_bg_left
		drawColor		"255 255 255 255"
		scaleImage		1

		zpos			90

		pin_to_sibling				GameInfoBG
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	Friendly_Player_Status_0
	{
		ControlName			ImagePanel
		xpos				2
		ypos				-2
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_pilot_friendly
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				ScoresFriendly
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	Friendly_Player_Status_1
	{
		ControlName			ImagePanel
		xpos				-4
		ypos				0
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_pilot_friendly
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Friendly_Player_Status_0
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	Friendly_Player_Status_2
	{
		ControlName			ImagePanel
		xpos				-4
		ypos				0
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_pilot_friendly
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Friendly_Player_Status_1
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	Friendly_Player_Status_3
	{
		ControlName			ImagePanel
		xpos				-4
		ypos				0
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_pilot_friendly
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Friendly_Player_Status_2
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	Friendly_Player_Status_4
	{
		ControlName			ImagePanel
		xpos				-4
		ypos				0
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_pilot_friendly
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Friendly_Player_Status_3
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	Friendly_Player_Status_5
	{
		ControlName			ImagePanel
		xpos				-4
		ypos				0
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_pilot_friendly
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Friendly_Player_Status_4
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	Friendly_Player_Status_6
	{
		ControlName			ImagePanel
		xpos				-4
		ypos				0
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_pilot_friendly
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Friendly_Player_Status_5
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	Friendly_Player_Status_7
	{
		ControlName			ImagePanel
		xpos				-4
		ypos				0
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_pilot_friendly
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Friendly_Player_Status_6
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	Friendly_Player_Status_0_Burncard_BG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				980
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_burncard_friendly
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Friendly_Player_Status_0
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	Friendly_Player_Status_1_Burncard_BG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				980
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_burncard_friendly
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Friendly_Player_Status_1
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	Friendly_Player_Status_2_Burncard_BG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				980
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_burncard_friendly
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Friendly_Player_Status_2
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}


	Friendly_Player_Status_3_Burncard_BG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				980
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_burncard_friendly
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Friendly_Player_Status_3
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}


	Friendly_Player_Status_4_Burncard_BG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				980
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_burncard_friendly
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Friendly_Player_Status_4
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}


	Friendly_Player_Status_5_Burncard_BG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				980
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_burncard_friendly
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Friendly_Player_Status_5
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	Friendly_Player_Status_6_Burncard_BG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				980
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_burncard_friendly
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Friendly_Player_Status_6
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	Friendly_Player_Status_7_Burncard_BG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				980
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_burncard_friendly
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Friendly_Player_Status_7
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	Enemy_Player_Status_0
	{
		ControlName			ImagePanel
		xpos				2
		ypos				-2
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_pilot_enemy
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				ScoresEnemy
		pin_corner_to_sibling		2
		pin_to_sibling_corner		2
	}

	Enemy_Player_Status_1
	{
		ControlName			ImagePanel
		xpos				-4
		ypos				0
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_pilot_enemy
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Enemy_Player_Status_0
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	Enemy_Player_Status_2
	{
		ControlName			ImagePanel
		xpos				-4
		ypos				0
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_pilot_enemy
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Enemy_Player_Status_1
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	Enemy_Player_Status_3
	{
		ControlName			ImagePanel
		xpos				-4
		ypos				0
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_pilot_enemy
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Enemy_Player_Status_2
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	Enemy_Player_Status_4
	{
		ControlName			ImagePanel
		xpos				-4
		ypos				0
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_pilot_enemy
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Enemy_Player_Status_3
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	Enemy_Player_Status_5
	{
		ControlName			ImagePanel
		xpos				-4
		ypos				0
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_pilot_enemy
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Enemy_Player_Status_4
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	Enemy_Player_Status_6
	{
		ControlName			ImagePanel
		xpos				-4
		ypos				0
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_pilot_enemy
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Enemy_Player_Status_5
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	Enemy_Player_Status_7
	{
		ControlName			ImagePanel
		xpos				-4
		ypos				0
		zpos				1000
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_pilot_enemy
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Enemy_Player_Status_6
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	Enemy_Player_Status_0_Burncard_BG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				980
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_burncard_enemy
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Enemy_Player_Status_0
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	Enemy_Player_Status_1_Burncard_BG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				980
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_burncard_enemy
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Enemy_Player_Status_1
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	Enemy_Player_Status_2_Burncard_BG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				980
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_burncard_enemy
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Enemy_Player_Status_2
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	Enemy_Player_Status_3_Burncard_BG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				980
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_burncard_enemy
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Enemy_Player_Status_3
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	Enemy_Player_Status_4_Burncard_BG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				980
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_burncard_enemy
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Enemy_Player_Status_4
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	Enemy_Player_Status_5_Burncard_BG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				980
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_burncard_enemy
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Enemy_Player_Status_5
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	Enemy_Player_Status_6_Burncard_BG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				980
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_burncard_enemy
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Enemy_Player_Status_6
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	Enemy_Player_Status_7_Burncard_BG
	{
		ControlName			ImagePanel
		xpos				0
		ypos				0
		zpos				980
		wide				14
		tall				14
		visible				0
		image				../ui/icon_status_burncard_enemy
		scaleImage			1
		drawColor			"255 255 255 255"

		pin_to_sibling				Enemy_Player_Status_7
		pin_corner_to_sibling		0
		pin_to_sibling_corner		0
	}

	//temp
	//{
	//	ControlName			ImagePanel
	//	image				HUD/white
	//	visible				1
	//	enable				1
	//	scaleImage			1
	//	wide				%100
	//	tall				%100
	//	xpos				0
	//	ypos				0
	//	zpos				-3000
	//	drawColor			"146 159 164 255"
	//}

	RankedPlayGoal
	{
		ControlName		Label
		xpos			0
		ypos			0
		wide			100
		tall			24
		visible			0
		font			HudFontMed
		labelText		"#HUD_PRESS_FOR_ANTI_TITAN_WEAPON"
		auto_wide_tocontents 1
		textAlignment	center
		fgcolor_override 	"255 255 255 255"

		pin_to_sibling				Screen
		pin_corner_to_sibling		8
		pin_to_sibling_corner		8
	}

	Coop_TeamScoreEventNotification_0
	{
		ControlName			CNestedPanel
		ypos				11
		xpos				55
		wide				256
		tall				32

		controlSettingsFile			"scripts/screens/Coop_TeamScoreEventNotification.res"

		pin_to_sibling				GameInfoBG
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}

	Coop_TeamScoreEventNotification_1
	{
		ControlName			CNestedPanel
		ypos				35
		xpos				55
		wide				256
		tall				32

		controlSettingsFile			"scripts/screens/Coop_TeamScoreEventNotification.res"

		pin_to_sibling				GameInfoBG
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}
}
