//-----------
// Models
//-----------
const CIVILIAN_MODEL_01 = "models/humans/civilian/civilian_male/civilian_male_a.mdl"
const CIVILIAN_MODEL_02 = "models/humans/civilian/civilian_male/civilian_male_b.mdl"
const CIVILIAN_MODEL_03 = "models/humans/civilian/civilian_male/civilian_male_c.mdl"
const CIVILIAN_MODEL_04 = "models/humans/civilian/civilian_male/civilian_male_d.mdl"
const SPECTRE_PALETTE_MODEL = "models/commercial/rack_spectre_palette.mdl"
const KNIFE_MODEL = "models/weapons/combat_knife/w_combat_knife.mdl"

PrecacheModel( KNIFE_MODEL )
PrecacheModel( CIVILIAN_MODEL_01 )
PrecacheModel( CIVILIAN_MODEL_02 )
PrecacheModel( CIVILIAN_MODEL_03 )
PrecacheModel( CIVILIAN_MODEL_04 )
PrecacheModel( SPECTRE_PALETTE_MODEL )


//-----------
// FX
//-----------
const FX_GUNSHIP_SPOTLIGHT = "P_veh_gunship_spotlight"
const FX_SPECTRE_EYE_GLOW = "P_spectre_eye_friend"
PrecacheParticleSystem( FX_GUNSHIP_SPOTLIGHT )
PrecacheParticleSystem( FX_SPECTRE_EYE_GLOW )

//-----------
// Audio
//-----------
//const SFX_CIVILIAN_SCREAMS = ""
const SFX_FLYAWAY_DROPSHIP_MILITIA = "Colony_Scr_MilitiaIntro_DropshipFlyaway"
const SFX_FLYAWAY_DROPSHIP_IMC = "Colony_Scr_MilitiaIntro_DropshipFlyaway"  //<-- need IMC-specific flyaway
const SFX_STRATTON1 = "Colony_Scr_IMCIntro_Stratton1"
const SFX_STRATTON2 = "Colony_Scr_IMCIntro_Stratton2"
const SFX_STRATTON3 = "Colony_Scr_IMCIntro_Stratton3"
const SFX_STRATTON4 = "Colony_Scr_IMCIntro_Stratton4"
const SFX_DROPSHIP_PLAYER_ENGINE_IMC = "Colony_Scr_IMCIntro_FlyIn"
const SFX_DROPSHIP_PLAYER_ENGINE_MILITIA = "Colony_Scr_MilitiaIntro_DropshipFlyinAmb"
const SFX_SPECTRE_LIGHT_ACTIVATE = "colony_spectre_initialize_beep"
const SFX_SPECTRE_RACK_ACTIVATE = "corporate_spectrerack_activate"
const SFX_GUNSHIP_WIRE_SNAP = "dropship_zipline_zipfire"

RegisterSignal( "ShowTitle" )

function main()
{
	if ( reloadingScripts )
		return

	level.viewcodeNoLookBehind <- true

	IncludeFileAllowMultipleLoads( "mp/_vehicle_gunship" )
	//FlagSet( "DisableDropships" )
	IncludeFile( "mp_corporate_shared" )

	FlagInit( "PaletteOnGround" )
	FlagInit( "MilitiaSoldierWaves" )
	FlagInit( "SpectreThroatSlit" )
	FlagInit( "DetachGunshipRopes" )
	FlagInit( "StartMilitiaDropships" )
	FlagInit( "IntroIMCstartPrisonerKill" )
	FlagInit( "IntroIMCstartBodyDisposal" )
	FlagInit( "StartIMCDropships" )
	FlagInit( "IntroDropshipDoneMilitia" )
	FlagInit( "IntroDropshipDoneIMC" )
	FlagInit( "IntroDoneMilitia" )
	FlagInit( "IntroDoneIMC" )
	FlagInit( "IntroIMCGunshipTakesOff" )
	FlagInit( "StartMilitiaSpectreAttack" )

	level.playCinematicContent <- false
	if ( ( GetCinematicMode() ) && ( GAMETYPE == ATTRITION ) )
		level.playCinematicContent = true

	//level.playCinematicContent = false	<--- debug

	if ( level.playCinematicContent )
	{
		level.spectreRallyPoints <- null
		FlagSet( "CinematicIntro" )
		FlagSet( "CinematicOutro" )
		FlagSet( "AllSpectreIMC" )
		FlagSet( "NoSpectreMilitia" )

		SetGameModeAnnouncement( "ColonyGameModeAnnounce_AT" )
		SetGameWonAnnouncement( "ColonyWonAnnouncement" )
		SetGameLostAnnouncement( "ColonyLostAnnouncement" )

		const MATCH_PROGRESS_FLAVOR_VDU1 = 15	//Play some story dialogue 15% of the way through
		const MATCH_PROGRESS_FLAVOR_VDU2 = 40	//Play some story dialogue 40% of the way through
		const MATCH_PROGRESS_FLAVOR_VDU3 = 60	//Play some story dialogue 60% of the way through
		const MATCH_PROGRESS_FLAVOR_VDU4 = 80	//Play some story dialogue 80% of the way through
		level.matchProgressFlavorVDU1 <- false
		level.matchProgressFlavorVDU2 <- false
		level.matchProgressFlavorVDU3 <- false
		level.matchProgressFlavorVDU4 <- false
		GM_SetMatchProgressAnnounceFunc( ColonyMatchProgressAnnouncementFunc )

		level.levelSpecificChatterFunc = ColonySpecificChatter
	}
	else
	{
		DeleteCinematicContent()
	}

	AddSpawnCallback( "npc_spectre", SpectreCallbackColony )
	GM_AddEndRoundFunc( EndRoundMain )
}




///////////////////////////////////////////////////////////////////////////////////////////////////////////
function EntitiesDidLoad()
{
	if ( !IsServer() )
		return

	if ( EvacEnabled() )
		EvacSetup()

	if ( level.playCinematicContent )
	{
		SetCustomIntroLength( 35 )
		thread Intros()
	}

	level.bloodsmear <- GetEnt( "func_brush_bloodsmear" )
	Assert( level.bloodsmear != null )
	level.bloodsmear.Hide()

	if ( GetBugReproNum() == 999 )
		thread debug()

}

function debug()
{
    local nodeCount = GetNodeCount()
    local origin

    while ( true )
    {
	    for ( local i = 0; i < nodeCount; i++ )
	    {
	        origin = GetNodePos( i, 0 )
	        if ( IsSpectreNode( i ) )
	            DebugDrawLine( origin, origin + Vector(0,0,64), 255, 0, 0, false, 1.0 )
	        else
	            DebugDrawLine( origin, origin + Vector(0,0,64), 0, 255, 0, false, 1.0 )
		}
		wait 0.1
	}
}

/*----------------------------------------------------------------------------------
/
/				INTROS
/
/-----------------------------------------------------------------------------------*/
function AA_INTRO_Functions()
{
	//Bookmark to jump to this section
}

function Intros()
{
	level.spectreRallyPoints = GetEntArrayByNameWildCard_Expensive( "spectreRallyPoint*" )
	Assert( level.spectreRallyPoints.len() > 10, "COLONY: Need more spectreRallyPoint entities: " + level.spectreRallyPoints.len() )

	IntroDropshipMilitiaSetup()
	IntroDropshipIMCSetup()

	FlagWait( "ReadyToStartMatch" )

	//--------------------------------
	// Disable stuff
	//--------------------------------
	SetGlobalForcedDialogueOnly( true )
	FlagSet( "Disable_IMC" )		// no random ai spawning
	FlagSet( "Disable_MILITIA" )	// no random ai spawning
	FlagSet( "DisableDropships" )	// no AI dropships or droppods

	//--------------------------------
	// Run intros
	//--------------------------------
	level.nv.ClientTiming = Time()
	thread IntroMilitia()
	thread IntroIMC()

	FlagWait( "IntroDoneMilitia" )
	FlagWait( "IntroDoneIMC" )

	FlagSet( "IntroDone" )

	//--------------------------------
	// Enable stuff
	//--------------------------------
	FlagClear( "Disable_MILITIA" )
	FlagClear( "DisableDropships" )	//temp fix till figure out why spectre pathgraphs are leaking
	FlagClear( "Disable_IMC" )
	SetGlobalForcedDialogueOnly( false )

}

/*----------------------------------------------------------------------------------
/
/				INTRO IMC
/
/-----------------------------------------------------------------------------------*/
function AA_INTRO_IMC_Functions()
{
	//Bookmark to jump to this section
}

///////////////////////////////////////////////////////////////////////////////////////////////////
function IntroIMC()
{
	//--------------------------------
	// Ground skits right as player takes off
	//--------------------------------
	local posDropshipSkit01 = Vector( 1150, 5557, -40 )
	local angDropshipSkit01 = Vector( 0, 0, 0 )

	local posDropshipSkit02 = Vector( 1030, 5613, -50 )
	local angDropshipSkit02 = Vector( 0, 270, 0 )

	local posDropshipSkit03 = Vector( 789.322, 6132.12, -107.383 )
	local angDropshipSkit03 = Vector( 0, 0, 0 )

	local posDropshipSkit04 = Vector( 625.322, 6168.12, -107.383 )
	local angDropshipSkit04 = Vector( 0, 0, 0 )


	//Dropship 1 view
	delaythread ( 5 ) IntroSkit( "spectreCorpsePatrolB2", UniqueString(), posDropshipSkit01, angDropshipSkit01, TEAM_IMC, null, null, 0, IntroSpectreFieldsCleanup )
	delaythread ( 8.5 ) IntroSkit( "prisonerDragKill", UniqueString(), posDropshipSkit02, angDropshipSkit02, TEAM_IMC, null, null, 0, IntroSpectreFieldsCleanup )

	//Dropship 2 view
	delaythread ( 0.1 ) IntroSkit( "prisonerKill", UniqueString(), posDropshipSkit03, angDropshipSkit03, TEAM_IMC, null, null, 0, IntroSpectreFieldsCleanup )
	delaythread ( 5.5 ) IntroSkit( "spectreCorpsePatrolB", UniqueString(), posDropshipSkit04, angDropshipSkit04, TEAM_IMC, null, null, 0, IntroSpectreFieldsCleanup )


	//--------------------------------
	// Blocker brush so AI navigates around skits
	//--------------------------------
	local IMCbrushBlocker = GetEnt( "func_brush_clip_imc_intro" )
	Assert( IMCbrushBlocker != null, "Can't find scripted func_brush for IMC intro: 'func_brush_clip_imc_intro'" )

	local posAmbientShip1 =  Vector( 1663.5, 4770.5, 591.5 )
	local angAmbientShip1 =  Vector ( 0, 90, 0 )
	local gunshipAmbient1 = GunshipSpawn( posAmbientShip1, angAmbientShip1, TEAM_IMC )
	gunshipAmbient1.SetSpeedImmediate( 50 )
	EmitSoundOnEntity( gunshipAmbient1, SFX_STRATTON1 )


	local posAmbientShip2 =  Vector( -620, 5808.5, -832 )
	local angAmbientShip2 =  Vector ( 0, 150, 0 )
	local gunshipAmbient2 = GunshipSpawn( posAmbientShip2, angAmbientShip2, TEAM_IMC )
	thread PlayAnim( gunshipAmbient2, "st_AngelCity_IMC_Win_Idle", posAmbientShip2, angAmbientShip2 )
	EmitSoundOnEntity( gunshipAmbient2, SFX_STRATTON2 )

	//------------------------------------------
	// Start dropship ride and prep ground intro
	//------------------------------------------
	thread IntroDropshipIMC()
	thread IntroIMCSpectresAssaultTown()

	//delaythread ( 1.25 ) ForcePlayConversationToTeam( "IntroDropshipIMC", TEAM_IMC )

	wait 6.5

	FlagSet( "StartIMCDropships" )


	//--------------------------------
	// Killing fields
	//--------------------------------
	//delaythread ( 3 ) IntroSkit( "spectreCorpsePatrolA", UniqueString(), Vector( 1234, 5999, -96 ), Vector( 0, 0, 0 ), TEAM_IMC, null, null, 0, IntroSpectreFieldsCleanup )
	delaythread ( 5 ) IntroSkit( "spectreCorpsePatrolB2", UniqueString(), Vector( 752.497, 6471.24, -125.89 ), Vector( 0, 180, 0 ), TEAM_IMC, null, null, 0, IntroSpectreFieldsCleanup )
	delaythread ( 5 ) IntroSkit( "spectreCorpsePatrolA", UniqueString(), Vector( 142, 6216, -116 ), Vector( 0, 0, 0 ), TEAM_IMC, null, null, 0, IntroSpectreFieldsCleanup )
	delaythread ( 5 ) IntroSkit( "spectreCorpsePatrolB2", UniqueString(), Vector( 493, 6558, -127 ), Vector( 0, 180, 0 ), TEAM_IMC, null, null, 0, IntroSpectreFieldsCleanup )
	delaythread ( 4 ) IntroSkit( "spectreCorpsePatrolB2", UniqueString(), Vector( -547, 6254, -117 ), Vector( 0, 180, 0 ), TEAM_IMC, null, null, 0, IntroSpectreFieldsCleanup )
	delaythread ( 6 ) IntroSkit( "spectreCorpsePatrolB", UniqueString(), Vector( -248, 6602, -136 ), Vector( 0, 0, 0 ), TEAM_IMC, null, null, 0, IntroSpectreFieldsCleanup )
	delaythread ( 6 ) IntroSkit( "spectreCorpsePatrolB2", UniqueString(), Vector( -732, 6622, -130 ), Vector( 0, 0, 0 ), TEAM_IMC, null, null, 0, IntroSpectreFieldsCleanup )
	//--------------------------------
	// Ground dialogue
	//--------------------------------
	delaythread ( 30 ) ForcePlayConversationToTeam( "IntroGroundIMCstart", TEAM_IMC )


	//--------------------------------
	// Ground sequences
	//--------------------------------
	delaythread ( 25 ) IntroSkit( "prisonerKill", "spectreIntroSquad5", Vector( -1160, 2680, 0 ), Vector( 0, 0, 0 ), TEAM_IMC, null, null, 0, IntroSpectreDefaultBehavior )

	thread IntroSkit( "prisonerMultiKill", "spectreIntroSquad5", Vector( -1242, 2541, 11 ), Vector( 0, -18.6667, 0 ), TEAM_IMC, null, "IntroIMCstartPrisonerKill", 0, IntroSpectreDefaultBehavior )

	thread IntroSkit( "bodyDisposal", "spectreIntroSquad5", Vector( -1072.5, 2336.5, 6 ), Vector( 0, 60, 0 ), TEAM_IMC, null, "IntroIMCstartBodyDisposal", 0, IntroSpectreDefaultBehavior )



	thread FlagSetDelayed( "IntroIMCGunshipTakesOff", 27 )
	thread FlagSetDelayed( "IntroIMCstartPrisonerKill", 40 )
	thread FlagSetDelayed( "IntroIMCstartBodyDisposal", 38 )


	wait 2
	local dest = Vector ( 639.5, 5922.5, 335.5 )
	gunshipAmbient1.MoveTo( dest, 7.5, 1, 1 )

	//thread IntroDropshipFlyawayIMC()


	FlagWait( "IntroDropshipDoneIMC" )


	gunshipAmbient1.Kill()
	gunshipAmbient2.Kill()
	//thread IntroSkit( "prisonerDragKill", "spectreIntroSquad5", Vector( -1304, 2328, 8 ), Vector( 0, 0, 0 ), TEAM_IMC, null, null, 0, IntroSpectreDefaultBehavior )

	FlagSet( "IntroDoneIMC" )

	wait 6


	IMCbrushBlocker.Kill()
	printt( "BRUSH DELETED" )
}

function FakeSpectreEyeGlow( spectre )
{
	//PlayFXOnEntity( FX_SPECTRE_EYE_GLOW, spectre, "EYEGLOW", null, Vector( 0, 0, 135 ) )

	local attach_id = spectre.LookupAttachment( "EYEGLOW" )
	local pos = spectre.GetAttachmentOrigin( attach_id )

	local env_sprite = CreateEntity( "env_sprite" )
	env_sprite.SetOrigin( PositionOffsetFromEnt( spectre, 4, 0, 75 ) )
	env_sprite.SetParent( spectre, "EYEGLOW", true )
	env_sprite.kv.rendermode = 9 //World glow, uses proxy size for visibility
	env_sprite.kv.rendercolor = "233 67 67 255"  //red
	env_sprite.kv.rendercolorFriendly = "67 87 233 255"	// blue
	env_sprite.SetTeam( TEAM_IMC )			// must set TEAM
	env_sprite.kv.model = "sprites/glow_05.vmt"
	env_sprite.kv.scale = "0.2"
	env_sprite.kv.GlowProxySize = 1.0
	env_sprite.kv.HDRColorScale = 15.0
	DispatchSpawn( env_sprite, false )
	spectre.s.eye_glow <- env_sprite

	spectre.EndSignal( "OnDestroy" )
	spectre.WaitSignal( "OnDeath" )
	spectre.s.eye_glow.Kill()

}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function IntroSpectreFieldsCleanup( spectre )
{
	if ( IsValid( spectre ) )
		spectre.Kill()

}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function IntroSpectreDefaultBehavior( spectre )
{
	if ( !IsAlive( spectre ) )
		return


	spectre.SetEfficientMode( false )
	//npc.Signal( "ShowTitle" )
	UpdateEnemyMemoryFromTeammates( spectre )
	//spectre.kv.alwaysalert = 1
	//spectre.kv.maxEnemyDist = 16000
	local rallyPoint = Random( level.spectreRallyPoints )

	//local enemy = spectre.GetEnemy()
	//if ( !enemy )
	spectre.AssaultPoint( rallyPoint.GetOrigin() )

}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function IntroIMCSpectresAssaultTown()
{
	local spectreSpawns = GetEntArrayByNameWildCard_Expensive( "spectreSpawnIMCintro*" )
	local spectreLeapEnts = GetEntArrayByNameWildCard_Expensive( "info_targetSpectreSpawn*" )
	//local spectreRackEnts = GetEntArrayByNameWildCard_Expensive( "spectreSpawnLabRackColony*" )

	Assert( spectreSpawns.len() == 8, "COLONY: Need 8 spectreSpawnIMCintro ents for IMC intro. Found " + spectreSpawns.len() )
	Assert( spectreLeapEnts.len() == 8, "COLONY: Need 8 spectre leap animEnts for IMC intro. Found " + spectreLeapEnts.len() )

	//--------------------------------
	// Racked Spectre Setup
	//--------------------------------
	//local spectreRackSpawners = []
	//foreach( spectreRackEnt in spectreRackEnts )
		//spectreRackSpawners.append( SpectreRackSetup( spectreRackEnt ) )

	local spectreRackRight = GetEnt( "spectrePaletteRight" )
	local spectreRackLeft = GetEnt( "spectrePaletteLeft" )
	spectreRackRight.NotSolid()
	spectreRackLeft.NotSolid()
	local spectreRackBehind = CreatePropDynamic( SPECTRE_PALETTE_MODEL, Vector( 0, 0, 0 ), Vector( 0, 0, 0 ) )

	MakeModelOnlyVisibleToTeam( spectreRackBehind, TEAM_IMC )
	MakeModelOnlyVisibleToTeam( spectreRackLeft, TEAM_IMC )

	delaythread ( 35 ) CreateSpectrePaletteLighting( spectreRackRight, false )



	local spectresRackBehind = SpectrePalettePopulate( spectreRackBehind, false )

	delaythread ( 28.5 ) ActivateFlybySpectreLights( spectresRackBehind )
	local spectreRackSpawners = SpectrePalettePopulate( spectreRackRight )
	ArrayAppend( spectreRackSpawners, SpectrePalettePopulate( spectreRackLeft ) )

	delaythread ( 4 ) IntroIMCShipDeliversSpectreRacks( spectreRackLeft )
	thread IntroIMCShipDeliversSpectreRacks( spectreRackBehind, true )

	wait 37

	//--------------------------------
	// Ground Spectres leap over wall into town
	//--------------------------------
	local spectre
	local animEnt
	local count = 1
	local squadName = "spectreIntroSquad1"

	foreach( spawn in spectreSpawns )
	{
		if ( count > 4 )
			squadName = "spectreIntroSquad2"
		spectre = Spawn_TrackedSpectre( TEAM_IMC, squadName, spawn.GetOrigin(), spawn.GetAngles() )
		animEnt = GetClosest( spectreLeapEnts, spectre.GetOrigin() )
		Assert( animEnt != null )
		thread IntroIMCSpectreAssaultTownThink( spectre, animEnt )
		ArrayRemove( spectreLeapEnts, animEnt )
		count++
	}

	wait 4.5

	local animPaletteHarness = "spectre_palette_harness_open"

	FlagWait( "PaletteOnGround" )
	//wait 10


	//if ( GetBugReproNum() == 666 )
	delaythread ( 0.1 ) PlayAnim( spectreRackLeft, animPaletteHarness, spectreRackLeft.GetOrigin(), spectreRackLeft.GetAngles() )
	delaythread ( 0.25 ) PlayAnim( spectreRackRight, animPaletteHarness )
	//--------------------------------
	// Racked Spectres spawn and go through front gate
	//--------------------------------
	ArrayRandomize( spectreRackSpawners )

	count = 1
	squadName = "spectreIntroSquad3"
	foreach( spawner in spectreRackSpawners )
	{
		if ( count > 4 )
				squadName = "spectreIntroSquad4"
		delaythread ( RandomFloat( 0.25, 1.8 ) ) SpawnRackedSpectre( spawner, TEAM_IMC, squadName )
	}

	MakeModelVisibleToEveryone( spectreRackLeft )
}

///////////////////////////////////////////////////////////////////////////////////////////////////
function ActivateFlybySpectreLights( spectres )
{

	foreach( spectre in spectres )
	{
		SpectreSetTeam( spectre, TEAM_IMC )
		EmitSoundOnEntity( spectre, SFX_SPECTRE_LIGHT_ACTIVATE )
		thread FakeSpectreEyeGlow( spectre )
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
function SpectrePalettePopulate( palette, frontSide = true )
{
	local spawnTags = []

	if ( frontSide )
	{
		spawnTags.append( "spectre_1" )
		spawnTags.append( "spectre_2" )
		spawnTags.append( "spectre_3" )
	}
	else
	{
		spawnTags.append( "spectre_4" )
		spawnTags.append( "spectre_5" )
		spawnTags.append( "spectre_6" )
	}

	local spawnerModels = []
	local spawner

	foreach( spawnTag in spawnTags )
	{
		spawner = SpectreRackSetup( palette, spawnTag )
		spawnerModels.append( spawner )
	}

	return spawnerModels
}

///////////////////////////////////////////////////////////////////////////////////////////////////
function SpectreRackSetup( palette, spawnTag )
{
	local attachID = palette.LookupAttachment( spawnTag )
	local pos = palette.GetAttachmentOrigin( attachID )
	local ang = palette.GetAttachmentAngles( attachID )

	local spawnerModel = CreatePropDynamic( IMC_SPECTRE_MODEL, pos, ang, 8 )
	spawnerModel.SetName( "spectreDroneRackSpawner" )
	spawnerModel.s.animEnt <- palette
	spawnerModel.s.animTag <- spawnTag


//	spawnerModel.Anim_ScriptedPlay( "sp_med_bay_dropidle_A" )
//	spawnerModel.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()

	spawnerModel.SetParent( palette, spawnTag )
	spawnerModel.MarkAsNonMovingAttachment()
	thread PlayAnim( spawnerModel, "sp_med_bay_dropidle_A", palette, spawnTag )

	return spawnerModel
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
function IntroIMCShipDeliversSpectreRacks( palette, flyby = false )
{

	local animEnt = GetEnt( "animNodeIMCGunshipSpectres" )
	Assert( animEnt != null )


	local pos = animEnt.GetOrigin() //+ Vector( 0, 0, -400 )
	local ang = animEnt.GetAngles() //+ Vector( 0, 150, 0 )
	local gunship = GunshipSpawn( pos, ang, TEAM_IMC )


	local ropeEnds = GunshipRopes( gunship, palette )

	gunship.EndSignal( "OnDeath" )

	local animPalette = "spectre_palette_colony_imc_intro"
	local animGunship =	"gunship_colony_imc_intro"

	if ( flyby )
	{
		EmitSoundOnEntity( gunship, SFX_STRATTON3 )
		FlagWait( "StartIMCDropships" )
		animPalette = "spectre_palette_B_colony_imc_intro"
		animGunship = "gunship_B_colony_imc_intro"
	}
	else
	{
		EmitSoundOnEntity( gunship, SFX_STRATTON4 )
		//local anim = "st_AngelCity_IMC_Win_Idle"
		local animLoop = "gunship_colony_imc_intro_hover_loop"
		local animDuration = gunship.GetSequenceDuration( animLoop )
	}

	//---------------------------------------------
	// Lights switch on
	//----------------------------------------------
	local paletteLightDelay = 32
	if ( flyby )
		paletteLightDelay = 21.3

	delaythread ( paletteLightDelay ) CreateSpectrePaletteLighting( palette, flyby )

	//---------------------------------------------
	// Gunship and palette fly into position
	//----------------------------------------------
	thread PlayAnimTeleport( gunship, animGunship, pos, ang )
	waitthread PlayAnimTeleport( palette, animPalette, pos, ang )

	if ( !flyby )
		FlagSet( "PaletteOnGround" )
	//---------------------------------------------
	// If it's the fly-by one, just delete
	//----------------------------------------------
	if ( flyby )
	{
		DeleteIfValid( gunship )
		DeleteIfValid( palette )
		return
	}


	//---------------------------------------------
	// Ropes detach on a delay as player approaches
	//----------------------------------------------
	thread GunshipRopesDetach( ropeEnds )

	//--------------------------------
	// Idle until we tell ship to leave
	//--------------------------------
	thread PlayAnim( gunship, "gunship_colony_imc_intro_hover_loop", pos, ang )
	while ( !Flag( "IntroIMCGunshipTakesOff" ) )
		wait animDuration

	//--------------------------------
	// Ship takes off
	//--------------------------------
	waitthread PlayAnim( gunship, "gunship_colony_imc_intro_flyaway", pos, ang )

	gunship.Kill()
}

///////////////////////////////////////////////////////////////////////////////////////////////////
function CreateSpectrePaletteLighting( palette, flyby = false, sound = true )
{
	local players = GetPlayerArrayOfTeam( TEAM_IMC )
	local eHandle = palette.GetEncodedEHandle()
	foreach( player in players )
	{
		if ( !IsAlive( player ) )
			continue

		Remote.CallFunction_Replay( player, "ServerCallback_CreateSpectrePaletteLighting", eHandle, flyby, sound ) //tell client to switch on lights
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////////
function GunshipRopesDetach( ropeEnds )
{
	foreach( endpoint in ropeEnds )
	{
		//endpoint.ClearParent()
		EmitSoundAtPosition( endpoint.GetOrigin(), SFX_GUNSHIP_WIRE_SNAP )
		endpoint.Fire( "Break" )
		wait RandomFloat( 0.1, 0.3 )
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
function GunshipSpawn( origin, angles, team )
{
	local gunship = CreateEntity( "npc_dropship" )
	//hornet.kv.spawnflags = 0
	gunship.kv.teamnumber = TEAM_MILITIA

	local model = HORNET_MODEL
	gunship.kv.vehiclescript = "scripts/vehicles/airvehicle_default.txt"
	if ( team == TEAM_IMC )
	{
		model = STRATON_MODEL
		gunship.kv.vehiclescript = "scripts/vehicles/straton.txt"
	}
	gunship.SetSkin( 1 )
	gunship.SetTeam( TEAM_IMC )
	gunship.SetModel( model )
	gunship.SetOrigin( origin )
	gunship.SetAngles( angles )
	DispatchSpawn( gunship, true )

	gunship.SetHealth( 500 )
	gunship.SetMaxHealth( 500 )

	gunship.EnableRenderAlways()
	gunship.SetAimAssistAllowed( false )

	local fxSpotlight = PlayLoopFXOnEntity( FX_GUNSHIP_SPOTLIGHT, gunship, "Spotlight", null, gunship.GetAngles() + Vector( 75, -90, 0 ) )		// Vector( 180, 90, 25 )
	fxSpotlight.SetTeam( TEAM_IMC )
	fxSpotlight.kv.VisibilityFlags = 2 // Only team members can see it
	gunship.kv.VisibilityFlags = 2 // Only team members can see it

	gunship.SetJetWakeFXEnabled( false )
	return gunship
}

////////////////////////////////////////////////////////////////////////////
function GunshipRopes( gunship, palette )
{
	gunship.EndSignal( "OnDeath" )

	local ropeEnds = []
	local ropeEndpoint
	local attachTag
	local attachPos
	for( local i = 1; i < 5; i++ )
	{
		attachTag = "corner_" + i
		attachPos = palette.GetAttachmentOrigin( palette.LookupAttachment( attachTag ) )
		ropeEndpoint = CreateCargoRope( gunship, attachPos )
		ropeEndpoint.SetParent( palette, attachTag )
		ropeEnds.append( ropeEndpoint )
	}

	return ropeEnds
}

function CreateCargoRope( gunship, attachPos )
{
	local subdivisions = 8 // 25
	local slack = 200 // 25
	local startpointName = UniqueString( "rope_startpoint" )
	local endpointName = UniqueString( "rope_endpoint" )

	local attach_id = gunship.LookupAttachment( "ORIGIN" )
	local attachPos = gunship.GetAttachmentOrigin( attach_id )

	local rope_start  = CreateEntity( "move_rope" )
	rope_start.SetName( startpointName )
	rope_start.kv.NextKey = endpointName
	rope_start.kv.MoveSpeed = 64
	rope_start.kv.Slack = slack
	rope_start.kv.Subdiv = subdivisions
	rope_start.kv.Width = "2"
	rope_start.kv.TextureScale = "1"
	rope_start.kv.RopeMaterial = "cable/cable.vmt"
	rope_start.kv.PositionInterpolator = 2
	rope_start.SetOrigin( attachPos )
	rope_start.SetParent( gunship, "ORIGIN" )

	local rope_end = CreateEntity( "keyframe_rope" )
	rope_end.SetName( endpointName )
	rope_end.kv.MoveSpeed = 64
	rope_end.kv.Slack = slack
	rope_end.kv.Subdiv = subdivisions
	rope_end.kv.Width = "2"
	rope_end.kv.TextureScale = "1"
	rope_end.kv.RopeMaterial = "cable/cable.vmt"
	rope_end.SetOrigin( attachPos )

	DispatchSpawn( rope_start )
	DispatchSpawn( rope_end   )

	return rope_end

}



///////////////////////////////////////////////////////////////////////////////////////////////////
function SpawnRackedSpectre( spawner, team, squadName )
{
	local spectre =	Spawn_TrackedSpectre( team, squadName, spawner.s.animEnt.GetOrigin(), Vector( 0, 0, 0 ), true, null, true )// <---hidden when spawned
	MakeInvincible( spectre )
	thread PlayAnimTeleport( spectre, "sp_med_bay_dropidle_A", spawner.s.animEnt, spawner.s.animTag )
	local weapon = spectre.GetActiveWeapon()
	spectre.TakeActiveWeapon()	//need to hide weapon or we'll see a pop
	local weapon = weapon.GetClassname()

	spectre.EndSignal( "OnDeath" )
	spectre.EndSignal( "OnDestroy" )

	wait 0.1
	spawner.Hide()
	spectre.Show()
	spectre.GiveWeapon( weapon )
	spectre.SetActiveWeapon( weapon )
	spectre.Anim_Stop()
	EmitSoundAtPosition( spectre.GetOrigin() + Vector( 0, 0, 72), SFX_SPECTRE_LIGHT_ACTIVATE )
	EmitSoundAtPosition( spectre.GetOrigin() + Vector( 0, 0, 72), SFX_SPECTRE_RACK_ACTIVATE )
	waitthread PlayAnim( spectre, "sp_med_bay_drop_armed", spawner.s.animEnt, spawner.s.animTag )
	ClearInvincible( spectre )
	spawner.Kill()

	thread IntroSpectreDefaultBehavior( spectre )
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
function IntroIMCSpectreAssaultTownThink( spectre, animEnt )
{
	spectre.EndSignal( "OnDeath" )

	Assert( animEnt.HasKey( "anim" ), "COLONY: info_target at " + animEnt.GetOrigin() + "has no 'anim' key value set" )
	local anim = animEnt.Get( "anim" )

	//MakeInvincible( spectre )
	//FlagWait( "IntroDropshipDoneIMC" )

	local animStartPos = SpectreLeapGetStartPosAndAdjustNode( spectre, anim, animEnt )

	waitthread RunToAnimStartForced( spectre, anim, animEnt )

	waitthread PlaySpectreLeap( spectre, animEnt, false )

	thread IntroSpectreDefaultBehavior( spectre )
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
function SpectreLeapGetStartPosAndAdjustNode( spectre, anim, animEnt )
{
	local animStartPos = spectre.Anim_GetStartForRefPoint( anim, animEnt.GetOrigin(), animEnt.GetAngles() )
	if ( ( anim == "sp_traverse_across_1024_up_256" ) || ( anim == "sp_traverse_across_512_up_128" ) )
	{
		// Some traverse anims have the ref at the end position, but I want to use them in scripted sequences
		local adjustedAnimPos = HackGetDeltaToRef( animEnt.GetOrigin(), animEnt.GetAngles(), spectre, anim )
		animEnt.SetOrigin( adjustedAnimPos )
	}

	return animStartPos
}


/////////////////////////////////////////////////////////////////////////////////////////////////////
function PlaySpectreLeap( spectre, animEnt, adjustStartPos = true )
{
	spectre.EndSignal( "OnDeath" )

	Assert( animEnt.HasKey( "anim" ), "COLONY: info_target at " + animEnt.GetOrigin() + "has no 'anim' key value set" )
	local anim = animEnt.Get( "anim" )

	if ( adjustStartPos )
		local animStartPos = SpectreLeapGetStartPosAndAdjustNode( spectre, anim, animEnt )

	//thread DrawLineEntToPos( spectre, animStartPos.origin )
	waitthread PlayAnim( spectre, anim, animEnt )
}

/*----------------------------------------------------------------------------------
/
/				INTRO - MILITIA
/
/-----------------------------------------------------------------------------------*/
function AA_INTRO_MILITIA_Functions()
{
	//Bookmark to jump to this section
}

///////////////////////////////////////////////////////////////////////////////////////////////////
function IntroMilitia()
{

	local spectreLeapEnts = GetEntArrayByNameWildCard_Expensive( "info_targetMilitiaSpectreSpawn*" )

	thread IntroDropshipMilitia()
	thread IntroMilitiaSpectreAttack()

	//thread ForcePlayConversationToTeam( "IntroDropshipMilitia", TEAM_MILITIA )

	wait 6.5

	FlagSet( "StartMilitiaDropships" )

	thread IntroSkit( "CQBscan01", "gruntIntroSquad1", Vector( 1152, -1796, 248 ), Vector( 0, 90, 0 ), TEAM_MILITIA, Vector( 1352, -1411, 247 ), "SpectreThroatSlit", 0, IntroGruntDefaultBehavior )

	wait 18

	//thread IntroWalker( "search_walk_leadA", "gruntIntroSquad1", TEAM_MILITIA, Vector( 1552, -2016, 256 ), Vector( -416, -1328, 184 ), IntroGruntDefaultBehavior )
	//thread IntroWalker( "search_walk", "gruntIntroSquad1", TEAM_MILITIA, Vector( 1304, -2120, 256 ), Vector( -208, -1608, 200 ), IntroGruntDefaultBehavior )

	thread IntroWalker( "search_walk_leadA", "gruntIntroSquad1", TEAM_MILITIA, Vector( 1552, -2016, 256 ), Vector( -206, -2124, 208.761 ), IntroGruntDefaultBehavior )
	thread IntroWalker( "search_walk", "gruntIntroSquad1", TEAM_MILITIA, Vector( 1304, -2120, 256 ), Vector( -206, -2124, 208.761 ), IntroGruntDefaultBehavior )

	wait 6

	FlagSet( "StartMilitiaSpectreAttack" )

	thread IntroDropshipFlyawayMilitia()

	wait 4

	ForcePlayConversationToTeam( "IntroGroundMilitiaMoveUp", TEAM_MILITIA )


	//wait 4

	//FlagWait( "IntroDropshipDoneMilitia" )

	FlagWait( "MilitiaSoldierWaves" )

	//Grunt 1	Hey! I've got a live one here!
	EmitSoundOnEntity (level.MilitiaIntroVictim, "diag_matchIntro_CY103_02_01_mcor_grunt1" )

	FlagSetDelayed( "SpectreThroatSlit", 5 )	//another failsafe to ensure flag is set regardless
	FlagWait( "SpectreThroatSlit" )

	wait 0.5

	ForcePlayConversationToTeam( "IntroGroundMilitiaFightStart", TEAM_MILITIA )

	delaythread ( 0.5 ) IntroMilitiaSpectreLeapers( spectreLeapEnts )

	wait 17


	FlagSet( "IntroDoneMilitia" )

}
///////////////////////////////////////////////////////////////////////////////////////////////////
function IntroDropshipFlyawayMilitia()
{
	if ( ! ( "introDropshipsIMC" in level ) )
		return

	FlagWait( "GamePlaying" )
	foreach( dropship in level.introDropshipsMilitia )
	{
		if ( IsValid( dropship ) )
			EmitSoundOnEntity( dropship, SFX_FLYAWAY_DROPSHIP_MILITIA )
	}
}
///////////////////////////////////////////////////////////////////////////////////////////////////
function IntroDropshipFlyawayIMC()
{
	FlagWait( "GamePlaying" )

	if ( ! ( "introDropshipsIMC" in level ) )
		return
	foreach( dropship in level.introDropshipsIMC )
	{
		if ( IsValid( dropship ) )
			EmitSoundOnEntity( dropship, SFX_FLYAWAY_DROPSHIP_IMC )
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
function IntroMilitiaSpectreLeapers( spectreLeapEnts )
{
	foreach( ent in spectreLeapEnts )
	{
		thread IntroMilitiaLeaper( ent )
		wait 0.75
	}
}
///////////////////////////////////////////////////////////////////////////////////////////////////
function IntroMilitiaLeaper( spawnEnt )
{
	local spectre = Spawn_TrackedSpectre( TEAM_IMC, "spectreIntroSquad5", spawnEnt.GetOrigin(), spawnEnt.GetAngles() )

	spectre.SetHealth( 50 )
	spectre.SetMaxHealth( 50 )
	spectre.EndSignal( "OnDeath" )

	OnThreadEnd
	(
		function() : ( spectre )
		{
			thread IntroSpectreDefaultBehavior( spectre )
		}
	)

	waitthread PlaySpectreLeap( spectre, spawnEnt )
}

///////////////////////////////////////////////////////////////////////////////////////////////////
function IntroGruntDefaultBehavior( grunt )
{
	if ( !IsAlive( grunt ) )
		return


	UpdateEnemyMemoryFromTeammates( grunt )

}

///////////////////////////////////////////////////////////////////////////////////////////////////
function IntroMilitiaSpectreAttack()
{
	local animNode = GetEnt( "animNodeMilitiaIntro" )

	local pos = animNode.GetOrigin() + Vector( 0, 0, 5 )
	local ang = animNode.GetAngles()
	Assert( animNode != null )

	local grunt = SpawnGrunt( TEAM_MILITIA, UniqueString(), pos, ang )
	local civilian = CreatePropDynamic( CIVILIAN_MODEL_01, pos, ang )
	local spectre = SpawnSpectre( TEAM_IMC, UniqueString(), pos, ang, true, null, true ) //<== spawn spectre hidden
	AddAnimEvent( spectre, "kills_grunt", SpectreThroatSlit )
	AddAnimEvent( grunt, "grunt_waves", MilitiaSoldierWaves )

	local spectreWeapon = spectre.GetActiveWeapon()
	spectreWeapon.Hide()

	thread PlaySequenceOnFlag( grunt, pos, ang, "pt_colony_intro_ambush_kill_sol1_idle", "pt_colony_intro_ambush_kill_sol1", "StartMilitiaSpectreAttack", spectre, null, null, true )
	thread PlaySequenceOnFlag( civilian, pos, ang, "pt_colony_intro_ambush_kill_sol2_idle", "pt_colony_intro_ambush_kill_sol2", "StartMilitiaSpectreAttack" )
	thread PlaySequenceOnFlag( spectre, pos, ang, "sp_colony_intro_ambush_kill_idle", "sp_colony_intro_ambush_kill", "StartMilitiaSpectreAttack", grunt, null, "SpectreThroatSlit" )

	level.MilitiaIntroVictim <- grunt

	FlagWait( "MilitiaSoldierWaves" )

	spectre.Show()
	spectreWeapon.Show()
}

function SpectreThroatSlit( spectre )
{
	level.bloodsmear.Show()

	FlagSet( "SpectreThroatSlit" )
}

function MilitiaSoldierWaves( grunt )
{
	FlagSet( "MilitiaSoldierWaves" )
}

/*----------------------------------------------------------------------------------
/
/				EVAC/EPILOGUE
/
/-----------------------------------------------------------------------------------*/
function AA_EVAC_Functions()
{
	//Bookmark to jump to this section
}

///////////////////////////////////////////////////////////////////////////////////////////
function EvacSetup()
{
	//-------------------------
	// Evac locations
	//-------------------------

	Evac_AddLocation( "evac01", Vector( -475.129913, 1480.167847, 527.363953 ), Vector( 8.841560, 219.338501, 0 ) )
	Evac_AddLocation( "evac2", Vector( 1009.315186, 3999.888916, 589.914917 ), Vector( 22.109896, -40.449619, 0 ) )
	Evac_AddLocation( "evac3", Vector( 2282.868896, -1363.706543, 846.188660 ), Vector( 23.945116, -146.680725, -0.000000 ) )
	Evac_AddLocation( "evac4", Vector( 1911.771606, -752.053101, 664.741821), Vector( 9.955260, 138.721191, 0.000000 ) )
	Evac_AddLocation( "evac5", Vector( 1985.563232, -1205.455078, 677.444763 ), Vector( 13.809734, -239.877441, 0.000000 ) )
	Evac_AddLocation( "evac6", Vector( -59.625496, -1858.108887, 811.592407 ), Vector( 20.556290, -252.775146, 0.000000 ) )
	Evac_AddLocation( "evac7", Vector( -1035.991211, -671.114380, 824.180908 ), Vector( 16.220453, -24.511070, 0.000000 ) )

	local spacenode = GetEnt( "intro_spacenode" )
	Assert( spacenode != null )

	Evac_SetSpaceNode( spacenode )


	//----------------------------------------------
	// Evac custom dialogue
	//----------------------------------------------
	Evac_SetupDefaultVDUs()

	if ( level.playCinematicContent )
	{
		//Evac_SetVDULosersEvacPostEvac( TEAM_IMC, "ColonyEpilogueStoryEnd" )
		//Evac_SetVDULosersEvacPostPursuit( TEAM_IMC, "ColonyEpilogueStoryEnd" )
		//Evac_SetVDULosersEvacPostEvac( TEAM_MILITIA, "ColonyEpilogueStoryEnd" )
		//Evac_SetVDULosersEvacPostPursuit( TEAM_MILITIA, "ColonyEpilogueStoryEnd" )
	}

}

function EndRoundMain()
{
	if ( EvacEnabled() )
		GM_SetObserverFunc( EvacObserverFunc )

	if ( level.playCinematicContent )
		delaythread ( 10 ) DialogueEpilogueStory()
}


function DialogueEpilogueStory()
{
	SetGlobalForcedDialogueOnly( true )

	ForcePlayConversationToAll( "ColonyEpilogueStory" )

	wait 40

	SetGlobalForcedDialogueOnly( false )
}

function EvacObserverFunc( player )
{
	player.SetObserverModeStaticPosition( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorPos )
	player.SetObserverModeStaticAngles( level.ExtractLocations[ level.SelectedExtractLocationIndex ].spectatorAng )

	player.StartObserverMode( OBS_MODE_CHASE )
	player.SetObserverTarget( null )
}


/*----------------------------------------------------------------------------------
/
/				INTRO DROPSHIPS
/
/-----------------------------------------------------------------------------------*/
function AA_DROPSHIP_Functions()
{
	//Bookmark to jump to this section
}


///////////////////////////////////////////////////////////////////////////////////////////////////
function IntroDropshipMilitiaSetup()
{
	level.introDropshipsMilitia <- []

	local animEnt1 = GetEnt( "animNodeMilitiaFlyin1" )

	local table				= CreateCinematicDropship()
	table.origin 			= animEnt1.GetOrigin()
	table.team				= TEAM_MILITIA
	table.count 			= 4
	table.side 				= "jumpSideR"
	table.turret			= false

	local event0			= CreateCinematicEvent()
	event0.origin 			= animEnt1.GetOrigin()
	event0.angles			= animEnt1.GetAngles()
	event0.anim				= "dropship_colony_mcor_intro_idle"
	event0.teleport 		= true
	Event_AddFlagWaitToEnd( event0, "StartMilitiaDropships" )
	Event_AddServerStateFunc( event0, CE_PlayerSkyScaleMCOR )
	Event_AddClientStateFunc( event0, "CE_VisualSettingColonyMCOR" )

	local event1			= CreateCinematicEvent()
	event1.origin 			= animEnt1.GetOrigin() //+ Vector( 0, 700 ,0 )
	event1.angles			= animEnt1.GetAngles()
	event1.anim				= "dropship_colony_mcor_intro"
	Event_AddFlagSetOnEnd( event1, "IntroDropshipDoneMilitia" )
	Event_AddAnimStartFunc( event1, IntroDialogueMilitia )
	Event_AddAnimStartFunc( event1, IntroMilitiaHeroes )

	local event2 			= CreateCinematicEvent()
	event2.origin 			= animEnt1.GetOrigin() //+ Vector( 0, 700, 0 )
	event2.angles			= animEnt1.GetAngles()
	event2.anim				= "dropship_colony_mcor_flyaway"

	AddSavedDropEvent( "introDropShipMCOR_1cr", table )
	AddSavedDropEvent( "introDropShipMCOR_1e0", event0 )
	AddSavedDropEvent( "introDropShipMCOR_1e1", event1 )
	AddSavedDropEvent( "introDropShipMCOR_1e2", event2 )

	local animEnt2 = animEnt1

	//local posOffset = Vector( 0, -375, 0 )
	//local angOffset = Vector( 0, 14, 0 )
	//local animEnt2 = CreateScriptRef( animEnt1.GetOrigin() + posOffset, animEnt1.GetAngles() + angOffset )

	local table				= CreateCinematicDropship()
	table.origin 			= animEnt2.GetOrigin()
	table.team				= TEAM_MILITIA
	table.count 			= 4
	table.side 				= "jumpSideR"
	table.turret			= false

	local event0			= CreateCinematicEvent()
	event0.origin 			= animEnt2.GetOrigin()
	event0.angles			= animEnt2.GetAngles()
	event0.anim				= "dropship_B_colony_mcor_intro_idle"
	event0.teleport 		= true
	Event_AddFlagWaitToEnd( event0, "StartMilitiaDropships" )
	Event_AddServerStateFunc( event0, CE_PlayerSkyScaleMCOR )
	Event_AddClientStateFunc( event0, "CE_VisualSettingColonyMCOR" )

	local event1 			= CreateCinematicEvent()
	event1.origin 			= animEnt2.GetOrigin()
	event1.angles			= animEnt2.GetAngles()
	event1.anim				= "dropship_B_colony_mcor_intro"
	Event_AddAnimStartFunc( event1, IntroDialogueMilitia )
	Event_AddAnimStartFunc( event1, IntroMilitiaHeroes )

	local event2 			= CreateCinematicEvent()
	event2.origin 			= animEnt2.GetOrigin()
	event2.angles			= animEnt2.GetAngles()
	event2.anim				= "dropship_B_colony_mcor_flyaway"

	AddSavedDropEvent( "introDropShipMCOR_2cr", table )
	AddSavedDropEvent( "introDropShipMCOR_2e0", event0 )
	AddSavedDropEvent( "introDropShipMCOR_2e1", event1 )
	AddSavedDropEvent( "introDropShipMCOR_2e2", event2 )
}

function IntroDropshipMilitia()
{
	local table 	= GetSavedDropEvent( "introDropShipMCOR_1cr" )
	local event0 	= GetSavedDropEvent( "introDropShipMCOR_1e0" )
	local event1 	= GetSavedDropEvent( "introDropShipMCOR_1e1" )
	local event2 	= GetSavedDropEvent( "introDropShipMCOR_1e2" )

	local dropship1 = SpawnCinematicDropship( table )
	dropship1.NotSolid()
	level.introDropshipsMilitia.append( dropship1 )
	thread RunCinematicDropship( dropship1, event0, event1, event2 )
	delaythread ( 1.5 ) IntroScreenDialogueMilitia( dropship1 )

	local table 	= GetSavedDropEvent( "introDropShipMCOR_2cr" )
	local event0 	= GetSavedDropEvent( "introDropShipMCOR_2e0" )
	local event1 	= GetSavedDropEvent( "introDropShipMCOR_2e1" )
	local event2 	= GetSavedDropEvent( "introDropShipMCOR_2e2" )

	local dropship2	= SpawnCinematicDropship( table )
	level.introDropshipsMilitia.append( dropship2 )
	thread RunCinematicDropship( dropship2, event0, event1, event2 )
	delaythread ( 0.5 ) IntroScreenDialogueMilitia( dropship2 )

	dropship1.NotSolid()
	dropship2.NotSolid()

	dropship1.SetJetWakeFXEnabled( false )
	dropship2.SetJetWakeFXEnabled( false )


	//dropship2.kv.disableshadows = 1
	//dropship2.kv.disableshadowdepth = 1
	//dropship2.kv.disableflashlight = 1
	//dropship2.kv.disablereceiveshadows = 1

	IntroMilitiaExperience( dropship1 )
	IntroMilitiaExperience( dropship2 )

	DebugSkipCinematicSlotsWithBugRepro( TEAM_MILITIA )
	//DebugSkipCinematicSlots( TEAM_MILITIA, 4 )
	//0 - back
	//1 - back middle
	//2 - front middle
	//3 - front

	dropship1.kv.VisibilityFlags = 2 // Only team members can see it
	dropship2.kv.VisibilityFlags = 2 // Only team members can see it
}

function CE_PlayerSkyScaleMCOR( player, ref )
{
	player.LerpSkyScale( SKYSCALE_COLONY_MCOR_PLAYER, 0.01 )
}

function IntroMilitiaHeroes( dropship, ref, table )
{
	local pos = dropship.GetOrigin()
	local ang = dropship.GetAngles()

	local pilot = CreatePropDynamic( TEAM_MILITIA_GRUNT_MDL )
	local sarah = CreatePropDynamic( SARAH_MODEL )

	pilot.SetParent( dropship, "ORIGIN" )
	sarah.SetParent( dropship, "RESCUE" )
	pilot.MarkAsNonMovingAttachment()
	sarah.MarkAsNonMovingAttachment()


	pilot.LerpSkyScale( SKYSCALE_COLONY_MCOR_ACTOR, 0.01 )
	sarah.LerpSkyScale( SKYSCALE_COLONY_MCOR_ACTOR, 0.01 )

	thread PlayAnimTeleport( pilot, "Militia_flyinA_idle_mac", dropship, "ORIGIN" )
	thread PlayAnimTeleport( sarah, "colony_militia_intro_sarah", dropship, "RESCUE" )
}

function IntroIMCHeroes( dropship, ref, table )
{

	local pos = dropship.GetOrigin()
	local ang = dropship.GetAngles()

	local blisk = CreatePropDynamic( BLISK_MODEL )
	local knife = CreatePropDynamic( KNIFE_MODEL )
	local pilot = CreatePropDynamic( TEAM_IMC_GRUNT_MDL )

	pilot.SetParent( dropship, "ORIGIN" )
	blisk.SetParent( dropship, "ORIGIN" )
	knife.SetParent( blisk, "R_HAND_alt" )

	pilot.MarkAsNonMovingAttachment()
	blisk.MarkAsNonMovingAttachment()
	knife.MarkAsNonMovingAttachment()

	pilot.LerpSkyScale( SKYSCALE_COLONY_IMC_ACTOR, 0.01 )
	blisk.LerpSkyScale( SKYSCALE_COLONY_IMC_ACTOR, 0.01 )
	knife.LerpSkyScale( SKYSCALE_COLONY_IMC_ACTOR, 0.01 )

	thread PlayAnimTeleport( pilot, "Militia_flyinA_idle_mac", dropship, "ORIGIN" )
	thread PlayAnimTeleport( blisk, "colony_imc_intro_blisk", dropship, "ORIGIN" )
}

///////////////////////////////////////////////////////////////////////////////////////////////////
function IntroScreenDialogueIMC( dropship )
{
	//PlaySoundToAttachedPlayers( dropship, SFX_CIVILIAN_SCREAMS )
}

///////////////////////////////////////////////////////////////////////////////////////////////////
//function IntroDialogueIMC( dropship, ref, table )
//{
//	wait 2
//
//	//Graves	Wiping out this second-rate terrorist camp was barely a test.
//	// Fighting veteran Pilots is a whole other story, Blisk.
//	PlaySoundToAttachedPlayers( dropship, "diag_matchIntro_CY102_02_01_imc_graves" )
//
//	wait 6.5
//
//	//Blisk 	Good. That’s why they keep us around, eh?
//	PlaySoundToAttachedPlayers( dropship, "diag_matchIntro_CY102_02a_01_imc_blisk" )
//
//	wait 3
//
//
//	//Pilot Radio	Sir! It looks like Militia ships! They’re deploying ground forces at the north end of the village.
//	PlaySoundToAttachedPlayers( dropship, "diag_matchIntro_CY102_03_01_imc_tpilot1" )
//
//	wait 5
//
//	//Blisk	Now that’s a real threat. Perhaps it’s time to start Phase Two.
//	PlaySoundToAttachedPlayers( dropship, "diag_matchIntro_CY102_04_01_imc_blisk" )
//
//	wait 4
//
//	//Graves	Agreed. Activate 3 more racks of Spectres - let’s see how they do in a real fight.
//	PlaySoundToAttachedPlayers( dropship, "diag_matchIntro_CY102_05_01_imc_graves" )
//
//	wait 5
//
//	//Blisk	Yes sir. Deploying additional Spectres at the south gate.
//	PlaySoundToAttachedPlayers( dropship, "diag_matchIntro_CY102_06_01_imc_blisk" )
//
//
//}
///////////////////////////////////////////////////////////////////////////////////////////////////
function IntroScreenDialogueMilitia( dropship )
{
	//Sarah - Bish, start playback
	PlaySoundToAttachedPlayers( dropship, "diag_matchIntro_CY101a_01_01_mcor_sarah" )

	wait 1

	//Radio (start with SOS beeps, then dialogue with fighting noises in background and Spectre sounds)
	//(beep) Mayday mayday, we are a small (garble garble) colony on planet Troy.
	//(garble garble) under attack from IMC forces (garble garble) need immediate assistance.
	//Please send help. Embedding coordinates.” (repeats 1.5x before being switched off with a ‘click’)
	PlaySoundToAttachedPlayers( dropship, "diag_matchIntro_CY101_01_01_mcor_civi1" )
}

///////////////////////////////////////////////////////////////////////////////////////////////////
function IntroDialogueMilitia( dropship, ref, table )
{

	wait 9

	//Bish	That distress call was four hours old.
	// Ok…first squad on the ground, they have eyes on the distress signal coordinates.
	PlaySoundToAttachedPlayers( dropship, "diag_matchIntro_CY101_02_01_mcor_bish" )

	/*

	//The rest is in Satrah's QC now for lip sync
	wait 6.5

	//Sarah	What do you see 3-2? Anything by the tower?
	PlaySoundToAttachedPlayers( dropship, "diag_matchIntro_CY101_03_01_mcor_sarah" )

	wait 3

	//Grunt	(radio) Nothing. The tower looks abandoned. We got dead colonists in the streets. No sign of the others.
	PlaySoundToAttachedPlayers( dropship, "diag_matchIntro_CY101_04_01_mcor_grunt1" )

	wait 4.75

	//Sarah	Got it. Pilots, let’s find out what the hell happened here. Fan out through the village and we’ll meet up at the south gate. Be careful down there.
	PlaySoundToAttachedPlayers( dropship, "diag_matchIntro_CY101_05_01_mcor_sarah" )


	*/
}
///////////////////////////////////////////////////////////////////////////////////////////////////
function IntroIMCExperience( dropship )
{
	thread IntroSharedExperience( dropship )
	PlaySoundToAttachedPlayers( dropship, SFX_DROPSHIP_PLAYER_ENGINE_IMC )
}

///////////////////////////////////////////////////////////////////////////////////////////////////
function IntroMilitiaExperience( dropship )
{

	thread IntroSharedExperience( dropship )

	PlaySoundToAttachedPlayers( dropship, SFX_DROPSHIP_PLAYER_ENGINE_MILITIA )

}

///////////////////////////////////////////////////////////////////////////////////////////////////
function IntroSharedExperience( dropship )
{

	//--------------------
	// Rain ambient SFX
	//--------------------
	PlaySoundToAttachedPlayers( dropship, "AMB_Colony_EXT_LightRainLayer" )

	wait 15
	PlaySoundToAttachedPlayers( dropship, "Colony_DistantThunder_IntroBeat1" )
	wait 15

	FadeSoundOnAttachedPlayers( dropship, "AMB_Colony_EXT_LightRainLayer" )
	PlaySoundToAttachedPlayers( dropship, "Colony_DistantThunder_IntroBeat2" )

	FlagWait( "IntroDropshipDoneMilitia" )

	level.nv.ClientTiming = -1	//tells the client that the ride is over
}


///////////////////////////////////////////////////////////////////////////////////////////////////
function IntroDropshipIMCSetup()
{
	SetAllViewConeSideRightNoHero()

	//local animEnt1 = CreateScriptRef( Vector( -1320, 2632, 592 ), Vector( 0, -45, 0 ) )
	local animEnt1 = GetEnt( "animNodeIMCFlyin1" )

	level.introDropshipsIMC <- []

	local table				= CreateCinematicDropship()
	table.origin 			= animEnt1.GetOrigin()
	table.team				= TEAM_IMC
	table.count 			= 4
	table.side 				= "jumpSideR"
	table.turret			= false

	local event0			= CreateCinematicEvent()
	event0.origin 			= animEnt1.GetOrigin()
	event0.angles			= animEnt1.GetAngles()
	event0.anim				= "dropship_colony_imc_intro_idle"
	event0.teleport 		= true
	Event_AddFlagWaitToEnd( event0, "StartIMCDropships" )
	Event_AddServerStateFunc( event0, CE_PlayerSkyScaleIMC )
	Event_AddClientStateFunc( event0, "CE_VisualSettingColonyIMC" )

	local event1			= CreateCinematicEvent()
	event1.origin 			= animEnt1.GetOrigin()
	//event1.origin			= PositionOffsetFromEnt( animEnt1, 700, 0, 400 )
	event1.angles			= animEnt1.GetAngles()
	event1.anim				= "dropship_colony_imc_intro"
	Event_AddFlagSetOnEnd( event1, "IntroDropshipDoneIMC" )
	//Event_AddAnimStartFunc( event1, IntroDialogueIMC )
	Event_AddAnimStartFunc( event1, IntroIMCHeroes )

	local event2 			= CreateCinematicEvent()
	event2.anim				= "dropship_colony_imc_flyaway"
	event2.origin 			= animEnt1.GetOrigin()
	event2.angles			= animEnt1.GetAngles()

	AddSavedDropEvent( "introDropShipIMC_1cr", table )
	AddSavedDropEvent( "introDropShipIMC_1e0", event0 )
	AddSavedDropEvent( "introDropShipIMC_1e1", event1 )
	AddSavedDropEvent( "introDropShipIMC_1e2", event2 )

	///////////////////////////////////////////////////////////////////////
	//local animEnt2 = GetEnt( "animNodeIMCFlyin2" )
	//local posOffset = Vector( 200, 200, 350 )
	//local angOffset = Vector( 0, 20, 0 )
	//local animEnt2 = CreateScriptRef( animEnt1.GetOrigin() + posOffset, animEnt1.GetAngles() + angOffset )
	local animEnt2 = animEnt1

	local table				= CreateCinematicDropship()
	table.origin 			= animEnt2.GetOrigin()
	table.team				= TEAM_IMC
	table.count 			= 4
	table.side 				= "jumpSideR"
	table.turret			= false

	local event0			= CreateCinematicEvent()
	event0.origin 			= animEnt2.GetOrigin()
	event0.angles			= animEnt2.GetAngles()
	event0.anim				= "dropship_B_colony_imc_intro_idle"
	event0.teleport 		= true
	Event_AddFlagWaitToEnd( event0, "StartIMCDropships" )
	Event_AddServerStateFunc( event0, CE_PlayerSkyScaleIMC )
	Event_AddClientStateFunc( event0, "CE_VisualSettingColonyIMC" )


	local event1 			= CreateCinematicEvent()
	event1.origin 			= animEnt2.GetOrigin()
	event1.angles			= animEnt2.GetAngles()
	event1.anim				= "dropship_B_colony_imc_intro"
	//Event_AddAnimStartFunc( event1, IntroDialogueIMC )
	Event_AddAnimStartFunc( event1, IntroIMCHeroes )

	local event2 			= CreateCinematicEvent()
	event2.anim				= "dropship_B_colony_imc_flyaway"
	event2.origin 			= animEnt2.GetOrigin()
	event2.angles			= animEnt2.GetAngles()

	AddSavedDropEvent( "introDropShipIMC_2cr", table )
	AddSavedDropEvent( "introDropShipIMC_2e0", event0 )
	AddSavedDropEvent( "introDropShipIMC_2e1", event1 )
	AddSavedDropEvent( "introDropShipIMC_2e2", event2 )
}

function IntroDropshipIMC()
{
	local table 	= GetSavedDropEvent( "introDropShipIMC_1cr" )
	local event0 	= GetSavedDropEvent( "introDropShipIMC_1e0" )
	local event1 	= GetSavedDropEvent( "introDropShipIMC_1e1" )
	local event2 	= GetSavedDropEvent( "introDropShipIMC_1e2" )

	local dropship1 = SpawnCinematicDropship( table )
	dropship1.NotSolid()
	level.introDropshipsIMC.append( dropship1 )
	thread RunCinematicDropship( dropship1, event0, event1, event2 )
	delaythread ( 0.5 ) IntroScreenDialogueIMC( dropship1 )


	local table 	= GetSavedDropEvent( "introDropShipIMC_2cr" )
	local event0 	= GetSavedDropEvent( "introDropShipIMC_2e0" )
	local event1 	= GetSavedDropEvent( "introDropShipIMC_2e1" )
	local event2 	= GetSavedDropEvent( "introDropShipIMC_2e2" )

	local dropship2	= SpawnCinematicDropship( table )
	dropship2.NotSolid()
	level.introDropshipsIMC.append( dropship2 )
	thread RunCinematicDropship( dropship2, event0, event1, event2 )
	delaythread ( 0.5 ) IntroScreenDialogueIMC( dropship2 )

	dropship1.SetJetWakeFXEnabled( false )
	dropship2.SetJetWakeFXEnabled( false )

	thread IntroIMCExperience( dropship1 )
	thread IntroIMCExperience( dropship2 )

	//DebugSkipCinematicSlots( TEAM_IMC, 4 )
	DebugSkipCinematicSlotsWithBugRepro( TEAM_IMC )
	//0 - back
	//1 - back middle
	//2 - front middle
	//3 - front

	dropship1.kv.VisibilityFlags = 2 // Only team members can see it
	dropship2.kv.VisibilityFlags = 2 // Only team members can see it
}

function CE_PlayerSkyScaleIMC( player, ref )
{
	player.LerpSkyScale( SKYSCALE_COLONY_IMC_PLAYER, 0.01 )
}

/*----------------------------------------------------------------------------------
/
/				HOUSEKEEPING/UTILITY
/
/-----------------------------------------------------------------------------------*/
function AA_UTILITY_Functions()
{
	//Bookmark to jump to this section
}


//////////////////////////////////////////////////////////////////////////////////////////
function DrawLineEntToPos( ent, pos )
{
	ent.EndSignal( "OnDeath" )

	while ( IsAlive( ent ) )
	{
		DebugDrawLine( ent.GetOrigin() + Vector( 0, 0, 64 ), pos, 0, 255, 0, true, 5.0 )
		wait 0.05
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////////////
function DieOnOtherNPCsDeath( npc, enderNPC )
{
	npc.EndSignal( "OnDeath" )
	enderNPC.WaitSignal( "OnDeath" )
	if ( IsAlive( npc ) )
		npc.BecomeRagdoll( Vector( 0, 0, 0 ) )
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
function PlaySequenceOnFlag( npc, pos, ang, idle, anim, flag, enderNPC = null, func = null, flagToSetOnEnd = null, dieIfEnderNPCdies = false )
{
	npc.EndSignal( "OnDeath" )

	if ( enderNPC )
	{
		enderNPC.EndSignal( "OnDeath" )
		if ( dieIfEnderNPCdies )
			thread DieOnOtherNPCsDeath( npc, enderNPC )
	}

	if ( IsNPC( npc ) )
		npc.SetEfficientMode( true )

	OnThreadEnd
	(
		function() : ( npc, func, flagToSetOnEnd )
		{
			if ( flagToSetOnEnd )
				FlagSet( flagToSetOnEnd )
			if ( !IsAlive( npc ) )
				return
			if ( IsNPC( npc ) )
				npc.SetEfficientMode( false )
			if ( func )
				thread func( npc )

		}
	)

	thread PlayAnimTeleport( npc, idle, pos, ang )

	FlagWait( flag )

	waitthread PlayAnim( npc, anim, pos, ang )
}

///////////////////////////////////////////////////////////////////////////////////////////////////
function FlagSetDelayed( flag, delay )
{
	wait delay
	FlagSet( flag )
}

function ColonyMatchProgressAnnouncementFunc( progression )
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

	if ( progression >= MATCH_PROGRESS_FLAVOR_VDU3 )
	{
		if ( !level.matchProgressFlavorVDU3 )
		{
			PlayConversationToAll( "match_progress_60_percent" )
			level.matchProgressFlavorVDU3 = true

		}
	}

	if ( progression >= MATCH_PROGRESS_FLAVOR_VDU4 )
	{
		if ( !level.matchProgressFlavorVDU4 )
		{
			PlayConversationToAll( "match_progress_80_percent" )
			level.matchProgressFlavorVDU4 = true

		}
	}

	//On top of the custom stuff, we want the default announcements, so call default announcements
	DefaultMatchProgressionAnnouncement( progression )
}

///////////////////////////////////////////////////////////////////////////////////////////////
function SpectreCallbackColony( spectre )
{
	local team = spectre.GetTeam()
	SpectreSetTeam( spectre, team )
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
function DeleteCinematicContent()
{
	local stuffToDelete = []
	//stuffToDelete.append( GetEnt( "spectrePaletteLeft" ) )
	//stuffToDelete.append( GetEnt( "spectrePaletteRight" ) )
	stuffToDelete.append( GetEnt( "func_brush_clip_imc_intro" ) )

	foreach( ent in stuffToDelete )
		DeleteIfValid( ent )

}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function MakeModelOnlyVisibleToTeam( model, team )
{
	model.SetTeam( team )
	model.kv.VisibilityFlags = 2 // Only team members can see it
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function MakeModelVisibleToEveryone( model )
{
	model.SetTeam( TEAM_UNASSIGNED )
	model.kv.VisibilityFlags = 7
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function ColonySpecificChatter( npc )
{
	Assert( GetMapName() == "mp_colony" )

	if ( !GamePlayingOrSuddenDeath() )
		return false

	PlaySquadConversationToTeam( "colony_grunt_chatter", npc.GetTeam(), npc, AI_FRIENDLY_CHATTER_RANGE_SQR )
	return true //return false if we should not be doing chatter so we can fall through and do other chatter if needed
}

function DEV_MatchProgressDialogue( number )
{
	local alias
	if ( number == 1 )
		alias = "match_progress_15_percent"
	else if ( number == 2 )
		alias = "match_progress_40_percent"
	else if ( number == 3 )
		alias = "match_progress_60_percent"
	else if ( number == 4 )
		alias = "match_progress_80_percent"
	else if ( number == 5 )
		alias = "ColonyEpilogueStory"
	else
		return

	thread PlayConversationToTeam( alias, TEAM_IMC )
	thread PlayConversationToTeam( alias, TEAM_MILITIA )
}



main()