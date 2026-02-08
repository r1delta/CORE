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
		labelText				"#X_BUTTON_MUTE"
		// labelText				"#Y_BUTTON_PLAYER_PROFILE" [!$GAMECONSOLE]
		// labelText				"#Y_BUTTON_GAMERCARD" [$GAMECONSOLE]
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
		visible					0
		enabled					0
	}

	ScoreboardKeyboardFooterButton0
	{
		ControlName				Label
		classname				ScoreboardKeyboardFooterButtonClass
		zpos					3
		auto_wide_tocontents 	1
		tall 					16
		font					FooterFont
		allcaps					1
		fgcolor_override 		"255 255 255 255" // HudBase160 is bad, and is defaulting everything to have 160 alpha
		enabled					1
		visible					1

		pin_to_sibling 			ScoreboardBackground
		pin_corner_to_sibling	1
		pin_to_sibling_corner	3
		ypos 					2
		labelText				"#SCOREBOARD_KB_MUTE"

		activeInputExclusivePaint	keyboard
	}
	ScoreboardKeyboardFooterButton1
	{
		ControlName				Label
		classname				ScoreboardKeyboardFooterButtonClass
		zpos					3
		auto_wide_tocontents 	1
		tall 					16
		font					FooterFont
		allcaps					1
		fgcolor_override 		"255 255 255 255" // HudBase160 is bad, and is defaulting everything to have 160 alpha
		enabled					1
		visible					1

		pin_to_sibling			ScoreboardKeyboardFooterButton0
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		xpos 					10
		labelText				"#SCOREBOARD_KB_SCROLL_DOWN"

		activeInputExclusivePaint	keyboard
	}
	ScoreboardKeyboardFooterButton2
	{
		ControlName				Label
		classname				ScoreboardKeyboardFooterButtonClass
		zpos					3
		auto_wide_tocontents 	1
		tall 					16
		font					FooterFont
		allcaps					1
		fgcolor_override 		"255 255 255 255" // HudBase160 is bad, and is defaulting everything to have 160 alpha
		enabled					1
		visible					1

		pin_to_sibling			ScoreboardKeyboardFooterButton1
		pin_corner_to_sibling	1
		pin_to_sibling_corner	0
		xpos 					10
		labelText				"#SCOREBOARD_KB_SCROLL_UP"

		activeInputExclusivePaint	keyboard
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
}
