"Resource/UI/menus/challenge_reward.res"
{
	Background
	{
		ControlName				ImagePanel
		xpos					-400
		ypos					-194
		zpos					3
		wide					760
		tall					340
		visible					1
		scaleImage				1
		image 					"../ui/menu/challenges/challenge_menu_back"
	}

	ChallengeRewardHeader
	{
		ControlName				Label
		xpos					5
		ypos					1
		zpos					100
		wide					322
		tall					24
		visible					1
		font					ChallengeNameFont
		labelText				"#CHALLENGE_REWARD_HEADER"
		textAlignment			center
		allcaps					1
		fgcolor_override		"255 255 255 255"
	}

	ChallengeXPRewardLabel
	{
		ControlName				Label
		classname				"ChallengeXPRewardLabel"
		xpos					0
		ypos					16
		zpos					100
		wide					318
		tall					24
		visible					1
		font					ChallengeRewardFont
		labelText				"[CHALLENGE XP REWARD]"
		textAlignment			center
		allcaps					1
		fgcolor_override		"230 161 23 255"

		pin_to_sibling			ChallengeRewardHeader
		pin_corner_to_sibling	4
		pin_to_sibling_corner	6
	}

	CoinCountIcon
	{
		ControlName				ImagePanel
		classname				"CoinCountIcon"
		xpos					-8
		ypos					0
		zpos					100
		wide					24
		tall					24
		visible					1
		image					"../vgui/black_market/coin"
		scaleImage				1
		drawColor				"255 133 133 255"

		pin_to_sibling			ChallengeXPRewardLabel
		pin_corner_to_sibling	1
		pin_to_sibling_corner	6
	}

	CoinAmountLabel
	{
		ControlName				Label
		classname				"CoinAmountLabel"
		xpos					0
		ypos 					0
		zpos					100
		wide					75
		tall 					22
		font					ChallengeCoinRewardFont
		textAlignment			west
		visible					1
		labelText				"XXXXX"
		fgcolor_override		"50 50 50 255"
		pin_to_sibling			CoinCountIcon
		pin_corner_to_sibling	7
		pin_to_sibling_corner	5
	}

	ChallengeXPRewardSmallLabel
	{
		ControlName				Label
		classname				"ChallengeXPRewardLabel"
		xpos					0
		ypos					0
		zpos					100
		wide					318
		tall					16
		visible					1
		font					ChallengeRewardFontSmall
		labelText				"[CHALLENGE XP REWARD]"
		textAlignment			center
		allcaps					1
		fgcolor_override		"230 161 23 255"

		pin_to_sibling			ChallengeRewardHeader
		pin_corner_to_sibling	4
		pin_to_sibling_corner	6
	}

	ChallengeDailyXPRewardSmallLabel
	{
		ControlName				Label
		classname				"ChallengeDailyXPRewardSmallLabel"
		xpos					0
		ypos					0
		zpos					100
		textinsetx				6
		wide					159
		tall					16
		visible					1
		font					ChallengeRewardFontSmall
		labelText				"[CHALLENGE XP REWARD]"
		textAlignment			east
		allcaps					1
		fgcolor_override		"230 161 23 255"

		pin_to_sibling			ChallengeRewardHeader
		pin_corner_to_sibling	1
		pin_to_sibling_corner	6
	}

	CoinCountIconSmall
	{
		ControlName				ImagePanel
		classname				"CoinCountIconSmall"
		xpos					10
		ypos					0
		zpos					100
		wide					20
		tall					20
		visible					1
		image					"../vgui/black_market/coin"
		scaleImage				1
		drawColor				"255 133 133 255"

		pin_to_sibling			ChallengeDailyXPRewardSmallLabel
		pin_corner_to_sibling	7
		pin_to_sibling_corner	5
	}

	CoinAmountLabelSmall
	{
		ControlName				Label
		classname				"CoinAmountLabelSmall"
		xpos					0
		ypos 					0
		zpos					100
		wide					75
		tall 					22
		font					ChallengeCoinRewardFontSmall
		textAlignment			west
		visible					1
		labelText				"XXXXX"
		fgcolor_override		"50 50 50 255"
		pin_to_sibling			CoinCountIconSmall
		pin_corner_to_sibling	7
		pin_to_sibling_corner	5
	}

	ChallengeBurnCardReward1
	{
		ControlName			CNestedPanel
		xpos				0//-110
		ypos				10
		zpos				150

		wide				110
		tall				110
		controlSettingsFile	"scripts/screens/vgui_burn_card_mid.res"

		scriptID				0

		pin_to_sibling				ChallengeRewardHeader
		pin_corner_to_sibling		4
		pin_to_sibling_corner		6
	}

	ChallengeBurnCardReward2
	{
		ControlName			CNestedPanel
		xpos				-36
		ypos				0
		zpos				150

		wide				110
		tall				110
		controlSettingsFile	"scripts/screens/vgui_burn_card_mid.res"

		scriptID				1

		pin_to_sibling				ChallengeBurnCardReward1
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	ChallengeBurnCardReward3
	{
		ControlName			CNestedPanel
		xpos				-36
		ypos				0
		zpos				150

		wide				110
		tall				110
		controlSettingsFile	"scripts/screens/vgui_burn_card_mid.res"

		scriptID				2

		pin_to_sibling				ChallengeBurnCardReward2
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	ChallengeBurnCardReward4
	{
		ControlName			CNestedPanel
		xpos				-36
		ypos				0
		zpos				150

		wide				110
		tall				110
		controlSettingsFile	"scripts/screens/vgui_burn_card_mid.res"

		scriptID				3

		pin_to_sibling				ChallengeBurnCardReward3
		pin_corner_to_sibling		0
		pin_to_sibling_corner		1
	}

	ChallengeRewardIcon
	{
		ControlName				ImagePanel
		classname				"ChallengeRewardIcon"
		xpos					0
		ypos					0
		zpos					100
		wide					62
		tall					62
		visible					1
		scaleImage				1
		image 					"../ui/menu/items/weapon_smartpistol"

		pin_to_sibling			ChallengeRewardHeader
		pin_corner_to_sibling	4
		pin_to_sibling_corner	6
	}

	ChallengeRewardNameLabel
	{
		ControlName				Label
		classname				"ChallengeRewardNameLabel"
		xpos					0
		ypos					62
		zpos					100
		wide					318
		tall					24
		visible					1
		font					ChallengeNameFont
		labelText				"[CHALLENGE REWARD ITEM NAME]"
		textAlignment			center
		allcaps					1
		fgcolor_override		"50 50 50 255"

		pin_to_sibling			ChallengeRewardHeader
		pin_corner_to_sibling	4
		pin_to_sibling_corner	6
	}

	ChallengeRewardDescLabel
	{
		ControlName				Label
		classname				"ChallengeRewardDescLabel"
		xpos					0
		ypos					0
		zpos					100
		wide					318
		visible					1
		font					ChallengeRewardDescFont
		labelText				"[CHALLENGE REWARD ITEM DESCRIPTION]"
		textAlignment			north-center
		centerwrap				1
		allcaps					1
		fgcolor_override		"50 50 50 255"
		auto_tall_tocontents	1

		pin_to_sibling			ChallengeRewardNameLabel
		pin_corner_to_sibling	4
		pin_to_sibling_corner	6
	}
}