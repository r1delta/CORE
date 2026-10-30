// Temporary runtime fixture; removed after the v3 movement smoke.
::MV3Input <- 0
::MV3Source <- @"
if (Move_GetPhase() == MOVE_SETUP)
{
    Move_SetCheckpointMask(MOVE_CHECKPOINT_ALL);
    Move_SetIntState(0, Move_GetCustomButtons());
    local player = Move_GetPlayer();
    Move_SetIntState(12, player == (IsClient() ? GetLocalClientPlayer() : GetPlayerArray()[0]) ? 1 : 0);
    Move_SetIntState(13, IsValid(player) && player.IsPlayer() ? 1 : 0);
    Move_SetIntState(62, Move_GetIntState(62) + 1);
    Move_SetFloatState(63, Move_GetTime());
}
if (Move_GetPhase() >= MOVE_FRICTION)
    Move_SetIntState(Move_GetPhase(), Move_GetIntState(Move_GetPhase()) + 1);
"
Movement_Register( "v3.input", ::MV3Source, 64, "" )
if ( IsClient() )
    Movement_SetInputCallback( "v3.input", "MV3_Input" )
function MV3_Input() { Move_InputSetButtons( ::MV3Input ) }
::MV3DuckSource <- @"
if (Move_GetPhase() == MOVE_SETUP) Move_SetDuckDuration(200);
if (Move_GetPhase() == MOVE_FINISH) {
    Move_SetFloatState(0,Move_GetEyeOffset(MOVE_Z));
    Move_SetIntState(1,Move_GetDuckState());
}
"
Movement_Register("v3.duck",::MV3DuckSource,64,"")

function MV3_Ready()
{
    local player = IsClient() ? GetLocalClientPlayer() : GetPlayerArray()[0]
    printt( "MV3_READY " + Movement_GetApiVersion() + " " + Movement_IsAvailable() + " " + IsAlive(player) )
}

function MV3_EntityReport()
{
    local p=IsClient() ? GetLocalClientPlayer() : GetPlayerArray()[0]
    local name="v3.input"
    if(IsClient() ? !Movement_HasPresentation(name) : !Movement_HasPlayerState(p,name))
    { printt("MV3_ENTITY absent"); return }
    local identity=IsClient() ? Movement_GetPresentationInt(name,12) : Movement_GetPlayerStateInt(p,name,12)
    local valid=IsClient() ? Movement_GetPresentationInt(name,13) : Movement_GetPlayerStateInt(p,name,13)
    printt("MV3_ENTITY "+identity+" "+valid)
}
function MV3_OutsidePlayer()
{
    local rejected=false
    try { Move_GetPlayer() }
    catch(error)
    {
        rejected=error=="Movement access is only valid in a synchronous movement evaluation"
        if(!rejected) printt("MV3_OUTSIDE_UNEXPECTED "+error)
    }
    printt("MV3_OUTSIDE "+rejected)
}

function MV3_Report( name )
{
    local player = IsClient() ? GetLocalClientPlayer() : GetPlayerArray()[0]
    local present = IsClient() ? Movement_HasPresentation(name) : Movement_HasPlayerState(player,name)
    local origin = player.GetOrigin()
    local velocity = player.GetVelocity()
    printt( "MV3_POSE " + origin.x + " " + origin.y + " " + origin.z + " " + velocity.x + " " + velocity.y + " " + velocity.z + " " + player.IsOnGround() )
    printt( "MV3_PRESENT " + present )
    if ( !present ) return
    local command = IsClient() ? Movement_GetPresentationCommand(name) : Movement_GetPlayerStateCommand(player,name)
    local session = IsClient() ? Movement_GetPresentationSession(name) : Movement_GetPlayerStateSession(player,name)
    local result = "MV3_STATE " + command + " " + session
    foreach ( slot in [0,1,3,4,5,6,7,8,9,10,16,17,62] )
        result += " " + (IsClient() ? Movement_GetPresentationInt(name,slot) : Movement_GetPlayerStateInt(player,name,slot))
    printt(result)
    printt( "MV3_SLOT63 " + (IsClient() ? Movement_GetPresentationFloat(name,63) : Movement_GetPlayerStateFloat(player,name,63)) )
}

function MV3_PilotReport()
{
    local name = "pilot.slide_grapple"
    local player = IsClient() ? GetLocalClientPlayer() : GetPlayerArray()[0]
    if ( IsClient() ? !Movement_HasPresentation(name) : !Movement_HasPlayerState(player,name) )
    { printt("MV3_PILOT absent"); return }
    local values = "MV3_PILOT"
    foreach ( slot in [0,1,9,10,16,17] )
        values += " " + (IsClient() ? Movement_GetPresentationInt(name,slot) : Movement_GetPlayerStateInt(player,name,slot))
    printt(values)
    local o=player.GetOrigin(); local v=player.GetVelocity()
    printt("MV3_POSE "+o.x+" "+o.y+" "+o.z+" "+v.x+" "+v.y+" "+v.z+" "+player.IsOnGround())
}

function MV3_Correct()
{
    local p=GetPlayerArray()[0]
    local before=p.GetOrigin()
    local corrected=before+Vector(24,0,8)
    local command=Movement_GetPlayerStateCommand(p,"pilot.slide_grapple")
    p.SetOrigin(corrected)
    printt("MV3_CORRECTED "+command+" "+before.x+" "+before.y+" "+before.z+" "+corrected.x+" "+corrected.y+" "+corrected.z)
}

function MV3_ControlledStart( grapple = false )
{
    local p=GetPlayerArray()[0]
    local t=TraceHull(Vector(0,0,256),Vector(0,0,-512),p.GetBoundingMins(),p.GetBoundingMaxs(),p,0x0201400B,8)
    if ( t.startSolid || t.fraction >= 1.0 ) throw "Controlled arena floor was not clear"
    local origin=t.endPos+Vector(0,0,1)
    local yaw=0.0; local longest=0.0
    for(local angle=0;angle<360;angle+=22.5)
    {
        local forward=Vector(0,angle,0).AnglesToForward()
        local path=TraceHull(origin,origin+forward*800,p.GetBoundingMins(),p.GetBoundingMaxs(),p,0x0201400B,8)
        if(!path.startSolid && path.fraction>longest)
        { longest=path.fraction; yaw=angle }
    }
    if(longest<0.75) throw "Arena has no clear 600-unit slide corridor"
    p.SetOrigin(origin)
    p.SetVelocity(Vector(0,0,0))
    p.SnapEyeAngles(Vector(grapple ? -20 : 0,yaw,0))
    printt("MV3_CONTROLLED "+p.GetOrigin()+" yaw="+yaw+" clear="+longest*800)
}

function MV3_PoseReport()
{
    local p=IsClient() ? GetLocalClientPlayer() : GetPlayerArray()[0]
    local o=p.GetOrigin(); local v=p.GetVelocity()
    printt("MV3_POSE "+o.x+" "+o.y+" "+o.z+" "+v.x+" "+v.y+" "+v.z+" "+p.IsOnGround())
}

function MV3_SyncReport( name = "pilot.slide_grapple" )
{
    local p=IsClient() ? GetLocalClientPlayer() : GetPlayerArray()[0]
    MV3_PoseReport()
    if ( IsClient() ? !Movement_HasPresentation(name) : !Movement_HasPlayerState(p,name) )
    { printt("MV3_SYNC absent"); return }
    local command=IsClient() ? Movement_GetPresentationCommand(name) : Movement_GetPlayerStateCommand(p,name)
    local session=IsClient() ? Movement_GetPresentationSession(name) : Movement_GetPlayerStateSession(p,name)
    local simulationTime=IsClient() ? Movement_GetPresentationTime(name) : Movement_GetPlayerStateTime(p,name)
    printt("MV3_SYNC "+command+" "+session+" "+simulationTime+" "+Time())
    // Raw words also compare persistent floats exactly. Only the documented
    // per-command grapple guards (61,62) are excluded by the runner.
    local words="MV3_WORDS"
    for(local slot=0;slot<64;slot++)
        words+=" "+(IsClient() ? Movement_GetPresentationInt(name,slot) : Movement_GetPlayerStateInt(p,name,slot))
    printt(words)
}

// Observation only: retain actual native handles, never substitute entities
// or change simulation slots to manufacture an attached/cleaned-up result.
::MV3Owned <- []
::MV3Weapon <- null
function MV3_Remember( entity )
{
    if(!IsValid(entity)) return
    foreach(saved in ::MV3Owned)
        if(saved==entity) return
    ::MV3Owned.append(entity)
}
function MV3_LiveResources()
{
    local live=0
    foreach(entity in ::MV3Owned)
        if(IsValid(entity)) live++
    return live
}
function MV3_ResetResources()
{
    if(MV3_LiveResources()!=0) throw "Previous observed native resources remain alive"
    ::MV3Owned.clear()
    local p=IsClient() ? GetLocalClientPlayer() : GetPlayerArray()[0]
    ::MV3Weapon=p.GetActiveWeapon()
}
function MV3_WeaponReady()
{
    local p=GetPlayerArray()[0]
    local w=p.GetActiveWeapon()
    local ready=PilotMovement_ServerCanChangeWeapon(p) && IsValid(w) &&
        !w.IsWeaponOffhand() && w.GetWeaponOwner()==p && !p.IsWeaponDisabled() &&
        w.GetWeaponPrimaryClipCount()>0
    printt("MV3_WEAPON_READY "+ready)
}
function MV3_ResourceReport()
{
    local p=IsClient() ? GetLocalClientPlayer() : GetPlayerArray()[0]
    local name="pilot.slide_grapple"
    local present=IsClient() ? Movement_HasPresentation(name) : Movement_HasPlayerState(p,name)
    local phase=-1; local session=-1; local command=-1; local corners=0
    if(present)
    {
        phase=IsClient() ? Movement_GetPresentationInt(name,16) : Movement_GetPlayerStateInt(p,name,16)
        session=IsClient() ? Movement_GetPresentationSession(name) : Movement_GetPlayerStateSession(p,name)
        command=IsClient() ? Movement_GetPresentationCommand(name) : Movement_GetPlayerStateCommand(p,name)
        corners=IsClient() ? Movement_GetPresentationInt(name,18) : Movement_GetPlayerStateInt(p,name,18)
    }
    local result="MV3_RES present="+present+" phase="+phase+" session="+session+" command="+command+" corners="+corners
    if(IsClient())
    {
        local state=::PilotMovementClient
        local cable=0; local claw=0; local panels=0; local visible=0
        foreach(index,screen in state.screens)
        {
            MV3_Remember(screen)
            if(!IsValid(screen)) continue
            if(index<5) cable++; else claw++
            local panel=screen.GetPanel()
            if(panel==null) continue
            panels++
            local image=screen.s.icon
            if((index<=corners || index>=5) && image.IsVisible()) visible++
        }
        result+=" count="+state.screens.len()+" cable="+cable+" claw="+claw+" panels="+panels+" visible="+visible+
            " player="+(state.player==p)+" ownerSession="+state.session+" view="+state.viewOwned+
            " fov="+state.fov+" pose="+state.pose
    }
    else
    {
        local record=null
        if("pilotMovementServer" in level && level.pilotMovementServer!=null && p in level.pilotMovementServer.players)
            record=level.pilotMovementServer.players[p]
        local count=0; local valid=0; local owners=0; local classes=0
        local tip=false; local tipOwner=false; local linked=false; local tipError=-1.0
        local endpointError=-1.0
        local attached=false
        if(record!=null)
        {
            count=record.ropes.len()
            foreach(index,rope in record.ropes)
            {
                MV3_Remember(rope)
                if(!IsValid(rope)) continue
                valid++
                if(rope.GetOwner()==p) owners++
                if(rope.GetClassname()==(index==0 ? "move_rope" : "keyframe_rope")) classes++
            }
            MV3_Remember(record.tip)
            tip=IsValid(record.tip)
            if(tip)
            {
                tipOwner=record.tip.GetOwner()==p && record.tip.GetClassname()=="script_mover"
                if(present)
                    tipError=(record.tip.GetOrigin()-PilotMovement_ServerPoint(p,32)).Length()
                linked=count>0 && IsValid(record.ropes[count-1]) && record.ropes[count-1].GetParent()==record.tip
                if(present && linked)
                    endpointError=(record.ropes[count-1].GetOrigin()-PilotMovement_ServerPoint(p,32)).Length()
            }
            attached=record.attached
        }
        result+=" record="+(record!=null)+" count="+count+" valid="+valid+" owners="+owners+" classes="+classes+
            " tip="+tip+" tipOwner="+tipOwner+" linked="+linked+" tipError="+tipError+" endpointError="+endpointError+
            " attached="+attached+
            " ownerSession="+(record!=null ? record.session : -1)+" enabled="+Movement_IsEnabled(p,name)
    }
    local weaponValid=IsValid(::MV3Weapon)
    result+=" retained="+::MV3Owned.len()+" live="+MV3_LiveResources()+" weapon="+weaponValid+
        " weaponOwner="+(weaponValid && ::MV3Weapon.GetWeaponOwner()==p)+
        " weaponActive="+(weaponValid && p.GetActiveWeapon()==::MV3Weapon)+
        " weaponDisabled="+p.IsWeaponDisabled()+" clip="+(weaponValid ? ::MV3Weapon.GetWeaponPrimaryClipCount() : -1)
    printt(result)
}
function MV3_AttachedAction( action )
{
    local p=GetPlayerArray()[0]
    local name="pilot.slide_grapple"
    if(!Movement_HasPlayerState(p,name)) return
    local phase=Movement_GetPlayerStateInt(p,name,16)
    if(phase!=4 && phase!=5) return
    local session=Movement_GetPlayerStateSession(p,name)
    if(action=="disable")
        PilotMovement_Disable(p)
    else if(action=="replace")
        Movement_Enable(p,"v3.input")
    else
        throw "Unknown attached lifecycle action"
    printt("MV3_ACTION "+action+" "+session+" "+phase)
}

::MV3Recording <- false
::MV3History <- []
function MV3_StartRecording()
{
    if ( ::MV3Recording ) return
    ::MV3Recording=true
    ::MV3History.clear()
    thread MV3_RecordFrames()
}
function MV3_RecordFrames()
{
    level.ent.EndSignal("OnDestroy")
    OnThreadEnd(function() { ::MV3Recording=false })
    while ( ::MV3Recording )
    {
        if ( Movement_HasPresentation("pilot.slide_grapple") )
        {
            local p=GetLocalClientPlayer()
            local o=p.GetOrigin(); local v=p.GetVelocity()
            ::MV3History.append([Movement_GetPresentationCommand("pilot.slide_grapple"),
                Movement_GetPresentationTime("pilot.slide_grapple"),
                Movement_GetPresentationInt("pilot.slide_grapple",0),
                Movement_GetPresentationInt("pilot.slide_grapple",16),
                sqrt(v.x*v.x+v.y*v.y),o.x,o.y,o.z,v.z])
        }
        if ( ::MV3History.len() >= 4096 ) ::MV3Recording=false
        wait 0
    }
}
function MV3_RecordReport()
{
    local slides=0; local fastest=0.0; local phases=0; local lastSlide=-1; local lastPhase=-1
    foreach(row in ::MV3History)
    {
        phases=phases | (1 << row[3])
        if(row[2]!=0) { slides++; fastest=max(fastest,row[4]) }
        if(row[2]!=lastSlide || row[3]!=lastPhase)
        {
            printt("MV3_TRANSITION "+row[0]+" "+row[1]+" "+row[2]+" "+row[3]+" "+row[4]+" "+row[5]+" "+row[6]+" "+row[7]+" "+row[8])
            lastSlide=row[2]; lastPhase=row[3]
        }
    }
    printt("MV3_RECORD "+::MV3History.len()+" "+slides+" "+fastest+" "+phases)
}

::MV3PhaseEvents <- []
function MV3_PhaseTrace( command, event, x, y, z )
{
    if(event>=0) ::MV3PhaseEvents.append([command,event,x,y,z])
}
function MV3_PhaseReport()
{
    local minimum=::MV3PhaseEvents.len()>0 ? ::MV3PhaseEvents.top()[0]-15 : 0
    foreach(row in ::MV3PhaseEvents)
        if(row[0]>=minimum && (row[1]==0 || row[1]==2 || row[1]==9 || row[1]>=16))
            printt("MV3_PHASE "+row[0]+" "+row[1]+" "+row[2]+" "+row[3]+" "+row[4])
}
local traceSetup="if(Move_GetPhase()==MOVE_SETUP) Move_SetCheckpointMask(MOVE_CHECKPOINT_ALL);\n"
local traceFooter=@"
local vx=Move_GetVelocity(MOVE_X); local vy=Move_GetVelocity(MOVE_Y);
Move_EmitEvent(Move_GetPhase(), Move_GetIntState(0)+(Move_GetDuckRequested()?2:0)+((Move_GetButtons()&MOVE_BUTTON_DUCK)!=0?4:0),
    Move_GetDuckState(), Move_Math(MOVE_MATH_SQRT,vx*vx+vy*vy,0.0));
Move_EmitEvent(27,Move_GetOrigin(MOVE_X),Move_GetOrigin(MOVE_Y),Move_GetOrigin(MOVE_Z));
if(Move_GetPhase()==MOVE_FINISH)
    Move_EmitEvent(18,Move_GetFloatState(4),Move_GetFloatState(5),Move_GetMaxSpeed());
"
Movement_Register("v3.pilot_trace",traceSetup+::PredictedSlideSource+"\n"+::PredictedGrappleSource+traceFooter,64,"MV3_PhaseTrace")
