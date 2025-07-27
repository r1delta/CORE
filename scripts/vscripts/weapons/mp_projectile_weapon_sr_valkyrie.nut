
function OnProjectileCollision( collisionParams )
{
	if ( IsClient() )
		return

	EmitAISound( SOUND_DANGER, SOUND_CONTEXT_FROM_SNIPER, collisionParams.pos, 256, 0.5 )
}
