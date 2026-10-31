// Live Fire: round-based Pilot Skirmish.
// One life per round, no Titans, no minions. A round ends when one team has no living Pilots;
// the match is first to LF_roundscorelimit rounds (see playlists.txt).
//
// The round, elimination and respawn handling all come from the engine's elimination mode,
// which is the same machinery Last Titan Standing and Titan Escort use. This file only turns it on.

function main()
{
	Assert( !GetCinematicMode(), "Cannot play Live Fire in cinematic mode" )

	level.nv.eliminationMode = eEliminationMode.Pilots
	level.nv.spawnAsTitan = eSpawnAsTitan.Never
	level.nv.titanAvailability = eTitanAvailability.Never
	Riff_ForceTitanAvailability( eTitanAvailability.Never )

	SetRoundBased( true )
	// no SetSwitchSidesBased: Live Fire has no sides, and rounds go straight from the winner screen into the next prematch

	level.spawnRatingFunc_Pilot = RateSpawnpoint_Generic
	level.spawnRatingFunc_Generic = RateSpawnpoint_Generic

	AddCallback_GameStateEnter( eGameState.Prematch, LiveFire_PrematchStart )
	AddCallback_GameStateEnter( eGameState.Playing, LiveFire_PlayingStart )
	AddCallback_GameStateEnter( eGameState.Epilogue, LiveFire_EpilogueStart )
}

function EntitiesDidLoad()
{
	// the riff settings are applied after main() and reset these, so set them again
	level.nv.eliminationMode = eEliminationMode.Pilots
	level.nv.spawnAsTitan = eSpawnAsTitan.Never
	level.nv.titanAvailability = eTitanAvailability.Never

	disable_npcs()

	foreach ( turret in GetNPCArrayByClass( "npc_turret_sentry" ) )
		turret.DisableTurret()
}

function LiveFire_PrematchStart()
{
	FlagSet( "ForceStartSpawn" )

	foreach ( player in GetPlayerArray() )
		player.s.respawnCount = 0
}

function LiveFire_PlayingStart()
{
	FlagClear( "ForceStartSpawn" )
}

// everyone is back in the game for the winner screen
function LiveFire_EpilogueStart()
{
	foreach ( player in GetPlayerArray() )
	{
		if ( IsAlive( player ) )
			continue

		if ( !IsPlayerEliminated( player ) )
			continue

		ClearPlayerEliminated( player )
		DecideRespawnPlayer( player )
	}
}
