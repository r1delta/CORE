// Burn Card Escalation, client side: keeps the lists of burn cards the pilot holds and shows them on the HUD, one label per line
// (bcePilotCardLine0.. and bceTitanCardLine0.. in base_hud.res, line 0 at the bottom). Pilot cards are on the left, left aligned.
// Titan cards wait for the next Titan drop and are on the right, right aligned, under a header saying so. The server sends
// the index of every burn card it gives (ServerCallback_BCE_CardAdded, ServerCallback_BCE_TitanCardAdded) and tells the client
// when all of them are gone (ServerCallback_BCE_CardsCleared), after which it sends the cards that are still held.

const BCE_PILOT_LINES = 11 // pilot card slots: one label each in base_hud.res
const BCE_TITAN_LINES = 8 // header and the seven Titan card slots
const BCE_TITAN_LIST_HEADER = "TITAN CARDS (CONSUMED ON NEXT DROP)"

function main()
{
	Globalize( ServerCallback_BCE_CardAdded )
	Globalize( ServerCallback_BCE_TitanCardAdded )
	Globalize( ServerCallback_BCE_CardsCleared )
	Globalize( ServerCallback_BCE_HighValueTarget )
	Globalize( ServerCallback_BCE_HighValueTargetKilled )

	level.bceCardRefs <- []
	level.bcePilotShown <- false

	level.bceTitanRefs <- []
	level.bceTitanShown <- false

	thread BCE_Client_ListThink()
}

function ServerCallback_BCE_CardAdded( index )
{
	local ref = level.indexToBurnCard[ index ]

	if ( !ArrayContains( level.bceCardRefs, ref ) )
		level.bceCardRefs.append( ref )
}

function ServerCallback_BCE_TitanCardAdded( index )
{
	local ref = level.indexToBurnCard[ index ]

	if ( !ArrayContains( level.bceTitanRefs, ref ) )
		level.bceTitanRefs.append( ref )
}

function ServerCallback_BCE_CardsCleared()
{
	level.bceCardRefs.clear()
	level.bceTitanRefs.clear()
}

// Announces a pilot who just became a High-Value Target in the event notification the First Strike message uses (same position,
// fade and 3 seconds on screen, white text with the name in red, or in teal when it is you; the colors are in the strings)
function ServerCallback_BCE_HighValueTarget( eHandle )
{
	local target = GetEntityFromEncodedEHandle( eHandle )
	if ( !IsValid( target ) || !target.IsPlayer() )
		return

	local text = target == GetLocalViewPlayer() ? "#BCE_HVT_FRIENDLY" : "#BCE_HVT_ENEMY"
	SetTimedEventNotification( 3.0, text, target.GetPlayerName() )
}

// Announces who claimed the bounty on a High-Value Target, the way a kill on the mark is announced in Marked for Death: the
// event notification over the death screen fade, three seconds, "<killer> killed <target>" with each name red, or teal when it
// is you (the colors are in the strings)
function ServerCallback_BCE_HighValueTargetKilled( killerHandle, victimHandle )
{
	local killer = GetEntityFromEncodedEHandle( killerHandle )
	local victim = GetEntityFromEncodedEHandle( victimHandle )
	if ( !IsValid( killer ) || !killer.IsPlayer() || !IsValid( victim ) || !victim.IsPlayer() )
		return

	local localPlayer = GetLocalViewPlayer()
	local text = "#BCE_HVT_CLAIMED"
	if ( killer == localPlayer )
		text = "#BCE_HVT_CLAIMED_BY_YOU"
	else if ( victim == localPlayer )
		text = "#BCE_HVT_CLAIMED_ON_YOU"

	SetTimedEventNotification( 3.0, text, killer.GetPlayerName(), victim.GetPlayerName(), EN_SHOW_OVER_SCREENFADE )
}

// The cockpit and its HUD elements are rebuilt on every spawn, so the lists are applied from a loop
function BCE_Client_ListThink()
{
	for ( ;; )
	{
		wait 0.1
		BCE_Client_UpdateLists()
	}
}

function BCE_Client_UpdateLists()
{
	// With nothing held the labels only need clearing if this script filled them in
	if ( level.bceCardRefs.len() == 0 && level.bceTitanRefs.len() == 0 && !level.bcePilotShown && !level.bceTitanShown )
		return

	local player = GetLocalViewPlayer()
	if ( !IsValid( player ) || player != GetLocalClientPlayer() )
		return

	local cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) || !( "mainVGUI" in cockpit.s ) )
		return

	// A new cockpit means fresh labels, so nothing has been written to them yet
	if ( !( "bcePilotLines" in cockpit.s ) )
	{
		local panel = cockpit.s.mainVGUI.GetPanel()

		cockpit.s.bcePilotLines <- []
		for ( local i = 0; i < BCE_PILOT_LINES; i++ )
			cockpit.s.bcePilotLines.append( HudElement( "bcePilotCardLine" + i, panel ) )

		cockpit.s.bceTitanLines <- []
		for ( local i = 0; i < BCE_TITAN_LINES; i++ )
			cockpit.s.bceTitanLines.append( HudElement( "bceTitanCardLine" + i, panel ) )

		cockpit.s.bcePilotText <- null
		cockpit.s.bceTitanText <- null
	}

	local pilotTitles = BCE_Client_GetTitles( level.bceCardRefs, null )
	local titanTitles = BCE_Client_GetTitles( level.bceTitanRefs, BCE_TITAN_LIST_HEADER )

	level.bcePilotShown = BCE_Client_ShowLines( cockpit.s.bcePilotLines, cockpit.s, "bcePilotText", pilotTitles )
	level.bceTitanShown = BCE_Client_ShowLines( cockpit.s.bceTitanLines, cockpit.s, "bceTitanText", titanTitles )
}

// The titles of the cards, top to bottom, under an optional header line. Empty when there are no cards.
function BCE_Client_GetTitles( refs, header )
{
	local titles = []
	if ( refs.len() == 0 )
		return titles

	if ( header != null )
		titles.append( header )

	foreach ( ref in refs )
		titles.append( Localize( GetBurnCardTitle( ref ) ) )

	return titles
}

// Puts the titles on the line labels, the last title on line 0 at the bottom, and hides the lines that are not needed.
// Returns whether there is a list showing.
function BCE_Client_ShowLines( lines, state, textKey, titles )
{
	if ( titles.len() == 0 )
	{
		if ( state[ textKey ] != null )
		{
			state[ textKey ] = null
			foreach ( line in lines )
			{
				line.SetText( "" )
				line.Hide()
			}
		}

		return false
	}

	local joined = ""
	foreach ( title in titles )
		joined += title + "\n"

	// Only touch the labels when something changed, or when the spawn gave us fresh ones
	if ( joined == state[ textKey ] )
		return true

	state[ textKey ] = joined

	for ( local i = 0; i < lines.len(); i++ )
	{
		local index = titles.len() - 1 - i
		if ( index >= 0 )
		{
			lines[i].SetText( titles[ index ] )
			lines[i].Show()
		}
		else
		{
			lines[i].SetText( "" )
			lines[i].Hide()
		}
	}

	return true
}
