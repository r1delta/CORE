function main()
{
	FlagInit( "IMCIntroTitansReady1" )
	FlagInit( "MCORIntroTitansReady1" )

	Globalize( AB_IntroCP )
}

function AB_IntroCP()
{
	thread AB_IntroIMCCP()
	thread AB_IntroMilitiaCP()

	FlagWait( "IMCIntroTitansReady1" )
	FlagWait( "MCORIntroTitansReady1" )

	FlagSet( "IntroDone" )
}

///////////////////////////////////////////////////////////////////////
//
//								IMC
//
///////////////////////////////////////////////////////////////////////

function AB_IntroIMCCP()
{
	thread IntroGravesTempDialogue( GetEnt( "IMCIntroCPDialoguepoint" ) )

	local baseTime = INTROCUSTOMLENGTH_CP - 4.0

	delaythread( baseTime + 2.0 ) AB_IntroAITitanDrop( "#NPC_SGT_ALAVI", TEAM_IMC, "imcMCORCPDroppilot1", "IntroIMCCPDrop1", "IMCIntroTitansReady1" )
	delaythread( baseTime + 1.0 ) AB_IntroAIDropPod( TEAM_IMC, "IMCIntroDP6", 0 )
	delaythread( baseTime + 2.0 ) AB_IntroAIDropPod( TEAM_IMC, "IMCIntroDP7", 1 )
	delaythread( baseTime + 2.5 ) AB_IntroAIDropPod( TEAM_IMC, "IMCIntroDP8", 2 )
}

function IntroGravesTempDialogue( ent )
{
	ent.EndSignal( "OnDeath" )

	wait 0.2
	EmitSoundOnEntity( ent, "diag_imc_graves_cmp_airbase_lobby5_03" )
	wait 5.5
	EmitSoundOnEntity( ent, "diag_imc_graves_cmp_airbase_lobby5_07" )
}


///////////////////////////////////////////////////////////////////////
//
//								MILITIA
//
///////////////////////////////////////////////////////////////////////

function AB_IntroMilitiaCP()
{
	thread MCORIntroDialogue( GetEnt( "MCORIntroCPDialoguepoint" ) )

	local baseTime = INTROCUSTOMLENGTH_CP - 4.0

	delaythread( baseTime + 2.0 ) AB_IntroAITitanDrop( "Cpl. Kraber", TEAM_MILITIA, "IntroMCORCPDroppilot", "IntroMCORCPDrop", "MCORIntroTitansReady1", "mp_titanweapon_rocket_launcher" )
	delaythread( baseTime + 1.0 ) AB_IntroAIDropPod( TEAM_MILITIA, "MCORIntroDP3", 0 )
	delaythread( baseTime + 2.0 ) AB_IntroAIDropPod( TEAM_MILITIA, "MCORIntroDP4", 1 )
	delaythread( baseTime + 2.5 ) AB_IntroAIDropPod( TEAM_MILITIA, "MCORIntroDP5", 2 )
}

function MCORIntroDialogue( ent )
{
	ent.EndSignal( "OnDeath" )

	wait 0.5

	EmitSoundOnEntity( ent, "diag_mcor_mac_airbase_temp_03" )
	wait 1.5

	EmitSoundOnEntity( ent, "diag_mcor_mac_airbase_temp_02" )
	wait 5.5

	EmitSoundOnEntity( ent, "diag_mcor_mac_airbase_temp_05" )
}