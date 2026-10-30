// Grapple code based on dmitryalexander/powder (https://github.com/dmitryalexander/powder), used with the author's permission.
// Shared opt-in movement source. Including this file neither registers nor runs it.
// This is a new command-driven implementation of the observed Powder grapple
// behavior, not a copy of its entity/thread/rendering implementation.
//
// Script rollback/presentation ABI: slots 16..63. I = int, F = float; XYZ always F.
// Native weapon-lock rollback words trail the 64 public slots and are not script-accessible.
// 16 I phase: 0 idle, 1 miss-out, 2 miss-return, 3 flying, 4 clamped,
//             5 pulling, 6 release-return.
// 17 I previous custom-button-1 level; release only rearms the rising edge.
// 18 I corner count, 0..4. Corners are ordered ANCHOR TO PLAYER.
// 19 I shot serial, incremented on each accepted fire, including misses.
// 20 F fire time; 21 F outbound arrival time; 22 F earliest pull time.
// 23 F current phase start; 24 F return duration (miss .30, release .16).
// 25 F winched rope length; 26 F closest routed distance since topology change.
// 27 F low-speed start (-1 = not timing); 28 F unapplied launch impulse.
// 29..31 F launch outlet XYZ, captured at fire.
// 32..34 F fixed anchor XYZ, or the miss endpoint. Never follows an entity.
// 35..37 F anchor surface normal XYZ (zero for a miss).
// 38..49 F four corner XYZ triples; only the first slot-18 triples are live.
// 50..52 F last clear eye XYZ, used as a collision-validated corner seed.
// 53 F total routed distance; 54 F fixed anchor-to-nearest-corner tail length.
// 55 F gravity fraction for this command (1 unless a pull force was accepted).
// 56..58 F captured return-start XYZ; fixed throughout either return phase.
// 59 I reason: 0 none, 1 fired, 2 miss, 3 cancel, 4 duration, 5 arrival,
//              6 range, 7 route failure, 8 passed anchor, 9 stalled,
//              10 invalid player state, 11 obstructed outbound flight.
// 60 unused; 61 I last simulated command; 62 I last simulated tick;
// 63 I initialized (0/1).
//
// Presentation consumes committed snapshots only. Flying interpolates launch
// to anchor over [20,21]. Miss-out uses the same interval with 1-(1-u)^2.
// Clamped/pulling keep the hook at the anchor and draw the corner chain in
// reverse from the current outlet. Returns interpolate 56..58 to the current
// outlet with u*u*(3-2*u), using phase start 23 and duration 24. Idle hides it.
// Slots 19, 16 and 23 identify presentation transitions without replay effects.
//
// The motor runs only in MOVE_SIMULATE. Each actual native half-gravity step
// is scaled at its own checkpoint, not estimated from a second frame timer.
// Helpers and routing scratch are evaluation-local; only typed slots persist.
::PredictedGrappleSource <- @"
{
    local grapplePhase = Move_GetPhase();
    if (grapplePhase == MOVE_SIMULATE)
    {
        local GrappleEvaluate = function()
        {
            local command = Move_GetCommandNumber();
            local tick = Move_GetTick();
            if (Move_GetIntState(63) != 0 &&
                Move_GetIntState(61) == command && Move_GetIntState(62) == tick)
                return;
            Move_SetIntState(63, 1);
            Move_SetIntState(61, command);
            Move_SetIntState(62, tick);

            local now = Move_GetTime();
            local dt = Move_GetFrameTime();
            local phase = Move_GetIntState(16);
            local pressed = (Move_GetCustomButtons() & 1) != 0;
            local edge = pressed && Move_GetIntState(17) == 0;
            Move_SetIntState(17, pressed ? 1 : 0);
            Move_SetFloatState(55, 1.0);

            // Native type 2 is normal pilot movement, not noclip/traversal.
            local eligible = Move_GetMoveType() == 2 && Move_IsAlive() && !Move_IsTitan() &&
                Move_IsWorldUp() && !Move_IsMantling() && !Move_IsZiplining() &&
                !Move_IsWaterJumping() && Move_GetWaterLevel() < 2;
            if (!eligible)
            {
                Move_SetWeaponLock(false);
                if (phase != 0)
                {
                    Move_SetIntState(16, 0);
                    Move_SetIntState(18, 0);
                    Move_SetIntState(59, 10);
                    Move_SetFloatState(23, now);
                    Move_SetFloatState(28, 0.0);
                }
                return;
            }
            if (phase == 0)
                Move_SetWeaponLock(false);
            if (phase == 0 && !edge)
                return;
            if (phase == 0 && !Move_SetWeaponLock(true))
            {
                Move_SetIntState(59, 10);
                return;
            }

            local LoadPoint = function(slot)
            {
                return Vector(Move_GetFloatState(slot), Move_GetFloatState(slot + 1), Move_GetFloatState(slot + 2));
            }
            local SavePoint = function(slot, point)
            {
                Move_SetFloatState(slot, point.x);
                Move_SetFloatState(slot + 1, point.y);
                Move_SetFloatState(slot + 2, point.z);
            }
            local Dot = function(a, b)
            {
                return a.x * b.x + a.y * b.y + a.z * b.z;
            }
            local ChangePhase = function(next, began)
            {
                if (next == 0 || next == 6)
                    Move_SetWeaponLock(false);
                else if (!Move_SetWeaponLock(true))
                {
                    Move_SetWeaponLock(false);
                    next = 0;
                    Move_SetIntState(18, 0);
                    Move_SetIntState(59, 10);
                }
                Move_SetIntState(16, next);
                Move_SetFloatState(23, began);
            }
            local Detach = function(reason, retract) : ( now, LoadPoint, SavePoint, ChangePhase )
            {
                local phase = Move_GetIntState(16);
                local attached = phase == 4 || phase == 5;
                if (attached && !Move_IsOnGround() && Move_GetRemainingAirJumps() < 1)
                    Move_SetRemainingAirJumps(1);

                // A return owns no velocity and cannot award another air jump.
                if (retract && phase >= 3 && phase <= 5)
                {
                    local tip = LoadPoint(32);
                    if (phase == 3)
                    {
                        local duration = Move_GetFloatState(21) - Move_GetFloatState(20);
                        local fraction = min(1.0, max(0.0, (now - Move_GetFloatState(20)) / max(0.001, duration)));
                        local outlet = LoadPoint(29);
                        tip = outlet + (tip - outlet) * fraction;
                    }
                    SavePoint(56, tip);
                    Move_SetFloatState(24, 0.16);
                    ChangePhase(6, now);
                }
                else
                    ChangePhase(0, now);

                Move_SetIntState(18, 0);
                Move_SetIntState(59, reason);
                Move_SetFloatState(27, -1.0);
                Move_SetFloatState(28, 0.0);
                Move_SetFloatState(53, 0.0);
                Move_SetFloatState(54, 0.0);
                Move_SetFloatState(55, 1.0);
                if (reason == 5)
                {
                    local vertical = Move_GetVelocity(MOVE_Z);
                    if (vertical < 300.0)
                        Move_SetVelocity(Move_GetVelocity(MOVE_X), Move_GetVelocity(MOVE_Y), min(300.0, vertical + 300.0));
                }
            }

            if (phase != 0 && phase != 6 && !Move_SetWeaponLock(true))
            {
                Detach(10, false);
                return;
            }
            if (edge && phase != 0)
            {
                Detach(3, true);
                return;
            }
            if (phase == 6)
            {
                if (now - Move_GetFloatState(23) >= Move_GetFloatState(24))
                    ChangePhase(0, now);
                return;
            }
            if (phase == 1 || phase == 2)
            {
                local turnAt = Move_GetFloatState(21);
                if (now >= turnAt + Move_GetFloatState(24))
                    ChangePhase(0, now);
                else if (phase == 1 && now >= turnAt)
                {
                    SavePoint(56, LoadPoint(32));
                    ChangePhase(2, turnAt);
                }
                return;
            }

            local origin = Vector(Move_GetOrigin(MOVE_X), Move_GetOrigin(MOVE_Y), Move_GetOrigin(MOVE_Z));
            local eye = origin + Vector(Move_GetEyeOffset(MOVE_X), Move_GetEyeOffset(MOVE_Y), Move_GetEyeOffset(MOVE_Z));
            local view = Vector(Move_GetViewAngles(MOVE_X), Move_GetViewAngles(MOVE_Y), Move_GetViewAngles(MOVE_Z));
            local forward = view.AnglesToForward();
            local right = Vector(forward.y, -forward.x, 0.0);
            local rightLength = right.Length();
            if (rightLength > 0.001)
                right = right * (1.0 / rightLength);
            else
            {
                local yaw = Move_GetViewAngles(MOVE_Y) * 0.0174532925199433;
                right = Vector(Move_Math(MOVE_MATH_SIN, yaw, 0.0), -Move_Math(MOVE_MATH_COS, yaw, 0.0), 0.0);
            }
            // Identical physical mask for acquisition and every rope segment.
            local surfaceMask = TRACE_MASK_SHOT & ~(CONTENTS_MONSTER | CONTENTS_HITBOX | CONTENTS_PLAYERCLIP | CONTENTS_MONSTERCLIP);

            if (phase == 0)
            {
                local up = Vector(right.y * forward.z, -right.x * forward.z, right.x * forward.y - right.y * forward.x);
                local outlet = eye + forward * 32.0 - up * 32.0;
                local farPoint = eye + forward * 1650.0;
                Move_TraceHull(eye.x, eye.y, eye.z, farPoint.x, farPoint.y, farPoint.z,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, surfaceMask, MOVE_COLLISION_GROUP_NONE);
                local hit = Vector(Move_GetTraceEnd(MOVE_X), Move_GetTraceEnd(MOVE_Y), Move_GetTraceEnd(MOVE_Z));
                local normal = Vector(Move_GetTraceNormal(MOVE_X), Move_GetTraceNormal(MOVE_Y), Move_GetTraceNormal(MOVE_Z));
                local hitDistance = (hit - eye).Length();
                local normalLength = normal.Length();
                local miss = Move_GetTraceFraction() >= 1.0 || Move_TraceStartedSolid() ||
                    Move_TraceAllSolid() || Move_TraceHitSky() || hitDistance < 33.0 || normalLength < 0.001;
                local endpoint;
                local travel;
                if (miss)
                {
                    local reach = 1650.0;
                    if (Move_GetTraceFraction() < 1.0 && !Move_TraceHitSky())
                        reach = max(8.0, hitDistance);
                    endpoint = eye + forward * reach;
                    normal = Vector(0.0, 0.0, 0.0);
                    travel = max(0.12, (endpoint - outlet).Length() / 3000.0);
                }
                else
                {
                    normal = normal * (1.0 / normalLength);
                    endpoint = hit + normal;
                    travel = (endpoint - eye).Length() / 3000.0;
                }
                local distance = (endpoint - eye).Length();
                local serial = Move_GetIntState(19);
                Move_SetIntState(19, serial == 2147483647 ? 1 : serial + 1);
                Move_SetIntState(18, 0);
                Move_SetIntState(59, miss ? 2 : 1);
                Move_SetFloatState(20, now);
                Move_SetFloatState(21, now + travel);
                Move_SetFloatState(22, miss ? 0.0 : now + travel + 0.45);
                Move_SetFloatState(24, 0.30);
                Move_SetFloatState(25, distance);
                Move_SetFloatState(26, distance);
                Move_SetFloatState(27, -1.0);
                Move_SetFloatState(28, 0.0);
                Move_SetFloatState(53, distance);
                Move_SetFloatState(54, 0.0);
                SavePoint(29, outlet);
                SavePoint(32, endpoint);
                SavePoint(35, normal);
                SavePoint(50, eye);
                SavePoint(56, endpoint);
                ChangePhase(miss ? 1 : 3, now);
                return;
            }

            if (now - Move_GetFloatState(20) > 10.0)
            {
                Detach(4, true);
                return;
            }
            local anchor = LoadPoint(32);
            local directDistance = (anchor - eye).Length();
            local count = Move_GetIntState(18);
            if (count == 0 && directDistance < 33.0)
            {
                Detach(5, false);
                return;
            }
            if (directDistance > 2475.0)
            {
                Detach(6, false);
                return;
            }

            local ClearCable = function(a, b) : ( surfaceMask )
            {
                local span = (b - a).Length();
                if (span < 0.001)
                    return true;
                Move_TraceHull(a.x, a.y, a.z, b.x, b.y, b.z,
                    -0.4, -0.4, -0.4, 0.4, 0.4, 0.4, surfaceMask, MOVE_COLLISION_GROUP_NONE);
                return !Move_TraceStartedSolid() && !Move_TraceAllSolid() && !Move_TraceHitSky() &&
                    Move_GetTraceFraction() * span >= span - 0.02;
            }

            if (phase == 3)
            {
                // Do not retroactively route an outgoing hook through a wall.
                if (!ClearCable(eye, anchor))
                {
                    Detach(11, false);
                    return;
                }
                if (now < Move_GetFloatState(21))
                    return;
                ChangePhase(4, now);
                phase = Move_GetIntState(16);
                Move_SetFloatState(22, now + 0.45);
                Move_SetFloatState(28, 350.0);
            }

            local ShortenCorner = function(a, b, point) : ( ClearCable )
            {
                local cost = (point - a).Length() + (point - b).Length();
                // Finite coordinate descent along the path gradient and each
                // endpoint. Every accepted candidate has TWO swept clear legs.
                for (local round = 0; round < 6; ++round)
                {
                    local before = point;
                    local toA = a - point;
                    local toB = b - point;
                    local lengthA = toA.Length();
                    local lengthB = toB.Length();
                    if (lengthA < 0.01 || lengthB < 0.01)
                        break;
                    local gradient = toA * (1.0 / lengthA) + toB * (1.0 / lengthB);
                    local gradientLength = gradient.Length();
                    local downhill = point;
                    if (gradientLength > 0.001)
                        downhill = point + gradient * (min(lengthA, lengthB) / gradientLength);
                    for (local direction = 0; direction < 3; ++direction)
                    {
                        if (direction == 0 && gradientLength <= 0.001)
                            continue;
                        local free = point;
                        local bound = direction == 0 ? downhill : (direction == 1 ? a : b);
                        for (local division = 0; division < 16; ++division)
                        {
                            local midpoint = (free + bound) * 0.5;
                            if (ClearCable(a, midpoint) && ClearCable(midpoint, b))
                                free = midpoint;
                            else
                                bound = midpoint;
                        }
                        local trialCost = (free - a).Length() + (free - b).Length();
                        if (trialCost + 0.0001 < cost)
                        {
                            point = free;
                            cost = trialCost;
                        }
                    }
                    if ((point - before).Length() < 0.01)
                        break;
                }
                return point;
            }

            local RouteCorner = function(a, b, obstruction, normal, previousEye) : ( ClearCable, ShortenCorner )
            {
                local normalSize = normal.Length();
                if (normalSize < 0.001)
                    return null;
                normal = normal * (1.0 / normalSize);
                local basisA = Vector(-normal.y, normal.x, 0.0);
                local basisSize = basisA.Length();
                basisA = basisSize < 0.001 ? Vector(1.0, 0.0, 0.0) : basisA * (1.0 / basisSize);
                local basisB = Vector(normal.y * basisA.z - normal.z * basisA.y,
                    normal.z * basisA.x - normal.x * basisA.z,
                    normal.x * basisA.y - normal.y * basisA.x);
                local face = obstruction + normal * 0.75;
                local winner = null;
                local shortest = 1000000.0;
                // The last eye is useful only if movement to it and its old
                // rope leg are still clear in this exact command's geometry.
                if ((previousEye - a).Length() > 1.0 &&
                    ClearCable(a, previousEye) && ClearCable(previousEye, b))
                {
                    local inside = face;
                    local outside = previousEye;
                    for (local step = 0; step < 8; ++step)
                    {
                        local probe = (inside + outside) * 0.5;
                        if (ClearCable(a, probe) && ClearCable(probe, b))
                            outside = probe;
                        else
                            inside = probe;
                    }
                    winner = outside;
                    shortest = (outside - a).Length() + (outside - b).Length();
                }
                // Eight face-plane directions at five radii, never an
                // unbounded search or a pivot accepted inside an obstruction.
                for (local ring = 0; ring < 5; ++ring)
                {
                    local radius = (16 << ring).tofloat();
                    for (local spoke = 0; spoke < 8; ++spoke)
                    {
                        local x = 0.0;
                        local y = 0.0;
                        if (spoke < 2)
                            x = spoke == 0 ? 1.0 : -1.0;
                        else if (spoke < 4)
                            y = spoke == 2 ? 1.0 : -1.0;
                        else
                        {
                            x = spoke < 6 ? 0.707106781186548 : -0.707106781186548;
                            y = (spoke & 1) == 0 ? 0.707106781186548 : -0.707106781186548;
                        }
                        local candidate = face + basisA * (x * radius) + basisB * (y * radius);
                        if ((candidate - a).Length() < 0.4 ||
                            !ClearCable(a, candidate) || !ClearCable(candidate, b))
                            continue;
                        local cost = (candidate - a).Length() + (candidate - b).Length();
                        if (cost < shortest)
                        {
                            winner = candidate;
                            shortest = cost;
                        }
                    }
                }
                if (winner == null)
                    return null;
                return ShortenCorner(a, b, winner);
            }

            local corners = [];
            for (local index = 0; index < count; ++index)
                corners.append(LoadPoint(38 + index * 3));
            local changed = false;
            for (local unwind = 0; unwind < 4 && corners.len() > 0; ++unwind)
            {
                local bypass = corners.len() == 1 ? anchor : corners[corners.len() - 2];
                if (!ClearCable(eye, bypass))
                    break;
                corners.pop();
                changed = true;
            }
            local aim = corners.len() == 0 ? anchor : corners[corners.len() - 1];
            if (!ClearCable(eye, aim))
            {
                if (corners.len() == 4 || Move_TraceStartedSolid() || Move_TraceAllSolid() || Move_TraceHitSky())
                {
                    Detach(7, false);
                    return;
                }
                local obstruction = Vector(Move_GetTraceEnd(MOVE_X), Move_GetTraceEnd(MOVE_Y), Move_GetTraceEnd(MOVE_Z));
                local surface = Vector(Move_GetTraceNormal(MOVE_X), Move_GetTraceNormal(MOVE_Y), Move_GetTraceNormal(MOVE_Z));
                local corner = RouteCorner(eye, aim, obstruction, surface, LoadPoint(50));
                if (corner == null)
                {
                    Detach(7, false);
                    return;
                }
                corners.append(corner);
                aim = corner;
                changed = true;
            }
            local tail = 0.0;
            local previous = anchor;
            foreach (corner in corners)
            {
                if (!ClearCable(corner, previous))
                {
                    Detach(7, false);
                    return;
                }
                tail += (corner - previous).Length();
                previous = corner;
            }
            local firstSpan = (aim - eye).Length();
            local routedDistance = firstSpan + tail;
            if (routedDistance > 2475.0)
            {
                Detach(6, false);
                return;
            }
            if (firstSpan < 0.001)
            {
                Detach(7, false);
                return;
            }
            Move_SetIntState(18, corners.len());
            for (local index = 0; index < corners.len(); ++index)
                SavePoint(38 + index * 3, corners[index]);
            SavePoint(50, eye);
            Move_SetFloatState(53, routedDistance);
            Move_SetFloatState(54, tail);
            if (changed)
                Move_SetFloatState(26, routedDistance);
            if (now < Move_GetFloatState(22) || dt <= 0.0)
                return;

            local direction = (aim - eye) * (1.0 / firstSpan);
            local velocity = Vector(Move_GetVelocity(MOVE_X), Move_GetVelocity(MOVE_Y), Move_GetVelocity(MOVE_Z));
            if (phase == 4)
            {
                ChangePhase(5, now);
                phase = Move_GetIntState(16);
                if (Move_IsOnGround())
                {
                    // Clearance is tested with the PILOT hull, not the cable.
                    // SetOrigin performs its own native movement sweep too.
                    Move_TraceHull(origin.x, origin.y, origin.z, origin.x, origin.y, origin.z + 4.0,
                        Move_GetHullMins(MOVE_X), Move_GetHullMins(MOVE_Y), Move_GetHullMins(MOVE_Z),
                        Move_GetHullMaxs(MOVE_X), Move_GetHullMaxs(MOVE_Y), Move_GetHullMaxs(MOVE_Z),
                        MOVE_MASK_PLAYERSOLID, MOVE_COLLISION_GROUP_PLAYER_MOVEMENT);
                    if (!Move_TraceStartedSolid() && !Move_TraceAllSolid() && Move_GetTraceFraction() == 1.0)
                        Move_SetOrigin(origin.x, origin.y, origin.z + 4.0);
                    velocity.z = max(velocity.z, 200.0);
                }
            }

            local remaining = Move_GetFloatState(28);
            local impulse = min(remaining, 350.0 * dt / 0.35);
            Move_SetFloatState(28, max(0.0, remaining - impulse));
            velocity = velocity + direction * impulse;

            // Command axes retain analogue magnitude up to native full speed;
            // forward remains camera-pitched, and side remains camera-right.
            local inputScale = max(1.0, max(Move_GetMaxSpeed(), Move_GetClientMaxSpeed()));
            local wish = (forward * Move_GetForwardSpeed() + right * Move_GetSideSpeed()) * (1.0 / inputScale);
            local wishLength = wish.Length();
            if (wishLength > 1.0)
                wish = wish * (1.0 / wishLength);
            local away = max(0.0, -Dot(wish, direction));
            local gravityFraction = 0.25 + 0.45 * away;
            local radial = Dot(velocity, direction);
            local tangent = velocity - direction * radial;
            local lateralInput = wish - direction * Dot(wish, direction);
            local lateralSize = lateralInput.Length();
            if (lateralSize > 0.001)
            {
                local lateralDirection = lateralInput * (1.0 / lateralSize);
                local available = max(0.0, 420.0 - Dot(tangent, lateralDirection));
                local addedSpeed = min(available, 650.0 * dt * min(1.0, lateralSize));
                tangent = tangent + lateralDirection * addedSpeed;
            }

            local closest = min(Move_GetFloatState(26), routedDistance);
            Move_SetFloatState(26, closest);
            if (corners.len() == 0 && routedDistance > closest + 16.0 && radial < -500.0)
            {
                Detach(8, true);
                return;
            }
            local progress = min(1.0, max(0.0, (now - Move_GetFloatState(22)) / 1.5));
            local winchSpeed = 50.0 + 750.0 * progress;
            local ropeLength = max(33.0, min(Move_GetFloatState(25), routedDistance) - winchSpeed * dt);
            Move_SetFloatState(25, ropeLength);
            local requiredInwardSpeed = max(0.0, routedDistance - ropeLength) / max(0.15, dt);
            radial += min(1000.0 * dt, max(0.0, requiredInwardSpeed - radial));
            // No tangent braking and no total-speed cap: existing swing and
            // slingshot momentum survive the inward-only winch constraint.
            velocity = tangent + direction * radial;
            Move_SetVelocity(velocity.x, velocity.y, velocity.z);
            Move_SetFloatState(55, gravityFraction);

            if (velocity.Length() < 250.0)
            {
                local lowSince = Move_GetFloatState(27);
                if (lowSince < 0.0)
                {
                    lowSince = now;
                    Move_SetFloatState(27, now);
                }
                local timeout = Move_IsOnGround() ? 0.7 : 1.5;
                if (now - lowSince > timeout)
                    Detach(9, false);
            }
            else
                Move_SetFloatState(27, -1.0);
        }
        GrappleEvaluate();
    }
    else if ((grapplePhase == MOVE_START_GRAVITY || grapplePhase == MOVE_FINISH_GRAVITY) &&
        Move_GetIntState(16) == 5 && Move_GetMoveType() == 2 && Move_IsAlive() && !Move_IsTitan() &&
        Move_IsWorldUp() && !Move_IsMantling() && !Move_IsZiplining() &&
        !Move_IsWaterJumping() && Move_GetWaterLevel() < 2)
    {
        // The checkpoint is before native gravity. Its contribution is the
        // positive half-step scalar including native dt and wallrun scaling.
        local cancelledGravity = (1.0 - Move_GetFloatState(55)) * Move_GetGravityContribution();
        Move_SetVelocity(Move_GetVelocity(MOVE_X), Move_GetVelocity(MOVE_Y), Move_GetVelocity(MOVE_Z) + cancelledGravity);
    }
}
"
