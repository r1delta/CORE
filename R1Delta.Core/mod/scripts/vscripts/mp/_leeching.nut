// _leeching.nut
// sets up global stuff for leeching

const LEECHABLE_HINT_TEXT = "Hold to Leech"
const LEECHING_HINT_TEXT = "Leeching..."
const LEECHED_3D_TEXT = "[Vektor]"
const PLAYER_LEECH_IN_PROGRESS_SOUND = "NPC_Alyx.PushKeypad1"
const PLAYER_LEECH_SUCCESSFUL_SOUND = "NPC_RocketTurret.LockingBeep"
const LEECH_SUCCESS_STATUS_LIGHT_PARTICLE = "blue_light_large_blink"
const LEECH_SUCCESS_REWARD_XP = 25

const MARVIN_EMOTE_SOUND_HAPPY = "diag_spectre_gs_LeechEnd_01_1"
const MARVIN_EMOTE_SOUND_SAD = "diag_spectre_gs_LeechAborted_01_1"
const MARVIN_EMOTE_SOUND_THINK = "marvin_thinking"
const MARVIN_EMOTE_SOUND_PAIN = "diag_spectre_gs_LeechStart_01_1"






function main()
{
	Globalize( DoLeech )
	Globalize( TryLeechAbortCallback )
	Globalize( StartLeechingProgress )
	Globalize( StopLeechingProgress )
	Globalize( InitLeechable )
	Globalize( GetLeechTargets )
	Globalize( EnableLeeching )
	Globalize( DisableLeeching )
	Globalize( MarvinWeaponsFree )
	Globalize( GetLeechedEnts )
	Globalize( IsLeeched )

	PrecacheParticleSystem( LEECH_SUCCESS_STATUS_LIGHT_PARTICLE )
	RegisterSignal( "OnLeeched" )
	RegisterSignal( "OnStartLeech" )
	RegisterSignal( "OnStopLeeched" )
	RegisterSignal( "EnableLeeching" )

	Assert( !( "_leechable" in getroottable() ), "Leechable objects array already set up!" )
	level._leechtargets <- {}


	// class specific DoLeech funcs live in entities/leechable.nut
	level._leechfuncs <- {}

	/*
	level._leechfuncs.npc_marvin <- {}
	level._leechfuncs.npc_marvin.DoLeech <- Leech_Marvin
	level._leechfuncs.npc_marvin.LeechStart <- LeechStart_Marvin
	level._leechfuncs.npc_marvin.LeechAbort <- LeechAbort_Marvin
	*/

	level._leechfuncs.npc_spectre <- {}
	level._leechfuncs.npc_spectre.DoLeech <- Leech_Spectre
	level._leechfuncs.npc_spectre.LeechStart <- LeechStart_Spectre
	level._leechfuncs.npc_spectre.LeechAbort <- LeechAbort_Spectre

	level._leechfuncs.logic_relay <- {}
	level._leechfuncs.logic_relay.DoLeech <- Leech_LogicRelay
	level._leechfuncs.func_physbox <- {}
	level._leechfuncs.func_physbox.DoLeech <- Leech_FuncPhysbox
}



function GetLeechTargets()
{
	Assert( "_leechtargets" in level )
	return level._leechtargets
}

function InitLeechable( self )
{
	if ( "leechInProgress" in self.s )
		return

	Assert( IsValid_ThisFrame( self ), "Self is no longer valid." )

	Assert( !( "leechInProgress" in self.s ), "Tried to run InitLeechable on " + self + " more than once." )

	self.s.leechInProgress <- false
	self.s.leechStartTime <- -1
	//self.s.leechPointMessage <- null // turning these off

	// NPCs with a player owner (like Marvins called in by the player via drop pods) shouldn't be leechable
	if ( self.IsNPC() )
	{
		if ( self.GetOwnerPlayer() != null )
			return
	}
}

function IsLeeched( self )
{
	// player may not be set yet, entities spawn before player
	if ( !( "player" in level ) )
		return false

	if ( !IsAlive( level.player ) )
		return false

	// just checks level.player currently
	return self in level.player.s.leechedEnts
}

function EnableLeeching( self )
{
	if ( !( "SetUsePrompts" in self.s ) )
	{
		self.SetUsePrompts( "#DEFAULT_HACK_HOLD_PROMPT", "#DEFAULT_HACK_HOLD_PROMPT" )
		self.s.SetUsePrompts <- true
	}

	Leech_SetLeechable( self )
}

function DisableLeeching( self )
{
	if ( !IsValid_ThisFrame( self ) )
		return

	Leech_ClearLeechable( self )
}

function StartLeechingProgress( self, leecher )
{
	self.s.leechInProgress = true
	self.s.leechStartTime = Time()

	TryLeechStartCallback( self, leecher )
}

function StopLeechingProgress( self )
{
	self.s.leechInProgress = false
	self.s.leechStartTime = -1
}

// called when any entity gets leeched
function DoLeech( self, leecher = null )
{
	if ( !IsLeechable( self ) )
	{
		EnableLeeching( self )
	}

	Assert( "s" in self, "Self " + self + " has no .s" )
	if ( !leecher )
		leecher = GetPlayer()

	if ( !IsMultiplayer() )
		DisableLeeching( self )

	// logic_relays get Triggered when the object is leeched
	local results = {}
	results.player <- leecher

	self.Signal( "OnLeeched", results )
	leecher.Signal( "OnLeeched", results )

	//DisableLeeching( self )

	//_EnableLeechedPointMessage()

	if ( leecher.IsPlayer() )
	{
		if ( self.IsNPC() )
			self.SetOwnerPlayer( leecher )

		TableRemoveDeadByKey( leecher.s.leechedEnts )

		leecher.s.leechedEnts[ self ] <- self

		// this will kill a random leeched ent from within the team, exluding the current target.
		if ( level.wifiHackOverflowDies == true )
			ReleaseLeechOverflow( leecher, self )

		if ( self.GetTeam() != leecher.GetTeam() )
		{
			if ( "burnCardLoot" in self.s )
			{
				EntityPickedUpBurnCard( leecher, self )
				delete self.s.burnCardLoot
			}
		}
	}

	if ( self.IsNPC() )
	{
		self.ScriptOnLeeched()
	}

	// call a class specific leeching function for custom behavior
	local targetCN = self.GetClassname()
	if ( targetCN in level._leechfuncs )
	{
		Assert( "DoLeech" in level._leechfuncs[ targetCN ] )

		local functionRef = level._leechfuncs[ targetCN ].DoLeech
		thread functionRef( self, leecher )
	}

	// call an optional level callback
	if ( "OnPlayerLeech" in getroottable() )
		OnPlayerLeech( self, leecher )
}

function GetTeamLeechedEnts( team )
{
	local players = GetPlayerArrayOfTeam( team )
	local totalCount = 0

	local leechedArray = []
	foreach( player in players )
	{
		if ( IsValid( player ) && !player.IsBot() )
			leechedArray.extend( GetLeechedEnts( player ) )
	}

	return leechedArray
}
Globalize( GetTeamLeechedEnts )

function GetLeechedEnts( leecher = null )
{
	if ( !leecher )
		leecher = level.player

	local ents = []

	foreach ( ent in leecher.s.leechedEnts )
	{
		if ( IsAlive( ent ) )
			ents.append( ent )
	}

	return ents
}

function TryLeechStartCallback( self, leecher )
{
	local leechtargetCN = self.GetClassname()
	if ( leechtargetCN in level._leechfuncs )
	{
		if ( "LeechStart" in level._leechfuncs[ leechtargetCN ] )
		{
			local functionRef = level._leechfuncs[ leechtargetCN ].LeechStart
			thread functionRef( self, leecher )
		}
	}
}

function TryLeechAbortCallback( self, leecher )
{
	local leechtargetCN = self.GetClassname()
	if ( leechtargetCN in level._leechfuncs )
	{
		if ( "LeechAbort" in level._leechfuncs[ leechtargetCN ] )
		{
			local functionRef = level._leechfuncs[ leechtargetCN ].LeechAbort
			thread functionRef( self, leecher )
		}
	}
}


// --- CLASS SPECIFIC LEECH FUNCTIONS ---
function Leech_LogicRelay( self, leecher )
{
	Assert( self.GetClassname() == "logic_relay" )

	// logic_relays get Triggered when the object is leeched
	self.Fire( "Trigger" )
}

function Leech_FuncPhysbox( self, leecher )
{
	Assert( self.GetClassname() == "func_physbox" )

	// logic_relays get Triggered when the object is leeched
	self.Fire( "FireUser1" )
}


function MarvinWeaponsFree( self )
{
	Assert( IsAlive( self ), self + " is dead, not alive!" )

	// already have a weapon
	if ( !self.GetActiveWeapon() )
		return

	self.EndSignal( "OnStopLeeched" )
	self.EndSignal( "OnDeath" )
	self.EndSignal( "OnTakeWeapon" )

	OnThreadEnd(
		function () : ( self )
		{
			if ( !IsAlive( self ) )
				return
		}
	)

	// its combat, time to get the hate on
	self.Fire( "UnholsterWeapon" )

	WaitForever()
}


function LeechStart_Marvin( self, leecher )
{
	//self.SetSkin( 4 )
	EmitSoundOnEntity( self, MARVIN_EMOTE_SOUND_PAIN )
}

function LeechAbort_Marvin( self, leecher )
{
	//self.SetSkin( 1 )  // happy
	EmitSoundOnEntity( self, MARVIN_EMOTE_SOUND_SAD )
}


// Spectre leech

function Leech_Spectre( self, leecher )
{
	thread Leech_SpectreThread( self, leecher )
}

function Leech_SpectreThread( self, leecher )
{
	Assert( self.GetClassname() == "npc_spectre" )

	self.EndSignal( "OnDestroy" )
	self.EndSignal( "OnDeath" )
	self.EndSignal( "OnLeeched" )

	EmitSoundOnEntity( self, MARVIN_EMOTE_SOUND_HAPPY )

	Assert( leecher.IsPlayer() )

	leecher.EndSignal( "Disconnected" )
	leecher.EndSignal( "OnDestroy" )

	AddPlayerScore( leecher, "LeechSpectre" )

	local timerCredit = GetCurrentPlaylistVarFloat( "spectre_kill_credit", 0.5 )
	if ( PlayerHasServerFlag( leecher, SFLAG_HUNTER_SPECTRE ) )
		timerCredit *= 2.5
	DecrementBuildCondition( leecher, timerCredit )

	// follow leecher
	local squadName = GetPlayerSpectreSquadName( leecher )

	self.Signal( "StopHardpointBehavior" )
	self.DisableBehavior( "Assault" )
	self.SetTeam( leecher.GetTeam() )

	if ( "eye_glow" in self.s && IsValid( self.s.eye_glow ) )
		self.s.eye_glow.SetTeam( leecher.GetTeam() )

	if ( GetNPCSquadSize( squadName ) )
	{
		printtodiag( "MapName: " +  GetMapName() + "\n" )
		printtodiag( "GameMode: " +  GameRules.GetGameMode() + "\n" )
		printtodiag( "Cinematic: " +  GetCinematicMode() + "\n" )
		printtodiag( "Playlist: " +  GetCurrentPlaylistName() + "\n" )
		printtodiag( "Leecher Team: " + leecher.GetTeam() + "\n" )
		printtodiag( "Leecher Name: " + leecher.GetPlayerName() + "\n" )
		printtodiag( "Spectre Index: " + self.GetEntIndex() + "\n" )

		local squad = GetNPCArrayBySquad( squadName )
		foreach( ent in squad )
		{
			printtodiag( "Spectre in squad Team: " + ent.GetTeam() + " Spectre Index: " + ent.GetEntIndex() + "\n" )
		}
	}

	// disabling follow
	SetSquad( self, squadName )
	self.InitFollowBehavior( leecher, AIF_FIRETEAM )
	self.EnableBehavior( "Follow" )
	self.StayPut( true )

	self.SetShortTitle( "" )
	self.SetBossPlayer( leecher )

	OnThreadEnd(
		function() : ( self, leecher )
		{
			// leecher is still connected so don't kill the spectre
			if ( IsValid( leecher ) && !leecher.IsDisconnected() )
				return

			// leecher is disconnected so kill the spectre
			if ( IsAlive( self ) )
				self.Die()
		}
	)

	if ( GameRules.GetGameMode() == ATTRITION && GetGameState() == eGameState.Playing )
	{
		local scoreVal = GetAttritionScore( leecher, self )

		local event = ScoreEventFromName( "AttritionPoints" )
		local scoreEventInt = event.GetInt()

		Remote.CallFunction_NonReplay( leecher, "ServerCallback_PointSplash", scoreEventInt, null, scoreVal )

		GameScore.AddTeamScore( leecher.GetTeam(), scoreVal )
		leecher.SetAssaultScore( leecher.GetAssaultScore() + scoreVal )
	}

	foreach( callbackInfo in level.onLeechedCustomCallbackFunc )
	{
		callbackInfo.func.acall( [ callbackInfo.scope, self, leecher ] )
	}

	WaitForever()
}

function LeechStart_Spectre( self, leecher )
{
	EmitSoundOnEntity( self, MARVIN_EMOTE_SOUND_PAIN )
}

function LeechAbort_Spectre( self, leecher )
{
	EmitSoundOnEntity( self, MARVIN_EMOTE_SOUND_SAD )
}
// --- END CLASS SPECIFIC LEECH FUNCTIONS ---