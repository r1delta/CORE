const GUNSHIPS			= 0
const BARKER_MODEL = "models/humans/mcor_hero/barker/mcor_hero_barker.mdl"

const SKYBOX 		= "skybox_cam_level"
const SKYBOXSPACE 	= "skybox_cam_intro"
const GUNSHIPWINGMANDISTSQR = 262144

const HORNET_MISSILE_MODEL = "models/weapons/bullets/rocket_missile.mdl"
PrecacheModel( HORNET_MISSILE_MODEL )

const SEARCH_DRONE_MODEL = "models/robots/agp/agp_hemlok_large.mdl"
PrecacheModel( SEARCH_DRONE_MODEL )

const EFFECT_HORNET_MISSILE_TRAIL = "Rocket_Smoke_Large"
PrecacheParticleSystem( EFFECT_HORNET_MISSILE_TRAIL )

const EFFECT_HORNET_MISSILE_FLASH = "wpn_muzzleflash_xo_rocket"
PrecacheParticleSystem( EFFECT_HORNET_MISSILE_FLASH )

const EFFECT_HORNET_MISSILE_EXPLOSION = "P_exp_wall_concrete"
PrecacheParticleSystem( EFFECT_HORNET_MISSILE_EXPLOSION )

const EFFECT_APARTMENT_SIGN_EXPLOSION = "P_exp_apartment_sign"
PrecacheParticleSystem( EFFECT_APARTMENT_SIGN_EXPLOSION )

const HORNET_MISSILE_SFX_LOOP_LEFT = "Weapon_ARL.Projectile"
const HORNET_MISSILE_SFX_LOOP_RIGHT = "AngelCity_Scr_RightRocketFire"
const HORNET_MISSILE_SFX_IMPACT_LEFT = "AngelCity_Scr_LeftRocketExplo"
const HORNET_MISSILE_SFX_IMPACT_RIGHT = "Default.Rocket_Explosion_3P_vs_3P"

const HATCH_MODEL = "models/utilities/utility_hatchround_metal01.mdl"

PrecacheModel( "models/vehicle/space_cluster/birmingham_space_clusterA.mdl" )
PrecacheModel( "models/vehicle/capital_ship_Birmingham/birmingham.mdl" )
PrecacheModel( BARKER_MODEL )

PrecacheModel( SKYBOX_REDEYE )
PrecacheModel( SKYBOX_BIRMINGHAM )
PrecacheModel( HATCH_MODEL )

PrecacheModel( CAPSHIP_BIRM_MODEL )
//PrecacheModel( CAPSHIP_ANNA_MODEL )

PrecacheModel( GRAVES_MODEL )
PrecacheModel( SPYGLASS_MODEL )
PrecacheModel( CASE_MODEL )
PrecacheModel( BISH_MODEL )
PrecacheModel( MAC_MODEL )
PrecacheModel( TEAM_MILITIA_GRUNT_MDL )
PrecacheModel( MARVIN_NO_JIGGLE_MODEL )
PrecacheModel( SARAH_MODEL )
PrecacheModel( LAPTOP_MODEL )
PrecacheModel( HORNET_MODEL )

PrecacheModel( "models/angel_city/vending_machine.mdl" )
PrecacheModel( "models/barriers/metal_parking_post_yell.mdl" )


function main()
{
	IncludeFile( "mp_angel_city_shared" )
	IncludeFile( "mp/mp_angel_city_intro" )
	IncludeFile( "mp/mp_angel_city_megacarrier" )

	if ( reloadingScripts )
		return

	FlagInit( "hatch_closed" )

	thread SearchShipsReplenish()
	if ( !GetCinematicMode() )
	{
		CreateIntroScriptRef()
		InsertHatch()
		FlagSet( "IntroDone" )
		return
	}

	level.debugIntroEnts <- []

	RegisterSignal( "NextCinematicEvent" )

	FlagInit( "IntroGoMilitia" ) //From fracture. Long run should globalize these flags
	FlagInit( "IntroGoIMC" ) //From fracture. Long run should globalize these flags
	FlagInit( "IMC_IntroDone" ) //From fracture. Long run should globalize these flags
	FlagInit( "MILITIA_IntroDone" ) //From fracture. Long run should globalize these flags

	FlagSet( "CinematicIntro" )
	FlagSet( "CinematicOutro" )

	level.levelSpecificChatterFunc = AngelCitySpecificChatter

	FlagInit( "DeletedIntroSpawners" )
	SetCustomIntroLength( 0 )
	AddSpawnFunction( "info_spawnpoint_human_start", AC_StartSpawnThink )

	SetupCinematicMatchProgressAnnouncement()
	GM_AddEndRoundFunc( AngelCityRoundEnd )

	AddSpawnFunction( "player", AngelCityPlayerSpawn )
}

function EntitiesDidLoad()
{
	FlagClear( "AnnounceWinnerEnabled" )

	if ( !IsServer() )
		return

	CreatePropDynamic( "models/angel_city/vending_machine.mdl", Vector( -757.220276, 4437.737305, 220 ), Vector( 0.000000, -12, 0.000000 ), 6 )
	CreatePropDynamic( "models/angel_city/vending_machine.mdl", Vector( -740.444458, 4490.892578, 220 ), Vector( 0.000000, -12, 0.000000 ), 6 )

	CreatePropDynamic( "models/barriers/metal_parking_post_yell.mdl", Vector( -2129.968750, 3787.591309, 200.031250 ), Vector( 0.000000, 0, 0.000000 ), 6 )
	CreatePropDynamic( "models/barriers/metal_parking_post_yell.mdl", Vector( -2121.086914, 3774.336914, 200.031311 ), Vector( 0.000000, 0, 0.000000 ), 6 )



	if ( EvacEnabled() )
	{
		local evacPositions = [ //Vector( 2527.889893, -2865.360107, 753.002991 ),
								Vector( 2446.989990, 809.364014, 576.000000 ),
								Vector( -2776.000000, 1988.000000, 480.000000 )//테스트용
								//Vector( 1253.530029, -554.075012, 811.125000 ),
								//Vector( -2027.430054, 960.395020, 609.007996)
		
							  ]

		local evacAngles = [ 	//Vector( 0, -80.54, 0 ),
								Vector( 0, 90.253, 0 )
								Vector( 0, 78, 0 ) //테스트용
								//Vector( 0, 180, 0 ),
								//Vector( 0, 179.604, 0 )
		
						   ]

		local evacSpectatorPositions = [ Vector( 2154.047852, -2074.738770, 942.299316 ),
										 Vector( 2714.390625, 45.400002, 759.743164 ),
										 Vector( 1903.058960, -1322.483521, 823.097656 ),
										 Vector( -1138.018311, 195.281570, 691.627930 )
		
							  		   ]

		local evacSpectatorAngles = [ 	Vector( 7.924948, -65.822983, 0 ),
										Vector( 0.014044, -234.180573, 0 ),
										Vector( 4.037039, -229.682098, 0 ),
										Vector( -4.035686, 140.311783, 0 )
		
									]

		level.evacNodes <- []
		level.evacSpectatorNodes <- []
		for ( local i = 0 ; i < evacPositions.len(); ++i )
		{
			local evacNode = CreateScriptRef( evacPositions[ i ], evacAngles[ i ] )
			level.evacNodes.append( evacNode )

			local evacSpectatorNode = CreateScriptRef( evacSpectatorPositions[ i ], evacSpectatorAngles[ i ] )
			level.evacSpectatorNodes.append( evacSpectatorNode )

		}

		EvacSetup()
		GM_AddEndRoundFunc( AngelCityEvacObserverSetup )
	}

	if ( GetCinematicMode() )
	{
		thread AC_Intro()
	}
	else
	{
		FlagWait( "GamePlaying" )
		NonCinematicSpawn()
		return
	}

}

function AngelCityPlayerSpawn( player )
{
	if ( Flag( "IntroDone" ) )
		return
	thread TemporaryIntroFlag( player )
}

function TemporaryIntroFlag( player )
{
	level.ent.EndSignal( "IntroDone" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnDestroy" )

	AddCinematicFlag( player, CE_FLAG_INTRO )
	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
			{
				RemoveCinematicFlag( player, CE_FLAG_INTRO )
			}
		}
	)

	WaittillGameStateOrHigher( eGameState.Prematch )
	wait 10

	local org = player.GetOrigin()
	local distBreak = 50
	local distBreakSqr = distBreak * distBreak

	for ( ;; )
	{
		if ( DistanceSqr( org, player.GetOrigin() ) > distBreakSqr )
			break

		wait 0
	}

}

/*--------------------------------------------------------------------------------------------------------------*\
|																												 |
|													INTRO														 |
|																												 |
\*--------------------------------------------------------------------------------------------------------------*/
function AC_Intro()
{
	CreateMilitiaStart()

	WaittillGameStateOrHigher( eGameState.WaitingForPlayers )

	thread IntroCityShow()

	WaittillGameStateOrHigher( eGameState.Prematch )

	local players = GetPlayerArrayOfTeam( TEAM_MILITIA )
	foreach ( player in players )
	{
		AddCinematicFlag( player, CE_FLAG_INTRO )
	}


	FlagSet( "Disable_IMC" )		// no random ai spawning
	FlagSet( "Disable_MILITIA" )	// no random ai spawning
	FlagSet( "DisableDropships" )	// no AI dropships or droppods

	thread IntroIMC()
	thread IntroMilitia()

	FlagWait( "IMC_IntroDone" )
	FlagClear( "Disable_IMC" )
	FlagClear( "Disable_MILITIA" )

	wait 5.0
	SetGlobalForcedDialogueOnly( false )
	FlagClear( "DisableDropships" )
	FlagSet( "IntroDone" )
}

function IntroMilitia()
{
	local players = GetPlayerArrayOfTeam( TEAM_MILITIA )
	foreach ( player in players )
	{
		thread SpawnPlayerOnGround( player, 26, 28 )
	}

	local scriptRef = level.mititiaIntroRef

	wait 4.4
	// Barker: I'm through with the frontier macallan, you hear me? I'm through.
	EmitSoundAtPosition( level.mititiaIntroRef.GetOrigin(), "diag_cmp_angc_mcor_barkr_groundintro_116_2" )
	wait 0.6

	thread IntroMilitiaNPC()
}

function NonCinematicSpawn()
{
	local players = GetPlayerArray()

	foreach ( player in players )
	{
		if ( !IsAlive( player ) )
		{
			DecideRespawnPlayer( player )
		}
	}
}

function ReplayIMCIntro()
{
	thread IntroIMCNPC( true )
}

function IntroIMC()
{
	thread IntroIMC_PlayerDropship()
	thread IntroIMCNPC()
}

function CreateIntroScriptRef()
{
	local origin = Vector ( -2652, 4309, 120 )
	local angles = Vector  (0, 0, 0)

	local scriptRef = CreateScriptRef()
	scriptRef.SetOrigin( origin )
	scriptRef.SetAngles( angles )
	level.mititiaIntroRef <- scriptRef
}

function CreateMilitiaStart()
{
	CreateIntroScriptRef()

	WaitEndFrame() // delete the existing spawners

	FlagSet( "DeletedIntroSpawners" ) // dont delete them anymore

	local scriptRef = level.mititiaIntroRef
	local origin = scriptRef.GetOrigin()
	local angles = scriptRef.GetAngles()


	local off = false
	local forward = angles.AnglesToForward()
	local offsets = []
	for ( local i = 0; i < 12; i++ )
	{
		local table = {}

		local offset = i - 6
		offset += 3 // move the arc

		table.offset <- offset

		table.odd <- off
		off = !off

		offsets.append( table )
	}

	ArrayRandomize( offsets )

	level.arc <- []

	local distMin = 130
	local distMax = 150
	local degrees = 8.0

	foreach ( table in offsets )
	{
		local yaw = table.offset * degrees
		yaw += 90
		local spawnAngles = angles.AnglesCompose( Vector( 0, yaw, 0 ) )
		local spawnForward = spawnAngles.AnglesToForward()
		local spawnOrigin = origin

		if ( table.odd )
			spawnOrigin = spawnOrigin + spawnForward * distMin
		else
			spawnOrigin = spawnOrigin + spawnForward * distMax


		// turn back around
		spawnAngles = spawnAngles.AnglesCompose( Vector( 0, 180, 0 ) )

		level.arc.append( { origin = spawnOrigin, angles = spawnAngles } )

		CreateMilitiaSpawner( spawnOrigin, spawnAngles )
	}
}

function CreateMilitiaSpawner( origin, angles )
{
	local ent = CreateEntity( "info_spawnpoint_human_start" )
	ent.SetOrigin( origin )
	ent.SetAngles( angles )
	ent.SetTeam( TEAM_MILITIA )
	DispatchSpawn( ent )
}

function ReplayMilitiaIntro()
{
	local ents = GetEntArrayByClass_Expensive( "info_spawnpoint_human_start" )

	foreach ( ent in ents )
	{
		local origin = ent.GetOrigin()
		local angles = ent.GetAngles()
		DrawArrow( origin, angles, 5.0, 20 )
	}

	thread IntroMilitiaNPC()
}

function InsertHatch()
{
	local scriptRef = level.mititiaIntroRef
	local origin = scriptRef.GetOrigin()
	local angles = scriptRef.GetAngles()
	local hatch = CreatePropDynamic( HATCH_MODEL, origin, angles )
//	thread PlayAnimTeleport( hatch, "hatch_angelcity_MILITIA_intro", scriptRef )
}

function IntroMilitiaNPC()
{

	printt( "Intro Militia Start" )
	SetGlobalForcedDialogueOnly( true )

	thread IntroMilitiaGruntSquad()
//
//	if ( !debug )
//		FlagWait( "IntroGoMilitia" )

	//scriptRef.SetOrigin( Vector (-2207.560791, 1216.342163, 120.031250) )
	//scriptRef.SetAngles( Vector  (0, 180, 0)  )
	local scriptRef = level.mititiaIntroRef
	local origin = scriptRef.GetOrigin()
	local angles = scriptRef.GetAngles()
	local hatch = CreatePropDynamic( HATCH_MODEL, origin, angles )
	local mac = CreateGrunt( TEAM_MILITIA, MAC_MODEL, "" )
	DispatchSpawn( mac )
//	CreatePropDynamic( MAC_MODEL, origin, angles )
	local grunt = CreateGrunt( TEAM_MILITIA, TEAM_MILITIA_CAPTAIN_MDL, "mp_weapon_rspn101" )
	DispatchSpawn( grunt )
//	CreatePropDynamic( TEAM_MILITIA_GRUNT_MDL, origin, angles )
//	local barker = CreatePropDynamic( BARKER_MODEL, origin, angles )
	local barker = CreateGrunt( TEAM_MILITIA, BARKER_MODEL, "" )
	DispatchSpawn( barker )

	barker.SetTitle( "#NPC_BARKER" )
	mac.SetTitle( "#NPC_MACALLAN" )
	grunt.SetTitle( "#NPC_SGT_RAKOWSKI" )
	MakeInvincible( grunt )
	MakeInvincible( barker )
	MakeInvincible( mac )


	//create titan and captain
	local table 	= CreateDefaultNPCTitanTemplate( TEAM_MILITIA )
	table.title 	= "#NPC_CAPTAIN_HAINEY"
	table.weapon	= "mp_titanweapon_40mm"
	table.origin 	= origin
	table.angles 	= angles

	local titan = SpawnNPCTitan( table )
	titan.SetEfficientMode( true )
	titan.SetTeam( TEAM_MILITIA )
	titan.DisableStarts()
	titan.EndSignal( "OnDeath" ) // in case we restart function
	DisableRodeo( titan )

	FlagClear( "hatch_closed" )
	// might be a re-run of intro
	foreach ( ent in level.debugIntroEnts )
	{
		if ( IsValid( ent ) )
			ent.Kill()
	}

	level.debugIntroEnts = []

	level.debugIntroEnts.append( mac )
	level.debugIntroEnts.append( barker )
	level.debugIntroEnts.append( titan )
	level.debugIntroEnts.append( hatch )
	level.debugIntroEnts.append( grunt )

	//thread ShowArcs()

	OnThreadEnd(
		function() : ( scriptRef, titan )
		{
			if ( IsAlive( titan ) )
			{
				titan.SetEfficientMode( false )
				EnableRodeo( titan )
			}
		}
	)

	thread PlayAnimTeleport( mac, "pt_angelcity_MILITIA_intro_mac", scriptRef )
	thread PlayAnimTeleport( barker, "pt_angelcity_MILITIA_intro_barker", scriptRef )
	thread PlayAnimTeleport( grunt, "pt_angelcity_MILITIA_intro_grunt", scriptRef )
	thread PlayAnimTeleport( hatch, "hatch_angelcity_MILITIA_intro", scriptRef )

	thread FinishIntroMilitiaDialogue( titan )
	thread RandomBarkerLine( barker )

	waitthread PlayAnimTeleport( titan, "at_angelcity_MILITIA_intro", scriptRef )

	FlagSet( "MILITIA_IntroDone" )

	if ( IsAlive( titan ) )
		thread MilitiaTitanMovesIn( titan )

	SetGlobalForcedDialogueOnly( false )

	wait 3

	if ( IsValid( barker ) )
		barker.Kill()

	if ( IsValid( grunt ) )
		grunt.Kill()

	if ( IsValid( mac ) )
		mac.Kill()
}

function MilitiaTitanMovesIn( titan )
{
	titan.EndSignal( "OnDeath" )
	local assault1 = Vector( -1895, 334, 182 )
	titan.AssaultPoint( assault1 )
	wait 8
	titan.EnableStarts()
	local assault2 = Vector( -251, 548, 180 )
	titan.AssaultPoint( assault2 )
}



function RandomBarkerLine( barker )
{
	/*
	local randomCommments = [
	//	Barker	I'm through with the Frontier! Ya hear me MacAllan? I'm through!
	//"diag_cmp_angc_mcor_barkr_groundintro_116_2",

	//	Barker	I'm gonna kick ALL your asses!
	//"diag_cmp_angc_mcor_barkr_groundintro_116_5",

	//	Barker	You ever love someone in a bar? Huhh? Huhh? Yeah, that's what I thought!
	"diag_cmp_angc_mcor_barker_groundintro_116_7",

	//	Barker	Frontier whiskey? You can't drink that cat piss! Hey, lemme go!
	"diag_cmp_angc_mcor_barker_groundintro_116_8",

	//"diag_cmp_angc_mcor_barker_groundintro_116_9",

	//	Barker	Oh, I don't feel so good - (vomiting sounds)
	//"diag_cmp_angc_mcor_barker_groundintro_116_10"
	]
	*/

	barker.EndSignal( "OnDestroy" )
	//local offset = 8.0
	//wait offset
	//	Barker	Put me down! Do you know who I am? Do you know who I am?
	//EmitSoundOnEntity( barker, "diag_cmp_angc_mcor_barker_groundintro_116_9" )

//	wait 15.2 - offset
	//wait 14.8 - offset

	//local sound = Random( randomCommments )
	//	Barker	Frontier whiskey? You can't drink that cat piss! Hey, lemme go!
	//local sound = "diag_cmp_angc_mcor_barker_groundintro_116_8"

	//EmitSoundOnEntity( barker, sound )
	wait 15.5
	EmitSoundOnEntity( barker, "diag_cmp_angc_mcor_barker_groundintro_116_8" )

	FlagWait( "hatch_closed" )
	StopSoundOnEntity( barker, "diag_cmp_angc_mcor_barker_groundintro_116_8" )
}

function IntroMilitiaGruntSquad()
{
	local squad = []

	local locations = []
	locations.append( { pos = Vector( -2406, 4284, 120 ), ang = Vector( 0, 170, 0 ) } )
	locations.append( { pos = Vector( -2975, 4034, 120 ), ang = Vector( 0, 35, 0 ) } )

	local node

	foreach( location in locations )
	{
		node = CreateScriptRef( location.pos, location.ang )
		for ( local i = 0 ; i < 3 ; i++ )
		{
			local guy = Spawn_TrackedGrunt( TEAM_MILITIA, "", node.GetOrigin(), node.GetAngles() )
			squad.append( guy )
			guy.AllowHandSignals( false )
			thread IntroMilitiaGruntSquadPlayAnim( guy, i, node )
		}
	}
}

function IntroMilitiaGruntSquadPlayAnim( guy, index, node )
{
	guy.EndSignal( "OnDeath" )

	local idles = [
		"pt_titan_briefingA_guy1_idle",
		"pt_titan_briefingA_guy2_idle",
		"pt_titan_briefingA_guy3_idle",
	]

	local anims = [
		"pt_titan_briefingA_guy1",
		"pt_titan_briefingA_guy2",
		"pt_titan_briefingA_guy3",
	]

	guy.SetEfficientMode( true )

	thread PlayAnimGravity( guy, idles[ index ], node )

	wait 4.5

	guy.DisableStarts()
	waitthread PlayAnimGravity( guy, anims[ index ], node )

	guy.SetEfficientMode( false )
	guy.AssaultPoint( Vector( 721, 548, 120 ), 512 )

	wait 2

	guy.EnableStarts()
}

function FinishIntroMilitiaDialogue( titan )
{
	local time = Time()
	wait 22.1
	if ( IsAlive( titan ) )
	{
		// alright people, let's buy them some time
		EmitSoundOnEntity( titan, "diag_cmp_angc_mcor_grunt2_groundintro_116_13" )
		wait 4.0
	}

	ForcePlayConversationToTeam( "militia_intro_vdu", TEAM_MILITIA)
	//Probably need some wait here to not stomp on game mode announcement
	wait 1.0
}

function ShowArcs()
{
	foreach ( table in level.arc )
	{
		DrawArrow( table.origin, table.angles, 20, 35 )
	}
}

function IntroIMCCloud( dropship, ref, table )
{
	 //return
	 thread CloudCoverEffect( dropship )
	 wait 2.0
	 thread CloudCoverEffect( dropship )
}

function IntroIMCStreetGrunt( pos )
{

}

function IntroIMCNPC( restart = false )
{
	local scriptRef = CreateScriptRef( Vector( 1888, -1384, 128  ), Vector(  0, 0, 0  ) )

	local grunts = []

	local grunt1 = Spawn_TrackedGrunt( TEAM_IMC, "IMCIntroGrunt", scriptRef.GetOrigin() , scriptRef.GetAngles() )
	grunt1.s.introFleePos <- Vector( 2018, -372, 182 )

	grunts.append( grunt1 )
	local grunt2 = Spawn_TrackedGrunt( TEAM_IMC, "IMCIntroGrunt", scriptRef.GetOrigin() , scriptRef.GetAngles() )
	grunt2.s.introFleePos <- Vector( 1980, -177, 180 )
	grunts.append( grunt2 )

	// 2-man skits for grunts lined up along streets
	local sideGruntLocations = []
	local sideGruntScriptRefs = []
	sideGruntLocations.append( { pos = Vector( 2393, -1826, 200 ), goal = Vector( 2155, 32, 180 ), anim = "A", delay = 0 } )
	sideGruntLocations.append( { pos = Vector( 2192, -1450, 120 ), goal = Vector( -42, 447, 120 ), anim = "B", delay = 0 } )
	sideGruntLocations.append( { pos = Vector( 2446, -1142, 200 ), goal = Vector( 747, 1611, 120 ), anim = "B", delay = 1.0 } )

	foreach ( location in sideGruntLocations )
	{
		local ref = CreateScriptRef( location.pos, Vector( 0, 90, 0 ) )
		ref.s.anim <- location.anim
		ref.s.delay <- location.delay

		ref.s.guyFront <- Spawn_TrackedGrunt( TEAM_IMC, "IMCIntroGrunt", ref.GetOrigin() , ref.GetAngles() )
		ref.s.guyFront.s.introFleePos <- location.goal
		grunts.append( ref.s.guyFront )

		ref.s.guyBack <- Spawn_TrackedGrunt( TEAM_IMC, "IMCIntroGrunt", ref.GetOrigin() , ref.GetAngles() )
		ref.s.guyBack.s.introFleePos <- location.goal
		grunts.append( ref.s.guyBack )

		sideGruntScriptRefs.append( ref )
	}

	// Setup grunts for animations
	foreach ( grunt in grunts )
	{
		grunt.SetEfficientMode( true )
		grunt.AllowFlee( false )
		grunt.AllowHandSignals( false )
	}

	local hornet = CreatePropDynamic( HORNET_MODEL, scriptRef.GetOrigin(), scriptRef.GetAngles()  )
	local missile1 = CreatePropDynamic( HORNET_MISSILE_MODEL, scriptRef.GetOrigin(), scriptRef.GetAngles() )
	missile1.Hide()
	local missile2 = CreatePropDynamic( HORNET_MISSILE_MODEL, scriptRef.GetOrigin(), scriptRef.GetAngles() )
	missile2.Hide()
	hornet.s.missile1 <- missile1
	hornet.s.missile2 <- missile2

	AddAnimEvent( hornet, "fire_missiles", HornetFireMissiles )
	AddAnimEvent( hornet, "explode", HornetExplodes )

	//create titan and captain
	local table 	= CreateDefaultNPCTitanTemplate( TEAM_IMC )
	table.title 	= "#NPC_CAPTAIN_BRACKEN"
	table.weapon	= "mp_titanweapon_xo16"
	table.origin 	= scriptRef.GetOrigin()
	table.angles 	= scriptRef.GetAngles()

	local titan = SpawnNPCTitan( table )
	titan.SetEfficientMode( true )
	DisableRodeo( titan )

	thread PlayAnimTeleport( grunt1, "pt_angelcity_IMC_ground_intro_A_idle", scriptRef )
	thread PlayAnimTeleport( grunt2, "pt_angelcity_IMC_ground_intro_B_idle", scriptRef )
	thread GruntAnimIntro( grunt1, "pt_angelcity_IMC_ground_intro_A_idle", scriptRef )
	thread GruntAnimIntro( grunt2, "pt_angelcity_IMC_ground_intro_B_idle", scriptRef )

	thread PlayAnimTeleport( hornet, "ht_angelcity_IMC_ground_intro_idle", scriptRef )
	thread PlayAnimTeleport( missile1, "rk_angelcity_IMC_ground_intro_A_idle", scriptRef )
	thread PlayAnimTeleport( missile2, "rk_angelcity_IMC_ground_intro_B_idle", scriptRef )
	thread PlayAnimTeleport( titan, "at_angelcity_IMC_ground_intro_idle", scriptRef )

	local idles = {}
	idles["A"] <- { front = "pt_IMC_intro_squad_A_front_idle", back = "pt_IMC_intro_squad_A_back_idle" }
	idles["B"] <- { front = "pt_IMC_intro_squad_B_front_idle", back = "pt_IMC_intro_squad_B_back_idle" }
	foreach ( ref in sideGruntScriptRefs )
	{
		thread PlayAnimTeleport( ref.s.guyFront, idles[ref.s.anim].front, ref )
		thread PlayAnimTeleport( ref.s.guyBack, idles[ref.s.anim].back, ref )
	}

	FlagWait( "GamePlaying" )

	if ( !restart )
		wait 11.5

	OnThreadEnd(
		function() : ( scriptRef, titan, grunts, hornet )
		{
			// dont do this because it breaks "replay imc intro" in dev menu
			//if ( IsValid( scriptRef ) )
			//	scriptRef.Kill()

			if ( IsValid( hornet ) )
				hornet.Kill()

			if ( IsAlive( titan ) )
			{
				titan.SetEfficientMode( false )
				EnableRodeo( titan )
			}

			foreach ( grunt in grunts )
			{
				if ( IsAlive( grunt ) )
				{
					grunt.SetEfficientMode( false )
					grunt.AllowFlee( true )

					if ( "introFleePos" in grunt.s )
						grunt.AssaultPoint( grunt.s.introFleePos, 0 )
				}

			}

		}
	)

	local anims = {}
	anims["A"] <- { front = "pt_IMC_intro_squad_A_front", back = "pt_IMC_intro_squad_A_back" }
	anims["B"] <- { front = "pt_IMC_intro_squad_B_front", back = "pt_IMC_intro_squad_B_back" }
	foreach ( ref in sideGruntScriptRefs )
	{
		Assert( ref.s.anim in anims )
		thread DelayedRefAnim( ref, anims, "guyFront", "front" )
		thread DelayedRefAnim( ref, anims, "guyBack", "back" )
	}

	grunt1.AssaultPoint( grunt1.s.introFleePos, 0 )
	grunt2.AssaultPoint( grunt2.s.introFleePos, 0 )
	grunt1.Anim_Stop()
	grunt2.Anim_Stop()

	thread PlayAnim( grunt1, "pt_angelcity_IMC_ground_intro_A", scriptRef )
	thread PlayAnim( grunt2, "pt_angelcity_IMC_ground_intro_B", scriptRef )
	thread PlayAnimTeleport( hornet, "ht_angelcity_IMC_ground_intro", scriptRef )
	thread PlayAnimTeleport( missile1, "rk_angelcity_IMC_ground_intro_A", scriptRef )
	thread PlayAnimTeleport( missile2, "rk_angelcity_IMC_ground_intro_B", scriptRef )
	waitthread PlayAnimTeleport( titan, "at_angelcity_IMC_ground_intro", scriptRef )

	// Play random dialog on grunts that were part of the intro sequence
	ArrayRandomize( sideGruntScriptRefs )
	local talkingGuy = null
	foreach( ref in sideGruntScriptRefs )
	{
		if ( IsAlive( ref.s.guyFront ) )
		{
			talkingGuy = ref.s.guyFront
			break
		}

		if ( IsAlive( ref.s.guyBack ) )
		{
			talkingGuy = ref.s.guyBack
			break
		}
	}

	if ( IsValid( talkingGuy ) )
		delaythread( 9.0 ) GruntIntroDialog( talkingGuy )

	// Make titan move up the street
	if ( IsAlive( titan ) )
	{
		local assault = Vector( -251, 548, 180 )
		titan.AssaultPoint( assault )
	}

	FlagSet( "IMC_IntroDone"  )
}

function GruntAnimIntro( grunt, anim1, scriptRef )
{
	//grunt.EndSignal( "OnAnimationDone" )
	//grunt.EndSignal( "OnAnimationInterrupted" )
	grunt.EndSignal( "OnDeath" )
	grunt.EndSignal( "ScriptAnimStop" )

	local anim2 = anim1 + "2"
	grunt.WaittillAnimDone()
	for ( ;; )
	{
		waitthread PlayAnim( grunt, anim2, scriptRef )
		waitthread PlayAnim( grunt, anim1, scriptRef )
	}
}

function GruntIntroDialog( guy )
{
	if ( !IsAlive( guy ) )
		return
	guy.EndSignal( "OnDeath" )

	EmitSoundOnEntity( guy, "diag_cmp_angc_imc_tpilot_groundintro_05_1" )
	wait 7.0
	EmitSoundOnEntity( guy, "diag_cmp_angc_imc_tpilot_groundintro_05_2" )
	wait 4.0
	EmitSoundOnEntity( guy, "diag_cmp_angc_imc_tpilot_groundintro_05_3" )
}

function DelayedRefAnim( ref, anims, guySpot, dir )
{
	local guy = ref.s[ guySpot ]
	local anim = anims[ref.s.anim][ dir ]
	Assert( IsAlive( guy ) )
	guy.EndSignal( "OnDeath" )
	ref.EndSignal( "OnDestroy" )


	wait ref.s.delay
	PlayAnimTeleport( guy, anim, ref )
}

function HornetFireMissiles( hornet )
{
	// Need to hide/unhide the missile when it shoots

	Assert( "missile1" in hornet.s )
	Assert( "missile2" in hornet.s )

	local missiles = []
	missiles.append( hornet.s.missile1 )
	missiles.append( hornet.s.missile2 )

	foreach( missile in missiles )
	{
		Assert( IsValid( missile ) )

		local attachID = missile.LookupAttachment( "exhaust" )
		local attachOrigin = missile.GetAttachmentOrigin( attachID )
		local attachAngles = missile.GetAttachmentAngles( attachID )

		local missileTrail = CreateEntity( "info_particle_system" )
		missileTrail.SetOrigin( attachOrigin )
		missileTrail.SetAngles( attachAngles )

		missileTrail.kv.effect_name = EFFECT_HORNET_MISSILE_TRAIL
		missileTrail.kv.start_active = 1
		DispatchSpawn( missileTrail, false )

		missileTrail.SetParent( missile )
		missileTrail.MarkAsNonMovingAttachment()
		missile.Show()

		local missileFlash = CreateEntity( "info_particle_system" )
		missileFlash.SetOrigin( attachOrigin )
		missileFlash.SetAngles( attachAngles )

		missileFlash.kv.effect_name = EFFECT_HORNET_MISSILE_FLASH
		missileFlash.kv.start_active = 1
		DispatchSpawn( missileFlash, false )

		if ( missile == hornet.s.missile2 )
			thread HornetMissileExplode_Building( missile, missileTrail, missileFlash )
		else
			thread HornetMissileExplode_Wall( missile, missileTrail, missileFlash )
	}
}

function HornetMissileExplode_Building( missile, missileTrail, missileFlash )
{
	EmitSoundOnEntity( missile, HORNET_MISSILE_SFX_LOOP_LEFT )

	local apartmentsign = GetEnt( "apartment_sign_destruct" )

	missile.WaitSignal( "OnAnimationDone" )

	missileTrail.Kill()
	missileFlash.Kill()
	missile.Kill()

	EmitSoundAtPosition( missile.GetOrigin(), HORNET_MISSILE_SFX_IMPACT_LEFT )

	// Explosion
	local explosion = CreateEntity( "info_particle_system" )
	//explosion.SetOrigin( missile.GetOrigin() )
	explosion.SetOrigin( Vector( 1976, -1330, 583) )
	explosion.SetAngles( Vector( 90, 0, 0 ) )
	explosion.kv.effect_name = EFFECT_HORNET_MISSILE_EXPLOSION
	explosion.kv.start_active = 1
	DispatchSpawn( explosion, false )

	wait 0.1

	if ( IsValid( apartmentsign ) )
		apartmentsign.Kill()

	local explosion2 = CreateEntity( "info_particle_system" )
	//explosion2.SetOrigin( missile.GetOrigin() )
	explosion2.SetOrigin( Vector( 1906, -1424, 584) )
	explosion2.SetAngles( Vector( 90, 0, 90 ) )
	explosion2.kv.effect_name = EFFECT_APARTMENT_SIGN_EXPLOSION
	explosion2.kv.start_active = 1
	DispatchSpawn( explosion2, false )

	CreateShake( explosion2.GetOrigin(), 16, 150, 1.5, 2048 )

	explosion.Kill( 5.0 )
	explosion2.Kill( 5.0 )
}

function HornetMissileExplode_Wall( missile, missileTrail, missileFlash )
{
	EmitSoundOnEntity( missile, HORNET_MISSILE_SFX_LOOP_RIGHT )

	missile.WaitSignal( "OnAnimationDone" )

	local pos = missile.GetOrigin()

	// Explosion
	local explosion = CreateEntity( "info_particle_system" )
	explosion.SetOrigin( pos )
	explosion.SetAngles( Vector( 90, 0, 0 ) )
	explosion.kv.effect_name = EFFECT_HORNET_MISSILE_EXPLOSION
	explosion.kv.start_active = 1
	DispatchSpawn( explosion, false )

	EmitSoundAtPosition( pos, HORNET_MISSILE_SFX_IMPACT_RIGHT )
	CreateShake( pos, 16, 150, 1.5, 768 )

	missileTrail.Kill()
	missileFlash.Kill()
	missile.Kill()
	explosion.Kill( 5.0 )
}

function HornetExplodes( hornet )
{
	local players = GetPlayerArray()
	local hornetEHandle = hornet.GetEncodedEHandle()
	foreach ( player in players )
		Remote.CallFunction_Replay( player, "ServerCallback_IMCIntroHornetExplosion", hornetEHandle )
	EmitSoundAtPosition( hornet.GetOrigin(), "AngelCity_Scr_HornetExplodes" )
	hornet.Hide()
}




/*--------------------------------------------------------------------------------------------------------------*\
|																												 |
|													UTILITY														 |
|																												 |
\*--------------------------------------------------------------------------------------------------------------*/

function PlaySoundOnEnt( ent, sound )
{
	EmitSoundOnEntity( ent, sound )
}

function MilitiaMatchProgressDialogue()
{
	if ( level.devForcedWin )  //Don't announce progress if we force win
		return

	local imcScore = GameRules.GetTeamScore( TEAM_IMC )
	local scoreLimit = GetScoreLimit_FromPlaylist()
	local imcScoreProgress = ( imcScore.tofloat() / scoreLimit.tofloat() ) * 100.0

	//printt( "imcScoreProgress:" + imcScoreProgress )

	local alias = null

	if ( imcScoreProgress >= 75.0 )
		alias = "militia_strength_25_percent"
	else if ( imcScoreProgress >= 50.0 )
		alias = "militia_strength_50_percent"
	else if ( imcScoreProgress >= 25.0 )
		alias = "militia_strength_75_percent"

	if ( !alias )
		return

	//printt( "Alias: " + alias )

	// MILITIA
	if ( !level.angelCityMatchProgressDialog[ TEAM_MILITIA ][ alias ] )
	{
		level.angelCityMatchProgressDialog[ TEAM_MILITIA ][ alias ] = true
		PlayConversationToTeam( alias, TEAM_MILITIA )
	}

}

function IMCMatchProgressDialogue()
{
	if ( level.devForcedWin )  //Don't announce progress if we force win
		return

	local militiaScore = GameRules.GetTeamScore( TEAM_MILITIA )
	local scoreLimit = GetScoreLimit_FromPlaylist()
	local militiaScoreProgress = ( militiaScore.tofloat() / scoreLimit.tofloat() ) * 100.0

	//printt( "militiaScoreProgress:" + militiaScoreProgress )

	local alias = null

	if ( militiaScoreProgress >= 75.0 )
		alias = "imc_strength_25_percent"
	else if ( militiaScoreProgress >= 50.0 )
		alias = "imc_strength_50_percent"
	else if ( militiaScoreProgress >= 25.0 )
		alias = "imc_strength_75_percent"

	if ( !alias )
		return

	//printt( "Alias: " + alias )

	// IMC
	if ( !level.angelCityMatchProgressDialog[ TEAM_IMC ][ alias ] )
	{
		level.angelCityMatchProgressDialog[ TEAM_IMC ][ alias ] = true
		PlayConversationToTeam( alias, TEAM_IMC )
	}

}

function EvacSetup()
{
	local evacIndex = RandomInt( 0, level.evacNodes.len()  )
	local evacNode = level.evacNodes[ evacIndex ]
	level.evacSpectatorNode <- level.evacSpectatorNodes[ evacIndex ] //This gets used later in AngelCityEvacObserverSetup. Can't just do the spectator observer setup now since it overrides the normal spectator function. We only want to do it at the end of the match
	local origin = Vector( -1700, -5500, -7600 )  //Just pick a good origin and view. Make sure you don't see the megacarrier!
	local angles = Vector( -3.620642, 270.307129, 0 )
	local spacenode = CreateScriptRef( origin, angles )

	Evac_SetEvacNode( evacNode )
	Evac_SetSpaceNode( spacenode )
	Evac_SetupDefaultVDUs()


	if ( GetCinematicMode() || GetCurrentPlaylistVarInt( "run_evac", 0 ) )
	{
		//Post Evac IMC lines. No equivalent militia lines
		Evac_SetPostEvacDialogueTime( 7.0 )
		Evac_SetVDULosersEvacPostEvac( TEAM_IMC, "losers_evac_post_evac" ) //This is only played when IMC lose.
		Evac_SetVDULosersEvacPostPursuit( TEAM_IMC, "losers_evac_post_pursuit" ) //This is only played when IMC win.
	}
}

//bind z "script thread TestFlightpath( STRATON_MODEL, STRATON_FLIGHT_ANIM )"




function AC_StartSpawnThink( ent )
{
	// delete the militia spawners and spawn them in script
	if ( Flag( "DeletedIntroSpawners" ) )
		return
	local team = ent.GetTeam()
	if ( team == TEAM_MILITIA )
		ent.Kill()
}


function IntroIMC_PlayerDropship()
{
	local origin = Vector( 2078.91, -1849.41, 122.998 )
	local angles = Vector( 0, 90, 0 )

	local initialTime = 4.0
	local anims = []

	// third person, first person, yaw offset
	local offset = 18
	AddRideAnims( anims, initialTime, "Militia_flyinB_exit_playerA", "Militia_flyinB_exit_povA", -18 )
	AddRideAnims( anims, initialTime, "Militia_flyinB_exit_playerB", "Militia_flyinB_exit_povB", 8 )
	AddRideAnims( anims, initialTime, "Militia_flyinB_exit_playerC", "Militia_flyinB_exit_povC", 8 )
	AddRideAnims( anims, initialTime, "Militia_flyinB_exit_playerD", "Militia_flyinB_exit_povD", -16 )

	local players = GetPlayerArrayOfTeam( TEAM_IMC )
	ArrayRandomize( players )
	local ship1Players = []
	local ship2Players = []

	if ( DROPSHIP_SEAT > 0 && players.len() == 1 )
	{
		// debugging dropship seats?
		Assert( DROPSHIP_SEAT >= 0 && DROPSHIP_SEAT < 8, "Illegal DROPSHIP_SEAT value " + DROPSHIP_SEAT )
		if ( DROPSHIP_SEAT < 4 )
		{
			ship1Players.append( players[0] )
		}
		else
		{
			ship2Players.append( players[0] )
		}
	}
	else
	{
		for ( local i = 0; i < 4; i++ )
		{
			if ( i >= players.len() )
				break
			ship1Players.append( players[i] )
		}

		for ( local i = 4; i < 8; i++ )
		{
			if ( i >= players.len() )
				break
			ship2Players.append( players[i] )
		}
	}

	////DrawArrow( origin, angles, 60, 150 )
	//local right = angles.AnglesToRight()
	//local forward = angles.AnglesToForward()
	//origin += forward * -150
	//origin += right * -600
	//angles = angles.AnglesCompose( Vector( 0, -60, 0 ) )
	thread DropshipIntro( initialTime, origin, angles, anims, ship1Players, "dropship_angelcity_flyin_imc_L" )
	thread DropshipIntro( initialTime, origin, angles, anims, ship2Players, "dropship_angelcity_flyin_imc_R" )
}

function DropshipIntro( initialTime, origin, angles, anims, players, anim )
{
	local ship = SpawnAnimatedDropship( origin, TEAM_IMC )
	ship.SetModel( DROPSHIP_HERO_MODEL )

	for ( local i = 0; i < players.len(); i++ )
	{
		local player = players[i]
		local anim
		if ( DROPSHIP_SEAT > 0 )
			anim = anims[ DROPSHIP_SEAT % 4 ]
		else
			anim = anims[i]

		thread SpawnPlayerIntoRide( ship, player, anim )
	}

	thread PlayAnim( ship, anim, origin, angles )

	// Graves
	local graves = CreatePropDynamic( GRAVES_MODEL )
	graves.SetParent( ship, "ORIGIN" )
	graves.MarkAsNonMovingAttachment()
	thread PlayAnim( graves, "IMC_Angel_City_ridin_end_graves", ship, "ORIGIN" )
	graves.Anim_SetInitialTime( initialTime )

	// Spyglass
	local spyglass = CreatePropDynamic( SPYGLASS_MODEL )
	spyglass.SetParent( ship, "ORIGIN" )
	thread PlayAnim( spyglass, "IMC_Angel_City_ridin_end_spyglass", ship, "ORIGIN" )
	spyglass.Anim_SetInitialTime( initialTime )
	spyglass.MarkAsNonMovingAttachment()

	ship.Anim_SetInitialTime( initialTime )
	ship.WaittillAnimDone()
}
	/*

	"Militia_flyinA_idle_playerD", 		"Militia_flyinA_idle_povD",			ViewConeRampFrontRight
	"Militia_flyinA_idle_playerA", 		"Militia_flyinA_idle_povA",			ViewConeRampBackRight )
	"Militia_flyinA_countdown_playerA", "Militia_flyinA_countdown_povA",	ViewConeRampFree )
	"Militia_flyinB_exit_playerA", 		"Militia_flyinB_exit_povA",			ViewConeRampFree )

	"Militia_flyinA_idle_playerB", 		"Militia_flyinA_idle_povB",			ViewConeRampFrontLeft )
	SetAnimProceduralLengthAdjustment( animGroup, "idle", -6.65 )
	AddAnimGroupBlend( animGroup,	"ready",	"Militia_flyinA_countdown_playerB", "Militia_flyinA_countdown_povB",	ViewConeRampFree )
	AddAnimGroupBlend( animGroup,	"deploy", 	"Militia_flyinB_exit_playerB", 		"Militia_flyinB_exit_povB",			ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "deploy" )

	//back left
	animGroup = CreateAnimGroup( "jump", "ORIGIN" )
	AddAnimGroupStart( animGroup, 	"idle", 	"Militia_flyinA_idle_playerC", 		"Militia_flyinA_idle_povC",			ViewConeRampBackLeft )
	SetAnimProceduralLengthAdjustment( animGroup, "idle", -6.65 )
	AddAnimGroupBlend( animGroup,	"ready",	"Militia_flyinA_countdown_playerC", "Militia_flyinA_countdown_povC",	ViewConeRampFree )
	AddAnimGroupBlend( animGroup,	"deploy", 	"Militia_flyinB_exit_playerC", 		"Militia_flyinB_exit_povC",			ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "deploy" )


}

*/

function SetupCinematicMatchProgressAnnouncement()
{
	local table = {}
	table[ TEAM_IMC ] <- {}
	table[ TEAM_MILITIA ] <- {}
	table[ TEAM_IMC ][ "militia_strength_75_percent" ] <- false
	table[ TEAM_MILITIA ][ "militia_strength_75_percent" ] <- false
	table[ TEAM_IMC ][ "militia_strength_50_percent" ] <- false
	table[ TEAM_MILITIA ][ "militia_strength_50_percent" ] <- false
	table[ TEAM_IMC ][ "militia_strength_25_percent" ] <- false
	table[ TEAM_MILITIA ][ "militia_strength_25_percent" ] <- false
	table[ TEAM_IMC ][ "imc_strength_75_percent" ] <- false
	table[ TEAM_MILITIA ][ "imc_strength_75_percent" ] <- false
	table[ TEAM_IMC ][ "imc_strength_50_percent" ] <- false
	table[ TEAM_MILITIA ][ "imc_strength_50_percent" ] <- false
	table[ TEAM_IMC ][ "imc_strength_25_percent" ] <- false
	table[ TEAM_MILITIA ][ "imc_strength_25_percent" ] <- false
	level.angelCityMatchProgressDialog <- table

	const MATCH_PROGRESS_FLAVOR_VDU1 = 15
	const MATCH_PROGRESS_FLAVOR_VDU2 = 40
	level.matchProgressFlavorVDU1 <- false
	level.matchProgressFlavorVDU2 <- false

	AddDeathCallback( "player", OnPlayerDeath ) //for match progress associated with player deaths.

	GM_SetMatchProgressAnnounceFunc( AngelCityMatchProgressAnnouncementFunc )

}

//Use OnPlayerDeath since match progression isn't quite what we want.
//Imagine the situation where 50% of IMC forces are killed, without militia dying once
//At that point in time progression is set to 50%.
//Now imagine the IMC start killing the militia without the IMC dying.
//match Progression doesn't increase until miliita deaths exceed 50%.
//Yet we want to report that 25% of the militia have been wiped out, 50% of the militia have been wiped out, etc
function OnPlayerDeath( player, damageInfo  )
{
	if (  GetGameState() != eGameState.Playing )
		return

	IMCMatchProgressDialogue()
	MilitiaMatchProgressDialogue()
}

function AngelCityMatchProgressAnnouncementFunc( progression )
{
	if ( level.devForcedWin )  //Don't announce progress if we force win
		return

	if ( progression >= MATCH_PROGRESS_FLAVOR_VDU1 )
	{
		if ( !level.matchProgressFlavorVDU1 )
		{
			PlayConversationToAll( "match_progress_15_percent" )
			level.matchProgressFlavorVDU1 = true

		}
	}

	if ( progression >= MATCH_PROGRESS_FLAVOR_VDU2 )
	{
		if ( !level.matchProgressFlavorVDU2 )
		{
			PlayConversationToAll( "match_progress_40_percent" )
			level.matchProgressFlavorVDU2 = true

		}
	}

	//On top of the custom stuff, we want the default announcements, so call default announcements
	DefaultMatchProgressionAnnouncement( progression )
}

function AngelCitySpecificChatter( npc )
{
	Assert( GetMapName() == "mp_angel_city" )
	//printt( "Trying AngelCitySpecificChatter" )
	local probability = RandomFloat( 0, 1 )
	if ( level.nv.megaCarrier && level.nv.matchProgress > 50.0 ) //Wait till matchProgress > 50 because a line in there refers to the Hornets, which should only be played after the entire sequence with the dropship is over
	{
		if ( probability < 0.02 ) //Low chance of commenting about the mega carrier again
		{
			PlaySquadConversationToTeam( "ai_comment_megacarrier", npc.GetTeam(), npc, AI_FRIENDLY_CHATTER_RANGE_SQR )
			return true
		}

	}

	PlaySquadConversationToTeam( "angelcity_grunt_chatter", npc.GetTeam(), npc, AI_FRIENDLY_CHATTER_RANGE_SQR )
	return true //return false if we should not be doing chatter so we can fall through and do other chatter if needed
}

function AngelCityRoundEnd()
{
	local winningTeam = GetTeamIndex(GetWinningTeam())

	// TODO: needs to handle draw better
	if ( winningTeam == TEAM_IMC )
	{
		thread IMCWinCarrierMoves()
	}
	else
	{
		thread MilitiaWinAttackMegaCarrier()
	}
}

//Separate from AngelCityRoundEnd so you can test evac without needing the cinematic stuff
function AngelCityEvacObserverSetup()
{
	//Set up Observer for evac
	GM_SetObserverFunc( ObserverFunc )
}

function ObserverFunc( player )
{
	player.SetObserverModeStaticPosition( level.evacSpectatorNode.GetOrigin() )
	player.SetObserverModeStaticAngles( level.evacSpectatorNode.GetAngles() )

	player.StartObserverMode( OBS_MODE_CHASE )
	player.SetObserverTarget( null )
}

function MilitiaWinAttackMegaCarrier()
{
	local players = GetPlayerArray()

	foreach ( player in players )
	{
		Remote.CallFunction_Replay( player, "ServerCallback_MilitiaFleetAttackMegaCarrier" )
	}

	wait 16.5
	FlagSet( "MegaCarrierEscapes" )
	//thread LaunchRandomDogFighterAttacks( TEAM_MILITIA )

}

function IMCWinCarrierMoves()
{
	local players = GetPlayerArray()

	foreach ( player in players )
	{
		Remote.CallFunction_Replay( player, "ServerCallback_IMCVictoryCarrierMoves" )
	}

	wait 2.0

	FlagSet( "MegaCarrierMovesOverCity" )
	wait 10.0
	//thread LaunchRandomDogFighterAttacks( TEAM_IMC )

	//Nothing here yet
	return

}

function SearchShipsReplenish()
{
	if ( GAMETYPE == COOPERATIVE )
		return
//	if ( JumpQuestEnabled() )
//		return

	WaittillGameStateOrHigher( eGameState.Prematch )

	wait 10

	local searchSpawnerNodeNames = []
	searchSpawnerNodeNames.append( "cinematic_mp_node_us576" )
	searchSpawnerNodeNames.append( "cinematic_mp_node_us493" )
	searchSpawnerNodeNames.append( "cinematic_mp_node_us665" )

	local searchSpawnerNodes = []
	foreach( name in searchSpawnerNodeNames )
	{
		local _node = GetNodeByUniqueID( name )
		Assert( _node != null )
		searchSpawnerNodes.append( _node )
	}

	// Continually run the nodes so we have constant supply of search ships in the level
	while ( GetGameState() <= eGameState.SuddenDeath )
	{
		foreach( node in searchSpawnerNodes )
		{
			delaythread( RandomFloat( 0.0, 15.0 ) ) NodeDoMoment( node )
		}
		wait 30
	}
}


main()



