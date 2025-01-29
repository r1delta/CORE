/*
	ServerCallback_PlayConversation( conversationType, priority )
*/

const MAX_VOICE_DIST_SQRD = 9000000 // 3000 * 3000
const RADIO_SPEECH_DELAY = 0.4
const PLAYER_HEARS_RADIO = false
const FRIENDLY_GRUNT_MINIMAP_MATERIAL = "vgui/HUD/threathud_friendly_soldier"

function main()
{
	InitGlobals()

	// call to attempt to start playing a conversation. will return false if it doesn't play, not that we can do anything about it.
	Globalize( ServerCallback_PlayConversation )
	Globalize( ServerCallback_PlaySquadConversation )
	Globalize( ServerCallback_CancelScene )
	Globalize( Dialog_AddClient )
	Globalize( SetDialogueDebugLevel )
	Globalize( GetDialogueDebugLevel )
	Globalize( VerifyConversationAliases )
	Globalize( ClDebugPlayConversation )
	Globalize( ClDebugPlayVDUAnimation )
	Globalize( ClDebugPlayVDUAnimationOnCharacter )
	Globalize( DisplayVDU )
	Globalize( CancelConversation )
	Globalize( AddSpeakerToBlacklist )
	Globalize( RemoveSpeakerFromBlacklist )

	RegisterSignal( "CancelConversation" )
	RegisterSignal( "ConversationOver" )
	RegisterSignal( "vdu_close" )
	RegisterSignal( "vdu_open" )

	file.nextVoiceIndex <- 0
	file.aiTalkers <- {}
	file.aiTalkers[ TEAM_IMC ] <- {}
	file.aiTalkers[ TEAM_MILITIA ] <- {}
	file.DebugLevel <- 0  // no debug = 0
	AddCreateCallback( "npc_soldier", AI_Dialogue_General_Init )

	file.squadConversationDebounceSettings <- {}
	file.squadConversationDebounceSettings[ VO_PRIORITY_AI_CHATTER_LOWEST ] <- { minTime = 5.0, maxTime = 8.0 }
	file.squadConversationDebounceSettings[ VO_PRIORITY_AI_CHATTER_LOW ] 	<- { minTime = 5.0, maxTime = 7.0 }
	file.squadConversationDebounceSettings[ VO_PRIORITY_AI_CHATTER ] 		<- { minTime = 4.0, maxTime = 6.0 }
	file.squadConversationDebounceSettings[ VO_PRIORITY_AI_CHATTER_HIGH ] 	<- { minTime = 3.0, maxTime = 5.0 }

	file.squadConversationDebounceTime <- {}
	file.squadConversationDebounceTime[ VO_PRIORITY_AI_CHATTER_LOWEST ] <- 0
	file.squadConversationDebounceTime[ VO_PRIORITY_AI_CHATTER_LOW ] 	<- 0
	file.squadConversationDebounceTime[ VO_PRIORITY_AI_CHATTER ] 		<- 0
	file.squadConversationDebounceTime[ VO_PRIORITY_AI_CHATTER_HIGH ] 	<- 0

	file.squadConversationPriorities <- [
		VO_PRIORITY_AI_CHATTER_LOWEST,
		VO_PRIORITY_AI_CHATTER_LOW,
		VO_PRIORITY_AI_CHATTER,
		VO_PRIORITY_AI_CHATTER_HIGH
	]

	//Debug stuff for QA
	RegisterFunctionDesc( "ClDebugPlayConversation", " Play conversation specified on this client." )
	AddKillReplayStartedCallback( ResetSquadConversationDebounce )
	AddKillReplayEndedCallback( ResetSquadConversationDebounce )
}

function EntitiesDidLoad()
{
	VerifyConversationAliases()
}


function AI_Dialogue_General_Init( guy, isRecreate )
{
	local team = guy.GetTeam()
	guy.s.spawnTeam <- team // so they use native tongue if they switch teams

	if ( !( team in file.aiTalkers ) )
		return

	local dialogue = {}
	dialogue.voiceIndex <- file.nextVoiceIndex
	file.nextVoiceIndex = (file.nextVoiceIndex + 1) % VOICE_COUNT

	dialogue.enabled <- true

	dialogue.hasBeenAlerted <- false
	dialogue.currentConversationPriority <- 0 // track priority of current conversation for this ai

	guy.s.dialogue <- dialogue

	file.aiTalkers[ team ][ guy ] <- guy
}


function InitGlobals()
{
	if ( reloadingScripts )
		return

	level.ConversationIndices		<- {}
	level.CurrentPriority			<- 0
	level.AnnouncementPriority		<- 1000
	level.debugType					<- ""

	level.DefaultLineInterval		<- 0.45	// default interval between lines in a conversations

	level.ConversationIntervalMin	<- 0.5	// interval between conversations in the form of delay before last vdu will close
	level.ConversationIntervalMax	<- 1.0

	level.speakerBlacklist          <- {}
}

function GetDialogueDebugLevel()
{
	return file.DebugLevel
}

function SetDialogueDebugLevel( level )
{
	file.DebugLevel = level
}

function Dialog_AddClient( player )
{
	player.cv.activeScenes <- {}
}

function GetConversationPriority( conversationType )
{
	return level.Conversations[ conversationType ].priority
}

function PlayConversationToLocalClient( convAlias )
{
	if ( IsWatchingKillReplay() )
	{
		if ( file.DebugLevel > 1 )
			printt( "Watching kill replay, not attempting conversation" )

		return
	}

	local priority = level.Conversations[ convAlias ].priority
	local player = GetLocalClientPlayer()

	if ( IsLobby() ) // TEMP: Too many MP assumptions that fail in lobby so just play directly
		thread ClRunConversation( player, convAlias )
	else
		thread ClAttemptConversation( convAlias, player, priority )

}
Globalize( PlayConversationToLocalClient )

function ServerCallback_PlayConversation( conversationIndex )
{
	local player = GetLocalClientPlayer()
	local conversationType = GetConversationName( conversationIndex )
	PlayConversationToLocalClient( conversationType )
}

function ServerCallback_CancelScene( sceneIndex )
{
	// scene index unused... we only ever made one scene

	local player = GetLocalClientPlayer()
	player.cv.activeScenes = {}
}

function ServerCallback_PlaySquadConversation( conversationIndex, eHandle1, eHandle2, eHandle3, eHandle4 )
{
	local ai = GetEntityFromEncodedEHandle( eHandle1 )
	if ( !IsAlive( ai ) )
		return

	local squad = []
	squad.append( ai )

	if ( eHandle2 != null )
	{
		local ent = GetEntityFromEncodedEHandle( eHandle2 )
		if ( IsValid( ent ) )
			squad.append( ent )
	}

	if ( eHandle3 != null )
	{
		local ent = GetEntityFromEncodedEHandle( eHandle3 )
		if ( IsValid( ent ) )
			squad.append( ent )
	}
	if ( eHandle4 != null )
	{
		local ent = GetEntityFromEncodedEHandle( eHandle4 )
		if ( IsValid( ent ) )
			squad.append( ent )
	}

	local foundNonSoldier = false
	local dialogueNotInitialized = false
	foreach ( soldier in squad )
	{
		if ( !( "dialogue" in soldier.s ) )
			dialogueNotInitialized = true

		if ( soldier.GetSignifierName() == "npc_soldier" )
			continue

		foundNonSoldier = true
		break
	}

	local conversationType = GetConversationName( conversationIndex )

	if ( foundNonSoldier )
	{
		printt( "ABORTING CONVERSATION: Found non soldier in conversation: " + conversationType )
		foreach ( soldier in squad )
		{
			printt( "Soldier is " + soldier.GetSignifierName() )
		}
//		Assert( 0, "See above, found non soldier in conversation" )
		return
	}

	if ( dialogueNotInitialized ) //JFS. Kill replay shenenigans with create callback not being run
	{
		printt( "ABORTING CONVERSATION: .s.dialogue not initialized: " + conversationType )
		return
	}





	local team = ai.GetTeam()
	Assert( team in file.aiTalkers, "Unknown AI team " + team )
	local priority = level.Conversations[ conversationType ].priority

	if ( file.DebugLevel > 1 )
	{
		printt( "Attempting squad conversation " + conversationType )
	}

	local currentConversationPriority = GetSquadConversationPriority( squad )

	if ( priority <= currentConversationPriority ) //Only cancel if squad conversation is higher priority
	{
		if ( file.DebugLevel > 1 )
			printt( "Priority of conversationType " + conversationType + " is " + priority + ", which is not higher than CurrentConversationPriority of " + currentConversationPriority + ", cancelling squad conversation " )

		return
	}

	foreach ( squadPriority in file.squadConversationPriorities )
	{
		if ( priority <= squadPriority )
		{
			if ( Time() < file.squadConversationDebounceTime[ squadPriority ] )
			{
				return
			}
		}
	}

	local min = file.squadConversationDebounceSettings[ priority ].minTime
	local max = file.squadConversationDebounceSettings[ priority ].maxTime
	file.squadConversationDebounceTime[ priority ] = Time() + RandomFloat( min, max )

    if ( currentConversationPriority )
	{
		CancelSquadConversation( squad )
	}

	local player = GetLocalViewPlayer()
	thread ClRunSquadConversation( player, conversationType, squad )
}

function ResetSquadConversationDebounce()
{
	foreach ( priority in file.squadConversationPriorities )
	{
		file.squadConversationDebounceTime[ priority ] = 0
	}
}
Globalize( ResetSquadConversationDebounce )

function GetSquadConversationPriority( squad )
{
	local highest = 0
	foreach ( guy in squad )
	{
		// handle deletion
		if ( !IsValid( guy ) )
			continue

		if ( guy.s.dialogue.currentConversationPriority > highest )
		{
			highest = guy.s.dialogue.currentConversationPriority
		}
	}

	return highest
}

function ClDebugPlayConversation( conversationType )
{
	thread ClRunConversation( GetLocalViewPlayer(), conversationType )
}

function ClDebugPlayVDUAnimation( animName )
{
	thread ClDebugPlayVDUAnimation_internal( animName )

}

function ClDebugPlayVDUAnimation_internal( animName )
{
	local teamArray = [ TEAM_IMC, TEAM_MILITIA, "neutral" ]

	foreach( index, convType in level.Conversations )
	{
		foreach( team in teamArray )
		{
			local convElement = convType[ team ]
			foreach( elemArray in convElement  )
			{
				foreach( elem in elemArray )
				{
					if ( elem.dialogType == "vdu_thread" ||  elem.dialogType == "vdu"  )
					{
						if ( elem.vduAnim == animName )
						{

							local player = GetLocalViewPlayer()
							//Note that this plays only that particular element. If the animation doesn't have voice embedded in it, it won't work.
							ClRunConversationElement( player, elem ) //Thus ends the most nested for loop Chin has ever written in non-throw away code ever.

							player.Signal( "ConversationOver" ) //Needed to close the VDU window

							return
						}
					}
				}

			}

		}

	}

	printt( "Could not find a VDU using animName: " + animName )
}

function ClDebugPlayVDUAnimationOnCharacter( character, animName )
{
	thread ClDebugPlayVDUAnimationOnCharacter_internal( character, animName )
}

function ClDebugPlayVDUAnimationOnCharacter_internal( character, animName )
{
	local player = GetLocalClientPlayer()

	local duration = DisplayVDU( player, character, animName )

	wait duration

	player.Signal( "ConversationOver" )
}

function ClAttemptConversation( conversationType, player, priority )
{
	if ( !level.vduEnabled )
		return

	// no conversations during scripted VDUs
	if ( level.vduLocked )
		return

	if ( file.DebugLevel > 0 )
	{
		printt( "Attempting conversation " + conversationType )
	}

	// compare new priority to current priority
	if ( AbortConversationDueToPriority( priority ) )
	{
		if ( file.DebugLevel > 1 )
			printt( "Discarding conversation \"" + conversationType + "\" of priority " + priority +
			" , which is less than either existing level priority " + level.CurrentPriority +
			" or is less than existing announcement priority " + level.AnnouncementPriority +
			" on player: " + player )
		return
	}

	//if ( IsLockedVDU() )
	//{
	//	if ( file.DebugLevel > 1 )
	//		printt( "VDU is locked on player " + player + ", discarding conversation " + conversationType )
	//	return
	//}

	player.ClientCommand("callConversationOverEndSignal")

	local team = player.GetTeam()

	if ( !AttemptScene( conversationType, player, team ) )
	{
		if ( file.DebugLevel > 0 )
			printt( "Scene not valid" )
			return
	}

	// cancel any playing conversation
	CancelConversation( player )

	level.CurrentPriority = priority

	if ( file.DebugLevel > 1 )
		printt( "Playing conversation \"" + conversationType + "\" of priority " + priority )

	thread ClRunConversation( player, conversationType )
}


function AttemptScene( conversationName, player, team )
{
	local conversationTable = level.Conversations[ conversationName ]

	local sceneName = null

	sceneName = conversationTable.scene[team]
	if ( !sceneName )
		sceneName = conversationTable.scene["neutral"]

	if ( !sceneName )
	{
		foreach ( sceneName, sceneData in player.cv.activeScenes )
		{
			// TODO: add a timeout check on sceneData

			if ( conversationName in level.scenes[sceneName].exclusions[team] )
			{
				if ( file.DebugLevel > 0 )
					printt( conversationName, "exluded from", sceneName, "for team", team )
				return false
			}
		}

		return true
	}

	local scene = level.scenes[sceneName]
	local conversation = scene.conversations[team][conversationName]

	if ( !(sceneName in player.cv.activeScenes) )
	{
		// not a valid starting conversation for this scene
		if ( !(conversation.flags & CONVFLAG_STARTPOINT) )
		{
			if ( file.DebugLevel > 0 )
				printt( "not a valid starting conversation for this scene" )
			return false
		}

		player.cv.activeScenes[sceneName] <- {
			index = -1
			startTime = Time()
			lastTime = null
		}
	}

	// scene timed out
	if ( player.cv.activeScenes[sceneName].lastTime && Time() - player.cv.activeScenes[sceneName].lastTime > 60.0 )
	{
		if ( file.DebugLevel > 0 )
			printt( "scene timed out", ( Time() - player.cv.activeScenes[sceneName].lastTime ) )
		delete player.cv.activeScenes[sceneName]

		// try it again in case it's a valid start point
		return AttemptScene( conversationName, player, team )
	}

	if ( !(conversation.flags & CONVFLAG_UNORDERED) )
	{
		// we're already beyond this point
		if ( player.cv.activeScenes[sceneName].index >= conversation.index )
		{
			if ( file.DebugLevel > 0 )
				printt( "we're already beyond this point" )
			return false
		}
		player.cv.activeScenes[sceneName].index = conversation.index
	}

	player.cv.activeScenes[sceneName].lastTime = Time()

	if ( conversation.flags & CONVFLAG_ENDPOINT )
		delete player.cv.activeScenes[sceneName]

	return true
}

function CancelSquadConversation( squad )
{
	local currentConversationPriority = GetSquadConversationPriority( squad )
	//printt( "priority was " + currentConversationPriority )
	if ( file.DebugLevel > 1 )
	{
		printt( "Cancelling squad conversation" )
	}

	foreach ( guy in squad )
	{
		if ( IsValid( guy ) )
		{
			guy.Signal( "CancelConversation" )
			guy.s.dialogue.currentConversationPriority = 0
		}
	}
}

function CancelConversation( player )
{
	if ( file.DebugLevel > 0 )
	{
		if ( level.CurrentPriority )
			printt( "Cancelling conversation of priority " + level.CurrentPriority )
	}

	local clientPlayer = GetLocalClientPlayer()
	clientPlayer.Signal( "CancelConversation" )
	player.Signal( "CancelConversation" )
	ClearVDUCharacter( player )

	// signaling "CancelConversation" to the player should cause him to be clear level.CurrentPriority.
	// This happend in the OnThreadEnd for RunConversation(...)
	Assert( !level.CurrentPriority )
}


function AbortConversationDueToPriority( priority )
{
	// will return true if the conversation should not play
	if ( priority > level.CurrentPriority )
		return false

	// conversations above level.AnnouncementPriority interupt conversations of the same priority level
	if ( priority < level.AnnouncementPriority )
		return true

	return priority < level.CurrentPriority
}

function GetConversationTeam( player, squad = null )
{
	if ( squad )
		return squad[0].s.spawnTeam

	return player.GetTeam()
}

function ClRunConversation( player, conversationType )
{
	OnThreadEnd(
		function() : ( player )
		{
			level.CurrentPriority = 0
			if ( IsValid( player ) ) {
				player.Signal( "ConversationOver" )
				player.ClientCommand("callConversationOverSignal")
				printt( "ConversationOver signal sent" )
			}
			if ( file.DebugLevel > 1 )
				printt( "ConversationOver signal sent" )
		}
	)

	level.debugType = conversationType

	player.EndSignal( "CancelConversation" )
	player.EndSignal( "OnDestroy" )

	// returns a pseudo random conversation for this team
	local conversation = ClSelectRandomConversation( conversationType, player.GetTeam() )
	// removes all but one alias choice in the conversation
	conversation = RemoveChoicesFromConversation( conversation )

	// temp debug print
	local numRadio = 0
	foreach ( elem in conversation )
	{
		if ( elem.dialogType == "radio" )
			numRadio++
	}

	printt( " Starting conversation " + conversationType + " with " + numRadio + " lines for " + player.GetPlayerName() )

//	Dump( conversation, 2 )
	foreach ( index, elem in conversation )
	{
		if ( file.DebugLevel > 1 )
		{
			printt( " Running elem " + elem )
		}

		ClRunConversationElement( player, elem )	// in the future indexed NPC speakers need to be passed as well for AI dialogue

		if ( file.DebugLevel > 1 )
		{
			printt( " Ended elem " + elem )
		}
	}
}

function RandomizeSquadVoices( squad )
{
	//local squadCopy = clone squad
	//ArrayRandomize( squadCopy )
	//for ( local i = 0; i < squadCopy.len(); i++ )
	//{
	//	squadCopy[i].s.dialogue.voiceIndex = i % VOICE_COUNT
	//	printt( "index is " + squadCopy[i].s.dialogue.voiceIndex )
	//}

	local offset = RandomInt( VOICE_COUNT )
	for ( local i = 0; i < squad.len(); i++ )
	{
		squad[i].s.dialogue.voiceIndex = ( i + offset ) % VOICE_COUNT
//		printt( "index is " + squadCopy[i].s.dialogue.voiceIndex )
	}
}

function ClRunSquadConversation( player, conversationType, squad )
{
	OnThreadEnd(
		function () : ( squad )
		{
			CancelSquadConversation( squad )
		}
	)

	// so the squad members each has a different voice
	RandomizeSquadVoices( squad )

	squad[0].EndSignal( "CancelConversation" )
	player.EndSignal( "OnDestroy" )

	local priority = level.Conversations[ conversationType ].priority
	squad[0].s.dialogue.currentConversationPriority = priority

	level.debugType = conversationType

	// returns a pseudo random conversation for this team
	local conversation = ClSelectRandomConversation( conversationType, GetConversationTeam( player, squad ) )
	// removes all but one alias choice in the conversation
	conversation = RemoveChoicesFromConversation( conversation )


	foreach ( index, elem in conversation )
	{
		if ( file.DebugLevel > 1 )
		{
			printt( " Running elem " + elem )
		}

		ClRunSquadConversationElement( player, elem, squad )	// in the future indexed NPC speakers need to be passed as well for AI dialogue

		if ( file.DebugLevel > 1 )
		{
			printt( " Ended elem " + elem )
		}
	}
}

function ClSelectRandomConversation( conversationType, team )
{
	local conversationTable = level.Conversations[ conversationType ]
	local conversationArray

	Assert( team in conversationTable )

	conversationArray = conversationTable[ team ]

	if ( conversationArray.len() == 0 )
	{
		Assert( "neutral" in conversationTable, "Conversation " + conversationType + " isn't available for team ID: " + team )
		conversationArray = conversationTable[ "neutral" ]
	}

	Assert( IsArray( conversationArray ) )

	// we cycle through a permutation of the conversations.

	// level.ConversationIndices is a map from array to index.
	// Thus it is actually indexed by the array itself.
	if ( !( conversationArray in level.ConversationIndices ) || level.ConversationIndices[ conversationArray ] >= conversationArray.len() )
	{
		// randomize it each time we use up all choices in the conversation
		ArrayRandomize( conversationArray )
		level.ConversationIndices[ conversationArray ] <- 0
	}

	local conversation = conversationArray[ level.ConversationIndices[ conversationArray ] ]

	// next time we'll play the next conversation in the system
	level.ConversationIndices[ conversationArray ]++

	return conversation
}

function RemoveChoicesFromConversation( conversation )
{
	// removes all but one alias choice, per team, in the conversation
	local _conversation = []
	foreach ( elem in conversation )
	{
		local _elem = RemoveChoicesFromElem( elem )
		_conversation.append( _elem )
	}

	return _conversation
}

function RemoveChoicesFromElem( elem )
{
	local _elem = {}
	_elem.dialogType <- elem.dialogType

	switch ( elem.dialogType )
	{
		case "radio":
			// elem.choices should be an array of lines to choose from randomly
			Assert( IsArray( elem.choices ) )

			_elem.alias <- Random( elem.choices )
			if ( "delay" in elem )
				_elem.delay <- elem.delay
			break

		case "multiple":
			local min = 0
			local max = elem.choices.len()

			if ( "min" in elem )
				min = elem.min
			if ( "max" in elem )
			{
				max = elem.max
				if ( max > elem.choices.len() )
					max = elem.choices.len()
			}
			local count = RandomInt( min, max + 1 )
			Assert( count >= min )
			Assert( count <= max )

			if ( file.DebugLevel > 1 )
				printt( "parsing dialogtype multiple. count: " + count )

			if ( elem.randomize )
				ArrayRandomize( elem.choices )

			local _choices = []
			for ( local i = 0; i < count; i++ )
			{
				local subelem = RemoveChoicesFromElem( elem.choices[i] )
				_choices.append( subelem )
			}
			_elem.choices <- _choices
			break

		default:
			_elem = elem
			break
	}

	return _elem
}

function ClRunConversationElement( player, elem )
{
	if ( "chance" in elem )
	{
		local rnd = RandomFloat( 0, 1 )
		if ( rnd >= elem.chance )
		{
			if ( file.DebugLevel > 1 )
				printt( " Skipping random elem: " + rnd + " >= " + elem.chance )

			return
		}
	}

	Assert( IsValid( player ) )

	switch ( elem.dialogType )
	{
		case "radio":
		case "fx":
			Assert( IsString( elem.alias ) )
			if ( SpeakerIsBlacklisted( elem.alias ) )
			{
				if ( file.DebugLevel > 1 )
					printt( "Speaker is blacklisted, not playing radio alias: " + elem.alias )

				return
			}
			local duration = DoGeneralRadioSound( elem.alias, null, player )
			if ( "delay" in elem )
				duration += elem.delay
			else
				duration += level.DefaultLineInterval
			wait duration
			break

		case "music":
			Assert( IsString( elem.alias ) )
			local duration
			duration = DoPlayerMusic( player, elem.alias )
			if ( "halt_conversation" in elem )
				wait duration
			break

		case "dispatch":
			Assert( squad != null, "Can't do a speech conversation without using PlaySquadConversation" )
			// choose an AI to say this
			local guy = squad[0]

			//SpeakingGuy = guy

			if ( !IsAlive( guy ) )
			{
				// We failed to find a guy to speak. Could be that guys have died or walked too far away since the conversation started.
				// for now just bail.

				if ( file.DebugLevel > 1 )
					printl( " Bailing: no guy left to talk" )

				CancelConversation( player )
				break
			}

			// elem.choices should be an array of lines to choose from randomly
			Assert( IsArray( elem.choices ) )

			local dialogueChoice = Random( elem.choices )
			local startTime = Time()

			if ( typeof dialogueChoice == "string" )
			{
				waitthread DoGuySound( guy, guy, dialogueChoice, 0 )
			}
			else
			{
				AssertVoiceAliasDataIsValid( dialogueChoice )

				if ( file.DebugLevel > 1 )
					printt( "Speaking ai: " + guy.GetEntIndex() + " voice index " + guy.s.dialogue.voiceIndex )
				local aliases = GetAliases( guy, dialogueChoice )
				DoGuySpeechLine( guy, aliases )
			}

			//printt( "time passed in dialogue " + ( Time() - startTime  ) )
			wait 0.3 // delay between speech lines

//			if ( IsAlive( guy ) )
//				guy.Signal( "FinishedLine", { alias = aliases.radioAlias } )

			break


		case "wait":
			wait RandomFloat( elem.durationMin, elem.durationMax )
			break

		case "flag_set":
			if ( file.DebugLevel > 1 )
				printt( " Setting flag " + elem.flag )
			FlagSet( elem.flag )
			break

		case "flag_clear":
			if ( file.DebugLevel > 1 )
				printt( " Clearing flag " + elem.flag )
			FlagClear( elem.flag )
			break

		case "flag_wait":
			if ( file.DebugLevel > 1 )
				printt( " Waiting on flag " + elem.flag )

			FlagWait( elem.flag )

			if ( file.DebugLevel > 1 )
				printt( " Flag wait complete" )
			break

		case "function":
			if ( file.DebugLevel > 1 )
				printt( " Calling function " + elem["func"] )

			elem[ "func" ]()
			break

		case "thread":
			if ( file.DebugLevel > 1 )
				printt( " Calling thread " + elem["func"] )

			local func = elem[ "func" ]
			thread func()
			break

		case "vdu_thread":
		case "vdu":
		    if ( "hide" in elem )
			{
				if ( "delay" in elem )
					wait elem["delay"]
				if ( !IsLockedVDU() )
					thread HideVDU()
			}
			else
			{
				if ( IsLockedVDU() )
					return

				Assert( "vduName" in elem )
				if ( SpeakerIsBlacklisted( elem["vduName"] ) )
				{
					if ( file.DebugLevel > 1 )
						printt( "Speaker is blacklisted, not playing vdu anim: " + elem[ "vduAnim" ] )

					return

				}

				local duration = DisplayVDU( player, elem["vduName"], elem["vduAnim"] )

				if ( duration && elem.dialogType != "vdu_thread" )
					wait duration
			}
			break

		case "custom_vdu":
			if ( IsLockedVDU() )
				return

		    if ( "hide" in elem )
			{
				if ( "delay" in elem )
					wait elem["delay"]
				if ( !IsLockedVDU() )
					thread HideVDU()
			}
			else
			{
				Assert( "custom_vdu_func" in elem )
				Assert( !IsLockedVDU() )
				ShowVDU()
				thread CloseVDU( player )
				waitthread elem["custom_vdu_func"]( player )
				// /printt( "custom_vdu_func finished" )
			}
			break

		case "multiple":
			foreach ( subelem in elem.choices )
			{
				// choices and randomization etc removed in RemoveChoicesFromElem( ... )
				ClRunConversationElement( player, subelem )
			}
			break

		default:
			Assert( "Invalid conversation element " + elem.dialogType )
	}
}

function ClRunSquadConversationElement( player, elem, squad = null )
{
	Assert( IsValid( player ) )

	switch ( elem.dialogType )
	{
		case "speech":
			Assert( squad != null, "Can't do a speech conversation without using PlaySquadConversation" )
			// choose an AI to say this
			local guy = ChooseSpeakingAI( squad, elem.speakerIndex )

			//SpeakingGuy = guy

			if ( !guy )
			{
				// We failed to find a guy to speak. Could be that guys have died or walked too far away since the conversation started.
				// for now just bail.

				if ( file.DebugLevel > 1 )
					printl( " Bailing: no guy left to talk" )

				CancelSquadConversation( squad )
				break
			}

			if ( !IsAlive( guy ) )
			{
				// this guy is dead. we should wait a moment and then start an "are you there?" dialogType conversation.
				// for now just bail.

				if ( file.DebugLevel > 1 )
					printl( " Bailing: next guy is dead" )

				CancelSquadConversation( squad )
				break
			}

			// elem.choices should be an array of lines to choose from randomly
			Assert( IsArray( elem.choices ) )

			local dialogueChoice = Random( elem.choices ) //Seems like this is unnecessary since we remove other choices earlier in ClRunSquadConversation, but it's too late in the project to chance changing this...

			AssertVoiceAliasDataIsValid( dialogueChoice )

			if ( file.DebugLevel > 1 )
				printt( "Speaking ai: " + guy.GetEntIndex() + " voice index " + guy.s.dialogue.voiceIndex )
			local aliases = GetAliases( guy, dialogueChoice )
			DoGuySpeechLine( guy, aliases )
			//wait RandomFloat( 0.1, 0.2 )// delay between speech lines. Taking out for now, might bring back later.


			break

		case "dispatch":
			Assert( squad != null, "Can't do a speech conversation without using PlaySquadConversation" )
			// choose an AI to say this
			local guy = squad[0]

			//SpeakingGuy = guy

			if ( !IsAlive( guy ) )
			{
				// We failed to find a guy to speak. Could be that guys have died or walked too far away since the conversation started.
				// for now just bail.

				if ( file.DebugLevel > 1 )
					printl( " Bailing: no guy left to talk" )

				CancelSquadConversation( squad )
				break
			}

			// elem.choices should be an array of lines to choose from randomly
			Assert( IsArray( elem.choices ) )

			local dialogueChoice = Random( elem.choices ) //Seems like this is unnecessary since we remove other choices earlier in ClRunSquadConversation, but it's too late in the project to chance changing this...
			local startTime = Time()

			if ( typeof dialogueChoice == "string" )
			{
				waitthread DoGuySound( guy, guy, dialogueChoice, 0 )
			}
			else
			{
				AssertVoiceAliasDataIsValid( dialogueChoice )

				if ( file.DebugLevel > 1 )
					printt( "Speaking ai: " + guy.GetEntIndex() + " voice index " + guy.s.dialogue.voiceIndex )
				local aliases = GetAliases( guy, dialogueChoice )
				DoGuySpeechLine( guy, aliases )
			}

			//printt( "time passed in dialogue " + ( Time() - startTime  ) )
			wait 0.3 // delay between speech lines

//			if ( IsAlive( guy ) )
//				guy.Signal( "FinishedLine", { alias = aliases.radioAlias } )

			break

		case "multiple":
			foreach ( subelem in elem.choices )
			{
				// choices and randomization etc removed in RemoveChoicesFromElem( ... )
				ClRunSquadConversationElement( player, subelem, squad )
			}
			break

		default:
			Assert( "Invalid conversation element " + elem.dialogType )
	}
}

function DoGeneralRadioSound( alias, sourceGuy, player )
{
	if ( file.DebugLevel > 1 )
	{
		printt( "Playing radio sound alias: " + alias + " to " + player.GetPlayerName() )
	}

//	printt( "playing alias: " + alias + " to " + player.GetPlayerName() )
	local duration = EmitSoundOnEntity( player, alias )
	thread EndPlayerSound( player, sourceGuy, alias, duration )

	return duration
}

function EndPlayerSound( player, sourceGuy, alias, delay = 0 )
{
	// this function is threaded but it needs to end with the conversation
	player.EndSignal( "ConversationOver" )
	player.EndSignal( "OnDestroy" )

	if ( sourceGuy )
		EndSignal( sourceGuy, "OnDeath" )

	OnThreadEnd(
		function () : ( player, alias )
		{
			if( IsValid( player ) )
				StopSoundOnEntity( player, alias )
		}
	)

	// necessary because of the OnThreadEnd
	wait delay	// this is for delayed radio playback of AI dialogue
}

function DoPlayerMusic( player, alias )
{
	if ( file.DebugLevel > 1 )
	{
		printt( "Playing music alias: " + alias + " to " + player )
	}

	local duration = EmitSoundOnEntity( player, alias )

	return duration
}

function DisplayVDU( player, vduName, vduAnim )
{
	if ( file.DebugLevel > 1 )
		printt( "Opening VDU for " + player )

	local duration

	if ( vduAnim )
	{
		ShowVDU( vduName )
		Assert( IsValid( level._vduCharacter ) )
		duration = level._vduCharacter.GetSequenceDuration( vduAnim )
		level._vduCharacter.Anim_Play( vduAnim )

		local closing = 0.65 //This is defined in HudAnimations.txt, look at ClosePilotVDU or CloseTitanVDU. Last number in a line is how long it takes.
		duration = max( 0, duration - closing )

		thread CloseVDU( player )	// close vdu when Conversation is over
	}


	return duration
}

function CloseVDU( player )
{
	printt( "Entering CloseVDU" )
	player.EndSignal( "vdu_open" )
	player.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function () : ( player )
		{
			if ( file.DebugLevel > 1 )
				printt( "Closing VDU for " + player )
			if ( !IsValid( player ) )
				return
			if ( IsLockedVDU() )
				return

			HideVDU()
		}
	)

	printt( "Waiting for ConversationOver" )
	player.WaitSignal( "ConversationOver" )
	printt( "Got ConversationOver" )
	player.Signal( "vdu_close" )
}

function GetAvailableTalkers( team )
{
	local array = []
	local ai = file.aiTalkers[ team ]

	foreach ( ent in clone ai )
	{
		if ( ent.IsValidInternal() )
		{
			array.append( ent )
			continue
		}

		delete ai[ ent ]
	}

	return array
}

function ChooseSpeakingAI( squad, speakerIndex )
{
	// originator has to be alive
	if ( !IsAlive( squad[0] ) )
		return null

	if ( speakerIndex >= squad.len() )
	{
		// find some other dude in the squad
		for ( local i = squad.len() - 1; i > 0; i-- ) //Dont' want to pick squad[0] since he originated the conversation
		{
			if ( IsAlive( squad[i] ) )
				return squad[i]
		}

		return null
	}

	if ( !IsAlive( squad[ speakerIndex ] ) )
		return null

	return squad[ speakerIndex ]

/*
	local player = GetLocalViewPlayer()
	local guys = GetAvailableTalkers( squad[0].GetTeam() )

	if ( RandomInt( 0, 3 ) == 0 )
		ArrayRandomize( guys )
	else
		guys = ArrayClosest( guys, player.GetOrigin() )

	local bestOptions = []
	local options = []

	// get two nearest AI not already in speakerIndexChoices
	foreach ( guy in guys )
	{
		if ( !GuyIsEligibleForDialogue( guy ) )
			continue

		local alreadyUsed = false
		local sameVoice = false
		foreach ( otherguy in speakerIndexChoices )
		{
			if ( guy == otherguy )
			{
				alreadyUsed = true
				break
			}
			if ( guy.s.dialogue.voiceIndex == otherguy.s.dialogue.voiceIndex )
				sameVoice = true
		}

		if ( alreadyUsed )
			continue

		if ( !sameVoice )
			bestOptions.append( guy )

		options.append( guy )
		if ( options.len() >= 2 )
			break
	}

	if ( bestOptions.len() >= 2 )
		options = bestOptions

	if ( options.len() <= 0 )
		return null

	local guy = Random( options )

	speakerIndexChoices[speakerIndex] <- guy

	return guy
	*/
}

function DoGuySound( guy, sourceGuy, alias, delay )
{
	Assert( IsAlive( guy ) )

	OnThreadEnd(
		function () : (guy, alias)
		{
			if ( !IsValid( guy ) )
				return

			//Let the AI have a chance to finish speaking
			if ( !IsAlive( guy ) )
				StopSoundOnEntity( guy, alias )
		}
	)

	guy.EndSignal( "OnDeath" )
	guy.EndSignal( "OnDestroy" )

	if ( sourceGuy && sourceGuy != guy )
		sourceGuy.EndSignal( "OnDeath" )

	wait delay

	local duration = EmitSoundOnEntity( guy, alias )

	wait duration
}

function DoGuySoundSilentWait( guy, sourceGuy, alias )
{
	Assert( IsAlive( guy ) )

	guy.EndSignal( "OnDeath" )
	guy.EndSignal( "OnDestroy" )
	if ( sourceGuy && sourceGuy != guy )
	{
		sourceGuy.EndSignal( "OnDeath" )
		sourceGuy.EndSignal( "OnDestroy" )
	}

	local duration = GetSoundDuration( alias )
	wait duration
}

function DoGuySpeechLine( guy, aliases )
{
	AssertGuyIsDialogueReady( guy )

	local radioAlias = aliases.radioAlias

	if ( file.DebugLevel > 1 )
	{
		printt( " Guy " + guy.GetName() + ": " + radioAlias )
		DebugDrawLine( GetLocalViewPlayer().GetOrigin(), guy.GetOrigin(), 255,255,255, true, 3 )
		DebugDrawText( guy.GetOrigin() + Vector(0,0,60), radioAlias, true, 6.0 )
	}

	waitthread DoGuySound( guy, guy, radioAlias, 0 )
}


function DoGeneralRadioSound_Nonblocking( alias, sourceGuy, delay )
{
	if ( PLAYER_HEARS_RADIO )
	{
		thread DoPlayerSound( GetLocalViewPlayer(), sourceGuy, alias, delay )
	}
	else
	{
		local guys = GetAvailableEnemyTalkers()
		local playerOrigin = GetLocalViewPlayer().GetOrigin()
		guys = ArrayClosest( guys, playerOrigin )

		local guyCount = 0
		foreach ( guy in guys )
		{
			if ( guyCount >= MaxRadioPlayGuys )
				break

			if ( DistanceSqr( guy.GetOrigin(), playerOrigin ) > RadioPlayDistance * RadioPlayDistance )
				break

			if ( guy == sourceGuy )
				continue

			if ( !GuyIsEligibleForDialogue( guy ) )
				continue

			thread DoGuyRadioSound( guy, sourceGuy, alias, delay )
			guyCount++
		}
	}
}

function GuyIsEligibleForDialogue( guy )
{
	if ( !("dialogue" in guy.s ) )
		return false

	if ( !IsAlive( guy ) )
		return false

	if ( DistanceSqr( guy.GetOrigin(), GetLocalViewPlayer().GetOrigin() ) > MAX_VOICE_DIST_SQRD )
		return false

	if ( !guy.s.dialogue.enabled )
		return false

	return true
}

function AssertVoiceAliasDataIsValid( aliasData )
{
	// NONE OF THE FOLLOWING ASSERTS SHOULD HIT IF YOU USE AI_Dialogue_AliasAllVoices OR AI_Dialogue_AliasSingleVoice for aliasData.

	Assert( IsArray( aliasData ) )
	Assert( aliasData.len() == VOICE_COUNT )
	// each voice should have a soundalias for the radio sound
	Assert( IsString( aliasData[0] ) )
}


function GetAliases( guy, dialogue, radioDelayOverride = null )
{
	local aliases = {}

	aliases.radioAlias <- null
	aliases.radioDelay <- null

	aliases.radioAlias = dialogue[ guy.s.dialogue.voiceIndex ]
	aliases.radioDelay = 0

	if ( radioDelayOverride != null )
	{
		aliases.radioDelay = radioDelayOverride
	}

	return aliases
}

function AssertGuyIsDialogueReady( guy )
{
	Assert( "dialogue" in guy.s, guy + " not set up for dialogue; call AI_Dialogue_Scripted_Init on him if this is a scripted conversation" )
}

function DoPlayerSound( player, sourceGuy, alias, delay )
{
	// this function is threaded from DoGeneralRadioSound_Nonblocking, but it needs to end with the conversation
	player.EndSignal( "CancelConversation" )
	player.EndSignal( "OnDestroy" )

	if ( sourceGuy )
	{
		sourceGuy.EndSignal( "OnDeath" )
		sourceGuy.EndSignal( "OnDestroy" )
	}

	wait delay

	OnThreadEnd(
		function () : (player, alias)
		{
			StopSoundOnEntity( player, alias )
		}
	)

	local duration = EmitSoundOnEntity( player, alias )
	wait duration
}

function VerifyConversationAliases()
{
	if ( !GetDeveloperLevel() )
		return

	local e = {}
	e.count <- 0
	e.failed <- {}
	e.tried <- {}
	local conv
	foreach ( table in level.Conversations )
	{
		foreach ( conv in table[ TEAM_IMC ] )
		{
			VerifyConversation( conv, e )
		}
		foreach ( conv in table[ TEAM_MILITIA ] )
		{
			VerifyConversation( conv, e )
		}
	}

	if ( e.failed.len() )
	{
		local failed = []
		foreach ( alias in e.failed )
		{
			failed.append( alias )
		}
		failed.sort( SortAlphabetize )
		foreach ( alias in failed )
		{
			CodeWarning( "Sound alias " + alias + " not found!\n" )
		}

	}
}

function VerifyConversation( convArray, e )
{
	foreach ( conv in convArray )
	{
		if ( !( "choices" in conv ) )
			continue

		if ( conv.dialogType == "temp_text" )
			continue

		foreach ( array in conv.choices )
		{
			if ( typeof array == "string" )
			{
				VerifyConversationAlias( array, e )
				continue
			}

			foreach ( aliases in array )
			{
				if ( typeof aliases == "array" )
				{
					foreach ( alias in aliases )
					{
						VerifyConversationAlias( alias, e )
					}
				}
				else
				{
					VerifyConversationAlias( aliases, e )
				}
			}
		}
	}
}

function VerifyConversationAlias( alias, e )
{
	if ( alias in e.tried )
		return
	e.tried[ alias ] <- alias

	local result = DoesAliasExist( alias )

	if ( !result )
	{
		if ( !( alias in e.failed ) )
			e.failed[ alias ] <- alias
	}
}

function AddSpeakerToBlacklist( character )
{
	if ( character in level.speakerBlacklist )
		return

	level.speakerBlacklist[ character ] <- true
}

function RemoveSpeakerFromBlacklist( character )
{
	if ( !(character in level.speakerBlacklist ) )
		return

	delete level.speakerBlacklist[ character ]
}

function SpeakerIsBlacklisted( alias )
{
	foreach( speaker, _ in level.speakerBlacklist )
	{
		if ( alias.find( speaker ) != null )
			return true
	}

	return false
}
