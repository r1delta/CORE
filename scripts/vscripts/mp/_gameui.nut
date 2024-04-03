
function main()
{
	Globalize( GetInput_XAxis )
	Globalize( GetInput_YAxis )
	Globalize( ButtonPressed )
	Globalize( WaitButtonPressed )
	Globalize( WaitAnyButtonPressed )
	Globalize( WaitButtonUnpressed )
	Globalize( CreatePlayerGameUI )
	Globalize( ButtonEndSignal )	
	Globalize( ButtonUnpressedEndSignal )
}

function CreatePlayerGameUI( player )
{
	Assert( !( "gameUI" in player.s ), "Player " + player + " already has a gameui" )
	Assert( player.GetClassname() == "player", "Player " + player + " is not a player." )

	// hack bad way to do get player input (spawning an entity, waiting on signals to send a signal)
	local gameui = CreateEntity( "game_ui" )
	gameui.SetName( UniqueString() )
	if ( IsMultiplayer() )
		gameui.kv.spawnflags = 32
	gameui.kv.FieldOfView = -1.0
	DispatchSpawn( gameui, false )

	gameui.Fire( "Activate", "", 0, player, null )

	player.s.gameUI <- gameui
	
	// will get deleted when the player quits server
	AddOwnedEntity( player, gameui )
	
	RegisterSignal( "WaitAnyButtonPressed" )
	
	gameui.s.player <- player
	gameui.s.buttonState <- {}
	gameui.s.buttonSignalPressed <- {}
	gameui.s.buttonSignalUnpressed <- {}

	AddGameUIHandleAxis( gameui, "XAxis", GameUI_XAxis )
	AddGameUIHandleAxis( gameui, "YAxis", GameUI_YAxis )
	
	AddGameUIButton( gameui, "attack", "PressedAttack", "UnpressedAttack", PressedAttack, UnpressedAttack );
	AddGameUIButton( gameui, "offhand1", "PressedOffhand1", "UnpressedOffhand1", PressedOffhand1, UnpressedOffhand1 );
	AddGameUIButton( gameui, "offhand2", "PressedOffhand2", "UnpressedOffhand2", PressedOffhand2, UnpressedOffhand2 );
	AddGameUIButton( gameui, "jump", "PressedJump", "UnpressedJump", PressedJump, UnpressedJump );
	AddGameUIButton( gameui, "left", "PressedLeft", "UnpressedLeft", PressedLeft, UnpressedLeft );
	AddGameUIButton( gameui, "right", "PressedRight", "UnpressedRight", PressedRight, UnpressedRight );
	AddGameUIButton( gameui, "forward", "PressedForward", "UnpressedForward", PressedForward, UnpressedForward );
	AddGameUIButton( gameui, "back", "PressedBack", "UnpressedBack", PressedBack, UnpressedBack );
	AddGameUIButton( gameui, "use", "PressedUse", "UnpressedUse", PressedUse, UnpressedUse );
	AddGameUIButton( gameui, "reload", "PressedReload", "UnpressedReload", PressedReload, UnpressedReload );
	AddGameUIButton( gameui, "useandreload", "PressedUseAndReload", "UnpressedUseAndReload", PressedUseAndReload, UnpressedUseAndReload );
	AddGameUIButton( gameui, "sprint", "PressedSpeed", "UnpressedSpeed", PressedSpeed, UnpressedSpeed );
	AddGameUIButton( gameui, "ads", "PressedZoom", "UnpressedADS", PressedADS, UnpressedADS );
	AddGameUIButton( gameui, "crouch", "PressedDuck", "UnpressedDuck", PressedDuck, UnpressedDuck );
	AddGameUIButton( gameui, "changeweapon", "PressedWeaponCycle", "UnpressedWeaponCycle", PressedWeaponCycle, UnpressedWeaponCycle );
	AddGameUIButton( gameui, "pause", "PressedPauseMenu", "UnpressedPauseMenu", PressedPauseMenu, UnpressedPauseMenu );
	AddGameUIButton( gameui, "dpad_up", "PressedFireteam1", "UnpressedFireteam1", PressedFireteam1, UnpressedFireteam1 );
	AddGameUIButton( gameui, "dpad_down", "PressedFireteam2", "UnpressedFireteam2", PressedFireteam2, UnpressedFireteam2 );
	AddGameUIButton( gameui, "dpad_left", "PressedFireteam3", "UnpressedFireteam3", PressedFireteam3, UnpressedFireteam3 );
	AddGameUIButton( gameui, "dpad_right", "PressedFireteam4", "UnpressedFireteam4", PressedFireteam4, UnpressedFireteam4 );
}

function GetInput_XAxis( player )
{
	return player.s.gameUI.s.XAxis
}

function GetInput_YAxis( player )
{
	return player.s.gameUI.s.YAxis
}

function ButtonPressed( player, button )
{
	Assert( button in player.s.gameUI.s.buttonState, "No button " + button + " for player input." )
	return player.s.gameUI.s.buttonState[ button ]
}

function ButtonEndSignal( player, button )
{
	player.s.gameUI.EndSignal( player.s.gameUI.s.buttonSignalPressed[ button ] )
}

function ButtonUnpressedEndSignal( player, button )
{
	player.s.gameUI.EndSignal( player.s.gameUI.s.buttonSignalUnpressed[ button ] )
}

function WaitButtonPressed( player, button )
{
	player.s.gameUI.WaitSignal( player.s.gameUI.s.buttonSignalPressed[ button ] )
}

function WaitAnyButtonPressed( player, buttonArray )
{
	local signaler = {}	// create a table that we can signal when one of the buttons is pressed
	
	foreach( button in buttonArray )
		thread _WaitAnyButtonPressed( player, signaler, button )
	
	WaitSignal( signaler, "WaitAnyButtonPressed" )
}

function _WaitAnyButtonPressed( player, signaler, button )
{
	EndSignal( signaler, "WaitAnyButtonPressed" )
	WaitButtonPressed( player, button )
	Signal( signaler, "WaitAnyButtonPressed" )
}

function WaitButtonUnpressed( player, button )
{
	player.s.gameUI.WaitSignal( player.s.gameUI.s.buttonSignalUnpressed[ button ] )
}

// internal functions
function AddGameUIButton( gameUI, button, outputOn, outputOff, funcOn, funcOff )
{
	gameUI.s.buttonState[ button ] <- false

	gameUI.s.buttonSignalPressed[ button ] <- "Signal" + outputOn
	gameUI.s.buttonSignalUnpressed[ button ] <- "Signal" + outputOff
	RegisterSignal( "Signal" + outputOn )
	RegisterSignal( "Signal" + outputOff )
	
	gameUI.ConnectOutput( outputOn, funcOn )
	gameUI.ConnectOutput( outputOff, funcOff )
}

function AddGameUIHandleAxis( gameui, output, func )
{
	gameui.s[ output ] <- 0
	gameui.ConnectOutput( output, func )
}

////////////////////////////////////////////////////////////////////////////////
// functions ConnectOutput'd to:
function GameUI_XAxis( self, activator, caller, value )
{
	self.s[ "XAxis" ] = value
}
function GameUI_YAxis( self, activator, caller, value )
{
	self.s[ "YAxis" ] = value
}


function PressedAttack( self, activator, caller, value )
{
	local button = "attack"
	self.s.buttonState[ button ] = true
	self.Signal( self.s.buttonSignalPressed[ button ] )
}
function UnpressedAttack( self, activator, caller, value )
{
	local button = "attack"
	self.s.buttonState[ button ] = false
	self.Signal( self.s.buttonSignalUnpressed[ button ] )
}

function PressedOffhand1( self, activator, caller, value )
{
	local button = "offhand1"
	self.s.buttonState[ button ] = true
	self.Signal( self.s.buttonSignalPressed[ button ] )
}
function UnpressedOffhand1( self, activator, caller, value )
{
	local button = "offhand1"
	self.s.buttonState[ button ] = false
	self.Signal( self.s.buttonSignalUnpressed[ button ] )
}

function PressedOffhand2( self, activator, caller, value )
{
	local button = "offhand2"
	self.s.buttonState[ button ] = true
	self.Signal( self.s.buttonSignalPressed[ button ] )
}
function UnpressedOffhand2( self, activator, caller, value )
{
	local button = "offhand2"
	self.s.buttonState[ button ] = false
	self.Signal( self.s.buttonSignalUnpressed[ button ] )
}

function PressedJump( self, activator, caller, value )
{
	local button = "jump"
	self.s.buttonState[ button ] = true
	self.Signal( self.s.buttonSignalPressed[ button ] )
}
function UnpressedJump( self, activator, caller, value )
{
	local button = "jump"
	self.s.buttonState[ button ] = false
	self.Signal( self.s.buttonSignalUnpressed[ button ] )
}

function PressedLeft( self, activator, caller, value )
{
	local button = "left"
	self.s.buttonState[ button ] = true
	self.Signal( self.s.buttonSignalPressed[ button ] )
}
function UnpressedLeft( self, activator, caller, value )
{
	local button = "left"
	self.s.buttonState[ button ] = false
	self.Signal( self.s.buttonSignalUnpressed[ button ] )
}

function PressedRight( self, activator, caller, value )
{
	local button = "right"
	self.s.buttonState[ button ] = true
	self.Signal( self.s.buttonSignalPressed[ button ] )
}
function UnpressedRight( self, activator, caller, value )
{
	local button = "right"
	self.s.buttonState[ button ] = false
	self.Signal( self.s.buttonSignalUnpressed[ button ] )
}

function PressedForward( self, activator, caller, value )
{
	local button = "forward"
	self.s.buttonState[ button ] = true
	self.Signal( self.s.buttonSignalPressed[ button ] )
}
function UnpressedForward( self, activator, caller, value )
{
	local button = "forward"
	self.s.buttonState[ button ] = false
	self.Signal( self.s.buttonSignalUnpressed[ button ] )
}

function PressedBack( self, activator, caller, value )
{
	local button = "back"
	self.s.buttonState[ button ] = true
	self.Signal( self.s.buttonSignalPressed[ button ] )
}
function UnpressedBack( self, activator, caller, value )
{
	local button = "back"
	self.s.buttonState[ button ] = false
	self.Signal( self.s.buttonSignalUnpressed[ button ] )
}

function PressedUse( self, activator, caller, value )
{
	local button = "use"
	self.s.buttonState[ button ] = true
	self.Signal( self.s.buttonSignalPressed[ button ] )
}
function UnpressedUse( self, activator, caller, value )
{
	local button = "use"
	self.s.buttonState[ button ] = false
	self.Signal( self.s.buttonSignalUnpressed[ button ] )
}

function PressedReload( self, activator, caller, value )
{
	local button = "reload"
	self.s.buttonState[ button ] = true
	self.Signal( self.s.buttonSignalPressed[ button ] )
}
function UnpressedReload( self, activator, caller, value )
{
	local button = "reload"
	self.s.buttonState[ button ] = false
	self.Signal( self.s.buttonSignalUnpressed[ button ] )
}

function PressedUseAndReload( self, activator, caller, value )
{
	local button = "useandreload"
	self.s.buttonState[ button ] = true
	self.Signal( self.s.buttonSignalPressed[ button ] )
}
function UnpressedUseAndReload( self, activator, caller, value )
{
	local button = "useandreload"
	self.s.buttonState[ button ] = false
	self.Signal( self.s.buttonSignalUnpressed[ button ] )
}

function PressedSpeed( self, activator, caller, value )
{
	local button = "sprint"
	self.s.buttonState[ button ] = true
	self.Signal( self.s.buttonSignalPressed[ button ] )
}
function UnpressedSpeed( self, activator, caller, value )
{
	local button = "sprint"
	self.s.buttonState[ button ] = false
	self.Signal( self.s.buttonSignalUnpressed[ button ] )
}

function PressedADS( self, activator, caller, value )
{
	local button = "ads"
	self.s.buttonState[ button ] = true
	self.Signal( self.s.buttonSignalPressed[ button ] )
}
function UnpressedADS( self, activator, caller, value )
{
	local button = "ads"
	self.s.buttonState[ button ] = false
	self.Signal( self.s.buttonSignalUnpressed[ button ] )
}

function PressedDuck( self, activator, caller, value )
{
	local button = "crouch"
	self.s.buttonState[ button ] = true
	self.Signal( self.s.buttonSignalPressed[ button ] )
}
function UnpressedDuck( self, activator, caller, value )
{
	local button = "crouch"
	self.s.buttonState[ button ] = false
	self.Signal( self.s.buttonSignalUnpressed[ button ] )
}

function PressedWeaponCycle( self, activator, caller, value )
{
	local button = "changeweapon"
	self.s.buttonState[ button ] = true
	self.Signal( self.s.buttonSignalPressed[ button ] )
}
function UnpressedWeaponCycle( self, activator, caller, value )
{
	local button = "changeweapon"
	self.s.buttonState[ button ] = false
	self.Signal( self.s.buttonSignalUnpressed[ button ] )
}

function PressedPauseMenu( self, activator, caller, value )
{
	local button = "pause"
	self.s.buttonState[ button ] = true
	self.Signal( self.s.buttonSignalPressed[ button ] )
}
function UnpressedPauseMenu( self, activator, caller, value )
{
	local button = "pause"
	self.s.buttonState[ button ] = false
	self.Signal( self.s.buttonSignalUnpressed[ button ] )
}

function PressedFireteam1( self, activator, caller, value )
{
	local button = "dpad_up"
	self.s.buttonState[ button ] = true
	self.Signal( self.s.buttonSignalPressed[ button ] )
}
function UnpressedFireteam1( self, activator, caller, value )
{
	local button = "dpad_up"
	self.s.buttonState[ button ] = false
	self.Signal( self.s.buttonSignalUnpressed[ button ] )
}

function PressedFireteam2( self, activator, caller, value )
{
	local button = "dpad_down"
	self.s.buttonState[ button ] = true
	self.Signal( self.s.buttonSignalPressed[ button ] )
}
function UnpressedFireteam2( self, activator, caller, value )
{
	local button = "dpad_down"
	self.s.buttonState[ button ] = false
	self.Signal( self.s.buttonSignalUnpressed[ button ] )
}

function PressedFireteam3( self, activator, caller, value )
{
	local button = "dpad_left"
	self.s.buttonState[ button ] = true
	self.Signal( self.s.buttonSignalPressed[ button ] )
}
function UnpressedFireteam3( self, activator, caller, value )
{
	local button = "dpad_left"
	self.s.buttonState[ button ] = false
	self.Signal( self.s.buttonSignalUnpressed[ button ] )
}

function PressedFireteam4( self, activator, caller, value )
{
	local button = "dpad_right"
	self.s.buttonState[ button ] = true
	self.Signal( self.s.buttonSignalPressed[ button ] )
}
function UnpressedFireteam4( self, activator, caller, value )
{
	local button = "dpad_right"
	self.s.buttonState[ button ] = false
	self.Signal( self.s.buttonSignalUnpressed[ button ] )
}







