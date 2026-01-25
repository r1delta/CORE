function main()
{
	Globalize( InitNewBurnCardPackMenu )
	Globalize( OnOpenBurnCards_NewPacks )
}


function InitNewBurnCardPackMenu( menu )
{
	// new burn card stuff
	file.NewBurnCardBackground	<- menu.GetChild( "NewBurnCardBackground" )
	file.NewBurnCardDialog	<- menu.GetChild( "NewBurnCardDialog" )
	file.NewBurnCardTitle <- menu.GetChild( "NewBurnCardTitle" )
	
	file.burnCardPackButtons <- GetElementsByClassname( menu, "BurnCardNewPackClass" )
	
	file.burnCardPackImages <- GetElementsByClassname( menu, "BurnCardNewPackPanelClass" )
	file.transitioning <- false
	
	file.NewBurnCardSubTitle <- menu.GetChild( "NewBurnCardSubTitle" ) 

	foreach ( index, button in file.burnCardPackButtons )
	{
		local table = {}
		table.button <- button

		button.SetParentMenu( menu ) // TMP: should be code
		local buttonID = button.GetScriptID().tointeger()
		button.loadoutID = buttonID
		button.AddEventHandler( UIE_CLICK, Bind( NewBurnCardPack_Click ) )
		button.AddEventHandler( UIE_GET_FOCUS, Bind( NewBurnCardPack_Focus ) )
		button.SetText( "" )
	}	
}

function DelayedRefreshPacks()
{
	WaitEndFrame()
	foreach ( index, button in file.burnCardPackButtons )
	{
		if ( button.IsFocused() )
		{
			file.burnCardPackImages[ index ].SetAlpha( 255 )
			file.burnCardPackImages[ index ].SetScale( 1.1, 1.1 )
		}
		else
		{
			file.burnCardPackImages[ index ].SetAlpha( 55 )
			file.burnCardPackImages[ index ].SetScale( 1.0, 1.0 )
		}
	}
}

function NewBurnCardPack_Click( button )
{
	file.transitioning = true

	ClientCommand( "BCOpenPack " + button.loadoutID )
	thread DelayedOpenNewCards()

	local time = 0.5
	foreach ( index, button in file.burnCardPackButtons )
	{
		if ( button.IsFocused() )
		{
			file.burnCardPackImages[ index ].FadeOverTime( 0, time, INTERPOLATOR_DEACCEL )
			file.burnCardPackImages[ index ].ScaleOverTime( 2.0, 2.0, time, INTERPOLATOR_DEACCEL )
		}
		else
		{
			file.burnCardPackImages[ index ].FadeOverTime( 0, time, INTERPOLATOR_DEACCEL )
			file.burnCardPackImages[ index ].ScaleOverTime( 0.0, 0.0, time, INTERPOLATOR_DEACCEL )
		}
	}

}

function DelayedOpenNewCards()
{
	wait 0.5
	if ( IsConnected() )
		AdvanceMenu( GetMenu( "BurnCards_newcards" ) )
}

function NewBurnCardPack_Focus( button )
{
	if ( file.transitioning )	
		return

	thread DelayedRefreshPacks()
}

function OnOpenBurnCards_NewPacks()
{
	file.transitioning = false
	//if ( GetUnopenedCards().len() )
	//{
	//	AdvanceMenu( GetMenu( "BurnCards_newcards" ) )	
	//	return
	//}

	//if ( !GetUnopenedPacks() )
	//{
	//	CloseTopMenu()
	//	return
	//}

	//if ( GetUnopenedPacks() > 1 )
	//	file.NewBurnCardSubTitle.SetText( "Open one pack (" + GetUnopenedPacks() + " remaining)" )
	//else
		file.NewBurnCardSubTitle.SetText( "Open one pack" )
		
	thread DelayedRefreshPacks()	
}