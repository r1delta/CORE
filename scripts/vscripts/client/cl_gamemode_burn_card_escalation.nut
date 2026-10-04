// Burn Card Escalation, client side: keeps the lists of burn cards the pilot holds and shows them on the HUD. Pilot cards are on
// the left, in their own label (bcePilotCardsList in base_hud.res). Titan cards wait for the next Titan drop and are on the right, in
// the burn card label of the cockpit HUD where the active burn card is normally shown, under a header saying so. The server sends
// the index of every burn card it gives (ServerCallback_BCE_CardAdded, ServerCallback_BCE_TitanCardAdded) and tells the client
// when all of them are gone (ServerCallback_BCE_CardsCleared), after which it sends the cards that are still held.

const BCE_LIST_LINE_HEIGHT = 14 // in 480p units, scaled to the screen below
const BCE_TITAN_LIST_HEADER = "TITAN CARDS (CONSUMED ON NEXT DROP)"

function main()
{
	Globalize( ServerCallback_BCE_CardAdded )
	Globalize( ServerCallback_BCE_TitanCardAdded )
	Globalize( ServerCallback_BCE_CardsCleared )

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
	if ( !IsValid( cockpit ) || !( "mainVGUI" in cockpit.s ) || !( "burnCardTitle" in cockpit.s ) )
		return

	// A new cockpit means fresh labels, so nothing has been written to them yet
	if ( !( "bcePilotList" in cockpit.s ) )
	{
		cockpit.s.bcePilotList <- HudElement( "bcePilotCardsList", cockpit.s.mainVGUI.GetPanel() )
		cockpit.s.bcePilotText <- null
		cockpit.s.bceTitanText <- null
	}

	// The pilot cards are in their own label; the stock one is a centered label, so it grows around its anchor
	level.bcePilotShown = BCE_Client_ShowList( cockpit.s.bcePilotList, cockpit.s, "bcePilotText", level.bceCardRefs, null, false )
	level.bceTitanShown = BCE_Client_ShowList( cockpit.s.burnCardTitle, cockpit.s, "bceTitanText", level.bceTitanRefs, BCE_TITAN_LIST_HEADER, true )
}

// Writes the titles of the cards into the label, one per line under an optional header line, and hides it when there are none.
// Returns whether the label is showing cards.
function BCE_Client_ShowList( label, state, textKey, refs, header, centered )
{
	if ( refs.len() == 0 )
	{
		if ( state[ textKey ] != null )
		{
			state[ textKey ] = null
			label.SetText( "" )
			label.Hide()
		}

		return false
	}

	local text = header != null ? header + "\n" : ""
	foreach ( ref in refs )
		text += Localize( GetBurnCardTitle( ref ) ) + "\n"

	// Only touch the label when something changed, or when the spawn gave us a fresh one
	if ( text == state[ textKey ] )
		return true

	state[ textKey ] = text

	local lines = refs.len() + ( header != null ? 1 : 0 )
	local scale = Hud.GetScreenSize()[1] / 480.0
	local height = ( BCE_LIST_LINE_HEIGHT * lines * scale ).tointeger()

	if ( centered )
	{
		// Taller by the extra height, moved up by half of it, so the list grows upward only
		height = max( height, label.GetBaseHeight() )
		label.SetHeight( height )
		label.SetPos( 0, -( height - label.GetBaseHeight() ) / 2 )
	}
	else
	{
		label.SetHeight( height )
	}

	label.SetText( text )
	label.Show()
	return true
}
