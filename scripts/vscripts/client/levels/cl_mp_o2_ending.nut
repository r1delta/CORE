const DEV_EDITOR = 0
const FORCEDIALOGUEBUFFER = 1.0
const MINWAITBETWEENLINES = 0.5

const SHAKEAMP = 0.2
const SHAKEFREQ = 30
enum GETREACTORFXFUNC
{
	DEFAULT,
	CAMDOWN,
	CLOSEUP
}

const FXVDU_DOOR_EXP 		= "P_impact_exp_med_metal"
const FXVDU_REACTOR_STEAM 	= "P_steam_leak_LG"

function main()
{
	FlagInit( "StoryVDU")
	FlagInit( "BadIdeaDone" )
	FlagInit( "ContactGravesDone" )
	FlagInit( "SacrificeDone" )
	FlagInit( "SacrificeHideCam" )

	FlagInit( "BadIdeaCamZoom1" )
	FlagInit( "BadIdeaCamZoom2" )

	Globalize( StoryBlurb1 )
	Globalize( StoryBlurb2 )
	Globalize( StoryBlurb3 )
	Globalize( StoryBlurb4 )
	Globalize( StoryBlurb5 )
	Globalize( PostEpilogueVO )

	Globalize( EndVDUMoment_BadIdea )
	Globalize( EndBadIdeaMain )

	Globalize( EndVDUMoment_ContactGraves )
	Globalize( EndContactGravesMain )

	Globalize( EndVDUMoment_CamFeedMilitia )
	Globalize( EndVDUMoment_Ambush )
	Globalize( EndAmbushMain )

	Globalize( EndVDUMoment_Sacrifice )
	Globalize( EndSacrificeMain )

	Globalize( EndVDUMoment_Death )

	PrecacheParticleSystem( FXVDU_REACTOR_STEAM )
	PrecacheParticleSystem( FXVDU_DOOR_EXP )

	level.reactorRoomFx <- []
}

function StoryBlurb1( team = null )
{
	LockStoryVDU( false )

	if ( team == null )
		team = GetLocalViewPlayer().GetTeam()

	if ( team == TEAM_MILITIA )
		waitthread EndBlurb1MilitiaMain()
	else
		waitthread EndBlurb1IMCMain()

	UnlockStoryVDU()
}

function StoryBlurb2( team = null )
{
	if ( team == null )
		team = GetLocalViewPlayer().GetTeam()

	if ( team != TEAM_MILITIA )
		return

	LockStoryVDU()
	ShowVDU()

	waitthread EndBadIdeaMain()

	UnlockStoryVDU()
}

function StoryBlurb3( team = null )
{
	LockStoryVDU()
	ShowVDU()
	if ( team == null )
		team = GetLocalViewPlayer().GetTeam()

	if ( team == TEAM_MILITIA )
	{
		waitthread EndCamFeedMilitiaMain()
		wait 1.0
		ShowVDU()
		waitthread EndAmbushMain()
		//Sarah: He’s gonna get himself killed.
		PlaySoundAndWait( "diag_hp_story30_O2507_07b_01_mcor_sarah" )
	}
	else
	{
		waitthread EndCamFeedIMCMain()
		waitthread EndAmbushMain()
	}

	UnlockStoryVDU()
}

function StoryBlurb4( team = null )
{
	LockStoryVDU()

	if ( team == null )
		team = GetLocalViewPlayer().GetTeam()

	if ( team == TEAM_MILITIA )
	{
		thread StopMusic( 2.0 )
		SetForcedMusicOnly( true )

		//Sarah: Bish, I’m picking up a spike in the reactor core - patching in now.
		PlaySoundAndWait( "diag_hp_story40_O2508_01_01_mcor_sarah" )
		delaythread( 2.0 ) PlayEndMusicUntilEpilogue()
		waitthread EndSacrificeMain( team )
	}
	else
	{
		thread StopMusic( 2.0 )
		SetForcedMusicOnly( true )

		//Vice Admiral Graves, I’m picking up a spike in the reactor core.
		EmitSoundOnEntity( GetLocalViewPlayer(), "diag_hp_story40_O2509_01_01_imc_spygl" )
		wait 1.5
		delaythread( 2.0 ) PlayEndMusicUntilEpilogue()
		waitthread EndSacrificeMain( team )
	}

	UnlockStoryVDU()
}

function PlayEndMusicUntilEpilogue()
{
	if ( Flag( "WinnerDetermined" ) )
		return
	FlagEnd( "WinnerDetermined" )

	waitthread ForcePlayMusicToCompletion( eMusicPieceID.LEVEL_CINEMATIC_1 )
	SetForcedMusicOnly( true )
	wait 4.0

	while( !Flag( "WinnerDetermined" ) )
	{
		waitthread ForcePlayMusicToCompletion( eMusicPieceID.LEVEL_CINEMATIC_2 )
		SetForcedMusicOnly( true )
		wait 4.0

		waitthread ForcePlayMusicToCompletion( eMusicPieceID.LEVEL_CINEMATIC_3 )
		SetForcedMusicOnly( true )
		wait 4.0

		waitthread ForcePlayMusicToCompletion( eMusicPieceID.LEVEL_CINEMATIC_4 )
		SetForcedMusicOnly( true )
		wait 4.0
	}
}

function StoryBlurb5( team = null )
{
	LockStoryVDU()
	wait 2.0 //a beat after music changes and victory and everything

	if ( team == null )
		team = GetLocalViewPlayer().GetTeam()

	if ( team == TEAM_MILITIA )
	{
		wait 1.0
		waitthread EndNoEvacMilitiaMain()
	}
	else
	{
		waitthread EndNoEvacIMCMain()
		waitthread EndFinaleIMCMain()
	}

	UnlockStoryVDU()
}

function PostEpilogueVO( team = null )
{
	LockStoryVDU()

	if ( team == null )
		team = GetLocalViewPlayer().GetTeam()

	if ( team == TEAM_MILITIA )//30s
	{
		PlaySoundAndWait( "diag_newsOutro_o2614a_01_01_neutral_fnews", -0.5 )	//On the frontier today, the IMC's port of demeter was attacked by Militia insurgents
		PlaySoundAndWait( "diag_newsOutro_o2614a_02_01_neutral_fnews", -0.25 )	//Reports are sketchy, but indications are that the refueling facilities sustained major damage in the battle
		PlaySoundAndWait( "diag_newsOutro_o2614a_04_01_neutral_fnews", -0.5 )	//Numerous casualties are indicated, including the mutineer james macallan, formly believed missing in action
		thread PostEpilogueVOBackGround( team )
		wait 1.25
		PlaySoundAndWait( "diag_hp_epEnd_O2514_05_01_mcor_bish", -0.25 )		//Bish: Adios my friend.
		PlaySoundAndWait( "diag_newsOutro_o2614a_06_01_neutral_fnews" )			//The where abouts of several high ranking officers involved in the conflict, including Vice admiral marcus graves, is presently unknown.
	}
	else
	{
		wait 0.5
		PlaySoundAndWait( "diag_newsOutro_o2614a_01_01_neutral_fnews", -0.5 )	//On the frontier today, the IMC's port of demeter was attacked by Militia insurgents
		PlaySoundAndWait( "diag_newsOutro_o2614a_02_01_neutral_fnews", -0.5 )	//Reports are sketchy, but indications are that the refueling facilities sustained major damage in the battle
		thread PostEpilogueVOBackGround( team )
		wait 1.25
		PlaySoundAndWait( "diag_epEnd_O2522_05_01_mcor_blisk" )					//Blisk: They just cut us off from the Core Systems. We’re stuck on the wrong side of the frontier, Sir.
		PlaySoundAndWait( "diag_epEnd_O2522_06_01_mcor_graves_alt" )			//Graves Yes, we are.
		PlaySoundAndWait( "diag_newsOutro_o2614a_06_01_neutral_fnews" )			//The where abouts of several high ranking officers involved in the conflict, including Vice admiral marcus graves, is presently unknown.
	}

	UnlockStoryVDU()
}

function PostEpilogueVOBackGround( team )
{
	if ( team == TEAM_MILITIA )
	{
		PlaySoundAndWait( "diag_newsOutro_o2614a_05_01_MCOR_fnews" )			//High Command in the IMC could not be reached for comment.
	}
	else
	{
		PlaySoundAndWait( "diag_newsOutro_o2614a_04_01_IMC_fnews", -0.5 )		//Numerous casualties are indicated, including the mutineer james macallan, formly believed missing in action
	//	PlaySoundAndWait( "diag_newsOutro_o2614a_05_01_neutral_fnews" )			//High Command in the IMC could not be reached for comment.
	}
}

/*
		PlaySoundAndWait( "diag_newsOutro_o2614a_01_01_neutral_fnews" )	//On the frontier today, the IMC's port of demeter was attacked by Militia insurgents
		PlaySoundAndWait( "diag_newsOutro_o2614a_02_01_neutral_fnews" )	//Reports are sketchy, but indications are that the refueling facilities sustained major damage in the battle
		PlaySoundAndWait( "diag_newsOutro_o2614a_03_01_neutral_fnews" )	//Mr. hammond is confident that the interruption in transportation services to the frontier will be temporary
		PlaySoundAndWait( "diag_newsOutro_o2614a_04_01_neutral_fnews" )	//Numerous casualties are indicated, including the mutineer james macallan, formly believed missing in action
		PlaySoundAndWait( "diag_newsOutro_o2614a_05_01_neutral_fnews" )	//High Command in the IMC could not be reached for comment.
		PlaySoundAndWait( "diag_newsOutro_o2614a_06_01_neutral_fnews" )	//The where abouts of several high ranking officers involved in the conflict, including Vice admiral marcus graves, is presently unknown.
*/

/************************************************************************************************\

########  ##       ##     ## ########  ########           ##
##     ## ##       ##     ## ##     ## ##     ##        ####
##     ## ##       ##     ## ##     ## ##     ##          ##
########  ##       ##     ## ########  ########           ##
##     ## ##       ##     ## ##   ##   ##     ##          ##
##     ## ##       ##     ## ##    ##  ##     ##          ##
########  ########  #######  ##     ## ########         ######

\************************************************************************************************/
function EndBlurb1MilitiaMain()
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	thread EndBlurb1MilitiaCam()

	//Sarah: Mac, I don’t know what’s wrong, but the hardpoints aren’t routing enough power to the core. Between that and the fleet taking a pounding, we might have to abort the mission.
	PlaySoundAndWait( "diag_hp_story10_O2501_01_01_mcor_Sarah" )
	//MacAllan:  I didn’t come all this way to give up, Sarah!
	PlaySoundAndWait( "diag_hp_story10_O2501_02_01_mcor_macal" )
	//Bish: Mac, uh, I think she might be right. The reactors are way more shielded than the intel indicated – the Pilots on the ground might not be able to make it go critical the way we planned!
	PlaySoundAndWait( "diag_hp_story10_O2501_03_01_mcor_bish" )
	//MacAllan: I said we’re not giving up! Pilots, keep those hardpoint terminals under control and get me a little more time! We’ll figure something out!
	PlaySoundAndWait( "diag_hp_story10_O2501_04_01_mcor_macal" )
}

function EndBlurb1MilitiaCam()
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	ShowVDU()

	local trackStart	= Vector( -355, 272, 700 )
	local trackEnd		= Vector( -355, 272, 50 )
	local origin 		= Vector( -355, 272, 90 )
	local startAng 		= Vector( 10, 150, 0 )
	local endAng 		= Vector( -20, 320, 0 )
	local startRadius	= 450
	local endRadius		= 400
	local pivotTime 	= 10
	local ease 			= 2
	local startFov 		= 70
	local endFov 		= 30

	local tracker = CreateClientsideScriptMover( "models/dev/empty_model.mdl", trackStart, Vector( 0, 0, 0 ) )
	tracker.NonPhysicsMoveTo( trackEnd, pivotTime * 0.6, 0, ease )

	thread TrackEntityWithMovingCamera( GetLocalViewPlayer(), tracker, pivotTime )
	thread PivotCameraOverTime( GetLocalViewPlayer(), origin, startAng, endAng, startRadius, endRadius, pivotTime, 0, ease )
	waitthread ZoomCameraOverTime( GetLocalViewPlayer(), startFov, endFov, pivotTime, ease, ease )

	wait 1

	tracker.Kill()

	local trackOrigin	= Vector( -11738, -15290, 3000 )
	local origin 		= Vector( 636, 1008, 2500 )
	local startAng 		= Vector( 21, -175, 0 )
	local endAng 		= Vector( 10, 52, 0 )
	local startRadius	= 9000
	local endRadius		= 4500
	local pivotTime 	= 11
	local ease 			= 4
	local startFov 		= 30
	local endFov 		= 20

	thread TrackPointWithMovingCamera( GetLocalViewPlayer(), trackOrigin, pivotTime )
	thread PivotCameraOverTime( GetLocalViewPlayer(), origin, startAng, endAng, startRadius, endRadius, pivotTime, 0, ease )
	waitthread ZoomCameraOverTime( GetLocalViewPlayer(), startFov, endFov, pivotTime, ease, ease )

	wait 0.5

	local camera 	= GetCamera()
	camera.SetOrigin( Vector( 2028.954468, -943.226807, 11.885265 ) )
	camera.SetAngles( Vector( -4, -18.314896, -0.000004 ) )
	camera.SetFOV( 45 )

	wait 1.5
	camera.SetOrigin( Vector( -1233.541870, 2336.584473, 113.767502 ) )
	camera.SetAngles( Vector( -25.980005, 167.391022, -0.000006 ) )
	camera.SetFOV( 50 )

	wait 1.5
	camera.SetOrigin( Vector( -376.066132, 462.210236, 42.575939 ) )
	camera.SetAngles( Vector( -1, -79.929703, -0.000003 ) )
	camera.SetFOV( 45 )
}

function EndBlurb1IMCMain()
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	thread EndBlurb1IMCCam()

	//spyglass: Sir, Militia forces are attempting to divert power to detonate the reactor core.
	PlaySoundAndWait( "diag_story10_O2502a_01_01_imc_spygl" )
	//graves: Can you disrupt them remotely, Spyglass?
	PlaySoundAndWait( "diag_story10_O2502a_02_01_imc_graves" )
	//spyglass: Of course, Vice Admiral, although a manual overload will still be possible.
	PlaySoundAndWait( "diag_story10_O2502a_03_01_imc_spygl" )
	//blisk: Well at least you’ve done your part, Spyglass. I’ll handle the other.
	//GenericWideScreenVDU( "diag_hp_story10_O2502a_04_01_imc_blisk", "blisk" )
}

function EndBlurb1IMCCam()
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	ShowVDU()

	local trackStart	= Vector( -355, 272, 700 )
	local trackEnd		= Vector( -355, 272, 50 )
	local origin 		= Vector( -355, 272, 90 )
	local startAng 		= Vector( 10, -40, 0 )
	local endAng 		= Vector( -20, 130, 0 )
	local startRadius	= 450
	local endRadius		= 400
	local pivotTime 	= 12
	local ease 			= 2
	local startFov 		= 70
	local endFov 		= 30

	local tracker = CreateClientsideScriptMover( "models/dev/empty_model.mdl", trackStart, Vector( 0, 0, 0 ) )
	tracker.NonPhysicsMoveTo( trackEnd, pivotTime * 0.6, 0, ease )

	thread TrackEntityWithMovingCamera( GetLocalViewPlayer(), tracker, pivotTime )
	thread PivotCameraOverTime( GetLocalViewPlayer(), origin, startAng, endAng, startRadius, endRadius, pivotTime, 0, ease )
	waitthread ZoomCameraOverTime( GetLocalViewPlayer(), startFov, endFov, pivotTime, ease, ease )

	wait 2

	tracker.Kill()
}

function CalcualteCircumference( pivOrg, startOrg, endOrg, startRad, endRad )
{
	local vec1 		= startOrg - pivOrg
	local vec2 		= endOrg - pivOrg
	vec1.Normalize()
	vec2.Normalize()
	local product 	= vec1.Dot( vec2 )
	local theta		= acos( product )
	local circ 		= theta * ( ( startRad + endRad  ) * 0.5 )

	return circ
}

/************************************************************************************************\

########     ###    ########        #### ########  ########    ###
##     ##   ## ##   ##     ##        ##  ##     ## ##         ## ##
##     ##  ##   ##  ##     ##        ##  ##     ## ##        ##   ##
########  ##     ## ##     ##        ##  ##     ## ######   ##     ##
##     ## ######### ##     ##        ##  ##     ## ##       #########
##     ## ##     ## ##     ##        ##  ##     ## ##       ##     ##
########  ##     ## ########        #### ########  ######## ##     ##

setpos -14352.766602 12069.745117 -10190
script_client thread EndBadIdeaMain()
\************************************************************************************************/
function EndBadIdeaMain()
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	local node = GetNodeByUniqueID( "cinematic_mp_node_endBadIdea" )
	waitthread EndBadIdeaAnim( node )
}

function EndBadIdeaAnim( node )
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	FlagClear( "BadIdeaCamZoom1" )
	FlagClear( "BadIdeaCamZoom2" )
	FlagClear( "BadIdeaDone" )

	NodeCleanUp( node )

	//anim setup
	local mac 		= CreatePropDynamic( MAC_MODEL, node.pos, node.ang )
	local macgun 	= CreatePropDynamic( MACGUN, node.pos, node.ang )
	node.ents.append( mac )
	node.ents.append( macgun )

	Cl_SetParent( macgun, mac, "PROPGUN" )
	macgun.MarkAsNonMovingAttachment()

	OnThreadEnd(
		function() : ( node )
		{
			foreach ( ent in node.ents )
			{
				if ( IsValid( ent ) )
					ent.Kill()
			}
		}
	)

	mac.EndSignal( "OnDeath" )
	mac.EndSignal( "OnDestroy" )

	//idle
	thread PlayAnimTeleport( mac, "pt_O2_finale_grenade_corner_idle", node.pos, node.ang )

	//Sarah: We’re running outta time and the fleet up here is in bad shape. If you’re gonna do something MacAllan, you’d better do it fast!
	delaythread( 2 ) EmitSoundOnEntity( GetLocalViewPlayer(), "diag_hp_story20_O2503_01_01_mcor_sarah" )

	//start the camera
	local initialPanTime = 1.5
	thread BadIdeaTrackCam( node, mac, initialPanTime )
	wait initialPanTime

	//play the explosion at the door
	local effectIndex 	= GetParticleSystemIndex( FXVDU_DOOR_EXP )
	local fxorigin 		= Vector( -14080.9, 12184.2, -10208 )
	local fxangles 		= Vector( 0, -90, 0 )
	StartParticleEffectInWorld( effectIndex, fxorigin, fxangles )

	//start the scene
	waitthread PlayAnim( mac, "pt_O2_finale_grenade_corner", node.pos, node.ang )
	thread BadIdeaDialogue()
	delaythread( 4.8 ) FlagSet( "BadIdeaCamZoom1" )
	waitthread PlayAnim( mac, "pt_O2_finale_O2503_02_01", mac.GetOrigin(), mac.GetAngles() )
	//waitthread PlayAnim( mac, "pt_O2_finale_run_look", mac.GetOrigin(), mac.GetAngles() )
	waitthread PlayAnim( mac, "pt_O2_finale_run", mac.GetOrigin(), mac.GetAngles() )
	waitthread PlayAnim( mac, "pt_O2_finale_run", mac.GetOrigin(), mac.GetAngles() + Vector( 0, -5, 0 ) )
	waitthread PlayAnim( mac, "pt_O2_finale_run_checkmap", mac.GetOrigin(), mac.GetAngles() + Vector( 0, -10, 0 ) )
	waitthread PlayAnim( mac, "pt_O2_finale_run", mac.GetOrigin(), mac.GetAngles() )
	waitthread PlayAnim( mac, "pt_O2_finale_run_look", mac.GetOrigin(), mac.GetAngles() )
	waitthread PlayAnim( mac, "pt_O2_finale_run", mac.GetOrigin(), mac.GetAngles() )
	FlagSet( "BadIdeaCamZoom2" )
	waitthread PlayAnim( mac, "pt_O2_finale_run", mac.GetOrigin(), mac.GetAngles() )

	local anim = "pt_O2_finale_O2503_04_01"
	local angles = mac.GetAngles() + Vector( 0, 15, 0 )
	local origin = HackGetDeltaToRef( mac.GetOrigin(), angles, mac, anim )
	thread PlayAnim( mac, anim, origin, angles )

	//pop camera to new location while his hand is up to his ear
	local popTime = 3.0
	local killTrack = 0.5

	delaythread( popTime - killTrack ) BadIdeaKillTracking()

	wait popTime

	//move mac to line up with hitting the terminal
	local origin 	= Vector( -12780, 11958, -10241.0 )
	local angles 	= Vector( 0, 0, 0 )
	thread PlayAnimTeleport( mac, "pt_O2_finale_O2503_04_01_noVO", origin, angles )
	mac.Anim_SetInitialTime( popTime )

	//move the camera
	local origin 	= Vector( -12750, 11950, -10178  )
	local angles 	= Vector( 0, 165, 0 )
	local camera 	= GetCamera()
	camera.SetOrigin( origin )
	camera.SetAngles( angles )
	camera.SetFOV( 55 )

	FlagWait( "BadIdeaDone" )
}

function BadIdeaKillTracking()
{
	GetLocalViewPlayer().Signal( "vdu_open" )//kill the tracking
}

function BadIdeaTrackCam( node, mac, initialPanTime )
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	local origin 	= Vector( -13396.906250, 11914.695313, -10132.277344 )
	local startAng	= Vector( 10, 130, 0 )
	local camera 	= GetCamera()
	local startFov	= 60

	camera.SetOrigin( origin )
	camera.SetAngles( startAng )
	camera.SetFogEnable( true )
	camera.SetFOV( startFov )

	local forwardDist	= 10
	local rightDist		= 0
	local upDist		= 60

	ShowVDU()

	//pan left
	local rotTime 	= initialPanTime
	local ease		= 0.25
	local endAng	= startAng + Vector( 0, 10, 0 )
	thread RotateCameraOverTime( GetLocalViewPlayer(), startAng, endAng, rotTime, ease, ease )

	wait initialPanTime + 0.5

	//pan and focus on mac
	local rotTime 	= 0.5
	local ease		= 0
	local startAng	= endAng
	local endAng	= GetVDUCamTrackAngles( origin, mac, forwardDist, rightDist, upDist )
	thread RotateCameraOverTime( GetLocalViewPlayer(), startAng, endAng, rotTime, ease, ease )

	//zoom in
	local zoomTime 	= 0.6
	local ease 		= 0.1
	local endFov	= 1
	thread ZoomCameraOverTime( GetLocalViewPlayer(), startFov, endFov, zoomTime, ease, ease )

	//back up
	local delayTime = zoomTime
	local zoomTime 	= 0.1
	local ease 		= 0.0
	local startFov 	= endFov
	local endFov	= startFov + 2
	delaythread( delayTime ) ZoomCameraOverTime( GetLocalViewPlayer(), startFov, endFov, zoomTime, ease, ease )

	//settle
	local delayTime = delayTime + zoomTime
	local zoomTime 	= 0.1
	local ease 		= 0.0
	local startFov 	= endFov
	local endFov	= startFov - 1
	delaythread( delayTime ) ZoomCameraOverTime( GetLocalViewPlayer(), startFov, endFov, zoomTime, ease, ease )

	wait rotTime + 0.1

	//track mac
	local time = 60
	thread TrackEntityWithCamera( GetLocalViewPlayer(), camera.GetOrigin(), mac, time, forwardDist, rightDist, upDist )

	FlagWait( "BadIdeaCamZoom1" )

	//slowly zoom out
	local zoomTime 	= 5
	local ease 		= 0.5
	local startFov 	= endFov
	local endFov	= 15
	thread ZoomCameraOverTime( GetLocalViewPlayer(), startFov, endFov, zoomTime, ease, ease )

	FlagWait( "BadIdeaCamZoom2" )

	//slowly zoom out
	local zoomTime 	= 3.5
	local ease 		= 0.5
	local startFov 	= endFov
	local endFov	= 10
	thread ZoomCameraOverTime( GetLocalViewPlayer(), startFov, endFov, zoomTime, ease, ease )
}

function BadIdeaDialogue()
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	wait 5.5

	//Bish: Mac, if you can find a way to trigger a manual overload, that’ll work, even if they manage to shut down the reactor core. Except there’s one problem - there isn’t a Titan in the world that could protect you against that kind of radiation.
	EmitSoundOnEntity( GetLocalViewPlayer(), "diag_hp_story20_O2503_03_01_mcor_bish" )
	wait 21.5

	FlagSet( "BadIdeaDone" )
}

function EndVDUMoment_BadIdea( node )
{
	thread EndBadIdeaAnim( node )
}

/************************************************************************************************\

 #######  ########  ######## ##    ##        ######  ##     ##    ###    ##    ## ##    ## ######## ##
##     ## ##     ## ##       ###   ##       ##    ## ##     ##   ## ##   ###   ## ###   ## ##       ##
##     ## ##     ## ##       ####  ##       ##       ##     ##  ##   ##  ####  ## ####  ## ##       ##
##     ## ########  ######   ## ## ##       ##       ######### ##     ## ## ## ## ## ## ## ######   ##
##     ## ##        ##       ##  ####       ##       ##     ## ######### ##  #### ##  #### ##       ##
##     ## ##        ##       ##   ###       ##    ## ##     ## ##     ## ##   ### ##   ### ##       ##
 #######  ##        ######## ##    ##        ######  ##     ## ##     ## ##    ## ##    ## ######## ########

script_client thread EndOpenChannelMain()
\************************************************************************************************/
function EndOpenChannelMain()
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	//Spyglass: Colonel Graves, incoming transmission from James MacAllan. He’s asking for you.
	GenericWideScreenVDU( "diag_hp_story22_O2504_01_01_imc_spygl", "spyglass", "spy_VDU_status" )

	//Graves:  Put him through and keep the channel open!
	GenericWideScreenVDU( null, "graves", "diag_hp_story22_O2504_02_01_imc_graves" )
}

/************************************************************************************************\

 ######   #######  ##    ## ########    ###     ######  ########        ######   ########     ###    ##     ## ########  ######
##    ## ##     ## ###   ##    ##      ## ##   ##    ##    ##          ##    ##  ##     ##   ## ##   ##     ## ##       ##    ##
##       ##     ## ####  ##    ##     ##   ##  ##          ##          ##        ##     ##  ##   ##  ##     ## ##       ##
##       ##     ## ## ## ##    ##    ##     ## ##          ##          ##   #### ########  ##     ## ##     ## ######    ######
##       ##     ## ##  ####    ##    ######### ##          ##          ##    ##  ##   ##   #########  ##   ##  ##             ##
##    ## ##     ## ##   ###    ##    ##     ## ##    ##    ##          ##    ##  ##    ##  ##     ##   ## ##   ##       ##    ##
 ######   #######  ##    ##    ##    ##     ##  ######     ##           ######   ##     ## ##     ##    ###    ########  ######

setpos -11696.357422 11937.871094 -10320
script_client thread EndContactGravesMain()
\************************************************************************************************/
function EndContactGravesMain()
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	local node = GetNodeByUniqueID( "cinematic_mp_node_endContactGraves" )
	waitthread EndContactGravesAnim( node )
}

function EndContactGravesAnim( node )
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	FlagClear( "ContactGravesDone" )

	NodeCleanUp( node )

	//anim setup
	local mac 		= CreatePropDynamic( MAC_MODEL, node.pos, node.ang )
	local macgun 	= CreatePropDynamic( MACGUN, node.pos, node.ang )
	node.ents.append( mac )
	node.ents.append( macgun )

	Cl_SetParent( macgun, mac, "PROPGUN" )
	macgun.MarkAsNonMovingAttachment()

	//camera setup
	local origin 	= Vector( -11425, 12010, -10305  )
	local angles 	= Vector( 0, 165, 0 )
	local camera 	= GetCamera()
	camera.SetOrigin( origin )
	camera.SetAngles( angles )
	camera.SetFOV( 55 )

	OnThreadEnd(
		function() : ( node )
		{
			foreach ( ent in node.ents )
			{
				if ( IsValid( ent ) )
					ent.Kill()
			}
		}
	)

	mac.EndSignal( "OnDeath" )
	mac.EndSignal( "OnDestroy" )

	ShowVDU()

	waitthread PlayAnimTeleport( mac, "pt_O2_finale_run_checkmap", node.pos, node.ang )
	thread EndContactGravesDialogue()

	local anim = "pt_O2_finale_contact_graves"
	local origin = HackGetDeltaToRef( mac.GetOrigin(), node.ang, mac, anim )
	waitthread PlayAnim( mac, anim, origin, node.ang )

	FlagWait( "ContactGravesDone" )
}

function EndContactGravesDialogue()
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	wait 8.5
	//Blisk: What the hell is he going on about? What ship?
	PlaySoundAndWait( "diag_hp_story22_O2505_08_01_imc_blisk" )
	//Graves: It’s a gambit. Blisk, get down to the reactor core – now.
	GenericWideScreenVDU( null, "graves", "diag_hp_story22_O2505_09_01_imc_graves" )

	FlagSet( "ContactGravesDone" )
}

function EndVDUMoment_ContactGraves( node )
{
	thread EndContactGravesAnim( node )
}

/************************************************************************************************\

 ######     ###    ##     ##       ######## ######## ######## ########
##    ##   ## ##   ###   ###       ##       ##       ##       ##     ##
##        ##   ##  #### ####       ##       ##       ##       ##     ##
##       ##     ## ## ### ##       ######   ######   ######   ##     ##
##       ######### ##     ##       ##       ##       ##       ##     ##
##    ## ##     ## ##     ##       ##       ##       ##       ##     ##
 ######  ##     ## ##     ##       ##       ######## ######## ########

setpos -9518 13580 -11771
script_client thread EndCamFeedMilitiaMain()
\************************************************************************************************/
function EndCamFeedMilitiaMain()
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	local node = GetNodeByUniqueID( "cinematic_mp_node_endCamFeedMilitia" )
	waitthread EndCamFeedMilitiaAnim( node )
}

function EndCamFeedMilitiaAnim( node )
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	NodeCleanUp( node )

	local mac 		= CreatePropDynamic( MAC_MODEL, node.pos, node.ang )
	local macgun 	= CreatePropDynamic( MACGUN, node.pos, node.ang )
	local door 		= CreatePropDynamic( DOORIMC64_MODEL, Vector( -9716, 13620, -11776 ), Vector( 0, 0, 0 ) )

	node.ents.append( mac )
	node.ents.append( macgun )
	node.ents.append( door )

	Cl_SetParent( macgun, mac, "PROPGUN" )
	macgun.MarkAsNonMovingAttachment()

	OnThreadEnd(
		function() : ( node )
		{
			foreach ( ent in node.ents )
			{
				if ( IsValid( ent ) )
					ent.Kill()
			}
		}
	)
	mac.EndSignal( "OnDeath" )
	mac.EndSignal( "OnDestroy" )

	thread EndCamFeedMilitiaCam( mac )

	thread PlayAnim( door, "open_idle" )
	delaythread( 1.0 ) PlayAnim( door, "close_slow" )

	waitthread PlayAnimTeleport( mac, "mac_o2_igotthis", node.pos, node.ang )

	local anim = "pt_O2_finale_1stdoor"
	local origin = HackGetDeltaToRef( mac.GetOrigin(), mac.GetAngles(), mac, anim )
	local angles = mac.GetAngles()
	thread PlayAnim( mac, anim, origin, angles )
	delaythread( 3.66 ) PlayAnimDeathCheck( mac, "pt_O2_finale_door_type_idle", origin, angles )

	//Sarah: What the hell are you talking about Mac?! Mac! Come in! Bish, get him back on comms, now!
	PlaySoundAndWait( "diag_hp_story30_O2506_02_01_mcor_sarah" )
	wait 0.5
	//Bish: He’s still transmitting, just not to us. I’m patching into his feed.
	PlaySoundAndWait( "diag_hp_story30_O2506_02a_01_mcor_bish" )

	HideVDU()
}

function EndCamFeedMilitiaCam( mac )
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	local camera = GetCamera()
	local startFov = 15
	camera.SetFOV( startFov )
	thread TrackEntityWithCamera( GetLocalViewPlayer(), Vector( -9513.881836, 13525.928711, -11690 ), mac, 20, 0, 0, 62 )

	wait 2.0
	local endFov = 35
	local zoomTime = 5
	local ease = 2.5
	thread ZoomCameraOverTime( GetLocalViewPlayer(), startFov, endFov, zoomTime, ease, ease )
}

function EndCamFeedIMCMain()
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	//Spyglass: Incoming transmission. It is MacAllan.
	GenericWideScreenVDU( "diag_o2pickups_incTrans_spyglass_01", "spyglass", "spy_VDU_point" )

/*	GenericWideScreenVDU( "diag_hp_story30_O2507_04_01_imc_spygl", "spyglass", "spy_VDU_twitchy" )
	GenericWideScreenVDU( "diag_hp_story30_O2507_04_01_imc_spygl", "spyglass", "spy_VDU_think_slow" )
	GenericWideScreenVDU( "diag_hp_story30_O2507_04_01_imc_spygl", "spyglass", "spy_VDU_think_fast" )
	GenericWideScreenVDU( "diag_hp_story30_O2507_04_01_imc_spygl", "spyglass", "spy_VDU_status" )*/
}

function EndVDUMoment_CamFeedMilitia( node )
{
	thread EndCamFeedMilitiaAnim( node )
}

/************************************************************************************************\

   ###    ##     ## ########  ##     ##  ######  ##     ##
  ## ##   ###   ### ##     ## ##     ## ##    ## ##     ##
 ##   ##  #### #### ##     ## ##     ## ##       ##     ##
##     ## ## ### ## ########  ##     ##  ######  #########
######### ##     ## ##     ## ##     ##       ## ##     ##
##     ## ##     ## ##     ## ##     ## ##    ## ##     ##
##     ## ##     ## ########   #######   ######  ##     ##

setpos -9518 14479 -11771
script_client thread EndAmbushMain()
\************************************************************************************************/
function EndAmbushMain()
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	SetNextVDUWideScreen( GetLocalViewPlayer() )
	local node = GetNodeByUniqueID( "cinematic_mp_node_endAmbush" )
	waitthread EndAmbushAnim( node )
}

function EndAmbushAnim( node )
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	NodeCleanUp( node )

	//anim setup
	local mac 		= CreatePropDynamic( MAC_MODEL, node.pos, node.ang )
	local blisk 	= CreatePropDynamic( BLISK_MODEL, node.pos, node.ang )
	local macgun 	= CreatePropDynamic( MACGUN, node.pos, node.ang )
	local bliskgun 	= CreatePropDynamic( BLISKGUN, node.pos, node.ang )
	local knife		= CreatePropDynamic( KNIFE_MODEL, node.pos, node.ang )
	local door 		= CreatePropDynamic( DOORIMC64_MODEL, Vector( -9716, 14516, -11776 ), Vector( 0, 0, 0 ) )

	//HACK - the door is transparent so spawn these black floor mat models to block the windows.
	local opaque1	= CreatePropDynamic( OPAQUE_PIECE, node.pos, node.ang )
	opaque1.SetParent( door, "DoorLeft" )
	opaque1.MarkAsNonMovingAttachment()
	opaque1.SetAttachOffsetAngles( Vector( 0, 90, 90 ) )
	opaque1.SetAttachOffsetOrigin( Vector( -3, 0, -50 ) )

	local opaque2	= CreatePropDynamic( OPAQUE_PIECE, node.pos, node.ang )
	opaque2.SetParent( door, "DoorRight" )
	opaque2.SetAttachOffsetAngles( Vector( 0, 90, 90 ) )
	opaque2.SetAttachOffsetOrigin( Vector( -3, 0, -50 ) )
	opaque2.MarkAsNonMovingAttachment()

	node.ents.append( mac )
	node.ents.append( blisk )
	node.ents.append( macgun )
	node.ents.append( bliskgun )
	node.ents.append( knife )
	node.ents.append( door )
	node.ents.append( opaque1 )
	node.ents.append( opaque2 )

	Cl_SetParent( macgun, mac, "PROPGUN" )
	Cl_SetParent( bliskgun, blisk, "PROPGUN" )
	Cl_SetParent( knife, blisk, "R_HAND_alt" )
	macgun.MarkAsNonMovingAttachment()
	bliskgun.MarkAsNonMovingAttachment()
	knife.MarkAsNonMovingAttachment()

	//camera setup
	local anim 		= "mac_O2_finale_scene3_1"
	local camera 	= GetCamera()
	local startFov	= 55
	local result 	= GetVDUPosFromAnim( mac, anim )
	local startAng 	= result.angle
	local startOG 	= result.position + Vector( 0,0,3 )

	OnThreadEnd(
		function() : ( node )
		{
			foreach ( ent in node.ents )
			{
				if ( IsValid( ent ) )
					ent.Kill()
			}
		}
	)

	blisk.EndSignal( "OnDeath" )
	blisk.EndSignal( "OnDestroy" )

	//zoom cam in on blisk
	local zoomDelay = 11
	local endFov 	= 7
	local zoomTime 	= 0.75
	local easeIn 	= 0.1
	local easeOut 	= 0.1

	delaythread( 0.2 ) EndAmbushCamInit( camera, startFov )
	delaythread( 0.2 ) TrackEntityWithCamera( GetLocalViewPlayer(), startOG, blisk, 24.25, 0, 0, 62 )
	delaythread( zoomDelay ) ZoomCameraOverTime( GetLocalViewPlayer(), startFov, endFov, zoomTime, easeIn, easeOut )

	//talking and ambush
	thread OpenDoor( door, "open_slow", 8.3 )
	thread PlayAnimTeleport( mac, anim, node.pos, node.ang )
	waitthread PlayAnimTeleport( blisk, "bsk_O2_finale_scene3_1", node.pos, node.ang )

	//take mac out of the scene
	mac.Kill()

	//zoom cam out for blisk
	local zoomReset = 4.0
	local zoomTime 	= 1.5
	local easeIn 	= 0.1
	local easeOut 	= 0.1
	local backFov	= 20
	delaythread( zoomReset ) ZoomCameraOverTime( GetLocalViewPlayer(), endFov, backFov, zoomTime, easeIn, easeOut )

	//blisk takes off after mac
	waitthread PlayAnim( blisk, "bsk_O2_finale_scene3_2", node.pos, node.ang )

	//blisk stops and pulls knife
	thread PlayAnim( door, "close_slow" )
	waitthread PlayAnim( blisk, "bsk_O2_finale_scene3_3", node.pos, node.ang )

	wait 0.25

	HideVDU()
}

function OpenDoor( door, anim, delay )
{
	door.EndSignal( "OnDestroy" )

	wait delay

	PlayAnim( door, anim )
}

function EndAmbushCamInit( camera, startFov )
{
	if ( !IsValid( camera ) )
		return

	camera.SetFogEnable( true )
	camera.SetFOV( startFov )
}

function EndVDUMoment_Ambush( node )
{
	thread EndAmbushAnim( node )
}


/************************************************************************************************\

 ######     ###     ######  ########  #### ######## ####  ######  ########
##    ##   ## ##   ##    ## ##     ##  ##  ##        ##  ##    ## ##
##        ##   ##  ##       ##     ##  ##  ##        ##  ##       ##
 ######  ##     ## ##       ########   ##  ######    ##  ##       ######
      ## ######### ##       ##   ##    ##  ##        ##  ##       ##
##    ## ##     ## ##    ## ##    ##   ##  ##        ##  ##    ## ##
 ######  ##     ##  ######  ##     ## #### ##       ####  ######  ########

setpos -7933.25 14923.3 -12240
script_client thread EndSacrificeMain()
\************************************************************************************************/
function EndSacrificeMain( team )
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	SetNextVDUWideScreen( GetLocalViewPlayer() )
	waitthread StartReactorRoomFx()

	local node = GetNodeByUniqueID( "cinematic_mp_node_endSacrifice" )
	waitthread EndSacrificeAnim( node, team  )

	KillReactorRoomFx()
}

function EndSacrificeAnim( node, team )
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	FlagClear( "SacrificeDone" )
	FlagClear( "SacrificeHideCam" )

	local child = clone node.childNodes[ 0 ]
	NodeCleanUp( node )
	NodeCleanUp( child )

	//anim setup
	local mac 		= CreatePropDynamic( MAC_MODEL, node.pos, node.ang )
	local rod 		= CreatePropDynamic( O2FUELROD, node.pos, node.ang )
	local blisk 	= CreatePropDynamic( BLISK_MODEL, child.pos, child.ang )
	local knife 	= CreatePropDynamic( KNIFE_MODEL, child.pos, child.ang )

	blisk.clHide()
	knife.clHide()
	node.ents.append( mac )
	node.ents.append( rod )
	node.ents.append( blisk )
	node.ents.append( knife )

	Cl_SetParent( knife, blisk, "R_HAND_alt" )
	knife.MarkAsNonMovingAttachment()

	thread EndSacrificeCam( blisk, mac )

	OnThreadEnd(
		function() : ( node )
		{
			foreach ( ent in node.ents )
			{
				if ( IsValid( ent ) )
					ent.Kill()
			}
		}
	)

	mac.EndSignal( "OnDeath" )
	mac.EndSignal( "OnDestroy" )

	thread EndSacrificeDialogue( team )
	thread EndSacrificeMacAnim( mac, rod, node )

	delaythread( 35.5 ) FlagSet( "SacrificeHideCam")

	wait 9.0
	thread PlayAnimTeleport( blisk, "bsk_O2_finale_scene5", child.pos, child.ang )

	wait 0.2
	blisk.clShow()
	knife.clShow()

	blisk.clWaittillAnimDone()
	blisk.Kill()

	FlagWait( "SacrificeHideCam" )
	//HideVDU()

	FlagWait( "SacrificeDone" )
}

function EndSacrificeMacAnim( mac, rod, node )
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	delaythread( 23 ) DestabilizeTheCore()

	thread PlayAnim( rod, "fr_O2_finale_scene4_1", node.pos, node.ang )
	waitthread PlayAnim( mac, "mac_O2_finale_scene4_1", node.pos, node.ang )
}

function DestabilizeTheCore()
{
	GetLocalViewPlayer().ClientCommand( "CoreDestabalizedOnServer" )
	FlagSet( "CoreDestabalized" )
	UpdateTowerExplosions()
}

function EndSacrificeCam( blisk, mac )
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	local camera 	= GetCamera()
	local startFov	= 45

	local origin 	= Vector( -7933.196289, 14908.385742, -12188.457031 )
	local baseAng 	= Vector( -1.892641, 89.965431, -0.196869 )

	wait 0.1

	ShowVDU()

	camera.SetOrigin( origin )
	camera.SetAngles( baseAng )
	camera.SetFogEnable( true )
	camera.SetFOV( startFov )

	wait 2.5

	//pan left to mac...
	local rotTime 	= 0.5
	local ease 		= 0.15
	local startAng	= baseAng
	local endAng	= baseAng + Vector( 0, 6, 0 )
	thread RotateCameraOverTime( GetLocalViewPlayer(), startAng, endAng, rotTime, ease, ease )
	//...then pan right with him
	local delay 	= rotTime + 0.1
	local rotTime 	= 1.5
	local ease		= 0.5
	local startAng	= endAng
	local endAng 	= baseAng + Vector( 0, 3, 0 )
	delaythread( delay ) RotateCameraOverTime( GetLocalViewPlayer(), startAng, endAng, rotTime, ease, ease )

	//zoom in on mac
	local zoomTime 	= 1.0
	local ease 		= 0.5
	local endFov	= 10
	thread ZoomCameraOverTime( GetLocalViewPlayer(), startFov, endFov, zoomTime, ease, ease )

	wait 5.0

	//pan up when mac picks up the thing
	local rotTime 	= 1.0
	local ease 		= rotTime * 0.5
	local startAng	= endAng
	local endAng	= startAng + Vector( -3, 0, 0 )
	thread RotateCameraOverTime( GetLocalViewPlayer(), startAng, endAng, rotTime, ease, ease )

	wait 1.0

	//pan down as he drops it
	local rotTime 	= 1.0
	local ease 		= rotTime * 0.5
	local startAng	= endAng
	local endAng	= startAng + Vector( 1, 0, 0 )
	thread RotateCameraOverTime( GetLocalViewPlayer(), startAng, endAng, rotTime, ease, ease )

	wait 1.0

	//rotate left to blisk...
	local rotTime 	= 1.0
	local ease 		= 0.5
	local startAng	= endAng
	local endAng 	= baseAng + Vector( 0, 12, 0 )
	thread RotateCameraOverTime( GetLocalViewPlayer(), startAng, endAng, zoomTime, ease, ease )

	//zoom out on blisk
	local zoomTime 	= 1.0
	local ease 		= 0.5
	local startFov 	= endFov
	local endFov	= 22
	thread ZoomCameraOverTime( GetLocalViewPlayer(), startFov, endFov, zoomTime, ease, ease )

	wait 1.0

	//...then pan right with him
	local rotTime 	= 0.75
	local ease		= 0.25
	local startAng	= endAng
	local endAng	= baseAng + Vector( 0, 4, 0 )
	thread RotateCameraOverTime( GetLocalViewPlayer(), startAng, endAng, rotTime, ease, ease )

	wait 1.0

	//zoom in on blisk and mac
	local zoomTime 	= 5.0
	local ease 		= 1.5
	local startFov 	= endFov
	local endFov 	= 15
	thread ZoomCameraOverTime( GetLocalViewPlayer(), startFov, endFov, zoomTime, ease, ease )

	wait 8.0

	//zoom out on blisk leaving
	local zoomTime 	= 5.0
	local ease 		= 2.5
	local startFov 	= endFov
	local endFov	= 20
	thread ZoomCameraOverTime( GetLocalViewPlayer(), startFov, endFov, zoomTime, ease, ease )

	thread ShakeCamera( GetLocalViewPlayer(), origin, 0.75, 50, 20 )

	wait 4.5

	//zoom in on mac's face
	local zoomTime 	= 0.5
	local ease 		= 0.1
	local startFov 	= endFov
	local endFov	= 3
	thread ZoomCameraOverTime( GetLocalViewPlayer(), startFov, endFov, zoomTime, ease, ease )

	//back up
	local delayTime = zoomTime
	local zoomTime 	= 0.1
	local ease 		= 0.0
	local startFov 	= endFov
	local endFov	= startFov + 2
	delaythread( delayTime ) ZoomCameraOverTime( GetLocalViewPlayer(), startFov, endFov, zoomTime, ease, ease )

	//settle
	local delayTime = delayTime + zoomTime
	local zoomTime 	= 0.1
	local ease 		= 0.0
	local startFov 	= endFov
	local endFov	= startFov - 1
	delaythread( delayTime ) ZoomCameraOverTime( GetLocalViewPlayer(), startFov, endFov, zoomTime, ease, ease )

	//pan over to mac
	local rotTime 	= 0.75
	local ease		= 0.25
	local startAng	= endAng
	local endAng	= startAng + Vector( -0.5, -3, 0 )
	waitthread RotateCameraOverTime( GetLocalViewPlayer(), startAng, endAng, rotTime, ease, ease )
}

function EndSacrificeReactorCam( doPan = true )
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	GetLocalViewPlayer().Signal( "ShakeCamera" )

	local trackStart	= Vector( -355, 272, 50 )
	local trackEnd		= Vector( -355, 272, 700 )
	local origin 		= Vector( -355, 272, 90 )
	local startAng 		= Vector( -20, 210, 0 )
	local endAng 		= Vector( 10, 45, 0 )
	local startRadius	= 400
	local endRadius		= 450
	local pivotTime 	= 6
	local ease 			= 2
	local startFov 		= 30
	local endFov 		= 70

	if ( doPan )
	{
		local tracker = CreateClientsideScriptMover( "models/dev/empty_model.mdl", trackStart, Vector( 0, 0, 0 ) )

		thread TrackEntityWithMovingCamera( GetLocalViewPlayer(), tracker, pivotTime )
		thread PivotCameraOverTime( GetLocalViewPlayer(), origin, startAng, endAng, startRadius, endRadius, pivotTime, ease, ease )
		thread ZoomCameraOverTime( GetLocalViewPlayer(), startFov, endFov, pivotTime, ease, ease )

		wait 1.0

		tracker.NonPhysicsMoveTo( trackEnd, pivotTime, ease, ease )
		wait pivotTime - 1.0
		tracker.Kill()
	}
	else
	{
		local camera 	= GetCamera()
		camera.SetOrigin( Vector( -41.636108, 585.363892, 11.858322 ) )
		camera.SetAngles( Vector( -54.933014, -134.972336, 0.000000 ) )
		camera.SetFOV( endFov )
	}

	local camera 	= GetCamera()
	local startLook = camera.GetAngles()
	local endLook  	= Vector( -89, startLook.y, 0 )
	local speed 	= 400.0

	//calculate where I want to be and when
	local startOrg 	= camera.GetOrigin()
	local dist 		= 300.0
	local time 		= dist / speed
	local endOrg 	= startOrg + ( startLook.AnglesToForward() * dist )

	//calculate a pivot point based on where I am and where I want to be
	local pivOrg 	= Vector( startOrg.x, startOrg.y, endOrg.z )
	local endAng 	= VectorToAngles( endOrg - pivOrg )
	local endRad 	= Distance( endOrg, pivOrg )
	local startAng  = VectorToAngles( startOrg - pivOrg )
	startAng 		= Vector( startAng.x, endAng.y, startAng.z )
	local startRad  = Distance( startOrg, pivOrg )

	//calculate the Circumference of the elipse and the time to travel it
	local circ 		= CalcualteCircumference( pivOrg, startOrg, endOrg, startRad, endRad )
	local time 		= circ / speed

	//pivot and rotate the camera into the shaft
	thread RotateCameraOverTime( GetLocalViewPlayer(), startLook, endLook, time, time, 0 )
	waitthread PivotCameraOverTime( GetLocalViewPlayer(), pivOrg, startAng, endAng, startRad, endRad, time, time, 0 )

	//move the camera up through the shaft
	local dist 		= 600.0
	local time 		= dist / speed
	local startOrg 	= endOrg
	local endOrg 	= startOrg + Vector( 0, 0, dist )
	waitthread MoveCameraOverTime( GetLocalViewPlayer(), startOrg, endOrg, time, 0, 0 )

	//calculate a pivot point behind the camera and an end point above that
	local startLook = endLook
	local endLook 	= Vector( -25, startLook.y, 0 )
	local startOrg 	= endOrg
	local ang 		= Vector( 0, startLook.y, 0 )
	local back 		= -1100
	local up 		= 1000
	local pivOrg 	= startOrg + ( ang.AnglesToForward() * back )
	local endOrg 	= pivOrg + Vector( 0, 0, up )

	//calculate the rest of the pivot
	local startAng  = VectorToAngles( startOrg - pivOrg )
	local startRad  = Distance( startOrg, pivOrg )
	local endAng 	= VectorToAngles( endOrg - pivOrg )
	endAng 			= Vector( -90, startAng.y, endAng.z )
	local endRad 	= Distance( endOrg, pivOrg )

	//figure out how fast I should get there
	local circ 		= CalcualteCircumference( pivOrg, startOrg, endOrg, startRad, endRad )
	local time 		= circ / speed

	//pivot and rotate the camera out of the shaft
	thread RotateCameraOverTime( GetLocalViewPlayer(), startLook, endLook, time, 0, time )
	waitthread PivotCameraOverTime( GetLocalViewPlayer(), pivOrg, startAng, endAng, startRad, endRad, time, 0, time )
}

function EndSacrificeDialogue( team )
{
	if ( ShouldNotWatch() )
		return
	GetLocalClientPlayer().EndSignal( "OnDestroy" )

	local destabilizeTime = 33.5
	local camTime = 0.5
	switch( team )
	{
		case TEAM_MILITIA:
			//Sarah: Oh no.
			delaythread( 3.0 ) EmitSoundOnEntity( GetLocalViewPlayer(), "diag_hp_story40_O2508_02_01_mcor_sarah" )
			//Bish: What?! (checks the screen) Aww no, Mac, you crazy son of a bitch, get out of there! Get out of there!
			//BISH: Dammit mac you crazy son of a bitch. What the hell are you doing?
			delaythread( 5.0 ) EmitSoundOnEntity( GetLocalViewPlayer(), "diag_hp_story40_O2508_03_01_mcor_bish_V2" )

			wait destabilizeTime - camTime
			thread EndSacrificeReactorCam( false )
			wait camTime

			//Sarah: All ships, the core is going critical! Lock in your jump coordinates, and prepare the evac crews.
			PlaySoundAndWait( "diag_hp_story40_O2508_03b_01_mcor_sarah" )
			wait 1.0
			break

		case TEAM_IMC:
			//graves: MacAllan, you fool.
			delaythread( 4.5 ) EmitSoundOnEntity( GetLocalViewPlayer(), "diag_hp_story40_O2509_02a_01_imc_graves" )

			wait destabilizeTime - camTime
			thread EndSacrificeReactorCam()
			wait camTime

			//SpyGlass: Colonel Graves, MacAllan has destabilized the core. Shutting down the reactor at this stage will cause a reverse pulse detonation and the destruction of Demeter. The situation is untenable.
			PlaySoundAndWait( "diag_hp_story40_O2510_03_01_imc_spygl" )
			wait 0.5
			break
	}

	FlagSet( "SacrificeDone" )
}

function EndVDUMoment_Sacrifice( node )
{
	thread EndSacrificeAnim( node )
}

/************************************************************************************************\

##    ##  #######        ######## ##     ##    ###     ######        ##     ##  ######   #######  ########
###   ## ##     ##       ##       ##     ##   ## ##   ##    ##       ###   ### ##    ## ##     ## ##     ##
####  ## ##     ##       ##       ##     ##  ##   ##  ##             #### #### ##       ##     ## ##     ##
## ## ## ##     ##       ######   ##     ## ##     ## ##             ## ### ## ##       ##     ## ########
##  #### ##     ##       ##        ##   ##  ######### ##             ##     ## ##       ##     ## ##   ##
##   ### ##     ##       ##         ## ##   ##     ## ##    ##       ##     ## ##    ## ##     ## ##    ##
##    ##  #######        ########    ###    ##     ##  ######        ##     ##  ######   #######  ##     ##

setpos -7933.25 14923.3 -12240
script_client thread EndNoEvacMilitiaMain()
\************************************************************************************************/
function EndNoEvacMilitiaMain()
{
	local node = GetNodeByUniqueID( "cinematic_mp_node_endDeath" )

	thread StartReactorRoomFx()
	waitthread EndNoEvacMilitiaLeadIn()

	SetNextVDUWideScreen( GetLocalViewPlayer() )
	waitthread EndNoEvacMilitiaAnim( node )

	KillReactorRoomFx()
}

function EndNoEvacMilitiaAnim( node )
{
	NodeCleanUp( node )

	//anim setup
	local mac 		= CreatePropDynamic( MAC_MODEL, node.pos, node.ang )
	node.ents.append( mac )

	//camera setup
	InitDeathCam()
	local camera 	= GetCamera()
	local startFov = 20
	local endFov = 15
	local zoomTime = 10
	local ease = 2.0
	camera.SetFOV( startFov )
	delaythread( 1.5 ) ZoomCameraOverTime( GetLocalViewPlayer(), startFov, endFov, zoomTime, ease, ease )
	thread ShakeCamera( GetLocalViewPlayer(), camera.GetOrigin(), SHAKEAMP, SHAKEFREQ, 40 )

	OnThreadEnd(
		function() : ( node )
		{
			foreach ( ent in node.ents )
			{
				if ( IsValid( ent ) )
					ent.Kill()
			}
		}
	)

	mac.EndSignal( "OnDeath" )

	thread PlayAnimTeleport( mac, "macal_O2_finale_scene5_2_Militia", node.pos, node.ang )

	wait 41.0

	NukeCam()
}

function EndNoEvacMilitiaLeadIn()
{
	ShowVDU()
	//Sarah: Pilots, the core is going critical.  We’re sending evac ships to your location. Find MacAllan and get the hell out of there.
	GenericWideScreenVDU( null, "sarah", "diag_matchEnd_O2514_09b_01_mcor_sarah" )
}

function EndNoEvacMilitiaLeadOut()
{
	//Bish: Sarah…
	PlaySoundAndWait( "diag_epMid_O2519a_04_01_mcor_bish" )
	//Sarah: Already on it.
	PlaySoundAndWait( "diag_epMid_O2519a_05_01_mcor_sarah" )
}

function EndVDUMoment_Death( node )
{
	thread EndNoEvacMilitiaAnim( node )
}

/************************************************************************************************\

##    ##  #######        ######## ##     ##    ###     ######        #### ##     ##  ######
###   ## ##     ##       ##       ##     ##   ## ##   ##    ##        ##  ###   ### ##    ##
####  ## ##     ##       ##       ##     ##  ##   ##  ##              ##  #### #### ##
## ## ## ##     ##       ######   ##     ## ##     ## ##              ##  ## ### ## ##
##  #### ##     ##       ##        ##   ##  ######### ##              ##  ##     ## ##
##   ### ##     ##       ##         ## ##   ##     ## ##    ##        ##  ##     ## ##    ##
##    ##  #######        ########    ###    ##     ##  ######        #### ##     ##  ######

setpos -7933.25 14923.3 -12240
script_client thread EndNoEvacIMCMain()
\************************************************************************************************/
function EndNoEvacIMCMain()
{
	local node = GetNodeByUniqueID( "cinematic_mp_node_endDeath" )

	thread StartReactorRoomFx()
	waitthread EndNoEvacIMCLeadIn()

	SetNextVDUWideScreen( GetLocalViewPlayer() )
}

function EndNoEvacIMCLeadIn()
{
	delaythread( 0.0 ) ShowVDU()
	//Pilots, the core is going critical. We’re sending evac ships to your location. We’re gonna get you out of there.
	GenericWideScreenVDU( null, "graves", "diag_matchEnd_O2516a_01_01_imc_graves" )
	//Negative - executing command override.  Evacuation dropships - cancelled.
	GenericWideScreenVDU( "diag_matchEnd_O2516a_02a_01_imc_spygl", "spyglass", "spy_VDU_think_fast" )
	//Dammit Spyglass! ( banging his fists on his console ) What the hell do you think you’re doing.
	GenericWideScreenVDU( null, "graves", "diag_matchEnd_O2516a_05_01_imc_graves" )
	//All Capital ships –auto pilot engaged. Forcing jump to minimum safe distance.
	GenericWideScreenVDU( "diag_matchEnd_O2516a_06_01_imc_spygl", "spyglass", "spy_VDU_status" )
}


/************************************************************************************************\

########  ########  ######   #######  ########  ########  #### ##    ##  ######
##     ## ##       ##    ## ##     ## ##     ## ##     ##  ##  ###   ## ##    ##
##     ## ##       ##       ##     ## ##     ## ##     ##  ##  ####  ## ##
########  ######   ##       ##     ## ########  ##     ##  ##  ## ## ## ##   ####
##   ##   ##       ##       ##     ## ##   ##   ##     ##  ##  ##  #### ##    ##
##    ##  ##       ##    ## ##     ## ##    ##  ##     ##  ##  ##   ### ##    ##
##     ## ########  ######   #######  ##     ## ########  #### ##    ##  ######

setpos -7933.25 14923.3 -12240
script_client thread EndFinaleMain( TEAM_IMC )
script_client thread EndFinaleMain( TEAM_MILITIA )
\************************************************************************************************/
function EndRecordingMain()
{
	wait 1.0

	//If we go head to head, only one of us lives, Marcus.
	PlaySoundAndWait( "diag_epMid_O2520_03_01_imc_macal" )
	//Then we go our separate ways, Mac. Take the ship.
	//PlaySoundAndWait( "diag_epMid_O2520_04_01_imc_graves" )
	//I won't fight you, Mac. Take the ship.
	PlaySoundAndWait( "diag_epMid_O2520_04a_01_imc_graves" )

	wait 1.0
}

/************************************************************************************************\

######## #### ##    ##    ###    ##       ########
##        ##  ###   ##   ## ##   ##       ##
##        ##  ####  ##  ##   ##  ##       ##
######    ##  ## ## ## ##     ## ##       ######
##        ##  ##  #### ######### ##       ##
##        ##  ##   ### ##     ## ##       ##
##       #### ##    ## ##     ## ######## ########

setpos -7933.25 14923.3 -12240
script_client thread EndFinaleMain( TEAM_IMC )
script_client thread EndFinaleMain( TEAM_MILITIA )
\************************************************************************************************/
function EndFinaleIMCMain()
{
	local node = GetNodeByUniqueID( "cinematic_mp_node_endDeath" )

	waitthread EndFinaleAnimIMC( node )
	KillReactorRoomFx()
}

function EndFinaleAnimIMC( node )
{
	NodeCleanUp( node )

	//anim setup
	local mac 		= CreatePropDynamic( MAC_MODEL, node.pos, node.ang )
	node.ents.append( mac )

	//camera setup
	InitDeathCam( 1 )
	local camera 	= GetCamera()
	local startFov = 20
	local endFov = 15
	local zoomTime = 10
	local ease = 2.0
	camera.SetFOV( startFov )
	local angles = camera.GetAngles()
	delaythread( 1.5 ) ZoomCameraOverTime( GetLocalViewPlayer(), startFov, endFov, zoomTime, ease, ease )
	delaythread( 22 ) RotateCameraOverTime( GetLocalViewPlayer(), angles, angles + Vector( -3, 0, 0 ), 2.0, 1.0, 1.0 )
	thread ShakeCamera( GetLocalViewPlayer(), camera.GetOrigin(), SHAKEAMP, SHAKEFREQ, 35 )

	OnThreadEnd(
		function() : ( node )
		{
			foreach ( ent in node.ents )
			{
				if ( IsValid( ent ) )
					ent.Kill()
			}
		}
	)

	mac.EndSignal( "OnDeath" )

	thread PlayAnimTeleport( mac, "macal_O2_finale_scene5_2_IMC", node.pos, node.ang )

	wait 28.3

	NukeCam()
}


function NukeCam()
{
	local camera = GetCamera()
	local origin = camera.GetOrigin() + ( camera.GetAngles().AnglesToForward() * 50 )
	local angles = camera.GetAngles() + Vector( 0, 180, 0 )

	local fx = GetParticleSystemIndex( FX_NUKE_SKYBOX )

	StartParticleEffectInWorld( fx, origin, angles )

	wait 1.5
	GetLocalViewPlayer().Signal( "ShakeCamera" )
}

/************************************************************************************************\

##    ##  #######  ########  ########       ########  #######   #######  ##        ######
###   ## ##     ## ##     ## ##                ##    ##     ## ##     ## ##       ##    ##
####  ## ##     ## ##     ## ##                ##    ##     ## ##     ## ##       ##
## ## ## ##     ## ##     ## ######            ##    ##     ## ##     ## ##        ######
##  #### ##     ## ##     ## ##                ##    ##     ## ##     ## ##             ##
##   ### ##     ## ##     ## ##                ##    ##     ## ##     ## ##       ##    ##
##    ##  #######  ########  ########          ##     #######   #######  ########  ######

\************************************************************************************************/
function GetVDUPosFromAnim( model, anim, tag = "VDU" )
{
	return model.Anim_GetAttachmentAtTime( anim, tag, 0.0 )
}

function NodeCleanUp( node )
{
	if ( DEV_EDITOR )
	{
		node.pos += Vector( 0,0,20 )
		local result = TraceLine( node.pos, node.pos + Vector( 0,0,-200 ), null, TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE )
		node.pos = result.endPos
	}

	if ( !( "ents" in node ) )
		node.ents <- []

	foreach ( ent in node.ents )
	{
		if ( IsValid( ent ) )
			ent.Kill()
	}

	node.ents = []
}

function GetCamera()
{
	return level.camera
}

function LockStoryVDU( widescreen = true )
{
	if ( Flag( "StoryVDU" ) )
		FlagWaitClear( "StoryVDU" )

	FlagSet( "StoryVDU" )

	if ( !IsLockedVDU() )
		LockVDU()

	HideVDU()

	if ( widescreen )
		SetNextVDUWideScreen( GetLocalViewPlayer() )
}

function UnlockStoryVDU()
{
	DelayedUnlockVDU( FORCEDIALOGUEBUFFER )
	FlagClear( "StoryVDU" )
}

function InitDeathCam( pitch = -1.5, yaw = 192, roll = 0 )
{
	local node = GetNodeByUniqueID( "cinematic_mp_node_endDeath" )
	local origin = node.pos + ( node.ang.AnglesToForward() * 100 ) + ( node.ang.AnglesToRight() * -20 ) + Vector( 0, 0, 20 )
	local angles = node.ang + Vector( pitch, yaw, roll )
	local camera 	= GetCamera()
	camera.SetOrigin( origin )
	camera.SetAngles( angles )
	camera.SetFogEnable( true )
}

function Cl_SetParent( ent, _parent, tag = "", keepOffset = false, time = 0.0 )
{
	ent.SetParent( _parent, tag, keepOffset, time )

	if ( ( tag != "" ) && !keepOffset )
	{
		ent.SetAttachOffsetAngles( Vector( 0, 0, 0 ) )
		ent.SetAttachOffsetOrigin( Vector( 0, 0, 0 ) )
	}
}

function StartReactorRoomFx( getFuncID = GETREACTORFXFUNC.DEFAULT )
{
	KillReactorRoomFx()

	local effectIndexSteam = GetParticleSystemIndex( FXVDU_REACTOR_STEAM )

	local getFunc = GetReactorRoomGetFunc( getFuncID )

	local origins = getFunc()
	local angles = Vector( 90, 0, 0 )

	foreach( origin in origins )
		level.reactorRoomFx.append( StartParticleEffectInWorldWithHandle( effectIndexSteam, origin, angles ) )

	wait 0.25//give time for the effect to build up
}

function KillReactorRoomFx()
{
	foreach( handle in level.reactorRoomFx )
		EffectStop( handle, true, false )

	level.reactorRoomFx = []
}

function GetReactorRoomGetFunc( getFuncID )
{
	local getFunc

	switch( getFuncID )
	{
		 case GETREACTORFXFUNC.DEFAULT:
		 	getFunc = GetReactorRoomFXOrigins
		 	break
		 case GETREACTORFXFUNC.CAMDOWN:
		 	getFunc = GetReactorRoomFXOriginsCamDown
		 	break
	}

	return getFunc
}

function GetReactorRoomFXOrigins()
{
	local array = []
	local height = Vector( 0, 0, 64 )

	array.append( Vector( -8000.788574, 15293.817383, -12147.968750 ) + height )
	array.append( Vector( -7988.983887, 15501.793945, -12147.968750 ) + height )
	array.append( Vector( -7826.915527, 15471.487305, -12147.968750 ) + height )
	array.append( Vector( -7823.000977, 15294.583984, -12147.969727 ) + height )
	array.append( Vector( -7825.615234, 15321.950195, -12147.968750 ) + height )
	array.append( Vector( -7895.805176, 15481.934570, -12147.967773 ) + height )
	array.append( Vector( -7904.142090, 15242.507813, -12147.968750 ) + height )

	return array
}

function GetReactorRoomFXOriginsCamDown()
{
	local array = []
	local height = Vector( 0, 0, 64 )

	array.append( Vector( -7988.028320, 15401.083008, -12147.968750  ) + height )

	return array
}

function PlaySoundAndWait( alias, extraWait = 0 )
{
	local duration = EmitSoundOnEntity( GetLocalViewPlayer(), alias )
	wait duration + MINWAITBETWEENLINES + extraWait
}

function GenericWideScreenVDU( alias, name, anim = DEFAULT_VDU_ANIM )
{
	local player = GetLocalViewPlayer()
	ClearVDUCharacter( player )
	CreateVDUCharacter( player, name, anim )

	if ( anim && alias )
		PlaySoundAndWait( alias )

	else if ( anim && !alias )
		wait level._vduCharacter.GetSequenceDuration( anim )
}

function ShouldNotWatch()
{
	if ( GetLocalClientPlayer() != GetLocalViewPlayer() )
		return true
	if ( IsWatchingKillReplay() )
		return true

	return false
}

function PlayAnimDeathCheck( guy, animation_name, reference = null, optionalTag = null, blendTime = DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME, initialTime = -1.0 )
{
	if ( !IsValid( guy ) )
		return
	PlayAnim( guy, animation_name, reference, optionalTag, blendTime, initialTime )
}