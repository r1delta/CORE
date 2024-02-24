

function Mp_Mia_main()
{
	if ( reloadingScripts )
		return
	IncludeFile( "mp_mia_shared" )
	IncludeFile( "mp/mp_mia_skyshow" )

	FlagInit( "Mia_Match01Percent" )
	FlagInit( "Mia_Match15Percent" )
	FlagInit( "Mia_Match25Percent" )
	FlagInit( "Mia_Match40Percent" )
	FlagInit( "Mia_Match45Percent" )
	FlagInit( "Mia_Match60Percent" )
	FlagInit( "Mia_Match80Percent" )
	FlagInit( "Mia_Match90Percent" )
	FlagInit( "Mia_Match98Percent" )

	PrecacheWeapon( "mp_weapon_mega_turret_aa" )

	level.IntroRefs 				<- {}
	level.IntroRefs[ TEAM_IMC ] 	<- []
	level.IntroRefs[ TEAM_MILITIA ] <- []
	level.progressDialogPlayed 		<- {}
	level.atmosOKFX 				<- null
	level.atmosBurnFX 				<- null

	MatchProgressSetup()

}

function EntitiesDidLoad()
{
	if ( !IsServer() )
		return

	FlagWait( "ReadyToStartMatch" )
	

	thread Mia_SkyShowMain()
	thread MatchProgressMilestones()
}

/************************************************************************************************\

##     ##    ###    ########  ######  ##     ##       ########  ########   #######   ######   ########  ########  ######   ######
###   ###   ## ##      ##    ##    ## ##     ##       ##     ## ##     ## ##     ## ##    ##  ##     ## ##       ##    ## ##    ##
#### ####  ##   ##     ##    ##       ##     ##       ##     ## ##     ## ##     ## ##        ##     ## ##       ##       ##
## ### ## ##     ##    ##    ##       #########       ########  ########  ##     ## ##   #### ########  ######    ######   ######
##     ## #########    ##    ##       ##     ##       ##        ##   ##   ##     ## ##    ##  ##   ##   ##             ##       ##
##     ## ##     ##    ##    ##    ## ##     ##       ##        ##    ##  ##     ## ##    ##  ##    ##  ##       ##    ## ##    ##
##     ## ##     ##    ##     ######  ##     ##       ##        ##     ##  #######   ######   ##     ## ########  ######   ######


\************************************************************************************************/
function MatchProgressSetup()
{
	GM_SetMatchProgressAnnounceFunc( MatchProgressUpdate )
}

// Only send important major milestones to client
function MatchProgressMilestones()
{
	FlagWait( "Mia_Match01Percent" )
	level.nv.matchProgressMilestone = 1

	FlagWait( "Mia_Match15Percent" )
	level.nv.matchProgressMilestone = 15

	FlagWait( "Mia_Match25Percent" )
	level.nv.matchProgressMilestone = 25

	FlagWait( "Mia_Match40Percent" )
	level.nv.matchProgressMilestone = 40

	FlagWait( "Mia_Match45Percent" )
	level.nv.matchProgressMilestone = 45

	FlagWait( "Mia_Match60Percent" )
	level.nv.matchProgressMilestone = 60

	FlagWait( "Mia_Match80Percent" )
	level.nv.matchProgressMilestone = 80

	FlagWait( "Mia_Match90Percent" )
	level.nv.matchProgressMilestone = 90

	FlagWait( "Mia_Match98Percent" )
	level.nv.matchProgressMilestone = 98
}

function MatchProgressUpdate( percentComplete )
{
	Assert( GetGameState() == eGameState.Playing )

	if ( level.devForcedWin )
		return

	// Set some progress flags - used for narrative & skyshow
	if( !Flag( "Mia_Match01Percent" )&& percentComplete >= 1 )
		FlagSet( "Mia_Match01Percent" )

	if( !Flag( "Mia_Match15Percent" )&& percentComplete >= 15 )
		FlagSet( "Mia_Match15Percent" )

	if( !Flag( "Mia_Match25Percent" )&& percentComplete >= 25 )
		FlagSet( "Mia_Match25Percent" )

	if( !Flag( "Mia_Match40Percent" ) && percentComplete >= 40 )
		FlagSet( "Mia_Match40Percent" )

	if( !Flag( "Mia_Match45Percent" ) && percentComplete >= 45 )
		FlagSet( "Mia_Match45Percent" )

	if( !Flag( "Mia_Match60Percent" ) && percentComplete >= 60 )
		FlagSet( "Mia_Match60Percent" )

	if( !Flag( "Mia_Match80Percent" ) && percentComplete >= 80 )
		FlagSet( "Mia_Match80Percent" )

	if( !Flag( "Mia_Match90Percent" ) && percentComplete >= 90 )
		FlagSet( "Mia_Match90Percent" )

	if( !Flag( "Mia_Match98Percent" ) && percentComplete >= 98 )
		FlagSet( "Mia_Match98Percent" )

	// On top of the custom stuff, we want the default announcements, so call default announcements
	DefaultMatchProgressionAnnouncement( percentComplete )
}

Mp_Mia_main()

