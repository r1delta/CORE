C_BasePlayer.classChanged <- true
C_BasePlayer.escalation <- null // mirrored on server, filled when player spawns and sends an RCP call. Should move to just local on spawn.
C_BasePlayer.pilotAbility <- null // mirrored on server, filled when player spawns and sends an RCP call. Should move to just local on spawn.
C_BasePlayer.cv <- null

function C_BasePlayer::GetBodyType()
{
	return this.GetPlayerSettingsField( "weaponClass" )
}
RegisterClassFunctionDesc( C_BasePlayer, "GetBodyType", "Get player body type" )

function C_BasePlayer::GetDoomedState()
{
	local soul = this.GetTitanSoul()
	if ( !IsValid( soul ) )
		return 0.0

	return soul.IsDoomed()
}

function C_BasePlayer::GetKillCount()
{
	return this.GetKills()
}

function C_BasePlayer::GetDeathCount()
{
	return this.GetDeaths()
}

function C_BasePlayer::GetTitanKillCount()
{
	return this.GetTitanKills()
}

function C_BasePlayer::GetAssistCount()
{
	return this.GetAssists()
}

function C_BasePlayer::GetAssistCount()
{
	return this.GetAssists()
}

function C_BasePlayer::GetPlayerPilotSettings()
{
	return this.GetPlayerRequestedSettings()
}

function C_BasePlayer::GetPersistentVar(key)
{
	return getroottable().GetPersistentVar(key)
}


C_BasePlayer.__GetActiveBurnCardIndex <- C_BasePlayer.GetActiveBurnCardIndex
function C_BasePlayer::GetActiveBurnCardIndex()
{
	return this.__GetActiveBurnCardIndex() - 1
}

function C_BasePlayer::SetIsPlayingRanked( isPlayingRanked )
{
	return getroottable().SetIsPlayingRanked(isPlayingRanked)
}

