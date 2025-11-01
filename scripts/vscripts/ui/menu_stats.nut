
function main()
{
	Globalize( OnOpenViewStats )
}

function OnOpenViewStats()
{
	InitStats_Overview()
	InitStats_Kills()
	InitStats_Time()
	InitStats_Distance()
	InitStats_Weapons()
	InitStats_Levels()
	InitStats_Misc()

	local menu = GetMenu( "ViewStatsMenu" )

	// Update the pilot image
	local pilotImage = GetElem( menu, "PilotImage" )
	if ( IsConnected() && GetTeam() == TEAM_IMC )
		pilotImage.SetImage( "../ui/menu/loadouts/pilot_character_male_battle_rifle_imc" )
	else
		pilotImage.SetImage( "../ui/menu/loadouts/pilot_character_male_battle_rifle_militia" )

	// XP Bar Panel
	local panel = GetElem( menu, "XPBarPanel" )

	// Player Level
	local elem = panel.GetChild( "LevelText" )
	elem.SetText( "#EOG_XP_BAR_LEVEL", GetLevel() )

	// Gen Icon
	elem = panel.GetChild( "GenIcon" )
	elem.SetImage( "../ui/menu/generation_icons/generation_" + GetGen() )
	elem.Show()

	// XP to Next Level
	local nextLevel = min( GetLevel() + 1, MAX_LEVEL )
	local xpReq = GetXPForLevel( nextLevel ) - GetXP()
	elem = panel.GetChild( "XPText" )
	elem.SetText( "#EOG_XP_BAR_XPCOUNT", xpReq )
	if ( GetLevel() == MAX_LEVEL )
		elem.SetText( "#EOG_XP_BAR_XPCOUNT_MAXED" )

	// XP Bar
	panel.GetChild( "BarFillNew" ).Hide()
	panel.GetChild( "BarFillNewColor" ).Hide()
	panel.GetChild( "BarFillFlash" ).Hide()

	local bar = panel.GetChild( "BarFillPrevious" )
	local barShadow = panel.GetChild( "BarFillShadow" )
	local startXP = GetXPForLevel( GetLevel() )
	local frac = GraphCapped( GetXP(), startXP, GetXPForLevel( nextLevel ), 0.0, 1.0 )
	bar.SetScaleX( frac )
	barShadow.SetScaleX( frac )
}