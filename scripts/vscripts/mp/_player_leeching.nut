// _player_leeching

const SPECTRE_LEECH_SURROUNDING_RANGE = 384
// 384	~ 32 feet
// 256	~ 21.3 feet
// 192	~ 16 feet
// 128	~ 10.6 feet

function main()
{
	Globalize( EnablePlayerLeeching )
	Globalize( DisablePlayerLeeching )
	Globalize( PlayerCanLeech )
	Globalize( InitLeeching )
	Globalize( LeechSurroundingSpectres )
	Globalize( CodeCallback_LeechStart )
	Globalize( LeechPropagate )
	Globalize( ReleaseLeechOverflow )

	if ( IsServer() )
	{
		PrecacheModel( "models/robots/marvin/marvin.mdl" )
		PrecacheModel( DATA_KNIFE_MODEL )
	}

	Assert( "_leechtargets" in level )

	level.globalLeechLimit <- 100		// max number of leeched ents per team
	level.maxLeechable <- 100			// max number of leeched ents per person
	level.leechRange <- SPECTRE_LEECH_SURROUNDING_RANGE
	level.propagateOnLeech <- true
	level.wifiHackOverflowDies <- false

}

function PlayerCanLeech( player = null )
{
	Assert( level )
	Assert( "player" in level )

	if ( !player )
		player = level.player

	return player.Leech_IsContextActionEnabled()
}

function EnablePlayerLeeching( player = null )
{
	if ( !player )
		player = level.player

	player.Leech_EnableContextAction()
}

function InitLeeching( player )
{
	// the ent we are leeching
	player.s._leechtarget <- null

	player.s.lastLeechTypeSoundTime <- -1

	// all the ents we currently have leeched
	player.s.leechedEnts <- {}
}

function DisablePlayerLeeching( player = null )
{
	if ( !player )
		player = level.player

	Assert( player.IsPlayer() )

	player.Leech_DisableContextAction()
}

function PlayerHasLeechedEnts( player )
{
	Assert( player, "No player!" )
	Assert( player.GetClassname() == "player", player + " is not a player" )
	Assert( "leechedEnts" in player.s, "Player did not get init'd properly" )

	foreach ( ent in player.s.leechedEnts )
	{
		return true
	}

	return false
}

function PlayerStopLeeching( player, target )
{
	Assert( target != null )
	Assert( player.s._leechtarget == target )

	// HUD stop
	//Remote.CallFunction_Replay( player, "ServerCallback_StopBootloaderText" )

//	if ( player.s._leechtarget.s.leechInProgress )
//	if ( !( player.s._leechtarget in player.s.leechedEnts ) )
	StopLeechingProgress( player.s._leechtarget )

	player.s._leechtarget = null
}

function LeechSuccessSound( player )
{
	EmitSoundOnEntity( player, PLAYER_LEECH_SUCCESSFUL_SOUND )
	wait( 0.068 )
	if ( IsAlive( player ) )
		EmitSoundOnEntity( player, PLAYER_LEECH_SUCCESSFUL_SOUND )
}

function CodeCallback_LeechStart( player, target )
{
	thread LeechStartThread( player, target )
}

function LeechStartThread( player, target )
{
	if ( !IsAlive( target ) )
		return

	if ( !IsAlive( player ) )
		return

	if (target.IsSpectre())
	{
		if (!player.HasHacking())
			return
	}


/*
	if ( player.ContextAction_IsActive()
	     || player.ContextAction_IsActive()
	     || target.ContextAction_IsActive() )
	{
		return
	}
*/

	player.EndSignal( "Disconnected" )
	player.EndSignal( "ScriptAnimStop" )
	player.EndSignal( "OnDeath" )
	target.EndSignal( "OnDestroy" )
	target.EndSignal( "OnDeath" )
	target.EndSignal( "ScriptAnimStop" )

	StartLeechingProgress( target, player )

	local e = {}
	e.ref <- null
	e.playerStartOrg <- player.GetOrigin()
	e.success <- false
	e.knives <- []

	e.targetStartPos <- target.GetOrigin()

	OnThreadEnd
	(
		function() : ( e, player, target )
		{
			if ( IsValid( player ) )
			{
				player.SetSyncedEntity( null )
				if ( player.ContextAction_IsLeeching() )
					player.Event_LeechEnd()

				player.ClearParent()

				// reset to start position in case animation moves us at all
				//player.SetOrigin( e.playerStartOrg )
				player.Anim_Stop()
				player.UnforceStand()

				// done with first person anims
				player.ClearAnimViewEntity()
				player.DeployWeapon()
			}

			if ( IsValid( target ) )
			{
				if ( !e.success )
				{
					if ( IsValid( player ) )
						TryLeechAbortCallback( target, player ) //Make "failed leech" sounds play here after exiting leech animation
				}

				target.SetNoTarget( false )
				target.SetNoTargetSmartAmmo( false )
				target.Anim_Stop()
				target.ClearParent()
				if ( IsAlive( target ) )
				{
					UnStuck( target, e.targetStartPos )
				}

				if ( target.ContextAction_IsLeeching() )
					target.Event_LeechEnd()

			}

			foreach( knife in e.knives )
			{
				if ( IsValid( knife ) )
				{
					knife.Kill()
				}

			}

			if ( IsValid( player ) && player.s._leechtarget )
			{
				PlayerStopLeeching( player, player.s._leechtarget )
			}

			if ( IsValid( e.ref ) )
			{
				if ( IsValid( player ) )
					player.ClearParent()

				if ( IsValid( target ) )
					target.ClearParent()

				//printt( "kill the ref" )
				e.ref.Kill()
			}
		}
	)

	// shouldn't have to do init stuff in the behavior
	if ( !( "_leechtarget" in player.s ) )
	{
		// the ent we are leeching
		player.s._leechtarget <- null
		player.s.lastLeechTypeSoundTime <- -1
		player.s.leechedEnts <- {}
	}

	Assert( player.s._leechtarget == null )
	player.s._leechtarget = target
	player.Event_LeechStart()
	target.Event_LeechStart()
	player.ForceStand()
	player.HolsterWeapon()

	local leechTime = 2.8
	if ( PlayerHasPassive( player, PAS_FAST_HACK ) )
		leechTime = 0.85

	e.leechTime <- leechTime


	local action = FindLeechAction( player, target )

	target.SetNoTarget( true )
	target.SetNoTargetSmartAmmo( true )

	// The data knife needs to be turned off, or it could be drawing whatever
	// was last on it
	Remote.CallFunction_Replay( player, "ServerCallback_DataKnifeReset" )
	if ( target.IsSpectre() )
		TellSquadmatesSpectreIsGettingLeeched( target, player )

	waitthread PlayerLeechTargetAnimation( player, target, action, e )


	e.leechStartTime <- Time()
//	local startTime = Time()
//	printt( "begin the leech" )
	Remote.CallFunction_Replay( player, "ServerCallback_DataKnifeStartLeech", e.leechTime )
	waitthread WaittillFinishedLeeching( player, target, e )
//	local timePassed = Time() - startTime
//	printt( "done, time passed", timePassed )

	if ( e.success  )
	{
		thread LeechSuccessSound( player )
		DoLeech( target, player )
		PlayerStopLeeching( player, target )

		// this will kill a random leeched ent from within the team, exluding the current target. When it's not done elsewhere
		if ( level.wifiHackOverflowDies == false )
			ReleaseLeechOverflow( player, target )

		//this is called when the player leeches - not when the system is leeching other spectres
		if ( target.IsSpectre() && level.propagateOnLeech )
			LeechSurroundingSpectres( target.GetOrigin(), player )

		if ( target.IsSpectre() )
		{
			local currentMap = GetMapName()
			local mapID = PersistenceGetEnumIndexForItemName( "maps", currentMap )

			Stats_IncrementStat( player, "misc_stats", "spectreLeeches", 1 )
			Stats_IncrementStat( player, "misc_stats", "spectreLeechesByMap", 1 )
		}
	}
	else
	{
		Remote.CallFunction_Replay( player, "ServerCallback_DataKnifeCancelLeech" )
		PlayerStopLeeching( player, player.s._leechtarget )
	}

	waitthread PlayerExitLeechingAnim( player, target, action, e )
}

function TellSquadmatesSpectreIsGettingLeeched( spectre, player )
{
	local squadName = spectre.kv.squadname
	if ( squadName == "" )
		return

	local squad = GetNPCArrayBySquad( squadName )
	ArrayRemove( squad, spectre )

	foreach( squadMate in squad )
	{
		//printt( "Setting enemy of " + squadMate + " to player:  " + player )
		squadMate.SetEnemy( player )
		squadMate.SetEnemyLKP( player, player.GetOrigin() )
	}
}

function ReleaseLeechOverflow( player, lastLeeched )
{
	local teamLeechedEnts = GetTeamLeechedEnts( player.GetTeam() )
	local leechedEnts = GetLeechedEnts( player )
	local globalOverflow = level.globalLeechLimit - teamLeechedEnts.len()
	local playerOverflow = level.maxLeechable - leechedEnts.len()

	local overflow = min( globalOverflow, playerOverflow )

	if ( overflow >= 0 )
		return

	overflow = abs( overflow )

	ArrayRandomize( teamLeechedEnts )
	foreach ( ent in teamLeechedEnts )
	{
		if ( lastLeeched == ent )
			continue

		local owner = ent.GetBossPlayer()
		Assert( IsPlayer( owner ) )


		// I think it's better to kill the overflow then have it become an enemy again.
		ent.Die()
//		thread ReleaseLeechedSpectre( ent )

		delete owner.s.leechedEnts[ ent ]
		overflow--

		if ( overflow == 0 )
			break
	}

	Assert( overflow == 0 )
}

/*
// commenting out this function since it's not used.
function ReleaseLeechedSpectre( spectre )
{
	spectre.EndSignal( "OnDestroy" )
	spectre.EndSignal( "OnDeath" )

	local otherTeam = GetOtherTeam( spectre.GetTeam() )
	local squadName = UniqueString( "unleeched" )

	spectre.DisableBehavior( "Follow" )
	spectre.StayPut( false )
	spectre.ClearBossPlayer()
	spectre.SetTeam( otherTeam )
	SetSquad( spectre, squadName )

	spectre.Anim_Stop()
	waitthread PlayAnim( spectre, "pt_reboot" )
	spectre.SetVelocity( Vector(0,0,0) )
}
Globalize( ReleaseLeechedSpectre )
*/

function GetMaxNumberOfLeechedEnts( player )
{
	local teamLeechedCount = GetTeamLeechedEnts( player.GetTeam() ).len()
	local leechedEntsCount = GetLeechedEnts( player ).len()
	local teamLimit = max( 0, level.globalLeechLimit - teamLeechedCount )
	local maxSize = max( 0, level.maxLeechable - leechedEntsCount )
	maxSize = min( teamLimit, maxSize )

	return maxSize
}

function LeechSurroundingSpectres( origin, player )
{
	local enemyTeam = GetOtherTeam( player.GetTeam() )

	local enemySpectreArray = GetNPCArrayEx( "npc_spectre", enemyTeam, player.GetOrigin(), level.leechRange  )

	if ( !enemySpectreArray.len() )
		return

	// don't resize the array if we should kill the overflow instead
	if ( level.wifiHackOverflowDies == false )
	{
		local maxSize = GetMaxNumberOfLeechedEnts( player )
		local newSize = min( enemySpectreArray.len(), maxSize )

		enemySpectreArray.resize( newSize )
	}

	foreach ( spectre in enemySpectreArray )
	{
		thread LeechPropagate( spectre, player )
	}

	if ( enemySpectreArray.len() )
	{
		if ( PlayerHasPassive( player, PAS_WIFI_SPECTRE ) )
		{
			EmitSoundOnEntity( player, "BurnCard_WiFiVirus_TurnSpectre" )
			printt( "play BurnCard_WiFiVirus_TurnSpectre" )
		}
	}
}

function LeechPropagate( spectre, player )
{
	if ( spectre.ContextAction_IsActive() )
		return

	if ( !spectre.IsInterruptable() )
		return

	if ( spectre.GetParent() )
		return

	if ( !Leech_IsLeechable( spectre ) )
		return

	player.EndSignal( "Disconnected" )
	spectre.EndSignal( "OnDestroy" )
	spectre.EndSignal( "OnDeath" )

	spectre.Event_LeechStart()

	AddAnimEvent( spectre, "leech_switchteam", DoLeech, player )

	OnThreadEnd(
		function() : ( spectre )
		{
			if ( IsValid( spectre ) )
			{
				DeleteAnimEvent( spectre, "leech_switchteam", DoLeech )

				if ( spectre.ContextAction_IsLeeching() )
					spectre.Event_LeechEnd()
			}
		}
	)

	spectre.Anim_Stop()
	waitthread PlayAnim( spectre, "pt_reboot" )
	spectre.SetVelocity( Vector(0,0,0) )
}

function WaittillFinishedLeeching( player, target, e )
{
	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "ScriptAnimStop" )
	target.EndSignal( "OnDeath" )
	ButtonUnpressedEndSignal( player, "use" )

	wait 0 // hack, have to wait to get button status on server
	// really though all these input checks should probably be on client.
	if ( !ButtonPressed( player, "use" ) )
		return

	local waitTime = e.leechTime
	local timePassed = Time() - e.leechStartTime
	waitTime -= timePassed
	if ( waitTime > 0 )
		wait waitTime

	e.success = true
}

function PlayerLeechTargetAnimation( player, target, action, e )
{
	local targetStartOrg = target.GetOrigin()
	local targetStartAng = target.GetAngles()

	local initialPlayerPosition = player.GetOrigin()
	local initialTargetPosition = target.GetOrigin()

	local endOrigin = target.GetOrigin()
	local startOrigin = player.GetOrigin()
	local refVec = endOrigin - startOrigin

	local refAng = VectorToAngles( refVec )

	e.ref = CreateLeechingScriptMoverBetweenEnts( player, target )
	e.ref.SetOrigin( e.playerStartOrg )
	e.ref.EndSignal( "OnDestroy" )

	local playerSequence = CreateFirstPersonSequence()
	playerSequence.blendTime = 0.25
	playerSequence.attachment = "ref"

	local targetSequence = clone playerSequence

	playerSequence.thirdPersonAnim = action.playerAnimation3pStart
	playerSequence.thirdPersonAnimIdle = action.playerAnimation3pIdle
	playerSequence.firstPersonAnim = action.playerAnimation1pStart
	playerSequence.firstPersonAnimIdle = action.playerAnimation1pIdle

	targetSequence.thirdPersonAnim = action.targetAnimation3pStart
	targetSequence.thirdPersonAnimIdle = action.targetAnimation3pIdle

	local model = DATA_KNIFE_MODEL
	// moved to client
	//local firstPersonKnife = CreatePropDynamic( model )
	//firstPersonKnife.SetName( "firstPersonKnife" )
	//firstPersonKnife.SetParent( player.GetFirstPersonProxy(), "propgun", false, 0.0 )
	//e.knives.append( firstPersonKnife )

	local thirdPersonKnife = CreatePropDynamic( model )
	thirdPersonKnife.SetName( "thirdPersonKnife" )
	thirdPersonKnife.SetParent( player, "propgun", false, 0.0 )
	e.knives.append( thirdPersonKnife )

//	thread FirstPersonSequence( targetSequence, target, e.ref )
	player.SetSyncedEntity( target )
	thread NEEDCHILDTHREAD_PlayerLeechTargetAnimation( targetSequence, target, e.ref )
	waitthread FirstPersonSequence( playerSequence, player, e.ref )
}

//Basically copy pasted from CreateMeleeScriptMoverBetweenEnts
function CreateLeechingScriptMoverBetweenEnts( attacker, target )
{
	local endOrigin = target.GetOrigin()
	local startOrigin = attacker.GetOrigin()
	local refVec = endOrigin - startOrigin

	local refAng = VectorToAngles( refVec )
	if ( abs( refAng.x ) > 35 ) //If pitch is too much, use angles from target
			refAng = target.GetAngles()  // Leech does it from behind target, so use target's angles.


	local refPos = endOrigin - refVec * 0.5

	local ref = CreateScriptMover( attacker )
	ref.SetOrigin( refPos )
	ref.SetAngles( refAng )

	return ref
}

function NEEDCHILDTHREAD_PlayerLeechTargetAnimation( targetSequence, target, ref )
{
	ref.EndSignal( "OnDestroy" )
	target.EndSignal( "OnDestroy" )
	waitthread FirstPersonSequence( targetSequence, target, ref )
}

function PlayerExitLeechingAnim( player, target, action, e )
{
	local playerSequence = CreateFirstPersonSequence()
	playerSequence.blendTime = 0.0
	playerSequence.attachment = "ref"
	playerSequence.teleport = true

	local targetSequence = clone playerSequence

	playerSequence.thirdPersonAnim = action.playerAnimation3pEnd
	playerSequence.firstPersonAnim = action.playerAnimation1pEnd
	targetSequence.thirdPersonAnim = action.targetAnimation3pEnd

	thread FirstPersonSequence( targetSequence, target, e.ref )
	waitthread FirstPersonSequence( playerSequence, player, e.ref )
}

/*
	// Teleport player to closest, free space
	if ( IsAlive( player ) )
	{
		local playerPosition = player.GetOrigin()

		local testPositions = [ playerPosition ]
		if ( IsValid( target ) )
			testPositions.append( target.GetOrigin() )

		testPositions.append( initialPlayerPosition )

		local hullMin = player.GetPlayerMins()
		local hullMax = player.GetPlayerMaxs()

		local bestDistanceSq = ( initialPlayerPosition - playerPosition ).LengthSqr();
		local bestPosition = initialPlayerPosition

		foreach( position in testPositions )
		{
			position += Vector( 0, 0, 0.01 )

			local distanceSq = ( position - playerPosition ).LengthSqr()
			if ( distanceSq > bestDistanceSq )
				continue

			if ( !player.IsFreeSpace( position ) )
				continue

			bestDistanceSq = distanceSq
			bestPosition = position
		}

		player.SetAbsOrigin( bestPosition )
	}

*/