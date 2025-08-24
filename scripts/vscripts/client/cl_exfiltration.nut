function main()
{
	Globalize( Exfil_AddPlayer )

	AddCreateCallback( "prop_control_panel", OnPanelCreated )

	RegisterServerVarChangeCallback( "exfilState", UpdateExfilIcons )
	RegisterServerVarChangeCallback( "attackingTeam", UpdateExfilIcons )

	RegisterSignal( "FlagUpdate" )

	level.exfilPanels <- [ null, null ]
}


function Exfil_AddPlayer( player )
{
	player.InitHudElem( "SiteAArrow" )
	player.InitHudElem( "SiteBArrow" )

	player.InitHudElem( "SiteAIcon" )
	player.InitHudElem( "SiteBIcon" )

	player.InitHudElem( "SiteALabel" )
	player.InitHudElem( "SiteBLabel" )

	player.hudElems.SiteAArrow.SetOffscreenArrow( true )
	player.hudElems.SiteAArrow.SetClampToScreen( CLAMP_RECT )
	player.hudElems.SiteAArrow.SetClampBounds( CL_HIGHLIGHT_ARROW_X, CL_HIGHLIGHT_ARROW_Y )

	player.hudElems.SiteBArrow.SetOffscreenArrow( true )
	player.hudElems.SiteBArrow.SetClampToScreen( CLAMP_RECT )
	player.hudElems.SiteBArrow.SetClampBounds( CL_HIGHLIGHT_ARROW_X, CL_HIGHLIGHT_ARROW_Y )

	player.hudElems.SiteAIcon.SetClampToScreen( CLAMP_RECT )
	player.hudElems.SiteAIcon.SetClampBounds( CL_HIGHLIGHT_ICON_X, CL_HIGHLIGHT_ICON_Y )

	player.hudElems.SiteBIcon.SetClampToScreen( CLAMP_RECT )
	player.hudElems.SiteBIcon.SetClampBounds( CL_HIGHLIGHT_ICON_X, CL_HIGHLIGHT_ICON_Y )
}


function UpdateExfilIcons()
{
	local player = GetLocalViewPlayer()

	if ( level.nv.exfilState )
	{
		player.hudElems.SiteAArrow.Hide()
		player.hudElems.SiteAIcon.Hide()
		player.hudElems.SiteALabel.Hide()

		player.hudElems.SiteBArrow.Hide()
		player.hudElems.SiteBIcon.Hide()
		player.hudElems.SiteBLabel.Hide()
		return
	}

	if ( level.exfilPanels[0] )
	{
		local panelEnt = level.exfilPanels[0]

		player.hudElems.SiteAArrow.Show()
		player.hudElems.SiteAArrow.SetEntityOverhead( panelEnt, Vector( 0, 0, 0 ), 0.5, 1.0 )
		player.hudElems.SiteAIcon.Show()
		player.hudElems.SiteAIcon.SetEntityOverhead( panelEnt, Vector( 0, 0, 0 ), 0.5, 1.0 )
		player.hudElems.SiteALabel.Show()

		if ( player.GetTeam() == level.nv.attackingTeam )
		{
			player.hudElems.SiteAIcon.SetImage( "HUD/capture_point_status_orange_a" )
			player.hudElems.SiteALabel.SetText( "HACK" )
		}
		else
		{
			player.hudElems.SiteAIcon.SetImage( "HUD/capture_point_status_blue_a" )
			player.hudElems.SiteALabel.SetText( "DEFEND" )
		}
	}

	if ( level.exfilPanels[1] )
	{
		local panelEnt = level.exfilPanels[1]

		player.hudElems.SiteBArrow.Show()
		player.hudElems.SiteBArrow.SetEntityOverhead( panelEnt, Vector( 0, 0, 0 ), 0.5, 1.0 )
		player.hudElems.SiteBIcon.Show()
		player.hudElems.SiteBIcon.SetEntityOverhead( panelEnt, Vector( 0, 0, 0 ), 0.5, 1.0 )
		player.hudElems.SiteBLabel.Show()

		if ( player.GetTeam() == level.nv.attackingTeam )
		{
			player.hudElems.SiteBIcon.SetImage( "HUD/capture_point_status_orange_b" )
			player.hudElems.SiteBLabel.SetText( "HACK" )
		}
		else
		{
			player.hudElems.SiteBIcon.SetImage( "HUD/capture_point_status_blue_b" )
			player.hudElems.SiteBLabel.SetText( "DEFEND" )
		}
	}
}


function OnPanelCreated( panelEnt, isRecreate )
{
	local player = GetLocalViewPlayer()

	if ( panelEnt.GetName() == "exfil_panel_a" )
		level.exfilPanels[0] = panelEnt
	else if ( panelEnt.GetName() == "exfil_panel_b" )
		level.exfilPanels[1] = panelEnt

	UpdateExfilIcons()
}
