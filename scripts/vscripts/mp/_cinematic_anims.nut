function main()
{
	IncludeFile( "mp/_viewcone" )

	Globalize( CreateAnimGroup )
	Globalize( AddAnimGroupBlend )
	Globalize( AddAnimGroupStart )

	Globalize( HasAnimGroupSequence )
	Globalize( GetAnimGroupSequence )

	Globalize( GetAnimGroupAllSeats )
	Globalize( GetAnimGroupSequences )
	Globalize( GetAnimGroupAttachment )
	Globalize( GetAnimGroupProceduralLength )
	Globalize( GetAnimGroup3rd )
	Globalize( GetAnimGroupFPS )
	Globalize( GetAnimGroupView )
	Globalize( GetAnimGroupBlendTime )
	Globalize( GetAnimGroupNoParent )
	Globalize( GetAnimGroupTeleport )
	Globalize( GetAnimGroupType )

	Globalize( SetSequenceViewCone )


	level.cinematicAnimGroups <- {}
	local animGroup

//ZIPLINE
	animGroup = CreateAnimGroup( "left", "RopeAttachLeftA", "zipline" )
	AddAnimGroupStart( animGroup, 	"idle",		"pt_dropship_rider_L_A_idle", "ptpov_dropship_rider_L_A_idle" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"zipline" )

	animGroup = CreateAnimGroup( "both", "RopeAttachLeftA", "zipline" )
	AddAnimGroupStart( animGroup, 	"idle", 	"pt_dropship_rider_L_A_idle", "ptpov_dropship_rider_L_A_idle" )
	AddAnimGroupBlend( animGroup,	"deploy",	"zipline" )
//----------------------
	animGroup = CreateAnimGroup( "right", "RopeAttachRightA", "zipline" )
	AddAnimGroupStart( animGroup, 	"idle", 	"pt_dropship_rider_R_A_idle", "ptpov_dropship_rider_R_A_idle" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"zipline" )

	animGroup = CreateAnimGroup( "both", "RopeAttachRightA", "zipline" )
	AddAnimGroupStart( animGroup, 	"idle", 	"pt_dropship_rider_R_A_idle", "ptpov_dropship_rider_R_A_idle" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"zipline" )
//----------------------
	animGroup = CreateAnimGroup( "left", "RopeAttachLeftC", "zipline" )
	AddAnimGroupStart( animGroup, 	"idle", 	"pt_dropship_rider_L_C_idle", "ptpov_dropship_rider_L_C_idle" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"zipline" )

	animGroup = CreateAnimGroup( "both", "RopeAttachLeftC", "zipline" )
	AddAnimGroupStart( animGroup, 	"idle", 	"pt_dropship_rider_L_C_idle", "ptpov_dropship_rider_L_C_idle" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"zipline" )
//----------------------
	animGroup = CreateAnimGroup( "right", "RopeAttachRightC", "zipline" )
	AddAnimGroupStart( animGroup, 	"idle", 	"pt_dropship_rider_R_C_idle", "ptpov_dropship_rider_R_C_idle" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"zipline" )

	animGroup = CreateAnimGroup( "both", "RopeAttachRightC", "zipline" )
	AddAnimGroupStart( animGroup, 	"idle", 	"pt_dropship_rider_R_C_idle", "ptpov_dropship_rider_R_C_idle" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"zipline" )
//----------------------
	animGroup = CreateAnimGroup( "left", "RopeAttachLeftB", "zipline" )
	AddAnimGroupStart( animGroup, 	"idle", 	"pt_dropship_rider_L_B_idle", "ptpov_dropship_rider_L_B_idle" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"zipline" )

	animGroup = CreateAnimGroup( "both", "RopeAttachLeftB", "zipline" )
	AddAnimGroupStart( animGroup, 	"idle", 	"pt_dropship_rider_L_B_idle", "ptpov_dropship_rider_L_B_idle" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"zipline" )
//----------------------
	animGroup = CreateAnimGroup( "right", "RopeAttachRightB", "zipline" )
	AddAnimGroupStart( animGroup, 	"idle", 	"pt_dropship_rider_R_B_idle", "ptpov_dropship_rider_R_B_idle" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"zipline" )

	animGroup = CreateAnimGroup( "both", "RopeAttachRightB", "zipline" )
	AddAnimGroupStart( animGroup, 	"idle", 	"pt_dropship_rider_R_B_idle", "ptpov_dropship_rider_R_B_idle" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"zipline" )


//RAMP DEPLOYMENT
	animGroup = CreateAnimGroup( "ramp", "RampAttachC", "ramp" )
	AddAnimGroupStart( animGroup, 	"idle", 	"CQB_Idle_static" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"ramp" )

	animGroup = CreateAnimGroup( "ramp", "RampAttachD", "ramp" )
	AddAnimGroupStart( animGroup, 	"idle", 	"CQB_Idle_static" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"ramp" )

	animGroup = CreateAnimGroup( "ramp", "RampAttachA", "ramp" )
	AddAnimGroupStart( animGroup, 	"idle", 	"CQB_Idle_static" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"ramp" )

	animGroup = CreateAnimGroup( "ramp", "RampAttachB", "ramp" )
	AddAnimGroupStart( animGroup, 	"idle", 	"CQB_Idle_static" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"ramp" )

	animGroup = CreateAnimGroup( "ramp", "RampAttachE", "ramp" )
	AddAnimGroupStart( animGroup, 	"idle", 	"CQB_Idle_static" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"ramp" )

	animGroup = CreateAnimGroup( "ramp", "RampAttachF", "ramp" )
	AddAnimGroupStart( animGroup, 	"idle", 	"CQB_Idle_static" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"ramp" )


//JUMP OUT
	//AddAnimGroupBlend( animGroup, 	name, 		anim3rd, 							animFPS = null, 					animView = ViewConeFree, 	teleport = null, noParent = true, blend )
	//front right
	animGroup = CreateAnimGroup( "jump", "ORIGIN", "jump" )
	AddAnimGroupStart( animGroup, 	"idle", 	"Militia_flyinA_idle_playerD", 		"Militia_flyinA_idle_povD",			ViewConeRampFrontRight )
	SetAnimProceduralLength( animGroup, "idle", true )
	SetAnimProceduralLengthAdjustment( animGroup, "idle", -6.65 )
	AddAnimGroupBlend( animGroup,	"ready",	"Militia_flyinA_countdown_playerD", "Militia_flyinA_countdown_povD",	ViewConeRampFree )
	AddAnimGroupBlend( animGroup,	"deploy", 	"Militia_flyinB_exit_playerD", 		"Militia_flyinB_exit_povD",			ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "deploy" )

	//back right
	animGroup = CreateAnimGroup( "jump", "ORIGIN", "jump" )
	AddAnimGroupStart( animGroup, 	"idle", 	"Militia_flyinA_idle_playerA", 		"Militia_flyinA_idle_povA",			ViewConeRampBackRight )
	SetAnimProceduralLength( animGroup, "idle", true )
	SetAnimProceduralLengthAdjustment( animGroup, "idle", -6.65 )
	AddAnimGroupBlend( animGroup,	"ready",	"Militia_flyinA_countdown_playerA", "Militia_flyinA_countdown_povA",	ViewConeRampFree )
	AddAnimGroupBlend( animGroup,	"deploy", 	"Militia_flyinB_exit_playerA", 		"Militia_flyinB_exit_povA",			ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "deploy" )

	//front left
	animGroup = CreateAnimGroup( "jump", "ORIGIN", "jump" )
	AddAnimGroupStart( animGroup, 	"idle", 	"Militia_flyinA_idle_playerB", 		"Militia_flyinA_idle_povB",			ViewConeRampFrontLeft )
	SetAnimProceduralLength( animGroup, "idle", true )
	SetAnimProceduralLengthAdjustment( animGroup, "idle", -6.65 )
	AddAnimGroupBlend( animGroup,	"ready",	"Militia_flyinA_countdown_playerB", "Militia_flyinA_countdown_povB",	ViewConeRampFree )
	AddAnimGroupBlend( animGroup,	"deploy", 	"Militia_flyinB_exit_playerB", 		"Militia_flyinB_exit_povB",			ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "deploy" )

	//back left
	animGroup = CreateAnimGroup( "jump", "ORIGIN", "jump" )
	AddAnimGroupStart( animGroup, 	"idle", 	"Militia_flyinA_idle_playerC", 		"Militia_flyinA_idle_povC",			ViewConeRampBackLeft )
	SetAnimProceduralLength( animGroup, "idle", true )
	SetAnimProceduralLengthAdjustment( animGroup, "idle", -6.65 )
	AddAnimGroupBlend( animGroup,	"ready",	"Militia_flyinA_countdown_playerC", "Militia_flyinA_countdown_povC",	ViewConeRampFree )
	AddAnimGroupBlend( animGroup,	"deploy", 	"Militia_flyinB_exit_playerC", 		"Militia_flyinB_exit_povC",			ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "deploy" )

//SIDE JUMP OUT
	//AddAnimGroupBlend( animGroup, 	name, 		anim3rd, 							animFPS = null, 				animView = ViewConeFree, 	teleport = null, noParent = true, blend )
	//standing front
	animGroup = CreateAnimGroup( "jumpSideR", "ORIGIN", "jump" )
	AddAnimGroupStart( animGroup, 	"idle", 	"pt_ds_side_intro_gen_idle_B", 			"ptpov_ds_side_intro_gen_idle_B",		ViewConeSideRightWithHeroStandFront )
	AddAnimGroupBlend( animGroup,	"deploy", 	"pt_ds_side_intro_gen_exit_B", 			"ptpov_ds_side_intro_gen_exit_B",		ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "deploy", true, "deploy"  )

	//sitting front
	animGroup = CreateAnimGroup( "jumpSideR", "ORIGIN", "jump" )
	AddAnimGroupStart( animGroup, 	"idle", 	"pt_ds_side_intro_gen_idle_D", 			"ptpov_ds_side_intro_gen_idle_D",		ViewConeSideRightWithHeroSitFront )
	AddAnimGroupBlend( animGroup,	"deploy", 	"pt_ds_side_intro_gen_exit_D", 			"ptpov_ds_side_intro_gen_exit_D",		ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "deploy", true, "deploy"  )

	//standing back
	animGroup = CreateAnimGroup( "jumpSideR", "ORIGIN", "jump" )
	AddAnimGroupStart( animGroup, 	"idle", 	"pt_ds_side_intro_gen_idle_A", 			"ptpov_ds_side_intro_gen_idle_A",		ViewConeSideRightWithHeroStandBack )
	AddAnimGroupBlend( animGroup,	"deploy", 	"pt_ds_side_intro_gen_exit_A", 			"ptpov_ds_side_intro_gen_exit_A",		ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "deploy", true, "deploy"  )

	//sitting back
	animGroup = CreateAnimGroup( "jumpSideR", "ORIGIN", "jump" )
	AddAnimGroupStart( animGroup, 	"idle", 	"pt_ds_side_intro_gen_idle_C", 			"ptpov_ds_side_intro_gen_idle_C",		ViewConeSideRightWithHeroSitBack )
	AddAnimGroupBlend( animGroup,	"deploy", 	"pt_ds_side_intro_gen_exit_C", 			"ptpov_ds_side_intro_gen_exit_C",		ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "deploy", true, "deploy"  )

	//standing middle
	animGroup = CreateAnimGroup( "jumpSideR", "ORIGIN", "jump" )
	AddAnimGroupStart( animGroup, 	"idle", 	"pt_ds_side_intro_gen_idle_E", 			"ptpov_ds_side_intro_gen_idle_E",		ViewConeSideRightWithHeroSitBack )
	AddAnimGroupBlend( animGroup,	"deploy", 	"pt_ds_side_intro_gen_exit_E", 			"ptpov_ds_side_intro_gen_exit_E",		ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "deploy", true, "deploy"  )

	//standing far back
	animGroup = CreateAnimGroup( "jumpSideR", "ORIGIN", "jump" )
	AddAnimGroupStart( animGroup, 	"idle", 	"pt_ds_side_intro_gen_idle_F", 			"ptpov_ds_side_intro_gen_idle_F",		ViewConeSideRightWithHeroSitBack )
	AddAnimGroupBlend( animGroup,	"deploy", 	"pt_ds_side_intro_gen_exit_F", 			"ptpov_ds_side_intro_gen_exit_F",		ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "deploy", true, "deploy"  )


//JUMP OUT QUICK
	//AddAnimGroupBlend( animGroup, 	name, 		anim3rd, 							animFPS = null, 					animView = ViewConeFree, 	teleport = null, noParent = true, blend )
	//front right
	animGroup = CreateAnimGroup( "jumpQuick", "ORIGIN", "jump" )
	AddAnimGroupStart( animGroup, 	"idle", 	"Militia_flyinA_idle_playerD", 		"Militia_flyinA_idle_povD",			ViewConeRampFrontRight )
	AddAnimGroupBlend( animGroup,	"deploy", 	"Militia_flyinB_exit_playerD", 		"Militia_flyinB_exit_povD",			ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "deploy" )

	//back right
	animGroup = CreateAnimGroup( "jumpQuick", "ORIGIN", "jump" )
	AddAnimGroupStart( animGroup, 	"idle", 	"Militia_flyinA_idle_playerA", 		"Militia_flyinA_idle_povA",			ViewConeRampBackRight )
	AddAnimGroupBlend( animGroup,	"deploy", 	"Militia_flyinB_exit_playerA", 		"Militia_flyinB_exit_povA",			ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "deploy" )

	//front left
	animGroup = CreateAnimGroup( "jumpQuick", "ORIGIN", "jump" )
	AddAnimGroupStart( animGroup, 	"idle", 	"Militia_flyinA_idle_playerB", 		"Militia_flyinA_idle_povB",			ViewConeRampFrontLeft )
	AddAnimGroupBlend( animGroup,	"deploy", 	"Militia_flyinB_exit_playerB", 		"Militia_flyinB_exit_povB",			ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "deploy" )

	//back left
	animGroup = CreateAnimGroup( "jumpQuick", "ORIGIN", "jump" )
	AddAnimGroupStart( animGroup, 	"idle", 	"Militia_flyinA_idle_playerC", 		"Militia_flyinA_idle_povC",			ViewConeRampBackLeft )
	AddAnimGroupBlend( animGroup,	"deploy", 	"Militia_flyinB_exit_playerC", 		"Militia_flyinB_exit_povC",			ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "deploy" )


//JUMP OUT GENERIC
	//AddAnimGroupBlend( animGroup, 	name, 		anim3rd, 							animFPS = null, 					animView = ViewConeFree, 	teleport = null, noParent = true, blend )
	//front right
	animGroup = CreateAnimGroup( "jumpGeneric", "ORIGIN", "jump" )
	AddAnimGroupStart( animGroup,	"deploy", 	"Militia_flyinB_exit_playerD", 		"Militia_flyinB_exit_povD",			ViewConeRampFrontRight )

	//back right
	animGroup = CreateAnimGroup( "jumpGeneric", "ORIGIN", "jump" )
	AddAnimGroupStart( animGroup,	"deploy", 	"Militia_flyinB_exit_playerA", 		"Militia_flyinB_exit_povA",			ViewConeRampBackRight )

	//front left
	animGroup = CreateAnimGroup( "jumpGeneric", "ORIGIN", "jump" )
	AddAnimGroupStart( animGroup,	"deploy", 	"Militia_flyinB_exit_playerB", 		"Militia_flyinB_exit_povB",			ViewConeRampFrontLeft )

	//back left
	animGroup = CreateAnimGroup( "jumpGeneric", "ORIGIN", "jump" )
	AddAnimGroupStart( animGroup,	"deploy", 	"Militia_flyinB_exit_playerC", 		"Militia_flyinB_exit_povC",			ViewConeRampBackLeft )



//JUMP OUT FRANTIC
	//AddAnimGroupBlend( animGroup, 	name, 		anim3rd, 							animFPS = null, 					animView = ViewConeFree, 	teleport = null, noParent = true, blend )
	//front right
	animGroup = CreateAnimGroup( "jump_frantic", "ORIGIN", "jump" )
	AddAnimGroupStart( animGroup, 	"flyin", 	"Militia_O2_flyinA_playlerA", 		"Militia_O2_flyinA_povA",			ViewConeRampFrontRight )
	AddAnimGroupBlend( animGroup,	"deploy", 	"Militia_flyinB_exit_playerD", 		"Militia_flyinB_exit_povD",			ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "deploy" )

	//back right
	animGroup = CreateAnimGroup( "jump_frantic", "ORIGIN", "jump" )
	AddAnimGroupStart( animGroup, 	"flyin", 	"Militia_O2_flyinA_playlerD", 		"Militia_O2_flyinA_povD",			ViewConeRampBackRight )
	AddAnimGroupBlend( animGroup,	"deploy", 	"Militia_flyinB_exit_playerA", 		"Militia_flyinB_exit_povA",			ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "deploy" )

	//front left
	animGroup = CreateAnimGroup( "jump_frantic", "ORIGIN", "jump" )
	AddAnimGroupStart( animGroup, 	"flyin", 	"Militia_O2_flyinA_playlerB", 		"Militia_O2_flyinA_povB",			ViewConeRampFrontLeft )
	AddAnimGroupBlend( animGroup,	"deploy", 	"Militia_flyinB_exit_playerB", 		"Militia_flyinB_exit_povB",			ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "deploy" )

	//back left
	animGroup = CreateAnimGroup( "jump_frantic", "ORIGIN", "jump" )
	AddAnimGroupStart( animGroup, 	"flyin", 	"Militia_O2_flyinA_playlerC", 		"Militia_O2_flyinA_povC",			ViewConeRampBackLeft )
	AddAnimGroupBlend( animGroup,	"deploy", 	"Militia_flyinB_exit_playerC", 		"Militia_flyinB_exit_povC",			ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "deploy" )

//CRASH SPIN
	//AddAnimGroupBlend( animGroup, 	name, 		anim3rd, 							animFPS = null, 					animView = ViewConeFree, 	teleport = null, noParent = true, blend )
	//front right
	animGroup = CreateAnimGroup( "frantic_crashSpin", "ORIGIN", "crash" )
	AddAnimGroupStart( animGroup, 	"flyin", 	"Militia_O2_flyinA_playlerA", 		"Militia_O2_flyinA_povA",			ViewConeRampFrontRight )
	AddAnimGroupBlend( animGroup,	"crash", 	"pt_o2_Militia_crashA", 			"ptpov_o2_Militia_crashA",			ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "crash" )
	AddAnimGroupBlend( animGroup,	"wake", 	"pt_o2_Militia_postCrashA", 		"ptpov_o2_Militia_postCrashA",		ViewConeZeroInstant )
	SetAnimSyncWithRef( animGroup, "wake" )
	SetAnimTeleport( animGroup, "wake" )
	SetAnimHideProxy( animGroup, "wake", false )

	//back right
	animGroup = CreateAnimGroup( "frantic_crashSpin", "ORIGIN", "crash" )
	AddAnimGroupStart( animGroup, 	"flyin", 	"Militia_O2_flyinA_playlerD", 		"Militia_O2_flyinA_povD",			ViewConeRampBackRight )
	AddAnimGroupBlend( animGroup,	"crash", 	"pt_o2_Militia_crashB", 			"ptpov_o2_Militia_crashB",			ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "crash" )
	AddAnimGroupBlend( animGroup,	"wake", 	"pt_o2_Militia_postCrashB", 		"ptpov_o2_Militia_postCrashB",		ViewConeZeroInstant )
	SetAnimSyncWithRef( animGroup, "wake" )
	SetAnimTeleport( animGroup, "wake" )
	SetAnimHideProxy( animGroup, "wake", false )

	//front left
	animGroup = CreateAnimGroup( "frantic_crashSpin", "ORIGIN", "crash" )
	AddAnimGroupStart( animGroup, 	"flyin", 	"Militia_O2_flyinA_playlerB", 		"Militia_O2_flyinA_povB",			ViewConeRampFrontLeft )
	AddAnimGroupBlend( animGroup,	"crash", 	"pt_o2_Militia_crashC", 			"ptpov_o2_Militia_crashC",			ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "crash" )
	AddAnimGroupBlend( animGroup,	"wake", 	"pt_o2_Militia_postCrashD", 		"ptpov_o2_Militia_postCrashD",		ViewConeZeroInstant )
	SetAnimSyncWithRef( animGroup, "wake" )
	SetAnimTeleport( animGroup, "wake" )
	SetAnimHideProxy( animGroup, "wake", false )

	//back left
	animGroup = CreateAnimGroup( "frantic_crashSpin", "ORIGIN", "crash" )
	AddAnimGroupStart( animGroup, 	"flyin", 	"Militia_O2_flyinA_playlerC", 		"Militia_O2_flyinA_povC",			ViewConeRampBackLeft )
	AddAnimGroupBlend( animGroup,	"crash", 	"pt_o2_Militia_crashD", 			"ptpov_o2_Militia_crashD",			ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "crash" )
	AddAnimGroupBlend( animGroup,	"wake", 	"pt_o2_Militia_postCrashC", 		"ptpov_o2_Militia_postCrashC",		ViewConeZeroInstant )
	SetAnimSyncWithRef( animGroup, "wake" )
	SetAnimTeleport( animGroup, "wake" )
	SetAnimHideProxy( animGroup, "wake", false )

//CRASH ROLL
	//AddAnimGroupBlend( animGroup, 	name, 		anim3rd, 							animFPS = null, 					animView = ViewConeFree, 	teleport = null, noParent = true, blend )
	//front right
	animGroup = CreateAnimGroup( "frantic_crashRoll", "ORIGIN", "crash" )
	AddAnimGroupStart( animGroup, 	"flyin", 	"Militia_O2_flyinA_playlerA", 		"Militia_O2_flyinA_povA",			ViewConeRampFrontRight )
	AddAnimGroupBlend( animGroup,	"crash", 	"pt_o2_Militia_crashE", 			"ptpov_o2_Militia_crashE",			ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "crash" )
	AddAnimGroupBlend( animGroup,	"wake", 	"pt_o2_Militia_postCrashE", 		"ptpov_o2_Militia_postCrashE",		ViewConeZeroInstant )
	SetAnimSyncWithRef( animGroup, "wake" )
	SetAnimTeleport( animGroup, "wake" )
	SetAnimHideProxy( animGroup, "wake", false )

	//back right
	animGroup = CreateAnimGroup( "frantic_crashRoll", "ORIGIN", "crash" )
	AddAnimGroupStart( animGroup, 	"flyin", 	"Militia_O2_flyinA_playlerD", 		"Militia_O2_flyinA_povD",			ViewConeRampBackRight )
	AddAnimGroupBlend( animGroup,	"crash", 	"pt_o2_Militia_crashF", 			"ptpov_o2_Militia_crashF",			ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "crash" )
	AddAnimGroupBlend( animGroup,	"wake", 	"pt_o2_Militia_postCrashF", 		"ptpov_o2_Militia_postCrashF",		ViewConeZeroInstant )
	SetAnimSyncWithRef( animGroup, "wake" )
	SetAnimTeleport( animGroup, "wake" )
	SetAnimHideProxy( animGroup, "wake", false )

	//front left
	animGroup = CreateAnimGroup( "frantic_crashRoll", "ORIGIN", "crash" )
	AddAnimGroupStart( animGroup, 	"flyin", 	"Militia_O2_flyinA_playlerB", 		"Militia_O2_flyinA_povB",			ViewConeRampFrontLeft )
	AddAnimGroupBlend( animGroup,	"crash", 	"pt_o2_Militia_crashG", 			"ptpov_o2_Militia_crashG",			ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "crash" )
	AddAnimGroupBlend( animGroup,	"wake", 	"pt_o2_Militia_postCrashG", 		"ptpov_o2_Militia_postCrashG",		ViewConeZeroInstant )
	SetAnimSyncWithRef( animGroup, "wake" )
	SetAnimTeleport( animGroup, "wake" )
	SetAnimHideProxy( animGroup, "wake", false )

	//back left
	animGroup = CreateAnimGroup( "frantic_crashRoll", "ORIGIN", "crash" )
	AddAnimGroupStart( animGroup, 	"flyin", 	"Militia_O2_flyinA_playlerC", 		"Militia_O2_flyinA_povC",			ViewConeRampBackLeft )
	AddAnimGroupBlend( animGroup,	"crash", 	"pt_o2_Militia_crashH", 			"ptpov_o2_Militia_crashH",			ViewConeRampFree )
	SetAnimSyncWithRef( animGroup, "crash" )
	AddAnimGroupBlend( animGroup,	"wake", 	"pt_o2_Militia_postCrashH", 		"ptpov_o2_Militia_postCrashH",		ViewConeZeroInstant )
	SetAnimSyncWithRef( animGroup, "wake" )
	SetAnimTeleport( animGroup, "wake" )
	SetAnimHideProxy( animGroup, "wake", false )

//RESCUE RAMP
//NOTE: These animations enable player's weapons at the end of the animation through qc events
	animGroup = CreateAnimGroup( "rescueRamp", "RESCUE", "evac" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"pt_e3_rescue_side_embark_A", 		"ptpov_e3_rescue_side_embark_A", 		ViewConeFree )
	SetAnimNoParent( animGroup,	"deploy", false )
	SetAnimBlendTime( animGroup, "deploy", 0.75 )
	AddAnimGroupBlend( animGroup, 	"idle", 	"pt_e3_rescue_side_idle_A",			"ptpov_e3_rescue_side_embark_A_idle", 	ViewConeFree )
	AddAnimCustomFuncs( animGroup, "idle", EnableWeaponWhileInCinematic )

	animGroup = CreateAnimGroup( "rescueRamp", "RESCUE", "evac" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"pt_e3_rescue_side_embark_B", 		"ptpov_e3_rescue_side_embark_B", 		ViewConeFree )
	SetAnimNoParent( animGroup,	"deploy", false )
	SetAnimBlendTime( animGroup, "deploy", 0.75 )
	AddAnimGroupBlend( animGroup, 	"idle", 	"pt_e3_rescue_side_idle_B",			"ptpov_e3_rescue_side_embark_B_idle", 	ViewConeFree )
	AddAnimCustomFuncs( animGroup, "idle", EnableWeaponWhileInCinematic )

	animGroup = CreateAnimGroup( "rescueRamp", "RESCUE", "evac" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"pt_e3_rescue_side_embark_C", 		"ptpov_e3_rescue_side_embark_C", 		ViewConeFree )
	SetAnimNoParent( animGroup,	"deploy", false )
	SetAnimBlendTime( animGroup, "deploy", 0.75 )
	AddAnimGroupBlend( animGroup, 	"idle", 	"pt_e3_rescue_side_idle_C",			"ptpov_e3_rescue_side_embark_C_idle", 	ViewConeFree )
	AddAnimCustomFuncs( animGroup, "idle", EnableWeaponWhileInCinematic )

	animGroup = CreateAnimGroup( "rescueRamp", "RESCUE", "evac" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"pt_e3_rescue_side_embark_D", 		"ptpov_e3_rescue_side_embark_D", 		ViewConeFree )
	SetAnimNoParent( animGroup,	"deploy", false )
	SetAnimBlendTime( animGroup, "deploy", 0.75 )
	AddAnimGroupBlend( animGroup, 	"idle", 	"pt_e3_rescue_side_idle_D",			"ptpov_e3_rescue_side_embark_D_idle", 	ViewConeFree )
	AddAnimCustomFuncs( animGroup, "idle", EnableWeaponWhileInCinematic )

	animGroup = CreateAnimGroup( "rescueRamp", "RESCUE", "evac" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"pt_e3_rescue_side_embark_E", 		"ptpov_e3_rescue_side_embark_E", 		ViewConeFree )
	SetAnimNoParent( animGroup,	"deploy", false )
	SetAnimBlendTime( animGroup, "deploy", 0.75 )
	AddAnimGroupBlend( animGroup, 	"idle", 	"pt_e3_rescue_side_idle_E",			"ptpov_e3_rescue_side_embark_E_idle", 	ViewConeFree )
	AddAnimCustomFuncs( animGroup, "idle", EnableWeaponWhileInCinematic )

	animGroup = CreateAnimGroup( "rescueRamp", "RESCUE", "evac" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"pt_e3_rescue_side_embark_F", 		"ptpov_e3_rescue_side_embark_F", 		ViewConeFree )
	SetAnimNoParent( animGroup,	"deploy", false )
	SetAnimBlendTime( animGroup, "deploy", 0.75 )
	AddAnimGroupBlend( animGroup, 	"idle", 	"pt_e3_rescue_side_idle_F",			"ptpov_e3_rescue_side_embark_F_idle", 	ViewConeFree )
	AddAnimCustomFuncs( animGroup, "idle", EnableWeaponWhileInCinematic )

	animGroup = CreateAnimGroup( "rescueRamp", "RESCUE", "evac" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"pt_e3_rescue_side_embark_G", 		"ptpov_e3_rescue_side_embark_G", 		ViewConeFree )
	SetAnimNoParent( animGroup,	"deploy", false )
	SetAnimBlendTime( animGroup, "deploy", 0.75 )
	AddAnimGroupBlend( animGroup, 	"idle", 	"pt_e3_rescue_side_idle_G",			"ptpov_e3_rescue_side_embark_G_idle", 	ViewConeFree )
	AddAnimCustomFuncs( animGroup, "idle", EnableWeaponWhileInCinematic )

	animGroup = CreateAnimGroup( "rescueRamp", "RESCUE", "evac" )
	AddAnimGroupBlend( animGroup,	"deploy", 	"pt_e3_rescue_side_embark_H", 		"ptpov_e3_rescue_side_embark_H", 		ViewConeFree )
	SetAnimNoParent( animGroup,	"deploy", false )
	SetAnimBlendTime( animGroup, "deploy", 0.75 )
	AddAnimGroupBlend( animGroup, 	"idle", 	"pt_e3_rescue_side_idle_H",			"ptpov_e3_rescue_side_embark_H_idle", 	ViewConeFree )
	AddAnimCustomFuncs( animGroup, "idle", EnableWeaponWhileInCinematic )

//DROPPOD BRIDGE R
	//AddAnimGroupBlend( animGroup, 	name, 		anim3rd, 								animFPS = null, 					animView = ViewConeFree, 	teleport = null, noParent = true, blend )
	//front right
	animGroup = CreateAnimGroup( "dpBridgeR", "TurretAttach", "droppod" )
	AddAnimGroupStart( animGroup, 	"timing",		"pt_droppod_ready_front_R", 		"ptpov_droppod_ready_front_R",		ViewConeFreeLookingForward )
	AddAnimGroupStart( animGroup, 	"idle",			"pt_droppod_ready_front_R", 		"ptpov_droppod_ready_front_R",		ViewConeFreeLookingForward )
	SetAnimSyncWithRef( animGroup, "idle" )
	AddAnimGroupBlend( animGroup, 	"dpIdle", 		"pt_droppod_ride_space_front_R",	"ptpov_droppod_ride_space_front_R",	ViewConeDropPodFrontR )
	SetAnimSyncWithRef( animGroup, "dpIdle" )
	SetAnimHideProxy( animGroup, "dpIdle", false )
	AddAnimGroupBlend( animGroup, 	"dropIdle", 	"pt_droppod_ride_atmos_front_R", 	"ptpov_droppod_ride_atmos_front_R",	ViewConeDropPodFrontR )
	SetAnimSyncWithRef( animGroup, "dropIdle" )
	SetAnimHideProxy( animGroup, "dropIdle", false )
	AddAnimGroupBlend( animGroup, 	"deploy", 		"pt_droppod_exit_front_R", 			"ptpov_droppod_exit_front_R",		ViewConeTight )
	SetAnimSyncWithRef( animGroup, "deploy" )
	SetAnimHideProxy( animGroup, "deploy", false )
	SetAnimRenderWithViewModels( animGroup, "dropIdle" )
	SetAnimRenderWithViewModels( animGroup, "deploy" )

	//front left
	animGroup = CreateAnimGroup( "dpBridgeR", "TurretAttach", "droppod" )
	AddAnimGroupStart( animGroup, 	"timing",		"pt_droppod_ready_front_L", 		"ptpov_droppod_ready_front_L",		ViewConeFreeLookingForward )
	AddAnimGroupStart( animGroup, 	"idle",			"pt_droppod_ready_front_L", 		"ptpov_droppod_ready_front_L",		ViewConeFreeLookingForward )
	SetAnimSyncWithRef( animGroup, "idle" )
	AddAnimGroupBlend( animGroup, 	"dpIdle", 		"pt_droppod_ride_space_front_L", 	"ptpov_droppod_ride_space_front_L",	ViewConeDropPodFrontL )
	SetAnimSyncWithRef( animGroup, "dpIdle" )
	SetAnimHideProxy( animGroup, "dpIdle", false )
	AddAnimGroupBlend( animGroup, 	"dropIdle", 	"pt_droppod_ride_atmos_front_L", 	"ptpov_droppod_ride_atmos_front_L",	ViewConeDropPodFrontL )
	SetAnimSyncWithRef( animGroup, "dropIdle" )
	SetAnimHideProxy( animGroup, "dropIdle", false )
	AddAnimGroupBlend( animGroup, 	"deploy", 		"pt_droppod_exit_front_L", 			"ptpov_droppod_exit_front_L",		ViewConeTight )
	SetAnimSyncWithRef( animGroup, "deploy" )
	SetAnimHideProxy( animGroup, "deploy", false )
	SetAnimRenderWithViewModels( animGroup, "dropIdle" )
	SetAnimRenderWithViewModels( animGroup, "deploy" )

	//back left
	animGroup = CreateAnimGroup( "dpBridgeR", "TurretAttach", "droppod" )
	AddAnimGroupStart( animGroup, 	"timing",		"pt_droppod_ready_back_L", 			"ptpov_droppod_drop_back_L",		ViewConeFreeLookingForward )
	AddAnimGroupStart( animGroup, 	"idle",			"pt_droppod_ready_back_L", 			"ptpov_droppod_drop_back_L",		ViewConeFreeLookingForward )
	SetAnimSyncWithRef( animGroup, "idle" )
	AddAnimGroupBlend( animGroup, 	"dpIdle", 		"pt_droppod_ride_space_back_L", 	"ptpov_droppod_ride_space_back_L",	ViewConeDropPodBackL )
	SetAnimSyncWithRef( animGroup, "dpIdle" )
	SetAnimHideProxy( animGroup, "dpIdle", false )
	AddAnimGroupBlend( animGroup, 	"dropIdle", 	"pt_droppod_ride_atmos_back_L", 	"ptpov_droppod_ride_atmos_back_L",	ViewConeDropPodBackL )
	SetAnimSyncWithRef( animGroup, "dropIdle" )
	SetAnimHideProxy( animGroup, "dropIdle", false )
	AddAnimGroupBlend( animGroup, 	"deploy", 		"pt_droppod_exit_back_L", 			"ptpov_droppod_exit_back_L",		ViewConeTight )
	SetAnimSyncWithRef( animGroup, "deploy" )
	SetAnimHideProxy( animGroup, "deploy", false )
	SetAnimRenderWithViewModels( animGroup, "dropIdle" )
	SetAnimRenderWithViewModels( animGroup, "deploy" )

	//back right
	animGroup = CreateAnimGroup( "dpBridgeR", "TurretAttach", "droppod" )
	AddAnimGroupStart( animGroup, 	"timing",		"pt_droppod_ready_back_R", 			"ptpov_droppod_drop_back_R",		ViewConeFreeLookingForward )
	AddAnimGroupStart( animGroup, 	"idle",			"pt_droppod_ready_back_R", 			"ptpov_droppod_drop_back_R",		ViewConeFreeLookingForward )
	SetAnimSyncWithRef( animGroup, "idle" )
	AddAnimGroupBlend( animGroup, 	"dpIdle", 		"pt_droppod_ride_space_back_R", 	"ptpov_droppod_ride_space_back_R",	ViewConeDropPodBackR )
	SetAnimSyncWithRef( animGroup, "dpIdle" )
	SetAnimHideProxy( animGroup, "dpIdle", false )
	AddAnimGroupBlend( animGroup, 	"dropIdle", 	"pt_droppod_ride_atmos_back_R", 	"ptpov_droppod_ride_atmos_back_R",	ViewConeDropPodBackR )
	SetAnimSyncWithRef( animGroup, "dropIdle" )
	SetAnimHideProxy( animGroup, "dropIdle", false )
	AddAnimGroupBlend( animGroup, 	"deploy", 		"pt_droppod_exit_back_R", 			"ptpov_droppod_exit_back_R",		ViewConeTight )
	SetAnimSyncWithRef( animGroup, "deploy" )
	SetAnimHideProxy( animGroup, "deploy", false )
	SetAnimRenderWithViewModels( animGroup, "dropIdle" )
	SetAnimRenderWithViewModels( animGroup, "deploy" )

//DROPPOD BRIDGE L
	//front right
	animGroup = CreateAnimGroup( "dpBridgeL", "TurretAttach", "droppod" )
	AddAnimGroupStart( animGroup, 	"timing",		"pt_droppod_ready_front_R", 		"ptpov_droppod_ready_front_R",		ViewConeFreeLookingForward )
	AddAnimGroupStart( animGroup, 	"idle",			"pt_droppod_ready_front_R", 		"ptpov_droppod_ready_front_R",		ViewConeFreeLookingForward )
	SetAnimSyncWithRef( animGroup, "idle" )
	AddAnimGroupBlend( animGroup, 	"dpIdle", 		"pt_droppod_ride_space_front_R",	"ptpov_droppod_ride_space_front_R",	ViewConeDropPodFrontR )
	SetAnimSyncWithRef( animGroup, "dpIdle" )
	SetAnimHideProxy( animGroup, "dpIdle", false )
	AddAnimGroupBlend( animGroup, 	"dropIdle", 	"pt_droppod_ride_atmos_front_R", 	"ptpov_droppod_ride_atmos_front_R",	ViewConeDropPodFrontR )
	SetAnimSyncWithRef( animGroup, "dropIdle" )
	SetAnimHideProxy( animGroup, "dropIdle", false )
	AddAnimGroupBlend( animGroup, 	"deploy", 		"pt_droppod_exit_front_R", 			"ptpov_droppod_exit_front_R",		ViewConeTight )
	SetAnimSyncWithRef( animGroup, "deploy" )
	SetAnimHideProxy( animGroup, "deploy", false )
	SetAnimRenderWithViewModels( animGroup, "dropIdle" )
	SetAnimRenderWithViewModels( animGroup, "deploy" )

	//front left
	animGroup = CreateAnimGroup( "dpBridgeL", "TurretAttach", "droppod" )
	AddAnimGroupStart( animGroup, 	"timing",		"pt_droppod_ready_front_L", 		"ptpov_droppod_ready_front_L",		ViewConeFreeLookingForward )
	AddAnimGroupStart( animGroup, 	"idle",			"pt_droppod_ready_front_L", 		"ptpov_droppod_ready_front_L",		ViewConeFreeLookingForward )
	SetAnimSyncWithRef( animGroup, "idle" )
	AddAnimGroupBlend( animGroup, 	"dpIdle", 		"pt_droppod_ride_space_front_L", 	"ptpov_droppod_ride_space_front_L",	ViewConeDropPodFrontL )
	SetAnimSyncWithRef( animGroup, "dpIdle" )
	SetAnimHideProxy( animGroup, "dpIdle", false )
	AddAnimGroupBlend( animGroup, 	"dropIdle", 	"pt_droppod_ride_atmos_front_L", 	"ptpov_droppod_ride_atmos_front_L",	ViewConeDropPodFrontL )
	SetAnimSyncWithRef( animGroup, "dropIdle" )
	SetAnimHideProxy( animGroup, "dropIdle", false )
	AddAnimGroupBlend( animGroup, 	"deploy", 		"pt_droppod_exit_front_L", 			"ptpov_droppod_exit_front_L",		ViewConeTight )
	SetAnimSyncWithRef( animGroup, "deploy" )
	SetAnimHideProxy( animGroup, "deploy", false )
	SetAnimRenderWithViewModels( animGroup, "dropIdle" )
	SetAnimRenderWithViewModels( animGroup, "deploy" )

	//back right
	animGroup = CreateAnimGroup( "dpBridgeL", "TurretAttach", "droppod" )
	AddAnimGroupStart( animGroup, 	"timing",		"pt_droppod_ready_back_R", 			"ptpov_droppod_drop_back_R",		ViewConeFreeLookingForward )
	AddAnimGroupStart( animGroup, 	"idle",			"pt_droppod_ready_back_R", 			"ptpov_droppod_drop_back_R",		ViewConeFreeLookingForward )
	SetAnimSyncWithRef( animGroup, "idle" )
	AddAnimGroupBlend( animGroup, 	"dpIdle", 		"pt_droppod_ride_space_back_R", 	"ptpov_droppod_ride_space_back_R",	ViewConeDropPodBackR )
	SetAnimSyncWithRef( animGroup, "dpIdle" )
	SetAnimHideProxy( animGroup, "dpIdle", false )
	AddAnimGroupBlend( animGroup, 	"dropIdle", 	"pt_droppod_ride_atmos_back_R", 	"ptpov_droppod_ride_atmos_back_R",	ViewConeDropPodBackR )
	SetAnimSyncWithRef( animGroup, "dropIdle" )
	SetAnimHideProxy( animGroup, "dropIdle", false )
	AddAnimGroupBlend( animGroup, 	"deploy", 		"pt_droppod_exit_back_R", 			"ptpov_droppod_exit_back_R",		ViewConeTight )
	SetAnimSyncWithRef( animGroup, "deploy" )
	SetAnimHideProxy( animGroup, "deploy", false )
	SetAnimRenderWithViewModels( animGroup, "dropIdle" )
	SetAnimRenderWithViewModels( animGroup, "deploy" )

	//back left
	animGroup = CreateAnimGroup( "dpBridgeL", "TurretAttach", "droppod" )
	AddAnimGroupStart( animGroup, 	"timing",		"pt_droppod_ready_back_L", 			"ptpov_droppod_drop_back_L",		ViewConeFreeLookingForward )
	AddAnimGroupStart( animGroup, 	"idle",			"pt_droppod_ready_back_L", 			"ptpov_droppod_drop_back_L",		ViewConeFreeLookingForward )
	SetAnimSyncWithRef( animGroup, "idle" )
	AddAnimGroupBlend( animGroup, 	"dpIdle", 		"pt_droppod_ride_space_back_L", 	"ptpov_droppod_ride_space_back_L",	ViewConeDropPodBackL )
	SetAnimSyncWithRef( animGroup, "dpIdle" )
	SetAnimHideProxy( animGroup, "dpIdle", false )
	AddAnimGroupBlend( animGroup, 	"dropIdle", 	"pt_droppod_ride_atmos_back_L", 	"ptpov_droppod_ride_atmos_back_L",	ViewConeDropPodBackL )
	SetAnimSyncWithRef( animGroup, "dropIdle" )
	SetAnimHideProxy( animGroup, "dropIdle", false )
	AddAnimGroupBlend( animGroup, 	"deploy", 		"pt_droppod_exit_back_L", 			"ptpov_droppod_exit_back_L",		ViewConeTight )
	SetAnimSyncWithRef( animGroup, "deploy" )
	SetAnimHideProxy( animGroup, "deploy", false )
	SetAnimRenderWithViewModels( animGroup, "dropIdle" )
	SetAnimRenderWithViewModels( animGroup, "deploy" )
}

function EnableWeaponWhileInCinematic( slot, player )
{
	if ( !IsValid( player ) )
		return

	if( !player.IsPlayer() )
		return

	if ( ( "doNotReturnWeaponViewModel" in player.s ) && player.s.doNotReturnWeaponViewModel )
		return

	player.EnableWeapon()
	player.EnableWeaponViewModel()
}


function CreateAnimGroup( style, attachment, type )
{
	if ( !( style in level.cinematicAnimGroups ) )
		level.cinematicAnimGroups[ style ] <- []

	local template = {}
	template.style		<- style
	template.type		<- type
	template.seat 		<- level.cinematicAnimGroups[ style ].len()
	template.attach 	<- attachment

	local seat = []
	level.cinematicAnimGroups[ style ].append( seat )

	return template
}

function AddAnimGroupBlend( template, name, anim3rd, animFPS = null, animView = null )
{
	if ( animView == null )
		animView = ViewConeFree

	local sequence 	= CreateFirstPersonSequence()

	sequence.firstPersonAnim	= animFPS
	sequence.thirdPersonAnim 	= anim3rd
	sequence.attachment 		= template.attach
	sequence.viewConeFunction	= animView

	sequence.blendTime			= DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME
	sequence.teleport			= null
	sequence.noParent			= true
	sequence.hideProxy			= true

	sequence.name				<- name
	sequence.style				<- template.style		//the specific name of the anim set( jump, jump_right, jump_frantic, etc )
	sequence.type				<- template.type		//the type of the group ( jumping out of dropship, droppod from bridge, ziplining from dropship, etc )
	sequence.syncWithRef		<- false				//whether this anim should sync up with the start of the ref ( dropship's ) anim
	sequence.syncWithRefSignal	<- null					//by default syncing with the ref means just waiting for the next anim to start. If this is set, it waits for a specific signal
	sequence.proceduralLength 	<- false				//whether this anim idles until the system tells it go ( based on the "dropship_deploy" notetrack on the ref )
	sequence.proceduralLengthAdjustment	<- null			//an adjustment for the procedural length ( to skip to the next anim early or late )
	sequence.customSlotFuncs	<- []					//an array of custom functions to run during this sequence

	local style 	= template.style
	local seat		= template.seat
	level.cinematicAnimGroups[ style ][ seat ].append( sequence )
}

function AddAnimGroupStart( template, name, anim3rd, animFPS = null, animView = null )
{
	if ( animView == null )
		animView = ViewConeFree

	AddAnimGroupBlend( template, name, anim3rd, animFPS, animView )

	SetAnimTeleport( template, name )
	SetAnimBlendTime( template, name, 0.0 )
	SetAnimNoParent( template, name, false )
}

function SetAnimSyncWithRef( template, name, syncWithRef = true, signal = null )
{
	local style 	= template.style
	local seat		= template.seat
	local sequence 	= GetAnimGroupSequence( style, seat, name )

	sequence.syncWithRef = syncWithRef
	sequence.syncWithRefSignal = signal
}

function SetAnimProceduralLength( template, name, proceduralLength )
{
	local style 	= template.style
	local seat		= template.seat
	local sequence 	= GetAnimGroupSequence( style, seat, name )

	sequence.proceduralLength = proceduralLength
}

function SetAnimProceduralLengthAdjustment( template, name, proceduralLengthAdjustment = true )
{
	local style 	= template.style
	local seat		= template.seat
	local sequence 	= GetAnimGroupSequence( style, seat, name )

	sequence.proceduralLengthAdjustment = proceduralLengthAdjustment
}

function SetAnimTeleport( template, name, teleport = true )
{
	local style 	= template.style
	local seat		= template.seat
	local sequence 	= GetAnimGroupSequence( style, seat, name )

	if ( !teleport )
		sequence.teleport = null
	else
		sequence.teleport = teleport
}

function SetAnimBlendTime( template, name, blendTime = DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME )
{
	local style 	= template.style
	local seat		= template.seat
	local sequence 	= GetAnimGroupSequence( style, seat, name )

	sequence.blendTime = blendTime
}

function SetAnimNoParent( template, name, noParent = true )
{
	local style 	= template.style
	local seat		= template.seat
	local sequence 	= GetAnimGroupSequence( style, seat, name )

	if ( !noParent )
		sequence.noParent = null
	else
		sequence.noParent = noParent
}

function SetAnimEnablePlanting( template, name, enablePlanting = true )
{
	local style 	= template.style
	local seat		= template.seat
	local sequence 	= GetAnimGroupSequence( style, seat, name )

	if ( !enablePlanting )
		sequence.enablePlanting = null
	else
		sequence.enablePlanting = enablePlanting

}

function SetAnimHideProxy( template, name, hideProxy = true )
{
	local style 	= template.style
	local seat		= template.seat
	local sequence 	= GetAnimGroupSequence( style, seat, name )

	if ( !hideProxy )
		sequence.hideProxy = null
	else
		sequence.hideProxy	= hideProxy
}

function SetAnimRenderWithViewModels( template, name, render = true )
{
	local style 	= template.style
	local seat		= template.seat
	local sequence 	= GetAnimGroupSequence( style, seat, name )

	sequence.renderWithViewModels = render
}

function AddAnimCustomFuncs( template, name, func )
{
	local style 	= template.style
	local seat		= template.seat
	local sequence 	= GetAnimGroupSequence( style, seat, name )

	sequence.customSlotFuncs.append( func )
}

function GetAnimGroupAllSeats( style )
{
	Assert( style in level.cinematicAnimGroups, "Unhandled dropship anim style " + style )

	return level.cinematicAnimGroups[ style ]
}

function GetAnimGroupSequences( style, seat )
{
	Assert( style in level.cinematicAnimGroups, "Unhandled dropship anim style " + style )
	Assert( seat in level.cinematicAnimGroups[ style ], "Unhandled seat[ " + seat + " ] for dropship anim type: " + style )

	return level.cinematicAnimGroups[ style ][ seat ]
}

function HasAnimGroupSequence( style, seat, name )
{
	local seatSequences = GetAnimGroupSequences( style, seat )

	foreach ( sequence in seatSequences )
	{
		if ( sequence.name == name  )
			return sequence
	}

	return null
}

function GetAnimGroupSequence( style, seat, name )
{
	local sequence = HasAnimGroupSequence( style, seat, name )
	Assert( sequence, "sequence: [ " + name + " ] not found for seat[ " + seat + " ] for dropship anim type: " + style )

	return sequence
}

function GetAnimGroupType( style, seat )
{
	local sequences = GetAnimGroupSequences( style, seat )
	Assert( sequences.len() )

	return sequences[ 0 ].type
}

function GetAnimGroup3rd( style, seat, name )
{
	return GetAnimGroupSequence( style, seat, name ).thirdPersonAnim
}

function GetAnimGroupFPS( style, seat, name )
{
	return GetAnimGroupSequence( style, seat, name ).firstPersonAnim
}

function GetAnimGroupView( style, seat, name )
{
	return GetAnimGroupSequence( style, seat, name ).viewConeFunction
}

function GetAnimGroupBlendTime( style, seat, name )
{
	return GetAnimGroupSequence( style, seat, name ).blendTime
}

function GetAnimGroupTeleport( style, seat, name )
{
	return GetAnimGroupSequence( style, seat, name ).teleport
}

function GetAnimGroupNoParent( style, seat, name )
{
	return GetAnimGroupSequence( style, seat, name ).noParent
}

function GetAnimGroupAttachment( style, seat, name )
{
	return GetAnimGroupSequence( style, seat, name ).attachment
}

function GetAnimGroupProceduralLength( style, seat, name )
{
	return GetAnimGroupSequence( style, seat, name ).proceduralLength
}

function SetSequenceViewCone( animView, style, seat, name )
{
	local sequence 	= GetAnimGroupSequence( style, seat, name )
	sequence.viewConeFunction	= animView
}