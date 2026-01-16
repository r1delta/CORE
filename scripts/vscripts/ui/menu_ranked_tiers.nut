
function main()
{
	Globalize( OnOpenRankedTiersMenu )
}

function OnOpenRankedTiersMenu()
{
	if ( !IsFullyConnected() )
		return

	local menu = GetMenu( "RankedTiersMenu" )

	// Highlight players current rank
	local division = GetPlayerDivision()
	local tier = GetPlayerTier()

	local highlight = menu.GetChild( "Highlight" )
	local highlightLabel = menu.GetChild( "HighlightLabel" )

	highlightLabel.SetText( GetTierName( tier ) )

	local parentTier = menu.GetChild( "DivisionTierName" + division + "_" + tier )
	local parentPos = parentTier.GetAbsPos()
	local parentSize = parentTier.GetSize()
	local center = [ parentPos[0] + ( parentSize[0] / 2.0 ), parentPos[1] + ( parentSize[1] / 2.0 ) ]
	local highlightSize = highlight.GetSize()

	highlight.SetPos( center[0] - highlightSize[0] / 2.0, center[1] - highlightSize[1] / 2.0 )

	highlight.Show()
	highlightLabel.Show()
}