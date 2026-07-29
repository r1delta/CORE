function main()
{
	CreateCinematicMPNode( "cinematic_mp_node_us0", Vector( -866.429, -548.336, 0.0 ), Vector( 0, 8, 0 ), CINEMATIC_TYPES.LEVIATHAN_SPAWN )
	CreateCinematicMPNode( "cinematic_mp_node_us1", Vector( -126.362, -399.503, 0.0 ), Vector( 0, 0, 0 ), CINEMATIC_TYPES.CHILD, "cinematic_mp_node_us0" )
	CreateCinematicMPNode( "cinematic_mp_node_us2", Vector( 1044.5, -666.364, 0.0 ), Vector( 0, 0, 0 ), CINEMATIC_TYPES.CHILD, "cinematic_mp_node_us1" )
}
