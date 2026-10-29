"resource/ui/menus/panels/player_coins.res"
{
	CoinCountIcon
	{
		ControlName				ImagePanel
		classname				"CoinCountIconClass"
		xpos 					0
		ypos 					0
		zpos					5
		wide					22
		tall					22
		visible					1
		image					"../vgui/black_market/coin"
		scaleImage				1
		drawColor				"255 133 133 255"
	}

	PlayerCoinAmountLabel
	{
		ControlName				Label
		classname				"PlayerCoinAmountLabelClass"
		xpos					0
		ypos 					3
		zpos					5 // Needed or clicking on the background can hide this
		wide					75
		auto_tall_tocontents 	1
		font					HudFontMed
		textinsetx				6
		allcaps					0
		textAlignment			west
		visible					1
		wrap					0
		labelText				"#CASH_AMOUNT_LABEL"
		fgcolor_override		"255 133 133 255"

		pin_to_sibling			CoinCountIcon
		pin_corner_to_sibling	7
		pin_to_sibling_corner	5
	}

	CoinsAddedPopupText
	{
		ControlName				Label
		classname				"CoinsAddedPopupTextClass"
		xpos					-30
		ypos					0
		zpos					5 // Needed or clicking on the background can hide this
		wide					75
		auto_tall_tocontents 	1
		font					HudFontMed
		textinsetx				6
		allcaps					0
		textAlignment			west
		visible					0
		wrap					0
		labelText				""
		fgcolor_override		"210 170 0 255"

		pin_to_sibling			PlayerCoinAmountLabel
		pin_corner_to_sibling	0
		pin_to_sibling_corner	1
	}
}
