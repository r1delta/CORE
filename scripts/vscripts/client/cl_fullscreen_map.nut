function main()
{
	if ( IsMenuLevel() )
		return

	if ( !IsTrainingLevel() )
	{
		RegisterConCommandTriggeredCallback( "+displayFullscreenMap", FullscreenMinimapButtonPressed )
		RegisterConCommandTriggeredCallback( "-displayFullscreenMap", FullscreenMinimapButtonReleased )
	}

	if ( !reloadingScripts )
	{
		level.showingFullscreenMap <- false
		level.fullscreenMinimapEnabled <- true
	}

	file.fullscreenMinimapZoomAmount <- 1.0
	file.fullscreenMinimapXPos <- 0.0
	file.fullscreenMinimapYPos <- 0.0
	file.fullscreenMinimapRotation <- 0.0
}

function InitFullscreenMap()
{
	file.minimapFullscreenGroup <- HudElementGroup( "minimapFullscreen" )

	file.minimapFullscreenGroup.AddElement( HudElement( "MinimapFullscreen_Square" ) )
	for ( local i = 0; i < 4; i++ )
	{
		local bgBorder = HudElement( "MinimapBGFullscreen_Square_" + i )
		bgBorder.SetRotation( i * -90 )
		file.minimapFullscreenGroup.AddElement( bgBorder )
	}
	file.minimapFullscreenGroup.AddElement( HudElement( "MinimapCompass_Fullscreen" ) )

	file.minimapFullscreenGroup.Hide()
}
Globalize( InitFullscreenMap )

function FullscreenMinimapButtonPressed( player )
{
	if ( !IsAlive( player ) || IsWatchingKillReplay() || !level.fullscreenMinimapEnabled || Riff_MinimapState() == eMinimapState.Hidden || 	PlayerHasPassive( player, PAS_MINIMAP_ALL ) )
		return

	ShowFullMap( player )
}

function FullscreenMinimapButtonReleased( player )
{
	if ( !IsAlive( player ) || IsWatchingKillReplay() || !level.fullscreenMinimapEnabled || Riff_MinimapState() == eMinimapState.Hidden )
		return

	ResetAndShowMinimap( player )
}

function ShowFullMap( player )
{
	level.showingFullscreenMap = true
	SetCrosshairPriorityState( crosshairPriorityLevel.MENU, CROSSHAIR_STATE_HIDE_ALL )
	HideMinimap( player )
	file.minimapFullscreenGroup.Show()
	SetMinimapZoomOverride( file.fullscreenMinimapZoomAmount )//HACK / BUG -> should be redundant, but actually displays differently when doubled up with the next line.
	SetMinimapFullOverride( file.fullscreenMinimapXPos, file.fullscreenMinimapYPos, file.fullscreenMinimapRotation, file.fullscreenMinimapZoomAmount )
}

function ResetAndShowMinimap( player )
{
	level.showingFullscreenMap = false
	if ( !IsInScoreboard( player ) )
		ClearCrosshairPriority( crosshairPriorityLevel.MENU )
	file.minimapFullscreenGroup.Hide()
	ShowMinimap( player )
	ClearMinimapFullOverride()
	if ( GetCustomMinimapZoom() != null )
		SetMinimapZoomOverride( GetCustomMinimapZoom() )
	else
		ClearMinimapZoomOverride()
}
Globalize( ResetAndShowMinimap )

function ShowMinimap( player )
{
	local cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) )
		return

	local vgui = cockpit.GetMainVGUI()
	if ( !IsValid( vgui ) )
		return

	vgui.s.minimapGroup.Show()
	vgui.s.minimapOverlay.Hide()

	if ( GAMETYPE == COOPERATIVE )
		EnableCoopMinimap( cockpit, player )
}

function HideMinimap( player )
{
	local cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) )
		return

	local vgui = cockpit.GetMainVGUI()
	if ( !IsValid( vgui ) )
		return

	vgui.s.minimapGroup.Hide()
}

function SetFullscreenMinimapParameters( zoomAmount, xPos, yPos, rotation )
{
	file.fullscreenMinimapZoomAmount = zoomAmount
	file.fullscreenMinimapXPos = xPos
	file.fullscreenMinimapYPos = yPos
	file.fullscreenMinimapRotation = rotation
}
Globalize( SetFullscreenMinimapParameters )