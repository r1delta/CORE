function main()
{
	Globalize( InitBurnCardsFiltersMenu )
	Globalize( OnOpenMenu_BurnCardsFilters )
	level.burnCardFilters <- []
	level.burnCardFilters.resize( BC_GROUPINGS )
}

function InitBurnCardsFiltersMenu( menu )
{

	file.filterButtons <- []
	local buttons = GetElementsByClassname( menu, "BurnCardFilterClass" )
	foreach ( index, button in buttons )
	{
		local table = {}
		table.button <- button

		button.SetParentMenu( menu ) // TMP: should be code
		button.AddEventHandler( UIE_CLICK, Bind( OnFilterButton_Activate ) )
		button.loadoutID = index
		file.filterButtons.append( button )
		level.burnCardFilters[ index ] = false
	}

//	file.filterMessages <- []
//	file.filterMessages[ BCGROUP_SPEED   ] <- "Speed"
//	file.filterMessages[ BCGROUP_STEALTH ] <- "Stealth"
//	file.filterMessages[ BCGROUP_INTEL	 ] <- "Intel"
//	file.filterMessages[ BCGROUP_BONUS   ] <- "Rewards"
//	file.filterMessages[ BCGROUP_NPC 	 ] <- "Non Player Characters"
//	file.filterMessages[ BCGROUP_WEAPON  ] <- "Weapons"
//	file.filterMessages[ BCGROUP_MISC 	 ] <- "Exotic"

	UpdateFilterButtonText()
	AddMenuEventHandler(menu, R1DELTA_UIE_OPEN, OnOpenMenu_BurnCardsFilters)
}

function OnOpenMenu_BurnCardsFilters()
{
}

function OnFilterButton_Activate( button )
{
	level.burnCardFilters[ button.loadoutID ] = !level.burnCardFilters[ button.loadoutID ]
	UpdateFilterButtonText()
}

function UpdateFilterButtonText()
{

}