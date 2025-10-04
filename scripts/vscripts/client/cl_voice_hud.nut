
const VOICEHUD_MAX = 5


function main()
{
	Globalize( InitVoiceHUD )
	Globalize( UpdateVoiceHUD )
}


function InitVoiceHUD( player )
{
	player.cv.voiceHUDArray <- []
	local elemPrefix
	local elemIndex

	for ( local index = 0; index < VOICEHUD_MAX; index++ )
	{
		elemPrefix = "voice"
		elemIndex = index.tostring()

		local table = {
			mic = HudElement( elemPrefix + "Mic" + elemIndex )
			name = HudElement( elemPrefix + "Name" + elemIndex )
		}

		player.cv.voiceHUDArray.append( table )

		table.name.Hide()
		table.mic.Hide()

		level.menuVisGroup.AddElement( table.mic )
		level.menuVisGroup.AddElement( table.name )
	}
}


function UpdateVoiceHUD()
{
	local localPlayer = GetLocalClientPlayer()

	// Verify init was called first
	if ( !( "voiceHUDArray" in localPlayer.cv ) )
		return

	local teamPlayers = GetPlayerArrayOfTeam( localPlayer.GetTeam() )
	local index = 0

	foreach ( teamPlayer in teamPlayers )
	{
		if ( teamPlayer.IsTalking() && !teamPlayer.IsMuted() )
		{
			localPlayer.cv.voiceHUDArray[index].mic.Show()

			localPlayer.cv.voiceHUDArray[index].name.SetText( teamPlayer.GetPlayerName() )
			localPlayer.cv.voiceHUDArray[index].name.Show()

			index++

			// Already showing max, can't do anything else
			if ( index >= VOICEHUD_MAX )
				return
		}
	}

	for ( index; index < VOICEHUD_MAX; index++ )
	{
		localPlayer.cv.voiceHUDArray[index].name.Hide()
		localPlayer.cv.voiceHUDArray[index].mic.Hide()
	}
}
