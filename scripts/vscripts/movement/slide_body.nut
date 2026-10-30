// Ordinary CLIENT consumer for native authored slide body animation.
// Local state comes only from the committed prediction snapshot; remote state
// comes only from the server-published entity network values. This never runs
// inside movement simulation or prediction and never writes player movement.
::PilotMovementBody <- {
	running = false,
	players = {}
}

function PilotMovement_BodyReset()
{
	local state = ::PilotMovementBody
	foreach ( player, record in state.players )
		if ( IsValid( player ) )
			Movement_SetSlideActivity( player, 0, false )
	state.players.clear()
}

function PilotMovement_BodyThink()
{
	Assert( IsClient() )
	local state = ::PilotMovementBody
	if ( state.running )
		return
	state.running = true
	OnThreadEnd( function() {
		PilotMovement_BodyReset()
		::PilotMovementBody.running = false
	} )
	while ( !( "clientScriptInitialized" in level ) || !level.clientScriptInitialized )
		wait 0

	level.ent.EndSignal( "OnDestroy" )

	local name = ::PilotMovementProgramName
	while ( state.running )
	{
		local localPlayer = GetLocalClientPlayer()
		local seen = {}
		foreach ( player in GetPlayerArray() )
		{
			if ( !IsValid( player ) || !player.IsPlayer() )
				continue
			seen[ player ] <- true

			local session = 0
			local sliding = false
			if ( player == localPlayer )
			{
				if ( IsAlive( player ) && !player.IsTitan() &&
					player == GetLocalViewPlayer() && !IsWatchingKillReplay() &&
					Movement_HasPresentation( name ) )
				{
					session = Movement_GetPresentationSession( name )
					sliding = Movement_GetPresentationInt( name, 0 ) != 0
				}
			}
			else if ( IsAlive( player ) && !player.IsTitan() )
			{
				// These values are published by the ordinary SERVER presentation
				// loop only after Movement_HasPlayerState succeeds.
				session = player.nv.pilotMovementSession
				sliding = session != 0 && player.nv.pilotMovementSlide
			}

			if ( session == 0 )
				sliding = false
		if ( GetConVarInt( "delta_pilot_slide_body" ) != 0 ) Movement_SetSlideActivity( player, session, sliding )
			state.players[ player ] <- { session = session, sliding = sliding }
		}

		local stale = []
		foreach ( player, record in state.players )
			if ( !( player in seen ) )
			{
				if ( IsValid( player ) )
					Movement_SetSlideActivity( player, 0, false )
				stale.append( player )
			}
		foreach ( player in stale )
			delete state.players[ player ]
		wait 0
	}
}
