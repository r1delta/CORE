function main()
{
	Globalize( OnOpenCampaignRewardMenu )
	Globalize( OnCloseCampaignRewardMenu )
}

function OnOpenCampaignRewardMenu( reward = 0 )
{
	HideAllRewards()

	local name, xoffset
	switch( reward )
	{
		case eCampaignReward.REWARD_STRYDER:
			name = "Stryder"
			xoffset = -300
			break

		case eCampaignReward.REWARD_OGRE:
			name = "Ogre"
			xoffset = 300
			break

		default:
			Assert( 0 )
			break
	}

	local menu = GetMenu( "CampaignRewardMenu" )
	AdvanceMenu( menu )

	delaythread ( 0.1 ) PlayTitanUnlockSound()

	local backgroundElements = GetElementsByClassname( menu, "BackgroundImageClass" )
	local background = GetLobbyBackgroundImage()

	foreach ( element in backgroundElements )
	{
		element.SetImage( background )
		element.Show()
	}

	local fill 	= GetElem( menu, "UnlockButtonFill" )
	local image = GetElem( menu, "TitanImage" + name )
	local text 	= GetElem( menu, "DetailText" + name )

	image.Show()
	text.Show()
	thread FlashElement( menu, fill, 4, 3.0, 120 )
	thread FancyLabelFadeIn( menu, text, xoffset, 0, false )
}

function PlayTitanUnlockSound()
{
	EmitUISound( "Menu_CampaignSummary_TitanUnlocked" )
}

function HideAllRewards()
{
	local menu = GetMenu( "CampaignRewardMenu" )
	GetElem( menu, "TitanImageStryder" ).Hide()
	GetElem( menu, "DetailTextStryder" ).Hide()
	GetElem( menu, "TitanImageOgre" ).Hide()
	GetElem( menu, "DetailTextOgre" ).Hide()
}

function OnCloseCampaignRewardMenu()
{
	if( uiGlobal.activeMenu != GetMenu( "CampaignRewardMenu" ) )
		return

	ClientCommand( "RewardMenuClosed" )//resets persistent data about titan rewards
	CloseTopMenu()
	ShowEOGSummary()
}
