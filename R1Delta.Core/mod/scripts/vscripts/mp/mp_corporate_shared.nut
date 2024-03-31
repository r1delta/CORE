

function main()
{
	if ( reloadingScripts )
		return

	Globalize( IntroSkit )
	Globalize( IntroWalker )
	Globalize( SpawnIntroNPC )
	Globalize( SpectreSetTeam )
	Globalize( DeleteIfValid )


}

//////////////////////////////////////////////////////////////////////////////////////
function IntroSkit( skitType, squadName, pos, ang, team, walkPos = null, flagTrigger = null, delay = 0, func = null )
{
	//---------------------------------
	// Quick ground intro skits for IMC/Militia
	//---------------------------------

	local actors = []
	local waitTillActorFinishes = null

	switch ( skitType )
	{
		case "spectreZombie":
			//Spectre
			actors.append( SpawnIntroNPC( "spectre", UniqueString(), GetTeamIndex(GetOtherTeams(1 << team)), pos, ang, true ) )
			actors[ 0 ].s.idle <- "sp_spectre_zombiedrag_idle"
			actors[ 0 ].s.actions <- []
			actors[ 0 ].s.actions.append( "sp_spectre_zombiedrag" )
			//actors[ 0 ].s.sound <- ""
			if ( walkPos )
				actors[ 0 ].s.walkPos <- walkPos
			//Grunt 1
			actors.append( SpawnIntroNPC( "grunt", squadName, team, pos, ang ) )
			actors[ 1 ].s.idle <- "pt_spectre_zombiedrag_idle"
			actors[ 1 ].s.actions <- []
			actors[ 1 ].s.actions.append( "pt_spectre_zombiedrag" )
			//actors[ 1 ].s.sound <- ""
			break
		case "spectreCrawl":
			//Spectre
			actors.append( SpawnIntroNPC( "spectre", UniqueString(), GetTeamIndex(GetOtherTeams(1 << team)), pos, ang, true ) )
			actors[ 0 ].s.idle <- "sp_spectre_crawl_idle"
			actors[ 0 ].s.actions <- []
			actors[ 0 ].s.actions.append( "sp_spectre_crawl" )
			//actors[ 0 ].s.sound <- ""
			if ( walkPos )
				actors[ 0 ].s.walkPos <- walkPos
			//Grunt 1
			actors.append( SpawnIntroNPC( "grunt", squadName, team, pos, ang ) )
			actors[ 1 ].s.idle <- "pt_spectre_crawl_idle"
			actors[ 1 ].s.actions <- []
			actors[ 1 ].s.actions.append( "pt_spectre_crawl" )
			//actors[ 1 ].s.sound <- ""
			break
		case "multikill":
			//Spectre
			actors.append( SpawnIntroNPC( "spectre", squadName, team, pos, ang, true ) )
			actors[ 0 ].s.idle <- "sp_spectre_speedkill_skit_idle"
			actors[ 0 ].s.actions <- []
			actors[ 0 ].s.actions.append( "sp_spectre_speedkill_skit" )
			actors[ 0 ].s.sound <- "ai_skit_spectre_speedkill_Spectre_comp"
			if ( walkPos )
				actors[ 0 ].s.walkPos <- walkPos
			//Grunt 1
			actors.append( SpawnIntroNPC( "grunt", UniqueString(), GetTeamIndex(GetOtherTeams(1 << team)), pos, ang ) )
			actors[ 1 ].s.idle <- "pt_spectre_speedkill_skit_A_idle"
			actors[ 1 ].s.actions <- []
			actors[ 1 ].s.actions.append( "pt_spectre_speedkill_skit_A" )
			actors[ 1 ].s.sound <- "ai_skit_spectre_speedkill_Soldier1_comp"
			//Grunt 2
			actors.append( SpawnIntroNPC( "grunt", UniqueString(), GetTeamIndex(GetOtherTeams(1 << team)), pos, ang ) )
			actors[ 2 ].s.idle <- "pt_spectre_speedkill_skit_B_idle"
			actors[ 2 ].s.actions <- []
			actors[ 2 ].s.actions.append( "pt_spectre_speedkill_skit_B" )
			actors[ 2 ].s.sound <- "ai_skit_spectre_speedkill_Soldier2_comp"
			break
		case "prisonerMultiKill":
			//Spectre
			actors.append( SpawnIntroNPC( "spectre", squadName, team, pos, ang, true ) )
			actors[ 0 ].s.idle <- "sp_street_execution_idle"
			actors[ 0 ].s.actions <- []
			actors[ 0 ].s.actions.append( "sp_street_execution" )
			//Grunt 1
			actors.append( SpawnIntroNPC( "civilian", UniqueString(), team, pos, ang, false, CIVILIAN_MODEL_01 ) )
			actors[ 1 ].s.idle <- "pt_street_execution_idle_A"
			actors[ 1 ].s.actions <- []
			actors[ 1 ].s.actions.append( "pt_street_execution_A" )
			//Grunt 2
			actors.append( SpawnIntroNPC( "civilian", UniqueString(), team, pos, ang, false, CIVILIAN_MODEL_02 ) )
			actors[ 2 ].s.idle <- "pt_street_execution_idle_B"
			actors[ 2 ].s.actions <- []
			actors[ 2 ].s.actions.append( "pt_street_execution_B" )
			break
		case "bodyDisposal":
			//Spectre
			actors.append( SpawnIntroNPC( "spectre", squadName, team, pos, ang, true ) )
			actors[ 0 ].s.idle <- "sp_spectre_dumpbody_skit_idle"
			actors[ 0 ].s.actions <- []
			actors[ 0 ].s.actions.append( "sp_spectre_dumpbody_skit" )
			//Civilian
			actors.append( CreatePropDynamic( CIVILIAN_MODEL_03, pos, ang, 0 ) )
			actors[ 1 ].s.idle <- "pt_spectre_dumpbody_skit_idle"
			actors[ 1 ].s.actions <- []
			actors[ 1 ].s.actions.append( "pt_spectre_dumpbody_skit" )
			break
		case "multikillMilitia":
			//Spectre
			actors.append( SpawnIntroNPC( "spectre", UniqueString(), GetTeamIndex(GetOtherTeams(1 << team)), pos, ang, true ) )
			actors[ 0 ].SetName( "SpectreIntroMilitia01" )
			actors[ 0 ].SetMaxHealth( 1 )
			actors[ 0 ].SetHealth( 1 )
			actors[ 0 ].s.idle <- "sp_spectre_speedkill_skit_idle"
			actors[ 0 ].s.actions <- []
			actors[ 0 ].s.actions.append( "sp_spectre_speedkill_skit" )
			actors[ 0 ].s.sound <- "ai_skit_spectre_speedkill_Spectre_comp"
			//Grunt 1
			actors.append( SpawnIntroNPC( "grunt", squadName, team, pos, ang ) )
			actors[ 1 ].s.idle <- "pt_spectre_speedkill_skit_A_idle"
			actors[ 1 ].s.actions <- []
			actors[ 1 ].s.actions.append( "pt_spectre_speedkill_skit_A" )
			actors[ 1 ].s.sound <- "ai_skit_spectre_speedkill_Soldier1_comp"
			//Grunt 2
			actors.append( SpawnIntroNPC( "grunt", squadName, team, pos, ang ) )
			actors[ 2 ].s.idle <- "pt_spectre_speedkill_skit_B_idle"
			actors[ 2 ].s.actions <- []
			actors[ 2 ].s.actions.append( "pt_spectre_speedkill_skit_B" )
			actors[ 2 ].s.sound <- "ai_skit_spectre_speedkill_Soldier2_comp"
			break
		case "curbstomp":
			//Spectre
			actors.append( SpawnIntroNPC( "spectre", squadName, team, pos, ang, true ) )
			actors[ 0 ].s.idle <- "sp_curbstomp_idle_skit"
			actors[ 0 ].s.actions <- []
			actors[ 0 ].s.actions.append( "sp_curbstomp_skit" )
			if ( walkPos )
				actors[ 0 ].s.walkPos <- walkPos
			//actors[ 0 ].s.sound <- null
			//Grunt
			actors.append( SpawnIntroNPC( "grunt", UniqueString(), GetTeamIndex(GetOtherTeams(1 << team)), pos, ang ) )
			actors[ 1 ].s.idle <- "pt_curbstomp_idle_skit"
			actors[ 1 ].s.actions <- []
			actors[ 1 ].s.actions.append( "pt_curbstomp_skit" )
			//actors[ 1 ].s.sound <- null
			SetSilentDeath( actors[ 1 ], true )
			actors[ 1 ].TakeActiveWeapon()
			break
		case "blindfire":
			//Spectre
			actors.append( SpawnIntroNPC( "spectre", squadName, team, pos, ang, true ) )
			actors[ 0 ].s.idle <- "sp_blindfire_idle_skit"
			actors[ 0 ].s.actions <- []
			actors[ 0 ].s.actions.append( "sp_blindfire_skit" )
			if ( walkPos )
				actors[ 0 ].s.walkPos <- walkPos
			//actors[ 0 ].s.sound <- null
			//Grunt
			actors.append( SpawnIntroNPC( "grunt", UniqueString(), GetTeamIndex(GetOtherTeams(1 << team)), pos, ang ) )
			actors[ 1 ].s.idle <- "pt_blindfire_idle_skit"
			actors[ 1 ].s.actions <- []
			actors[ 1 ].s.actions.append( "pt_blindfire_skit" )
			//actors[ 1 ].s.sound <- null
			break
		case "chestpunch":
			//Spectre
			actors.append( SpawnIntroNPC( "spectre", squadName, team, pos, ang, true ) )
			actors[ 0 ].s.idle <- "sp_spectre_chestpunch_idle"
			actors[ 0 ].s.actions <- []
			actors[ 0 ].s.actions.append( "sp_spectre_chestpunch" )
			if ( walkPos )
				actors[ 0 ].s.walkPos <- walkPos
			//actors[ 0 ].s.sound <- null
			//Grunt
			actors.append( SpawnIntroNPC( "grunt", UniqueString(), GetTeamIndex(GetOtherTeams(1 << team)), pos, ang ) )
			actors[ 1 ].s.idle <- "pt_spectre_chestpunch_idle"
			actors[ 1 ].s.actions <- []
			actors[ 1 ].s.actions.append( "pt_spectre_chestpunch" )
			actors[ 1 ].s.sound <- "ai_skit_spectre_speedkill_Soldier1_comp"
			SetSilentDeath( actors[ 1 ], true )
			break
		case "necksnap":
			//Spectre
			actors.append( SpawnIntroNPC( "spectre", squadName, team, pos, ang, true ) )
			actors[ 0 ].s.idle <- "sp_spectre_kill_skit_idle"
			actors[ 0 ].s.actions <- []
			actors[ 0 ].s.actions.append( "sp_spectre_kill_skit" )
			actors[ 0 ].s.sound <- "ai_skit_spectre_kill_Spectre_comp"
			if ( walkPos )
				actors[ 0 ].s.walkPos <- walkPos
			//Grunt
			actors.append( SpawnIntroNPC( "grunt", UniqueString(), GetTeamIndex(GetOtherTeams(1 << team)), pos, ang ) )
			actors[ 1 ].s.idle <- "pt_spectre_kill_skit_idle"
			actors[ 1 ].s.actions <- []
			actors[ 1 ].s.actions.append( "pt_spectre_kill_skit" )
			actors[ 1 ].s.sound <- "ai_skit_spectre_kill_Soldier_comp"
			SetSilentDeath( actors[ 1 ], true )
			break
		case "spectreLoot":
			//looter
			actors.append( SpawnIntroNPC( "grunt", squadName, team, pos, ang ) )
			actors[ 0 ].s.idle <- "pt_loot_corpse_skit_A_idle"
			actors[ 0 ].s.actions <- []
			actors[ 0 ].s.actions.append( "pt_loot_corpse_skit_A" )
			actors[ 0 ].s.sound <- "ai_skit_pt_loot_corpse_Soldier1_comp"
			//looter
			actors.append( SpawnIntroNPC( "grunt", squadName, team, pos, ang ) )
			actors[ 1 ].s.idle <- "pt_loot_corpse_skit_B_idle"
			actors[ 1 ].s.actions <- []
			actors[ 1 ].s.actions.append( "pt_loot_corpse_skit_B" )
			actors[ 1 ].s.sound <- "ai_skit_pt_loot_corpse_Soldier2_comp"
			//dead spectre
			actors.append( CreatePropDynamic( NEUTRAL_SPECTRE_MODEL, pos, ang, 0 ) )
			actors[ 2 ].s.idle <- "pt_loot_corpse_skit_idle"
			actors[ 2 ].s.actions <- []
			actors[ 2 ].s.actions.append( "pt_loot_corpse_skit" )
			actors[ 2 ].s.sound <- "ai_skit_pt_loot_corpse_Corpse_comp"
			break
		case "patrolSurprise1":
			//walker
			actors.append( SpawnIntroNPC( "grunt", squadName, team, pos, ang ) )
			actors[ 0 ].s.idle <- "pt_bored_stand_talker_A"
			actors[ 0 ].s.actions <- []
			//actors[ 0 ].s.actions.append( "patrol_walk_highport_scripted" )
			actors[ 0 ].s.actions.append( "React_duckL" )
			actors[ 0 ].s.actions.append( "React_signal_farright" )
			break
		case "CQBscan01":
			//walker
			actors.append( SpawnIntroNPC( "grunt", squadName, team, pos, ang ) )
			actors[ 0 ].s.idle <- "search_look_around"
			actors[ 0 ].s.actions <- []
			actors[ 0 ].s.actions.append( "React_frantic" )
			break
		case "prisonerDragKill":
			//Spectre - dragger
			actors.append( SpawnIntroNPC( "spectre", squadName, team, pos, ang, true ) )
			actors[ 0 ].s.idle <- "pt_prisoner_drag_zinger_C_idle"
			actors[ 0 ].s.actions <- []
			actors[ 0 ].s.actions.append( "pt_prisoner_drag_zinger_C" )
			if ( walkPos )
				actors[ 0 ].s.walkPos <- walkPos
			//Spectre - shooter
			actors.append( SpawnIntroNPC( "spectre", squadName, team, pos, ang, true ) )
			actors[ 1 ].s.idle <- "pt_prisoner_drag_zinger_B_idle"
			actors[ 1 ].s.actions <- []
			actors[ 1 ].s.actions.append( "pt_prisoner_drag_zinger_B" )
			if ( walkPos )
				actors[ 1 ].s.walkPos <- walkPos
			//Civilian - victim
			actors.append( CreatePropDynamic( CIVILIAN_MODEL_04, pos, ang, 0 ) )
			actors[ 2 ].s.idle <- "pt_prisoner_drag_zinger_A_idle"
			actors[ 2 ].s.actions <- []
			actors[ 2 ].s.actions.append( "pt_prisoner_drag_zinger_A" )
			break
		case "prisonerKill":
			//Spectre
			actors.append( SpawnIntroNPC( "spectre", squadName, team, pos, ang, true ) )
			actors[ 0 ].s.idle <- "sp_colony_execution_idle"
			actors[ 0 ].s.actions <- []
			actors[ 0 ].s.actions.append( "sp_colony_execution" )
			if ( walkPos )
				actors[ 0 ].s.walkPos <- walkPos
			//Civilian - victim
			actors.append( SpawnIntroNPC( "civilian", UniqueString(), team, pos, ang ) )
			actors[ 1 ].s.idle <- "pt_colony_execution_idle"
			actors[ 1 ].s.actions <- []
			actors[ 1 ].s.actions.append( "pt_colony_execution" )
			break
		case "spectreCorpsePatrolA":
			//spectre
			actors.append( SpawnIntroNPC( "spectre", squadName, team, pos, ang ) )
			actors[ 0 ].s.idle <- "sp_corpse_patrol_A_idle"
			actors[ 0 ].s.actions <- []
			actors[ 0 ].s.actions.append( "sp_corpse_patrol_A" )
			//Civilian - victim
			actors.append( CreatePropDynamic( CIVILIAN_MODEL_01, pos, ang, 0 ) )
			actors[ 1 ].s.idle <- "pt_corpse_patrol_A_idle"
			actors[ 1 ].s.actions <- []
			actors[ 1 ].s.actions.append( "pt_corpse_patrol_A" )
			//Civilian - victim
			actors.append( CreatePropDynamic( CIVILIAN_MODEL_02, pos, ang, 0 ) )
			actors[ 2 ].s.idle <- "pt_corpse_patrol_A_2_idle"
			actors[ 2 ].s.actions <- []
			actors[ 2 ].s.actions.append( "pt_corpse_patrol_A_2" )
			break
		case "spectreCorpsePatrolB":
			//spectre
			actors.append( SpawnIntroNPC( "spectre", squadName, team, pos, ang ) )
			actors[ 0 ].s.idle <- "sp_corpse_patrol_B_1_idle"
			actors[ 0 ].s.actions <- []
			actors[ 0 ].s.actions.append( "sp_corpse_patrol_B_1" )
			//spectre
			actors.append( SpawnIntroNPC( "spectre", squadName, team, pos, ang ) )
			actors[ 1 ].s.idle <- "sp_corpse_patrol_B_2_idle"
			actors[ 1 ].s.actions <- []
			actors[ 1 ].s.actions.append( "sp_corpse_patrol_B_2" )
			//Civilian - victim
			actors.append( CreatePropDynamic( CIVILIAN_MODEL_03, pos, ang, 0 ) )
			actors[ 2 ].s.idle <- "pt_corpse_patrol_B_idle"
			actors[ 2 ].s.actions <- []
			actors[ 2 ].s.actions.append( "pt_corpse_patrol_B" )
			//Civilian - victim
			actors.append( CreatePropDynamic( CIVILIAN_MODEL_04, pos, ang, 0 ) )
			actors[ 3 ].s.idle <- "pt_corpse_patrol_B_2_idle"
			actors[ 3 ].s.actions <- []
			actors[ 3 ].s.actions.append( "pt_corpse_patrol_B_2" )
			break
		case "spectreCorpsePatrolB2":
			//spectre
			actors.append( SpawnIntroNPC( "spectre", squadName, team, pos, ang ) )
			actors[ 0 ].s.idle <- "sp_corpse_patrol_B_2_idle"
			actors[ 0 ].s.actions <- []
			actors[ 0 ].s.actions.append( "sp_corpse_patrol_B_2" )
			//Civilian - victim
			actors.append( CreatePropDynamic( CIVILIAN_MODEL_01, pos, ang, 0 ) )
			actors[ 1 ].s.idle <- "pt_corpse_patrol_B_idle"
			actors[ 1 ].s.actions <- []
			actors[ 1 ].s.actions.append( "pt_corpse_patrol_B" )
			break
		default:
			Assert( 0, "CORPORATE: not a valid skit type: " + skitType )
	}

	//-----------------------------------------------
	// Idle until triggered through flag and/or delay
	//-----------------------------------------------
	foreach( npc in actors )
		thread PlayAnimTeleport( npc, npc.s.idle, pos, ang )

	if ( flagTrigger )
		FlagWait( flagTrigger )

	wait delay

	//----------------------
	// Run skit anim(s)
	//----------------------
	foreach( npc in actors )
	{
		if ( !IsValid( npc ) )
			continue

		if ( ( IsNPC( npc ) ) && ( !IsAlive( npc ) ) )
			continue

		thread IntroSkitRunAnimQueue( npc, pos, ang, func )
	}
}

/////////////////////////////////////////////////////////////////////////////////////
function IntroSkitRunAnimQueue( npc, pos, ang, func )
{
	npc.EndSignal( "OnDeath" )

	if ( IsNPC( npc ) )
	{
		if ( npc.ContextAction_IsActive() )	//may already be getting neck snapped, return
			return
		else
			npc.ContextAction_SetBusy() //don't allow melee execution
	}

	OnThreadEnd
	(
		function() : ( npc, func )
		{
			if ( !IsAlive( npc ) )
				return
			if ( IsNPC( npc ) )
			{
				npc.SetEfficientMode( false )
				npc.ContextAction_ClearBusy() //allow melee execution again
			}
			if ( "walkPos" in npc.s )
				thread GotoOrigin( npc, npc.s.walkPos  )
			if ( func )
				thread func( npc )
		}
	)

	local firstAnim = true

	foreach( anim in npc.s.actions )
	{
		if ( firstAnim = true )
		{
			if ( "sound" in npc.s )
				EmitSoundOnEntity( npc, npc.s.sound )
			waitthread PlayAnim( npc, anim, pos, ang )
			firstAnim = false
		}
		else
			waitthread PlayAnim( npc, npc.s.action2 )
	}
}


/////////////////////////////////////////////////////////////////////////////////////
function SpawnIntroNPC( npcType, squadName, team, pos, ang, norockets = false, modelOverride = null )
{
	//ReserveAISlots( team, count )
	local npc

	switch( npcType )
	{
		case "grunt":
			npc = SpawnGrunt( team, squadName, pos, ang )
			break
		case "civilian":
			npc = SpawnGrunt( team, squadName, pos, ang )
			npc.SetModel( CIVILIAN_MODEL_01 )
			npc.SetNoTarget( true )
			npc.SetNoTargetSmartAmmo( true )
			//MakeInvincible( npc )
			break
		case "spectre":
			if ( GetMapName() == "mp_corporate" )
			{
				npc = SpawnSpectre( TEAM_UNASSIGNED, UniqueString(), pos, ang )
				SpectreSetTeam( npc, team )
				SetSquad( npc, squadName )
			}
			else
				npc = SpawnSpectre( team, squadName, pos, ang )
			break
		default:
			Assert( 0, "Invalid npcType: " + npcType )
	}

	if ( modelOverride )
		npc.SetModel( modelOverride )

	npc.SetEfficientMode( true )

	thread HideNameUntilNotified( npc )

	if ( norockets )
		DisableRockets( npc )

	return npc
}

//////////////////////////////////////////////////////////////////////////////////////
function HideNameUntilNotified( npc )
{
	npc.EndSignal( "OnDeath" )

	npc.SetTitle( "" )
	npc.SetShortTitle( "" )

	npc.WaitSignal( "ShowTitle" )

	local title

	switch ( npc.GetClassname() )
	{
		case "npc_soldier":
			title = "#NPC_GRUNT"
			break
		case "npc_spectre":
			title = "#NPC_SPECTRE"
			break
		case "npc_titan":
			title = "#NPC_TITAN"
			break
		default:
			Assert( 0, "CORPORATE: Unhandled npc: " + npc.GetClassname() )
	}

	npc.SetTitle( title )
	npc.SetShortTitle( title )
}

//////////////////////////////////////////////////////////////////////////////////////
function IntroWalker( moveAnim, squadName, team, startPos, endPos, func = null )
{
	local npc = SpawnIntroNPC( "grunt", squadName, team, startPos, Vector( 0, 0, 0 ) )
	npc.EndSignal( "OnDeath" )

	npc.SetMoveAnim( moveAnim )

	OnThreadEnd
	(
		function() : ( npc, func )
		{
			if ( !IsAlive( npc ) )
				return
			if ( IsNPC( npc ) )
			{
				npc.SetEfficientMode( false )
				npc.ClearMoveAnim()
			}
			if ( func )
				thread func( npc )
		}
	)

	waitthread GotoOrigin( npc, endPos )

}

////////////////////////////////////////////////////////////////////////////////////
function SpectreSetTeam( spectre, team )
{
	spectre.SetTeam( team )
	if ( IsNPC( spectre ) )
	{
		if ( "eye_glow" in spectre.s && IsValid( spectre.s.eye_glow ) )
			spectre.s.eye_glow.SetTeam( team )
	}

}


/////////////////////////////////////////////////////////////////////////////////////////
function DeleteIfValid( ent )
{
	if ( !IsValid( ent ) )
		return
	ent.Kill()
}