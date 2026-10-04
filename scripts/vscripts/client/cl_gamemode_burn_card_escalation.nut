// Burn Card Escalation, client side: keeps the list of burn cards the pilot holds and shows it in the burn card label of the
// cockpit HUD, where the active burn card is normally shown. The server sends the index of every burn card it gives
// (ServerCallback_BCE_CardAdded) and tells the client when all of them are gone (ServerCallback_BCE_CardsCleared).

const BCE_LIST_LINE_HEIGHT = 14 // in 480p units, scaled to the screen below

function main()
{
	Globalize( ServerCallback_BCE_CardAdded )
	Globalize( ServerCallback_BCE_CardsCleared )

	level.bceCardRefs <- []
	level.bceListLabel <- null
	level.bceListText <- ""

	thread BCE_Client_ListThink()
}

function ServerCallback_BCE_CardAdded( index )
{
	local ref = level.indexToBurnCard[ index ]

	if ( !ArrayContains( level.bceCardRefs, ref ) )
		level.bceCardRefs.append( ref )
}

function ServerCallback_BCE_CardsCleared()
{
	level.bceCardRefs.clear()
}

// The cockpit and its HUD elements are rebuilt on every spawn, so the list is applied from a loop
function BCE_Client_ListThink()
{
	for ( ;; )
	{
		wait 0.1
		BCE_Client_UpdateList()
	}
}

function BCE_Client_UpdateList()
{
	if ( level.bceCardRefs.len() == 0 )
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
