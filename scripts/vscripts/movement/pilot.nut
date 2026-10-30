// Shared v3 reference program. Base mapspawn includes this file on both peers;
// registration is inert until SERVER explicitly calls PilotMovement_Enable.
IncludeScript( "movement/slide" )
IncludeScript( "movement/grapple" )
IncludeScript( "movement/slide_audio" )
if ( IsClient() )
{
	IncludeScript( "movement/slide_body" )
	IncludeScript( "movement/pilot_client" )
}
else
	IncludeScript( "movement/pilot_server" )

::PilotMovementProgramName <- "pilot.slide_grapple"
::PilotMovementRegistered <- false
::PilotMovementGrappleHeld <- false

function PilotMovement_Register()
{
	if ( ::PilotMovementRegistered )
		return
	if ( Movement_GetApiVersion() != 3 )
		throw "pilot.slide_grapple requires movement API 3"
	local setup = "if (Move_GetPhase() == MOVE_SETUP) Move_SetCheckpointMask(MOVE_CHECKPOINT_ALL);\n"
	Movement_Register( ::PilotMovementProgramName, setup + ::PredictedSlideSource + "\n" + ::PredictedGrappleSource, 64, "PilotMovement_Event" )
	if ( IsClient() )
	{
		Movement_SetInputCallback( ::PilotMovementProgramName, "PilotMovement_Input" )
		thread PilotMovement_ClientThink()
		thread PilotMovement_BodyThink()
	}
	else
		thread PilotMovement_ServerThink()
	::PilotMovementRegistered = true
}

function PilotMovement_Enable( player )
{
	Assert( IsServer() )
	PilotMovement_Register()
	Movement_Enable( player, ::PilotMovementProgramName )
}

function PilotMovement_Disable( player )
{
	Assert( IsServer() )
	if ( Movement_IsEnabled( player, ::PilotMovementProgramName ) )
	{
		Movement_Disable( player )
		PilotMovement_ServerCleanup( player )
	}
}

// Ordinary input state is sampled only while constructing a new usercmd. The
// native payload, not this variable, supplies simulation and prediction replays.
function PilotMovement_GrapplePressed( ... ) { ::PilotMovementGrappleHeld = true }
function PilotMovement_GrappleReleased( ... ) { ::PilotMovementGrappleHeld = false }
function PilotMovement_Input()
{
	Move_InputSetButtons( ::PilotMovementGrappleHeld ? 1 : 0 )
}

function PilotMovement_Event( command, event, x, y, z )
{
	if ( event == MOVE_EVENT_RESET )
	{
		::PilotMovementGrappleHeld = false
		PilotMovement_ClientReset()
	}
}
