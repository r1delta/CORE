"Resource/UI/HudScoreboard.res"
{
	Screen
	{
		ControlName		ImagePanel
		wide			%100
		tall			%100
		visible			1
		scaleImage		1
		fillColor		"0 0 0 0"
		drawColor		"0 0 0 0"
	}

	// Main header

	ScoreboardBackground
	{
		ControlName				ImagePanel
		pin_to_sibling			Screen
		pin_corner_to_sibling	8
		pin_to_sibling_corner	8
		zpos					1008
		wide					700
		tall					338
		image					"../ui/menu/scoreboard/scoreboard"
		visible					0
		scaleImage				1
	}

	ScoreboardHeaderBackground
	{
		ControlName				Label
		pin_to_sibling			ScoreboardBackground
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
		zpos					1010
		wide					700
		tall					78
		visible					0
		labelText				""
		//bgcolor_override 		"255 127 127 127"
	}

	ScoreboardGametypeAndMap
	{
		ControlName				Label
		pin_to_sibling			ScoreboardHeaderBackground
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
		xpos 					-9
		ypos					-7
		zpos					1012
		auto_wide_tocontents	1
		auto_tall_tocontents	1
		visible					1
		font					ScoreboardTitleFont
		labelText				""
		allcaps					1
		fgcolor_override	 	"204 234 255 255"
		//bgcolor_override 		"255 0 0 127"
	}
	ScoreboardHeaderGametypeDesc
	{
		ControlName				Label
		pin_to_sibling			ScoreboardGametypeAndMap
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
		ypos					-2
		zpos					1012
		auto_wide_tocontents	1
		auto_tall_tocontents	1
		visible					1
		font					ScoreboardFont
		labelText				"SOME OTHER TEXT"
		allcaps					1
		fgcolor_override	 	"204 234 255 255"
		//bgcolor_override 		"0 255 0 127"
	}
	ScoreboardLossProtection
	{
		ControlName				Label
		pin_to_sibling			ScoreboardHeaderGametypeDesc
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
		ypos					9
		zpos					1012
		auto_wide_tocontents	1
		auto_tall_tocontents	1
		visible					1
		font					ScoreboardColumnHeaderFont
		labelText				"#LATE_JOIN_NO_LOSS"
		allcaps					1
		fgcolor_override	 	"211 171 8 255"
	}

	// Connection column label and icon
	ConnectionColumnLabel
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnHeader
		pin_to_sibling			ScoreboardHeaderBackground
		pin_corner_to_sibling	3
		pin_to_sibling_corner	3
		xpos 					-5
		visible					1
		labelText				"#SCOREBOARD_CONNECTION"	[$GAMECONSOLE]
		labelText				"#SCOREBOARD_PING"			[!$GAMECONSOLE]
		fgcolor_override 		"155 178 194 255"
		//bgcolor_override 		"0 250 255 127"
	}
	ConnectionColumnIconBackground
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnIconBackground
		pin_to_sibling			ConnectionColumnLabel
		pin_corner_to_sibling	6
		pin_to_sibling_corner	4
		visible					1
	}
	ConnectionColumnIcon
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardColumnIcon
		pin_to_sibling			ConnectionColumnIconBackground
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
		visible					1
		image					"../ui/menu/scoreboard/sb_icon_ping"
		drawColor				"255 255 255 127"
	}
	//ConnectionColumnHeaderIcon
	//{
	//	ControlName				ImagePanel
	//	InheritProperties 		ScoreboardColumnConnection
	//	pin_to_sibling			ConnectionColumnLabel
	//	pin_corner_to_sibling	8
	//	pin_to_sibling_corner	8
	//	visible					1
	//	image					"../ui/menu/scoreboard/connection_quality_header"
	//	drawColor 				"155 178 194 255"
	//}

	// Data column labels
	ScoreboardColumnLabels6
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnHeader
		pin_to_sibling			ConnectionColumnLabel
		pin_corner_to_sibling	3
		pin_to_sibling_corner	2
		xpos 					1
		labelText				"[Column 6]"
		//bgcolor_override 		"255 255 0 127"
	}
	ScoreboardColumnLabels5
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnHeader
		pin_to_sibling			ScoreboardColumnLabels6
		pin_corner_to_sibling	3
		pin_to_sibling_corner	2
		xpos					1
		labelText				"[Column 5]"
		//bgcolor_override 		"255 255 0 127"
	}
	ScoreboardColumnLabels4
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnHeader
		pin_to_sibling			ScoreboardColumnLabels5
		pin_corner_to_sibling	3
		pin_to_sibling_corner	2
		xpos					1
		labelText				"[Column 4]"
		//bgcolor_override 		"255 255 0 127"
	}
	ScoreboardColumnLabels3
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnHeader
		pin_to_sibling			ScoreboardColumnLabels4
		pin_corner_to_sibling	3
		pin_to_sibling_corner	2
		xpos					1
		labelText				"[Column 3]"
		//bgcolor_override 		"255 0 255 127"
	}
	ScoreboardColumnLabels2
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnHeader
		pin_to_sibling			ScoreboardColumnLabels3
		pin_corner_to_sibling	3
		pin_to_sibling_corner	2
		xpos					1
		labelText				"[Column 2]"
		//bgcolor_override	 	"130 255 0 127"
	}
	ScoreboardColumnLabels1
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnHeader
		pin_to_sibling			ScoreboardColumnLabels2
		pin_corner_to_sibling	3
		pin_to_sibling_corner	2
		xpos					1
		labelText				"[Column 1]"
		//bgcolor_override 		"0 255 120 127"
	}
	ScoreboardColumnLabels0
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnHeader
		pin_to_sibling			ScoreboardColumnLabels1
		pin_corner_to_sibling	3
		pin_to_sibling_corner	2
		xpos					1
		labelText				"[Column 0]"
		//bgcolor_override 		"0 123 0 127"
	}


	// Column icon backgrounds
	ScoreboardColumnIconBackground6
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnIconBackground
		pin_to_sibling			ScoreboardColumnLabels6
		pin_corner_to_sibling	6
		pin_to_sibling_corner	4
	}
	ScoreboardColumnIconBackground5
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnIconBackground
		pin_to_sibling			ScoreboardColumnLabels5
		pin_corner_to_sibling	6
		pin_to_sibling_corner	4
	}
	ScoreboardColumnIconBackground4
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnIconBackground
		pin_to_sibling			ScoreboardColumnLabels4
		pin_corner_to_sibling	6
		pin_to_sibling_corner	4
	}
	ScoreboardColumnIconBackground3
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnIconBackground
		pin_to_sibling			ScoreboardColumnLabels3
		pin_corner_to_sibling	6
		pin_to_sibling_corner	4
	}
	ScoreboardColumnIconBackground2
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnIconBackground
		pin_to_sibling			ScoreboardColumnLabels2
		pin_corner_to_sibling	6
		pin_to_sibling_corner	4
	}
	ScoreboardColumnIconBackground1
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnIconBackground
		pin_to_sibling			ScoreboardColumnLabels1
		pin_corner_to_sibling	6
		pin_to_sibling_corner	4
	}


	// Column icons
	ScoreboardColumnIcon6
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardColumnIcon
		pin_to_sibling			ScoreboardColumnLabels6
		pin_corner_to_sibling	6
		pin_to_sibling_corner	4
	}

	ScoreboardColumnIcon5
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardColumnIcon
		pin_to_sibling			ScoreboardColumnLabels5
		pin_corner_to_sibling	6
		pin_to_sibling_corner	4
	}

	ScoreboardColumnIcon4
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardColumnIcon
		pin_to_sibling			ScoreboardColumnLabels4
		pin_corner_to_sibling	6
		pin_to_sibling_corner	4
	}

	ScoreboardColumnIcon3
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardColumnIcon
		pin_to_sibling			ScoreboardColumnLabels3
		pin_corner_to_sibling	6
		pin_to_sibling_corner	4
	}

	ScoreboardColumnIcon2
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardColumnIcon
		pin_to_sibling			ScoreboardColumnLabels2
		pin_corner_to_sibling	6
		pin_to_sibling_corner	4
	}

	ScoreboardColumnIcon1
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardColumnIcon
		pin_to_sibling			ScoreboardColumnLabels1
		pin_corner_to_sibling	6
		pin_to_sibling_corner	4
	}




	// My team info
	ScoreboardMyTeamScore
	{
		ControlName				Label
		InheritProperties		ScoreboardTeamScore
		pin_to_sibling			ScoreboardHeaderBackground
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardMyTeamLogo
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardTeamLogo
		pin_to_sibling			ScoreboardMyTeamScore
		pin_corner_to_sibling	4
		pin_to_sibling_corner	6
	}

	// Enemy team info
	ScoreboardEnemyTeamScore
	{
		ControlName				Label
		InheritProperties		ScoreboardTeamScore
		pin_to_sibling			ScoreboardHeaderBackground
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardEnemyTeamLogo
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardTeamLogo
		pin_to_sibling			ScoreboardEnemyTeamScore
		pin_corner_to_sibling	4
		pin_to_sibling_corner	6
	}

	// Left side column lines
	ScoreboardMyTeamColumnLineMic
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardTeammateMic0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		visible 				1
	}
	ScoreboardMyTeamColumnLinePlayerNumber
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardTeammatePlayerNumber0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		visible 				1
	}
	ScoreboardMyTeamColumnLineStatus
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardTeammateStatus0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		visible 				1
	}
	ScoreboardMyTeamColumnLineLvl
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardTeammateLvl0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		visible 				1
	}

	ScoreboardEnemyTeamColumnLineMic
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardOpponentMic0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		visible 				1
	}
	ScoreboardEnemyTeamColumnLinePlayerNumber
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardOpponentPlayerNumber0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		visible 				1
	}
	ScoreboardEnemyTeamColumnLineStatus
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardOpponentStatus0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		visible 				1
	}
	ScoreboardEnemyTeamColumnLineLvl
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardOpponentLvl0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		visible 				1
	}


	// Right data column lines
	ScoreboardMyTeamColumnLineConnection
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardTeammateConnection0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		//visible 				1
		//bgcolor_override 		"255 0 0 255"
	}
	ScoreboardMyTeamDataColumnLine6
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardTeammateColumn6_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		//bgcolor_override 		"0 255 0 255"
	}
	ScoreboardMyTeamDataColumnLine5
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardTeammateColumn5_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		//bgcolor_override 		"0 0 255 255"
	}
	ScoreboardMyTeamDataColumnLine4
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardTeammateColumn4_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		//bgcolor_override 		"0 0 255 255"
	}
	ScoreboardMyTeamDataColumnLine3
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardTeammateColumn3_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		//bgcolor_override 		"0 0 255 255"
	}
	ScoreboardMyTeamDataColumnLine2
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardTeammateColumn2_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		//bgcolor_override 		"0 0 255 255"
	}
	ScoreboardMyTeamDataColumnLine1
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardTeammateColumn1_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		//bgcolor_override 		"0 0 255 255"
	}
	ScoreboardMyTeamDataColumnLine0
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardTeammateColumn0_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		//bgcolor_override 		"0 0 255 255"
	}



	ScoreboardEnemyTeamColumnLineConnection
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardOpponentConnection0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		//visible 				1
		//bgcolor_override 		"255 0 0 255"
	}
	ScoreboardEnemyTeamDataColumnLine6
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardOpponentColumn6_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		//bgcolor_override 		"0 255 0 255"
	}
	ScoreboardEnemyTeamDataColumnLine5
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardOpponentColumn5_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		//bgcolor_override 		"0 0 255 255"
	}
	ScoreboardEnemyTeamDataColumnLine4
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardOpponentColumn4_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		//bgcolor_override 		"0 0 255 255"
	}
	ScoreboardEnemyTeamDataColumnLine3
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardOpponentColumn3_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		//bgcolor_override 		"0 0 255 255"
	}
	ScoreboardEnemyTeamDataColumnLine2
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardOpponentColumn2_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		//bgcolor_override 		"0 0 255 255"
	}
	ScoreboardEnemyTeamDataColumnLine1
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardOpponentColumn1_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		//bgcolor_override 		"0 0 255 255"
	}
	ScoreboardEnemyTeamDataColumnLine0
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnLine
		pin_to_sibling			ScoreboardOpponentColumn0_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		//bgcolor_override 		"0 0 255 255"
	}


	// Friendly players
	ScoreboardTeammateBackground0
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayer
		pin_to_sibling			ScoreboardMyTeamScore
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		ypos					0
	}
	ScoreboardTeammateSelection0
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayerSelection
		pin_to_sibling			ScoreboardTeammateBackground0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammatePlayerNumber0
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerNumber
		pin_to_sibling			ScoreboardTeammateBackground0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateMic0
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerMic
		pin_to_sibling			ScoreboardTeammatePlayerNumber0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateStatus0
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerStatus
		pin_to_sibling			ScoreboardTeammateMic0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateArt0
	{
		ControlName				CNestedPanel
		InheritProperties 		ScoreboardPlayerArt
		pin_to_sibling			ScoreboardTeammateStatus0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateLvl0
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerLevel
		pin_to_sibling			ScoreboardTeammateArt0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateName0
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerName
		pin_to_sibling			ScoreboardTeammateLvl0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammatePartyLeader0
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerPartyLeader
		pin_to_sibling			ScoreboardTeammateName0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateConnection0
	{
		ControlName				ImagePanel	[$GAMECONSOLE]
		ControlName				Label 		[!$GAMECONSOLE]
		InheritProperties 		ScoreboardColumnConnection
		pin_to_sibling			ScoreboardTeammateBackground0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	1
	}
	ScoreboardTeammatePing0
	{
		ControlName				Label
		InheritProperties 		ScoreboardPing
		pin_to_sibling			ScoreboardTeammateBackground0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateColumn6_0
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateConnection0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		xpos					1
	}
	ScoreboardTeammateColumn5_0
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn6_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn4_0
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn5_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn3_0
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn4_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn2_0
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn3_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn1_0
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn2_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn0_0
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn1_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}

	ScoreboardTeammateBackground1
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayer
		pin_to_sibling			ScoreboardTeammateBackground0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}
	ScoreboardTeammateSelection1
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayerSelection
		pin_to_sibling			ScoreboardTeammateBackground1
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammatePlayerNumber1
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerNumber
		pin_to_sibling			ScoreboardTeammateBackground1
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateMic1
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerMic
		pin_to_sibling			ScoreboardTeammatePlayerNumber1
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateStatus1
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerStatus
		pin_to_sibling			ScoreboardTeammateMic1
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateArt1
	{
		ControlName				CNestedPanel
		InheritProperties 		ScoreboardPlayerArt
		pin_to_sibling			ScoreboardTeammateStatus1
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateLvl1
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerLevel
		pin_to_sibling			ScoreboardTeammateArt1
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateName1
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerName
		pin_to_sibling			ScoreboardTeammateLvl1
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammatePartyLeader1
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerPartyLeader
		pin_to_sibling			ScoreboardTeammateName1
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateConnection1
	{
		ControlName				ImagePanel	[$GAMECONSOLE]
		ControlName				Label 		[!$GAMECONSOLE]
		InheritProperties 		ScoreboardColumnConnection
		pin_to_sibling			ScoreboardTeammateBackground1
		pin_corner_to_sibling	1
		pin_to_sibling_corner	1
	}
	ScoreboardTeammatePing1
	{
		ControlName				Label
		InheritProperties 		ScoreboardPing
		pin_to_sibling			ScoreboardTeammateBackground1
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateColumn6_1
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateConnection1
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		xpos					1
	}
	ScoreboardTeammateColumn5_1
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn6_1
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn4_1
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn5_1
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn3_1
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn4_1
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn2_1
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn3_1
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn1_1
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn2_1
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn0_1
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn1_1
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}

	ScoreboardTeammateBackground2
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayer
		pin_to_sibling			ScoreboardTeammateBackground1
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}
	ScoreboardTeammateSelection2
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayerSelection
		pin_to_sibling			ScoreboardTeammateBackground2
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammatePlayerNumber2
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerNumber
		pin_to_sibling			ScoreboardTeammateBackground2
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateMic2
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerMic
		pin_to_sibling			ScoreboardTeammatePlayerNumber2
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateStatus2
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerStatus
		pin_to_sibling			ScoreboardTeammateMic2
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateArt2
	{
		ControlName				CNestedPanel
		InheritProperties 		ScoreboardPlayerArt
		pin_to_sibling			ScoreboardTeammateStatus2
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateLvl2
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerLevel
		pin_to_sibling			ScoreboardTeammateArt2
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateName2
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerName
		pin_to_sibling			ScoreboardTeammateLvl2
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammatePartyLeader2
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerPartyLeader
		pin_to_sibling			ScoreboardTeammateName2
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateConnection2
	{
		ControlName				ImagePanel	[$GAMECONSOLE]
		ControlName				Label 		[!$GAMECONSOLE]
		InheritProperties 		ScoreboardColumnConnection
		pin_to_sibling			ScoreboardTeammateBackground2
		pin_corner_to_sibling	1
		pin_to_sibling_corner	1
	}
	ScoreboardTeammatePing2
	{
		ControlName				Label
		InheritProperties 		ScoreboardPing
		pin_to_sibling			ScoreboardTeammateBackground2
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateColumn6_2
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateConnection2
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		xpos					1
	}
	ScoreboardTeammateColumn5_2
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn6_2
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn4_2
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn5_2
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn3_2
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn4_2
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn2_2
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn3_2
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn1_2
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn2_2
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn0_2
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn1_2
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}

	ScoreboardTeammateBackground3
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayer
		pin_to_sibling			ScoreboardTeammateBackground2
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}
	ScoreboardTeammateSelection3
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayerSelection
		pin_to_sibling			ScoreboardTeammateBackground3
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammatePlayerNumber3
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerNumber
		pin_to_sibling			ScoreboardTeammateBackground3
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateMic3
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerMic
		pin_to_sibling			ScoreboardTeammatePlayerNumber3
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateStatus3
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerStatus
		pin_to_sibling			ScoreboardTeammateMic3
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateArt3
	{
		ControlName				CNestedPanel
		InheritProperties 		ScoreboardPlayerArt
		pin_to_sibling			ScoreboardTeammateStatus3
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateLvl3
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerLevel
		pin_to_sibling			ScoreboardTeammateArt3
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateName3
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerName
		pin_to_sibling			ScoreboardTeammateLvl3
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammatePartyLeader3
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerPartyLeader
		pin_to_sibling			ScoreboardTeammateName3
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateConnection3
	{
		ControlName				ImagePanel	[$GAMECONSOLE]
		ControlName				Label 		[!$GAMECONSOLE]
		InheritProperties 		ScoreboardColumnConnection
		pin_to_sibling			ScoreboardTeammateBackground3
		pin_corner_to_sibling	1
		pin_to_sibling_corner	1
	}
	ScoreboardTeammatePing3
	{
		ControlName				Label
		InheritProperties 		ScoreboardPing
		pin_to_sibling			ScoreboardTeammateBackground3
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateColumn6_3
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateConnection3
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		xpos					1
	}
	ScoreboardTeammateColumn5_3
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn6_3
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn4_3
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn5_3
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn3_3
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn4_3
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn2_3
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn3_3
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn1_3
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn2_3
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn0_3
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn1_3
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}

	ScoreboardTeammateBackground4
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayer
		pin_to_sibling			ScoreboardTeammateBackground3
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}
	ScoreboardTeammateSelection4
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayerSelection
		pin_to_sibling			ScoreboardTeammateBackground4
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammatePlayerNumber4
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerNumber
		pin_to_sibling			ScoreboardTeammateBackground4
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateMic4
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerMic
		pin_to_sibling			ScoreboardTeammatePlayerNumber4
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateStatus4
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerStatus
		pin_to_sibling			ScoreboardTeammateMic4
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateArt4
	{
		ControlName				CNestedPanel
		InheritProperties 		ScoreboardPlayerArt
		pin_to_sibling			ScoreboardTeammateStatus4
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateLvl4
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerLevel
		pin_to_sibling			ScoreboardTeammateArt4
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateName4
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerName
		pin_to_sibling			ScoreboardTeammateLvl4
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammatePartyLeader4
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerPartyLeader
		pin_to_sibling			ScoreboardTeammateName4
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateConnection4
	{
		ControlName				ImagePanel	[$GAMECONSOLE]
		ControlName				Label 		[!$GAMECONSOLE]
		InheritProperties 		ScoreboardColumnConnection
		pin_to_sibling			ScoreboardTeammateBackground4
		pin_corner_to_sibling	1
		pin_to_sibling_corner	1
	}
	ScoreboardTeammatePing4
	{
		ControlName				Label
		InheritProperties 		ScoreboardPing
		pin_to_sibling			ScoreboardTeammateBackground4
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateColumn6_4
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateConnection4
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		xpos					1
	}
	ScoreboardTeammateColumn5_4
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn6_4
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn4_4
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn5_4
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn3_4
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn4_4
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn2_4
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn3_4
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn1_4
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn2_4
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn0_4
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn1_4
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}

	ScoreboardTeammateBackground5
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayer
		pin_to_sibling			ScoreboardTeammateBackground4
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}
	ScoreboardTeammateSelection5
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayerSelection
		pin_to_sibling			ScoreboardTeammateBackground5
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammatePlayerNumber5
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerNumber
		pin_to_sibling			ScoreboardTeammateBackground5
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateMic5
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerMic
		pin_to_sibling			ScoreboardTeammatePlayerNumber5
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateStatus5
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerStatus
		pin_to_sibling			ScoreboardTeammateMic5
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateArt5
	{
		ControlName				CNestedPanel
		InheritProperties 		ScoreboardPlayerArt
		pin_to_sibling			ScoreboardTeammateStatus5
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateLvl5
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerLevel
		pin_to_sibling			ScoreboardTeammateArt5
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateName5
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerName
		pin_to_sibling			ScoreboardTeammateLvl5
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammatePartyLeader5
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerPartyLeader
		pin_to_sibling			ScoreboardTeammateName5
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateConnection5
	{
		ControlName				ImagePanel	[$GAMECONSOLE]
		ControlName				Label 		[!$GAMECONSOLE]
		InheritProperties 		ScoreboardColumnConnection
		pin_to_sibling			ScoreboardTeammateBackground5
		pin_corner_to_sibling	1
		pin_to_sibling_corner	1
	}
	ScoreboardTeammatePing5
	{
		ControlName				Label
		InheritProperties 		ScoreboardPing
		pin_to_sibling			ScoreboardTeammateBackground5
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateColumn6_5
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateConnection5
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		xpos					1
	}
	ScoreboardTeammateColumn5_5
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn6_5
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn4_5
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn5_5
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn3_5
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn4_5
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn2_5
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn3_5
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn1_5
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn2_5
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn0_5
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn1_5
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}

	ScoreboardTeammateBackground6
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayer
		pin_to_sibling			ScoreboardTeammateBackground5
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}
	ScoreboardTeammateSelection6
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayerSelection
		pin_to_sibling			ScoreboardTeammateBackground6
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammatePlayerNumber6
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerNumber
		pin_to_sibling			ScoreboardTeammateBackground6
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateMic6
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerMic
		pin_to_sibling			ScoreboardTeammatePlayerNumber6
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateStatus6
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerStatus
		pin_to_sibling			ScoreboardTeammateMic6
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateArt6
	{
		ControlName				CNestedPanel
		InheritProperties 		ScoreboardPlayerArt
		pin_to_sibling			ScoreboardTeammateStatus6
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateLvl6
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerLevel
		pin_to_sibling			ScoreboardTeammateArt6
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateName6
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerName
		pin_to_sibling			ScoreboardTeammateLvl6
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammatePartyLeader6
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerPartyLeader
		pin_to_sibling			ScoreboardTeammateName6
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateConnection6
	{
		ControlName				ImagePanel	[$GAMECONSOLE]
		ControlName				Label 		[!$GAMECONSOLE]
		InheritProperties 		ScoreboardColumnConnection
		pin_to_sibling			ScoreboardTeammateBackground6
		pin_corner_to_sibling	1
		pin_to_sibling_corner	1
	}
	ScoreboardTeammatePing6
	{
		ControlName				Label
		InheritProperties 		ScoreboardPing
		pin_to_sibling			ScoreboardTeammateBackground6
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateColumn6_6
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateConnection6
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		xpos					1
	}
	ScoreboardTeammateColumn5_6
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn6_6
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn4_6
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn5_6
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn3_6
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn4_6
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn2_6
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn3_6
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn1_6
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn2_6
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn0_6
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn1_6
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}

	ScoreboardTeammateBackground7
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayer
		pin_to_sibling			ScoreboardTeammateBackground6
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}
	ScoreboardTeammateSelection7
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayerSelection
		pin_to_sibling			ScoreboardTeammateBackground7
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammatePlayerNumber7
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerNumber
		pin_to_sibling			ScoreboardTeammateBackground7
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateMic7
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerMic
		pin_to_sibling			ScoreboardTeammatePlayerNumber7
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateStatus7
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerStatus
		pin_to_sibling			ScoreboardTeammateMic7
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateArt7
	{
		ControlName				CNestedPanel
		InheritProperties 		ScoreboardPlayerArt
		pin_to_sibling			ScoreboardTeammateStatus7
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateLvl7
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerLevel
		pin_to_sibling			ScoreboardTeammateArt7
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateName7
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerName
		pin_to_sibling			ScoreboardTeammateLvl7
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammatePartyLeader7
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerPartyLeader
		pin_to_sibling			ScoreboardTeammateName7
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateConnection7
	{
		ControlName				ImagePanel	[$GAMECONSOLE]
		ControlName				Label 		[!$GAMECONSOLE]
		InheritProperties 		ScoreboardColumnConnection
		pin_to_sibling			ScoreboardTeammateBackground7
		pin_corner_to_sibling	1
		pin_to_sibling_corner	1
	}
	ScoreboardTeammatePing7
	{
		ControlName				Label
		InheritProperties 		ScoreboardPing
		pin_to_sibling			ScoreboardTeammateBackground7
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardTeammateColumn6_7
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateConnection7
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		xpos					1
	}
	ScoreboardTeammateColumn5_7
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn6_7
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn4_7
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn5_7
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn3_7
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn4_7
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn2_7
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn3_7
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn1_7
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn2_7
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardTeammateColumn0_7
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardTeammateColumn1_7
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}

	// Enemy players

	ScoreboardOpponentBackground0
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayer
		pin_to_sibling			ScoreboardEnemyTeamScore
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
		ypos					0
	}
	ScoreboardOpponentSelection0
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayerSelection
		pin_to_sibling			ScoreboardOpponentBackground0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentPlayerNumber0
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerNumber
		pin_to_sibling			ScoreboardOpponentBackground0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentMic0
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerMic
		pin_to_sibling			ScoreboardOpponentPlayerNumber0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentStatus0
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerStatus
		pin_to_sibling			ScoreboardOpponentMic0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentArt0
	{
		ControlName				CNestedPanel
		InheritProperties 		ScoreboardPlayerArt
		pin_to_sibling			ScoreboardOpponentStatus0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentLvl0
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerLevel
		pin_to_sibling			ScoreboardOpponentArt0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentName0
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerName
		pin_to_sibling			ScoreboardOpponentLvl0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentPartyLeader0
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerPartyLeader
		pin_to_sibling			ScoreboardOpponentName0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentConnection0
	{
		ControlName				ImagePanel	[$GAMECONSOLE]
		ControlName				Label 		[!$GAMECONSOLE]
		InheritProperties 		ScoreboardColumnConnection
		pin_to_sibling			ScoreboardOpponentBackground0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentPing0
	{
		ControlName				Label
		InheritProperties 		ScoreboardPing
		pin_to_sibling			ScoreboardOpponentBackground0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentColumn6_0
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentConnection0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		xpos					1
	}
	ScoreboardOpponentColumn5_0
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn6_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn4_0
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn5_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn3_0
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn4_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn2_0
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn3_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn1_0
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn2_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn0_0
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn1_0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}

	ScoreboardOpponentBackground1
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayer
		pin_to_sibling			ScoreboardOpponentBackground0
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}
	ScoreboardOpponentSelection1
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayerSelection
		pin_to_sibling			ScoreboardOpponentBackground1
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentPlayerNumber1
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerNumber
		pin_to_sibling			ScoreboardOpponentBackground1
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentMic1
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerMic
		pin_to_sibling			ScoreboardOpponentPlayerNumber1
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentStatus1
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerStatus
		pin_to_sibling			ScoreboardOpponentMic1
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentArt1
	{
		ControlName				CNestedPanel
		InheritProperties 		ScoreboardPlayerArt
		pin_to_sibling			ScoreboardOpponentStatus1
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentLvl1
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerLevel
		pin_to_sibling			ScoreboardOpponentArt1
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentName1
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerName
		pin_to_sibling			ScoreboardOpponentLvl1
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentPartyLeader1
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerPartyLeader
		pin_to_sibling			ScoreboardOpponentName1
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentConnection1
	{
		ControlName				ImagePanel	[$GAMECONSOLE]
		ControlName				Label 		[!$GAMECONSOLE]
		InheritProperties 		ScoreboardColumnConnection
		pin_to_sibling			ScoreboardOpponentBackground1
		pin_corner_to_sibling	1
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentPing1
	{
		ControlName				Label
		InheritProperties 		ScoreboardPing
		pin_to_sibling			ScoreboardOpponentBackground1
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentColumn6_1
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentConnection1
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		xpos					1
	}
	ScoreboardOpponentColumn5_1
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn6_1
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn4_1
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn5_1
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn3_1
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn4_1
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn2_1
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn3_1
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn1_1
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn2_1
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn0_1
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn1_1
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}

	ScoreboardOpponentBackground2
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayer
		pin_to_sibling			ScoreboardOpponentBackground1
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}
	ScoreboardOpponentSelection2
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayerSelection
		pin_to_sibling			ScoreboardOpponentBackground2
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentPlayerNumber2
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerNumber
		pin_to_sibling			ScoreboardOpponentBackground2
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentMic2
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerMic
		pin_to_sibling			ScoreboardOpponentPlayerNumber2
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentStatus2
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerStatus
		pin_to_sibling			ScoreboardOpponentMic2
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentArt2
	{
		ControlName				CNestedPanel
		InheritProperties 		ScoreboardPlayerArt
		pin_to_sibling			ScoreboardOpponentStatus2
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentLvl2
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerLevel
		pin_to_sibling			ScoreboardOpponentArt2
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentName2
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerName
		pin_to_sibling			ScoreboardOpponentLvl2
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentPartyLeader2
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerPartyLeader
		pin_to_sibling			ScoreboardOpponentName2
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentConnection2
	{
		ControlName				ImagePanel	[$GAMECONSOLE]
		ControlName				Label 		[!$GAMECONSOLE]
		InheritProperties 		ScoreboardColumnConnection
		pin_to_sibling			ScoreboardOpponentBackground2
		pin_corner_to_sibling	1
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentPing2
	{
		ControlName				Label
		InheritProperties 		ScoreboardPing
		pin_to_sibling			ScoreboardOpponentBackground2
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentColumn6_2
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentConnection2
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		xpos					1
	}
	ScoreboardOpponentColumn5_2
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn6_2
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn4_2
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn5_2
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn3_2
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn4_2
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn2_2
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn3_2
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn1_2
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn2_2
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn0_2
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn1_2
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}

	ScoreboardOpponentBackground3
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayer
		pin_to_sibling			ScoreboardOpponentBackground2
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}
	ScoreboardOpponentSelection3
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayerSelection
		pin_to_sibling			ScoreboardOpponentBackground3
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentPlayerNumber3
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerNumber
		pin_to_sibling			ScoreboardOpponentBackground3
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentMic3
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerMic
		pin_to_sibling			ScoreboardOpponentPlayerNumber3
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentStatus3
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerStatus
		pin_to_sibling			ScoreboardOpponentMic3
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentArt3
	{
		ControlName				CNestedPanel
		InheritProperties 		ScoreboardPlayerArt
		pin_to_sibling			ScoreboardOpponentStatus3
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentLvl3
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerLevel
		pin_to_sibling			ScoreboardOpponentArt3
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentName3
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerName
		pin_to_sibling			ScoreboardOpponentLvl3
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentPartyLeader3
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerPartyLeader
		pin_to_sibling			ScoreboardOpponentName3
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentConnection3
	{
		ControlName				ImagePanel	[$GAMECONSOLE]
		ControlName				Label 		[!$GAMECONSOLE]
		InheritProperties 		ScoreboardColumnConnection
		pin_to_sibling			ScoreboardOpponentBackground3
		pin_corner_to_sibling	1
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentPing3
	{
		ControlName				Label
		InheritProperties 		ScoreboardPing
		pin_to_sibling			ScoreboardOpponentBackground3
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentColumn6_3
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentConnection3
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		xpos					1
	}
	ScoreboardOpponentColumn5_3
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn6_3
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn4_3
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn5_3
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn3_3
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn4_3
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn2_3
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn3_3
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn1_3
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn2_3
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn0_3
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn1_3
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}

	ScoreboardOpponentBackground4
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayer
		pin_to_sibling			ScoreboardOpponentBackground3
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}
	ScoreboardOpponentSelection4
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayerSelection
		pin_to_sibling			ScoreboardOpponentBackground4
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentPlayerNumber4
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerNumber
		pin_to_sibling			ScoreboardOpponentBackground4
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentMic4
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerMic
		pin_to_sibling			ScoreboardOpponentPlayerNumber4
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentStatus4
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerStatus
		pin_to_sibling			ScoreboardOpponentMic4
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentArt4
	{
		ControlName				CNestedPanel
		InheritProperties 		ScoreboardPlayerArt
		pin_to_sibling			ScoreboardOpponentStatus4
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentLvl4
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerLevel
		pin_to_sibling			ScoreboardOpponentArt4
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentName4
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerName
		pin_to_sibling			ScoreboardOpponentLvl4
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentPartyLeader4
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerPartyLeader
		pin_to_sibling			ScoreboardOpponentName4
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentConnection4
	{
		ControlName				ImagePanel	[$GAMECONSOLE]
		ControlName				Label 		[!$GAMECONSOLE]
		InheritProperties 		ScoreboardColumnConnection
		pin_to_sibling			ScoreboardOpponentBackground4
		pin_corner_to_sibling	1
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentPing4
	{
		ControlName				Label
		InheritProperties 		ScoreboardPing
		pin_to_sibling			ScoreboardOpponentBackground4
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentColumn6_4
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentConnection4
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		xpos					1
	}
	ScoreboardOpponentColumn5_4
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn6_4
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn4_4
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn5_4
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn3_4
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn4_4
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn2_4
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn3_4
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn1_4
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn2_4
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn0_4
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn1_4
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}

	ScoreboardOpponentBackground5
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayer
		pin_to_sibling			ScoreboardOpponentBackground4
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}
	ScoreboardOpponentSelection5
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayerSelection
		pin_to_sibling			ScoreboardOpponentBackground5
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentPlayerNumber5
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerNumber
		pin_to_sibling			ScoreboardOpponentBackground5
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentMic5
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerMic
		pin_to_sibling			ScoreboardOpponentPlayerNumber5
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentStatus5
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerStatus
		pin_to_sibling			ScoreboardOpponentMic5
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentArt5
	{
		ControlName				CNestedPanel
		InheritProperties 		ScoreboardPlayerArt
		pin_to_sibling			ScoreboardOpponentStatus5
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentLvl5
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerLevel
		pin_to_sibling			ScoreboardOpponentArt5
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentName5
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerName
		pin_to_sibling			ScoreboardOpponentLvl5
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentPartyLeader5
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerPartyLeader
		pin_to_sibling			ScoreboardOpponentName5
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentConnection5
	{
		ControlName				ImagePanel	[$GAMECONSOLE]
		ControlName				Label 		[!$GAMECONSOLE]
		InheritProperties 		ScoreboardColumnConnection
		pin_to_sibling			ScoreboardOpponentBackground5
		pin_corner_to_sibling	1
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentPing5
	{
		ControlName				Label
		InheritProperties 		ScoreboardPing
		pin_to_sibling			ScoreboardOpponentBackground5
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentColumn6_5
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentConnection5
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		xpos					1
	}
	ScoreboardOpponentColumn5_5
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn6_5
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn4_5
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn5_5
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn3_5
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn4_5
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn2_5
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn3_5
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn1_5
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn2_5
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn0_5
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn1_5
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}

	ScoreboardOpponentBackground6
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayer
		pin_to_sibling			ScoreboardOpponentBackground5
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}
	ScoreboardOpponentSelection6
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayerSelection
		pin_to_sibling			ScoreboardOpponentBackground6
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentPlayerNumber6
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerNumber
		pin_to_sibling			ScoreboardOpponentBackground6
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentMic6
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerMic
		pin_to_sibling			ScoreboardOpponentPlayerNumber6
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentStatus6
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerStatus
		pin_to_sibling			ScoreboardOpponentMic6
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentArt6
	{
		ControlName				CNestedPanel
		InheritProperties 		ScoreboardPlayerArt
		pin_to_sibling			ScoreboardOpponentStatus6
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentLvl6
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerLevel
		pin_to_sibling			ScoreboardOpponentArt6
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentName6
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerName
		pin_to_sibling			ScoreboardOpponentLvl6
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentPartyLeader6
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerPartyLeader
		pin_to_sibling			ScoreboardOpponentName6
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentConnection6
	{
		ControlName				ImagePanel	[$GAMECONSOLE]
		ControlName				Label 		[!$GAMECONSOLE]
		InheritProperties 		ScoreboardColumnConnection
		pin_to_sibling			ScoreboardOpponentBackground6
		pin_corner_to_sibling	1
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentPing6
	{
		ControlName				Label
		InheritProperties 		ScoreboardPing
		pin_to_sibling			ScoreboardOpponentBackground6
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentColumn6_6
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentConnection6
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		xpos					1
	}
	ScoreboardOpponentColumn5_6
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn6_6
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn4_6
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn5_6
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn3_6
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn4_6
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn2_6
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn3_6
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn1_6
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn2_6
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn0_6
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn1_6
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}

	ScoreboardOpponentBackground7
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayer
		pin_to_sibling			ScoreboardOpponentBackground6
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}
	ScoreboardOpponentSelection7
	{
		ControlName				ImagePanel
		InheritProperties		ScoreboardPlayerSelection
		pin_to_sibling			ScoreboardOpponentBackground7
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentPlayerNumber7
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerNumber
		pin_to_sibling			ScoreboardOpponentBackground7
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentMic7
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerMic
		pin_to_sibling			ScoreboardOpponentPlayerNumber7
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentStatus7
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerStatus
		pin_to_sibling			ScoreboardOpponentMic7
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentArt7
	{
		ControlName				CNestedPanel
		InheritProperties 		ScoreboardPlayerArt
		pin_to_sibling			ScoreboardOpponentStatus7
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentLvl7
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerLevel
		pin_to_sibling			ScoreboardOpponentArt7
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentName7
	{
		ControlName				Label
		InheritProperties 		ScoreboardPlayerName
		pin_to_sibling			ScoreboardOpponentLvl7
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentPartyLeader7
	{
		ControlName				ImagePanel
		InheritProperties 		ScoreboardPlayerPartyLeader
		pin_to_sibling			ScoreboardOpponentName7
		pin_corner_to_sibling	0
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentConnection7
	{
		ControlName				ImagePanel	[$GAMECONSOLE]
		ControlName				Label 		[!$GAMECONSOLE]
		InheritProperties 		ScoreboardColumnConnection
		pin_to_sibling			ScoreboardOpponentBackground7
		pin_corner_to_sibling	1
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentPing7
	{
		ControlName				Label
		InheritProperties 		ScoreboardPing
		pin_to_sibling			ScoreboardOpponentBackground7
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
	ScoreboardOpponentColumn6_7
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentConnection7
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		xpos					1
	}
	ScoreboardOpponentColumn5_7
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn6_7
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn4_7
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn5_7
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn3_7
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn4_7
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn2_7
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn3_7
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn1_7
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn2_7
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}
	ScoreboardOpponentColumn0_7
	{
		ControlName				Label
		InheritProperties 		ScoreboardColumnData
		pin_to_sibling			ScoreboardOpponentColumn1_7
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
	}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	ScoreboardBadRepPresentMessage
	{
		ControlName				Label
		pin_to_sibling 			ScoreboardBackground
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
		ypos 					2
		auto_wide_tocontents	1
		auto_tall_tocontents	1
		visible 				0
		font 					FooterFont
		labelText				""
		fgcolor_override 		"255 50 50 255"
	}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// In reverse order because these fill from right to left
	ScoreboardGamepadFooterButton0
	{
		ControlName				Label
		InheritProperties		ScoreboardGamepadFooterButton
		pin_to_sibling 			ScoreboardBackground
		pin_corner_to_sibling	1
		pin_to_sibling_corner	3
		ypos 					2
		labelText				"#Y_BUTTON_PLAYER_PROFILE" [!$GAMECONSOLE]
		labelText				"#Y_BUTTON_GAMERCARD" [$GAMECONSOLE]
	}
	ScoreboardGamepadFooterButton1
	{
		ControlName				Label
		InheritProperties		ScoreboardGamepadFooterButton
		pin_to_sibling			ScoreboardGamepadFooterButton0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		xpos 					10
		labelText				"#X_BUTTON_MUTE"
	}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// COOP WAVE INFO

	ScoreboardTD_WaveNumber
	{
		ControlName				Label
		xpos 					-6
		ypos					7
		zpos					1012
		visible					0
		auto_wide_tocontents	1
		auto_tall_tocontents	1
		font					ScoreboardFont
		labelText				"WAVE NUMBER"
		allcaps					1
		fgcolor_override	 	"204 234 255 255"
		bgcolor_override 		"255 127 127 127"

		pin_to_sibling			ScoreboardTeammateBackground3
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}

	ScoreboardTD_WaveName
	{
		ControlName				Label
		xpos 					4
		ypos					0
		zpos					1012
		visible					0
		auto_wide_tocontents	1
		auto_tall_tocontents	1
		font					ScoreboardFont
		labelText				"WAVE NAME"
		allcaps					1
		fgcolor_override	 	"204 234 255 255"

		pin_to_sibling			ScoreboardTD_WaveNumber
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}

	ScoreboardTD_RemainingEnemies
	{
		ControlName				Label
		ypos					4
		zpos					1012
		visible					0
		auto_wide_tocontents	1
		auto_tall_tocontents	1
		font					HudFontSmallPlain
		labelText				"#COOP_REMAINING_ENEMIES"
		allcaps					1
		fgcolor_override	 	"255 255 255 255"

		pin_to_sibling			ScoreboardTD_WaveNumber
		pin_corner_to_sibling	0
		pin_to_sibling_corner	2
	}

	ScoreboardTD_ContinuesRemaining_Title
	{
		ControlName				Label
		ypos					45
		zpos					1012
		visible					0
		wide					60
		tall					36
		font					HudFontSmallPlain
		labelText				"#SCOREBOARD_TD_CONTINUES"
		allcaps					1
		centerwrap				1
		textAlignment			"center"
//		textinsety				-1
		fgcolor_override	 	"204 234 255 255"

		pin_to_sibling			ScoreboardMyTeamLogo
		pin_corner_to_sibling	4
		pin_to_sibling_corner	6
	}

	ScoreboardTD_ContinuesRemaining_Count
	{
		ControlName				Label
		ypos					-2
		zpos					1012
		visible					0
		wide					101
		tall					30
		font					HudNumbersMedium
		labelText				"3"
		textAlignment			"center"
		fgcolor_override	 	"255 255 255 255"

		pin_to_sibling			ScoreboardTD_ContinuesRemaining_Title
		pin_corner_to_sibling	4
		pin_to_sibling_corner	6
	}

	ScoreboardTD_WaveEnemyType_0
	{
		ControlName					CNestedPanel
		InheritProperties 			ScoreboardTD_WaveEnemy

		ypos						5
		xpos						0

		pin_to_sibling				ScoreboardTD_RemainingEnemies
		pin_corner_to_sibling		0
		pin_to_sibling_corner		2
	}

	ScoreboardTD_WaveEnemyType_1
	{
		ControlName					CNestedPanel
		InheritProperties 			ScoreboardTD_WaveEnemy

		xpos						6

		pin_to_sibling				ScoreboardTD_WaveEnemyType_0
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	ScoreboardTD_WaveEnemyType_2
	{
		ControlName					CNestedPanel
		InheritProperties 			ScoreboardTD_WaveEnemy

		xpos						6

		pin_to_sibling				ScoreboardTD_WaveEnemyType_1
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	ScoreboardTD_WaveEnemyType_3
	{
		ControlName					CNestedPanel
		InheritProperties 			ScoreboardTD_WaveEnemy

		xpos						6

		pin_to_sibling				ScoreboardTD_WaveEnemyType_2
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	ScoreboardTD_WaveEnemyType_4
	{
		ControlName					CNestedPanel
		InheritProperties 			ScoreboardTD_WaveEnemy

		xpos						6

		pin_to_sibling				ScoreboardTD_WaveEnemyType_3
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	ScoreboardTD_WaveEnemyType_5
	{
		ControlName					CNestedPanel
		InheritProperties 			ScoreboardTD_WaveEnemy

		ypos						5
		xpos						0

		pin_to_sibling				ScoreboardTD_WaveEnemyType_0
		pin_corner_to_sibling		0
		pin_to_sibling_corner		2
	}

	ScoreboardTD_WaveEnemyType_6
	{
		ControlName					CNestedPanel
		InheritProperties 			ScoreboardTD_WaveEnemy

		xpos						6

		pin_to_sibling				ScoreboardTD_WaveEnemyType_5
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	ScoreboardTD_WaveEnemyType_7
	{
		ControlName					CNestedPanel
		InheritProperties 			ScoreboardTD_WaveEnemy

		xpos						6

		pin_to_sibling				ScoreboardTD_WaveEnemyType_6
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	ScoreboardTD_WaveEnemyType_8
	{
		ControlName					CNestedPanel
		InheritProperties 			ScoreboardTD_WaveEnemy

		xpos						6

		pin_to_sibling				ScoreboardTD_WaveEnemyType_7
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	ScoreboardTD_WaveEnemyType_9
	{
		ControlName					CNestedPanel
		InheritProperties 			ScoreboardTD_WaveEnemy

		xpos						6

		pin_to_sibling				ScoreboardTD_WaveEnemyType_8
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	ScoreboardTD_Star_0
	{
		ControlName			ImagePanel
		xpos				12
		ypos				15
		wide				28
		tall				28
		visible				0
		image				"../ui/menu/lobby/map_star_empty_small"
		scaleImage			1

		pin_to_sibling				ScoreboardTD_ContinuesRemaining_Title
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0

		zpos			1101
	}

	ScoreboardTD_Star_1
	{
		ControlName			ImagePanel
		ypos				0
		wide				28
		tall				28
		visible				0
		image				"../ui/menu/lobby/map_star_empty_small"
		scaleImage			1

		pin_to_sibling				ScoreboardTD_Star_0
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1

		zpos			1101
	}

	ScoreboardTD_Star_2
	{
		ControlName			ImagePanel
		ypos				0
		wide				28
		tall				28
		visible				0
		image				"../ui/menu/lobby/map_star_empty_small"
		scaleImage			1

		pin_to_sibling				ScoreboardTD_Star_1
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1

		zpos			1101
	}
	    ScoreboardTeammateBackground8
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayer
        pin_to_sibling			ScoreboardTeammateBackground7
        pin_corner_to_sibling	0
        pin_to_sibling_corner	2
    }
    ScoreboardTeammateSelection8
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayerSelection
        pin_to_sibling			ScoreboardTeammateBackground8
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammatePlayerNumber8
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerNumber
        pin_to_sibling			ScoreboardTeammateBackground8
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammateMic8
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerMic
        pin_to_sibling			ScoreboardTeammatePlayerNumber8
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateStatus8
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerStatus
        pin_to_sibling			ScoreboardTeammateMic8
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateArt8
    {
        ControlName				CNestedPanel
        InheritProperties 		ScoreboardPlayerArt
        pin_to_sibling			ScoreboardTeammateStatus8
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateLvl8
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerLevel
        pin_to_sibling			ScoreboardTeammateArt8
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateName8
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerName
        pin_to_sibling			ScoreboardTeammateLvl8
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammatePartyLeader8
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerPartyLeader
        pin_to_sibling			ScoreboardTeammateName8
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammateConnection8
    {
        ControlName				ImagePanel	[$GAMECONSOLE]
        ControlName				Label 		[!$GAMECONSOLE]
        InheritProperties 		ScoreboardColumnConnection
        pin_to_sibling			ScoreboardTeammateBackground8
        pin_corner_to_sibling	1
        pin_to_sibling_corner	1
    }
    ScoreboardTeammatePing8
    {
        ControlName				Label
        InheritProperties 		ScoreboardPing
        pin_to_sibling			ScoreboardTeammateBackground8
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateColumn6_8
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateConnection_8
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        xpos					1
    }
    ScoreboardTeammateColumn5_8
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn6_8
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn4_8
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn5_8
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn3_8
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn4_8
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn2_8
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn3_8
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn1_8
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn2_8
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn0_8
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn1_8
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }

    ScoreboardTeammateBackground9
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayer
        pin_to_sibling			ScoreboardTeammateBackground8
        pin_corner_to_sibling	0
        pin_to_sibling_corner	2
    }
    ScoreboardTeammateSelection9
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayerSelection
        pin_to_sibling			ScoreboardTeammateBackground9
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammatePlayerNumber9
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerNumber
        pin_to_sibling			ScoreboardTeammateBackground9
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammateMic9
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerMic
        pin_to_sibling			ScoreboardTeammatePlayerNumber9
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateStatus9
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerStatus
        pin_to_sibling			ScoreboardTeammateMic9
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateArt9
    {
        ControlName				CNestedPanel
        InheritProperties 		ScoreboardPlayerArt
        pin_to_sibling			ScoreboardTeammateStatus9
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateLvl9
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerLevel
        pin_to_sibling			ScoreboardTeammateArt9
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateName9
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerName
        pin_to_sibling			ScoreboardTeammateLvl9
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammatePartyLeader9
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerPartyLeader
        pin_to_sibling			ScoreboardTeammateName9
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammateConnection9
    {
        ControlName				ImagePanel	[$GAMECONSOLE]
        ControlName				Label 		[!$GAMECONSOLE]
        InheritProperties 		ScoreboardColumnConnection
        pin_to_sibling			ScoreboardTeammateBackground9
        pin_corner_to_sibling	1
        pin_to_sibling_corner	1
    }
    ScoreboardTeammatePing9
    {
        ControlName				Label
        InheritProperties 		ScoreboardPing
        pin_to_sibling			ScoreboardTeammateBackground9
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateColumn6_9
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateConnection_9
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        xpos					1
    }
    ScoreboardTeammateColumn5_9
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn6_9
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn4_9
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn5_9
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn3_9
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn4_9
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn2_9
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn3_9
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn1_9
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn2_9
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn0_9
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn1_9
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }

    ScoreboardTeammateBackground10
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayer
        pin_to_sibling			ScoreboardTeammateBackground9
        pin_corner_to_sibling	0
        pin_to_sibling_corner	2
    }
    ScoreboardTeammateSelection10
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayerSelection
        pin_to_sibling			ScoreboardTeammateBackground10
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammatePlayerNumber10
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerNumber
        pin_to_sibling			ScoreboardTeammateBackground10
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammateMic10
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerMic
        pin_to_sibling			ScoreboardTeammatePlayerNumber10
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateStatus10
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerStatus
        pin_to_sibling			ScoreboardTeammateMic10
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateArt10
    {
        ControlName				CNestedPanel
        InheritProperties 		ScoreboardPlayerArt
        pin_to_sibling			ScoreboardTeammateStatus10
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateLvl10
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerLevel
        pin_to_sibling			ScoreboardTeammateArt10
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateName10
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerName
        pin_to_sibling			ScoreboardTeammateLvl10
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammatePartyLeader10
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerPartyLeader
        pin_to_sibling			ScoreboardTeammateName10
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammateConnection10
    {
        ControlName				ImagePanel	[$GAMECONSOLE]
        ControlName				Label 		[!$GAMECONSOLE]
        InheritProperties 		ScoreboardColumnConnection
        pin_to_sibling			ScoreboardTeammateBackground10
        pin_corner_to_sibling	1
        pin_to_sibling_corner	1
    }
    ScoreboardTeammatePing10
    {
        ControlName				Label
        InheritProperties 		ScoreboardPing
        pin_to_sibling			ScoreboardTeammateBackground10
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateColumn6_10
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateConnection_10
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        xpos					1
    }
    ScoreboardTeammateColumn5_10
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn6_10
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn4_10
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn5_10
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn3_10
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn4_10
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn2_10
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn3_10
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn1_10
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn2_10
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn0_10
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn1_10
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }

    ScoreboardTeammateBackground11
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayer
        pin_to_sibling			ScoreboardTeammateBackground10
        pin_corner_to_sibling	0
        pin_to_sibling_corner	2
    }
    ScoreboardTeammateSelection11
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayerSelection
        pin_to_sibling			ScoreboardTeammateBackground11
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammatePlayerNumber11
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerNumber
        pin_to_sibling			ScoreboardTeammateBackground11
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammateMic11
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerMic
        pin_to_sibling			ScoreboardTeammatePlayerNumber11
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateStatus11
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerStatus
        pin_to_sibling			ScoreboardTeammateMic11
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateArt11
    {
        ControlName				CNestedPanel
        InheritProperties 		ScoreboardPlayerArt
        pin_to_sibling			ScoreboardTeammateStatus11
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateLvl11
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerLevel
        pin_to_sibling			ScoreboardTeammateArt11
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateName11
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerName
        pin_to_sibling			ScoreboardTeammateLvl11
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammatePartyLeader11
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerPartyLeader
        pin_to_sibling			ScoreboardTeammateName11
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammateConnection11
    {
        ControlName				ImagePanel	[$GAMECONSOLE]
        ControlName				Label 		[!$GAMECONSOLE]
        InheritProperties 		ScoreboardColumnConnection
        pin_to_sibling			ScoreboardTeammateBackground11
        pin_corner_to_sibling	1
        pin_to_sibling_corner	1
    }
    ScoreboardTeammatePing11
    {
        ControlName				Label
        InheritProperties 		ScoreboardPing
        pin_to_sibling			ScoreboardTeammateBackground11
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateColumn6_11
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateConnection_11
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        xpos					1
    }
    ScoreboardTeammateColumn5_11
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn6_11
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn4_11
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn5_11
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn3_11
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn4_11
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn2_11
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn3_11
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn1_11
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn2_11
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn0_11
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn1_11
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }

    ScoreboardTeammateBackground12
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayer
        pin_to_sibling			ScoreboardTeammateBackground11
        pin_corner_to_sibling	0
        pin_to_sibling_corner	2
    }
    ScoreboardTeammateSelection12
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayerSelection
        pin_to_sibling			ScoreboardTeammateBackground12
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammatePlayerNumber12
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerNumber
        pin_to_sibling			ScoreboardTeammateBackground12
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammateMic12
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerMic
        pin_to_sibling			ScoreboardTeammatePlayerNumber12
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateStatus12
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerStatus
        pin_to_sibling			ScoreboardTeammateMic12
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateArt12
    {
        ControlName				CNestedPanel
        InheritProperties 		ScoreboardPlayerArt
        pin_to_sibling			ScoreboardTeammateStatus12
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateLvl12
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerLevel
        pin_to_sibling			ScoreboardTeammateArt12
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateName12
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerName
        pin_to_sibling			ScoreboardTeammateLvl12
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammatePartyLeader12
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerPartyLeader
        pin_to_sibling			ScoreboardTeammateName12
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammateConnection12
    {
        ControlName				ImagePanel	[$GAMECONSOLE]
        ControlName				Label 		[!$GAMECONSOLE]
        InheritProperties 		ScoreboardColumnConnection
        pin_to_sibling			ScoreboardTeammateBackground12
        pin_corner_to_sibling	1
        pin_to_sibling_corner	1
    }
    ScoreboardTeammatePing12
    {
        ControlName				Label
        InheritProperties 		ScoreboardPing
        pin_to_sibling			ScoreboardTeammateBackground12
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateColumn6_12
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateConnection_12
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        xpos					1
    }
    ScoreboardTeammateColumn5_12
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn6_12
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn4_12
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn5_12
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn3_12
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn4_12
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn2_12
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn3_12
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn1_12
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn2_12
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn0_12
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn1_12
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }

    ScoreboardTeammateBackground13
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayer
        pin_to_sibling			ScoreboardTeammateBackground12
        pin_corner_to_sibling	0
        pin_to_sibling_corner	2
    }
    ScoreboardTeammateSelection13
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayerSelection
        pin_to_sibling			ScoreboardTeammateBackground13
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammatePlayerNumber13
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerNumber
        pin_to_sibling			ScoreboardTeammateBackground13
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammateMic13
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerMic
        pin_to_sibling			ScoreboardTeammatePlayerNumber13
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateStatus13
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerStatus
        pin_to_sibling			ScoreboardTeammateMic13
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateArt13
    {
        ControlName				CNestedPanel
        InheritProperties 		ScoreboardPlayerArt
        pin_to_sibling			ScoreboardTeammateStatus13
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateLvl13
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerLevel
        pin_to_sibling			ScoreboardTeammateArt13
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateName13
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerName
        pin_to_sibling			ScoreboardTeammateLvl13
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammatePartyLeader13
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerPartyLeader
        pin_to_sibling			ScoreboardTeammateName13
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammateConnection13
    {
        ControlName				ImagePanel	[$GAMECONSOLE]
        ControlName				Label 		[!$GAMECONSOLE]
        InheritProperties 		ScoreboardColumnConnection
        pin_to_sibling			ScoreboardTeammateBackground13
        pin_corner_to_sibling	1
        pin_to_sibling_corner	1
    }
    ScoreboardTeammatePing13
    {
        ControlName				Label
        InheritProperties 		ScoreboardPing
        pin_to_sibling			ScoreboardTeammateBackground13
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateColumn6_13
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateConnection_13
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        xpos					1
    }
    ScoreboardTeammateColumn5_13
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn6_13
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn4_13
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn5_13
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn3_13
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn4_13
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn2_13
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn3_13
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn1_13
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn2_13
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn0_13
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn1_13
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }

    ScoreboardTeammateBackground14
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayer
        pin_to_sibling			ScoreboardTeammateBackground13
        pin_corner_to_sibling	0
        pin_to_sibling_corner	2
    }
    ScoreboardTeammateSelection14
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayerSelection
        pin_to_sibling			ScoreboardTeammateBackground14
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammatePlayerNumber14
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerNumber
        pin_to_sibling			ScoreboardTeammateBackground14
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammateMic14
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerMic
        pin_to_sibling			ScoreboardTeammatePlayerNumber14
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateStatus14
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerStatus
        pin_to_sibling			ScoreboardTeammateMic14
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateArt14
    {
        ControlName				CNestedPanel
        InheritProperties 		ScoreboardPlayerArt
        pin_to_sibling			ScoreboardTeammateStatus14
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateLvl14
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerLevel
        pin_to_sibling			ScoreboardTeammateArt14
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateName14
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerName
        pin_to_sibling			ScoreboardTeammateLvl14
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammatePartyLeader14
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerPartyLeader
        pin_to_sibling			ScoreboardTeammateName14
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammateConnection14
    {
        ControlName				ImagePanel	[$GAMECONSOLE]
        ControlName				Label 		[!$GAMECONSOLE]
        InheritProperties 		ScoreboardColumnConnection
        pin_to_sibling			ScoreboardTeammateBackground14
        pin_corner_to_sibling	1
        pin_to_sibling_corner	1
    }
    ScoreboardTeammatePing14
    {
        ControlName				Label
        InheritProperties 		ScoreboardPing
        pin_to_sibling			ScoreboardTeammateBackground14
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateColumn6_14
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateConnection_14
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        xpos					1
    }
    ScoreboardTeammateColumn5_14
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn6_14
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn4_14
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn5_14
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn3_14
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn4_14
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn2_14
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn3_14
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn1_14
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn2_14
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn0_14
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn1_14
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }

    ScoreboardTeammateBackground15
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayer
        pin_to_sibling			ScoreboardTeammateBackground14
        pin_corner_to_sibling	0
        pin_to_sibling_corner	2
    }
    ScoreboardTeammateSelection15
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayerSelection
        pin_to_sibling			ScoreboardTeammateBackground15
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammatePlayerNumber15
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerNumber
        pin_to_sibling			ScoreboardTeammateBackground15
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammateMic15
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerMic
        pin_to_sibling			ScoreboardTeammatePlayerNumber15
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateStatus15
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerStatus
        pin_to_sibling			ScoreboardTeammateMic15
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateArt15
    {
        ControlName				CNestedPanel
        InheritProperties 		ScoreboardPlayerArt
        pin_to_sibling			ScoreboardTeammateStatus15
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateLvl15
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerLevel
        pin_to_sibling			ScoreboardTeammateArt15
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateName15
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerName
        pin_to_sibling			ScoreboardTeammateLvl15
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammatePartyLeader15
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerPartyLeader
        pin_to_sibling			ScoreboardTeammateName15
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammateConnection15
    {
        ControlName				ImagePanel	[$GAMECONSOLE]
        ControlName				Label 		[!$GAMECONSOLE]
        InheritProperties 		ScoreboardColumnConnection
        pin_to_sibling			ScoreboardTeammateBackground15
        pin_corner_to_sibling	1
        pin_to_sibling_corner	1
    }
    ScoreboardTeammatePing15
    {
        ControlName				Label
        InheritProperties 		ScoreboardPing
        pin_to_sibling			ScoreboardTeammateBackground15
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateColumn6_15
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateConnection_15
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        xpos					1
    }
    ScoreboardTeammateColumn5_15
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn6_15
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn4_15
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn5_15
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn3_15
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn4_15
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn2_15
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn3_15
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn1_15
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn2_15
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn0_15
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn1_15
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }

    ScoreboardTeammateBackground16
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayer
        pin_to_sibling			ScoreboardTeammateBackground15
        pin_corner_to_sibling	0
        pin_to_sibling_corner	2
    }
    ScoreboardTeammateSelection16
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayerSelection
        pin_to_sibling			ScoreboardTeammateBackground16
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammatePlayerNumber16
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerNumber
        pin_to_sibling			ScoreboardTeammateBackground16
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammateMic16
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerMic
        pin_to_sibling			ScoreboardTeammatePlayerNumber16
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateStatus16
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerStatus
        pin_to_sibling			ScoreboardTeammateMic16
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateArt16
    {
        ControlName				CNestedPanel
        InheritProperties 		ScoreboardPlayerArt
        pin_to_sibling			ScoreboardTeammateStatus16
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateLvl16
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerLevel
        pin_to_sibling			ScoreboardTeammateArt16
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateName16
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerName
        pin_to_sibling			ScoreboardTeammateLvl16
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammatePartyLeader16
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerPartyLeader
        pin_to_sibling			ScoreboardTeammateName16
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammateConnection16
    {
        ControlName				ImagePanel	[$GAMECONSOLE]
        ControlName				Label 		[!$GAMECONSOLE]
        InheritProperties 		ScoreboardColumnConnection
        pin_to_sibling			ScoreboardTeammateBackground16
        pin_corner_to_sibling	1
        pin_to_sibling_corner	1
    }
    ScoreboardTeammatePing16
    {
        ControlName				Label
        InheritProperties 		ScoreboardPing
        pin_to_sibling			ScoreboardTeammateBackground16
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateColumn6_16
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateConnection_16
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        xpos					1
    }
    ScoreboardTeammateColumn5_16
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn6_16
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn4_16
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn5_16
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn3_16
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn4_16
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn2_16
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn3_16
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn1_16
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn2_16
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn0_16
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn1_16
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }

    ScoreboardTeammateBackground17
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayer
        pin_to_sibling			ScoreboardTeammateBackground16
        pin_corner_to_sibling	0
        pin_to_sibling_corner	2
    }
    ScoreboardTeammateSelection17
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayerSelection
        pin_to_sibling			ScoreboardTeammateBackground17
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammatePlayerNumber17
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerNumber
        pin_to_sibling			ScoreboardTeammateBackground17
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammateMic17
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerMic
        pin_to_sibling			ScoreboardTeammatePlayerNumber17
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateStatus17
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerStatus
        pin_to_sibling			ScoreboardTeammateMic17
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateArt17
    {
        ControlName				CNestedPanel
        InheritProperties 		ScoreboardPlayerArt
        pin_to_sibling			ScoreboardTeammateStatus17
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateLvl17
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerLevel
        pin_to_sibling			ScoreboardTeammateArt17
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateName17
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerName
        pin_to_sibling			ScoreboardTeammateLvl17
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammatePartyLeader17
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerPartyLeader
        pin_to_sibling			ScoreboardTeammateName17
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardTeammateConnection17
    {
        ControlName				ImagePanel	[$GAMECONSOLE]
        ControlName				Label 		[!$GAMECONSOLE]
        InheritProperties 		ScoreboardColumnConnection
        pin_to_sibling			ScoreboardTeammateBackground17
        pin_corner_to_sibling	1
        pin_to_sibling_corner	1
    }
    ScoreboardTeammatePing17
    {
        ControlName				Label
        InheritProperties 		ScoreboardPing
        pin_to_sibling			ScoreboardTeammateBackground17
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardTeammateColumn6_17
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateConnection_17
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        xpos					1
    }
    ScoreboardTeammateColumn5_17
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn6_17
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn4_17
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn5_17
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn3_17
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn4_17
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn2_17
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn3_17
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn1_17
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn2_17
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardTeammateColumn0_17
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardTeammateColumn1_17
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }

    ScoreboardOpponentBackground8
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayer
        pin_to_sibling			ScoreboardOpponentBackground7
        pin_corner_to_sibling	0
        pin_to_sibling_corner	2
    }
    ScoreboardOpponentSelection8
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayerSelection
        pin_to_sibling			ScoreboardOpponentBackground8
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentPlayerNumber8
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerNumber
        pin_to_sibling			ScoreboardOpponentBackground8
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentMic8
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerMic
        pin_to_sibling			ScoreboardOpponentPlayerNumber8
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentStatus8
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerStatus
        pin_to_sibling			ScoreboardOpponentMic8
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentArt8
    {
        ControlName				CNestedPanel
        InheritProperties 		ScoreboardPlayerArt
        pin_to_sibling			ScoreboardOpponentStatus8
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentLvl8
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerLevel
        pin_to_sibling			ScoreboardOpponentArt8
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentName8
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerName
        pin_to_sibling			ScoreboardOpponentLvl8
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentPartyLeader8
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerPartyLeader
        pin_to_sibling			ScoreboardOpponentName8
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentConnection8
    {
        ControlName				ImagePanel	[$GAMECONSOLE]
        ControlName				Label 		[!$GAMECONSOLE]
        InheritProperties 		ScoreboardColumnConnection
        pin_to_sibling			ScoreboardOpponentBackground8
        pin_corner_to_sibling	1
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentPing8
    {
        ControlName				Label
        InheritProperties 		ScoreboardPing
        pin_to_sibling			ScoreboardOpponentBackground8
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentColumn6_8
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentConnection_8
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        xpos					1
    }
    ScoreboardOpponentColumn5_8
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn6_8
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn4_8
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn5_8
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn3_8
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn4_8
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn2_8
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn3_8
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn1_8
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn2_8
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn0_8
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn1_8
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }

    ScoreboardOpponentBackground9
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayer
        pin_to_sibling			ScoreboardOpponentBackground8
        pin_corner_to_sibling	0
        pin_to_sibling_corner	2
    }
    ScoreboardOpponentSelection9
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayerSelection
        pin_to_sibling			ScoreboardOpponentBackground9
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentPlayerNumber9
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerNumber
        pin_to_sibling			ScoreboardOpponentBackground9
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentMic9
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerMic
        pin_to_sibling			ScoreboardOpponentPlayerNumber9
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentStatus9
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerStatus
        pin_to_sibling			ScoreboardOpponentMic9
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentArt9
    {
        ControlName				CNestedPanel
        InheritProperties 		ScoreboardPlayerArt
        pin_to_sibling			ScoreboardOpponentStatus9
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentLvl9
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerLevel
        pin_to_sibling			ScoreboardOpponentArt9
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentName9
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerName
        pin_to_sibling			ScoreboardOpponentLvl9
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentPartyLeader9
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerPartyLeader
        pin_to_sibling			ScoreboardOpponentName9
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentConnection9
    {
        ControlName				ImagePanel	[$GAMECONSOLE]
        ControlName				Label 		[!$GAMECONSOLE]
        InheritProperties 		ScoreboardColumnConnection
        pin_to_sibling			ScoreboardOpponentBackground9
        pin_corner_to_sibling	1
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentPing9
    {
        ControlName				Label
        InheritProperties 		ScoreboardPing
        pin_to_sibling			ScoreboardOpponentBackground9
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentColumn6_9
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentConnection_9
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        xpos					1
    }
    ScoreboardOpponentColumn5_9
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn6_9
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn4_9
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn5_9
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn3_9
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn4_9
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn2_9
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn3_9
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn1_9
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn2_9
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn0_9
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn1_9
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }

    ScoreboardOpponentBackground10
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayer
        pin_to_sibling			ScoreboardOpponentBackground9
        pin_corner_to_sibling	0
        pin_to_sibling_corner	2
    }
    ScoreboardOpponentSelection10
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayerSelection
        pin_to_sibling			ScoreboardOpponentBackground10
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentPlayerNumber10
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerNumber
        pin_to_sibling			ScoreboardOpponentBackground10
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentMic10
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerMic
        pin_to_sibling			ScoreboardOpponentPlayerNumber10
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentStatus10
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerStatus
        pin_to_sibling			ScoreboardOpponentMic10
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentArt10
    {
        ControlName				CNestedPanel
        InheritProperties 		ScoreboardPlayerArt
        pin_to_sibling			ScoreboardOpponentStatus10
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentLvl10
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerLevel
        pin_to_sibling			ScoreboardOpponentArt10
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentName10
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerName
        pin_to_sibling			ScoreboardOpponentLvl10
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentPartyLeader10
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerPartyLeader
        pin_to_sibling			ScoreboardOpponentName10
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentConnection10
    {
        ControlName				ImagePanel	[$GAMECONSOLE]
        ControlName				Label 		[!$GAMECONSOLE]
        InheritProperties 		ScoreboardColumnConnection
        pin_to_sibling			ScoreboardOpponentBackground10
        pin_corner_to_sibling	1
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentPing10
    {
        ControlName				Label
        InheritProperties 		ScoreboardPing
        pin_to_sibling			ScoreboardOpponentBackground10
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentColumn6_10
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentConnection_10
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        xpos					1
    }
    ScoreboardOpponentColumn5_10
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn6_10
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn4_10
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn5_10
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn3_10
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn4_10
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn2_10
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn3_10
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn1_10
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn2_10
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn0_10
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn1_10
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }

    ScoreboardOpponentBackground11
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayer
        pin_to_sibling			ScoreboardOpponentBackground10
        pin_corner_to_sibling	0
        pin_to_sibling_corner	2
    }
    ScoreboardOpponentSelection11
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayerSelection
        pin_to_sibling			ScoreboardOpponentBackground11
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentPlayerNumber11
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerNumber
        pin_to_sibling			ScoreboardOpponentBackground11
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentMic11
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerMic
        pin_to_sibling			ScoreboardOpponentPlayerNumber11
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentStatus11
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerStatus
        pin_to_sibling			ScoreboardOpponentMic11
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentArt11
    {
        ControlName				CNestedPanel
        InheritProperties 		ScoreboardPlayerArt
        pin_to_sibling			ScoreboardOpponentStatus11
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentLvl11
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerLevel
        pin_to_sibling			ScoreboardOpponentArt11
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentName11
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerName
        pin_to_sibling			ScoreboardOpponentLvl11
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentPartyLeader11
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerPartyLeader
        pin_to_sibling			ScoreboardOpponentName11
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentConnection11
    {
        ControlName				ImagePanel	[$GAMECONSOLE]
        ControlName				Label 		[!$GAMECONSOLE]
        InheritProperties 		ScoreboardColumnConnection
        pin_to_sibling			ScoreboardOpponentBackground11
        pin_corner_to_sibling	1
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentPing11
    {
        ControlName				Label
        InheritProperties 		ScoreboardPing
        pin_to_sibling			ScoreboardOpponentBackground11
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentColumn6_11
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentConnection_11
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        xpos					1
    }
    ScoreboardOpponentColumn5_11
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn6_11
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn4_11
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn5_11
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn3_11
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn4_11
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn2_11
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn3_11
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn1_11
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn2_11
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn0_11
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn1_11
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }

    ScoreboardOpponentBackground12
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayer
        pin_to_sibling			ScoreboardOpponentBackground11
        pin_corner_to_sibling	0
        pin_to_sibling_corner	2
    }
    ScoreboardOpponentSelection12
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayerSelection
        pin_to_sibling			ScoreboardOpponentBackground12
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentPlayerNumber12
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerNumber
        pin_to_sibling			ScoreboardOpponentBackground12
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentMic12
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerMic
        pin_to_sibling			ScoreboardOpponentPlayerNumber12
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentStatus12
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerStatus
        pin_to_sibling			ScoreboardOpponentMic12
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentArt12
    {
        ControlName				CNestedPanel
        InheritProperties 		ScoreboardPlayerArt
        pin_to_sibling			ScoreboardOpponentStatus12
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentLvl12
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerLevel
        pin_to_sibling			ScoreboardOpponentArt12
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentName12
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerName
        pin_to_sibling			ScoreboardOpponentLvl12
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentPartyLeader12
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerPartyLeader
        pin_to_sibling			ScoreboardOpponentName12
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentConnection12
    {
        ControlName				ImagePanel	[$GAMECONSOLE]
        ControlName				Label 		[!$GAMECONSOLE]
        InheritProperties 		ScoreboardColumnConnection
        pin_to_sibling			ScoreboardOpponentBackground12
        pin_corner_to_sibling	1
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentPing12
    {
        ControlName				Label
        InheritProperties 		ScoreboardPing
        pin_to_sibling			ScoreboardOpponentBackground12
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentColumn6_12
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentConnection_12
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        xpos					1
    }
    ScoreboardOpponentColumn5_12
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn6_12
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn4_12
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn5_12
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn3_12
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn4_12
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn2_12
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn3_12
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn1_12
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn2_12
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn0_12
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn1_12
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }

    ScoreboardOpponentBackground13
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayer
        pin_to_sibling			ScoreboardOpponentBackground12
        pin_corner_to_sibling	0
        pin_to_sibling_corner	2
    }
    ScoreboardOpponentSelection13
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayerSelection
        pin_to_sibling			ScoreboardOpponentBackground13
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentPlayerNumber13
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerNumber
        pin_to_sibling			ScoreboardOpponentBackground13
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentMic13
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerMic
        pin_to_sibling			ScoreboardOpponentPlayerNumber13
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentStatus13
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerStatus
        pin_to_sibling			ScoreboardOpponentMic13
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentArt13
    {
        ControlName				CNestedPanel
        InheritProperties 		ScoreboardPlayerArt
        pin_to_sibling			ScoreboardOpponentStatus13
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentLvl13
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerLevel
        pin_to_sibling			ScoreboardOpponentArt13
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentName13
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerName
        pin_to_sibling			ScoreboardOpponentLvl13
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentPartyLeader13
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerPartyLeader
        pin_to_sibling			ScoreboardOpponentName13
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentConnection13
    {
        ControlName				ImagePanel	[$GAMECONSOLE]
        ControlName				Label 		[!$GAMECONSOLE]
        InheritProperties 		ScoreboardColumnConnection
        pin_to_sibling			ScoreboardOpponentBackground13
        pin_corner_to_sibling	1
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentPing13
    {
        ControlName				Label
        InheritProperties 		ScoreboardPing
        pin_to_sibling			ScoreboardOpponentBackground13
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentColumn6_13
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentConnection_13
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        xpos					1
    }
    ScoreboardOpponentColumn5_13
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn6_13
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn4_13
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn5_13
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn3_13
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn4_13
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn2_13
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn3_13
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn1_13
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn2_13
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn0_13
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn1_13
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }

    ScoreboardOpponentBackground14
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayer
        pin_to_sibling			ScoreboardOpponentBackground13
        pin_corner_to_sibling	0
        pin_to_sibling_corner	2
    }
    ScoreboardOpponentSelection14
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayerSelection
        pin_to_sibling			ScoreboardOpponentBackground14
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentPlayerNumber14
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerNumber
        pin_to_sibling			ScoreboardOpponentBackground14
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentMic14
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerMic
        pin_to_sibling			ScoreboardOpponentPlayerNumber14
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentStatus14
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerStatus
        pin_to_sibling			ScoreboardOpponentMic14
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentArt14
    {
        ControlName				CNestedPanel
        InheritProperties 		ScoreboardPlayerArt
        pin_to_sibling			ScoreboardOpponentStatus14
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentLvl14
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerLevel
        pin_to_sibling			ScoreboardOpponentArt14
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentName14
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerName
        pin_to_sibling			ScoreboardOpponentLvl14
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentPartyLeader14
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerPartyLeader
        pin_to_sibling			ScoreboardOpponentName14
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentConnection14
    {
        ControlName				ImagePanel	[$GAMECONSOLE]
        ControlName				Label 		[!$GAMECONSOLE]
        InheritProperties 		ScoreboardColumnConnection
        pin_to_sibling			ScoreboardOpponentBackground14
        pin_corner_to_sibling	1
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentPing14
    {
        ControlName				Label
        InheritProperties 		ScoreboardPing
        pin_to_sibling			ScoreboardOpponentBackground14
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentColumn6_14
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentConnection_14
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        xpos					1
    }
    ScoreboardOpponentColumn5_14
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn6_14
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn4_14
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn5_14
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn3_14
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn4_14
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn2_14
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn3_14
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn1_14
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn2_14
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn0_14
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn1_14
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }

    ScoreboardOpponentBackground15
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayer
        pin_to_sibling			ScoreboardOpponentBackground14
        pin_corner_to_sibling	0
        pin_to_sibling_corner	2
    }
    ScoreboardOpponentSelection15
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayerSelection
        pin_to_sibling			ScoreboardOpponentBackground15
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentPlayerNumber15
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerNumber
        pin_to_sibling			ScoreboardOpponentBackground15
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentMic15
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerMic
        pin_to_sibling			ScoreboardOpponentPlayerNumber15
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentStatus15
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerStatus
        pin_to_sibling			ScoreboardOpponentMic15
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentArt15
    {
        ControlName				CNestedPanel
        InheritProperties 		ScoreboardPlayerArt
        pin_to_sibling			ScoreboardOpponentStatus15
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentLvl15
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerLevel
        pin_to_sibling			ScoreboardOpponentArt15
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentName15
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerName
        pin_to_sibling			ScoreboardOpponentLvl15
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentPartyLeader15
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerPartyLeader
        pin_to_sibling			ScoreboardOpponentName15
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentConnection15
    {
        ControlName				ImagePanel	[$GAMECONSOLE]
        ControlName				Label 		[!$GAMECONSOLE]
        InheritProperties 		ScoreboardColumnConnection
        pin_to_sibling			ScoreboardOpponentBackground15
        pin_corner_to_sibling	1
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentPing15
    {
        ControlName				Label
        InheritProperties 		ScoreboardPing
        pin_to_sibling			ScoreboardOpponentBackground15
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentColumn6_15
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentConnection_15
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        xpos					1
    }
    ScoreboardOpponentColumn5_15
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn6_15
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn4_15
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn5_15
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn3_15
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn4_15
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn2_15
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn3_15
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn1_15
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn2_15
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn0_15
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn1_15
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }

    ScoreboardOpponentBackground16
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayer
        pin_to_sibling			ScoreboardOpponentBackground15
        pin_corner_to_sibling	0
        pin_to_sibling_corner	2
    }
    ScoreboardOpponentSelection16
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayerSelection
        pin_to_sibling			ScoreboardOpponentBackground16
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentPlayerNumber16
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerNumber
        pin_to_sibling			ScoreboardOpponentBackground16
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentMic16
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerMic
        pin_to_sibling			ScoreboardOpponentPlayerNumber16
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentStatus16
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerStatus
        pin_to_sibling			ScoreboardOpponentMic16
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentArt16
    {
        ControlName				CNestedPanel
        InheritProperties 		ScoreboardPlayerArt
        pin_to_sibling			ScoreboardOpponentStatus16
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentLvl16
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerLevel
        pin_to_sibling			ScoreboardOpponentArt16
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentName16
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerName
        pin_to_sibling			ScoreboardOpponentLvl16
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentPartyLeader16
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerPartyLeader
        pin_to_sibling			ScoreboardOpponentName16
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentConnection16
    {
        ControlName				ImagePanel	[$GAMECONSOLE]
        ControlName				Label 		[!$GAMECONSOLE]
        InheritProperties 		ScoreboardColumnConnection
        pin_to_sibling			ScoreboardOpponentBackground16
        pin_corner_to_sibling	1
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentPing16
    {
        ControlName				Label
        InheritProperties 		ScoreboardPing
        pin_to_sibling			ScoreboardOpponentBackground16
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentColumn6_16
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentConnection_16
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        xpos					1
    }
    ScoreboardOpponentColumn5_16
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn6_16
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn4_16
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn5_16
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn3_16
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn4_16
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn2_16
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn3_16
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn1_16
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn2_16
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn0_16
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn1_16
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }

    ScoreboardOpponentBackground17
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayer
        pin_to_sibling			ScoreboardOpponentBackground16
        pin_corner_to_sibling	0
        pin_to_sibling_corner	2
    }
    ScoreboardOpponentSelection17
    {
        ControlName				ImagePanel
        InheritProperties		ScoreboardPlayerSelection
        pin_to_sibling			ScoreboardOpponentBackground17
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentPlayerNumber17
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerNumber
        pin_to_sibling			ScoreboardOpponentBackground17
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentMic17
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerMic
        pin_to_sibling			ScoreboardOpponentPlayerNumber17
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentStatus17
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerStatus
        pin_to_sibling			ScoreboardOpponentMic17
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentArt17
    {
        ControlName				CNestedPanel
        InheritProperties 		ScoreboardPlayerArt
        pin_to_sibling			ScoreboardOpponentStatus17
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentLvl17
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerLevel
        pin_to_sibling			ScoreboardOpponentArt17
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentName17
    {
        ControlName				Label
        InheritProperties 		ScoreboardPlayerName
        pin_to_sibling			ScoreboardOpponentLvl17
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentPartyLeader17
    {
        ControlName				ImagePanel
        InheritProperties 		ScoreboardPlayerPartyLeader
        pin_to_sibling			ScoreboardOpponentName17
        pin_corner_to_sibling	0
        pin_to_sibling_corner	0
    }
    ScoreboardOpponentConnection17
    {
        ControlName				ImagePanel	[$GAMECONSOLE]
        ControlName				Label 		[!$GAMECONSOLE]
        InheritProperties 		ScoreboardColumnConnection
        pin_to_sibling			ScoreboardOpponentBackground17
        pin_corner_to_sibling	1
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentPing17
    {
        ControlName				Label
        InheritProperties 		ScoreboardPing
        pin_to_sibling			ScoreboardOpponentBackground17
        pin_corner_to_sibling	0
        pin_to_sibling_corner	1
    }
    ScoreboardOpponentColumn6_17
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentConnection_17
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        xpos					1
    }
    ScoreboardOpponentColumn5_17
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn6_17
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn4_17
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn5_17
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn3_17
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn4_17
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn2_17
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn3_17
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn1_17
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn2_17
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
    ScoreboardOpponentColumn0_17
    {
        ControlName				Label
        InheritProperties 		ScoreboardColumnData
        pin_to_sibling			ScoreboardOpponentColumn1_17
        pin_corner_to_sibling	1
        pin_to_sibling_corner	0
        
    }
}
