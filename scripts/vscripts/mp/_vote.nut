
function main()
{
	IncludeFile( "_vote_shared" )

	if ( IsLobby() )
		return

	AddCallback_OnClientConnected( Vote_PlayerConnected )
	AddCallback_OnClientDisconnected( Vote_PlayerDisconnected )

	AddClientCommandCallback( "StartVote", ClientCommand_PressedStartVote )
	AddClientCommandCallback( "VoteOption", ClientCommand_PressedVoteOption )

	level.playerVoteOwner <- null
	level.nextTimeCanVote <- {}
	for ( local i = 0; i < eVoteType.voteTargetInfo; i++ )
	{
		level.nextTimeCanVote[i] <- 0
	}
	level.customVote_StartFunc <- null
	level.customVote_SuccessFunc <- null
	level.customVote_FailureFunc <- null

	Globalize( SetPlayerHasVotekickImmunity )
	Globalize( StartCustomServerVote )
	Globalize( StartServerVote )
	Globalize( EndCurrentVote )

	Globalize( Dev_ForcePlayerStartVote )
	Globalize( Dev_ForcePlayerVote )
	Globalize( Dev_ForceVoteWin )
	Globalize( Dev_ForceVoteLose )
}

function Vote_PlayerConnected( player )
{
	player.s.voteKickImmunity <- false
	player.s.nextVoteCreateTime <- 0
}

function Vote_PlayerDisconnected( player )
{
	if ( PlayerHasAlreadyVoted( player ) )
		SetPlayerHasVoted( player, false )
}

function ClientCommand_PressedStartVote( player, ... )
{
	if ( vargc <= 0 )
		return true

	if ( level.nv.voteInProgress )
		return true

	if ( PlayerHasAlreadyVoted( player ) )
		return true

	if ( Time() < player.s.nextVoteCreateTime && GetPlayerArray().len() > 1 )
		return false

	if ( player == level.playerVoteOwner )
		return true

	local choice = vargv[0].tointeger()
	if ( choice == null )
		return

	local target = null
	if ( vargc > 1 )
		target = vargv[1].tointeger()

	thread StartVoteUI( player, choice, target )

	return true
}

function StartVoteUI( caller, choice, target, ignoreNextVoteTime = false )
{
	if ( !CanCreateVoteOfType( choice, target, ignoreNextVoteTime ) )
		return

	if ( choice == eVoteType.serverCustom && level.customVote_StartFunc != null )
		level.customVote_StartFunc( caller, target )

	local callerIsPlayer = caller && caller.IsPlayer()
	if ( callerIsPlayer && !GetConVarBool( "delta_vote_holder_may_vote_no" ) )
		SetPlayerHasVotedYes( caller, true )

	//caller.EndSignal( "Disconnected" )
	level.ent.EndSignal( "EndVote" )

	OnThreadEnd (
		function() : ( caller, choice, target )
		{
			thread VoteEnded( caller, choice, target )
		}
	)

	level.nv.voteInProgress = true
	level.nv.votePeriodInProgress = true
	level.playerVoteOwner = caller

	local callerEHandle = null
	if ( callerIsPlayer )
		callerEHandle = caller.GetEncodedEHandle()

	foreach( player in GetPlayerArray() )
	{
		printt( "a" )
		Remote.CallFunction_NonReplay( player, "ServerCallback_NewVoteAnnounceCards", choice, callerEHandle, target )
	}

	wait GetVoteDuration()
}

function VoteEnded( caller, choice, target )
{
	local success = level.nv.playersVotingYes > level.nv.playersVotingNo
	level.nv.votePeriodInProgress = false

	if ( caller && caller.IsPlayer() )
		caller.s.nextVoteCreateTime = Time() + GetConVarFloat( "delta_vote_creation_timer" )

	foreach( player in GetPlayerArray() )
	{
		printt( "b" )
		printt( "level.nv.playersVotingYes " + level.nv.playersVotingYes )
		printt( "level.nv.playersVotingNo " + level.nv.playersVotingNo )
		Remote.CallFunction_NonReplay( player, "ServerCallback_VoteEnded", choice, success )
	}

	if ( !success )
	{
		printt( "VOTE SYSTEM: vote failed" )
		level.nv.voteInProgress = false
		level.playerVoteOwner = null
		level.nv.playersVotingYes = 0
		level.nv.playersVotingNo = 0

		level.nextTimeCanVote[choice] <- Time() + GetConVarFloat( "delta_vote_failure_timer" )

		if ( choice == eVoteType.serverCustom && level.customVote_FailureFunc != null )
		{
			level.customVote_FailureFunc( caller, target )

			level.customVote_StartFunc = null
			level.customVote_SuccessFunc = null
			level.customVote_FailureFunc = null
		}

		return
	}

	wait 3.0

	level.nv.voteInProgress = false
	level.playerVoteOwner = null
	level.nv.playersVotingYes = 0
	level.nv.playersVotingNo = 0

	level.nextTimeCanVote[choice] <- Time()

	local targetInfo = GetVoteTargetInfo( choice, target )

	printt( "============================" )
	switch( choice )
	{
		case eVoteType.kickPlayer:
			thread KickPlayer( target )
			break

		case eVoteType.mapChange:
			if ( targetInfo )
				MapChange( targetInfo )
			break

		case eVoteType.nextMap:
			ServerCommand( "delta_vote_next_map " + target )
			break

		case eVoteType.nextMode:
			ServerCommand( "delta_vote_next_mode " + target )
			break

		case eVoteType.teamScramble:
			TeamScramble()
			break

		case eVoteType.toggleAlltalk:
			if ( GetConVarBool( "sv_alltalk" ) )
				ServerCommand( "sv_alltalk 0" )
			else
				ServerCommand( "sv_alltalk 1" )
			break

		case eVoteType.restartMatch:
			ServerCommand( "changelevel " + GetMapName() )
			break

		case eVoteType.serverCustom:
			serverCustom()
			break
	}
}

function KickPlayer( target )
{
	ServerCommand( "kickid " + target.GetUserId() )
	wait 0.5
	foreach( player in GetPlayerArray() )
	{
		//if ( PlayerVotedYes( player ) )
			PlayConversationToPlayer( "PlayerKicked", player )
	}
}

function MapChange( targetInfo )
{
	// script_client printt( GetPlaylistUniqueMaps( GetCurrentPlaylistName() ).len() )

	local modeName = GetNextVotedMode()
	if ( IsMultiGamemodePlaylist( GetCurrentPlaylistName() ) )
		GameRules_ChangeCampaignMap( targetInfo, modeName )
	else
		GameRules_ChangeMap( targetInfo, modeName )

	ServerCommand( "delta_vote_next_map \"\"" )
	ServerCommand( "delta_vote_next_mode \"\"" )
}

function TeamScramble()
{
	// Need a better way to handle this
	return

	local playerArray = GetPlayerArray()
	ArrayRandomize( playerArray )

	local i = 0
	foreach( player in playerArray )
	{
		if ( i < playerArray.len() / 2 )
		{
			AutoBalancePlayer( player, true )
		}
		i++
	}
}

function serverCustom()
{
	if ( level.customVote_SuccessFunc != null )
		level.customVote_SuccessFunc( caller, target )

	level.customVote_StartFunc = null
	level.customVote_SuccessFunc = null
	level.customVote_FailureFunc = null
}

function ClientCommand_PressedVoteOption( player, ... )
{
	if ( vargc <= 0 )
		return true

	if ( !PlayerCanVote( player ) )
		return true

	if ( player == level.playerVoteOwner && !GetConVarBool( "delta_vote_holder_may_vote_no" ) )
		return true

	local choice = vargv[0].tointeger()

	if ( choice != 0 )
		SetPlayerHasVotedYes( player, true )
	else
		SetPlayerHasVotedNo( player, true )

	local playerArray = GetPlayerArray()
	if ( playerArray.len() > 1 && level.nv.playersVotingYes >= playerArray.len() )
		EndCurrentVote()

	return true
}

function SetPlayerHasVoted( player, state )
{
	if ( GetPlayerVoteOption( player ) == level.nv.playersVotingYes )
		SetPlayerHasVotedYes( player, state )
	else if ( GetPlayerVoteOption( player ) == level.nv.playersVotingNo )
		SetPlayerHasVotedNo( player, state )
}

function SetPlayerHasVotedYes( player, state )
{
	printt( "PLAYER VOTED YES" )
	local entIndex = player.GetEntIndex()
	local data = level.nv.playersVotingYes
	local playerBit = 1 << ( entIndex - 1 )					// 1 = 0x01, 2 = 0x02, 3 = 0x04, 4 = 0x08

	if ( state == true )
		level.nv.playersVotingYes = playerBit | data		// set the player bit
	else
		level.nv.playersVotingYes = ~playerBit & data	// clear the player bit
}

function SetPlayerHasVotedNo( player, state )
{
	printt( "PLAYER VOTED NO" )
	local entIndex = player.GetEntIndex()
	local data = level.nv.playersVotingNo
	local playerBit = 1 << ( entIndex - 1 )					// 1 = 0x01, 2 = 0x02, 3 = 0x04, 4 = 0x08

	if ( state == true )
		level.nv.playersVotingNo = playerBit | data		// set the player bit
	else
		level.nv.playersVotingNo = ~playerBit & data	// clear the player bit
}

// So people cant kick lexi on her own server for example
function SetPlayerHasVotekickImmunity( player, state )
{
	if ( !player )
		return

	player.s.voteKickImmunity = state
}

// startFunction = function called when the vote starts
// successFunction = function called when the vote succeeds
// failureFunction = function called when the vote fails
function StartCustomServerVote( startFunction, successFunction, failureFunction )
{
	if ( level.nv.voteInProgress )
		return

	level.customVote_StartFunc = startFunction
	level.customVote_SuccessFunc = successFunction
	level.customVote_FailureFunc = failureFunction

	StartServerVote( eVoteType.serverCustom )
}

function StartServerVote( choice, target = null )
{
	if ( level.nv.voteInProgress )
		return

	thread StartVoteUI( level.ent, choice, target, true )
}

function EndCurrentVote()
{
	level.ent.Signal( "EndVote"  )

	foreach ( player in GetPlayerArray() )
	{
		Remote.CallFunction_NonReplay( player, "ServerCallback_EndCurrentVote" )
	}
}

function Dev_ForcePlayerStartVote( player, choice, target = null )
{
	if ( level.nv.voteInProgress )
		return

	thread StartVoteUI( player, choice, target )
}

function Dev_ForcePlayerVote( player, choice )
{
	if ( !level.nv.voteInProgress )
		return

	if ( choice != 0 )
		SetPlayerHasVotedYes( player, true )
	else
		SetPlayerHasVotedNo( player, true )
}

// Probably not good to use in a real game, but theyre debug functions so who cares
function Dev_ForceVoteWin()
{
	if ( !level.nv.voteInProgress )
		return

	level.nv.playersVotingYes = 32
}

function Dev_ForceVoteLose()
{
	if ( !level.nv.voteInProgress )
		return

	level.nv.playersVotingNo = 32
}

main()
