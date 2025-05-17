function main() {
    
}

function EntitiesDidLoad() {
    if ( !IsServer() )
		return
    
    switch(GameRules.GetGameMode()) {
        case "cp":
            SetupHardpointMode()
            break
    }
}

function SetupHardpointMode() {
    // remove this when mode is playable
	if( GetDeveloperLevel() < 1 )
	{
		return
	}

	// See maps/mp_box_script.ent for creation of these ents
	local hardpointA = GetEnt( "hardpoint_A" )
	local hardpointB = GetEnt( "hardpoint_B" )
	local hardpointC = GetEnt( "hardpoint_C" )
    // capture triggers
	local triggerHardpointA = GetEnt( "trigger_hardpoint_A_target" )
	local triggerHardpointB = GetEnt( "trigger_hardpoint_B_target" )
	local triggerHardpointC = GetEnt( "trigger_hardpoint_C_target" )
    
    // MOVE THEM
    hardpointA.SetOrigin( Vector( -256.153900, -2050.634033, 0.031250 ) )
    triggerHardpointA.SetOrigin( Vector( -256.153900, -2243.634033, 0.031250 ) )
    hardpointC.SetOrigin( Vector( 257.883759, 1022.805725, 0.031250 ) )
    triggerHardpointC.SetOrigin( Vector( 257.883759, 1222.805725, 0.031250 ))

    // assault points
    local BOX_ASSAULTPOINTS_A = [
        { origin = Vector( 127.719559, -1023.319519, 0.031250 ), angles = Vector( 0, 0, 0 ) }
        { origin = Vector( 767.276123, -1021.955078, 0.031250 ), angles = Vector( 0, 0, 0 ) }
    ]
    local BOX_ASSAULTPOINTS_B = [
        { origin = Vector( 768.502930, -382.223450, 0.031250 ), angles = Vector( 0, 0, 0 ) }
        { origin = Vector( -768.474243, -385.433289, 0.031250 ), angles = Vector( 0, 0, 0 ) }
    ]
    local BOX_ASSAULTPOINTS_C = [
        { origin = Vector( -128.356796, 125.474632, 0.031250 ), angles = Vector( 0, 0, 0 ) }
        { origin = Vector( -768.711975, 126.185272, 0.031250 ), angles = Vector( 0, 0, 0 ) }
    ]
    // assault points (near)
    local BOX_ASSAULTPOINTS_NEAR_A = [
        { origin = Vector( 767.443542, -1985.338989, 0.031250 ), angles = Vector( 0, 0, 0 ) }
        { origin = Vector( 191.692825, -1858.399536, 0.031250 ), angles = Vector( 0, 0, 0 ) }
    ]
    local BOX_ASSAULTPOINTS_NEAR_B = [
        { origin = Vector( 386.902008, -384.707672, 0.031250 ), angles = Vector( 0, 0, 0 ) }
        { origin = Vector( -577.843872, -385.118988, 0.031250 ), angles = Vector( 0, 0, 0 ) }
    ]
    local BOX_ASSAULTPOINTS_NEAR_C = [
        { origin = Vector( -833.326050, 1024.425415, 0.031250 ), angles = Vector( 0, 0, 0 ) }
        { origin = Vector( -260.551208, 767.624329, 0.031250 ), angles = Vector( 0, 0, 0 ) }
    ]

    CreateAssaultPointFromArray(BOX_ASSAULTPOINTS_A, "hardpoint_A", false)
    CreateAssaultPointFromArray(BOX_ASSAULTPOINTS_B, "hardpoint_B", false)
    CreateAssaultPointFromArray(BOX_ASSAULTPOINTS_C, "hardpoint_C", false)
    CreateAssaultPointFromArray(BOX_ASSAULTPOINTS_NEAR_A, "hardpoint_A", true)
    CreateAssaultPointFromArray(BOX_ASSAULTPOINTS_NEAR_B, "hardpoint_B", true)
    CreateAssaultPointFromArray(BOX_ASSAULTPOINTS_NEAR_C, "hardpoint_C", true)

    FlagWait( "ReadyToStartMatch" )
}

main()