// Turbo Titan Brawl and Turbo Titan Free For All: the base mode's rules (Titan Brawl or Titan Free For All, loaded just
// before this script) with every Titan running Turbo. On top of them:
//   - everyone has the Turbo Engine burn card effect (the extra dash charge) for the whole match
//   - dashes recharge 50% faster (TURBO_DASH_REGEN_RATE_SCALE)
//   - the Core builds in half the time (GetTitanCoreBuildTime in _utility_shared_all.nut)
//   - shields regenerate twice as fast (GetShieldRegenTime in _titan_health.nut)

function main()
{
	AddCallback_OnPlayerRespawned( TurboTitan_PlayerRespawned )
}

function TurboTitan_PlayerRespawned( player )
{
	GiveServerFlag( player, SFLAG_BC_DASH_CAPACITY )
	player.SetPowerRegenRateScale( TURBO_DASH_REGEN_RATE_SCALE )
}
