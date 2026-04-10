
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

function VoteTypeNeedsString( voteTypeID )
{
 	switch( voteTypeID )
	{
		case eVoteType.mapChange:
		case eVoteType.nextMap:
		case eVoteType.nextMode:
			return true
	}

	return false   
}

function CanCreateVoteOfType( voteTypeID, target, ignoreNextVoteTime = false )
{
	if ( !GetConVarBool( "delta_vote_allowed" ) )
		return false

	if ( IsVoteInProgress() )
		return false

	if ( IsServer() )
	{
		if ( Time() < level.nextTimeCanVote[voteTypeID] && !ignoreNextVoteTime )
			return false
	}

    if ( !IsUI() )
    {
	    if ( GetGameState() < eGameState.Playing || GetGameState() == eGameState.Postmatch )
	    	return false

	    if ( !IsValid( target ) && VoteTypeNeedsTarget( voteTypeID ) )
	    	return false

	    switch( voteTypeID )
	    {
	    	case eVoteType.kickPlayer:
	    		if ( target.s.voteKickImmunity == true )
	    			return false
	    		break

	    	//case eVoteType.mapChange:
	    	//	if ( !GetCurrentPlaylistMapByIndex( target ) )
	    	//		return false
	    	//	break
		
	    	case eVoteType.nextMode:
	    		if ( GetCinematicMode() )
	    			return false
	    		break
	    }
    }

	if ( GetConVarString( "mp_gamemode" ) == COOPERATIVE && ( voteTypeID == eVoteType.teamScramble || voteTypeID == eVoteType.toggleAlltalk ) )
		return false

	// TEMP, they dont work yet
	if ( voteTypeID == eVoteType.kickPlayer || voteTypeID == eVoteType.teamScramble || voteTypeID == eVoteType.nextMode )
		return false

	return voteTypeID >= eVoteType.kickPlayer && voteTypeID < eVoteType.voteTargetInfo
}

function IsVoteInProgress()
{
    if ( IsUI() )
        return level.ui.voteInProgress

    return level.nv.voteInProgress
}
