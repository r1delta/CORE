"resource/ui/menus/panels/menu_common.res"
{
	BackgroundImage
	{
		ControlName				ImagePanel
		classname 				BackgroundImageClass
		wide					f0
		tall					f0
		visible					1
		scaleImage				1
	}

	BreadCrumbs
	{
		ControlName				Label
		classname 				BreadCrumbsClass
		xpos					63
		ypos					16 [!$FRENCH && !$SPANISH && !$GERMAN && !$POLISH && !$PORTUGUESE && !$RUSSIAN]
		ypos					13 [$FRENCH || $SPANISH || $GERMAN || $POLISH || $PORTUGUESE || $RUSSIAN]
		zpos					3 // Needed or clicking on the background can hide this
		auto_wide_tocontents 	1
		tall					43
		visible					1
		font					MenuTitleSmallFont
		allcaps					1
		fgcolor_override		"255 133 133 255"
		labelText				"OLDER MENU > OLD MENU"
	}

	//MenuTitle
	//{
	//	ControlName				Label
	//	classname 				LobbyTitleClass
	//	xpos					63
	//	ypos					21
	//	zpos					3 // Needed or clicking on the background can hide this
	//	auto_wide_tocontents 	1
	//	tall					43
	//	visible					1
	//	font					MenuTitleFont
	//	allcaps					1
	//	fgcolor_override		"255 133 133 255"
	//	labelText				"MENU TITLE"
	//}

	//ImgTopBar
	//{
	//	ControlName				ImagePanel
	//	xpos					54
	//	ypos					65
	//	wide					745
	//	tall					7
	//	image 					"../ui/menu/common/menu_title_bar"
	//	visible					1
	//	scaleImage				1
	//	drawColor				"255 0 0 255"
	//}
}