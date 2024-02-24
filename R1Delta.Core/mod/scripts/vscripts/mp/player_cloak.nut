//=========================================================
//	player_cloak
//
//=========================================================

const CLOAK_FADE_IN = 1.0
const CLOAK_FADE_OUT = 1.0

function main()
{
	Globalize( EnableCloak )
	Globalize( DisableCloak )
	Globalize( EnableCloakForever )

	RegisterSignal( "OnStartCloak" )

	AddCallback_OnPlayerKilled( Bind( AbilityCloak_OnDeath ) )
	AddSpawnCallback( "npc_titan", SetCannotCloak )
}

function SetCannotCloak( entity )
{
	if ( IsNPC( entity ) && entity.GetBossPlayer() == null && GAMETYPE == COOPERATIVE )
		return
	entity.SetCanCloak( false )
}

function PlayCloakSounds( player )
{
	EmitSoundOnEntity( player, "Cloak_On" )
	EmitSoundOnEntity( player, "Cloak_Sustain_Loop" )
}

function EnableCloak( player, duration )
{
	if ( player.cloakedForever )
		return

	thread AICalloutCloak( player )

	PlayCloakSounds( player )

	local duration = duration - CLOAK_FADE_IN

	player.SetCloakDuration( CLOAK_FADE_IN, duration, CLOAK_FADE_OUT )

	player.s.cloakedShotsAllowed = 0

	thread HandleCloakEnd( player )
}

function AICalloutCloak( player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "Disconnected" )

	wait CLOAK_FADE_IN //Give it a beat after cloak has finishing cloaking in

	local enemyTeam = GetTeamIndex(GetOtherTeams(1 << player.GetTeam()))

	local nearbySoldiers = GetNPCArrayEx( "npc_soldier", enemyTeam, player.GetOrigin(), 1000  )  //-1 for distance parameter means all spectres in map

	foreach( grunt in nearbySoldiers )
	{
		if ( !IsAlive( grunt ) )
			continue

		if ( grunt.GetEnemy() == player )
		{
			local aiCallout = DecideCloakCallOut( player )
			PlaySquadConversationToAll( aiCallout, grunt )
			return //Only need one guy to say this instead of multiple guys
		}


	}
}

function DecideCloakCallOut( player )
{
	local probability = RandomFloat( 0, 1 )

	if ( probability < 0.5 )
		return "aichat_generic_pilot_cloaked"

	if ( PlayerIsFemale( player ) )
		return "aichat_female_pilot_cloaked"

	return "aichat_male_pilot_cloaked"
}

function EnableCloakForever( player )
{
	player.SetCloakDuration( CLOAK_FADE_IN, 9999, CLOAK_FADE_OUT ) // 2.7 hours enough?

	player.cloakedForever = true

	thread HandleCloakEnd( player )
	PlayCloakSounds( player )
}


function DisableCloak( player, fadeOut = CLOAK_FADE_OUT )
{
	StopSoundOnEntity( player, "Cloak_Sustain_Loop" ) // broken w/ looping sounds
	FadeOutSoundOnEntity( player, "Cloak_Sustain_Loop", 0.1 )

	if ( fadeOut < CLOAK_FADE_OUT )
	{
		EmitSoundOnEntity( player, "Cloak_InterruptEnd" )
		StopSoundOnEntity( player, "Cloak_WarningToEnd" )
	}

	local wasCloaked = player.IsCloaked( CLOAK_INCLUDE_FADE_IN_TIME )

	player.SetCloakDuration( 0, 0, fadeOut )
}


function HandleCloakEnd( player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnEMPPilotHit" )
	player.EndSignal( "OnChangedPlayerClass" )
	player.Signal( "OnStartCloak" )
	player.EndSignal( "OnStartCloak" )

	local duration = player.GetCloakEndTime() - Time()

	OnThreadEnd(
		function() : ( player )
		{
			if ( !IsValid( player ) )
				return

			StopSoundOnEntity( player, "Cloak_Sustain_Loop" ) // broken w/ looping sounds
			FadeOutSoundOnEntity( player, "Cloak_Sustain_Loop", 0.1 )
			if ( !IsCloaked( player ) )
				return

			if ( !IsAlive( player ) || !player.IsHuman() )
			{
				DisableCloak( player )
				return
			}

			local duration = player.GetCloakEndTime() - Time()
			if ( duration <= 0 )
			{
				DisableCloak( player )
			}
		}
	)

	local soundBufferTime = 3.45

	if ( duration > soundBufferTime )
	{
		wait ( duration - soundBufferTime )
		if ( !IsCloaked( player ) )
			return
		EmitSoundOnEntity( player, "Cloak_WarningToEnd" )
		wait soundBufferTime
	}
	else
	{
		wait duration
	}
}


function AbilityCloak_OnDeath( player, damageInfo )
{
	// stupid callback...
	if ( !player.IsPlayer() )
		return

	if ( !IsCloaked( player ) )
		return

	DisableCloak( player, 0 )
}