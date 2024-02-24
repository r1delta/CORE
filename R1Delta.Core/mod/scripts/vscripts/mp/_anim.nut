function main()
{
	Globalize( CreateViewModel )

	Globalize( FirstPersonSequence )
	Globalize( GetAnim )
	Globalize( HasAnim )
	Globalize( SetAnim )
	Globalize( AddGlobalAnimEvent )
	Globalize( AddAnimEvent )
	Globalize( DeleteAnimEvent )
	Globalize( PlayAnimTeleport )
	Globalize( PlayViewAnim )
	Globalize( ViewModelResetView )
	Globalize( GetAnimStartInfo )
	Globalize( PlayAnimGravityClientSyncing )
	Globalize( HasAnimEvent )

	Globalize( PlayAnim )
	Globalize( PlayAnimGravity )
	Globalize( PlayAnimRunGravity )
	Globalize( PlayAnimRun )
	Globalize( RunToAnimStart )
	Globalize( RunToAnimStartForced )

	Globalize( AddSignalAnimEvent )

	RegisterSignal( "NewViewAnim" )
	RegisterSignal( "NewFirstPersonSequence" )
	RegisterSignal( "ScriptAnimStop" )
	RegisterSignal( "AnimEventKill" )

	level.globalServerAnimEvents <- {}

	AddGlobalAnimEvent( "enable_weapon",
		function( guy )
		{
			if ( guy.IsPlayer() )
			{
				guy.EnableWeapon()
				guy.EnableWeaponViewModel()
			}
			else
				printt( "Warning: Tried to enable weapon on non player: " + guy )
		}
	)

	AddGlobalAnimEvent( "disable_weapon",
		function( guy )
		{
			if ( guy.IsPlayer() )
			{
				guy.disable_weapon()
			}
			else
				printt( "Warning: Tried to disable weapon on non player: " + guy )
		}
	)

	AddGlobalAnimEvent( "clear_parent",
		function( guy )
		{
			guy.ClearParent()
		}
	)

	AddGlobalAnimEvent( "hide",
		function( guy )
		{
			guy.Hide()
		}
	)

	AddGlobalAnimEvent( "show",
		function( guy )
		{
			guy.Show()
		}
	)

	AddGlobalAnimEvent( "RecordOrigin",
		function( actor )
		{
			if ( !actor.IsPlayer() )
				return
			if ( !( "recordedOrigin" in actor.s ) )
				actor.s.recordedOrigin <- []

			local record = {}
			record.origin <- actor.GetOrigin()
			record.time <- Time()

			actor.s.recordedOrigin.append( record )
		}
	)

	AddGlobalAnimEvent( "ShowFPSProxy",
		function( player )
		{
			if ( !player.IsPlayer() )
				return
			local viewmodel = player.GetFirstPersonProxy()
			viewmodel.Show()
		}
	)


	AddGlobalAnimEvent( "SetVelocity",
		function( actor )
		{
			if ( !actor.IsPlayer() )
				return
			local record = null

			if ( ( "recordedOrigin" in actor.s ) && actor.s.recordedOrigin.len() )
				record = actor.s.recordedOrigin[ actor.s.recordedOrigin.len() - 1 ]

			Assert( record, "anim had AE_SV_VSCRIPT_CALLBACK: SetVelocity, but no AE_SV_VSCRIPT_CALLBACK:RecordOrigin" )

			local vector 		= actor.GetOrigin() - record.origin
			local distance 		= Distance( actor.GetOrigin(), record.origin )
			local time			= Time() - record.time
			local speed 		= distance / time

			vector.Normalize()
			actor.SetVelocity( vector * speed )
		}
	)


	AddGlobalAnimEvent( "stance_kneel",
		function( guy )
		{
			Assert( guy.IsTitan() )
			Assert( guy.IsNPC() )
			SetStanceKneel( guy.GetTitanSoul() )
		}
	)

	AddGlobalAnimEvent( "stance_kneeling",
		function( guy )
		{
			Assert( guy.IsTitan() )
			Assert( guy.IsNPC() )
			SetStanceKneeling( guy.GetTitanSoul() )
		}
	)

	AddGlobalAnimEvent( "stance_stand",
		function( guy )
		{
			Assert( guy.IsTitan() )
			Assert( guy.IsNPC() )
			SetStanceStand( guy.GetTitanSoul() )
		}
	)

	AddGlobalAnimEvent( "stance_standing",
		function( guy )
		{
			Assert( guy.IsTitan() )
			Assert( guy.IsNPC() )
			SetStanceStanding( guy.GetTitanSoul() )
		}
	)

	AddGlobalAnimEvent( "worldsound",
		function( guy, msg )
		{
			local tokens = split( msg, " " )
			local sound = tokens[0]
			local origin
			if ( tokens.len() == 1 )
			{
				origin = guy.GetOrigin()
			}
			else
			{
				local tag = tokens[1]
				local index = guy.LookupAttachment( tag )
				origin = guy.GetAttachmentOrigin( index )
			}

			EmitSoundAtPosition( origin, sound )
		}
	)

	AddGlobalAnimEvent( "enable_planting",
		function( guy )
		{
			if ( guy.IsNPC() || guy.IsPlayer() )
				guy.Anim_EnablePlanting()
			else
				printt( "Warning: Tried to enable planting on " + guy )
		}
	)

	AddGlobalAnimEvent( "vdu_close",
		function( guy )
		{
			VDU_Off()
		}
	)


	AddGlobalAnimEvent( "signal",
		function( guy, msg )
		{
			guy.Signal( msg )
		}
	)

	AddGlobalAnimEvent( "flagset",
		function( guy, msg )
		{
			printl( "FLAG SET " + msg )
			FlagSet( msg )
		}
	)

	AddGlobalAnimEvent( "kill",
		function( guy )
		{
			if ( IsAlive( guy ) )
			{
				Signal( guy, "AnimEventKill" )
				guy.TakeDamage( guy.GetMaxHealth() + 1, null, null, { damageSourceId=eDamageSourceId.suicide } )
				guy.BecomeRagdoll( Vector( 0, 0, 0 ) )
			}
		}
	)

}


function CreateViewModel( player )
{
	if ( "viewmodel" in player.s )
		return

	local viewmodel = CreateEntity( "prop_dynamic" )
	viewmodel.kv.model = DEFAULT_VIEW_MODEL
	viewmodel.kv.fadedist = -1
	viewmodel.kv.rendercolor = "255 255 255"
	viewmodel.kv.renderamt = 255
	viewmodel.kv.solid = 0 //not solid
	viewmodel.kv.MinAnimTime = 5
	viewmodel.kv.MaxAnimTime = 10
	viewmodel.kv.VisibilityFlags = 1 // ONLY VISIBLE TO PLAYER
	DispatchSpawn( viewmodel, false )

	viewmodel.Anim_DisableAnimDelta()
	viewmodel.SetOrigin( player.GetOrigin() )
	viewmodel.SetOwner( player )
	viewmodel.SetVelocity( Vector( 0, 0, 0 ) )
	viewmodel.Anim_PlayWithOriginOnEntity( "ptpov_preanim", player, "", 0 )
	viewmodel.Hide()
	viewmodel.DisableDraw()

	player.s.viewmodel <- viewmodel
}

function GetAnim( guy, animation )
{
	if ( !( "anims" in guy.s ) )
		return animation

	if ( !( animation in guy.s.anims ) )
		return animation

	return guy.s.anims[ animation ]
}

function HasAnim( guy, animation )
{
	if ( !( "anims" in guy.s ) )
		return false

	return animation in guy.s.anims
}

function SetAnim( guy, name, animation )
{
	if ( !( "anims" in guy.s ) )
		guy.s.anims <- {}

	Assert( !( name in guy.s.anims ), guy + " already has set anim " + name )

	guy.s.anims[ name ] <- animation
}

function GetAnimStartInfo( ent, animAlias, animref )
{
	local animData = GetAnim( ent, animAlias )
	local animStartInfo = ent.Anim_GetStartForRefPoint( animData, animref.GetOrigin(), animref.GetAngles() )

	return animStartInfo
}


function GetRefPosition( reference )
{
	Assert( reference.HasKey( "model" ) && reference.kv.model != "", "Tried to play an anim relative to " + reference + " but it has no model/ref attachment." )

	local position = {}
	local attach_id
	attach_id = reference.LookupAttachment( "REF" )

	if ( attach_id )
	{
		position.origin <- reference.GetAttachmentOrigin( attach_id )
		position.angles <- reference.GetAttachmentAngles( attach_id )
	}

	return position
}

// play the anim
function __PlayAnim( guy, animation_name, reference = null, optionalTag = null, blendTime = DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME )
{
	Assert( IsValid_ThisFrame( guy ), "Invalid ent " + guy + " sent to PlayAnim" )
	local animation = GetAnim( guy, animation_name )

	guy.SetNextThinkNow()
	if ( guy.IsNPC() )
	{
		guy.EndSignal( "OnDeath" )
		Assert( IsAlive( guy ), "Guy " + guy + " tried to play an anim, but it is not alive." )
	}

	if ( reference )
	{
		if ( reference == guy )
		{
			local position = GetRefPosition( reference )
			local origin = position.origin
			local angles = position.angles

			if ( guy.IsNPC() )
				guy.Anim_ScriptedPlayWithRefPoint( animation, origin, angles, blendTime )
			else
				guy.Anim_PlayWithRefPoint( animation, origin, angles, blendTime )

			return
		}

		if ( optionalTag )
		{
			if ( typeof( reference ) == "Vector" )
			{
				Assert( typeof( optionalTag ) == "Vector", "Expected angles but got " + optionalTag )
				if ( guy.IsNPC() )
					guy.Anim_ScriptedPlayWithRefPoint( animation, reference, optionalTag, blendTime )
				else
					guy.Anim_PlayWithRefPoint( animation, reference, optionalTag, blendTime )
				return
			}

			Assert( typeof( optionalTag == "string" ), "Passed invalid optional tag " + optionalTag )

			if ( guy.GetParent() == reference )
			{
				if ( guy.IsNPC() )
					guy.Anim_ScriptedPlay( animation )
				else
					guy.Anim_Play( animation )
			}
			else
			{
				local attachIndex = reference.LookupAttachment( optionalTag )
				local origin = reference.GetAttachmentOrigin( attachIndex )
				local angles = reference.GetAttachmentAngles( attachIndex )
				if ( guy.IsNPC() )
				{
					//local origin = reference.GetOrigin()
					//local angles = reference.GetAngles()
					guy.Anim_ScriptedPlayWithRefPoint( animation, origin, angles, blendTime )
				}
				else
				{
					//local animStartPos = guy.Anim_GetStartForRefEntity( animation, reference, optionalTag )
					//local origin = animStartPos.origin
					//local angles = animStartPos.angles
					guy.Anim_PlayWithRefPoint( animation, origin, angles, blendTime )
				}
			}
			return
		}
	}
	else
	{
		Assert( optionalTag == null, "Reference was null, but optionalTag was not. Did you mean to set the tag?" )
	}

	if ( reference != null && guy.GetParent() == reference )
	{
		if ( guy.IsNPC() )
			guy.Anim_ScriptedPlay( animation )
		else
			guy.Anim_Play( animation )

		return
	}

    if ( !reference )
	    reference = guy

    local origin = reference.GetOrigin()
    local angles = reference.GetAngles()

    if ( guy.IsNPC() )
	    guy.Anim_ScriptedPlayWithRefPoint( animation, origin, angles, blendTime )
    else
	    guy.Anim_PlayWithRefPoint( animation, origin, angles, blendTime )

}

function TeleportToAnimStart( guy, animation_name, reference, optionalTag = null )
{
	Assert( reference, "NO reference" )
	local animation = GetAnim( guy, animation_name )
	local animStartPos

	if ( optionalTag )
	{
		if ( typeof( reference ) == "Vector" )
		{
			Assert( typeof( optionalTag ) == "Vector", "Expected angles but got " + optionalTag )
			animStartPos = guy.Anim_GetStartForRefPoint( animation, reference, optionalTag )
		}
		else
		{
			animStartPos = guy.Anim_GetStartForRefEntity( animation, reference, optionalTag )
		}
	}
	else
	{
		//printt( "Reference is " + reference )
		//printt( "guy is " + guy )
		//printt( "animation is " + animation )
		local origin = reference.GetOrigin()
		local angles = reference.GetAngles()
		animStartPos = guy.Anim_GetStartForRefPoint( animation, origin, angles )
	}
	Assert( animStartPos, "No animStartPos for " + animation + " on " + guy )

	// hack! shouldn't need to do this
	ClampToWorldspace( animStartPos.origin )

	if ( guy.GetParent() )
	{
		guy.SetAbsOrigin( animStartPos.origin )
		guy.SetAbsAngles( animStartPos.angles )
	}
	else
	{
		guy.SetOrigin( animStartPos.origin )
		guy.SetAngles( animStartPos.angles )
	}
}

// run to the place to start the anim, then play it
function RunToAnimStart( guy, animation_name, reference = null, optionalTag = null )
{
	Assert( IsAlive( guy ) )
	guy.Anim_Stop() // in case we were doing an anim already
	guy.EndSignal( "OnDeath" )

	local allowFlee = guy.GetAllowFlee()
	local allowHandSignal = guy.GetAllowHandSignals()

	guy.AllowFlee( false )
	guy.AllowHandSignals( false )

	local animation = GetAnim( guy, animation_name )
	local animStartPos

	if ( optionalTag )
	{
		// this command doesnt exist yet
		animStartPos = guy.Anim_GetStartForRefEntity( animation, reference, optionalTag )
	}
	else
	{
		local origin = reference.GetOrigin()
		local angles = reference.GetAngles()
		animStartPos = guy.Anim_GetStartForRefPoint( animation, origin, angles )
	}

	guy.AssaultPointToAnim( animStartPos.origin, animation, 4 )
	guy.WaitSignal( "OnFinishedAssault" )

	guy.AllowFlee( allowFlee )
	guy.AllowHandSignals( allowHandSignal )

	local dist = Distance( animStartPos.origin, guy.GetOrigin() )
	if ( dist > 8 )
	{
		//DebugDrawLine( animStartPos.origin, guy.GetOrigin(), 255, 150, 0, true, 60 )
		printt( guy, " was ", dist, " units away from where he wanted to end his scripted sequence" )
	}
//	printt( guy + " finished assault at dist ", Distance( animStartPos.origin, guy.GetOrigin() ) )
//	Assert( Distance( animStartPos.origin, guy.GetOrigin() ) < 32, guy + " finished assault but was " + ( Distance( animStartPos.origin, guy.GetOrigin() ) ) + " away from where he should have ended up." )
}


///////////////////////////////////////////////////////////////////
// Regular RunToAnimStart will not always raise the "OnFinishedAssault" signal -> consider switching to this
function RunToAnimStartForced( guy, animation_name, reference = null, optionalTag = null )
{
	Assert( IsAlive( guy ) )
	guy.Anim_Stop() // in case we were doing an anim already
	guy.EndSignal( "OnDeath" )

	guy.DisableArrivalOnce( true )

	local allowFlee = guy.GetAllowFlee()
	local allowHandSignal = guy.GetAllowHandSignals()

	guy.AllowFlee( false )
	guy.AllowHandSignals( false )

	local animation = GetAnim( guy, animation_name )
	local animStartPos

	if ( optionalTag )
	{
		// this command doesnt exist yet
		animStartPos = guy.Anim_GetStartForRefEntity( animation, reference, optionalTag )
	}
	else
	{
		local origin = reference.GetOrigin()
		local angles = reference.GetAngles()
		animStartPos = guy.Anim_GetStartForRefPoint( animation, origin, angles )
	}

	local assaultEnt = CreateStrictAssaultEnt( animStartPos.origin )

	OnThreadEnd(
		function() : ( assaultEnt )
		{
			assaultEnt.Kill()
		}
	)

	guy.AssaultPointEnt( assaultEnt )
	//thread DebugAssaultEnt( guy, assaultEnt )
	guy.WaitSignal( "OnFinishedAssault" )

	guy.DisableArrivalOnce( false )

	guy.AllowFlee( allowFlee )
	guy.AllowHandSignals( allowHandSignal )
}




function PlayViewAnim( player, anim, blendTime = DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME )
{
	waitthread __PlayViewAnim( player, anim )
}

function __PlayViewAnim( player, anim )
{
	Assert( IsAlive( player ), player + " ain't alive." )

	local viewmodel = player.GetFirstPersonProxy()

	if ( !IsValid( viewmodel ) ) //JFS: Defensive fix for player not having view models sometimes
		return

	if ( !EntHasModelSet(viewmodel) )
		return

	viewmodel.Signal( "NewViewAnim" )
	viewmodel.EndSignal( "NewViewAnim" )
	if ( IsMultiplayer() )
	{
		player.EndSignal( "OnDeath" )
		player.EndSignal( "Disconnected" )
	}

	viewmodel.EnableDraw()
//	viewmodel.Show()
//	player.SetViewOffsetEntity( viewmodel )
	player.SetAnimViewEntity( viewmodel )

	viewmodel.SetVelocity( Vector( 0, 0, 0 ) )
	viewmodel.Anim_PlayWithOriginOnEntity( anim, player, "", 0.0 )
	viewmodel.Anim_DisableAnimDelta()
	viewmodel.SetNextThinkNow() // everybody animate together

	delaythread( 0.1 ) ShowEnt( viewmodel )

	viewmodel.WaittillAnimDone()

	// hack: This should all go away, but satchel still uses it in MP.
	thread ViewModelResetView( player )
}

function ViewModelResetView( player )
{
	if ( !IsValid_ThisFrame( player ) )
		return

	player.EndSignal( "OnDeath" )
	if ( IsMultiplayer() )
		player.EndSignal( "Disconnected" )

	local viewmodel
	if ( "viewmodel" in player.s && IsValid( player.s.viewmodel ) )
		viewmodel = player.s.viewmodel
	else
		viewmodel = player.GetFirstPersonProxy()
	viewmodel.EndSignal( "NewViewAnim" )

	wait 0
	viewmodel.SetVelocity( Vector( 0, 0, 0 ) )

	if ( IsValid( viewmodel ) && EntHasModelSet(viewmodel) ) //JFS: Defensive fix for player not having view models sometimes
	{
		if ( viewmodel.Anim_HasSequence( "ptpov_postanim" ) )
			viewmodel.Anim_PlayWithOriginOnEntity( "ptpov_postanim", player, "", 0 )
	}

	wait 0.5 // links up with fadeout time on ptpov_postanim
	//player.ClearViewOffsetEntity()
	player.ClearAnimViewEntity()

	viewmodel.DisableDraw()
	//wait 0.4
}

function ShowEnt( viewmodel )
{
	if ( IsValid_ThisFrame( viewmodel ) )
		viewmodel.Show()
}



// anim teleport
function PlayAnimTeleport( guy, animation_name, reference = null, optionalTag = null, initialTime = -1.0 )
{
	if ( type( guy ) == "array" || type( guy ) == "table" )
	{
		Assert( reference, "NO reference" )
		local firstEnt = null
		foreach ( ent in guy )
		{
			if ( !firstEnt )
				firstEnt = ent

			TeleportToAnimStart( ent, animation_name, reference, optionalTag )
			__PlayAnim( ent, animation_name, reference, optionalTag, 0 )
			if ( initialTime > 0.0 )
				guy.Anim_SetInitialTime( initialTime )
		}

		firstEnt.WaittillAnimDone()
	}
	else
	{
		if ( !reference )
			reference = guy

		TeleportToAnimStart( guy, animation_name, reference, optionalTag )
		__PlayAnim( guy, animation_name, reference, optionalTag, 0 )
		if ( initialTime > 0.0 )
			guy.Anim_SetInitialTime( initialTime )
		guy.WaittillAnimDone()
	}
}

// play the anim
function PlayAnim( guy, animation_name, reference = null, optionalTag = null, blendTime = DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME, initialTime = -1.0 )
{
	if ( type( guy ) == "array" )
	{
		foreach ( ent in guy )
		{
			__PlayAnim( ent, animation_name, reference, optionalTag, blendTime )
			if ( initialTime > 0.0 )
				guy.Anim_SetInitialTime( initialTime )
		}

		guy[0].WaittillAnimDone()
	}
	else
	{
		__PlayAnim( guy, animation_name, reference, optionalTag, blendTime )
		if ( initialTime > 0.0 )
			guy.Anim_SetInitialTime( initialTime )
		guy.WaittillAnimDone()
	}
}

// play the anim
function PlayAnimRun( guy, animation_name, reference = null, optionalTag = null, blendTime = DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME  )
{
	RunToAnimStart( guy, animation_name, reference, optionalTag )

	__PlayAnim( guy, animation_name, reference, optionalTag, blendTime )
	guy.WaittillAnimDone()
}

function PlayAnimGravityClientSyncing( guy, animation_name, reference = null, optionalTag = null, blendTime = DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME  )
{
	__PlayAnim( guy, animation_name, reference, optionalTag, blendTime )
	guy.Anim_EnablePlanting()
	guy.WaittillAnimDone()
}

function PlayAnimGravity( guy, animation_name, reference = null, optionalTag = null, blendTime = DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME  )
{
	__PlayAnim( guy, animation_name, reference, optionalTag, blendTime )
	guy.Anim_EnablePlanting()
	guy.WaittillAnimDone()
}

function PlayAnimRunGravity( guy, animation_name, reference = null, optionalTag = null, blendTime = DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME )
{
	RunToAnimStart( guy, animation_name, reference, optionalTag )
	__PlayAnim( guy, animation_name, reference, optionalTag, blendTime )
	guy.Anim_EnablePlanting()
	guy.WaittillAnimDone()
}


// when this guy animates and hits an AE_SV_VSCRIPT_CALLBACK event, he will
// call the function registered to the given name

function AddGlobalAnimEvent( name, func )
{
	Assert( !( name in level.globalServerAnimEvents ), "Already created global anim event " + name )
	level.globalServerAnimEvents[ name ] <- func
}

function HasAnimEvent( entity, eventName )
{
	if ( !( "serverAnimEvents" in entity.s ) )
		return false
	return ( eventName in entity.s.serverAnimEvents )
}

function AddSignalAnimEvent( entity, eventName )
{
	RegisterSignal( eventName )
	AddAnimEvent( entity, eventName, _SignalAnimEvent, eventName )
}

function _SignalAnimEvent( entity, signalName )
{
	entity.Signal( signalName )
}

// when this guy animates and hits an AE_SV_VSCRIPT_CALLBACK event, he will
// call the function registered to the given name
function AddAnimEvent( guy, name, func, optionalVar = null )
{
	if ( !( "serverAnimEvents" in guy.s ) )
	{
		guy.s.serverAnimEvents <- {}
		guy.s.serverAnimEvents_optionalVars <- {}
	}
	else
	{
		Assert( !( name in guy.s.serverAnimEvents ), "Already created anim event " + name )
	}

	guy.s.serverAnimEvents[ name ] <- func

	if ( optionalVar != null )
	{
		Assert( !( name in guy.s.serverAnimEvents_optionalVars ), "Already created anim optional var for " + name )
		guy.s.serverAnimEvents_optionalVars[ name ] <- optionalVar
	}
}

function DeleteAnimEvent( guy, name, func )
{
	Assert( name in guy.s.serverAnimEvents, "Does not have anim event " + name )
	local oldName = FunctionToString( guy.s.serverAnimEvents[ name ] )
	local newName = FunctionToString( func )
	Assert( oldName == newName, "Anim event " + name + " was not " + oldName )

	if ( name in guy.s.serverAnimEvents_optionalVars )
	{
		delete guy.s.serverAnimEvents_optionalVars[ name ]
	}

	delete guy.s.serverAnimEvents[ name ]
}

function CalcSequenceBlendTime( sequence, player, ent = null )
{
	if ( sequence.blendTime != null )
		return

	sequence.blendTime = 0
	if ( ent && sequence.thirdPersonAnim )
	{
		local start
		if ( sequence.attachment )
		{
			start = player.Anim_GetStartForRefEntity( sequence.thirdPersonAnim, ent, sequence.attachment )
		}
		else
		{
			start = {}
			start.origin <- ent.GetOrigin()
			start.angles <- ent.GetAngles()
		}

		if ( sequence.teleport )
		{
			player.SetAbsOrigin( start.origin )
			player.SetAbsAngles( start.angles )
		}
		else
		{
			local dist = Distance( player.GetOrigin(), start.origin )
			sequence.blendTime = GraphCapped( dist, 0, 350, 0.25, 0.9 )
		}
	}
}

function FirstPersonSequence( sequence, player, ent = null )
{
	player.Signal( "NewFirstPersonSequence" )
	player.EndSignal( "NewFirstPersonSequence" )
	player.EndSignal( "ScriptAnimStop" )


	player.SetVelocity( Vector(0,0,0) ) // fix this

	local viewmodel
	if ( sequence.firstPersonAnim )
	{
		viewmodel = player.GetFirstPersonProxy()
		if ( IsValid( viewmodel ) && EntHasModelSet( viewmodel ) ) //JFS: Defensive fix for player not having view models sometimes
		{
			viewmodel.Show()

			if ( sequence.renderWithViewModels )
				viewmodel.RenderWithViewModels( true )
			else
				viewmodel.RenderWithViewModels( false )

			player.SetAnimViewEntity( viewmodel )
			viewmodel.SetNextThinkNow()

			printtodiag( Time() + ": FirstPersonSequence: Playing 1p anim \'" + sequence.firstPersonAnim + "\' on " + player + " \n" )
			viewmodel.Anim_Play( sequence.firstPersonAnim )

			if ( sequence.setInitialTime )
				viewmodel.Anim_SetInitialTime( sequence.setInitialTime )

			if ( sequence.hideProxy )
				viewmodel.Hide()

			if ( sequence.viewConeFunction )
				sequence.viewConeFunction( player )
		}
	}

	local soul

	if ( ent )
	{
		// the entity we are animating relative to may change during the animation
		if ( IsSoul( ent ) )
		{
			soul = ent
			ent = soul.GetTitan()
			if ( !IsValid( ent ) )
				return
		}
		else if ( HasSoul( ent ) )
		{
			soul = ent.GetTitanSoul()
		}
	}

	CalcSequenceBlendTime( sequence, player, ent )

	if ( player.IsPlayer() )
	{
		if ( sequence.teleport )
		{
			player.SetAnimViewEntityLerpInTime( 0.0 )
			player.PlayerCone_SetLerpTime( 0.0 )
		}
		else
		{
			if ( sequence.noViewLerp )
				player.SetAnimViewEntityLerpInTime( 0.0 )
			else
				player.SetAnimViewEntityLerpInTime( 0.4 )
			player.PlayerCone_SetLerpTime( 0.5 )
		}

		player.SetAnimViewEntityLerpOutTime( 0.4 )
	}

	if ( ent && !sequence.noParent )
	{
		local optionalTag
		if ( sequence.attachment )
		{
			optionalTag = sequence.attachment
		}
		else
		{
			optionalTag = ""
		}

		if ( player.GetParent() != ent )
		{
			printtodiag( "FirstPersonSequence: Parenting " + player + " to " + ent + " \n" )

			if ( player.IsPlayer() )
			{
				printtodiag( "FirstPersonSequence: " + player + " is a player with name: " + player.GetPlayerName() + "\n" )
			}

			if ( ent.IsPlayer() )
			{
				printtodiag( "FirstPersonSequence: " + ent + " is a player with name: " + ent.GetPlayerName() + "\n" )
			}

			// you could be parenting from one tag to another but we don't do
			// that anywhere currently, and if we want to do it we can do some
			// special stuff
			player.SetParent( ent, optionalTag, false, sequence.blendTime )
		}
	}

	if ( sequence.relativeAnim )
	{
		if ( sequence.teleport )
		{
			thread PlayAnimGravityClientSyncing( ent, sequence.relativeAnim, null, null, 0.0 )
		}
		else
		{
			thread PlayAnimGravityClientSyncing( ent, sequence.relativeAnim )
		}

		if ( sequence.setInitialTime )
			ent.Anim_SetInitialTime( sequence.setInitialTime )
	}

	if ( sequence.thirdPersonAnim )
	{
		if ( ent )
		{
			thread PlayAnim( player, sequence.thirdPersonAnim, ent, sequence.attachment, sequence.blendTime )
		}
		else
		{
			if ( sequence.gravity )
				thread PlayAnimGravityClientSyncing( player, sequence.thirdPersonAnim, sequence.origin, sequence.angles, sequence.blendTime )
			else
				thread PlayAnim( player, sequence.thirdPersonAnim, sequence.origin, sequence.angles, sequence.blendTime )
		}

		if ( sequence.enablePlanting )
			player.Anim_EnablePlanting()

		if ( sequence.viewConeFunction )
			sequence.viewConeFunction( player )

		if ( sequence.setInitialTime )
			player.Anim_SetInitialTime( sequence.setInitialTime )

		if ( sequence.useAnimatedRefAttachment )
			player.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()

		player.WaittillAnimDone()
	}

	if ( sequence.firstPersonAnim && IsValid( viewmodel ) && viewmodel.Anim_IsActive() && !viewmodel.IsSequenceFinished() )
	{
		viewmodel.WaittillAnimDone()
	}

	if ( !IsValid( player ) )
		return

	if ( player.IsPlayer() )
	{
		if ( !IsAlive( player ) )
			return

 		if ( player.IsDisconnected() )
 			return
	}
	else
	if ( player.IsNPC() )
	{
		if ( !IsAlive( player ) )
			return
	}

	// time passed
	if ( soul )
	{
		if ( !IsValid( soul ) )
			return

		ent = soul.GetTitan()
		if ( !IsAlive( ent ) )
			return
	}

	if ( sequence.thirdPersonAnimIdle )
	{
//		thread PlayAnim( player, sequence.thirdPersonAnimIdle, ent, sequence.attachment, 0 )
		if ( ent )
		{
			thread PlayAnim( player, sequence.thirdPersonAnimIdle, ent, sequence.attachment, sequence.blendTime )
		}
		else
		{
			thread PlayAnim( player, sequence.thirdPersonAnimIdle, sequence.origin, sequence.angles, sequence.blendTime )
		}
	}

	if ( sequence.firstPersonAnimIdle )
	{
		viewmodel = player.GetFirstPersonProxy()
		viewmodel.Show()

		if ( IsValid( viewmodel ) && EntHasModelSet( viewmodel ) ) //JFS: Defensive fix for player not having view models sometimes
		{
			if ( sequence.renderWithViewModels )
			viewmodel.RenderWithViewModels( true )
			else
				viewmodel.RenderWithViewModels( false )

			player.SetAnimViewEntity( viewmodel )
			viewmodel.SetNextThinkNow()

			viewmodel.Anim_Play( sequence.firstPersonAnimIdle )
		}
	}

	if ( sequence.thirdPersonAnimIdle && sequence.firstPersonAnimIdle )
	{
		if ( sequence.viewConeFunction )
			sequence.viewConeFunction( player )
	}
}


function FadeToBlackClient( player, fadeTime )
{
	if ( IsValid( player ) )
	{
		ScreenFadeToBlack( player, fadeTime )
	}
}



function ClampPlayerViewCone( player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "Disconnected" )
	player.PlayerCone_SetLerpTime( 0.0 )
}