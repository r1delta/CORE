// Burn Card Escalation, client side: keeps the lists of burn cards the pilot holds. Pilot cards are shown in the burn card label
// of the cockpit HUD, where the active burn card is normally shown. Titan cards wait for the next Titan drop and are listed
// on the left of the screen under their own header (bceTitanCardsHeader and bceTitanCardsList in base_hud.res). The server sends
// the index of every burn card it gives (ServerCallback_BCE_CardAdded, ServerCallback_BCE_TitanCardAdded) and tells the client
// when all of them are gone (ServerCallback_BCE_CardsCleared), after which it sends the cards that are still held.

const BCE_LIST_LINE_HEIGHT = 14 // in 480p units, scaled to the screen below

function main()
{
	Globalize( ServerCallback_BCE_CardAdded )
	Globalize( ServerCallback_BCE_TitanCardAdded )
	Globalize( ServerCallback_BCE_CardsCleared )

	level.bceCardRefs <- []
	level.bceListLabel <- null
	level.bceListText <- ""

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

// The cockpit and its HUD elements are rebuilt on every spawn, so the list is applied from a loop
function BCE_Client_ListThink()
{
	for ( ;; )
	{
		wait 0.1
		BCE_Client_UpdateList()
		BCE_Client_UpdateTitanList()
	}
}

function BCE_Client_UpdateList()
{
	// With nothing held the label only needs clearing if this script filled it in
	if ( level.bceCardRefs.len() == 0 && level.bceListText == "" )
		return

	local player = GetLocalViewPlayer()
	if ( !IsValid( player ) || player != GetLocalClientPlayer() )
		return

	local cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) || !( "burnCardTitle" in cockpit.s ) )
		return

	local label = cockpit.s.burnCardTitle

	local text = ""
	foreach ( ref in level.bceCardRefs )
		text += Localize( GetBurnCardTitle( ref ) ) + "\n"

	if ( level.bceCardRefs.len() == 0 )
	{
		level.bceListText = ""
		label.SetText( "" )
		label.Hide()
		return
	}

	// Only touch the label when something changed, or when the spawn gave us a fresh one
	if ( label == level.bceListLabel && text == level.bceListText )
		return

	level.bceListLabel = label
	level.bceListText = text

	// The label is centered on its anchor, so grow it upward only: taller by the extra height, moved up by half of it
	local scale = Hud.GetScreenSize()[1] / 480.0
	local height = ( BCE_LIST_LINE_HEIGHT * level.bceCardRefs.len() * scale ).tointeger()
	height = max( height, label.GetBaseHeight() )

	label.SetHeight( height )
	label.SetPos( 0, -( height - label.GetBaseHeight() ) / 2 )
	label.SetText( text )
	label.Show()
}

// The Titan cards, on the left of the screen. The header is only there while at least one card is held.
function BCE_Client_UpdateTitanList()
{
	// With nothing held the labels only need hiding if this script showed them
	if ( level.bceTitanRefs.len() == 0 && !level.bceTitanShown )
		return

	local player = GetLocalViewPlayer()
	if ( !IsValid( player ) || player != GetLocalClientPlayer() )
		return

	local cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) || !( "mainVGUI" in cockpit.s ) || !( "burnCardTitle" in cockpit.s ) )
		return

	// The cockpit and its HUD elements are rebuilt on every spawn
	if ( !( "bceTitanList" in cockpit.s ) )
	{
		local panel = cockpit.s.mainVGUI.GetPanel()
		cockpit.s.bceTitanHeader <- HudElement( "bceTitanCardsHeader", panel )
		cockpit.s.bceTitanList <- HudElement( "bceTitanCardsList", panel )
		cockpit.s.bceTitanText <- null
	}

	local header = cockpit.s.bceTitanHeader
	local list = cockpit.s.bceTitanList

	if ( level.bceTitanRefs.len() == 0 )
	{
		level.bceTitanShown = false
		header.Hide()
		list.SetText( "" )
		list.Hide()
		cockpit.s.bceTitanText = null
		return
	}

	local text = ""
	foreach ( ref in level.bceTitanRefs )
		text += Localize( GetBurnCardTitle( ref ) ) + "\n"

	// Only touch the labels when something changed, or when the spawn gave us fresh ones
	if ( text == cockpit.s.bceTitanText )
		return

	cockpit.s.bceTitanText = text
	level.bceTitanShown = true

	local scale = Hud.GetScreenSize()[1] / 480.0
	list.SetHeight( ( BCE_LIST_LINE_HEIGHT * level.bceTitanRefs.len() * scale ).tointeger() )
	list.SetText( text )
	header.Show()
	list.Show()
}
