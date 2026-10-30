// R1Delta automatic bunnyhopping (sv_autobunnyhopping).
//
// Native movement keeps the JUMP bit in the move's old-buttons field until the
// end of the move, and the native jump path refuses to jump while that bit is
// set. Clearing it during MOVE_SETUP makes a held jump look like a fresh press
// for that grounded command, so holding jump bunnyhops while jump power,
// gravity, collision, and the native movement dispatcher stay untouched.
//
// The source runs in the ordinary script environment; this base-tree controller
// owns the server's per-player opt-in according to sv_autobunnyhopping.
// Both peers register identical source. Registration is inert and, in API v3,
// no longer depends on native hook readiness.

::AutoBhopProgramName <- "autobhop"

::AutoBhopSource <- @"
if (Move_GetPhase() == MOVE_SETUP && Move_IsAlive() && !Move_IsTitan())
{
    if ((Move_GetButtons() & MOVE_BUTTON_JUMP) != 0 && Move_IsOnGround())
        Move_SetOldButtons(Move_GetOldButtons() & ~MOVE_BUTTON_JUMP);
}
"

::AutoBhopRegistered <- false
::AutoBhopLastError <- ""

// Registration alone does not change movement; it only makes the program
// available to the server's per-player opt-in. Repeated identical registration
// is accepted by the API, so this is safe to retry.
function AutoBhop_Register( quiet = false )
{
	if ( ::AutoBhopRegistered )
		return true

	if ( !( "Movement_Register" in getroottable() ) )
	{
		::AutoBhopLastError = "script movement API is unavailable"
		if ( !quiet )
			printl( "R1Delta autobhop: " + ::AutoBhopLastError )
		return false
	}

	try
	{
		Movement_Register( ::AutoBhopProgramName, ::AutoBhopSource, 0, "" )
	}
	catch ( error )
	{
		::AutoBhopLastError = "" + error
		if ( !quiet )
			printl( "R1Delta autobhop: movement program registration failed: " + error )
		return false
	}

	::AutoBhopRegistered = true
	::AutoBhopLastError = ""
	return true
}

// Client side: the server refuses to run a program the client does not know,
// so keep retrying until map-load registration has been accepted.
function AutoBhop_ClientRegisterThink()
{
	for ( local attempt = 0 ; attempt < 40 ; attempt++ )
	{
		if ( AutoBhop_Register( true ) )
		{
			printl( "R1Delta autobhop: client registration recovered after map load." )
			return
		}
		wait 0.25
	}
	printl( "R1Delta autobhop: client registration failed: " + ::AutoBhopLastError )
}

function AutoBhop_SetPlayerEnabled( player, enabled )
{
	try
	{
		if ( enabled )
			Movement_Enable( player, ::AutoBhopProgramName )
		else
			Movement_Disable( player )
		return true
	}
	catch ( error )
	{
		printl( "R1Delta autobhop: player " + player.entindex() + " could not be " + ( enabled ? "enabled" : "disabled" ) + ": " + error )
		return false
	}
}

function AutoBhop_ReconcilePlayers()
{
	local shouldEnable = GetConVarBool( "sv_autobunnyhopping" )
	foreach ( player in GetPlayerArray() )
	{
		if ( !IsValid( player ) )
			continue
		local enabled = Movement_IsEnabled( player, ::AutoBhopProgramName )
		// One program owns a player; preserve a mod's explicit opt-in.
		if ( Movement_IsEnabled( player, "" ) && !enabled )
			continue
		if ( shouldEnable != enabled )
			AutoBhop_SetPlayerEnabled( player, shouldEnable )
	}
}

// Server only: own the program registration and follow sv_autobunnyhopping for
// the whole match. Registration is retried here because this Squirrel thread is
// the same context that interactive `script` commands use.
function AutoBhop_ServerThink()
{
	local reportedFailure = false

	for ( ;; )
	{
		if ( !::AutoBhopRegistered )
		{
			if ( AutoBhop_Register( reportedFailure ) )
				printl( "R1Delta autobhop: server registration recovered after map load." )
			else
				reportedFailure = true
		}

		if ( ::AutoBhopRegistered )
			AutoBhop_ReconcilePlayers()

		wait 0.25
	}
}
