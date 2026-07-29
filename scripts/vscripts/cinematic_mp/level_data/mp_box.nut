function main()
{
	CreateCinematicMPNode( "cinematic_mp_node_us0", Vector( -1532.6, -1147.35, 350.895 ), Vector( 0, 90.6667, 0 ), CINEMATIC_TYPES.SEARCHSHIP_DRONE_SPAWN )
	CreateCinematicMPNode( "cinematic_mp_node_us6", Vector( 0, 0, 500 ), Vector( 0, 90, 0 ), CINEMATIC_TYPES.SEARCHSHIP_DRONE_SPAWN )
	CreateCinematicMPNode( "cinematic_mp_node_us7", Vector( 0, 0, 250.696 ), Vector( 0, 90.6667, 0 ), CINEMATIC_TYPES.SEARCHSHIP_DRONE_SPAWN )
	CreateCinematicMPNode( "cinematic_mp_node_us1", Vector( -1387.76, 11.5515, 51.3082 ), Vector( 0, 1.33378, 0 ), CINEMATIC_TYPES.SEARCHSHIP_SEARCH, "cinematic_mp_node_us0" )
	CreateCinematicMPNode( "cinematic_mp_node_us2", Vector( -1355.15, 498.642, 82.138 ), Vector( 0, -178.667, 0 ), CINEMATIC_TYPES.SEARCHSHIP_SEARCH, "cinematic_mp_node_us1" )
	CreateCinematicMPNode( "cinematic_mp_node_us4", Vector( -1763.28, 496.617, 79.4056 ), Vector( 0, 0, 0 ), CINEMATIC_TYPES.SEARCHSHIP_SEARCH_TARGET, "cinematic_mp_node_us2" )
	CreateCinematicMPNode( "cinematic_mp_node_us5", Vector( 1514.16, 201.935, 532.689 ), Vector( 0, -4, 0 ), CINEMATIC_TYPES.SEARCHSHIP_DELETE, "cinematic_mp_node_us2" )
	CreateCinematicMPNode( "cinematic_mp_node_us3", Vector( -953.996, 256.741, 325.289 ), Vector( 0, 0, 0 ), CINEMATIC_TYPES.SEARCHSHIP_SEARCH_TARGET, "cinematic_mp_node_us1" )
	CreateCinematicMPNode( "cinematic_mp_node_us5", Vector( 1514.16, 201.935, 766.023 ), Vector( 0, -4, 0 ), CINEMATIC_TYPES.SEARCHSHIP_DELETE, "cinematic_mp_node_us6" )
	CreateCinematicMPNode( "cinematic_mp_node_us8", Vector( 100, 100, 250 ), Vector( 0, 1.33378, 0 ), CINEMATIC_TYPES.CHILD, "cinematic_mp_node_us7" )
}