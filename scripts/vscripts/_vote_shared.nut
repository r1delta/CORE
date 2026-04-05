
function main()
{
	RegisterSignal( "EndVote" )

	level.voteAnnounceCardInfos <- {}
	Vote_CreateAnnounceCards()

	Globalize( VoteTypeNeedsTarget )
	Globalize( PlayerCanVote )
	Globalize( PlayerHasAlreadyVoted )
	Globalize( PlayerVotedYes )
	Globalize( PlayerVotedNo )

	Globalize( GetPlayerVoteOption )
	Globalize( GetVoteTargetInfo )
	Globalize( GetVoteDuration )
	Globalize( GetNextVotedMap )
	Globalize( GetNextVotedMode )

	Globalize( CanCreateVoteOfType )
}

// -------------------------
// ---- ENEMY ANNOUNCES ----
// -------------------------
function Vote_CreateAnnounceCards()
{
	CreateVoteAnnounceCard( eVoteType.kickPlayer, "#VOTETYPE_KICK", "#VOTETYPE_KICK_DESC", "../ui/menu/items/mod_icons/slammer" )
	CreateVoteAnnounceCard( eVoteType.mapChange, "#VOTETYPE_CHANGE_LEVEL", "#VOTETYPE_CHANGE_LEVEL_DESC", "../ui/menu/items/passive_icons/run_and_gun" )
	CreateVoteAnnounceCard( eVoteType.nextMap, "#VOTETYPE_NEXT_LEVEL", "#VOTETYPE_NEXT_LEVEL_DESC", "../ui/menu/items/passive_icons/stealth_movement" )

	if ( !GetCinematicMode() )
		CreateVoteAnnounceCard( eVoteType.nextMode, "#VOTETYPE_NEXT_GAMEMODE", "#VOTETYPE_NEXT_GAMEMODE_DESC", "../ui/menu/items/mod_icons/starburst" )

	if ( GAMETYPE != COOPERATIVE )
	{
		CreateVoteAnnounceCard( eVoteType.teamScramble, "#VOTETYPE_SCRAMBLE", "#VOTETYPE_SCRAMBLE_DESC", "../ui/menu/items/mod_icons/counterweight" )
		CreateVoteAnnounceCard( eVoteType.toggleAlltalk, "#VOTETYPE_ALLTALK", "#VOTETYPE_ALLTALK_DESC", "../ui/menu/scoreboard/sb_icon_voip_party_talk" )
	}

	CreateVoteAnnounceCard( eVoteType.restartMatch, "#VOTETYPE_RESTART_MATCH", "#VOTETYPE_RESTART_MATCH_DESC", "../ui/menu/items/passive_icons/dead_mans_trigger" )
	CreateVoteAnnounceCard( eVoteType.serverCustom, "#VOTETYPE_SERVER_CUSTOM", "#VOTETYPE_SERVER_CUSTOM_DESC", "../ui/menu/items/passive_icons/icepick" )

	CreateVoteAnnounceCard( eVoteType.voteTargetInfo, "#VOTETYPE_TARGET", "#VOTETYPE_TARGET_DESC", "hud/mfd_enemy" )
	CreateVoteAnnounceCard( eVoteType.voteYes, "#YES", "#VOTETYPE_YES_DESC", "../ui/menu/r1delta/vote_yes" )
	CreateVoteAnnounceCard( eVoteType.voteNo, "#NO", "#VOTETYPE_NO_DESC", "../ui/menu/r1delta/vote_no" )
}

function CreateVoteAnnounceCard( voteTypeIdx, title, description, icon )
{
	ValidateVoteTypeIdx( voteTypeIdx )

	Assert( !( voteTypeIdx in level.voteAnnounceCardInfos ), "Already created enemy announce card for voteTypeIdx: " + voteTypeIdx )

	local table = {}
	level.voteAnnounceCardInfos[ voteTypeIdx ] <- table

	table.voteTypeIdx <- voteTypeIdx
	table.title <- title

	table.icon <- icon
	table.description <- description

	return table
}

function ValidateVoteTypeIdx( voteTypeIdx )
{
	local foundIt = false
	foreach ( aiNameKey, id in getconsttable().eVoteType )
	{
		if ( id == voteTypeIdx )
		{
			foundIt = true
			break
		}
	}
	Assert( foundIt, "Couldn't find voteTypeIdx " + voteTypeIdx + " in eVoteType enum" )
}
Globalize( ValidateVoteTypeIdx )

function VoteTypeNeedsTarget( voteTypeID )
{
	switch( voteTypeID )
	{
		case eVoteType.kickPlayer:
		case eVoteType.mapChange:
		case eVoteType.nextMap:
		case eVoteType.nextMode:
			return true
	}

	return false
}

function PlayerCanVote( player )
{
	if ( !IsValid( player ) )
		return false

	if ( !level.nv.voteInProgress )
		return false

	if ( PlayerHasAlreadyVoted( player ) )
		return false

	return true
}

function PlayerHasAlreadyVoted( player )
{
	return ( PlayerVotedYes( player ) || PlayerVotedNo( player ) )
}

function PlayerVotedYes( player )
{
	local entIndex = player.GetEntIndex()
	local playerBit = 1 << ( entIndex - 1 )

	if ( playerBit & level.nv.playersVotingYes )	// is the player bit set in the data
		return true

	return false
}

function PlayerVotedNo( player )
{
	local entIndex = player.GetEntIndex()
	local playerBit = 1 << ( entIndex - 1 )

	if ( playerBit & level.nv.playersVotingNo )	// is the player bit set in the data
		return true

	return false
}

function GetPlayerVoteOption( player )
{
	if ( PlayerVotedYes( player ) )
		return level.nv.playersVotingYes

	if ( PlayerVotedNo( player ) )
		return level.nv.playersVotingNo

	return null
}

function GetVoteTargetInfo( voteTypeID, target )
{
	local info = null
	switch ( voteTypeID )
	{
		case eVoteType.kickPlayer:
			foreach ( player in GetPlayerArray() )
			{
				if ( player.GetEntIndex() == target )
					info = player.GetPlayerName()
			}
			break

		case eVoteType.mapChange:
			info = GetMapDisplayName( GetCurrentPlaylistMapByIndex( target ) )
			break
	}

	return info
}

function GetVoteDuration()
{
	return GetConVarFloat( "delta_vote_timer_duration" )
}

function GetNextVotedMap()
{
	if ( GetConVarString( "delta_vote_next_map" ) != "" )
		return GetConVarString( "delta_vote_next_map" )

	return GetMapName()
}

function GetNextVotedMode()
{
	if ( GetConVarString( "delta_vote_next_mode" ) != "" && !GetCinematicMode() )
		return GetConVarString( "delta_vote_next_mode" )

	return GameRules.GetGameMode()
}

function CanCreateVoteOfType( voteTypeID, target, ignoreNextVoteTime = false )
{
	if ( !GetConVarBool( "delta_vote_allowed" ) )
		return false

	if ( GetGameState() < eGameState.Playing || GetGameState() == eGameState.Postmatch )
		return false

	if ( level.nv.voteInProgress )
		return false

	if ( IsServer() )
	{
		if ( Time() < level.nextTimeCanVote[voteTypeID] && !ignoreNextVoteTime )
			return false
	}

	if ( !IsValid( target ) && VoteTypeNeedsTarget( voteTypeID ) )
		return false

	switch( voteTypeID )
	{
		case eVoteType.kickPlayer:
			if ( target.s.voteKickImmunity == true )
				return false
			break

		case eVoteType.mapChange:
			if ( !GetCurrentPlaylistMapByIndex( target ) )
				return false
			break
		
		case eVoteType.nextMode:
			if ( GetCinematicMode() )
				return false
			break
	}

	local noCoop = [ eVoteType.teamScramble, eVoteType.toggleAlltalk ]
	if ( GAMETYPE == COOPERATIVE && ( voteTypeID in noCoop ) )
		return false

	local TEMP_DISABLEDVOTES = [ eVoteType.kickPlayer, eVoteType.teamScramble ]
	if ( voteTypeID in TEMP_DISABLEDVOTES )
		return false

	return voteTypeID < eVoteType.voteTargetInfo
}

main()
