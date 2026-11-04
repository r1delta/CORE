delta_hud.res
{
	// Burn Card Escalation: the cards the pilot holds, one label per line, in the orange and font of inGameBurnCard_label (see
	// cl_gamemode_burn_card_escalation.nut). The pilot cards are on the left, left aligned; the Titan cards, with a header line on top,
	// are on the right, right aligned. Line 0 is the bottom one and each line is pinned on top of the one before, so a list grows
	// upward. A label per line keeps every line aligned (a multi-line label only aligns the text block as a whole) and leaves each
	// box far wider than any card title. In this panel a positive xpos pushes an element outward past the corner it is pinned
	// to, so the margin from the left or right edge is a negative xpos.

	bcePilotCardLine0
	{
		ControlName			Label
		xpos				-14
		ypos				-110
		zpos				1000
		wide				400
		tall				14
		labelText			""
		textAlignment		west
		textinsetx			0
		font				HudFontSmall
		visible				0
		fgcolor_override	"246 134 40 255"

		pin_to_sibling				SafeArea
		pin_corner_to_sibling		2
		pin_to_sibling_corner		2
	}

	bcePilotCardLine1
	{
		ControlName			Label
		xpos				0
		ypos				0
		zpos				1000
		wide				400
		tall				14
		labelText			""
		textAlignment		west
		textinsetx			0
		font				HudFontSmall
		visible				0
		fgcolor_override	"246 134 40 255"

		pin_to_sibling				bcePilotCardLine0
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}

	bcePilotCardLine2
	{
		ControlName			Label
		xpos				0
		ypos				0
		zpos				1000
		wide				400
		tall				14
		labelText			""
		textAlignment		west
		textinsetx			0
		font				HudFontSmall
		visible				0
		fgcolor_override	"246 134 40 255"

		pin_to_sibling				bcePilotCardLine1
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}

	bcePilotCardLine3
	{
		ControlName			Label
		xpos				0
		ypos				0
		zpos				1000
		wide				400
		tall				14
		labelText			""
		textAlignment		west
		textinsetx			0
		font				HudFontSmall
		visible				0
		fgcolor_override	"246 134 40 255"

		pin_to_sibling				bcePilotCardLine2
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}

	bcePilotCardLine4
	{
		ControlName			Label
		xpos				0
		ypos				0
		zpos				1000
		wide				400
		tall				14
		labelText			""
		textAlignment		west
		textinsetx			0
		font				HudFontSmall
		visible				0
		fgcolor_override	"246 134 40 255"

		pin_to_sibling				bcePilotCardLine3
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}

	bcePilotCardLine5
	{
		ControlName			Label
		xpos				0
		ypos				0
		zpos				1000
		wide				400
		tall				14
		labelText			""
		textAlignment		west
		textinsetx			0
		font				HudFontSmall
		visible				0
		fgcolor_override	"246 134 40 255"

		pin_to_sibling				bcePilotCardLine4
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}

	bcePilotCardLine6
	{
		ControlName			Label
		xpos				0
		ypos				0
		zpos				1000
		wide				400
		tall				14
		labelText			""
		textAlignment		west
		textinsetx			0
		font				HudFontSmall
		visible				0
		fgcolor_override	"246 134 40 255"

		pin_to_sibling				bcePilotCardLine5
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}

	bcePilotCardLine7
	{
		ControlName			Label
		xpos				0
		ypos				0
		zpos				1000
		wide				400
		tall				14
		labelText			""
		textAlignment		west
		textinsetx			0
		font				HudFontSmall
		visible				0
		fgcolor_override	"246 134 40 255"

		pin_to_sibling				bcePilotCardLine6
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}

	bcePilotCardLine8
	{
		ControlName			Label
		xpos				0
		ypos				0
		zpos				1000
		wide				400
		tall				14
		labelText			""
		textAlignment		west
		textinsetx			0
		font				HudFontSmall
		visible				0
		fgcolor_override	"246 134 40 255"

		pin_to_sibling				bcePilotCardLine7
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}

	bcePilotCardLine9
	{
		ControlName			Label
		xpos				0
		ypos				0
		zpos				1000
		wide				400
		tall				14
		labelText			""
		textAlignment		west
		textinsetx			0
		font				HudFontSmall
		visible				0
		fgcolor_override	"246 134 40 255"

		pin_to_sibling				bcePilotCardLine8
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}

	bcePilotCardLine10
	{
		ControlName			Label
		xpos				0
		ypos				0
		zpos				1000
		wide				400
		tall				14
		labelText			""
		textAlignment		west
		textinsetx			0
		font				HudFontSmall
		visible				0
		fgcolor_override	"246 134 40 255"

		pin_to_sibling				bcePilotCardLine9
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}

	bceTitanCardLine0
	{
		ControlName			Label
		xpos				-12
		ypos				-99
		zpos				1000
		wide				400
		tall				14
		labelText			""
		textAlignment		east
		textinsetx			0
		font				HudFontSmall
		visible				0
		fgcolor_override	"246 134 40 255"

		pin_to_sibling				SafeArea
		pin_corner_to_sibling		3
		pin_to_sibling_corner		3
	}

	bceTitanCardLine1
	{
		ControlName			Label
		xpos				0
		ypos				0
		zpos				1000
		wide				400
		tall				14
		labelText			""
		textAlignment		east
		textinsetx			0
		font				HudFontSmall
		visible				0
		fgcolor_override	"246 134 40 255"

		pin_to_sibling				bceTitanCardLine0
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}

	bceTitanCardLine2
	{
		ControlName			Label
		xpos				0
		ypos				0
		zpos				1000
		wide				400
		tall				14
		labelText			""
		textAlignment		east
		textinsetx			0
		font				HudFontSmall
		visible				0
		fgcolor_override	"246 134 40 255"

		pin_to_sibling				bceTitanCardLine1
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}

	bceTitanCardLine3
	{
		ControlName			Label
		xpos				0
		ypos				0
		zpos				1000
		wide				400
		tall				14
		labelText			""
		textAlignment		east
		textinsetx			0
		font				HudFontSmall
		visible				0
		fgcolor_override	"246 134 40 255"

		pin_to_sibling				bceTitanCardLine2
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}

	bceTitanCardLine4
	{
		ControlName			Label
		xpos				0
		ypos				0
		zpos				1000
		wide				400
		tall				14
		labelText			""
		textAlignment		east
		textinsetx			0
		font				HudFontSmall
		visible				0
		fgcolor_override	"246 134 40 255"

		pin_to_sibling				bceTitanCardLine3
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}

	bceTitanCardLine5
	{
		ControlName			Label
		xpos				0
		ypos				0
		zpos				1000
		wide				400
		tall				14
		labelText			""
		textAlignment		east
		textinsetx			0
		font				HudFontSmall
		visible				0
		fgcolor_override	"246 134 40 255"

		pin_to_sibling				bceTitanCardLine4
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}

	bceTitanCardLine6
	{
		ControlName			Label
		xpos				0
		ypos				0
		zpos				1000
		wide				400
		tall				14
		labelText			""
		textAlignment		east
		textinsetx			0
		font				HudFontSmall
		visible				0
		fgcolor_override	"246 134 40 255"

		pin_to_sibling				bceTitanCardLine5
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}

	bceTitanCardLine7
	{
		ControlName			Label
		xpos				0
		ypos				0
		zpos				1000
		wide				400
		tall				14
		labelText			""
		textAlignment		east
		textinsetx			0
		font				HudFontSmall
		visible				0
		fgcolor_override	"246 134 40 255"

		pin_to_sibling				bceTitanCardLine6
		pin_corner_to_sibling		2
		pin_to_sibling_corner		0
	}
}