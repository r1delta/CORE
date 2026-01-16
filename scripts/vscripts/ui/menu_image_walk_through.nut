function main()
{
	Globalize( OnOpenImageWalkThroughMenu )
	Globalize( OnCloseImageWalkThroughMenu )
	Globalize( AddWalkthroughPage )
	Globalize( StartImageWalkthroughSubMenu )
	Globalize( InitImageWalkThroughMenu )
	Globalize( ImageWalkThroughMenu_FooterUpdate )
	file.pages <- null
	file.currentPage <- null
	file.buttonsRegistered <- false
}

/*
	// KEEP THIS COMMENTED OUT BLOCK FOR REFERENCE

function OnClick_BtnRankedExplanation( button )
{
	local height = file.MenuCommon.GetHeight()

	local WALKTHROUGH_TEMP = "../ui/menu/common/menu_background_neutral"

	local pages = []

	AddWalkthroughPage( pages, "#RANKED_MENU_WALKTHROUGH1", WALKTHROUGH_TEMP )
	AddWalkthroughPage( pages, "#RANKED_MENU_WALKTHROUGH2", WALKTHROUGH_TEMP )
	AddWalkthroughPage( pages, "#RANKED_MENU_WALKTHROUGH3", WALKTHROUGH_TEMP )
	AddWalkthroughPage( pages, "#RANKED_MENU_WALKTHROUGH4", WALKTHROUGH_TEMP )
	AddWalkthroughPage( pages, "#RANKED_MENU_WALKTHROUGH5", WALKTHROUGH_TEMP )
	AddWalkthroughPage( pages, "#RANKED_MENU_WALKTHROUGH6", WALKTHROUGH_TEMP )
	AddWalkthroughPage( pages, "#RANKED_MENU_WALKTHROUGH7", WALKTHROUGH_TEMP )
	AddWalkthroughPage( pages, "#RANKED_MENU_WALKTHROUGH8", WALKTHROUGH_TEMP )
	AddWalkthroughPage( pages, "#RANKED_MENU_WALKTHROUGH9", WALKTHROUGH_TEMP )
	AddWalkthroughPage( pages, "#RANKED_MENU_WALKTHROUGH10", WALKTHROUGH_TEMP )
	AddWalkthroughPage( pages, "#RANKED_MENU_WALKTHROUGH11", WALKTHROUGH_TEMP )
	AddWalkthroughPage( pages, "#RANKED_MENU_WALKTHROUGH12", WALKTHROUGH_TEMP )
	AddWalkthroughPage( pages, "#RANKED_MENU_WALKTHROUGH13", WALKTHROUGH_TEMP )
	AddWalkthroughPage( pages, "#RANKED_MENU_WALKTHROUGH14", WALKTHROUGH_TEMP )

	StartImageWalkthroughSubMenu( "How Leagues Work", pages, 0, height * 0.5 )
}
*/

function InitImageWalkThroughMenu()
{
	local menu = GetMenu( "ImageWalkThroughMenu" )
	file.ImageWalkThrough_Title <- menu.GetChild( "ImageWalkThrough_Title" )
	file.ImageWalkThrough_Page <- menu.GetChild( "ImageWalkThrough_Page" )
	file.ImageWalkThrough_Label <- menu.GetChild( "ImageWalkThrough_Label" )
	file.ImageWalkThrough_Image <- menu.GetChild( "ImageWalkThrough_Image" )

	AddMenuEventHandler(menu, R1DELTA_UIE_OPEN, OnOpenImageWalkThroughMenu)
	AddMenuEventHandler(menu, R1DELTA_UIE_CLOSE, OnCloseImageWalkThroughMenu)
}

function OnCloseImageWalkThroughMenu()
{
	if ( file.buttonsRegistered )
	{
		DeregisterButtonPressedCallback( BUTTON_A, 					ImageWalkthrough_Next )
		DeregisterButtonPressedCallback( BUTTON_DPAD_RIGHT, 		ImageWalkthrough_Next )
		DeregisterButtonPressedCallback( BUTTON_SHOULDER_RIGHT, 	ImageWalkthrough_Next )
		DeregisterButtonPressedCallback( STICK1_RIGHT, 				ImageWalkthrough_Next )
		DeregisterButtonPressedCallback( KEY_RIGHT, 				ImageWalkthrough_Next )
		DeregisterButtonPressedCallback( BUTTON_X, 					ImageWalkthrough_Last )
		DeregisterButtonPressedCallback( BUTTON_DPAD_LEFT,	 		ImageWalkthrough_Last )
		DeregisterButtonPressedCallback( BUTTON_SHOULDER_LEFT,	 	ImageWalkthrough_Last )
		DeregisterButtonPressedCallback( STICK1_LEFT, 				ImageWalkthrough_Last )
		DeregisterButtonPressedCallback( KEY_LEFT, 					ImageWalkthrough_Last )
		file.buttonsRegistered = false
	}
}

function OnOpenImageWalkThroughMenu()
{
	thread RegisterImageWalkthroughButtons()
}

function AddWalkthroughPage( pages, label, image )
{
	pages.append( { label = label, image = image } )
}

function StartImageWalkthroughSubMenu( title, pages, xpos, ypos )
{
	file.pages = pages
	file.currentPage = 0

	file.ImageWalkThrough_Title.SetText( title )

	local menuName = "ImageWalkThroughMenu"
	local imageMenu = GetMenu( menuName )

	OpenSubmenu( imageMenu, false )
	UpdateFooterButtons( menuName )

	uiGlobal.activeMenu.SetPos( xpos, ypos )
	RefreshImageWalkthrough()
}

function RegisterImageWalkthroughButtons()
{
	wait 0 // so it wont click a if its being held
	if ( !file.buttonsRegistered )
	{
		RegisterButtonPressedCallback( BUTTON_A, 					ImageWalkthrough_Next )
		RegisterButtonPressedCallback( BUTTON_DPAD_RIGHT, 			ImageWalkthrough_Next )
		RegisterButtonPressedCallback( BUTTON_SHOULDER_RIGHT, 		ImageWalkthrough_Next )
		RegisterButtonPressedCallback( STICK1_RIGHT, 				ImageWalkthrough_Next )
		RegisterButtonPressedCallback( KEY_RIGHT, 					ImageWalkthrough_Next )
		RegisterButtonPressedCallback( BUTTON_X, 					ImageWalkthrough_Last )
		RegisterButtonPressedCallback( BUTTON_DPAD_LEFT,	 		ImageWalkthrough_Last )
		RegisterButtonPressedCallback( BUTTON_SHOULDER_LEFT,	 	ImageWalkthrough_Last )
		RegisterButtonPressedCallback( STICK1_LEFT, 				ImageWalkthrough_Last )
		RegisterButtonPressedCallback( KEY_LEFT, 					ImageWalkthrough_Last )
		file.buttonsRegistered = true
	}
}

function RefreshImageWalkthrough()
{
	Assert( file.pages != null, "Have not setup image walkthrough" )
	Assert( file.currentPage != null, "Have not setup image walkthrough" )

	file.currentPage = clamp( file.currentPage, 0, file.pages.len() - 1 )
	Assert( file.currentPage < file.pages.len() )
	Assert( file.currentPage >= 0 )

	local page = file.pages[ file.currentPage ]

	file.ImageWalkThrough_Label.SetText( page.label )
	file.ImageWalkThrough_Image.SetImage( page.image )
	file.ImageWalkThrough_Page.SetText( "#EOG_CHALLENGE_PROGRESS", file.currentPage + 1, file.pages.len() )
}

function ImageWalkThroughMenu_FooterUpdate( footerData )
{
	footerData.gamepad.append( { label = "#B_BUTTON_BACK" } )
	footerData.gamepad.append( { label = "#X_BUTTON_LAST_PAGE", func = Bind( ImageWalkthrough_Last ) } )
	footerData.gamepad.append( { label = "#A_BUTTON_NEXT_PAGE", func = Bind( ImageWalkthrough_Next ) } )

	footerData.pc.append( { label = "#BACK", func = PCBackButton_Activate } )
	footerData.pc.append( { label = "#LAST_PAGE", func = Bind( ImageWalkthrough_Last ) } )
	footerData.pc.append( { label = "#NEXT_PAGE", func = Bind( ImageWalkthrough_Next ) } )
}

function ClickImageWalkthrough_Last( button )
{
	ImageWalkthrough_Last()
}

function ClickImageWalkthrough_Next( button )
{
	ImageWalkthrough_Next()
}

function ImageWalkthrough_Last( _ = null, _ = null, _ = null )
{
	file.currentPage--
	RefreshImageWalkthrough()
}

function ImageWalkthrough_Next( _ = null, _ = null, _ = null )
{
	file.currentPage++
	RefreshImageWalkthrough()
}

