///////////////////////////////////////////////////////////
// Tracker scheme resource file
//
// sections:
//		Colors			- all the colors used by the scheme
//		BaseSettings	- contains settings for app to use to draw controls
//		Fonts			- list of all the fonts used by app
//		Borders			- description of all the borders
//
///////////////////////////////////////////////////////////
Scheme
{
	//////////////////////// COLORS ///////////////////////////
	// color details
	// this is a list of all the colors used by the scheme
	Colors
	{
		// base colors
		Orange								"178 82 22 255"
		OrangeDim							"178 82 22 120"
		LightOrange							"188 112 0 128"
		GoalOrange							"255 133 0"
		White								"235 235 235 255"
		Red									"192 28 0 140"
		RedSolid							"192 28 0 255"
		Blue								"0 28 162 140"
		Yellow								"251 235 202 255"
		TransparentYellow					"251 235 202 140"
		//Black								"0 0 0 255"
		Black								"46 43 42 255" //Changed black to a NTSC safe color
		TransparentBlack					"0 0 0 196"
		TransparentLightBlack				"0 0 0 90"
		FooterBGBlack						"52 48 55 255"
		HUDBlueTeam							"104 124 155 127"
		HUDRedTeam							"180 92 77 127"
		HUDSpectator						"124 124 124 127"
		HUDBlueTeamSolid					"104 124 155 255"
		HUDRedTeamSolid						"180 92 77 255"
		HUDDeathWarning						"255 0 0 255"
		HudWhite							"255 255 255 255"
		HudOffWhite							"200 187 161 255"
		Gray								"178 178 178 255"
		Blank								"0 0 0 0"
		ForTesting							"255 0 0 32"
		ForTesting_Magenta					"255 0 255 255"
		ForTesting_MagentaDim				"255 0 255 120"
		HudPanelForeground					"123 110 59 184"
		HudPanelBackground					"123 110 59 184"
		HudPanelBorder						"255 255 255 102"
		HudProgressBarActive				"240 207 78 255"
		HudProgressBarInActive				"140 120 73 255"
		HudProgressBarActiveLow				"240 30 30 255"
		HudProgressBarInActiveLow			"240 30 30 99"
		HudTimerProgressActive				"251 235 202 255"
		HudTimerProgressInActive			"52 48 45 255"
		HudTimerProgressWarning				"240 30 30 255"
		TanDark								"117 107 94 255"
		TanLight							"235 226 202 255"
		TanDarker							"46 43 42 255"
		LowHealthRed						"255 0 0 255"
		ProgressOffWhite					"251 235 202 255"
		ProgressBackground					"250 234 201 51"
		HealthBgGrey						"72 71 69 255"
		ProgressOffWhiteTransparent			"251 235 202 128"
		LabelDark							"48 43 42 255"
		LabelTransparent					"109 96 80 180"
		BuildMenuActive						"248 231 198 255"
		DisguiseMenuIconRed					"192 56 63 255"
		DisguiseMenuIconBlue				"92 128 166 255"
 		MatchmakingDialogTitleColor			"200 184 151 255"
 		MatchmakingMenuItemBackground		"46 43 42 255"
 		MatchmakingMenuItemBackgroundActive	"150 71 0 255"
		MatchmakingMenuItemTitleColor		"200 184 151 255"
		MatchmakingMenuItemDescriptionColor	"200 184 151 255"
		HTMLBackground						"95 92 101 255"
		QualityColorNormal					"178 178 178 255"
		QualityColorrarity1					"77 116 85 255"
		QualityColorrarity2					"141 131 75 255"
		QualityColorrarity3					"207 106 50 255"
		QualityColorrarity4					"134 80 172 255"
		QualityColorVintage					"71 98 145 255"
		QualityColorUnique					"255 215 0 255"
		QualityColorCommunity				"112 176 74 255"
		QualityColorDeveloper				"165 15 121 255"
		QualityColorSelfMade				"112 176 74 255"
		QualityColorCustomized				"71 98 145 255"
		QualityColorStrange					"205 155 29 255"
	}

	///////////////////// BASE SETTINGS ////////////////////////
	// default settings for all panels
	// controls use these to determine their settings
	BaseSettings
	{
		Label.TextDullColor					TanDark
		Label.TextColor						TanLight
		Label.TextBrightColor				TanLight
		Label.SelectedTextColor				White
		Label.BgColor						Blank
		Label.DisabledFgColor1				Blank
		Label.DisabledFgColor2				"255 255 225 255"

		Rosette.DefaultFgColor				White
		Rosette.DefaultBgColor				Blank
		Rosette.ArmedBgColor				Blank
		Rosette.DisabledBgColor				Blank
		Rosette.DisabledBorderColor			Blank
		Rosette.LineColor					"192 192 192 128"
		Rosette.DrawBorder					1
		Rosette.DefaultFont					DefaultSmall
		Rosette.ArmedFont					Default

		Frame.TopBorderImage				"vgui/menu_backgroud_top"
		Frame.BottomBorderImage				"vgui/menu_backgroud_bottom"
		Frame.SmearColor					"0 0 0 225"		[$X360]
		Frame.SmearColor					"0 0 0 180"		[$WIN32]

		FgColor								"248 255 248 200"
		BgColor								"39 63 82 0"

		Panel.FgColor						"248 255 248 200"
		Panel.BgColor						"39 63 82 0"

		BrightFg							"255 255 255 128"

		DamagedBg							"180 0 0 200"
		DamagedFg							"180 0 0 230"
		BrightDamagedFg						"255 0 0 255"

		YellowBg							"180 113 0 200"
		YellowFg							"180 113 0 230"
		BrightYellowFg						"255 160 0 255"

		// checkboxes and radio buttons
		BaseText							OffWhite
		BrightControlText					White
		CheckBgColor						TransparentBlack
		CheckButtonBorder1 					Border.Dark 		// the left checkbutton border
		CheckButtonBorder2  				Border.Bright		// the right checkbutton border
		CheckButtonCheck					White				// color of the check itself

		// weapon selection colors
		SelectionNumberFg					"255 255 225 255"
		SelectionTextFg						"255 255 225 255"
		SelectionEmptyBoxBg 				"0 0 0 80"
		SelectionBoxBg 						"0 0 0 80"
		SelectionSelectedBoxBg 				"0 0 0 80"

		// HL1-style QuickHUD colors
		Yellowish							"255 160 0 255"
		Normal								"255 255 225 128"
		Caution								"255 48 0 255"

		// Top-left corner of the "Half-Life 2" on the main screen
		Main.Title1.X						32
		Main.Title1.Y						280
		Main.Title1.Y_hidef					130
		Main.Title1.Color					"255 255 255 0"

		// Top-left corner of secondary title e.g. "DEMO" on the main screen
		Main.Title2.X						76
		Main.Title2.Y						190
		Main.Title2.Y_hidef					174
		Main.Title2.Color					"255 255 255 0"

		// Top-left corner of the menu on the main screen
		Main.Menu.X							32
		Main.Menu.X_hidef					76
		Main.Menu.Y							340
		Main.Menu.Color						"168 97 64 255"
		Menu.TextColor						"0 0 0 255"
		Menu.BgColor						"125 125 125 255"

		// Blank space to leave beneath the menu on the main screen
		Main.BottomBorder					32

		ScrollBar.Wide						12

		ScrollBarButton.FgColor				Black
		ScrollBarButton.BgColor				Blank
		ScrollBarButton.ArmedFgColor		White
		ScrollBarButton.ArmedBgColor		Blank
		ScrollBarButton.DepressedFgColor	White
		ScrollBarButton.DepressedBgColor	Blank

		ScrollBarSlider.FgColor				"0 0 0 255"			// nob color
		ScrollBarSlider.BgColor				"0 0 0 40"			// slider background color
		ScrollBarSlider.NobFocusColor		White
		ScrollBarSlider.NobDragColor		White
		ScrollBarSlider.Inset				3
		
		"ItemColor"		"255 167 42 200"	// default 255 167 42 255
		"MenuColor"		"233 208 173 255"
		"MenuBoxBg"		"0 0 0 100"
	}

	//////////////////////// FONTS /////////////////////////////
	// describes all the fonts

	BitmapFontFiles
	{
		ControllerButtons		"materials/vgui/fonts/controller_buttons.vbf"			[$DURANGO]
		ControllerButtons		"materials/vgui/fonts/controller_buttons_xbox360.vbf"	[!$DURANGO]
	}
	Fonts
	{
		// fonts are used in order that they are listed
		// fonts listed later in the order will only be used if they fulfill a range not already filled
		// if a font fails to load then the subsequent fonts will replace

		DebugFixed
		{
			1
			{
				name		"Lucida Console"
				tall		14
				antialias 	1
			}
		}

		DebugFixedSmall
		{
			1
			{
				name		"Lucida Console"
				tall		14
				antialias 	1
			}
		}

		DebugOverlay
		{
			1
			{
				name		"Lucida Console"
				tall		14
				antialias 	1
				outline		1
			}
		}

		DebugBoldOutline
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		20	// Some values of tall don't work with 'outline' on Durango, please leave this value at 20
				antialias	1
				outline		1
			}
		}

		Default [!$GAMECONSOLE]
		{
			1
			{
				name		"Tahoma"
				tall		9
				weight		700
				antialias 	1
			}
		}

		Default [$GAMECONSOLE]
		{
			1
			{
				name		"Tahoma"
				tall		14
				weight		900
				antialias 	1
			}
		}

		DefaultSmall
		{
			1
			{
				name		"Tahoma"
				tall		12
				weight		0
				range		"0x0000 0x017F"
				yres		"480 599"
			}
			2
			{
				name		"Tahoma"
				tall		13
				weight		0
				range		"0x0000 0x017F"
				yres		"600 767"
			}
			3
			{
				name		"Tahoma"
				tall		14
				weight		0
				range		"0x0000 0x017F"
				yres		"768 1023"
				antialias	1
			}
			4
			{
				name		"Tahoma"
				tall		20
				weight		0
				range		"0x0000 0x017F"
				yres		"1024 1199"
				antialias	1
			}
			5
			{
				name		"Tahoma"
				tall		24
				weight		0
				range		"0x0000 0x017F"
				yres		"1200 6000"
				antialias	1
			}
			6
			{
				name		"Tahoma"
				tall		12
				range 		"0x0000 0x00FF"
				weight		0
			}
		}

		DefaultVerySmall
		{
			1
			{
				name		"Tahoma"
				tall		12
				weight		0
				range		"0x0000 0x017F" //	Basic Latin, Latin-1 Supplement, Latin Extended-A
				yres		"480 599"
			}
			2
			{
				name		"Tahoma"
				tall		13
				weight		0
				range		"0x0000 0x017F" //	Basic Latin, Latin-1 Supplement, Latin Extended-A
				yres		"600 767"
			}
			3
			{
				name		"Tahoma"
				tall		14
				weight		0
				range		"0x0000 0x017F" //	Basic Latin, Latin-1 Supplement, Latin Extended-A
				yres		"768 1023"
				antialias	1
			}
			4
			{
				name		"Tahoma"
				tall		20
				weight		0
				range		"0x0000 0x017F" //	Basic Latin, Latin-1 Supplement, Latin Extended-A
				yres		"1024 1199"
				antialias	1
			}
			5
			{
				name		"Tahoma"
				tall		24
				weight		0
				range		"0x0000 0x017F" //	Basic Latin, Latin-1 Supplement, Latin Extended-A
				yres		"1200 6000"
				antialias	1
			}
			6
			{
				name		"Tahoma"
				tall		12
				range 		"0x0000 0x00FF"
				weight		0
			}
			7
			{
				name		"Tahoma"
				tall		11
				range 		"0x0000 0x00FF"
				weight		0
			}
		}

		HudNumbers
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		64
				antialias	1
				additive	1
			}
		}

		HudNumbersGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		64
				weight		0
				blur		2
				scanlines	2
				antialias 	1
				additive	1
			}
		}

		HudNumbersSmall
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		32
				weight		1000
				additive	1
				antialias 	1
			}
		}

		HudNumbersTiny
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		16
				weight		1000
				additive	1
				antialias 	1
			}
		}

		HudNumbersTinyGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		16
				weight		1000
				antialias	1
  				blur		2
  				additive	1
				scanlines	2
			}
		}

		HudSelectionNumbers
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		11
				weight		700
				antialias 	1
				additive	1
			}
		}

		HudHintText
		{
			1
			{
				name		"ConduitITCPro-Medium"
				tall		14
				weight		1000
				antialias 	1
				additive	1
			}
		}

		HudHintTextLarge
		{
			1
			{
				name		"ConduitITCPro-Medium"
				tall		14
				weight		1000
				antialias 	1
				additive	1
			}
		}

		HudHintTextSmall
		{
			1
			{
				name		"ConduitITCPro-Medium"
				tall		11
				weight		0
				antialias 	1
				additive	1
			}
		}

		// this is the symbol font
		Marlett
		{
			1
			{
				name		"Marlett"
				tall		14
				weight		0
				symbol		1
			}
		}

		CenterPrint
		{
			1
			{
				name		ConduitITCPro-Medium
				tall		24
				weight		900
				antialias 	1
				additive	1
			}
		}

		LargeHUDTitle
		{
			1
			{
				name		ConduitITCPro-Medium
				tall		20
				antialias 	1
			}
		}

		XpText
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		20
				antialias	1
			}
		}

		PlayerNames
		{
			1
			{
				name		"ConduitITCPro-Medium"
				tall		18
				weight		100
				antialias	1
				shadowglow	4
			}
		}

		KillShot
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		25
				antialias	1
			}
		}

		GameUIButtons
		{
			1
			{
				bitmap		1
				name		"ControllerButtons"
				scalex		0.375
				scaley		0.375
			}
		}

		HUDPrompt
		{
			1
			{
				name		"ConduitITCPro-Medium"
				tall		20
				antialias	1
				shadowglow		3
			}
		}

		KillShotGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		25
				weight		0
				antialias	1
	  			blur		2
  				additive	1
				scanlines	2
			}
		}

		AiKillShot
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		13
				antialias	1
			}
		}

		BigKillShot
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		25
				antialias	1
				outline		1
			}
		}

		WinScreenFont
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		64
				antialias	1
			}
		}

		WinScreenFontGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		64
				antialias	1
				additive	1
  				blur		2
			}
		}

		OperatorCooldown
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		25
				antialias	1
			}
		}

		OperatorCooldownGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		25
				weight		0
				antialias	1
  				blur		2
	  			additive	1
				scanlines	2
			}
		}

		OperatorCost
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		15
				antialias	1
			}
		}

		OperatorCostGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		15
				weight		0
				antialias	1
  				blur		2
	  			additive	1
				scanlines	2
			}
		}

		OperatorSelection
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		15
				antialias	1
			}
		}

		OperatorSelectionGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		15
				weight		0
				antialias	1
  				blur		2
  				additive	1
				scanlines	2
			}
		}

		ScoreSplash
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		14
				antialias	1
			}
		}

		ScoreSplashGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		14
				weight		0
				antialias	1
  				blur		2
  				additive	1
				scanlines	2
			}
		}

		ScoreSplashSmall
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		12
				antialias	1
			}
		}

		ScoreSplashSmallGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		12
				weight		0
				antialias	1
  				blur		2
  				additive	1
				scanlines	2
			}
		}

		ScoreSplashTotal
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		33
				antialias	1
				additive	1
			}
		}

		ScoreSplashTotalGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		33
				weight		0
				antialias	1
  				blur		2
	  			additive	1
			}
		}

		MPObituary
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		12
				antialias	1
			}
		}

		MPObituaryGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		12
				weight		0
				antialias	1
  				blur		2
	  			additive	1
				scanlines	2
			}
		}

		MPDeathNotice
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		16
				antialias	1
			}
		}

		MPDeathNoticeGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		16
				weight		0
				antialias	1
  				blur		2
  				additive	1
				scanlines	2
			}
		}

		CapturePointWorldOverlay
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		100
				antialias	1
				additive	1
			}
		}

		CapturePointWorldOverlayGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		100
				weight		0
				antialias	1
  				blur		2
	  			additive	1
			}
		}

		CapturePointDistance
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		12
				antialias	1
			}
		}

		CapturePointDistanceGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		12
				weight		0
				antialias	1
	  			blur		2
  				additive	1
				scanlines	2
			}
		}

		CapturePointStatusHUD
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		20
				antialias	1
			}
		}

		CapturePointStatusHUDGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		20
				weight		0
				antialias	1
  				blur		2
  				additive	1
				scanlines	2
			}
		}

		CapturePointEnemyCount
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		13
				antialias	1
			}
		}

		CapturePointName
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		15
				antialias	1
			}
		}

		CapturePointNameGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		15
				weight		0
				antialias	1
  				blur		2
  				additive	1
				scanlines	2
			}
		}

		MPScoreBarLarge
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		16
				antialias	1
			}
		}

		MPScoreBarLargeGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		16
				weight		0
				antialias	1
  				blur		2
	  			additive	1
				scanlines	2
			}
		}

		MPScoreBarSmall
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		11
				antialias	1
			}
		}

		MPScoreBarSmallGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		11
				weight		0
				antialias	1
	  			blur		2
  				additive	1
				scanlines	2
			}
		}

		TitanHUD
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		20
				antialias	1
			}
		}

		TitanHUDGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		20
				weight		0
				antialias	1
  				blur		2
  				additive	1
				scanlines	2
			}
		}

		TitanHUDSmall
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		12
				antialias	1
			}
		}

		TitanHUDSmallGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		12
				weight		0
				antialias	1
	  			blur		2
  				additive	1
				scanlines	2
			}
		}

		OperatorAbilityName
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		12
				antialias	1
			}
		}

		OperatorAbilityNameGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		12
				weight		0
				antialias	1
  				blur		2
  				additive	1
				scanlines	2
			}
		}

		SmartPistolStatus
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		12
				antialias	1
			}
		}

		SmartPistolStatusGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		12
				weight		0
				antialias	1
  				blur		2
  				additive	1
				scanlines	2
			}
		}

		ObjectiveTitle
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		30
				antialias	1
			}
		}

		ObjectiveTitleGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		30
				weight		0
				antialias	1
  				blur		2
  				additive	1
				scanlines	2
			}
		}

		ObjectiveDesc
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		22
				antialias	1
			}
		}

		ObjectiveDescGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		22
				weight		0
				antialias	1
  				blur		2
  				additive	1
				scanlines	2
			}
		}

		ObjectiveDistance
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		20
				antialias	1
			}
		}

		ObjectiveDistanceGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		20
				weight		0
				antialias	1
	  			blur		2
  				additive	1
				scanlines	2
			}
		}

		FlyoutTitle
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		19
				antialias	1
			}
		}

		FlyoutTitleGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		19
				weight		0
				antialias	1
  				blur		2
  				additive	1
				scanlines	2
			}
		}

		FlyoutDescription
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		15
				antialias	1
			}
		}

		FlyoutDescriptionGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		15
				weight		0
				antialias	1
  				blur		2
  				additive	1
				scanlines	2
			}
		}

		SuperBarHUDName
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		22
				antialias	1
			}
		}

		SuperBarHUDNameGlow
		{
			1
			{
				name		"ConduitITCPro-Bold"
				tall		22
				weight		0
				antialias	1
  				blur		2
  				additive	1
				scanlines	2
			}
		}
	}

	//////////////////// BORDERS //////////////////////////////
	// describes all the border types
	Borders
	{
	}

	//////////////////////// CUSTOM FONT FILES /////////////////////////////
	// specifies all the custom (non-system) font files that need to be loaded to service the above described fonts
	CustomFontFiles
	{
		1		"resource/ConduitITCPro-Medium.vfont"
		2		"resource/ConduitITCPro-Bold.vfont"
		3 		"resource/PFDinTextCondPro-Light.vfont"
		4 		"resource/PFDinTextCondPro-Medium.vfont"
		5 		"resource/arialuni.vfont" [$WINDOWS]
	}

	FontRemap
	{
		"ConduitITCPro-Medium"	"PFDinTextCondPro-Light" [$RUSSIAN]
		"ConduitITCPro-Bold"	"PFDinTextCondPro-Medium" [$RUSSIAN]

		"ConduitITCPro-Medium"	"arial unicode ms" [$JAPANESE || $KOREAN || $TCHINESE]
		"ConduitITCPro-Bold"	"arial unicode ms" [$JAPANESE || $KOREAN || $TCHINESE]

		// Dev only fonts
		"Tahoma"				"ConduitITCPro-Medium" [$GAMECONSOLE]
		"Lucida Console"		"ConduitITCPro-Medium" [$GAMECONSOLE]
	}
}

