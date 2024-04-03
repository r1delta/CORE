function main()
{
	RegisterSignal( "RespawnEntireTeam" )
}

function PlayerRevivesOrBleedsOut( player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "Disconnected" )
	Assert( !IsAlive( player ) )

	local e = {}
	e.revived <- false

	OnThreadEnd(
		function() : ( player, e )
		{
			if ( !IsValid( player ) )
				return

			if ( IsAlive( player ) )
				return

			if ( e.revived )
			{
				//printt( "origin " + player.GetOrigin() )
				//DecideRespawnPlayer( player, player.GetOrigin() )
				local settings = player.GetPlayerSettings()
				player.SetPlayerSettings( "spectator" )
				player.SetPlayerSettings( settings )
				player.RespawnPlayer( null )
				MessageToPlayer( player, eEventNotifications.Clear )
			}
			else
			{
				thread DeadPlayerOrTeamRespawns( player )
			}
		}
	)

	local endTime = Time() + REVIVE_BLEED_OUT_TIME
	local reviving = false
	local doneReviveTime

	for ( ;; )
	{
		local team = player.GetTeam()
		local players = GetLivingPlayers( team )
		if ( !players.len() )
			return

		if ( reviving )
		{
			if ( !FriendlyIsReviving( players, player, REVIVE_DIST_OUTER ) )
			{
				reviving = false
				MessageToPlayer( player, eEventNotifications.NeedRevive, null, endTime )
			}
		}
		else
		{
			if ( FriendlyIsReviving( players, player, REVIVE_DIST_INNER ) )
			{
				doneReviveTime = Time() + REVIVE_TIME_TO_REVIVE
				reviving = true
				MessageToPlayer( player, eEventNotifications.BeingRevived, null, doneReviveTime )
			}
		}

		if ( reviving )
		{
			if ( Time() > doneReviveTime )
			{
				e.revived = true
				return
			}
		}

		if ( Time() > endTime )
			return

		wait 1
	}
}
Globalize( PlayerRevivesOrBleedsOut )

function FriendlyIsReviving( players, player, dist )
{
	local origin = player.GetOrigin()

	foreach ( friend in players )
	{
		if ( !IsAlive( friend ) )
			continue

		if ( Distance( friend.GetOrigin(), origin ) < dist )
			return true
	}

	return false
}

function DeadPlayerOrTeamRespawns( player )
{
	local team = player.GetTeam()
	local players = GetLivingPlayers( team )

	if ( players.len() )
	{
		// if other players are alive, then we just respawn
		player.SetPlayerSettings( "spectator" )
		DecideRespawnPlayer( player )
		MessageToPlayer( player, eEventNotifications.Clear )
		return
	}

	// if all friendlies are dead, wait a moment then respawn everybody

	// clear existing runs of this function to account for players that have also just died, we don't want them to die and then instant-respawn.
	level.ent.Signal( "RespawnEntireTeam" )
	level.ent.EndSignal( "RespawnEntireTeam" )

	wait 3 // some time for everybody to be dead

	local players = GetPlayerArrayOfTeam( team )

	foreach ( guy in players )
	{
		// new player joined?
		if ( IsAlive( guy ) )
			continue

		guy.SetPlayerSettings( "spectator" )
		DecideRespawnPlayer( guy )
		//MessageToPlayer( guy, eEventNotifications.Clear )
		MessageToPlayer( player, eEventNotifications.WipedOut )
	}
}