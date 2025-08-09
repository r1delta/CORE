function main()
{
	AddCreateCallback( "item_healthcore", CreateScavengerOre )
	AddCreateCallback( "player", InitPreviousDefenseScore ) //Using DefenseScore as a work around for an oreCollected variable
	RegisterServerVarChangeCallback( "gameState", SCV_GameStateChanged )

	RegisterSignal( "TouchedMegaOre" )

	AddCallback_OnInitPlayerScripts( Scavenger_InitPlayerScripts )
	level.teamOreDumpSpot <- {}
	level.teamOreDumpSpot[TEAM_IMC] <- null
	level.teamOreDumpSpot[TEAM_MILITIA] <- null

}

function CreateScavengerOre( ore, isRecreate )
{
	ore.SetFadeDistance( 10000 )
	if ( ore.GetModelName() != CTF_FLAG_BASE_MODEL ) //TODO: Hacky! Making ore dump spot a healthpack too instead of a separate thing
		return

	OnOreDumpSpotCreatedCreated( ore, isRecreate )

}

function InitPreviousDefenseScore( player, isRecreate )
{
	player.s.previousDefenseScore <- 0
}

function ClearCarryingLabel( player )
{
	return

	local localClientPlayer = GetLocalClientPlayer()
	if ( player == GetLocalClientPlayer() )
		return

	/*if ( player.GetTeam() == localClientPlayer.GetTeam() )
		return*/

	local oreCarryingLabel = GetPlayerOreCarryingLabel( player )

	oreCarryingLabel.Hide()
}

function ScavengerOreSparks( ore )
{
	ore.EndSignal( "OnDestroy" )
	local fxID = GetParticleSystemIndex( "xo_spark_med" )
	local origin = ore.GetOrigin() + Vector(0,0,16)
	local angles = ore.GetAngles()

	for ( ;; )
	{
		OreSparkFunc( ore, fxID, origin, angles )
	}
}

function OreSparkFunc( ore, fxID, origin, angles )
{
	local newAngles = angles.AnglesCompose( Vector(90,0,0) )
	if ( RandomInt( 100 ) > 85 )
	{
		StartParticleEffectInWorld( fxID, origin, newAngles )
	}
	EmitSoundOnEntity( ore, "titan_damage_spark" )
	wait 0.2
}

function Scavenger_InitPlayerScripts( player )
{
	player.InitHudElem( "FriendlyFlagArrow" ) //TODO: Hacky! Create new icons. Using Flag Icons because the base icons aren't quite right for what I"m trying to do.
	player.InitHudElem( "EnemyFlagArrow" )

	player.InitHudElem( "FriendlyFlagIcon" )
	player.InitHudElem( "EnemyFlagIcon" )

	player.InitHudElem( "FriendlyFlagLabel" )
	player.InitHudElem( "EnemyFlagLabel" )

	player.InitHudElem( "FlagAnchor" )

	player.hudElems.FriendlyFlagArrow.SetOffscreenArrow( true )
	player.hudElems.FriendlyFlagArrow.SetClampToScreen( CLAMP_RECT )
	player.hudElems.FriendlyFlagArrow.SetClampBounds( CL_HIGHLIGHT_ARROW_X, CL_HIGHLIGHT_ARROW_Y )

	player.hudElems.EnemyFlagArrow.SetOffscreenArrow( true )
	player.hudElems.EnemyFlagArrow.SetClampToScreen( CLAMP_RECT )
	player.hudElems.EnemyFlagArrow.SetClampBounds( CL_HIGHLIGHT_ARROW_X, CL_HIGHLIGHT_ARROW_Y )

	player.hudElems.FriendlyFlagIcon.SetClampToScreen( CLAMP_RECT )
	player.hudElems.FriendlyFlagIcon.SetClampBounds( CL_HIGHLIGHT_ICON_X, CL_HIGHLIGHT_ICON_Y )
	//player.hudElems.FriendlyFlagIcon.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )

	player.hudElems.EnemyFlagIcon.SetClampToScreen( CLAMP_RECT )
	player.hudElems.EnemyFlagIcon.SetClampBounds( CL_HIGHLIGHT_ICON_X, CL_HIGHLIGHT_ICON_Y )
	//player.hudElems.EnemyFlagIcon.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )

	player.hudElems.FriendlyFlagLabel.SetClampToScreen( CLAMP_RECT )
	player.hudElems.FriendlyFlagLabel.SetClampBounds( CL_HIGHLIGHT_LABEL_X, CL_HIGHLIGHT_LABEL_Y )
	//player.hudElems.FriendlyFlagLabel.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )

	player.hudElems.EnemyFlagLabel.SetClampToScreen( CLAMP_RECT )
	player.hudElems.EnemyFlagLabel.SetClampBounds( CL_HIGHLIGHT_LABEL_X, CL_HIGHLIGHT_LABEL_Y )
	//player.hudElems.EnemyFlagLabel.SetADSFade( deg_cos( 5 ), deg_cos( 2 ), 0, 1 )


	/*if ( GetGameState() != eGameState.Playing )
		player.hudElems.HomeBaseIcon.Hide()*/

	//TODO: Terribly hacky, rethink this if we want to make this gamemode real!
	for ( local i = 0; i < 16; ++i  )
	{
		player.InitHudElem( "PlayerOreCarryingLabel" + i )
	}

	player.hudElems.FriendlyFlagArrow.Show()
	player.hudElems.FriendlyFlagIcon.Show()
	player.hudElems.FriendlyFlagLabel.Show()
	player.hudElems.EnemyFlagArrow.Show()
	player.hudElems.EnemyFlagIcon.Show()
	player.hudElems.EnemyFlagLabel.Show()

	thread ScavengerHudThink( player )
}


function PrintPlayerOreCounts()
{
	foreach( player in GetPlayerArray() )
	{
		printt( "Player : " + player.GetEntIndex() + " has collectedOreCount: " + player.GetDefenseScore() ) //check to see clients know other player's ore count
	}

}

Globalize( PrintPlayerOreCounts )

function OnOreDumpSpotCreatedCreated( oreDumpEnt, isRecreate )
{
	level.teamOreDumpSpot[ oreDumpEnt.GetTeam() ] = oreDumpEnt

	local player = GetLocalViewPlayer()

	if ( oreDumpEnt.GetTeam() == player.GetTeam() )
	{
		player.hudElems.FriendlyFlagIcon.SetEntityOverhead( oreDumpEnt, Vector( 0, 0, 64 ), 0.5, 1.0 )
		player.hudElems.FriendlyFlagArrow.SetEntity( oreDumpEnt, Vector( 0, 0, 64 ), 0.5, 1.0 )
		player.hudElems.FriendlyFlagLabel.SetEntityOverhead( oreDumpEnt, Vector( 0, 0, 64 ), 0.5, 0.25 )
		player.hudElems.FriendlyFlagLabel.Show()
		player.hudElems.FriendlyFlagLabel.SetAutoTextVector( "#GAMEMODE_SCAVENGER_FRIENDLY_BASE_DISTANCE", HATT_DISTANCE_METERS, oreDumpEnt.GetOrigin() )
	}
	else
	{
		player.hudElems.EnemyFlagIcon.SetEntityOverhead( oreDumpEnt, Vector( 0, 0, 64 ), 0.5, 1.0 )
		player.hudElems.EnemyFlagArrow.SetEntity( oreDumpEnt, Vector( 0, 0, 64 ), 0.5, 1.0 )
		player.hudElems.EnemyFlagLabel.SetEntityOverhead( oreDumpEnt, Vector( 0, 0, 64 ), 0.5, 0.25 )
		player.hudElems.EnemyFlagLabel.Show()
		player.hudElems.EnemyFlagLabel.SetAutoTextVector( "#GAMEMODE_SCAVENGER_ENEMY_BASE_DISTANCE", HATT_DISTANCE_METERS, oreDumpEnt.GetOrigin() )
	}
}

function ScavengerHudThink( player )
{
	// HACK: Need codecallback for defensescore changed.
	player.EndSignal( "OnDestroy" )

	while ( GetGameState() < eGameState.Playing )
		wait 0

	while( true )
	{
		if ( GetGameState() > eGameState.Playing )
			return

		if ( IsWatchingKillReplay() ) //TODO: Hacking around kill replay related error. Need to make this real if we're shipping it!
		{
			printt( "Returning because watching kill replay!" )
			return
		}

		foreach( playerCharacter in GetPlayerArray() )
		{
			local defenseScore = playerCharacter.GetDefenseScore()

			if ( !( "previousDefenseScore" in playerCharacter.s  ) ) //TODO: Really fragile, would prefer it if we used a code variable instead of defenseScore!
				continue

			if ( defenseScore == playerCharacter.s.previousDefenseScore )
				continue

			playerCharacter.s.previousDefenseScore = defenseScore

			if ( playerCharacter == GetLocalClientPlayer() )
			{
				if ( defenseScore >= MAX_ORE_PLAYER_CAN_CARRY )
				{
					//printt( "Setting defense score to : " + defenseScore )
					SetEventNotification( "#GAMEMODE_SCAVENGER_CARRYING_MAX_ORE", defenseScore )
				}
				else if ( defenseScore > 0 )
				{
					SetEventNotification( "#GAMEMODE_SCAVENGER_CARRYING_N_ORE", defenseScore )
				}
				else
				{
					if ( !IsAlive( playerCharacter ) )
						ClearEventNotification()
				}
			}

			else
			{
				local oreCarryingLabel = GetPlayerOreCarryingLabel( playerCharacter )

				if ( defenseScore == 0 )
				{
					oreCarryingLabel.Hide()
				}
				else
				{
					oreCarryingLabel.Show()
					oreCarryingLabel.SetText( "#GAMEMODE_SCAVENGER_PLAYER_CARRYING_N_ORE", playerCharacter.GetDefenseScore()  )
					oreCarryingLabel.SetEntityOverhead( playerCharacter, Vector( 0, 0, 10 ), 0.5, 1.0 ) //TODO: If we make this a real thing, make it so that the label isn't shown if player can't be seen!
					oreCarryingLabel.UseFriendlyVisibilityAlpha( 1.0 )
				}
			}
		}

		wait 0
	}
}

function SCV_GameStateChanged()
{
	local player = GetLocalViewPlayer()

	if ( GetGameState() < eGameState.Playing )
		return

	if ( GetGameState() > eGameState.Playing )
		HideHudElements( player )
}

function HideHudElements( player )
{
	PrintFunc()
	for ( local i = 0; i < 16; ++i  )
	{
		player.hudElems[ "PlayerOreCarryingLabel" + i ].Hide()
	}

	player.hudElems.FriendlyFlagArrow.Hide()
	player.hudElems.FriendlyFlagIcon.Hide()
	player.hudElems.FriendlyFlagLabel.Hide()
	player.hudElems.EnemyFlagArrow.Hide()
	player.hudElems.EnemyFlagIcon.Hide()
	player.hudElems.EnemyFlagLabel.Hide()

	ClearEventNotification()

}


function SCB_DeliveredOre( deliveredOre )
{
	ClearEventNotification()
	SetTimedEventNotification( 3, "#GAMEMODE_SCAVENGER_DELIVERED_N_ORE", deliveredOre )
}
Globalize( SCB_DeliveredOre )

function SCB_CantPickupMegaOre()
{
	thread SCB_CantPickupMegaOre_threaded()
}

Globalize( SCB_CantPickupMegaOre )

function SCB_CantPickupMegaOre_threaded()
{
	local player = GetLocalClientPlayer()
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	player.Signal( "TouchedMegaOre" ) //TODO: Hack. Need a better way to do this, not really shippable!
	player.EndSignal( "TouchedMegaOre" )



	ClearEventNotification()
	SetTimedEventNotification( 3, "#GAMEMODE_SCAVENGER_CANT_PICKUP_MEGA_ORE" )

	wait 3.0

	local defenseScore = player.GetDefenseScore()
	if ( defenseScore >= MAX_ORE_PLAYER_CAN_CARRY )
	{
		//printt( "Setting defense score to : " + defenseScore )
		SetEventNotification( "#GAMEMODE_SCAVENGER_CARRYING_MAX_ORE", defenseScore )
	}
	else if ( defenseScore > 0 )
	{
		SetEventNotification( "#GAMEMODE_SCAVENGER_CARRYING_N_ORE", defenseScore )
	}

}

function GetPlayerOreCarryingLabel( player )
{
	local localClientPlayer = GetLocalClientPlayer()
	return localClientPlayer.hudElems[ "PlayerOreCarryingLabel" + player.GetEntIndex() ]
}

