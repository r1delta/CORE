function main()
{
	IncludeFile( "_melee_shared" )

	Globalize( CodeCallback_NPCMeleedPlayerOrNPC )
}

//File is pretty sparse for now. In all honesty a lot of existing functionality in _melee_shared should
//belong here instead, but we'll wait until we try to do prediction (which requires running the same code
//on client and server) before we try to split up functionality in the different script files any better.


function CodeCallback_NPCMeleedPlayerOrNPC( entity, damageInfo )
{
	if ( damageInfo.GetDamage() > 0 )
	{
		local dmgVelocity = damageInfo.GetDamageForce() * 0.05
		dmgVelocity.z *= 0.1

		entity.SetVelocity( entity.GetVelocity() + dmgVelocity )
	}
}