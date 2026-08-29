
// Example file that shows you how to override hud elements from other files
// This will move the attrition score popup so its next to the crosshair

// Do note that override priority goes from top to bottom
// So, for example, if custom_hud_13 changes the x position of the rodeo alert, then custom_hud_14 and the next files cant change the x position of it
// Because custom_hud_13 has priority

// If you only want to add new stuff and arent planning on overriding anything, choose a lower priority custom_hud file

custom_hud_00.res
{
	// You can include only the things you wanna change, and let the original definition handle the rest
	ScorePopupLabel
	{
		xpos				80
		ypos				-200
		tall				24
		textAlignment		center
	
		pin_to_sibling				SafeAreaCenter
		pin_corner_to_sibling		6
		pin_to_sibling_corner		6
	}

	// ..or you can include everything. Both of these will work
	// (You should probably go with the other one though)
	//ScorePopupLabel
	//{
	//	ControlName			Label
	//	xpos				80
	//	ypos				-200
	//	wide				64
	//	tall				24
	//	visible				0
	//	font				HudFontMed
	//	labelText			"#ATTRITION_POINT_POPUP"
	//	textAlignment		center
	//	fgcolor_override 	"255 255 255 180"
	//
	//	zpos				151
	//	pin_to_sibling				SafeAreaCenter
	//	pin_corner_to_sibling		6
	//	pin_to_sibling_corner		6
	//}
}