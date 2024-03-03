// this script is a bunch of non-interactive stuff that goes down while you are flying in

function main()
{
	Globalize( IntroCityShow )
	file.explosion <- TITAN_EXPLOSION_EFFECT
}

function IntroCityShow()
{
	thread IntroPhantoms()
}

function AddIntroTitan( time, style, weapon, healthFraction, team, origin, yaw, destOrigin = null )
{
	delaythread( time ) SpawnIntroTitan( file.titanCount, style, weapon, healthFraction, team, origin, yaw, destOrigin )
	file.titanCount++
}

function SpawnIntroTitan( debugNum, style, weapon, healthFraction, team, origin, yaw, destOrigin = null )
{
	local angles = Vector(0,yaw,0)
	local titan = CreateNPCTitanFromSettings( "titan_atlas", team, origin, angles )
	titan.GiveWeapon( weapon )
	titan.EndSignal( "OnDeath" )
	local maxHealth = titan.GetMaxHealth()
	titan.SetHealth( maxHealth * healthFraction )

	if ( team == TEAM_IMC )
		titan.SetTitle( "#NPC_EAGLE_SQUADRON" )
	else
		titan.SetTitle( "#NPC_ALPHA_SQUADRON" )

	if ( destOrigin == null )
		destOrigin = origin

	local endTime = Time() + 11
	for ( ;; )
	{
		if ( Time() > endTime )
			break
		titan.AssaultPoint( destOrigin )
		//DebugDrawText( titan.GetOrigin(), "" + debugNum, true, 1.0 )
		//DebugDrawLine( titan.GetOrigin(), origin, 255, 0, 0, true, 1.0 )
		//DebugDrawLine( titan.GetOrigin(), destOrigin, 255, 255, 0, true, 1.0 )
		wait 1.0
	}

	titan.Die()
}

function AddDropship( time, anim, origin, yaw )
{
//	time -= 11.71 // flag timing
	delaythread( time ) DrawDropship( anim, origin, yaw )
}

function DrawDropship( anim, origin, yaw )
{
	local angles = Vector( 0, yaw, 0 )
	local ship = CreatePropDynamic( CROW_MODEL, origin, angles )
	waitthread PlayAnim( ship, anim, origin, angles )
	ship.Kill()
}

function AddExplosion( time, vec )
{
	delaythread( time - 2.0 ) PlayIntroExplosion( time, vec )
}

function PlayIntroExplosion( time, vec )
{
//	DebugDrawText( vec, time + " ", true, 10	 )
	PlayFX( TITAN_EXPLOSION_EFFECT, vec, Vector(0,0,0) )
}

function IntroPhantoms()
{
	local autoStartPhantomNodesNames = []

	// Phantoms
	autoStartPhantomNodesNames.append( { name = "cinematic_mp_node_us298", delay = 5.0 } )
	autoStartPhantomNodesNames.append( { name = "cinematic_mp_node_us306", delay = 5.0 } )
	autoStartPhantomNodesNames.append( { name = "cinematic_mp_node_us320", delay = 5.0 } )
	autoStartPhantomNodesNames.append( { name = "cinematic_mp_node_us332", delay = 5.0 } )
	autoStartPhantomNodesNames.append( { name = "cinematic_mp_node_us342", delay = 5.0 } )
	autoStartPhantomNodesNames.append( { name = "cinematic_mp_node_us349", delay = 5.0 } )
	autoStartPhantomNodesNames.append( { name = "cinematic_mp_node_us350", delay = 5.0 } )
	autoStartPhantomNodesNames.append( { name = "cinematic_mp_node_us357", delay = 5.0 } )
	autoStartPhantomNodesNames.append( { name = "cinematic_mp_node_us369", delay = 5.0 } )
	autoStartPhantomNodesNames.append( { name = "cinematic_mp_node_us384", delay = 5.0 } )
	autoStartPhantomNodesNames.append( { name = "cinematic_mp_node_us715", delay = 5.0 } )

	// Drones
	autoStartPhantomNodesNames.append( { name = "cinematic_mp_node_us386", delay = 25.0 } )
	autoStartPhantomNodesNames.append( { name = "cinematic_mp_node_us440", delay = 25.0 } )

	foreach( data in autoStartPhantomNodesNames )
	{
		local node = GetNodeByUniqueID( data.name )
		Assert( node != null )
		delaythread( data.delay ) NodeDoMoment( node )
	}

	thread PA_Announcements()
}

function PA_Announcements()
{
	local pa_locations = []
	pa_locations.append( Vector( 2153, 282, 683 ) )
	pa_locations.append( Vector( -52, -1617, 923 ) )
	pa_locations.append( Vector( -83, 1228, 858 ) )
	pa_locations.append( Vector( -3267, 450, 692 ) )
	pa_locations.append( Vector( -3176, 3448, 682 ) )
	pa_locations.append( Vector( -957, 3295, 967 ) )
	pa_locations.append( Vector( 375, 2275, 678 ) )

	local pa_aliases = []
	pa_aliases.append( "diag_cmp_angc_imc_psyop_megaphone_117" )	// Barker! MacAllan! We know you're in the city! There is no - way - out! Give yourselves up!
	pa_aliases.append( "diag_cmp_angc_imc_psyop_megaphone_118" )	// MacAllan! We know you have Barker! There is no escape! I repeat, no - escape! Give up while you can!
	pa_aliases.append( "diag_cmp_angc_imc_psyop_megaphone_119" ) 	// Militia forces! Turn in your leaders! They are fugitives from the law! You will be spared prosecution under Article Seven of the Amnesty Convention, IF you provide information leading to their capture and arrest!
	pa_aliases.append( "diag_cmp_angc_imc_psyop_megaphone_120" ) 	// Give it up MacAllan! There is no way out of this! We have Angel City under lockdown! Turn yourself in! We can talk it over, we can make a deal!
	pa_aliases.append( "diag_cmp_angc_imc_psyop_megaphone_121" )	// MacAllan! You might as well surrender now! You think we're gonna let you get offworld with Barker? Don't be a fool, MacAllan, give it up!

	local drone_aliases = []
	drone_aliases.append( "diag_cmp_angc_imc_bgpa1_angelpa_109" )
	drone_aliases.append( "diag_cmp_angc_imc_bgpa1_angelpa_110" )
	drone_aliases.append( "diag_cmp_angc_imc_bgpa1_angelpa_111" )
	drone_aliases.append( "diag_cmp_angc_imc_bgpa1_angelpa_112" )
	drone_aliases.append( "diag_cmp_angc_imc_bgpa1_angelpa_113" )
	drone_aliases.append( "diag_cmp_angc_imc_bgpa1_angelpa_114" )
	drone_aliases.append( "diag_cmp_angc_imc_bgpa1_angelpa_115" )

	wait 40

	// First one is canned, to always play at the same spot at the same timing for the intro sequences
	EmitSoundAtPosition( Vector( 2761, -1398, 821 ), Random( pa_aliases ) )
	EmitSoundAtPosition( Vector( -2427, 2751, 629 ), Random( pa_aliases ) )

	local pa_aliases_remaining
	local drone_aliases_remaining
	local total_aliases = pa_aliases.len() + drone_aliases.len()
	while(1)
	{
		ArrayRandomize( pa_aliases )
		ArrayRandomize( drone_aliases )

		pa_aliases_remaining = pa_aliases.len()
		drone_aliases_remaining = drone_aliases.len()

		//printt( "SHUFFLING PA AND DRONE ALIASES!!!" )

		while(1)
		{
			if ( pa_aliases_remaining <= 0 && drone_aliases_remaining <= 0 )
			{
				//printt( "PLAYED ALL PA AND DRONE ALIASES" )
				break
			}

			Assert( pa_aliases_remaining + drone_aliases_remaining > 0 )
			ArrayRemoveInvalid( level.activeSearchDrones )

			local shouldDoDroneAlias = CoinFlip()
			if ( shouldDoDroneAlias && drone_aliases_remaining > 0 && level.activeSearchDrones.len() > 0 )
			{
				drone_aliases_remaining--
				local alias = drone_aliases[ drone_aliases_remaining ]
				//printt( "PLAYING DRONE ALIAS:", alias )
				local randPlayer = Random( GetPlayerArray() )
				local playerPos = IsValid( randPlayer ) ? randPlayer.GetOrigin() : Vector( -112, 1192, 1091 )
				local drone = GetClosest( level.activeSearchDrones, playerPos )
				EmitSoundOnEntity( drone, alias )
			}
			else if ( pa_aliases_remaining > 0 )
			{
				pa_aliases_remaining--
				local alias = pa_aliases[ pa_aliases_remaining ]
				//printt( "PLAYING PA ALIAS:", alias )
				EmitSoundAtPosition( Random( pa_locations ), alias )
			}
			else
			{
				//printt( "NO PA ALIASES LEFT TO PLAY, AND NO DRONES LEFT. TRYING AGAIN" )
				wait 3.0
			}

			wait RandomFloat( 20.0, 40.0 )
		}
	}
}