
const HUD_DPAD_EJECT_MATERIAL = "HUD/dpad_eject"
const HUD_TITAN_IDLE_ICON_MATERIAL = "HUD/titan_stance_icon_ready"
const HUD_DPAD_TITAN_FOLLOW_MATERIAL = "HUD/titan_stance_icon_follow"
const HUD_DPAD_TITAN_GUARD_MATERIAL = "HUD/titan_stance_icon_guard"

const HUD_TITAN_BUILDING_ICON_MATERIAL = "HUD/titan_build_icon_5"
const HUD_TITAN_READY_ICON_MATERIAL = "HUD/titan_stance_ready"
const HUD_TITAN_INCOMING_ICON_MATERIAL = "HUD/titan_stance_icon_drop"
const HUD_TITAN_SHIELDED_ICON_MATERIAL = "HUD/titan_stance_shielded"

const HUD_TITAN_TIMEEARNED_ICON_MATERIAL = "HUD/titan_build_icon"

const HUD_STRYDER_CORE_BUILDING_ICON_MATERIAL = "HUD/dpad_titan_core_dash"
const HUD_OGRE_CORE_BUILDING_ICON_MATERIAL = "HUD/dpad_titan_core_shield"
const HUD_ATLAS_CORE_BUILDING_ICON_MATERIAL = "HUD/dpad_titan_core_emp"

const HUD_STRYDER_CORE_ICON_MATERIAL = "HUD/dpad_titan_core_dash"
const HUD_OGRE_CORE_ICON_MATERIAL = "HUD/dpad_titan_core_shield"
const HUD_ATLAS_CORE_ICON_MATERIAL = "HUD/dpad_titan_core_emp"

PrecacheHUDMaterial( HUD_TITAN_READY_ICON_MATERIAL )
PrecacheHUDMaterial( HUD_DPAD_EJECT_MATERIAL )
PrecacheHUDMaterial( HUD_TITAN_IDLE_ICON_MATERIAL )
PrecacheHUDMaterial( HUD_DPAD_TITAN_FOLLOW_MATERIAL )
PrecacheHUDMaterial( HUD_DPAD_TITAN_GUARD_MATERIAL )
PrecacheHUDMaterial( HUD_TITAN_SHIELDED_ICON_MATERIAL )

PrecacheHUDMaterial( HUD_TITAN_BUILDING_ICON_MATERIAL )
PrecacheHUDMaterial( HUD_TITAN_TIMEEARNED_ICON_MATERIAL )
PrecacheHUDMaterial( HUD_TITAN_INCOMING_ICON_MATERIAL )

PrecacheHUDMaterial( HUD_STRYDER_CORE_BUILDING_ICON_MATERIAL )
PrecacheHUDMaterial( HUD_OGRE_CORE_BUILDING_ICON_MATERIAL )
PrecacheHUDMaterial( HUD_ATLAS_CORE_BUILDING_ICON_MATERIAL )

PrecacheHUDMaterial( HUD_STRYDER_CORE_ICON_MATERIAL )
PrecacheHUDMaterial( HUD_OGRE_CORE_ICON_MATERIAL )
PrecacheHUDMaterial( HUD_ATLAS_CORE_ICON_MATERIAL )

function main()
{
	FlagInit( "EnableIncomingTitanDropEffects", true )

	RegisterSignal( "ReplacementTitanKillParticle" )
	RegisterSignal( "TitanHealthDropKillParticle" )

	RegisterSignal( "titanCoreUpdate" )
	RegisterSignal( "titanImpactUpdate" )
	RegisterSignal( "titanRespawnUpdate" )
	RegisterSignal( "UpdateTitanModeHUD" )

	Globalize( ReplacementTitanHUD_AddPlayer )
	Globalize( ServerCallback_ReplacementTitanSpawnpoint )
	Globalize( SetAutoTitanModeHudIndicator )
	Globalize( TitanModeHUD_Enable )
	Globalize( TitanModeHUD_Disable )
	Globalize( UpdateTitanModeHUD )
	Globalize( PetTitanChanged )
	Globalize( HotDropImpactTimeChanged )
	Globalize( CinematicEventFlagsChanged )
	Globalize( ClientCodeCallback_OnTitanBubbleShieldTimeChanged )
	Globalize( ReplacementTitanHUD_AddClient )
	Globalize( GetCoreIcon )
	Globalize( GetCoreBuildingIcon )
	Globalize( GetTitanReadyIcon )
	Globalize( GetTitanBuildingIcon )

	AddKillReplayEndedCallback( RTH_KillReplayEnded )

	PrecacheParticleSystem( "ar_titan_droppoint" )
}


function ReplacementTitanHUD_AddPlayer( player )
{
	player.InitHudElem( "PlayerReplacementTitanCountdown" )
	player.InitHudElem( "PlayerReplacementTitanArrow" )
	player.InitHudElem( "PlayerReplacementTitanIcon" )

	player.hudElems.PlayerReplacementTitanArrow.SetClampToScreen( CLAMP_RECT )
	player.hudElems.PlayerReplacementTitanArrow.SetOffscreenArrow( true )
	player.hudElems.PlayerReplacementTitanArrow.SetClampBounds( 0.85, 0.80 )

	player.hudElems.PlayerReplacementTitanIcon.SetClampToScreen( CLAMP_RECT )
	player.hudElems.PlayerReplacementTitanIcon.SetClampBounds( 0.80, 0.75 )


	player.InitHudElem( "TitanHealthDropCountdown" )
	player.InitHudElem( "TitanHealthDropArrow" )
	player.InitHudElem( "TitanHealthDropIcon" )

	player.hudElems.TitanHealthDropArrow.SetClampToScreen( CLAMP_RECT )
	player.hudElems.TitanHealthDropArrow.SetOffscreenArrow( true )
	player.hudElems.TitanHealthDropArrow.SetClampBounds( 0.85, 0.80 )

	player.hudElems.TitanHealthDropIcon.SetClampToScreen( CLAMP_RECT )
	player.hudElems.TitanHealthDropIcon.SetClampBounds( 0.80, 0.75 )

	player.s.lastReadyMessageTime <- -9999
	player.s.lastCoreReadyMessageTime <- -9999
	player.s.coreActiveState <- false

	TitanModeHUD_AddPlayer( player )
}


function ReplacementTitanHUD_AddClient( player )
{
	player.cv.PlayerPetTitanIcon <- HudElement( "PlayerPetTitanIcon" )

	player.cv.PlayerPetTitanIcon.SetClampToScreen( CLAMP_RECT )
	player.cv.PlayerPetTitanIcon.SetADSFade( 0, 0, 0, 1 )
	//player.cv.PlayerPetTitanIcon.SetFOVFade( deg_cos( 30 ), deg_cos( 15 ), 0.75, 0.35 )
}


enum eTitanModeHudStates
{
	HotDrop,
	Follow,
	Guard,
	Drop,
	Building,
	InTitan,
	NoTitan,
	Embark,
}

enum eTitanHealthHudStates
{
	Drop,
	Building,
	Dropped,
}

const DROP_HINT_DELAY = 10.0
const CORE_HINT_DELAY = 10.0
function TitanModeHUD_AddPlayer( player )
{
	if ( player != GetLocalViewPlayer() )
		return

	player.s.titanModeHudNextDropHintTime <- 0
	player.s.titanModeHudNextCoreHintTime <- 0

	thread TitanModeHUD_Think( player )
	thread TitanModeHUD_DropTitanHintThink( player )
}


function TitanModeHUD_Think( player )
{
	player.EndSignal( "OnDestroy" )

	while ( 1 )
	{
		player.WaitSignal( "SettingsChanged" )

		UpdateTitanModeHUD( player )
	}
}

function RTH_KillReplayEnded()
{
	UpdatePetTitanIcon( GetLocalClientPlayer() )

}

function ServerCallback_ReplacementTitanSpawnpoint( x, y, z, impactTime )
{
	impactTime += TimeAdjustmentForRemoteReplayCall()
	thread ReplacementTitanSpawnpointThread( Vector( x, y, z ), impactTime )
}


function ReplacementTitanSpawnpointThread( origin, impactTime )
{
	if ( !Flag( "EnableIncomingTitanDropEffects" ) )
		return

	local player = GetLocalViewPlayer()
	player.EndSignal( "ReplacementTitanKillParticle" )
	player.EndSignal( "OnDeath" )

	player.hudElems.PlayerReplacementTitanArrow.SetScale( 0.75, 0.75 )

	local surfaceNormal = Vector( 0, 0, 1 )

	local index = GetParticleSystemIndex( "ar_titan_droppoint" )
	local targetEffect = StartParticleEffectInWorldWithHandle( index, origin, surfaceNormal )
	EffectSetControlPointVector( targetEffect, 1, Vector( 100, 255, 100 ) )

	OnThreadEnd(
		function() : ( player, targetEffect )
		{
			if ( !IsValid( player ))
				return

			player.hudElems.PlayerReplacementTitanCountdown.SetText( "" )
			player.hudElems.PlayerReplacementTitanCountdown.Hide()
			player.hudElems.PlayerReplacementTitanIcon.Hide()
			player.hudElems.PlayerReplacementTitanArrow.Hide()

			if ( IsClient() && EffectDoesExist( targetEffect ) )
				EffectStop( targetEffect, true, false )
		}
	)

	origin += Vector( 0, 0, 64 )

	player.hudElems.PlayerReplacementTitanCountdown.SetOrigin( origin + Vector( 0, 0, 80 ) )
	player.hudElems.PlayerReplacementTitanIcon.SetOrigin( origin )
	player.hudElems.PlayerReplacementTitanArrow.SetOrigin( origin )

	local HATT_COUNTDOWN_SECONDS_MILLISECONDS = 0.5 //Dont have R1 Delta file, so i made a patch here
	if( PlayerHasPassive( player, PAS_TURBO_DROP ) )
	{
		HATT_COUNTDOWN_SECONDS_MILLISECONDS = 0.3
	}

	player.hudElems.PlayerReplacementTitanCountdown.SetAutoText( "#HudAutoText_EtaCountdownTimePrecise", HATT_COUNTDOWN_SECONDS_MILLISECONDS, impactTime )
	player.hudElems.PlayerReplacementTitanCountdown.Show()
	player.hudElems.PlayerReplacementTitanIcon.Show()
	player.hudElems.PlayerReplacementTitanArrow.Show()

	wait impactTime - Time()
}


function UpdatePetTitanIcon( player )
{
	local player = GetLocalClientPlayer()

	if ( ShouldPetTitanIconBeVisible( player ) )
	{
		local petTitan = player.GetPetTitan()
		Assert( IsAlive( petTitan ) )

		player.cv.PlayerPetTitanIcon.SetEntityOverhead( petTitan, Vector( 0, 0, 0 ), 0.5, 0.5 )
		player.cv.PlayerPetTitanIcon.Show()
	}
	else
	{
		player.cv.PlayerPetTitanIcon.Hide()
	}
}
Globalize( UpdatePetTitanIcon )

function ShouldPetTitanIconBeVisible( player )
{
	if ( player != GetLocalViewPlayer() )
		return false

	if ( IsWatchingKillReplay() )
		return false

	local ceFlags = player.GetCinematicEventFlags()

	if ( (ceFlags & CE_FLAG_EMBARK) || (ceFlags & CE_FLAG_DISEMBARK) )
		return false

	local petTitan = player.GetPetTitan()

	if ( !IsAlive( petTitan ) )
		return false

	if ( player.GetHotDropImpactTime() )
		return false

	if ( player.GetParent() && player.GetParent().IsDropship() )
		return false

	return true
}


function CinematicEventFlagsChanged( player )
{
	local ceFlags = player.GetCinematicEventFlags()

	UpdatePetTitanIcon( player )
}


function ClientCodeCallback_OnTitanBubbleShieldTimeChanged( player )
{
	if ( !IsValid( player ) )
		return

	UpdateTitanModeHUD( player )
}


function HotDropImpactTimeChanged( player )
{
	UpdateTitanModeHUD( player )
	UpdatePetTitanIcon( player )
}


function PetTitanChanged( player )
{
	UpdatePetTitanIcon( player )

	if ( player != GetLocalViewPlayer() )
		return

	if ( IsAlive( player.GetPetTitan() ) )
		thread PetTitan_HealthUpdateThink( player, player.GetPetTitan() )
	else
		player.Signal( "UpdateTitanBuildBar" )

	UpdateTitanModeHUD( player )
}


function PetTitan_HealthUpdateThink( player, titan )
{
	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )

	titan.EnableHealthChangedCallback()

	while ( true )
	{
		UpdateTitanModeHUD( player )
		WaitSignal( titan, "Doomed", "HealthChanged" )
	}
}

function UpdateTitanModeHUD( player, mode = null )
{
	thread UpdateTitanModeHUD_Internal( player, mode )
}

function UpdateTitanModeHUD_Internal( player, mode = null )
{
	player.Signal( "UpdateTitanModeHUD" )
	player.EndSignal( "UpdateTitanModeHUD" )

	WaitEndFrame()

	if ( player != GetLocalViewPlayer() )
		return

	local cockpit = player.GetCockpit()
	if ( !cockpit )
		return

	local isTitanCockpit = IsTitanCockpitModelName( cockpit.GetModelName() )

	if ( !TitanModeHUD_ShouldShow( player ) )
	{
		if ( player.IsTitan() )
		{
			SetDpadIcon( player, BUTTON_DPAD_UP, HUD_DPAD_EJECT_MATERIAL )
			SetDpadTitle( player, BUTTON_DPAD_UP, "" )
			SetDpadDesc( player, BUTTON_DPAD_UP, "#HUD_EJECT_NO_BRACKETS" )
			ShowDpadIcon( player, BUTTON_DPAD_UP )
		}
		else
		{
			HideDpadIcon( player, BUTTON_DPAD_UP )
			HideDpadIcon( player, BUTTON_DPAD_DOWN )
		}

		player.Signal( "UpdateTitanBuildBar" )
	}
	else if ( isTitanCockpit )
		UpdateTitanDPad( player )
	else
		UpdatePilotDPad( player, mode )

	player.Signal( "UpdateTitanBuildBar" )
}

function DelayUpdateTitanModeHUD( delay, player, endSignal )
{
	level.ent.Signal( endSignal )
	level.ent.EndSignal( endSignal )

	wait delay

	thread UpdateTitanModeHUD( player )
}

function UpdateTitanDPad( player )
{
	if ( IsWatchingKillReplay() )
		return

	if ( IsTrainingLevel() )
		return

	SetDpadIcon( player, BUTTON_DPAD_UP, HUD_DPAD_EJECT_MATERIAL )
	SetDpadTitle( player, BUTTON_DPAD_UP, "" )
	SetDpadDesc( player, BUTTON_DPAD_UP, "#HUD_EJECT_NO_BRACKETS" )
	ShowDpadIcon( player, BUTTON_DPAD_UP )

	SetDpadProgressColor( player, BUTTON_DPAD_DOWN, [0, 0, 0, 0], [0, 0, 0, 0] )
	SetDpadProgressFlip( player, BUTTON_DPAD_DOWN, false )
	SetDpadProgress( player, BUTTON_DPAD_DOWN, 0, null, null, ProgressSource.PROGRESS_SOURCE_SCRIPTED )

	ShowDpadIcon( player, BUTTON_DPAD_DOWN )
	SetDpadIconColor( player, BUTTON_DPAD_DOWN, [255, 255, 255, 255] )

	// handle the execution-pilot-with-titan-cockpit hack.
	if ( !player.IsTitan() )
		return

	local currentTime = Time()
	local soul = player.GetTitanSoul()

	local nextCoreChargeAvailable = soul.GetNextCoreChargeAvailable()

	if ( player.GetDoomedState() )
	{
		ShowDpadIcon( player, BUTTON_DPAD_DOWN )
		SetDpadIcon( player, BUTTON_DPAD_DOWN, "HUD/empty" )
		SetDpadDesc( player, BUTTON_DPAD_DOWN, "#HUD_BLANK_TIME" )
		SetDpadIconColor( player, BUTTON_DPAD_DOWN, [128, 128, 128, 255] )

		SetDpadCooldown( player, BUTTON_DPAD_DOWN, 0.0 )

		SetDpadProgress( player, BUTTON_DPAD_DOWN, 0, null, null, ProgressSource.PROGRESS_SOURCE_ENTITY_HEALTH, player )
		SetDpadProgressColor( player, BUTTON_DPAD_DOWN, [255, 0, 0, 255], [255, 255, 255, 32] )
		SetDpadProgressFlip( player, BUTTON_DPAD_DOWN, true )
	}
	else if ( Time() < soul.GetCoreChargeExpireTime()  )
	{
		local expireTime = soul.GetCoreChargeExpireTime()
		local activeTime = GetTitanCoreActiveTime( player )
		local chargeTime = TITAN_CORE_CHARGE_TIME

		local totalTime = activeTime + chargeTime
		local startTime = expireTime - totalTime

		SetDpadCooldown( player, BUTTON_DPAD_DOWN, 0.0 )

		SetDpadIcon( player, BUTTON_DPAD_DOWN, GetCoreIcon( player ) )
		SetDpadDesc( player, BUTTON_DPAD_DOWN, "" )

		// charging
		if ( Time() <= expireTime - activeTime )
		{
			thread FakeDpadPulse( player, BUTTON_DPAD_DOWN )
			SetDpadIconColor( player, BUTTON_DPAD_DOWN, [255, 50, 35, 255] )
			local progress = GraphCapped( Time(), startTime, startTime + chargeTime, 0.0, 1.0 )
			local remainingTime = (startTime + chargeTime) - Time()
			SetDpadProgressFlip( player, BUTTON_DPAD_DOWN, false )
			SetDpadProgress( player, BUTTON_DPAD_DOWN, progress, 1.0, remainingTime )
			SetDpadProgressColor( player, BUTTON_DPAD_DOWN, [255, 50, 35, 250], [0, 0, 0, 128] )

			thread DelayUpdateTitanModeHUD( max( remainingTime, 0 ), player, "titanCoreUpdate" )
		}
		else //active
		{
			player.s.coreActiveState = true
			local progress = GraphCapped( Time(), startTime + chargeTime, expireTime, 0.0, 1.0 )
			local remainingTime = expireTime - Time()
			SetDpadProgressFlip( player, BUTTON_DPAD_DOWN, true )
			SetDpadProgress( player, BUTTON_DPAD_DOWN, progress, 1.0, remainingTime )
			SetDpadProgressColor( player, BUTTON_DPAD_DOWN, [SHIELD_BOOST_R, SHIELD_BOOST_G, SHIELD_BOOST_B, 255], [0, 0, 0, 128] )

			thread DelayUpdateTitanModeHUD( max( remainingTime, 0 ), player, "titanCoreUpdate" )
		}
	}
	else if ( nextCoreChargeAvailable >= 0  )
	{
		if ( player.s.coreActiveState )
		{
			TitanCockpit_PlayDialog( player, "core_offline" )
			player.s.coreActiveState = false
		}

		local soul = player.GetTitanSoul()

		local msg
		local soul = player.GetTitanSoul()
		switch ( player.GetPlayerSettingsField( "footstep_type" ) )
		{
			case "atlas":
				msg = "#CHASSIS_ATLAS_CORE_NAME"
				break

			case "ogre":
				msg = "#CHASSIS_OGRE_CORE_NAME"
				break

			case "stryder":
				msg = "#CHASSIS_STRYDER_CORE_NAME"
				break
			
			case "missile_core":
				msg = "Missile Core"
				break

			default:
				Assert( 0, "Unknown titan " + titanType )
		}

		SetDpadTitle( player, BUTTON_DPAD_DOWN, msg )
		SetDpadIcon( player, BUTTON_DPAD_DOWN, GetCoreIcon( player ) )
		SetDpadDesc( player, BUTTON_DPAD_DOWN, "" )
		SetDpadDesc( player, BUTTON_DPAD_DOWN, "", nextCoreChargeAvailable )

		local totalTime = TITAN_CORE_BUILD_TIME
		local remainingTime = soul.GetNextCoreChargeAvailable() - Time()
		if ( remainingTime > 0 )
		{
			SetDpadProgressColor( player, BUTTON_DPAD_DOWN, [0, 0, 0, 0], [0, 0, 0, 160] )

			SetDpadDesc( player, BUTTON_DPAD_DOWN, "", nextCoreChargeAvailable )
			thread DelayUpdateTitanModeHUD( max( remainingTime, 0 ), player, "titanCoreUpdate" )
		}
		else if ( currentTime >= player.s.titanModeHudNextCoreHintTime )
		{
			SetDpadProgressColor( player, BUTTON_DPAD_DOWN, [0, 0, 0, 0], [0, 0, 0, 0] )

			player.s.titanModeHudNextCoreHintTime = (currentTime + CORE_HINT_DELAY) - 0.15
			AlertDpadIcon( player, BUTTON_DPAD_DOWN )

			if ( Time() - player.s.lastCoreReadyMessageTime > 60.0 )
			{
				player.s.lastCoreReadyMessageTime = Time()
				CoreReadyMessage( player )
				TitanCockpit_PlayDialog( player, "core_online" )
			}
		}

		SetDpadCooldown( player, BUTTON_DPAD_DOWN, 1 - (remainingTime / totalTime), 1.0, remainingTime )
	}
}

function FakeDpadPulse( player, button )
{
	local cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) )
		return

	local mainVGUI = cockpit.GetMainVGUI()
	if ( !mainVGUI )
		return

	cockpit.EndSignal( "OnDestroy" )
	cockpit.s.dpadIcons[button].SetPulsate( 0.1, 0.95, 13.0 )
	wait TITAN_CORE_CHARGE_TIME
	cockpit.s.dpadIcons[button].SetPulsate( 1.0, 1.0, 1.0 )
//	cockpit.s.dashBarFG.SetColor( 170, 210, 240, 220 )
}

function UpdatePilotDPad( player, mode )
{
	if ( IsWatchingKillReplay() )
		return

	// JFS: pet titan with no soul... maybe he died this frame?
	local titan = player.GetPetTitan()
	if ( !IsValid( titan ) || !IsValid( titan.GetTitanSoul() ) )
		titan = null

	if ( mode == null )
		mode = player.GetPetTitanMode()

	player.s.coreActiveState = false

	local currentTime = Time()

	ShowDpadIcon( player, BUTTON_DPAD_DOWN )
	SetDpadIconColor( player, BUTTON_DPAD_DOWN, [255, 255, 255, 255] )

	SetDpadProgressColor( player, BUTTON_DPAD_DOWN, [0, 0, 0, 0], [0, 0, 0, 0] )
	SetDpadProgressFlip( player, BUTTON_DPAD_DOWN, false )
	SetDpadProgress( player, BUTTON_DPAD_DOWN, 0.0 )

	local hotDropImpactTime = player.GetHotDropImpactTime()
	local impactTime = hotDropImpactTime - currentTime
	if ( impactTime > 0 )
	{
		SetDpadDesc( player, BUTTON_DPAD_DOWN, "", hotDropImpactTime )
		SetDpadTitle( player, BUTTON_DPAD_DOWN, "Titan Incoming" )
		SetDpadIcon( player, BUTTON_DPAD_DOWN, HUD_TITAN_INCOMING_ICON_MATERIAL )

		if ( impactTime > 0 )
		{
			thread DelayUpdateTitanModeHUD( impactTime, player, "titanImpactUpdate" )
		}
	}
	else if ( titan )
	{
		SetDpadCooldown( player, BUTTON_DPAD_DOWN, 0 )

		local titan = player.GetPetTitan()
		if ( titan.GetTitanSoul().GetStance() == STANCE_KNEEL && player.GetTitanBubbleShieldTime() > currentTime )
		{
			SetDpadDesc( player, BUTTON_DPAD_DOWN, "", player.GetTitanBubbleShieldTime() )
			SetDpadTitle( player, BUTTON_DPAD_DOWN, "Shielded" )
			SetDpadIcon( player, BUTTON_DPAD_DOWN, HUD_TITAN_SHIELDED_ICON_MATERIAL )
		}
		else
		{
			SetDpadProgress( player, BUTTON_DPAD_DOWN, 0, null, null, ProgressSource.PROGRESS_SOURCE_ENTITY_HEALTH, player.GetPetTitan() )
			SetDpadProgressFlip( player, BUTTON_DPAD_DOWN, false )
			SetDpadProgressColor( player, BUTTON_DPAD_DOWN, [132, 156, 175, 128], [0, 0, 0, 128] )

			SetDpadDesc( player, BUTTON_DPAD_DOWN, "" )
			if ( titan.GetDoomedState() )
			{
				SetDpadProgressColor( player, BUTTON_DPAD_DOWN, [255, 0, 0, 255], [255, 255, 255, 32] )
				SetDpadProgressFlip( player, BUTTON_DPAD_DOWN, true )
				//SetDpadDesc( player, BUTTON_DPAD_DOWN, format( "Doomed: %d%%", GetHealthFrac( titan ) * 100 ) )
			}
			else
			{
				SetDpadProgressColor( player, BUTTON_DPAD_DOWN, [132, 156, 175, 128], [0, 0, 0, 128] )
				SetDpadProgressFlip( player, BUTTON_DPAD_DOWN, false )
				//SetDpadDesc( player, BUTTON_DPAD_DOWN, format( "Health: %d%%", GetHealthFrac( titan ) * 100 ) )
			}

			if ( mode == eNPCTitanMode.FOLLOW )
			{
				SetDpadTitle( player, BUTTON_DPAD_DOWN, "Follow" )
				SetDpadIcon( player, BUTTON_DPAD_DOWN, HUD_DPAD_TITAN_FOLLOW_MATERIAL )
			}
			else
			{
				Assert( mode == eNPCTitanMode.STAY )
				SetDpadTitle( player, BUTTON_DPAD_DOWN, "Guard" )
				SetDpadIcon( player, BUTTON_DPAD_DOWN, HUD_DPAD_TITAN_GUARD_MATERIAL )
			}
		}
	}
	else
	{
		local totalTime = max( player.GetTitanBuildTime(), 1 )
		local remainingTime = player.GetNextTitanRespawnAvailable() - Time()
		SetDpadCooldown( player, BUTTON_DPAD_DOWN, 1 - (remainingTime / totalTime), 1.0, remainingTime )

		local nextTitanRespawnAvailable = player.GetNextTitanRespawnAvailable()
		if ( nextTitanRespawnAvailable >= 0 )
		{
			// legal range for the respawn titan
			local time = nextTitanRespawnAvailable - currentTime

			if ( time > 0 )
			{
				SetDpadProgressColor( player, BUTTON_DPAD_DOWN, [0, 0, 0, 0], [0, 0, 0, 160] )

				SetDpadDesc( player, BUTTON_DPAD_DOWN, "", nextTitanRespawnAvailable )

				thread DelayUpdateTitanModeHUD( time, player, "titanRespawnUpdate" )

				SetDpadTitle( player, BUTTON_DPAD_DOWN, "Building Titan" )
				SetDpadIcon( player, BUTTON_DPAD_DOWN, HUD_TITAN_BUILDING_ICON_MATERIAL )
			}
			else
			{
				SetDpadProgressColor( player, BUTTON_DPAD_DOWN, [0, 0, 0, 0], [0, 0, 0, 0] )

				SetDpadTitle( player, BUTTON_DPAD_DOWN, "Titanfall" )
				SetDpadIcon( player, BUTTON_DPAD_DOWN, HUD_TITAN_READY_ICON_MATERIAL )

				SetDpadDesc( player, BUTTON_DPAD_DOWN, "" )

				if ( currentTime >= player.s.titanModeHudNextDropHintTime )
				{
					player.s.titanModeHudNextDropHintTime = (currentTime + DROP_HINT_DELAY) - 0.15
					AlertDpadIcon( player, BUTTON_DPAD_DOWN )
				}

				if ( currentTime - player.s.lastReadyMessageTime > 60.0 )
				{
					player.s.lastReadyMessageTime = Time()
					TitanReadyMessage( player )
				}
			}
		}
		else
		{
			ShowDpadIcon( player, BUTTON_DPAD_DOWN )
			SetDpadIcon( player, BUTTON_DPAD_DOWN, HUD_TITAN_BUILDING_ICON_MATERIAL )
			SetDpadDesc( player, BUTTON_DPAD_DOWN, "#HUD_BLANK_TIME" )
			SetDpadIconColor( player, BUTTON_DPAD_DOWN, [128, 128, 128, 255] )
			SetDpadProgressColor( player, BUTTON_DPAD_DOWN, [0, 0, 0, 0], [0, 0, 0, 0] )
		}
	}
}



function TitanModeHUD_DropTitanHintThink( player )
{
	player.EndSignal( "OnDestroy" )

	while ( true )
	{
		UpdateTitanModeHUD( player )

		wait DROP_HINT_DELAY
	}
}


function TitanModeHUD_ShouldShow( player )
{
	if ( !IsAlive( player ) )
		return false

	if ( ( "hideTitanModeHUD" in player.s ) )
		return false

	if ( !IsAlive( player.GetPetTitan() ) && !player.IsTitan() )
	{
		local time = player.GetNextTitanRespawnAvailable() - Time()
		if ( time > 500 )
			return false
	}

	return true
}


function TitanModeHUD_Disable( player )
{
	if ( ( "hideTitanModeHUD" in player.s ) )
		return

	player.s.hideTitanModeHUD <- 1
}


function TitanModeHUD_Enable( player )
{
	if ( !( "hideTitanModeHUD" in player.s ) )
		return

	delete player.s.hideTitanModeHUD
}


function SetAutoTitanModeHudIndicator( player, mode )
{
	Assert( IsValid( player ) )
	Assert( mode == eNPCTitanMode.FOLLOW || mode == eNPCTitanMode.STAY )

	if ( !IsAlive( player.GetPetTitan() ) )
		return

	UpdateTitanModeHUD( player, mode )
}


function GetCoreIcon( player )
{
	local coreIcon = "HUD/empty"
	switch ( player.GetPlayerSettingsField( "footstep_type" ) )
	{
		case "stryder":
			coreIcon = HUD_STRYDER_CORE_ICON_MATERIAL
			break

		case "atlas":
			coreIcon = HUD_ATLAS_CORE_ICON_MATERIAL
			break

		case "ogre":
			coreIcon = HUD_OGRE_CORE_ICON_MATERIAL
			break
	}

	return coreIcon
}


function GetCoreBuildingIcon( player )
{
	local coreIcon = "HUD/empty"
	switch ( player.GetPlayerSettingsField( "footstep_type" ) )
	{
		case "stryder":
			coreIcon = HUD_STRYDER_CORE_BUILDING_ICON_MATERIAL
			break

		case "atlas":
			coreIcon = HUD_ATLAS_CORE_BUILDING_ICON_MATERIAL
			break

		case "ogre":
			coreIcon = HUD_OGRE_CORE_BUILDING_ICON_MATERIAL
			break
	}

	return coreIcon
}

function GetTitanReadyIcon( player )
{
	return HUD_TITAN_READY_ICON_MATERIAL
}

function GetTitanBuildingIcon( player )
{
	return HUD_TITAN_TIMEEARNED_ICON_MATERIAL
}
