
function OnWeaponDeactivate( deactivateParams )
{
	TakeClacker()
}

function OnWeaponPrimaryAttack( attackParams )
{
	thread WaitBeforeDetonating()
}

function WaitBeforeDetonating()
{
	wait 0.35
	self.EmitWeaponSound( SATCHEL_CLACKER_SOUND )
	local player = self.GetWeaponOwner()
	Signal( player, "DetonateCabers" )
	TakeClacker()
}

function TakeClacker()
{
	if ( IsServer() )
	{
		local player = self.GetWeaponOwner()
		if ( IsAlive( player ) )
		{
			player.TakeWeapon( self.GetClassname() )
		}
	}
}

function OnClientAnimEvent( name )
{
}