const NUM_OBITUARY_LINES			= 4		// cant change arbitrarily, need to have matching entries in the .res file
const obituaryTextBoxWidth = 500
const obituaryTextBoxHeight = 20
const defaultCharacterWidth = 5

function main()
{
	Globalize( Obituary_Print )
	Globalize( Obituary )
	Globalize( Obituary_GetEntityInfo )
	Globalize( GetAttackerDisplayNamesFromClassname )
	Globalize( GetAttackerDisplayNamesDamageSourceId )

	file.obituaryLines <- {}
	file.nextObituaryIndexToUse <- 0
	file.obituaryPrints <- []
	file.obituaryOverflow <- []

	file.obituaryPrints = []
	file.obituaryPrints.resize( NUM_OBITUARY_LINES )
	PrecacheHUDMaterial( "hud/obituary_headshot" )
	PrecacheHUDMaterial( "hud/obituary_burncard" )
}

function EntitiesDidLoad()
{
	local screenSize = Hud.GetScreenSize()
	local screenCenterX = screenSize[ 0 ] / 2.0
	local screenCenterY = screenSize[ 1 ] / 2.0
	local defaultObituaryPosX = 0
	local defaultObituaryPosY = 0//screenCenterY + ( OBITUARY_Y * GetContentScaleFactor()[1] )
	local elem

	local scale = 1.0

	// Obituary Lines - corner prints containing death events in the game
	for ( local i = 0 ; i < NUM_OBITUARY_LINES ; i++ )
	{
		file.obituaryLines[ i ] <- {}
		file.obituaryLines[ i ].attacker <- HudElement( "ObituaryAttacker_" + i )
		file.obituaryLines[ i ].icon <- HudElement( "ObituaryIcon_" + i )
		file.obituaryLines[ i ].weapon <- HudElement( "ObituaryWeapon_" + i )
		file.obituaryLines[ i ].victim <- HudElement( "ObituaryVictim_" + i )
	}

	file.nextObituaryIndexToUse = 0

	for ( local i = NUM_OBITUARY_LINES - 1; i >= 0; i-- )
	{
		if ( !file.obituaryPrints[i] )
			continue

		if ( Time() - file.obituaryPrints[i].time > OBITUARY_DURATION )
			continue

		Obituary_Display( file.obituaryPrints[i] )
	}
}

function Obituary_GetEntityInfo( ent, victimIsOwnedTitan = false, damageSourceId = null )
{
	local info = {}
	info.displayName <- null
	info.displayColor <- OBITUARY_COLOR_WEAPON
	info.petDisplayName <- ""

	if ( IsValid( ent ) )
	{
		local names = GetAttackerDisplayNamesFromClassname( ent, victimIsOwnedTitan )
		info.displayName = names.attackerName
		info.petDisplayName = names.attackerPetName

		local localPlayer = GetLocalClientPlayer()
		if ( IsFFABased() ) {
			info.displayColor = OBITUARY_COLOR_ENEMY
		} else {
			info.displayColor = localPlayer.GetTeamNumber() == ent.GetTeamNumber() ? OBITUARY_COLOR_FRIENDLY : OBITUARY_COLOR_ENEMY
		}
		if ( !IsWatchingKillReplay() )
		{
			local entBoss = ent.GetBossPlayer()
			if ( !IsPrivateMatch() && ((ent.IsPlayer() && IsPartyMember( ent )) || ((entBoss != null) && IsPartyMember( entBoss ))) )
				info.displayColor = OBITUARY_COLOR_PARTY

			if ( ent == localPlayer )
				info.displayColor = OBITUARY_COLOR_LOCALPLAYER
			else if ( !ent.IsPlayer() && (entBoss == localPlayer) )
				info.displayColor = OBITUARY_COLOR_LOCALPLAYER
		}
	}
	else if ( damageSourceId != null )
	{
		local name = GetAttackerDisplayNamesDamageSourceId( damageSourceId )
		info.displayColor = OBITUARY_COLOR_ENEMY // Since we can't know if it's an enemy of friendly lets assume enemy.
		info.displayName = name
	}

	return info
}

function Obituary( attacker, attackerClass, victim, scriptDamageType, damageSourceId, isHeadShot, victimIsOwnedTitan = false )
{
	if ( IsTrainingLevel() )
		return

	if ( victim.IsPlayer() )
	{
		// Players
		if ( !OBITUARY_ENABLED_PLAYERS )
			return
	}
	else if ( victim.IsTitan() )
	{
		// NPC Titans
		if ( !OBITUARY_ENABLED_NPC_TITANS )
			return
	}
	else
	{
		// NPC
		if ( !OBITUARY_ENABLED_NPC )
			return
	}

	if ( damageSourceId == eDamageSourceId.round_end )
		return

	/*******************************************/
	/* GET INFORMATION ABOUT ENTITIES INVOLVED */
	/*******************************************/

	local attackerInfo = Obituary_GetEntityInfo( attacker, false, damageSourceId )
	local victimInfo = Obituary_GetEntityInfo( victim, victimIsOwnedTitan, damageSourceId )
	local isDeathSuicide = IsSuicide( attacker, victim, damageSourceId )

	// Don't show NPC suicides, also makes titan eject deaths not show up which is good
	if ( isDeathSuicide && victim.IsNPC() )
		return

	local sourceDisplayName = null
	//if ( isDeathSuicide )
	//	damageSourceId = eDamageSourceId.suicide
	if ( damageSourceId in damageSourceStrings )
		sourceDisplayName = damageSourceStrings[ damageSourceId ]

	/********************************************/
	/* PRINT DEBUG INFO IF SOMETHING GOES WRONG */
	/********************************************/

	local printDebugInfo = false
	local debugSourceDisplayName = sourceDisplayName

	if ( sourceDisplayName == null )
	{
		sourceDisplayName = ""
		debugSourceDisplayName = damageSourceStrings[ eDamageSourceId.unknownBugIt ]
		printDebugInfo = true
	}

	if ( attackerInfo.displayName == null )
	{
		attackerInfo.displayName = ""
		printDebugInfo = true
	}

	if ( victimInfo.displayName == null )
	{
		victimInfo.displayName = ""
		printDebugInfo = true
	}

	if ( printDebugInfo )
	{
		printt( "------------------------------------------" )
		printt( " FULL OBITUARY INFO COULD NOT BE RESOLVED " )
		printt( "    attacker:", attacker )
		if ( IsValid( attacker ) )
		{
			printt( "    attacker classname:", attacker.GetClassname() )
			local attackerOwner = attacker.GetOwner()
			printt( "    attackerOwner:", attackerOwner )
			if ( IsValid( attackerOwner ) )
				printt( "    attackerOwner classname:", attackerOwner.GetClassname() )
		}
		printt( "    victim:", victim )
		if ( IsValid( victim ) )
		{
			printt( "    victim classname:", victim.GetClassname() )
			local victimOwner = victim.GetOwner()
			printt( "    victimOwner:", victimOwner )
			if ( IsValid( victimOwner ) )
				printt( "    victimOwner classname:", victimOwner.GetClassname() )
		}
		printt( "    scriptDamageType:", scriptDamageType )
		printt( "    damageSourceId:", damageSourceId )
		printt( "    sourceDisplayName:", debugSourceDisplayName )
		printt( "------------------------------------------" )
	}

	/**************************/
	/* PRINT THE OBIT MESSAGE */
	/**************************/

	if ( isDeathSuicide )
	{
		attackerInfo.displayName = victimInfo.displayName	// swap display names because the attacker could be the titan that no longer has any info about it's driver
		attackerInfo.displayColor = victimInfo.displayColor	// swap display color as weil
		victimInfo.displayName = ""
	}

	local weaponIcon = null
	if ( isHeadShot )
		weaponIcon = "HUD/obituary_headshot"

	local obitColor
	if ( scriptDamageType & DF_BURN_CARD_WEAPON )
		obitColor = BURN_CARD_WEAPON_HUD_COLOR_STRING
	else
		obitColor = OBITUARY_COLOR_WEAPON

	Obituary_Print( attackerInfo.displayName, sourceDisplayName, victimInfo.displayName, attackerInfo.displayColor, obitColor, victimInfo.displayColor, weaponIcon, attackerInfo.petDisplayName, victimInfo.petDisplayName )

	/**************************/
	/*   SMART GLASS UPDATE   */
	/**************************/

	if ( attacker == GetLocalClientPlayer() && victim.IsPlayer() && !isDeathSuicide )
		SmartGlass_SetGameStateProperty( SMARTGLASS_PROP_LASTKILLED, victimInfo.displayName )
	if ( IsValid( attacker ) && attacker.IsPlayer() && victim == GetLocalClientPlayer() )
		SmartGlass_SetGameStateProperty( SMARTGLASS_PROP_LASTKILLEDBY, attackerInfo.displayName )
}

function Obituary_Print( attackerDisplayName, weaponDisplayName, victimDisplayName, attackerColor, weaponColor, victimColor, weaponIcon = null, attackerPetDisplayName = "", victimPetDisplayName = "" )
{
	// obituaryLines is initialized in EntitiesDidLoad, but this can get called before that.
	if ( !( file.nextObituaryIndexToUse in file.obituaryLines ) )
		return

	local obituaryData = {}
	obituaryData.attackerDisplayName 	<- attackerDisplayName
	obituaryData.weaponDisplayName 		<- weaponDisplayName
	obituaryData.victimDisplayName		<- victimDisplayName
	obituaryData.attackerColor			<- attackerColor
	obituaryData.weaponColor			<- weaponColor
	obituaryData.victimColor			<- victimColor
	obituaryData.weaponIcon				<- weaponIcon
	obituaryData.time					<- Time()
	obituaryData.attackerPetDisplayName <- attackerPetDisplayName
	obituaryData.victimPetDisplayName	<- victimPetDisplayName

	thread HandleObituaryOverflow( obituaryData )
}

function HandleObituaryOverflow( obituaryData )
{
	waitthread CheckForObitOverflow( obituaryData )

	obituaryData.indexToUse <- file.nextObituaryIndexToUse
	file.obituaryPrints.insert( 0, obituaryData )
	file.obituaryPrints.resize( NUM_OBITUARY_LINES )

	Obituary_Display( obituaryData )
}

function CheckForObitOverflow( obituaryData )
{
	Assert( ( OBITUARY_MIN_DURATION + OBITUARY_FADE_OUT_DURATION ) < OBITUARY_DURATION )

	if ( file.obituaryPrints[ NUM_OBITUARY_LINES - 1 ] == null )
		return

	local currentTime = Time()

	local timeSinceLastObit = currentTime - file.obituaryPrints[ NUM_OBITUARY_LINES - 1 ].time

	if ( timeSinceLastObit < OBITUARY_MIN_DURATION )
	{
		file.obituaryOverflow.append( obituaryData )

		local overflowLength = file.obituaryOverflow.len()
		local remainingTime = 0
		if ( overflowLength > NUM_OBITUARY_LINES )
		{
			local maxObitPrintIndex = ( NUM_OBITUARY_LINES - 1 )
			local correspondingObitPrint = ( maxObitPrintIndex - ( ( overflowLength - 1 ) % NUM_OBITUARY_LINES ) )
			remainingTime = file.obituaryOverflow[ overflowLength - NUM_OBITUARY_LINES ].time + OBITUARY_MIN_DURATION - currentTime
			thread DelayedObitFadeCall( file.obituaryPrints[ correspondingObitPrint ].indexToUse, remainingTime )
		}
		else
		{
			local correspondingObitPrint = ( NUM_OBITUARY_LINES - overflowLength )
			remainingTime = max( OBITUARY_FADE_OUT_DURATION, file.obituaryPrints[ correspondingObitPrint ].time + OBITUARY_MIN_DURATION - currentTime )

			foreach ( elem in file.obituaryLines[ file.obituaryPrints[ correspondingObitPrint ].indexToUse ] )
			{
				elem.SetAlpha( 255 )
				elem.FadeOverTimeDelayed( 0, OBITUARY_FADE_OUT_DURATION, remainingTime - OBITUARY_FADE_OUT_DURATION )
				elem.Show()
			}
		}
		obituaryData.time = obituaryData.time + remainingTime

		wait remainingTime

		file.obituaryOverflow.remove( 0 )
	}
}

function DelayedObitFadeCall( obitLineIndex, remainingTime )
{
	wait remainingTime - OBITUARY_MIN_DURATION
	foreach ( elem in file.obituaryLines[ obitLineIndex ] )
	{
		elem.SetAlpha( 255 )
		elem.FadeOverTimeDelayed( 0, OBITUARY_FADE_OUT_DURATION, OBITUARY_MIN_DURATION - OBITUARY_FADE_OUT_DURATION )
		elem.Show()
	}
}

function Obituary_Display( obituaryData )
{
	local next = obituaryData.indexToUse
	BumpDownExistingObituaries()

	if ( split( obituaryData.attackerDisplayName, "(" ).len() )
		obituaryData.attackerDisplayName = split( obituaryData.attackerDisplayName, "(" )[0]

	if ( split( obituaryData.victimDisplayName, "(" ).len() )
		obituaryData.victimDisplayName = split( obituaryData.victimDisplayName, "(" )[0]


	if ( obituaryData.attackerPetDisplayName != "" )
		file.obituaryLines[ next ].attacker.SetText( "#OBIT_PLAYER_CONTROLLED_AI_STRING", obituaryData.attackerDisplayName, obituaryData.attackerPetDisplayName  )
	else
		file.obituaryLines[ next ].attacker.SetText( obituaryData.attackerDisplayName )
	file.obituaryLines[ next ].attacker.SetColor( ColorStringToArray( obituaryData.attackerColor ) )

	file.obituaryLines[ next ].weapon.SetText( "#OBIT_BRACKETED_STRING", obituaryData.weaponDisplayName, null, null, null, null )
	file.obituaryLines[ next ].weapon.SetColor( ColorStringToArray( obituaryData.weaponColor ) )

	if ( obituaryData.victimPetDisplayName != "" )
		file.obituaryLines[ next ].victim.SetText( "#OBIT_PLAYER_CONTROLLED_AI_STRING", obituaryData.victimDisplayName, obituaryData.victimPetDisplayName )
	else
		file.obituaryLines[ next ].victim.SetText( obituaryData.victimDisplayName )
	file.obituaryLines[ next ].victim.SetColor( ColorStringToArray( obituaryData.victimColor ) )

	if ( obituaryData.weaponIcon )
	{
		file.obituaryLines[ next ].icon.SetImage( obituaryData.weaponIcon )
		file.obituaryLines[ next ].icon.SetSize( file.obituaryLines[ next ].victim.GetHeight(), file.obituaryLines[ next ].victim.GetHeight() )
	}
	else
	{
		file.obituaryLines[ next ].icon.SetWidth( 0 )
	}

	file.obituaryLines[ next ].victim.ReturnToBasePos()

	foreach ( elem in file.obituaryLines[ next ]	)
	{
		elem.SetAlpha( 255 )
		elem.FadeOverTimeDelayed( 0, OBITUARY_FADE_OUT_DURATION, OBITUARY_DURATION )
		elem.Show()
	}

	// increment which hud elems to use next time
	file.nextObituaryIndexToUse++
	if ( file.nextObituaryIndexToUse >= NUM_OBITUARY_LINES )
		file.nextObituaryIndexToUse = 0
}

function BumpDownExistingObituaries()
{
	foreach( index, obituary in file.obituaryLines )
	{
		local distanceFromTop = GetObituaryDistanceFromTop( index )
		local basePos = obituary.victim.GetBasePos()
		obituary.victim.MoveOverTime( basePos[0], basePos[1] + -obituary.victim.GetHeight() * distanceFromTop, 0.25, INTERPOLATOR_DEACCEL )
	}
}

function GetObituaryDistanceFromTop( index )
{
	if ( index <= file.nextObituaryIndexToUse )
		return file.nextObituaryIndexToUse - index
	else
		return NUM_OBITUARY_LINES - ( index - file.nextObituaryIndexToUse )
}

function GetAttackerDisplayNamesFromClassname( ent, victimIsOwnedTitan = false )
{
	local names = { attackerName = "", attackerPetName = "" }

	//If the victim is a titan being doomed with a player inside, need to say the victim is "player's titan" instead of just "player"
	if ( victimIsOwnedTitan )
	{
		//Can't just check IsPlayer && IsTitan because we might get pilots whose titans have already been obituaried
		names.attackerName = ent.GetPlayerName()
		names.attackerPetName = "#NPC_TITAN"
	}
	else if ( ent.IsPlayer() )
	{
		names.attackerName = ent.GetPlayerName()
	}
	else if ( ent instanceof C_AI_BaseNPC )
	{
		local bossPlayerName = ent.GetBossPlayerName()

		if ( bossPlayerName != "" )
		{
			///////////////////////
			// dev only - remove (machinename-re)
			if ( developer() != 0 )
			{
				local index = bossPlayerName.find( " (", 1 )
				if ( index != null )
					bossPlayerName = bossPlayerName.slice( 0, index )
			}
			///////////////////////

			// player autotitans are titled "follow mode" or "guard mode" so we need to change the obit display name
			if ( ent.IsTurret() )
			{
				names.attackerName = bossPlayerName
			}
			else if ( ent.IsTitan() )
			{
				names.attackerName = bossPlayerName
				names.attackerPetName = "#NPC_AUTO_TITAN"
			}
			else if ( ent.IsSoldier() )
			{
				names.attackerName = bossPlayerName
				names.attackerPetName = "#NPC_CONSCRIPT"
			}
			else if ( ent.IsSpectre() )
			{
				names.attackerName = bossPlayerName
				names.attackerPetName = "#NPC_SPECTRE"
			}
			else
			{
				names.attackerName = bossPlayerName
				names.attackerPetName = "_Noun"
			}
		}

		if ( developer() != 0 )
		{
			local title = ent.GetTitle()
			local classname = ent.GetClassname()
			if ( title == "" )
			{
				printt( "-----------------------------------------------" )
				printt( "Tried to print name in obituary for an entity that didn't call SetTitle()" )
				printt( "    ent classname:", classname )
				printt( "    ent title:", title )
				printt( "    ent bossPlayerName:", bossPlayerName )
				printt( "-----------------------------------------------" )
				//title = damageSourceStrings[ eDamageSourceId.unknownBugIt ]
			}
		}

		if ( names.attackerName == "" )
			names.attackerName = ent.GetTitle()
	}

	return names
}

function GetAttackerDisplayNamesDamageSourceId( damageSourceId )
{
	/*
		this is not a great solution for bugs #79124, #79124, #78831 etc.
		but unfortunately the current damage/death system assumes entites exist on the client to
		ask for names etc. this turns out to be a problem when a player disconnects or an entity
		is removed just after he caused a death. I think we should rewrite how it works for R2
	*/

	local killerName = null
	switch( damageSourceId )
	{
		case eDamageSourceId.nuclear_core:
			if ( GAMETYPE == COOPERATIVE )
				killerName = "#NPC_TITAN_NUKE"
			break
		case eDamageSourceId.suicideSpectre:
		case eDamageSourceId.suicideSpectreAoE:
				killerName = "#NPC_SPECTRE_SUICIDE"
			break
	}

	return killerName
}
