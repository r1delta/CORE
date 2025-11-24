const RODEO_SMOOTHING_ENABLED = 0

function main()
{
	Assert( IsClient() )
	Globalize( RodeoHUD_AddPlayer )
	Globalize( ServerCallback_RodeoScreenShake )
	Globalize( TitleScrollDown )
	Globalize( PlayRodeoAlertMedia )
	Globalize( ClientCodeCallback_RodeoHitTimeChanged )
	Globalize( RodeoWarningVGUI )
	Globalize( ShouldDrawRodeoVGUI )
	Globalize( DrawRodeoAlertIcons )
	Globalize( HasFriendlyRiderEnt )
	Globalize( HasEnemyRiderEnt )
	Globalize( CodeCallback_TitanRiderEntVarChanged )
	Globalize( CodeCallback_TitanRodeoedUpdated )
	Globalize( GetRodeoAlertEntity )

	IncludeFile( "_rodeo_shared" )
	RegisterSignal( "ClientRodeoOver" )
	RegisterSignal( "RodeoAlertStarted" )
	RegisterSignal( "StopRodeoAlert" )
	RegisterSignal( "StartRodeoAlert" )
	RegisterSignal( "UpdateRodeoAlert" )
	RegisterSignal( "client_rodeo_change" )


	PrecacheMaterial( "vgui/HUD/rodeo_icon_enemy" )
	PrecacheMaterial( "vgui/HUD/rodeo_icon_friendly" )

	file.smoothing <- false
}


//Client only function
if ( IsClient() )
{
	function RodeoHUD_AddPlayer(player)
	{
		player.InitHudElem( "RodeoAlertLabel" )
		player.InitHudElem( "RodeoAlertGlowLabel" )

		player.InitHudElem( "RodeoHitchHikeLabel" )
		player.InitHudElem( "RodeoHitchHikeGlowLabel" )

		player.InitHudElem( "RodeoAttackHintLabel" )
		player.InitHudElem( "RodeoAttackHintLabelGlow" )

		player.InitHudElem( "RodeoAlertGraphic" )
		player.InitHudElem( "RodeoWallSmashGraphic" )

		player.hudElems.RodeoAlertLabel.SetText( "FOREIGN OBJECT DETECTED!" )
		player.hudElems.RodeoAlertGlowLabel.SetText( "FOREIGN OBJECT DETECTED!" )

		player.s.previousRiderEnt <- null
	}
}

function ClientCodeCallback_RodeoHitTimeChanged( soul )
{
	//Defensive fix temporarily. Code probably shouldn't just pass us null. Remove when bug 36907 is resolved.
	if ( !IsValid( soul ) )
		return

	local titan = GetLocalPlayerFromSoul( soul )
	if ( !IsAlive( titan ) )
		return

	if ( ShouldDrawRodeoVGUI( titan ) )
	{
		if ( !HasFriendlyRiderEnt( titan ) )
			TitanCockpitDialog_RodeoAnnounce( titan )

		thread DrawRodeoAlertIcons( soul )
	}
}

function ServerCallback_RodeoScreenShake()
{
	Assert( IsClient() )
	local player = GetLocalViewPlayer()

	local max = 3
	for ( local i = 1; i <= max; i++ )
	{
		local direction = RandomVec( 1 )
		local frac = i / max
		frac *= 0.3
		// hack! this command is horrible and does not give desired result.
		ClientScreenShake( 15 * frac, 1.95 * frac, 0.40 * frac, direction )
		//printt( "direction ", direction )
//		ClientScreenShake( 24, 4.95, 0.40, direction )
	}
	//local direction = RandomVec( 1 )
//	local direction = Vector(0,0,0)
////	ClientScreenShake( 12, 2.95, 0.40, direction )
//	ClientScreenShake( 24, 4.95, 0.40, direction )
//	ClientScreenShake( 80, 10.95, 0.50, direction )
}

function GetLocalPlayerFromSoul( soul )
{
	local titan = soul.GetTitan()

	if ( !IsValid( titan ) )
		return null

	if ( titan.IsNPC() )
		return null

	Assert( titan.IsPlayer(), titan + " should be a player" )

	if ( titan != GetLocalViewPlayer() )
		return null

	return titan
}

function CodeCallback_TitanRiderEntVarChanged( soul )
{
	Assert( !IsServer() )
	if ( !IsValid( soul ) )
		return

	local rider = soul.GetRiderEnt()
	local player = GetLocalViewPlayer()
	if ( !IsAlive( rider ) )
	{
		soul.Signal( "StopRodeoAlert" )

		if ( !IsValid( player.s.previousRiderEnt ) )
			return
		if ( player.s.previousRiderEnt.GetTeam() == player.GetTeam() )
		{
			TitanCockpit_PlayDialog( GetLocalViewPlayer(), "rodeo_friendly_detach" )
			player.s.previousRiderEnt = null
		}

		return
	}

	local titan = GetLocalPlayerFromSoul( soul )
	if ( !IsValid( titan ) )
		return

	player.s.previousRiderEnt = rider

	// trapped hatch draws it always
	if ( ShouldDrawRodeoVGUI( titan ) )
	{
		TitanCockpitDialog_RodeoAnnounce( titan )
		thread DrawRodeoAlertIcons( soul )
	}
}

function TitanCockpitDialog_RodeoAnnounce( titan )
{
	Assert( ShouldDrawRodeoVGUI( titan ) )

	if ( HasFriendlyRiderEnt( titan ) )
	{
		TitanCockpit_PlayDialog( GetLocalViewPlayer(), "rodeo_friendly_attach" )
	}
	else
	{
		local soul = titan.GetTitanSoul()
		local riderEnt = soul.GetRiderEnt()

		local cockpitAlias = "rodeo_enemy_attach"
		if ( riderEnt.IsNPC() )
			cockpitAlias = "rodeo_enemy_spectre_attach"

		TitanCockpit_PlayDialog( GetLocalViewPlayer(), cockpitAlias )
	}
}
Globalize( TitanCockpitDialog_RodeoAnnounce )


//Show or hide the indication that you are rodeoing
function CodeCallback_TitanRodeoedUpdated( player )
{
	if ( player != GetLocalViewPlayer() )
		return

	player.Signal( "UpdateRodeoAlert" )

	if ( file.smoothing )
	{
		if ( !ShouldEnableRodeoSmoothing( player ) )
		{
			StopClientRodeo( player )
			return
		}
	}
	else
	{
		if ( ShouldEnableRodeoSmoothing( player ) )
		{
			thread StartClientRodeo( player )
			return
		}
	}
}

function StopClientRodeo( player )
{
	player.Signal( "client_rodeo_change" )
	player.hudElems.RodeoAttackHintLabel.Hide()
	player.hudElems.RodeoAttackHintLabelGlow.Hide()

	player.Signal( "ClientRodeoOver" )
	if ( RODEO_SMOOTHING_ENABLED )
		player.Rodeo_StopCameraSmoothing( 0.25 )
	file.smoothing = false
}

function StartClientRodeo( player )
{
	player.Signal( "client_rodeo_change" )
	player.EndSignal( "client_rodeo_change" )

	wait 1.5 // setting smoothing right when we parent makes a pop
	if ( RODEO_SMOOTHING_ENABLED )
		player.Rodeo_StartCameraSmoothing( 0.25 )
	file.smoothing = true
}

function ShouldEnableRodeoSmoothing( player )
{
	local soul = player.GetTitanSoulBeingRodeoed()
	if ( !soul )
		return false

	local titan = soul.GetTitan()
	if ( !IsValid( titan ) )
		return false

	return titan.GetTeam() == player.GetTeam()
}

function UpdateRodeoAttackHint( player )
{
	player.EndSignal( "ClientRodeoOver" )

	local displayText = ""
	local oldText
	local titan
	local soul = player.GetTitanSoulBeingRodeoed()
	local coord = [ 505, 170, true ]
	local scale = 5
	local alpha = 255

	for ( ;; )
	{
		wait 0
		if ( !IsValid( soul ) )
			break

		if ( !soul.nv.hasKey( "titan" ) )
		{
			printt( "Warning! This should be impossible!" )
			break
		}
		titan = soul.GetTitan()

		if ( !IsValid( player ) || !IsValid( titan ) )
		{
			break
		}

		if ( player.GetTeam() != GetOtherTeam( titan ) )
		{
			continue
		}

		if ( titan.GetHealth() <= 1 )
		{
			displayText  =  "Press [A] to jump off destroyed Titan"
		}
		else
		{
		//	displayText  =  "Press [RT] to plant explosive."
		}

		if ( oldText != displayText	)
		{
			DisplayRodeoHint( player, displayText )
		}

		oldText = displayText
	}
}

function DisplayRodeoHint( player, displayText )
{
	player.hudElems.RodeoAttackHintLabel.SetText(displayText)
	player.hudElems.RodeoAttackHintLabelGlow.SetText(displayText)
	player.hudElems.RodeoAttackHintLabel.Show()
	player.hudElems.RodeoAttackHintLabelGlow.Show()
}

function HideRodeoLabel( player )
{
	player.hudElems.RodeoAttackHintLabel.Hide()
	player.hudElems.RodeoAttackHintLabelGlow.Hide()
}

function LoopAlertSound( player )
{
	return
	player.EndSignal( "OnTitanLost" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "ClientRodeoOver" )
	player.EndSignal( "RodeoAlertStarted" )

	OnThreadEnd(
		function () : ( player )
		{
			if ( IsValid( player ) )
			{
				StopSoundOnEntity( player, "titan_alarm" )
			}
		}
	)

	for ( ;; )
	{
		local duration = EmitSoundOnEntity( player, "titan_alarm" )
		wait duration
	}
}

function HideRodeoAlertGraphicWithDebounce( player, startTime )
{
	OnThreadEnd(
		function () : ( player )
		{
			if ( IsValid( player ) )
			{
				player.hudElems.RodeoAlertLabel.Hide()
				player.hudElems.RodeoAlertGraphic.Hide()
			}
		}
	)

	if ( !IsAlive( player ) )
		return
	if ( !player.IsTitan() )
		return

	local timePassed = Time() - startTime
	local debounceTime = 1.8
	debounceTime -= timePassed

	local minDebounceTime = 0.5
	if ( debounceTime < minDebounceTime )
		debounceTime = minDebounceTime
	// some debounce time for when a rodeo ends
	wait debounceTime
}

function DetectRodeoAlertEnd( player, e )
{
	OnThreadEnd(

		function() : ( e )
		{
			e.done = true
		}

	)

	player.EndSignal( "OnTitanLost" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "ClientRodeoOver" )
	player.EndSignal( "RodeoAlertStarted" )
	WaitForever()
}

function PlayRodeoAlertMedia( player = null )
{
	if ( !player )
		player = GetLocalViewPlayer() // for debug from console

	if ( !HasSoul( player ) )
		return
	local soul = player.GetTitanSoul()

	if ( !IsAlive( soul.GetRiderEnt() ) )
		return


	local e = {}
	e.done <- false

	player.Signal( "RodeoAlertStarted" )
	thread DetectRodeoAlertEnd( player, e )
	thread LoopAlertSound( player )

	/*
	local myModel = CreatePropDynamic( player.GetModelName(), Vector(0,0,0), Vector(0,0,0) )
	myModel.Anim_Play( "cqb_idle_mp" )
//	myModel.Anim_Play( "walk_aim_all" )

	local playerModel = soul.GetRiderEnt().GetModelName()
	printt( "playermodel " + playerModel )
	local riderModel = CreatePropDynamic( playerModel, Vector(0,0,0), Vector(0,0,0) )
	riderModel.SetParent( myModel, "hijack" )
	riderModel.Anim_Play( "pt_rodeo_move_atlas_back_idle" )
	SetSkinForTeam( riderModel, soul.GetRiderEnt().GetTeam() )
	SetSkinForTeam( myModel, player.GetTeam() )
	thread FakeRodeoVDU( player, myModel, riderModel )

	local startTime = Time()
	OnThreadEnd(
		function () : ( myModel, riderModel, player, startTime )
		{
			printt( "THREAD ENDED" )
			if ( !IsValid( player ) )
				return

			if ( IsLockedVDU() )
			{
				UnlockVDU()
				HideVDU()
			}
			myModel.Kill()
			if ( IsValid( riderModel ) )
				riderModel.Kill()
//			thread HideRodeoAlertGraphicWithDebounce( player, startTime )
		}
	)
	*/

//	local vgui = RodeoWarningVGUI()
	for ( ;; )
	{
		if ( e.done )
			break
		wait 0.5
	}
//	vgui.Destroy()
}

function RodeoWarningVGUI( leftOffset = 5 )
{
	local player = GetLocalViewPlayer()
	local cockpit = player.GetCockpit()
	local mod = Create_VGUIMod()
	mod.forward = leftOffset
	mod.right = -12.5 // up
	mod.up = 4.0 // towards
	mod.sizeX = 0.15
	mod.sizeY = 0.45

//	mod.forward = -0.5
//	mod.right = -8.0 // up
//	mod.up = 4.0 // towards
//	mod.sizeX = 0.4
//	mod.sizeY = 1.0
	local vgui = Create_CenterLowerVGUI( "vgui_icon", cockpit, player, mod )
	local panel = vgui.GetPanel()
	local icon = HudElement( "CenterIcon", panel )
//	icon.SetImage( "HUD/rodeo_icon_left" )
	icon.SetImage( "HUD/rodeo_icon_enemy" )

//	icon.SetColor( 255, 255, 255, 55 )
	vgui.s.icon <- icon
	//icon.FadeOverTime( 0, 1.0 )
	return vgui
}

function RodeoFriendlyVGUI( leftOffset = 0 )
{
	printt( "In RodeoFriendlyVGUI" )
	local player = GetLocalViewPlayer()
	local cockpit = player.GetCockpit()
	local mod = Create_VGUIMod()
	mod.forward = 0
	mod.right = -12.5 // up
	mod.up = 4.0 // towards
	mod.sizeX = 0.15
	mod.sizeY = 0.45

	local vgui = Create_CenterLowerVGUI( "vgui_icon", cockpit, player, mod )

	local panel = vgui.GetPanel()
	local icon = HudElement( "CenterIcon", panel )
	icon.SetImage( "HUD/rodeo_icon_friendly" )
	vgui.s.icon <- icon
	return vgui
}

function GetRodeoAlertEntity( player )
{

}


function DrawRodeoAlertIcons( soul )
{
	local player = GetLocalViewPlayer()

	soul.EndSignal( "OnDestroy" )
	soul.Signal( "StopRodeoAlert" )
	soul.EndSignal( "StopRodeoAlert" )

	OnThreadEnd(
		function() : ( player )
		{
			player.Signal( "UpdateRodeoAlert" )
		}
	)

	player.Signal( "UpdateRodeoAlert" )

	while ( true )
	{
		wait 0
	}
}

function FakeRodeoVDU( player, myModel, riderModel )
{
	myModel.EndSignal( "OnDestroy" )

	if ( IsLockedVDU() )
		return

	LockVDU()
 	ShowVDU()

	for ( ;; )
	{
		if ( !IsAlive( player ) )
			return
		if ( !player.IsTitan() )
			return
		if ( !HasSoul( player ) )
			return

		if ( IsValid( riderModel ) )
		{
			if ( !IsAlive( player.GetTitanSoul().GetRiderEnt() ) )
			{
				riderModel.Kill()
			}
		}
		RodeoVDUFunc( player, myModel )
		wait 0
	}
}

function RodeoVDUFunc( player, myModel )
{
	local playerAngles = player.EyeAngles()
	local playerForward = playerAngles.AnglesToForward()
	local playerUp = playerAngles.AnglesToUp()
	local playerOrigin = GetTitanHijackOrigin( player )


	local modelOrigin = playerOrigin + playerForward * -85
	modelOrigin += playerUp * -200

	myModel.SetOrigin( modelOrigin )
	myModel.SetAngles( playerAngles )

	local attach = myModel.LookupAttachment( "hijack" )
	local cameraOrigin = myModel.GetAttachmentOrigin( attach )
	local cameraAngles = myModel.GetAttachmentAngles( attach )
	local cameraForward = cameraAngles.AnglesToForward()
	local cameraUp = cameraAngles.AnglesToUp()
	local cameraRight = cameraAngles.AnglesToRight()

	cameraOrigin += cameraForward * -0
	cameraOrigin += cameraRight * 30
	cameraOrigin += cameraUp * 70
	cameraAngles = cameraAngles.AnglesCompose( Vector(30,175,0))

/*
	cameraOrigin += cameraForward * -60
	cameraOrigin += cameraRight * 40
	cameraOrigin += cameraUp * 60
	cameraAngles = cameraAngles.AnglesCompose( Vector(0,40,0))
*/
	level.camera.SetOrigin( cameraOrigin )
	level.camera.SetAngles( cameraAngles )
}


function LerpGraphicScale( graphic, maxScale, maxTime = 0.4, lerpTime = 0.18, scaleUp = true )
{
	local startTime = Time()
	local timePassed
	local scale

	for ( ;; )
	{
		timePassed = Time() - startTime

		if ( timePassed > maxTime )
			return

//		timePassed %= maxTime
		if ( scaleUp )
		{
			scale = GraphCapped( timePassed, 0, lerpTime, maxScale, 1.0 )
		}
		else
		{
			scale = GraphCapped( timePassed, 0, lerpTime, 1.0, maxScale )
		}

		graphic.SetScale( scale, scale )
		wait 0
	}
}

function TitleScrollDown( player = null )
{
	if ( !player )
		player = GetLocalViewPlayer() // for debugging from console

	player.EndSignal( "RodeoAlertStarted" )

	local graphic = player.hudElems.RodeoAlertLabel
	graphic.SetText( "FOREIGN OBJECT DETECTED!" )

	local moveBuffer = -700
	local finalY = -300
	graphic.SetPos( 0, finalY + moveBuffer )

	graphic.Show()

	local startTime = Time()
	local moveTime = 0.5

	for ( ;; )
	{
		TitleScrollDownComplete( graphic, startTime, moveTime, moveBuffer )
		wait 0
	}

	graphic.SetPos( 0, finalY )
}

function TitleScrollDownComplete( graphic, startTime, moveTime, moveBuffer )
{
	local finalY = -220
	local result = Interpolate( startTime, moveTime, 0, moveTime * 0.5 )

	result = 1 - result
	local buffer = moveBuffer * result

	if ( result <= 0 )
	{
		buffer = 0
		graphic.SetPos( 0, finalY + buffer )
		return true
	}

	graphic.SetPos( 0, finalY + buffer )
	return false
}

function TitleScrollUp( player = null )
{
	if ( !player )
		player = GetLocalViewPlayer() // for debugging from console

	player.EndSignal( "RodeoAlertStarted" )

	local graphic = player.hudElems.RodeoAlertLabel
	graphic.SetText( "FOREIGN OBJECT DETECTED!" )

	local moveBuffer = -700
	local finalY = -300
	graphic.SetPos( 0, finalY )

	graphic.Show()

	local startTime = Time()
	local moveTime = 0.5

	for ( ;; )
	{
		TitleScrollUpComplete( graphic, startTime, moveTime, moveBuffer )
		wait 0
	}

	graphic.SetPos( 0, finalY + moveBuffer )
}

function TitleScrollUpComplete( graphic, startTime, moveTime, moveBuffer )
{
	local finalY = -220
	local result = Interpolate( startTime, moveTime, 0, moveTime * 0.5 )

	local buffer = moveBuffer * result

	if ( result >= 1 )
	{
		graphic.SetPos( 0, finalY + buffer )
		return true
	}

	graphic.SetPos( 0, finalY + buffer )
	return false
}

function ShouldDrawRodeoVGUI( player )
{
	if ( !IsAlive( player ) )
		return false

	if ( !player.IsTitan() )
		return false

	local soul = player.GetTitanSoul()

	local riderEnt = soul.GetRiderEnt()
	if ( !IsValid( riderEnt ) )
			return false

	if ( riderEnt.GetTeam() == player.GetTeam() )
		return true

	return soul.GetLastRodeoHitTime() > 0
}

function HasFriendlyRiderEnt( player )
{
	if ( !player.IsTitan() )
		return false

	local soul = player.GetTitanSoul()

	local riderEnt = soul.GetRiderEnt()
	if ( !IsValid( riderEnt ) )
	{
		return false
	}
	return ShouldPreventFriendlyFire( player, riderEnt )
}


function HasEnemyRiderEnt( player )
{
	if ( !player.IsTitan() )
		return false

	local soul = player.GetTitanSoul()
	local riderEnt = soul.GetRiderEnt()
	if ( !IsValid( riderEnt ) )
		return false

	return ShouldPreventFriendlyFire( player, riderEnt )
}
