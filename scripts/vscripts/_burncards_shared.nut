const BURNCARD_ICON_KILLSWITCH 		= "burncards/burncard_icon_kill_switch"
const GROUP_ICONS_ENABLED = 1
const TITAN_BURN_CARD_CONSUMED_ON_ROUND_END = false

::CT_WEAPON 	<- 0x00000001
::CT_COOLDOWN 	<- 0x00000002
::CT_BUILDTIME 	<- 0x00000004
::CT_GRUNT 		<- 0x00000008
::CT_SPECTRE 	<- 0x00000010
::CT_TITAN 		<- 0x00000020
::CT_PILOT 		<- 0x00000040
::CT_SONAR 		<- 0x00000080
::CT_CLOAK 		<- 0x00000100
::CT_STIM 		<- 0x00000200
::CT_HUNT		<- 0x00000400
::CT_XP			<- 0x00000800
::CT_SPECIAL	<- 0x00001000
::CT_NPC		<- 0x00002000
::CT_INTEL		<- 0x00004000
::CT_FRAG		<- 0x00008000
::CT_PISTOL		<- 0x00010000
::CT_SMG		<- 0x00020000
::CT_RIFLE		<- 0x00040000
::CT_SNIPER		<- 0x00080000
::CT_ANTI_TITAN <- 0x00100000
::CT_TITAN_WPN 	<- 0x00200000
::CT_PRIMARY	<- 0x00400000
::CT_ORDNANCE	<- 0x00800000
::CT_TACTICAL	<- 0x01000000
//= 0x02000000
//= 0x04000000
//= 0x08000000
//= 0x10000000
//= 0x20000000
//= 0x40000000



::ALL_BITFIELDS <- [
	0x00000001
	0x00000002
	0x00000004
	0x00000008
	0x00000010
	0x00000020
	0x00000040
	0x00000080
	0x00000100
	0x00000200
	0x00000400
	0x00000800
	0x00001000
	0x00002000
	0x00004000
	0x00008000
	0x00010000
	0x00020000
	0x00040000
	0x00080000
	0x00100000
	0x00200000
	0x00400000
	0x00800000
	0x01000000
	0x02000000
	0x04000000
	0x08000000
	0x10000000
	0x20000000
	0x40000000
]

// cards with cost 1 may appear twice in a pack
::BURNCARD_FLAG_COST_1 <- CT_SPECIAL | CT_WEAPON | CT_BUILDTIME

//const BURNCARD_ART_TEMPLATE 		= "burncards/burncard_large_art_template"
const BURNCARD_MID_ICON_TEMPLATE 	= "burncards/burncard_mid_icon_template"
const BURNCARD_LARGE_ICON_TEMPLATE 	= "burncards/burncard_large_icon_template"

::BC_NEXTDEATH <- 0 // lasts until you die
::BC_NEXTSPAWN <- 1 // only lasts until you spawn (no persistent effect)
::BC_NEXTEJECT <- 2 // lasts until you eject
::BC_NEXTTITAN <- 3 // lasts until you embark
::BC_NEXTBCARD <- 4 // lasts until you use another burn card
::BC_FOREVER   <- 5 // lasts forever
::BC_NEXTTITANDROP	<- 6 // lasts from titan drop until that titan's death.
::BC_NEXTLOAD <- 7 // lasts until you join another server

function main()
{
//	image
//	text
//	usetime
//	prematch time
//

	Globalize( GetBurnCardData )
	Globalize( GetBurnCardRarity )
	Globalize( GetBurnCardLastsUntil )
	Globalize( GetBurnCardCount )
	Globalize( GetBurnCardPassive )
	Globalize( GetBurnCardServerFlags )
	Globalize( GetBurnCardDescription )
	Globalize( GetBurnCardFlavorText )
	Globalize( GetBurnCardIndex )
	Globalize( GetBurnCardImage )
	Globalize( GetBurnCardColor )
	Globalize( GetBurnCardGroup )
	Globalize( GetBurnCardFlags )
	Globalize( GetBurnCardLargeIcon )
	Globalize( GetBurnCardMidIcon )
	Globalize( GetBurnCardFromSlot )
	Globalize( GetBurnCardTitle )
	Globalize( GetBurnCardWeapon )
	Globalize( GetBurnCardRarityColor )
	Globalize( GetRandomBurnCardOfRarity )
	Globalize( GetRandomBurnCardOfGroup )
	Globalize( GetRandomBurnCardGroup )
	Globalize( GetRandomBurnCard )
	Globalize( GetBurnCardIndexByRef )
	Globalize( GetSellCostOfRarity )


	if ( !IsUI() )
	{
		if ( IsServer() )
		{
			Globalize( SetPlayerBurnCardUpgraded )
			Globalize( SetPlayerBlackMarketNextResetTime )
			Globalize( SetPlayerBlackMarketUpgrade )
			Globalize( SetPlayerBurnCardFromDeck )
			Globalize( SetPlayerLastActiveBurnCardFromSlot )
			Globalize( SetPlayerStashedCardTime )
			Globalize( SetPlayerActiveBurnCardSlotContents )
			Globalize( SetPlayerBurnCardCollected )
			Globalize( SetPlayerBurnCardActiveSlotID )
			Globalize( SetPlayerBurnCardOnDeckIndex )
			Globalize( SetPlayerStashedCardRef )
		}

		Globalize( PlayerHasDiceStashed )
		Globalize( FindPlayerBurnCardInActive )
		Globalize( FindPlayerFirstEmptyActiveSlot )
		Globalize( GetPlayerStashedCardRef )
		Globalize( GetPlayerBurnCardDeck )
		Globalize( GetPlayerBurnCardUpgraded )
		Globalize( GetPlayerBlackMarketUpgradeShopItem )
		Globalize( GetPlayerBlackMarketNextResetTime )
		Globalize( GetPlayerBurnCardFromDeck )
		Globalize( GetPlayerActiveBurnCard )
		Globalize( GetPlayerActiveBurnCardSlotContents )
		Globalize( GetPlayerStashedCardTime )
		Globalize( GetPlayerTotalBurnCards )
		Globalize( GetPlayerActiveBurnCardSlotClearOnStart )
		Globalize( GetPlayerUnopenedCards )
		Globalize( GetPlayerNextPack_XPRemaining )
		Globalize( GetPlayerMaxActiveBurnCards )
		Globalize( GetPlayerMaxStoredBurnCards )
		Globalize( GetPlayerBurnCardsSpent )
		Globalize( GetPlayerBurnCardCollected )
		Globalize( GetPlayerBurnCardOnDeckIndex )
		Globalize( GetPlayerBurnCardActiveSlotID )
		Globalize( GetPlayerActiveBurnCards )
	}

	::BC_GROUP_ICONS <- []
	BC_GROUP_ICONS.resize( BC_GROUPINGS	)
	BC_GROUP_ICONS[ BCGROUP_SPEED 	] = "burncards/burncard_group_icon_speed"
	BC_GROUP_ICONS[ BCGROUP_STEALTH	] = "burncards/burncard_group_icon_stealth"
	BC_GROUP_ICONS[ BCGROUP_INTEL	] = "burncards/burncard_group_icon_intel"
	BC_GROUP_ICONS[ BCGROUP_BONUS 	] = "burncards/burncard_group_icon_reward"
	BC_GROUP_ICONS[ BCGROUP_NPC 	] = "burncards/burncard_group_icon_npc"
	BC_GROUP_ICONS[ BCGROUP_WEAPON 	] = "burncards/burncard_group_icon_weapons"
	BC_GROUP_ICONS[ BCGROUP_MISC 	] = "burncards/burncard_group_icon_exotic"
	BC_GROUP_ICONS[ BCGROUP_DICE	] = "burncards/burncard_group_icon_dice"

	// used to hint to pack generation and replacement cards

	RARITY_COLOR <- []
	RARITY_COLOR.resize( BURNCARD_RARE + 1 )
	RARITY_COLOR[ BURNCARD_COMMON ] 	= { r = 205, g = 215, b = 225 }
	RARITY_COLOR[ BURNCARD_RARE ] 		= { r = 205, g = 55, b = 25 }


	level.burnCardCurrentIndex <- 0
	level.indexToBurnCard <- {}

	// these burn cards will be available in game
	level.burnCards <- []

	level.burnCardsByName <- {}
	level.burnCardsOfRarity <- {}
	for ( local i = 0; i < BURNCARD_RARE + 1; i++ )
	{
		// array of rarities
		level.burnCardsOfRarity[ i ] <- []
	}

	level.burnCardGroups <- []
	for ( local i = 0; i < BC_GROUPINGS; i++ )
	{
		level.burnCardGroups.append( i )
	}

	level.burnCardsOfGroup <- {}
	for ( local i = 0; i < level.burnCardGroups.len(); i++ )
	{
		level.burnCardsOfGroup[ level.burnCardGroups[ i ] ] <-[]
	}

	level.burnCardData <- {}

	level.burnCardWeaponModList <- {}

	CreateAllBurnCards()

	if ( IsServer() )
	{
		// CreateAllBurnCards()
		if ( BURN_CARD_MAP_LOOT_DROP && !IsLobby() )
			IncludeFile( "mp/_burncards_maps" )

		IncludeFile( "mp/_burncards_sets" )
		if(IsLobby())
			IncludeFile("menu/_burncards_lobby.nut")
		//InitBurnCardSets()
	}

	if ( !IsUI() )
	{
		PrecacheMaterial( "vgui/burncards/burncard_mid_rare_hover" )
		PrecacheMaterial( "vgui/burncards/burncard_mid_rare" )
		PrecacheMaterial( "vgui/burncards/burncard_mid_common_hover" )
		PrecacheMaterial( "vgui/burncards/burncard_mid_common" )
		PrecacheMaterial( "vgui/burncards/burncard_mid_blank" )
		PrecacheMaterial( "vgui/burncards/burncard_mid_blank_hover" )

		//PrecacheMaterial( "vgui/burncards/burncard_large_header_rare" )
		//PrecacheMaterial( "vgui/burncards/burncard_large_rare" )


		for ( local i = 0; i < BC_GROUPINGS; i++ )
		{
			local index = i + 1
			PrecacheMaterial( "vgui/burncards/burncard_mid_type" + index + "_hover" )
			PrecacheMaterial( "vgui/burncards/burncard_mid_type" + index )
			PrecacheMaterial( "vgui/burncards/burncard_large_type" + index )
		}

		foreach ( icon in BC_GROUP_ICONS )
		{
			PrecacheMaterial( "vgui/" + icon )
			PrecacheMaterial( "vgui/" + icon + "_white" )
		}
	}
}

function AddBurnCardLastsUntil( indexString )
{
}

function GetRandomBurnCard()
{
	if ( RandomFloat( 0, 1.0 ) <= 1.0 / NON_RARES_PER_RARE )
		return GetRandomBurnCardOfRarity( BURNCARD_RARE )

	return GetRandomBurnCardOfRarity( BURNCARD_COMMON )
}

function GetRandomBurnCardOfRarity( rarity )
{
	return Random( level.burnCardsOfRarity[ rarity ] )
}

function GetRandomBurnCardOfGroup( group )
{
	return Random( level.burnCardsOfGroup[ group ] )
}

function GetRandomBurnCardGroup()
{
	return Random( level.burnCardGroups )
}

function CreateAllBurnCards()
{
	CreateBurnCardWeapon( "bc_frag_m2",					BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_WEAPON	| CT_FRAG									, "burncards/burncard_art_08", 	BC_NEXTDEATH, 		"#BC_FRAG_GRENADE_M2"		, "#BC_FRAG_GRENADE_M2_DESC"	, "#BC_FRAG_GRENADE_FLAVOR"				, "#BC_FLAVOR_LABEL",			"mp_weapon_frag_grenade",		"burn_mod_frag_grenade",				"OFFHAND0"		)
	CreateBurnCardWeapon( "bc_arc_m2",					BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_WEAPON	| CT_FRAG									, "burncards/burncard_art_11", 	BC_NEXTDEATH, 		"#BC_EMP_GRENADE_M2"		, "#BC_EMP_GRENADE_M2_DESC"		, "#BC_EMP_GRENADE_M2_FLAVOR"			, "#BC_FLAVOR_BLISK_ANGEL_CITY", "mp_weapon_grenade_emp",		"burn_mod_emp_grenade",					"OFFHAND0"		)
	CreateBurnCardWeapon( "bc_prox_m2",					BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_WEAPON	| CT_FRAG									, "burncards/burncard_art_10", 	BC_NEXTDEATH, 		"#BC_PROXIMITY_MINE_M2"		, "#BC_PROXIMITY_MINE_M2_DESC"	, "#BC_PROXIMITY_MINE_M2_FLAVOR"		, "#BC_FLAVOR_GRAVES",			"mp_weapon_proximity_mine",		"burn_mod_proximity_mine",				"OFFHAND0"		)
	CreateBurnCardWeapon( "bc_satchel_m2",				BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_WEAPON	| CT_FRAG									, "burncards/burncard_art_09", 	BC_NEXTDEATH, 		"#BC_SATCHEL_M2"			, "#BC_SATCHEL_M2_DESC"			, "#BC_SATCHEL_M2_FLAVOR"				, "#BC_FLAVOR_TITAN_FIGHTER",	"mp_weapon_satchel",			"burn_mod_satchel",						"OFFHAND0"		)
	CreateBurnCardWeapon( "bc_autopistol_m2",			BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_WEAPON	| CT_PISTOL									, "burncards/burncard_art_14", 	BC_NEXTDEATH, 		"#BC_AUTOPISTOL_M2"			, "#BC_AUTOPISTOL_M2_DESC"		, "#BC_AUTOPISTOL_M2_FLAVOR"			, "#BC_FLAVOR_BONEYARD",		"mp_weapon_autopistol",			"burn_mod_autopistol",					"SIDEARM"		)
	CreateBurnCardWeapon( "bc_semipistol_m2",			BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_WEAPON	| CT_PISTOL									, "burncards/burncard_art_28", 	BC_NEXTDEATH, 		"#BC_SEMIPISTOL_M2"			, "#BC_SEMIPISTOL_M2_DESC"		, "#BC_SEMIPISTOL_M2_FLAVOR"			, "#BC_FLAVOR_BLISK",			"mp_weapon_semipistol",			"burn_mod_semipistol",					"SIDEARM"		)
	CreateBurnCardWeapon( "bc_wingman_m2", 				BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_WEAPON	| CT_PISTOL									, "burncards/burncard_art_12", 	BC_NEXTDEATH, 		"#BC_WINGMAN_M2" 		    , "#BC_WINGMAN_M2_DESC" 		, "#BC_WINGMAN_M2_FLAVOR" 		   		, "#BC_FLAVOR_SARAH",			"mp_weapon_wingman",			"burn_mod_wingman",	 		"SIDEARM"		)
	CreateBurnCardWeapon( "bc_smart_pistol_m2",			BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_WEAPON	| CT_PISTOL									, "burncards/burncard_art_04", 	BC_NEXTDEATH, 		"#BC_SMART_PISTOL_M2"		, "#BC_SMART_PISTOL_M2_DESC"	, "#BC_SMART_PISTOL_M2_FLAVOR"			, "#BC_FLAVOR_SARAH",			"mp_weapon_smart_pistol",		"burn_mod_smart_pistol",				"PRIMARY"		)
	CreateBurnCardWeapon( "bc_car_m2",					BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_WEAPON	| CT_SMG									, "burncards/burncard_art_07", 	BC_NEXTDEATH, 		"#BC_CAR_M2"			   	, "#BC_CAR_M2_DESC"			    , "#BC_CAR_M2_FLAVOR"					, "#BC_FLAVOR_BLISK",			"mp_weapon_car",				"burn_mod_car",							"PRIMARY"		)
	CreateBurnCardWeapon( "bc_r97_m2",					BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_WEAPON	| CT_SMG									, "burncards/burncard_art_05", 	BC_NEXTDEATH, 		"#BC_R97_M2"				, "#BC_R97_M2_DESC"			    , "#BC_R97_M2_FLAVOR"					, "#BC_FLAVOR_SARAH_COBALT",	"mp_weapon_r97",				"burn_mod_r97",							"PRIMARY"		)
	CreateBurnCardWeapon( "bc_shotgun_m2",				BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_WEAPON	| CT_SMG									, "burncards/burncard_art_06", 	BC_NEXTDEATH, 		"#BC_SHOTGUN_M2"			, "#BC_SHOTGUN_M2_DESC"			, "#BC_SHOTGUN_M2_FLAVOR"				, "#BC_FLAVOR_BAKER_ANGEL_CITY", "mp_weapon_shotgun",			"burn_mod_shotgun",			"PRIMARY"		)
	CreateBurnCardWeapon( "bc_rspn101_m2",				BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_WEAPON	| CT_RIFLE									, "burncards/burncard_art_26", 	BC_NEXTDEATH, 		"#BC_RSPN101_M2"			, "#BC_RSPN101_M2_DESC"			, "#BC_RSPN101_M2_FLAVOR"				, "#BC_FLAVOR_MACALLAN",		"mp_weapon_rspn101",			"burn_mod_rspn101",						"PRIMARY"		)
	CreateBurnCardWeapon( "bc_hemlok_m2",				BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_WEAPON	| CT_RIFLE									, "burncards/burncard_art_21", 	BC_NEXTDEATH, 		"#BC_HEMLOK_M2"				, "#BC_HEMLOK_M2_DESC"			, "#BC_HEMLOK_M2_FLAVOR"				, "#BC_FLAVOR_BISH",			"mp_weapon_hemlok",				"burn_mod_hemlok",						"PRIMARY"		)
	CreateBurnCardWeapon( "bc_g2_m2",					BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_WEAPON	| CT_RIFLE									, "burncards/burncard_art_20", 	BC_NEXTDEATH, 		"#BC_G2_M2"			   		, "#BC_G2_M2_DESC"			    , "#BC_G2_M2_FLAVOR"					, "#BC_FLAVOR_FARMER_COLONY",	"mp_weapon_g2",					"burn_mod_g2",							"PRIMARY"		)
	CreateBurnCardWeapon( "bc_lmg_m2",					BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_WEAPON	 											, "burncards/burncard_art_22", 	BC_NEXTDEATH, 		"#BC_LMG_M2"			   	, "#BC_LMG_M2_DESC"			    , "#BC_LMG_M2_FLAVOR"					, "#BC_FLAVOR_PILOT",			"mp_weapon_lmg",				"burn_mod_lmg",							"PRIMARY"		)
	CreateBurnCardWeapon( "bc_dmr_m2",					BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_WEAPON	| CT_SNIPER									, "burncards/burncard_art_17", 	BC_NEXTDEATH, 		"#BC_DMR_M2"				, "#BC_DMR_M2_DESC"			    , "#BC_DMR_M2_FLAVOR"					, "#BC_FLAVOR_SPYGLASS",		"mp_weapon_dmr",				"burn_mod_dmr",							"PRIMARY"		)
	CreateBurnCardWeapon( "bc_sniper_m2",				BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_WEAPON	| CT_SNIPER									, "burncards/burncard_art_31", 	BC_NEXTDEATH, 		"#BC_SNIPER_M2"				, "#BC_SNIPER_M2_DESC"			, "#BC_SNIPER_M2_FLAVOR"				, "#BC_FLAVOR_SARAH",			"mp_weapon_sniper",				"burn_mod_sniper",						"PRIMARY"		)
	CreateBurnCardWeapon( "bc_smr_m2",					BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_WEAPON	| CT_ANTI_TITAN								, "burncards/burncard_art_30", 	BC_NEXTDEATH, 		"#BC_SMR_M2"				, "#BC_SMR_M2_DESC"			    , "#BC_SMR_M2_FLAVOR"					, "#BC_FLAVOR_SARAH",			"mp_weapon_smr",				"burn_mod_smr",							"SECONDARY"		)
	CreateBurnCardWeapon( "bc_rocket_launcher_m2",		BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_WEAPON	| CT_ANTI_TITAN								, "burncards/burncard_art_32", 	BC_NEXTDEATH, 		"#BC_ROCKET_LAUNCHER_M2"	, "#BC_ROCKET_LAUNCHER_M2_DESC"	, "#BC_ROCKET_LAUNCHER_M2_FLAVOR"		, "#BC_FLAVOR_BISH",			"mp_weapon_rocket_launcher",	"burn_mod_rocket_launcher",				"SECONDARY"		)
	CreateBurnCardWeapon( "bc_mgl_m2",					BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_WEAPON	| CT_ANTI_TITAN								, "burncards/burncard_art_23", 	BC_NEXTDEATH, 		"#BC_MGL_M2"			    , "#BC_MGL_M2_DESC"			    , "#BC_MGL_M2_FLAVOR"					, "#BC_FLAVOR_GRAVES",			"mp_weapon_mgl",				"burn_mod_mgl",							"SECONDARY"		)
	CreateBurnCardWeapon( "bc_defender_m2",				BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_WEAPON	| CT_ANTI_TITAN								, "burncards/burncard_art_16", 	BC_NEXTDEATH, 		"#BC_DEFENDER_M2"			, "#BC_DEFENDER_M2_DESC"		, "#BC_DEFENDER_M2_FLAVOR"				, "#BC_FLAVOR_BISH",			"mp_weapon_defender",			"burn_mod_defender",					"SECONDARY"		)
	CreateBurnCardWeapon( "bc_super_cloak", 			BURNCARD_COMMON,	BCGROUP_STEALTH, 	CT_SPECIAL	| CT_CLOAK									, "burncards/burncard_art_01", 	BC_NEXTDEATH, 		"#BC_SUPER_CLOAK" 		    , "#BC_SUPER_CLOAK_DESC" 		, "#BC_SUPER_CLOAK_FLAVOR" 		   		, "#BC_FLAVOR_SARAH",			"mp_ability_cloak",				null,									"OFFHAND1"		)
	CreateBurnCardOnSpawn( "bc_cloak_forever", 			BURNCARD_RARE, 		BCGROUP_STEALTH, 	CT_CLOAK |		CT_SPECIAL | CT_COOLDOWN				, "burncards/burncard_art_57", 	BC_NEXTDEATH, 		"#BC_CLOAK_FOREVER" 	    , "#BC_CLOAK_FOREVER_DESC" 		, "#BC_CLOAK_FOREVER_FLAVOR" 			, "#BC_FLAVOR_SARAH",			null,							null,							null,			null						)
	CreateBurnCardSrvFlag( "bc_fast_movespeed", 		BURNCARD_COMMON, 	BCGROUP_SPEED, 		CT_SPECIAL | CT_PILOT 									, "burncards/burncard_art_39", 	BC_NEXTDEATH, 		"#BC_FAST_MOVESPEED" 	 	, "#BC_FAST_MOVESPEED_DESC" 	, "#BC_FAST_MOVESPEED_FLAVOR" 	   		, "#BC_FLAVOR_DOCTOR",			SFLAG_BC_FAST_MOVESPEED,		null,							null,			null						)
	CreateBurnCardWeapon( "bc_super_stim", 				BURNCARD_COMMON,	BCGROUP_SPEED, 		CT_SPECIAL	| CT_STIM									, "burncards/burncard_art_03", 	BC_NEXTDEATH, 		"#BC_SUPER_STIM" 		   	, "#BC_SUPER_STIM_DESC" 		, "#BC_SUPER_STIM_FLAVOR" 		   		, "#BC_FLAVOR_DOCTOR",			"mp_ability_heal",				null,									"OFFHAND1"					)
	CreateBurnCardOnSpawn( "bc_stim_forever", 			BURNCARD_RARE, 		BCGROUP_SPEED, 		CT_STIM |		CT_SPECIAL | CT_COOLDOWN				, "burncards/burncard_art_58", 	BC_NEXTDEATH, 		"#BC_STIM_FOREVER" 		    , "#BC_STIM_FOREVER_DESC" 		, "#BC_STIM_FOREVER_FLAVOR" 			, "#BC_FLAVOR_DOCTOR",			null,							null,							null,			null						)
	CreateBurnCardPassive( "bc_pilot_warning", 			BURNCARD_COMMON, 	BCGROUP_INTEL, 		CT_INTEL | 	CT_PILOT									, "burncards/burncard_art_49", 	BC_NEXTDEATH, 		"#BC_PILOT_WARNING" 	    , "#BC_PILOT_WARNING_DESC" 		, "#BC_PILOT_WARNING_FLAVOR" 			, "#BC_FLAVOR_BISH",			null,							null,							null,			null						)
	CreateBurnCardPassive( "bc_auto_sonar", 			BURNCARD_COMMON, 	BCGROUP_INTEL, 		CT_INTEL 	| CT_SPECIAL | CT_SONAR						, "burncards/burncard_art_42", 	BC_NEXTDEATH, 		"#BC_AUTO_SONAR" 		   	, "#BC_AUTO_SONAR_DESC" 		, "#BC_AUTO_SONAR_FLAVOR" 		   		, "#BC_FLAVOR_BISH",			PAS_AUTO_SONAR,					null,							null,			null						)
	CreateBurnCardWeapon( "bc_super_sonar", 			BURNCARD_COMMON,	BCGROUP_INTEL, 		CT_SPECIAL	| CT_SONAR | CT_INTEL						, "burncards/burncard_art_02", 	BC_NEXTDEATH, 		"#BC_SUPER_SONAR" 		    , "#BC_SUPER_SONAR_DESC" 		, "#BC_SUPER_SONAR_FLAVOR" 		   		, "#BC_FLAVOR_MACALLAN",		"mp_ability_sonar",				null,									"OFFHAND1"					)
	CreateBurnCardPassive( "bc_sonar_forever", 			BURNCARD_RARE, 		BCGROUP_INTEL, 		CT_INTEL | CT_SONAR |		CT_SPECIAL | CT_COOLDOWN	, "burncards/burncard_art_44", 	BC_NEXTDEATH, 		"#BC_SONAR_FOREVER" 	    , "#BC_SONAR_FOREVER_DESC" 		, "#BC_SONAR_FOREVER_FLAVOR" 			, "#BC_FLAVOR_BISH",			PAS_AUTO_SONAR,					null,							null,			null						)
	CreateBurnCardOnSpawn( "bc_minimap_scan", 			BURNCARD_COMMON, 	BCGROUP_INTEL, 		CT_INTEL												, "burncards/burncard_art_51", 	BC_NEXTDEATH, 		"#BC_MINIMAP_SCAN" 		    , "#BC_MINIMAP_SCAN_DESC" 		, "#BC_MINIMAP_SCAN_FLAVOR" 			, "#BC_FLAVOR_SARAH",			null,							null,							null,			null						)
	CreateBurnCardPassive( "bc_minimap", 				BURNCARD_RARE, 		BCGROUP_INTEL, 		CT_INTEL												, "burncards/burncard_art_45", 	BC_NEXTDEATH, 		"#BC_MINIMAP" 			    , "#BC_MINIMAP_DESC" 			, "#BC_MINIMAP_FLAVOR" 			   		, "#BC_FLAVOR_BISH",			PAS_MINIMAP_ALL, 				null,							null,			null						)
	CreateBurnCardOnSpawn( "bc_double_agent", 			BURNCARD_COMMON, 	BCGROUP_NPC, 		CT_NPC	| CT_GRUNT | CT_SPECTRE | CT_TITAN				, "burncards/burncard_art_60", 	BC_NEXTDEATH, 		"#BC_DOUBLE_AGENT" 		    , "#BC_DOUBLE_AGENT_DESC" 		, "#BC_DOUBLE_AGENT_FLAVOR" 			, "#BC_FLAVOR_SOLDIER",			null,							null,							null,			null						)
	CreateBurnCardPassive( "bc_conscription", 			BURNCARD_COMMON, 	BCGROUP_NPC, 		CT_GRUNT	| CT_NPC									, "burncards/burncard_art_41", 	BC_NEXTDEATH, 		"#BC_CONSCRIPTION" 		    , "#BC_CONSCRIPTION_DESC" 		, "#BC_CONSCRIPTION_FLAVOR" 			, "#BC_FLAVOR_SOLDIER",			PAS_CONSCRIPT,					null,							null,			null						)
	CreateBurnCardPassive( "bc_wifi_spectre_hack",	 	BURNCARD_COMMON, 	BCGROUP_NPC,	 	CT_NPC | 		CT_SPECTRE								, "burncards/burncard_art_43", 	BC_NEXTDEATH, 		"#BC_WIFI_SPECTRE_HACK"	    , "#BC_WIFI_SPECTRE_HACK_DESC"	, "#BC_WIFI_SPECTRE_HACK_FLAVOR"		, "#BC_FLAVOR_SARAH", 			PAS_WIFI_SPECTRE,				null,							null,			null						)
	CreateBurnCardPassive( "bc_nuclear_core", 			BURNCARD_COMMON,	BCGROUP_MISC, 		CT_TITAN                                                , "burncards/burncard_art_46", 	BC_NEXTDEATH, 		"#BC_NUCLEAR_CORE" 		    , "#BC_NUCLEAR_CORE_DESC" 		, "#BC_NUCLEAR_CORE_FLAVOR" 			, "#BC_FLAVOR_BISH",			PAS_NUCLEAR_CORE, 			null,							null,			null						)
	CreateBurnCardOnSpawn( "bc_core_charged", 			BURNCARD_COMMON, 	BCGROUP_MISC, 		CT_TITAN												, "burncards/burncard_art_59", 	BC_NEXTDEATH, 		"#BC_CORE_CHARGED" 		    , "#BC_CORE_CHARGED_DESC" 		, "#BC_CORE_CHARGED_FLAVOR" 			, "#BC_FLAVOR_SPYGLASS",		null,						null,							null,			null						)
	CreateBurnCardOnSpawn( "bc_rematch", 				BURNCARD_COMMON, 	BCGROUP_MISC, 		CT_PILOT												, "burncards/burncard_art_50", 	BC_NEXTSPAWN, 		"#BC_REMATCH" 			    , "#BC_REMATCH_DESC" 			, "#BC_REMATCH_FLAVOR" 			   		, "#BC_FLAVOR_PILOT",			null,							null,							null,			null						)
	CreateBurnCardOnSpawn( "bc_play_spectre", 			BURNCARD_RARE, 		BCGROUP_MISC, 		CT_SPECTRE												, "burncards/burncard_art_52", 	BC_NEXTDEATH, 		"#BC_PLAY_SPECTRE" 		    , "#BC_PLAY_SPECTRE_DESC" 		, "#BC_PLAY_SPECTRE_FLAVOR" 			, "#BC_FLAVOR_HAMMOND",			null,							null,							null,			null						)
	CreateBurnCardOnSpawn( "bc_free_build_time_1",		BURNCARD_COMMON, 	BCGROUP_BONUS, 		CT_BUILDTIME											, "burncards/burncard_art_47", 	BC_NEXTSPAWN, 		"#BC_FREE_BUILD_TIME_1"	    , "#BC_FREE_BUILD_TIME_1_DESC"	, "#BC_FREE_BUILD_TIME_1_FLAVOR"		, "#BC_FLAVOR_MACALLAN",		null,							null,							null,			null						)
	CreateBurnCardOnSpawn( "bc_free_build_time_2",		BURNCARD_COMMON, 	BCGROUP_BONUS, 		CT_BUILDTIME											, "burncards/burncard_art_48", 	BC_NEXTSPAWN, 		"#BC_FREE_BUILD_TIME_2"	    , "#BC_FREE_BUILD_TIME_2_DESC"	, "#BC_FREE_BUILD_TIME_2_FLAVOR"		, "#BC_FLAVOR_GRAVES",			null,							null,							null,			null						)
	CreateBurnCardSrvFlag( "bc_fast_build_2", 			BURNCARD_COMMON, 	BCGROUP_BONUS, 		CT_BUILDTIME											, "burncards/burncard_art_40", 	BC_NEXTDEATH, 		"#BC_FAST_BUILD_2" 		    , "#BC_FAST_BUILD_2_DESC" 		, "#BC_FAST_BUILD_2_FLAVOR" 			, "#BC_FLAVOR_BLISK",			SFLAG_FAST_BUILD2,				null,							null,			null						)
	CreateBurnCardSrvFlag( "bc_double_xp", 				BURNCARD_COMMON, 	BCGROUP_BONUS, 		CT_XP 													, "burncards/burncard_art_34", 	BC_NEXTDEATH, 		"#BC_DOUBLE_XP" 		    , "#BC_DOUBLE_XP_DESC" 		    , "#BC_DOUBLE_XP_FLAVOR" 		   		, "#BC_FLAVOR_SPYGLASS",		SFLAG_DOUBLE_XP, 				null,							null,			null						)
	CreateBurnCardSrvFlag( "bc_hunt_soldier", 			BURNCARD_COMMON, 	BCGROUP_BONUS,		CT_HUNT | CT_XP | CT_NPC |	CT_GRUNT |	CT_BUILDTIME	, "burncards/burncard_art_35", 	BC_NEXTDEATH, 		"#BC_HUNT_SOLDIER" 		    , "#BC_HUNT_SOLDIER_DESC" 		, "#BC_HUNT_SOLDIER_FLAVOR" 			, "#BC_FLAVOR_BLISK",			SFLAG_HUNTER_GRUNT, 			null,							null,			null						)
	CreateBurnCardSrvFlag( "bc_hunt_spectre",			BURNCARD_COMMON, 	BCGROUP_BONUS,		CT_HUNT | CT_XP | CT_NPC |	CT_SPECTRE |CT_BUILDTIME	, "burncards/burncard_art_36", 	BC_NEXTDEATH, 		"#BC_HUNT_SPECTRE"		    , "#BC_HUNT_SPECTRE_DESC"		, "#BC_HUNT_SPECTRE_FLAVOR"		   		, "#BC_FLAVOR_SPYGLASS",		SFLAG_HUNTER_SPECTRE, 			null,							null,			null						)
	CreateBurnCardSrvFlag( "bc_hunt_pilot", 			BURNCARD_COMMON, 	BCGROUP_BONUS,		CT_HUNT | CT_XP | CT_PILOT |	CT_BUILDTIME			, "burncards/burncard_art_37", 	BC_NEXTDEATH, 		"#BC_HUNT_PILOT" 		   	, "#BC_HUNT_PILOT_DESC" 		, "#BC_HUNT_PILOT_FLAVOR" 		   		, "#BC_FLAVOR_GRAVES",			SFLAG_HUNTER_PILOT, 			null,							null,			null						)
	CreateBurnCardSrvFlag( "bc_hunt_titan", 			BURNCARD_COMMON, 	BCGROUP_BONUS,		CT_HUNT | CT_XP | CT_TITAN |	CT_BUILDTIME			, "burncards/burncard_art_38", 	BC_NEXTDEATH, 		"#BC_HUNT_TITAN" 		   	, "#BC_HUNT_TITAN_DESC" 		, "#BC_HUNT_TITAN_FLAVOR" 		   		, "#BC_FLAVOR_SCRAPYARD",		SFLAG_HUNTER_TITAN, 			null,							null,			null						)
	CreateBurnCardOnSpawn( "bc_summon_atlas",			BURNCARD_RARE,	 	BCGROUP_BONUS, 		CT_TITAN |		CT_NPC |		CT_BUILDTIME			, "burncards/burncard_art_54", 	BC_NEXTTITAN, 		"#BC_SUMMON_ATLAS"		    , "#BC_SUMMON_ATLAS_DESC"		, "#BC_SUMMON_ATLAS_FLAVOR"		   		, "#BC_FLAVOR_MANUAL",			null,							null,							null,			null						)
	CreateBurnCardOnSpawn( "bc_summon_ogre",			BURNCARD_RARE,	 	BCGROUP_BONUS, 		CT_TITAN |		CT_NPC |		CT_BUILDTIME			, "burncards/burncard_art_55", 	BC_NEXTTITAN, 		"#BC_SUMMON_OGRE"		   	, "#BC_SUMMON_OGRE_DESC"		, "#BC_SUMMON_OGRE_FLAVOR"		   		, "#BC_FLAVOR_SALESMAN",		null,							null,							null,			null						)
	CreateBurnCardOnSpawn( "bc_summon_stryder",			BURNCARD_RARE,	 	BCGROUP_BONUS, 		CT_TITAN |		CT_NPC |		CT_BUILDTIME			, "burncards/burncard_art_56", 	BC_NEXTTITAN, 		"#BC_SUMMON_STRYDER"	    , "#BC_SUMMON_STRYDER_DESC"		, "#BC_SUMMON_STRYDER_FLAVOR"			, "#BC_FLAVOR_GRAVES",			null,							null,							null,			null						)
	//CreateBurnCardOnSpawn( "bc_free_xp",				BURNCARD_RARE, 		BCGROUP_BONUS, 		CT_XP													, "burncards/burncard_art_61", 	BC_NEXTSPAWN, 		"#BC_FREE_XP"	    		, "#BC_FREE_XP_DESC"	    	, "#BC_FREE_XP_FLAVOR"					, "#BC_FLAVOR_ADVOCATE",		null,							null,							null,			null						)
	CreateBurnCardOnSpawn( "bc_auto_refill",			BURNCARD_COMMON, 	BCGROUP_BONUS, 		0														, "burncards/burncard_art_62", 	BC_FOREVER,   		"#BC_AUTO_REFILL"	    	, "#BC_AUTO_REFILL_DESC"	    , "#BC_AUTO_REFILL_FLAVOR"				, "#BC_FLAVOR_ADVOCATE",		null,							null,							null,			null						)
	CreateBurnCardOnSpawn( "bc_dice_ondeath",			BURNCARD_RARE, 		BCGROUP_DICE, 		CT_INTEL | CT_PILOT | CT_SPECIAL | CT_GRUNT				, "burncards/burncard_art_62", 	BC_FOREVER,   		"#BC_DICE_ONDEATH"	    	, "#BC_DICE_ONDEATH_DESC"	    , "#BC_AUTO_REFILL_FLAVOR"				, "#BC_FLAVOR_ADVOCATE",		null,							null,							null,			null						)

	//DLC Titan Weapon Burn Cards
	CreateBurnCardWeapon( "bc_titan_40mm_m2",					BURNCARD_RARE, 		BCGROUP_WEAPON, 	CT_TITAN_WPN	| CT_PRIMARY					, "burncards/amped_titan_40mm", 		BC_NEXTTITANDROP, "#BC_TITAN_40MM_M2"					, "#BC_TITAN_40MM_M2_DESC"				, "#BC_TITAN_40MM_M2_FLAVOR"				, "#BC_FLAVOR_IMC_RESEARCH",	"mp_titanweapon_40mm",					"burn_mod_titan_40mm", 					"TITAN_PRIMARY"		)
	CreateBurnCardWeapon( "bc_titan_arc_cannon_m2",				BURNCARD_RARE, 		BCGROUP_WEAPON, 	CT_TITAN_WPN	| CT_PRIMARY					, "burncards/amped_titan_arc_cannon", 	BC_NEXTTITANDROP, "#BC_TITAN_ARC_CANNON_M2"				, "#BC_TITAN_ARC_CANNON_M2_DESC"		, "#BC_TITAN_ARC_CANNON_M2_FLAVOR"			, "#BC_FLAVOR_IMC_RESEARCH",	"mp_titanweapon_arc_cannon",			"burn_mod_titan_arc_cannon", 			"TITAN_PRIMARY"		)
	CreateBurnCardWeapon( "bc_titan_rocket_launcher_m2",		BURNCARD_RARE, 		BCGROUP_WEAPON, 	CT_TITAN_WPN	| CT_PRIMARY					, "burncards/amped_titan_quadrocket", 	BC_NEXTTITANDROP, "#BC_TITAN_ROCKET_LAUNCHER_M2"		, "#BC_TITAN_ROCKET_LAUNCHER_M2_DESC"	, "#BC_TITAN_ROCKET_LAUNCHER_M2_FLAVOR"		, "#BC_FLAVOR_PILOT",			"mp_titanweapon_rocket_launcher",		"burn_mod_titan_rocket_launcher", 		"TITAN_PRIMARY"		)
	CreateBurnCardWeapon( "bc_titan_sniper_m2",					BURNCARD_RARE, 		BCGROUP_WEAPON, 	CT_TITAN_WPN	| CT_PRIMARY					, "burncards/amped_titan_railgun", 		BC_NEXTTITANDROP, "#BC_TITAN_SNIPER_M2"					, "#BC_TITAN_SNIPER_M2_DESC"			, "#BC_TITAN_SNIPER_M2_FLAVOR"				, "#BC_FLAVOR_IMC_RESEARCH",	"mp_titanweapon_sniper",				"burn_mod_titan_sniper", 				"TITAN_PRIMARY"		)
	CreateBurnCardWeapon( "bc_titan_triple_threat_m2",			BURNCARD_RARE, 		BCGROUP_WEAPON, 	CT_TITAN_WPN	| CT_PRIMARY					, "burncards/amped_titan_triplethreat", BC_NEXTTITANDROP, "#BC_TITAN_TRIPLE_THREAT_M2"			, "#BC_TITAN_TRIPLE_THREAT_M2_DESC"		, "#BC_TITAN_TRIPLE_THREAT_M2_FLAVOR"		, "#BC_FLAVOR_PILOT",			"mp_titanweapon_triple_threat",			"burn_mod_titan_triple_threat", 		"TITAN_PRIMARY"		)
	CreateBurnCardWeapon( "bc_titan_xo16_m2",					BURNCARD_RARE, 		BCGROUP_WEAPON, 	CT_TITAN_WPN	| CT_PRIMARY					, "burncards/amped_titan_xo16_arc", 	BC_NEXTTITANDROP, "#BC_TITAN_XO16_M2"					, "#BC_TITAN_XO16_M2_DESC"				, "#BC_TITAN_XO16_M2_FLAVOR"				, "#BC_FLAVOR_MACALLAN",		"mp_titanweapon_xo16",					"burn_mod_titan_xo16", 					"TITAN_PRIMARY"		)
	CreateBurnCardWeapon( "bc_titan_dumbfire_missile_m2",		BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_TITAN_WPN	| CT_ORDNANCE					, "burncards/amped_cluster_missile",	BC_NEXTTITANDROP, "#BC_TITAN_DUMBFIRE_MISSILE_M2"		, "#BC_TITAN_DUMBFIRE_MISSILE_M2_DESC"	, "#BC_TITAN_DUMBFIRE_MISSILE_M2_FLAVOR"	, "#BC_FLAVOR_MCKENZIE",		"mp_titanweapon_dumbfire_rockets",		"burn_mod_titan_dumbfire_rockets", 		"TITAN_OFFHAND0"	)
	CreateBurnCardWeapon( "bc_titan_homing_rockets_m2",			BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_TITAN_WPN	| CT_ORDNANCE					, "burncards/amped_slaved_warheads",	BC_NEXTTITANDROP, "#BC_TITAN_HOMING_ROCKETS_M2"			, "#BC_TITAN_HOMING_ROCKETS_M2_DESC"	, "#BC_TITAN_HOMING_ROCKETS_M2_FLAVOR"		, "#BC_FLAVOR_SPYGLASS",		"mp_titanweapon_homing_rockets",		"burn_mod_titan_homing_rockets", 		"TITAN_OFFHAND0"	)
	CreateBurnCardWeapon( "bc_titan_salvo_rockets_m2",			BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_TITAN_WPN	| CT_ORDNANCE					, "burncards/amped_rocket_salvo", 		BC_NEXTTITANDROP, "#BC_TITAN_SALVO_ROCKETS_M2"			, "#BC_TITAN_SALVO_ROCKETS_M2_DESC"		, "#BC_TITAN_SALVO_ROCKETS_M2_FLAVOR"		, "#BC_FLAVOR_BLISK",			"mp_titanweapon_salvo_rockets",			"burn_mod_titan_salvo_rockets",			"TITAN_OFFHAND0"	)
	CreateBurnCardWeapon( "bc_titan_shoulder_rockets_m2",		BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_TITAN_WPN	| CT_ORDNANCE					, "burncards/amped_multi_target", 		BC_NEXTTITANDROP, "#BC_TITAN_SHOULDER_ROCKETS_M2"		, "#BC_TITAN_SHOULDER_ROCKETS_M2_DESC"	, "#BC_TITAN_SHOULDER_ROCKETS_M2_FLAVOR"	, "#BC_FLAVOR_BISH",			"mp_titanweapon_shoulder_rockets",		"burn_mod_titan_shoulder_rockets", 		"TITAN_OFFHAND0"	)
	CreateBurnCardWeapon( "bc_titan_vortex_shield_m2",			BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_TITAN_WPN	| CT_TACTICAL					, "burncards/amped_vortex_shield", 		BC_NEXTTITANDROP, "#BC_TITAN_VORTEX_SHIELD_M2"			, "#BC_TITAN_VORTEX_SHIELD_M2_DESC"		, "#BC_TITAN_VORTEX_SHIELD_M2_FLAVOR"		, "#BC_FLAVOR_MCKENZIE",		"mp_titanweapon_vortex_shield",			"burn_mod_titan_vortex_shield",			"TITAN_OFFHAND1"	)
	CreateBurnCardWeapon( "bc_titan_electric_smoke_m2",			BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_TITAN_WPN	| CT_TACTICAL					, "burncards/amped_electric_smoke", 	BC_NEXTTITANDROP, "#BC_TITAN_ELECTRIC_SMOKE_M2"			, "#BC_TITAN_ELECTRIC_SMOKE_M2_DESC"	, "#BC_TITAN_ELECTRIC_SMOKE_M2_FLAVOR"		, "#BC_FLAVOR_BISH",			"mp_titanability_smoke",				"burn_mod_titan_smoke",					"TITAN_OFFHAND1"	)
	CreateBurnCardWeapon( "bc_titan_shield_wall_m2",			BURNCARD_COMMON, 	BCGROUP_WEAPON, 	CT_TITAN_WPN	| CT_TACTICAL					, "burncards/amped_shield_wall", 		BC_NEXTTITANDROP, "#BC_TITAN_SHIELD_WALL_M2"			, "#BC_TITAN_SHIELD_WALL_M2_DESC"		, "#BC_TITAN_SHIELD_WALL_M2_FLAVOR"			, "#BC_FLAVOR_MACALLAN",		"mp_titanability_bubble_shield",		"burn_mod_titan_bubble_shield",			"TITAN_OFFHAND1"	)
	CreateBurnCardSrvFlag( "bc_titan_melee_m2", 				BURNCARD_RARE, 		BCGROUP_SPEED, 		CT_TITAN_WPN 									, "burncards/amped_melee", 				BC_NEXTTITANDROP, "#BC_TITAN_MELEE_M2" 	   				, "#BC_TITAN_MELEE_M2_DESC" 			, "#BC_TITAN_MELEE_M2_FLAVOR" 	   			, "#BC_FLAVOR_BISH",			SFLAG_BC_EXPLOSIVE_PUNCH,			null,							null,			null						)
	CreateBurnCardSrvFlag( "bc_extra_dash", 					BURNCARD_COMMON, 	BCGROUP_SPEED, 		CT_TITAN 										, "burncards/amped_dash", 				BC_NEXTTITANDROP, "#BC_EXTRA_DASH" 	   					, "#BC_EXTRA_DASH_DESC" 				, "#BC_EXTRA_DASH_FLAVOR" 	   				, "#BC_FLAVOR_BISH",			SFLAG_BC_DASH_CAPACITY,				null,							null,			null						)

	if ( IsServer() )
	{
		//GenerateBurnCardPacks()
	}
}

function CreateMatchLongShopItems()
{
	foreach ( cardRef, table in level.burnCardData )
	{
		if ( table.lastsUntil == BC_NEXTLOAD )
			CreateMatchLongUpgradeShopItem( cardRef )
	}
}
Globalize( CreateMatchLongShopItems )

function CreateMatchLongUpgradeShopItem( cardRef )
{
	local image = ""
	if ( !IsServer() )
		image = GetBurnCardImage( cardRef )

	local item = CreateShopItem( cardRef, "Upgrade Burn Card", "Permanently upgrade this Burn Card to always last the entire match.", image, COST_BC_MATCHLONG_UPGRADE )
	item.upgradedCardRef <- cardRef
}
Globalize( CreateMatchLongUpgradeShopItem )


function CreateNewBurnCard( cardRef )
{
	local table = {}
	table.index <- level.burnCardCurrentIndex
	table.passiveLifeLong <- null
	table.serverFlags <- null

	// for making burn cards have a unique color for debugging
	table.debugColor <- { r = RandomInt( 255 ), g = RandomInt( 255 ), b = RandomInt( 255 ) }

	level.indexToBurnCard[ table.index ] <- cardRef

	level.burnCardsByName[ cardRef ] <- table
	level.burnCards.append( cardRef )
	level.burnCardCurrentIndex++
	return table
}

function BurnCardRarityGroupSort( card1, card2 )
{
	if ( card1 == null )
	{
		if ( card2 == null )
			return 0
		return 1
	}
	else if ( card2 == null )
	{
		return -1
	}
}

function RefreshBurnCardHint()
{
	local hints = GetBurnCardHints()
	ArrayRandomize( hints )
	local cardData = level.burnCardData[ "bc_auto_refill" ]
	cardData.description = hints[0]
}
Globalize( RefreshBurnCardHint )

function GetBurnCardHints()
{
	local hints = []
	hints.append( "#BC_HINT_ONE_LIFE"				)
	hints.append( "#BC_HINT_AVAILABLE_WHEN_DEAD"	)
	hints.append( "#BC_HINT_AVAILABLE_MATCH_START"	)
	hints.append( "#BC_HINT_AVAILABLE_DURING_MATCH" )
	hints.append( "#BC_HINT_ROUND_BASED" )
	hints.append( "#BC_HINT_KILL_REPLAY"			)

	local player
	if ( !IsUI() )
		player = GetLocalClientPlayer()

	if ( !IsItemLocked( "challenges", null, player ) )
		hints.append( "#BC_HINT_COMPLETE_CHALLENGES" )

	return hints
}
Globalize( GetBurnCardHints )

function SetBurnCardRarity( table, rarity )
{
	table.rarity <- rarity

	// doesnt get given at random
	switch ( table.card )
	{
		case "bc_dice_ondeath":
		case "bc_auto_refill":
		case "bc_free_xp":
			return
	}

	level.burnCardsOfRarity[ rarity ].append( table.card )
}

function SetBurnCardGroup( table, group )
{
	table.group <- group
	level.burnCardsOfGroup[ group ].append( table.card )
}

function CreateBurnCardOnSpawn( card, rarity, group, ctFlags, image, lastsUntil, title, description, flavorText, flavorOwner, _ = null, _ = null, _ = null, _ = null, _ = null, _ = null )
{
	local table = CreateNewBurnCard( card )
	level.burnCardData[ card ] <- table
	table.card <- card
	SetBurnCardGroup( table, group )
	table.lastsUntil <- lastsUntil
	SetBurnCardRarity( table, rarity )
	table.title <- title
	table.ctFlags <- ctFlags

	if ( !IsUI() )
	{
		PrecacheMaterial( "vgui/" + image )
		//PrecacheMaterial( "vgui/" + midIcon )
		//PrecacheMaterial( "vgui/" + largeIcon )
	}

	if ( IsServer() )
	{
		table.enumIndex <- PersistenceGetEnumIndexForItemName( "burnCard", card );
	}
	else
	{
		table.image <- image
		//table.midIcon <- midIcon
		//table.largeIcon <- largeIcon
		table.description <- description
		table.flavorText <- flavorText
		table.flavorOwner <- flavorOwner
	}

	return table
}

function CreateBurnCardWeapon( card, rarity, group, ctFlags, image, lastsUntil, title, description, flavorText, flavorOwner, weapon, mod = null, weaponType = null )
{
	local table = CreateBurnCardOnSpawn( card, rarity, group, ctFlags, image, lastsUntil, title, description, flavorText, flavorOwner )
	table.Weapon <- weapon
	table.WeaponMod <- mod
	table.WeaponType <- weaponType

	if ( mod != null )
	{
		if ( !( mod in level.burnCardWeaponModList ) )
			level.burnCardWeaponModList[ mod ] <- title
	}
}

function CreateBurnCardPassive( card, rarity, group, ctFlags, image, lastsUntil, title, description, flavorText, flavorOwner, passive, _ = null, _ = null, _ = null)
{
	local table = CreateBurnCardOnSpawn( card, rarity, group, ctFlags, image, lastsUntil, title, description, flavorText, flavorOwner )
	table.passiveLifeLong = passive
}

function CreateBurnCardSrvFlag( card, rarity, group, ctFlags, image, lastsUntil, title, description, flavorText, flavorOwner, srvFlag, _ = null, _ = null, _ = null)
{
	local table = CreateBurnCardOnSpawn( card, rarity, group, ctFlags, image, lastsUntil, title, description, flavorText, flavorOwner )
	table.serverFlags = srvFlag
}

function GetBurnCardData( card )
{
	return level.burnCardData[ card ]
}

function GetBurnCardWeapon( card )
{
	local cardData = level.burnCardData[ card ]
	if ( !( "Weapon" in cardData ) )
		return null

	local mods = []
	if ( cardData.WeaponMod )
		mods.append( cardData.WeaponMod )

	return { weapon = cardData.Weapon, mods = mods, weaponType = cardData.WeaponType }
}

function GetBurnCardRarity( card )
{
	local cardData = level.burnCardData[ card ]

	return cardData.rarity
}

function GetBurnCardLastsUntil( card )
{
	local cardData = level.burnCardData[ card ]
	return cardData.lastsUntil
}

function GetBurnCardCount( card )
{
	local cardData = level.burnCardData[ card ]
	return cardData.count
}

function GetBurnCardPassive( card )
{
	local cardData = level.burnCardData[ card ]
	return cardData.passiveLifeLong
}

function GetBurnCardServerFlags( card )
{
	local cardData = level.burnCardData[ card ]
	return cardData.serverFlags
}

function GetBurnCardDescription( card )
{
	local cardData = level.burnCardData[ card ]
	return cardData.description
}

function GetBurnCardTitle( card )
{
	local cardData = level.burnCardData[ card ]
	return cardData.title
}

function GetBurnCardImage( card )
{
	local cardData = level.burnCardData[ card ]
	return cardData.image
}

function GetBurnCardFlags( card )
{
	local cardData = level.burnCardData[ card ]
	return cardData.ctFlags
}

function GetBurnCardGroup( card )
{
	local cardData = level.burnCardData[ card ]
	return cardData.group
}

function GetBurnCardColor( card )
{
	local cardData = level.burnCardData[ card ]
	return cardData.debugColor
}

function GetBurnCardRarityColor( card )
{
	local cardData = level.burnCardData[ card ]
	return RARITY_COLOR[ cardData.rarity ]
}

function GetBurnCardLargeIcon( card )
{
	local cardData = level.burnCardData[ card ]
	if ( GROUP_ICONS_ENABLED )
	{
		return BC_GROUP_ICONS[ cardData.group ]
	}

	return cardData.largeIcon
}

function GetBurnCardHudIcon( card )
{
	local icon = GetBurnCardLargeIcon( card )
	return icon + "_white"
}
Globalize( GetBurnCardHudIcon )

function GetBurnCardMidIcon( card )
{
	local cardData = level.burnCardData[ card ]
	return cardData.midIcon
}

function GetBurnCardFlavorText( card )
{
	local cardData = level.burnCardData[ card ]
	if ( cardData.flavorText == null )
		return null

	return { text = cardData.flavorText, owner = cardData.flavorOwner }
}

function GetBurnCardIndex( card )
{
	local cardData = level.burnCardData[ card ]
	return cardData.index
}

if ( IsServer() )
{
	function GetBurnCardPersistenceEnumIndex( card )
	{
		local cardData = level.burnCardData[ card ]
		return cardData.enumIndex
	}
	Globalize( GetBurnCardPersistenceEnumIndex )
}

function _GetActiveBurnCardsPersDataPrefix()
{
	if ( UsingAlternateBurnCardPersistence() )
		return "persData_pm_activeBurnCards"
	else
		return "persData_activeBurnCards"
}

function _GetBurnCardDeckPersDataPrefix()
{
	if ( UsingAlternateBurnCardPersistence() )
		return "pm_burnCardDeck"
	else
		return "burnCardDeck"
}
Globalize( _GetBurnCardDeckPersDataPrefix )

function _GetBurnCardPersPlayerDataPrefix()
{
	if ( UsingAlternateBurnCardPersistence() )
		return "pm_bc"
	else
		return "bc"
}
Globalize( _GetBurnCardPersPlayerDataPrefix )

function GetBurnCardFromSlot( player, persDataIndex )
{
	local dataName = _GetActiveBurnCardsPersDataPrefix() + "[" + persDataIndex + "].cardRef"
	local card = player.GetPersistentVar( dataName )
	if ( card == null )
		return null
	if ( card in level.burnCardsByName )
		return card

	return null
}

function IsDiceCard( cardRef )
{
	local group = GetBurnCardGroup( cardRef )
	return group == BCGROUP_DICE
}
Globalize( IsDiceCard )

if ( !IsUI() )
{
	function GetPlayerBurnCardDeck( player )
	{
		local burncards = []

		local max = PersistenceGetArrayCount( _GetBurnCardDeckPersDataPrefix() )
		for ( local i = 0; i < max; i++ )
		{
			local bcard = GetPlayerBurnCardFromDeck( player, i )
			if ( bcard != null )
				burncards.append( bcard )
		}

		return burncards
	}

	function GetPlayerBurnCardUpgraded( player, cardRef )
	{
		if ( !( cardRef in level.burnCardsByName ) )
			return false
		return player.GetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".burnCardUpgraded[" + cardRef + "]" )
	}

	function SetPlayerBurnCardUpgraded( player, cardRef )
	{
		if ( !( cardRef in level.burnCardsByName ) )
			return false
		return player.SetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".burnCardUpgraded[" + cardRef + "]", true )
	}

	function GetPlayerBlackMarketUpgradeShopItem( player, index )
	{
		local cardRef = player.GetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".blackMarkedBurnCardUpgrades[" + index + "].cardRef" )
		if ( cardRef in level.burnCardsByName )
			return cardRef

		return null
	}

	function SetPlayerBlackMarketNextResetTime( player, time )
	{
		player.SetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".blackMarketTimeUntilBurnCardUpgradeReset", time )
	}

	function GetPlayerBlackMarketNextResetTime( player )
	{
		return player.GetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".blackMarketTimeUntilBurnCardUpgradeReset" )
	}

	function SetPlayerBlackMarketUpgrade( player, index, cardRef )
	{
		player.SetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".blackMarkedBurnCardUpgrades[" + index + "].cardRef", cardRef )
	}

	function GetPlayerBurnCardFromDeck( player, slotID )
	{
		local cardRef = player.GetPersistentVar( _GetBurnCardDeckPersDataPrefix() + "[" + slotID + "]" )
		if ( cardRef == null )
			return null
		if ( cardRef in level.burnCardsByName )
		{
			return { cardRef = cardRef, new = player.GetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".burnCardIsNew[" + slotID + "]" ) }
		}

		return null
	}

	function SetPlayerBurnCardFromDeck( player, slotID, bcard = null )
	{
		if ( bcard == null )
		{
			player.SetPersistentVar( _GetBurnCardDeckPersDataPrefix() + "[" + slotID + "]", null )
			player.SetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".burnCardIsNew[" + slotID + "]", false )
			return
		}

		player.SetPersistentVar( _GetBurnCardDeckPersDataPrefix() + "[" + slotID + "]", bcard.cardRef )
		player.SetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".burnCardIsNew[" + slotID + "]", bcard.new )
	}

	function GetPlayerActiveBurnCard( player )
	{
		local index = player.GetActiveBurnCardIndex()
		if ( index < 0 )
			return null
		if ( index >= level.indexToBurnCard.len() )
			return null
		if ( index == BURNCARD_INDEX_EMPTY )
			return null

		return level.indexToBurnCard[ index ]
	}

	function GetPlayerActiveBurnCardSlotContents( player, slotID )
	{
		local cardRef = player.GetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + slotID + "].cardRef" )
		if ( cardRef == null )
			return null
		if ( cardRef in level.burnCardsByName )
			return cardRef

		return null
	}

	function SetPlayerLastActiveBurnCardFromSlot( player, slotID, cardRef )
	{
		if ( !( cardRef in level.burnCardsByName ) )
			return

		player.SetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + slotID + "].lastCardRef", cardRef )
	}

	function PlayerHasDiceStashed( player, index )
	{
		local cardRef = GetPlayerStashedCardRef( player, index )
		if ( cardRef == null )
			return false

		return IsDiceCard( cardRef )
	}

	function GetPlayerStashedCardRef( player, index )
	{
		Assert( index < PersistenceGetArrayCount( _GetBurnCardPersPlayerDataPrefix() + ".stashedCardRef" ) )
		Assert( index >= 0 )

		local cardRef = player.GetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".stashedCardRef[" + index + "]" )
		if ( !( cardRef in level.burnCardsByName ) )
			return null

		return cardRef
	}

	function SetPlayerStashedCardRef( player, cardRef, index )
	{
		Assert( index < PersistenceGetArrayCount( _GetBurnCardPersPlayerDataPrefix() + ".stashedCardRef" ) )
		Assert( index >= 0 )

		if ( !( cardRef in level.burnCardsByName ) )
			cardRef = null

		player.SetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".stashedCardRef[" + index + "]", cardRef )
	}

	function SetPlayerStashedCardTime( player, cardTime, index )
	{
		Assert( index < PersistenceGetArrayCount( _GetBurnCardPersPlayerDataPrefix() + ".stashedCardRef" ) )
		Assert( index >= 0 )
		player.SetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".stashedCardTime[" + index + "]", cardTime )
	}

	function GetPlayerStashedCardTime( player, index )
	{
		Assert( index < PersistenceGetArrayCount( _GetBurnCardPersPlayerDataPrefix() + ".stashedCardRef" ) )
		Assert( index >= 0 )
		return player.GetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".stashedCardTime[" + index + "]" )
	}

	function GetPlayerTotalBurnCards( player )
	{
		local deck = GetPlayerBurnCardDeck( player )
		local actives = GetPlayerActiveBurnCards( player )
		local count = deck.len()

		for ( local slotID = 0; slotID < INGAME_BURN_CARDS; slotID++ )
		{
			if ( GetPlayerStashedCardRef( player, slotID ) != null )
				count++
		}

		foreach ( active in actives )
		{
			if ( active != null )
				count++
		}
		return count
	}

	function SetPlayerActiveBurnCardSlotContents( player, slotID, cardRef, clearOnStart )
	{
		player.SetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + slotID + "].cardRef", cardRef )
		player.SetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + slotID + "].clearOnStart", clearOnStart )
		player.Signal( "RefreshDice" )
	}

	function GetPlayerActiveBurnCardSlotClearOnStart( player, slotID )
	{
		return player.GetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + slotID + "].clearOnStart" )
	}

	function BurnCardChallengeCompleted( player, cardRef, tier )
	{
		// stub
	}
	Globalize( BurnCardChallengeCompleted )

	function GetPlayerUnopenedCards( player )
	{
		local cards = []
		for ( local i = 0; i < MAX_UNOPENED_BURNCARDS; i++ )
		{
			local card = player.GetPersistentVar( "persData_unopenedBurnCards[" + i + "]" )
			if ( card == null )
				break
			if ( !( card in level.burnCardsByName ) )
				continue

			cards.append( card )
		}
		return cards
	}

	function GetPlayerNextPack_XPRemaining( player )
	{
		local xp = player.GetPersistentVar( "xp" )
		return GetBurnCardNextPack_XPRemaining( xp )
	}

	function FindPlayerFirstEmptyActiveSlot( player )
	{
		for ( local slotID = 0; slotID < GetPlayerMaxActiveBurnCards( player ); slotID++ )
		{
			local cardRef = GetPlayerActiveBurnCardSlotContents( player, slotID )
			if ( cardRef != null )
				continue

			return slotID
		}

		return null
	}

	function GetPlayerMaxActiveBurnCards( player )
	{
		if ( UsingAlternateBurnCardPersistence() )
			return 3

		local gen = player.GetGen()
		if ( gen > 0 )
			return 3

		local lvl = GetLevel( player )
		if ( lvl >= GetUnlockLevelReq( "burn_card_slot_3" ) )
			return 3
		if ( lvl >= GetUnlockLevelReq( "burn_card_slot_2" ) )
			return 2
		return 1
	}

	function GetMaxActiveBurnCardSlots()
	{
		return PersistenceGetArrayCount( _GetActiveBurnCardsPersDataPrefix() )
	}
	Globalize( GetMaxActiveBurnCardSlots )

	function GetPlayerMaxStoredBurnCards( player )
	{
		return BurnCardLimitFunc( player.GetGen() )
	}

	function GetPlayerBurnCardsSpent( player )
	{
		local spent = 0
		local entryCount = PersistenceGetEnumCount( "burnCard" )
		for ( local i = 0; i < entryCount; i++ )
		{
			local used = player.GetPersistentVar( "persData_historyBurnCards[" + i + "].spent" )
			spent += player.GetPersistentVar( "persData_historyBurnCards[" + i + "].spent" )
		}
		return spent
	}

	function GetPlayerBurnCardCollected( player, cardRef )
	{
		return player.GetPersistentVar( "persData_historyBurnCards[" + cardRef + "].collected" )
	}

	function SetPlayerBurnCardCollected( player, cardRef, count )
	{
		return player.SetPersistentVar( "persData_historyBurnCards[" + cardRef + "].collected", count )
	}

	function GetPlayerBurnCardOnDeckIndex( player )
	{
		local val = player.GetPersistentVar( "onDeckBurnCardIndex" )
		if ( val == -1 )
			return null
		return val
	}

	function GetPlayerBurnCardActiveSlotID( player )
	{
		local val = player.GetPersistentVar( "activeBCID" )
		if ( val == -1 )
			return null
		return val
	}

	function SetPlayerBurnCardActiveSlotID( player, index )
	{
		if ( index == null )
			index = -1

		if ( index >= GetPlayerMaxActiveBurnCards( player ) )
			return

		player.SetPersistentVar( "activeBCID", index )
	}

	function FindPlayerBurnCardInActive( player, findCardRef )
	{
		for ( local slotID = 0; slotID < GetPlayerMaxActiveBurnCards( player ); slotID++ )
		{
			local cardRef = GetPlayerActiveBurnCardSlotContents( player, slotID )
			if ( cardRef == null )
				continue

			if ( cardRef != findCardRef )
				continue

			return slotID
		}

		return null
	}

	function GetPlayerActiveBurnCards( player )
	{
		local cards = []
		for ( local slotID = 0; slotID < GetPlayerMaxActiveBurnCards( player ); slotID++ )
		{
			local cardRef = GetPlayerActiveBurnCardSlotContents( player, slotID )
			cards.append( cardRef )
		}

		return cards
	}

	function SetPlayerBurnCardOnDeckIndex( player, index )
	{
		if ( "burnCardSelectionLocked" in player.s )
		{
			printt( player + " burn card selection is locked" )
			return
		}

		if ( index == null )
			index = -1

		if ( index >= GetPlayerMaxActiveBurnCards( player ) )
			return

		player.SetPersistentVar( "onDeckBurnCardIndex", index )
		Remote.CallFunction_NonReplay( player, "ServerCallback_UpdateOnDeckIndex" )
		player.Signal( "RefreshDice" )
		//printt( "Sending " + player + " on deck " + index )
	}
}
else
{
	function IsBurnCardUpgradedForLocalPlayer( cardRef )
	{
		return GetBurnCardUpgraded( cardRef )
	}
	Globalize( IsBurnCardUpgradedForLocalPlayer )

	function GetBurnCardOnDeckIndex()
	{
		if ( !IsConnected() )
			return null
		if ( !IsFullyConnected() )
			return null
		local val = GetPersistentVar( "onDeckBurnCardIndex" )
		if ( val == -1 )
			return null
		return val
	}
	Globalize( GetBurnCardOnDeckIndex )

	function GetTotalActiveBurnCards()
	{
		local count = 0
		local actives = GetActiveBurnCards()
		foreach ( active in actives )
		{
			if ( active != null )
				count++
		}
		return count
	}
	Globalize( GetTotalActiveBurnCards )

	function ShouldEnableBurnCardMenu()
	{
		if ( GetBurnCardActiveSlotID() != null )
			return true

		local max = PersistenceGetArrayCount( _GetBurnCardPersPlayerDataPrefix() + ".stashedCardRef" )

		for ( local i = 0; i < max; i++ )
		{
			if ( GetStashedCardRef( i ) != null )
				return true
		}
		return GetTotalActiveBurnCards() > 0
	}
	Globalize( ShouldEnableBurnCardMenu )

	function GetStashedCardRef( index )
	{
		Assert( index < PersistenceGetArrayCount( _GetBurnCardPersPlayerDataPrefix() + ".stashedCardRef" ) )
		Assert( index >= 0 )

		local cardRef = GetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".stashedCardRef[" + index + "]" )
		if ( !( cardRef in level.burnCardsByName ) )
			return null

		return cardRef
	}


	function UIGetActiveBurnCard()
	{
		local index = GetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".uiActiveBurnCardIndex" ) - 1
		if ( index < 0 )
			return null
		if ( index >= level.indexToBurnCard.len() )
			return null
		if ( index == BURNCARD_INDEX_EMPTY )
			return null
		return level.indexToBurnCard[ index ]
	}
	Globalize( UIGetActiveBurnCard )

	function GetTotalBurnCards()
	{
		return GetBurnCardDeck().len() + GetTotalActiveBurnCards() + GetTotalStashedBurnCards()
	}
	Globalize( GetTotalBurnCards )

	function GetTotalStashedBurnCards()
	{
		local count = 0
		for ( local slotID = 0; slotID < INGAME_BURN_CARDS; slotID++ )
		{
			if ( GetStashedCardRef( slotID ) != null )
				count++
		}
		return count
	}

	function GetActiveBurnCards()
	{
		local cards = []
		for ( local slotID = 0; slotID < GetMaxActiveBurnCards(); slotID++ )
		{
			local cardRef = GetActiveBurnCardFromSlot( slotID )
			cards.append( cardRef )
		}

		return cards
	}
	Globalize( GetActiveBurnCards )

	function GetMaxStoredBurnCards()
	{
		return BurnCardLimitFunc( GetPersistentVar( "gen" ) )
	}
	Globalize( GetMaxStoredBurnCards )

	function GetMaxActiveBurnCards()
	{
		local gen = GetGen()
		if ( gen > 0 )
			return 3

		if ( UsingAlternateBurnCardPersistence() )
			return 3

		local lvl = GetLevel()
		if ( lvl >= GetUnlockLevelReq( "burn_card_slot_3" ) )
			return 3
		if ( lvl >= GetUnlockLevelReq( "burn_card_slot_2" ) )
			return 2
		return 1
	}
	Globalize( GetMaxActiveBurnCards )

	function GetBurnCardActiveSlotID()
	{
		local val = GetPersistentVar( "activeBCID" )
		if ( val == -1 )
			return null
		return val
	}
	Globalize( GetBurnCardActiveSlotID )

	function GetStashedCardRef( index )
	{
		Assert( index < PersistenceGetArrayCount( _GetBurnCardPersPlayerDataPrefix() + ".stashedCardRef" ) )
		Assert( index >= 0 )

		local cardRef = GetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".stashedCardRef[" + index + "]" )
		if ( !( cardRef in level.burnCardsByName ) )
			return null

		return cardRef
	}
	Globalize( GetStashedCardRef )

	function GetStashedCardTime( index )
	{
		Assert( index < PersistenceGetArrayCount( _GetBurnCardPersPlayerDataPrefix() + ".stashedCardRef" ) )
		Assert( index >= 0 )
		return GetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".stashedCardTime[" + index + "]" )
	}
	Globalize( GetStashedCardTime )

	function GetBurnCardDeck()
	{
		local burncards = []
		local max = PersistenceGetArrayCount( _GetBurnCardDeckPersDataPrefix() )
		for ( local i = 0; i < max; i++ )
		{
			local bcard = GetBurnCardFromDeck( i )
			if ( bcard != null )
				burncards.append( bcard )
		}

		return burncards
	}
	Globalize( GetBurnCardDeck )



	function GetBurnCardFromDeck( slotID )
	{
		local cardRef = GetPersistentVar( _GetBurnCardDeckPersDataPrefix() + "[" + slotID + "]" )
		if ( cardRef == null )
			return null
		if ( cardRef in level.burnCardsByName )
			return cardRef

		return null
	}
	Globalize( GetBurnCardFromDeck )

	function GetBlackMarketMatchLongUpgradeShopItem( index )
	{
		local cardRef = GetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".blackMarkedBurnCardUpgrades[" + index + "].cardRef" )
		if ( cardRef in level.burnCardsByName )
			return cardRef

		return null
	}
	Globalize( GetBlackMarketMatchLongUpgradeShopItem )

	function GetBurnCardUpgraded( cardRef )
	{
		if ( !IsFullyConnected() )
			return false
		if ( !( cardRef in level.burnCardsByName ) )
			return false
		return GetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".burnCardUpgraded[" + cardRef + "]" )
	}
	Globalize( GetBurnCardUpgraded )


	function FindFirstEmptyActiveSlot()
	{
		for ( local slotID = 0; slotID < GetMaxActiveBurnCards(); slotID++ )
		{
			local cardRef = GetActiveBurnCardFromSlot( slotID )
			if ( cardRef != null )
				continue

			return slotID
		}

		return null
	}
	Globalize( FindFirstEmptyActiveSlot )


	function GetNextPack_XPRemaining()
	{
		local xp = GetPersistentVar( "xp" )
		return GetBurnCardNextPack_XPRemaining( xp )
	}
	Globalize( GetNextPack_XPRemaining )

	function GetActiveBurnCardFromSlot( slotID )
	{
		local card = GetPersistentVar( _GetActiveBurnCardsPersDataPrefix() + "[" + slotID + "].cardRef" )
		if ( card == null )
			return null

		if ( card in level.burnCardsByName )
			return card

		return null
	}
	Globalize( GetActiveBurnCardFromSlot )

	function HasNewBurnCards()
	{
		local max = PersistenceGetArrayCount( _GetBurnCardPersPlayerDataPrefix() + ".burnCardIsNew" )
		for ( local i = 0; i < max; i++ )
		{
			if ( GetPersistentVar( _GetBurnCardPersPlayerDataPrefix() + ".burnCardIsNew[" + i + "]" ) )
				return true
		}
		return false
	}
	Globalize( HasNewBurnCards )

}

if ( IsClient() )
{
	function IsBurnCardUpgradedForLocalPlayer( cardRef )
	{
		local player = GetLocalClientPlayer()
		return GetPlayerBurnCardUpgraded( player, cardRef )
	}
	Globalize( IsBurnCardUpgradedForLocalPlayer )
}


if ( !IsServer() )
{
	function HideBurnCard( elemTable )
	{
		elemTable.title.Hide()
		elemTable.image.Hide()
		elemTable.slotText.Hide()
		elemTable.background.Hide()
		elemTable.BurnCardMid_star.Hide()
	}
	Globalize( HideBurnCard )

	function ShowBurnCard( elemTable )
	{
		elemTable.title.Show()
		elemTable.title.SetAlpha( 255 )
		elemTable.image.Show()
		elemTable.image.SetAlpha( 255 )
		elemTable.background.Show()
		elemTable.background.SetAlpha( 255 )
		elemTable.BurnCardMid_star.Hide()

		if ( elemTable.upgraded )
			elemTable.BurnCardMid_star.Show()
		else
			elemTable.BurnCardMid_star.Hide()
	}
	Globalize( ShowBurnCard )

	function ShowBurnCardUpgraded( elemTable )
	{
		ShowBurnCard( elemTable )
		elemTable.BurnCardMid_star.Show()
	}
	Globalize( ShowBurnCardUpgraded )

	function CreateBurnCardPanel( table, vguiOrPanel )
	{
		if ( IsClient() && vguiOrPanel instanceof C_VGuiScreen )
		{
			local panel = vguiOrPanel.GetPanel()
			table.title 		<- HudElement( "BurnCardMid_title", panel )
			table.slotText 		<- HudElement( "BurnCardMid_slotText", panel )
			table.BurnCardMid_BottomText <- HudElement( "BurnCardMid_BottomText", panel )
			table.image 		<- HudElement( "BurnCardMid_SelectImage", panel )
			table.BurnCardMid_star 		<- HudElement( "BurnCardMid_star", panel )
			table.background 	<- HudElement( "BurnCardMid_background", panel )
			table.reminder 		<- HudElement( "BurnCardMid_Reminder", panel )
			table.panel <- panel
		}
		else
		{
			local panel = vguiOrPanel
			table.title 		<- panel.GetChild( "BurnCardMid_title" )
			table.slotText 		<- panel.GetChild( "BurnCardMid_slotText" )
			table.BurnCardMid_BottomText <- panel.GetChild( "BurnCardMid_BottomText" )
			table.image 		<- panel.GetChild( "BurnCardMid_SelectImage" )
			table.BurnCardMid_star 		<- panel.GetChild( "BurnCardMid_star" )
			table.background 	<- panel.GetChild( "BurnCardMid_background" )
			table.reminder 		<- panel.GetChild( "BurnCardMid_Reminder" )
			table.panel <- panel
		}

		table.upgraded <- false
	}
	Globalize( CreateBurnCardPanel )

	function UpdateActiveSlotBurnCardBottomText( elemTable, selected, slotID, onDeckSlotID, activeSlotID, activeCardRef, stashedCardRef = null, stashedCardTime = null )
	{
		local activeSlotIsActiveIndex = slotID == activeSlotID
		local activeSlotMessage
		local selected


		if ( activeSlotIsActiveIndex && activeCardRef == null )
		{
			SetBurnCardBottomText( elemTable, "#BC_ACTIVE_SLOT", 55, 205, 55, 255 )
			return
		}

		if ( slotID == onDeckSlotID )
		{
			SetBurnCardBottomText( elemTable, "#BC_ON_DECK", 255, 205, 35, 255 )
			return
		}

		if ( stashedCardRef != null )
		{
			Assert( stashedCardTime != null )

			if ( !( activeCardRef in level.burnCardsByName ) )
			{
				if ( stashedCardRef == null )
					return

				if ( stashedCardTime == null )
					return

				// show the stashed card, active card is null
				SetBurnCardToCard( elemTable, selected, stashedCardRef )
				ShowBurnCard( elemTable )
			}

			elemTable.BurnCardMid_BottomText.SetColor( 255, 255, 255, 255 )
			elemTable.BurnCardMid_BottomText.SetAutoText( "", HATT_COUNTDOWN_TIME, stashedCardTime )
			elemTable.BurnCardMid_BottomText.Show()
			return
		}

		// clear it
		SetBurnCardBottomText( elemTable, "", 255, 255, 255, 255 )
	}
	Globalize( UpdateActiveSlotBurnCardBottomText )

	function DrawBurnCard( elemTable, selectedButton, active, card )
	{
		SetBurnCardToCard( elemTable, selectedButton, card )
		ShowBurnCard( elemTable )
	}
	Globalize( DrawBurnCard )

	function DrawCardSlot( elemTable, selectedButton, selectable )
	{
		local title = "#BC_EMPTY_SLOT"

		elemTable.slotText.SetText( title )

		elemTable.slotText.SetColor( 235, 245, 255, 255 )
		elemTable.slotText.Show()
		elemTable.background.SetAlpha( 255 )
		elemTable.image.SetColor( 255, 255, 255, 255 )

		ShowBurnCard( elemTable )
		elemTable.title.Hide()
		elemTable.image.Hide()

		if ( selectedButton )
		{
			elemTable.background.SetImage( "burncards/burncard_mid_blank_hover" )
		}
		else
		{
			elemTable.background.SetImage( "burncards/burncard_mid_blank" )
		}

		if ( !selectable )
		{
			elemTable.background.SetAlpha( 55 )
			elemTable.slotText.SetColor( 115, 125, 135, 255 )
		}
	}
	Globalize( DrawCardSlot )

	function FadeBurnCard( previewCardTable, alpha, time, interp )
	{
		previewCardTable.background.FadeOverTime( alpha, time, interp )
		previewCardTable.image.FadeOverTime( alpha, time, interp )
		previewCardTable.BurnCardMid_BottomText.FadeOverTime( alpha, time, interp )
		previewCardTable.title.FadeOverTime( alpha, time, interp )
		previewCardTable.slotText.FadeOverTime( alpha, time, interp )
	}
	Globalize( FadeBurnCard )

	function SetBurnCardToCard( elemTable, selectedButton, card )
	{
		local alphaDisabled = 25
		Assert( card != null )
		local title = GetBurnCardTitle( card )
		local description = GetBurnCardDescription( card )
		local image = GetBurnCardImage( card )
		local rarity = GetBurnCardRarity( card )
		local group = GetBurnCardGroup( card )

		elemTable.title.SetText( title )
		elemTable.slotText.Hide()
		elemTable.image.SetImage( image )

		elemTable.upgraded = IsBurnCardUpgradedForLocalPlayer( card )

		if ( selectedButton )
		{
			elemTable.background.SetImage( "burncards/burncard_mid_type" + ( group + 1 ) + "_hover" )
			elemTable.background.SetColor( 255, 255, 255, 255 )
			elemTable.image.SetColor( 255, 255, 255, 255 )
			elemTable.title.SetColor( 255, 255, 255, 255 )
			elemTable.BurnCardMid_star.SetColor( 255, 255, 255, 145 )
		}
		else
		{
			elemTable.background.SetImage( "burncards/burncard_mid_type" + ( group + 1 ) )
			elemTable.background.SetColor( 155, 155, 155, 255 )
			elemTable.image.SetColor( 150, 150, 150, 255 )
			elemTable.title.SetColor( 160, 160, 160, 255 )
			elemTable.BurnCardMid_star.SetColor( 255, 255, 255, 15 )
		}

		elemTable.background.SetAlpha( 255 )
	}
	Globalize( SetBurnCardToCard )

	function CreatePreviewCardFromStandardElements( previewPanel )
	{
		local previewNames = [
			"PreviewCard_image",
			"PreviewCard_icon1",
			"PreviewCard_icon2",
			"PreviewCard_star",
			"PreviewCard_title",
			"PreviewCard_description",
			"PreviewCard_topbottom_brackets",
			"PreviewCard_background",
			"PreviewCard_flavorText",
			"PreviewCard_flavorText_Owner",
			"PreviewCard_number"
			"PreviewCard_outline"
			"PreviewCard_new"
		]

		local table = {}
		if ( IsClient() && previewPanel instanceof C_VGuiScreen )
		{
			local panel = previewPanel.GetPanel()
			foreach ( name in previewNames )
			{
				table[ name ] <- HudElement( name, panel )
			}
		}
		else
		{
			foreach ( name in previewNames )
			{
				table[ name ] <- previewPanel.GetChild( name )
			}
		}

		// manually hide things that aren't meant to be on by default
		table.PreviewCard_new.Hide()
		table.PreviewCard_outline.Hide()

		table.hudElement <- previewPanel

		return table
	}
	Globalize( CreatePreviewCardFromStandardElements )

	function CreateBurnCardSlotVGUI( previewPanel )
	{
		local previewNames = [
			"PreviewCard_title",
			"PreviewCard_background",
			"PreviewCard_outline",
			"PreviewCard_slot"
		]

		local table = {}
		if ( IsClient() && previewPanel instanceof C_VGuiScreen )
		{
			local panel = previewPanel.GetPanel()
			foreach ( name in previewNames )
			{
				table[ name ] <- HudElement( name, panel )
			}
		}
		else
		{
			foreach ( name in previewNames )
			{
				table[ name ] <- previewPanel.GetChild( name )
			}
		}

		table.PreviewCard_outline.Hide()
		table.hudElement <- previewPanel

		return table
	}
	Globalize( CreateBurnCardSlotVGUI )

	function PreviewCardOutline_SetColor( elemTable, r, g, b, a )
	{
		elemTable.PreviewCard_outline.Show()
		elemTable.PreviewCard_outline.SetColor( r, g, b, a )
	}
	Globalize( PreviewCardOutline_SetColor )

	function PreviewCardOutline_Hide( elemTable )
	{
		elemTable.PreviewCard_outline.Hide()
	}
	Globalize( PreviewCardOutline_Hide )

	function PreviewCardOutline_Show( elemTable )
	{
		elemTable.PreviewCard_outline.Show()
	}
	Globalize( PreviewCardOutline_Show )

	function HidePreviewCard( previewCardTable )
	{
		previewCardTable.hudElement.Hide()
		foreach ( element in previewCardTable )
		{
			element.Hide()
		}
	}
	Globalize( HidePreviewCard )

	function SetBurnCardBottomText( elemTable, msg, r, g, b, a )
	{
		if ( elemTable.BurnCardMid_BottomText.IsAutoText() )
			elemTable.BurnCardMid_BottomText.DisableAutoText()

		elemTable.BurnCardMid_BottomText.SetText( msg )
		elemTable.BurnCardMid_BottomText.SetColor( r, g, b, a )
		elemTable.BurnCardMid_BottomText.Show()
	}
	Globalize( SetBurnCardBottomText )

	function FadePreviewCard( previewCardTable, alpha, time, interp )
	{
		//foreach ( element in previewCardTable )
		//{
		//	element.FadeOverTime( alpha, time, interp )
		//}
		previewCardTable.PreviewCard_image.FadeOverTime( alpha, time, interp )
		previewCardTable.PreviewCard_icon1.FadeOverTime( alpha, time, interp )
		previewCardTable.PreviewCard_icon2.FadeOverTime( alpha, time, interp )
		previewCardTable.PreviewCard_title.FadeOverTime( alpha, time, interp )
		previewCardTable.PreviewCard_description.FadeOverTime( alpha, time, interp )
		previewCardTable.PreviewCard_flavorText.FadeOverTime( alpha, time, interp )
		previewCardTable.PreviewCard_number.FadeOverTime( alpha, time, interp )
		previewCardTable.PreviewCard_flavorText_Owner.FadeOverTime( alpha, time, interp )
		previewCardTable.PreviewCard_topbottom_brackets.FadeOverTime( alpha, time, interp )
		previewCardTable.PreviewCard_background.FadeOverTime( alpha, time, interp )
	}
	Globalize( FadePreviewCard )

	function ShowPreviewCard( previewCardTable )
	{
		previewCardTable.hudElement.Show()
		foreach ( element in previewCardTable )
		{
			element.Show()
			element.SetAlpha( 255 )
		}

		previewCardTable.PreviewCard_new.Hide()
		previewCardTable.PreviewCard_outline.Hide()
	}
	Globalize( ShowPreviewCard )

	function FadeInPreviewCard( previewCardTable )
	{
		foreach ( element in previewCardTable )
		{
			element.SetAlpha( 0 )
			element.FadeOverTime( 255, 0.4, INTERPOLATOR_LINEAR )
		}
	}
	Globalize( FadeInPreviewCard )

	function SetSlotColor( previewCardTable, r, g, b, a )
	{
		previewCardTable.PreviewCard_background.SetColor( r, g, b, a )
		//previewCardTable.PreviewCard_title.SetAlpha( r )
	}
	Globalize( SetSlotColor )

	function SetSlotText( previewCardTable, text, num = null )
	{
		previewCardTable.PreviewCard_slot.SetText( text, num )
	}
	Globalize( SetSlotText )

	function SetSlotTitleColor( previewCardTable, r, g, b )
	{
		previewCardTable.PreviewCard_title.SetColor( r, g, b )
	}
	Globalize( SetSlotTitleColor )

	function SetSlotTitleAlpha( previewCardTable, a )
	{
		previewCardTable.PreviewCard_title.SetAlpha( a )
	}
	Globalize( SetSlotTitleAlpha )

	function SetPreviewCardColor( previewCardTable, r, g, b, a = null )
	{
		if ( a != null )
		{
			previewCardTable.PreviewCard_image.SetColor( r, g, b, a )
			previewCardTable.PreviewCard_title.SetAlpha( r )
			previewCardTable.PreviewCard_topbottom_brackets.SetColor( r, g, b, a )
			previewCardTable.PreviewCard_background.SetColor( r, g, b, a )
			previewCardTable.PreviewCard_flavorText.SetColor( r, g, b, a )
			previewCardTable.PreviewCard_flavorText_Owner.SetColor( r, g, b, a )
		}
		else
		{
			previewCardTable.PreviewCard_image.SetColor( r, g, b )
			previewCardTable.PreviewCard_topbottom_brackets.SetColor( r, g, b )
			previewCardTable.PreviewCard_background.SetColor( r, g, b )
			previewCardTable.PreviewCard_flavorText.SetColor( r, g, b )
			previewCardTable.PreviewCard_flavorText_Owner.SetColor( r, g, b )
		}
	}
	Globalize( SetPreviewCardColor )

	function SetPreviewCard( cardRef, previewCardTable )
	{
		local image = GetBurnCardImage( cardRef )
		local title = GetBurnCardTitle( cardRef )
		local desc = GetBurnCardDescription( cardRef )
		local flavor =	GetBurnCardFlavorText( cardRef )
		local rarity = GetBurnCardRarity( cardRef )
		local number = GetBurnCardIndex( cardRef ) + 1

		previewCardTable.PreviewCard_image.SetImage( image )
		previewCardTable.PreviewCard_title.SetText( title )
		previewCardTable.PreviewCard_description.SetText( desc )
		previewCardTable.PreviewCard_outline.Hide()

		local group = GetBurnCardGroup( cardRef )
		local icon
		if ( rarity == BURNCARD_RARE )
		{
			previewCardTable.PreviewCard_title.SetColor( 255, 205, 155 )
			//previewCardTable.PreviewCard_topbottom_brackets.SetImage( "burncards/burncard_large_header_rare" )
			//previewCardTable.PreviewCard_background.SetImage( "burncards/burncard_large_rare" )
			icon = GetBurnCardHudIcon( cardRef )
			previewCardTable.PreviewCard_icon1.SetColor( 255, 205, 155 )
			previewCardTable.PreviewCard_icon2.SetColor( 255, 205, 155 )
			previewCardTable.PreviewCard_title.SetColor( 255, 205, 155 )
		}
		else
		{
			previewCardTable.PreviewCard_icon1.SetColor( 255, 255, 255 )
			previewCardTable.PreviewCard_icon2.SetColor( 255, 255, 255 )
			previewCardTable.PreviewCard_title.SetColor( 255, 255, 255 )
			//previewCardTable.PreviewCard_background.SetImage( "burncards/burncard_large_back" )
			icon = GetBurnCardLargeIcon( cardRef )
		}

		if ( IsBurnCardUpgradedForLocalPlayer( cardRef ) )
		{
			previewCardTable.PreviewCard_star.Show()
			previewCardTable.PreviewCard_star.SetColor( 255, 255, 255, 135 )
		}
		else
		{
			previewCardTable.PreviewCard_star.Hide()
		}

		previewCardTable.PreviewCard_icon1.SetImage( icon )
		previewCardTable.PreviewCard_icon2.SetImage( icon )
		previewCardTable.PreviewCard_topbottom_brackets.SetImage( "burncards/burncard_large_type" + ( group + 1 ) )


		if ( number < 10 )
		{
			number = "0" + number
		}
		else
		{
			number = "" + number
		}
		previewCardTable.PreviewCard_number.SetText( number )

		if ( flavor )
		{
	//		previewCardTable.PreviewCard_text_brackets.Show()
			previewCardTable.PreviewCard_flavorText.SetText( flavor.text )

			if ( flavor.owner )
			{
				previewCardTable.PreviewCard_flavorText_Owner.SetText( flavor.owner )
			}
		}
		else
		{
			//previewCardTable.PreviewCard_text_brackets.Hide()
			previewCardTable.PreviewCard_flavorText.SetText( "" )
			previewCardTable.PreviewCard_flavorText_Owner.SetText( "" )
		}
	}
	Globalize( SetPreviewCard )
}

function GetBurnCardNextPack_XPRemaining( xp )
{
	return xp % BURNCARD_PACK_PER_XP
}
Globalize( GetBurnCardNextPack_XPRemaining )

function BurnCardLimitFunc( gen )
{
	local limit = GetCurrentPlaylistVarInt( "bc_base_cards", 26 ) + gen * GetCurrentPlaylistVarInt( "bc_stash_bonus_per_gen", 0 )
	local max = PersistenceGetArrayCount( _GetBurnCardDeckPersDataPrefix() )

	if ( UsingAlternateBurnCardPersistence() )
		limit = max

	// return clamp( limit, 0, max )
	return max
}

function GetBurnCardIndexByRef( cardRef )
{
	local index = 0
	for( index = 0; index < level.indexToBurnCard.len() ; index++ )
	{
		if ( level.indexToBurnCard[ index ] == cardRef )
			return index
	}

	return null  // error
}

function DoesTitanHaveActiveTitanBurnCard( titan )
{
	local titanOwner
	if ( titan.IsPlayer() )
		titanOwner = titan
	else
		titanOwner = titan.GetBossPlayer()

	if ( !IsValid( titanOwner ) )
		return false

	return DoesPlayerHaveActiveTitanBurnCard( titanOwner )
}

Globalize( DoesTitanHaveActiveTitanBurnCard )

function DoesPlayerHaveActiveTitanBurnCard( player )
{
	local cardRef = GetPlayerActiveBurnCard( player )

	if ( !cardRef )
		return false

	return GetBurnCardLastsUntil( cardRef ) == BC_NEXTTITANDROP
}

Globalize( DoesPlayerHaveActiveTitanBurnCard )

function DoesPlayerHaveActiveNonTitanBurnCard( player )
{
	local cardRef = GetPlayerActiveBurnCard( player )

	if ( !cardRef )
		return false

	return GetBurnCardLastsUntil( cardRef ) != BC_NEXTTITANDROP
}

Globalize( DoesPlayerHaveActiveNonTitanBurnCard )

function UsingAlternateBurnCardPersistence()
{
	if ( IsUI() )
		return IsPrivateMatch() && GetLobbyTypeScript() == eLobbyType.PRIVATE_MATCH
	else
		return IsPrivateMatch()
}
Globalize( UsingAlternateBurnCardPersistence )

function GetSellCostOfRarity( rarity )
{
	switch ( rarity )
	{
		case BURNCARD_COMMON:
			return COIN_REWARD_SELL_COMMON
			break

		case BURNCARD_RARE:
			return COIN_REWARD_SELL_RARE
			break
	}
}
