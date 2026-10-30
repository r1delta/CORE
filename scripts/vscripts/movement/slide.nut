// Shared opt-in program fragment. Loading this file does not register or enable it.
// Persistent state belongs exclusively to the combined program's rollback slots:
//   0 int: sliding (0/1), committed presentation flag.
//   1 int: long-jump permission (0/1), consumed only by a successful legal jump.
//   2 float: last slide entry command time (also the boost cooldown origin).
//   3 float: horizontal speed actually supplied by the most recent eligible boost.
//   4 float: last landing command time, committed presentation timestamp.
//   5 float: retained landing impact height, committed presentation magnitude.
//   6..8 float: last actual published ground-plane normal XYZ, never gravity-up.
//   9 int: ground-plane known (0/1); zero-initialized XYZ is NOT a known plane.
//  10 int: native down-transition duration, 200 fast / 400 ordinary; zero means400.
//  11 int: pending legal-jump adjustment (0/1), cleared at the paired finish.
//  12..13 float: original horizontal velocity for a rejected prepared jump.
//  14 int: reserved, zero; 15 int: last published native ground surface.
// Initial entry time is zero: a boost requires strictly more than two seconds,
// matching the default profile. No wall-clock time, effects or private assets.
// Physics tuning is server-replicated under the original SP parameter names.
// Native convar bounds: landing scale [0,1], friction scale [0,4], ground
// acceleration [0,2000] native units, retain crouch [0,1] (integer boolean).
// Landing scale changes the applied slowdown, never the retained impact history.
// Friction scales both linear deceleration and exponential velocity decay.
::PredictedSlideSource <- @"
{
    local SlideLandingScale = function( now )
    {
        local height = Move_GetFloatState( 5 );
        local elapsed = now - Move_GetFloatState( 4 );
        if ( height <= 300.0 || elapsed >= 1.0 )
            return 1.0;
        local weight = (height - 300.0) / 500.0;
        if ( weight > 1.0 ) weight = 1.0;
        if ( elapsed < 0.0 ) elapsed = 0.0;
        return 1.0 - GetConVarFloat( ""delta_sp_landing_slowdown_scale"" )
            * (1.0 - elapsed * elapsed) * weight;
    }

    local SlideEnd = function()
    {
        Move_SetIntState( 0, 0 );
        Move_ClearAcceleration();
        Move_ClearDeceleration();
    }

    local SlideScalars = function() : ( SlideLandingScale )
    {
        if ( Move_GetIntState( 0 ) == 0 ) return;
        local dot = Move_GetVelocity( MOVE_X ) * Move_GetInputDirection( MOVE_X )
            + Move_GetVelocity( MOVE_Y ) * Move_GetInputDirection( MOVE_Y )
            + Move_GetVelocity( MOVE_Z ) * Move_GetInputDirection( MOVE_Z );
        Move_SetAcceleration( GetConVarFloat( ""delta_sp_slide_ground_acceleration"" )
            * Move_GetMoveScale() * SlideLandingScale( Move_GetTime() ) );
        Move_SetDeceleration( (Move_GetDuckRequested() && dot >= 0.0 ? 100.0 : 400.0)
            * GetConVarFloat( ""delta_sp_slide_friction_scale"" ) );
    }

    local SlideEnter = function( grounded, now ) : ( SlideLandingScale, SlideScalars )
    {
        if ( Move_GetIntState( 0 ) != 0 || Move_GetIntState( 9 ) == 0
            || Move_GetFloatState( 8 ) < 0.7 || Move_GetStance() == 1 )
            return;
        local x = Move_GetVelocity( MOVE_X );
        local y = Move_GetVelocity( MOVE_Y );
        local speedSquared = x * x + y * y;
        local threshold = !grounded && Move_GetVelocity( MOVE_Z ) <= -200.0 ? 90.0 : 200.0;
        if ( speedSquared < threshold * threshold ) return;
        if ( grounded )
        {
            // Native forward/input dot, not velocity alignment or raw forwardSpeed.
            local forwardInput = Move_GetViewForward( MOVE_X ) * Move_GetInputDirection( MOVE_X )
                + Move_GetViewForward( MOVE_Y ) * Move_GetInputDirection( MOVE_Y )
                + Move_GetViewForward( MOVE_Z ) * Move_GetInputDirection( MOVE_Z );
            if ( forwardInput < 0.6 ) return;
        }
        Move_SetIntState( 0, 1 );
        if ( now - Move_GetFloatState( 2 ) > 2.0 )
        {
            local speed = Move_Math( MOVE_MATH_SQRT, speedSquared, 0.0 );
            local moveScale = Move_GetMoveScale() * SlideLandingScale( now );
            local target = speed + 150.0 * moveScale;
            local cap = 400.0 * moveScale;
            if ( target > cap ) target = cap;
            Move_SetFloatState( 3, 0.0 );
            if ( target > speed )
            {
                local ratio = target / speed;
                Move_SetVelocity( x * ratio, y * ratio, Move_GetVelocity( MOVE_Z ) );
                Move_SetFloatState( 3, target - speed );
            }
            Move_SetIntState( 1, 1 );
        }
        // Even an unboosted entry postpones the next boost. Standing does not
        // revoke a previously earned jump permission or erase its boost amount.
        Move_SetFloatState( 2, now );
        Move_SetIntState( 10, 200 );
        Move_SetDuckDuration( 200 );
        // Native Duck alone owns hull, flags, ceiling refusal and timer reversal.
        SlideScalars();
    }

    local SlideEvaluate = function() : ( SlideEnd, SlideLandingScale, SlideScalars, SlideEnter )
    {
        local phase = Move_GetPhase();
        local now = Move_GetTime();
        if ( !Move_IsAlive() || Move_IsTitan() )
        {
            SlideEnd();
            Move_SetIntState( 1, 0 );
            Move_SetFloatState( 2, 0.0 );
            Move_SetFloatState( 3, 0.0 );
            Move_SetFloatState( 4, 0.0 );
            Move_SetFloatState( 5, 0.0 );
            Move_SetFloatState( 6, 0.0 );
            Move_SetFloatState( 7, 0.0 );
            Move_SetFloatState( 8, 0.0 );
            Move_SetIntState( 9, 0 );
            Move_SetIntState( 10, 0 );
            Move_SetIntState( 11, 0 );
            Move_SetFloatState( 12, 0.0 );
            Move_SetFloatState( 13, 0.0 );
            return;
        }
        local type = Move_GetMoveType();
        local eligible = (type == 2 || type == 7) && Move_IsWorldUp()
            && Move_GetWaterLevel() < 2 && !Move_IsWallRunning()
            && !Move_IsMantling() && !Move_IsZiplining();
        if ( !eligible )
        {
            SlideEnd();
            // Eligibility may change halfway through a native transition.
            // Preserve its denominator even while all slide mechanics are off.
            if ( phase == MOVE_SETUP )
            {
                local transition = Move_GetDuckState();
                local duration = Move_GetIntState( 10 );
                if ( (transition == 1 || transition == 3) && duration > 0 )
                    Move_SetDuckDuration( duration );
            }
            Move_SetIntState( 11, 0 );
            return;
        }

        local duck = Move_GetDuckState();
        // DUCK is before the native stance transition. Every later phase sees
        // its real outcome, including a ceiling/suppression refusal to crouch.
        if ( phase != MOVE_DUCK && (duck == 0 || duck == 3) )
            SlideEnd();

        if ( phase == MOVE_SETUP )
        {
            Move_SetIntState( 11, 0 );
            if ( GetConVarBool( ""sv_autobunnyhopping"" ) && Move_IsOnGround() )
                Move_SetOldButtons( Move_GetOldButtons() & ~MOVE_BUTTON_JUMP );
            Move_SetCrouchJumpEnabled( true );
            local scale = SlideLandingScale( now );
            Move_SetMoveScale( scale );
            Move_SetSprintAllowed( scale >= 0.7 );
            // A completed transition can choose a fresh duration. An in-flight
            // transition must keep its original denominator even after slide ends.
            local duration = Move_GetIntState( 10 );
            if ( duck == 0 || duck == 2 || duration == 0 )
            {
                duration = Move_GetIntState( 0 ) != 0 ? 200 : 400;
                Move_SetIntState( 10, duration );
            }
            Move_SetDuckDuration( duration );
            SlideScalars();
            return;
        }

        if ( phase == MOVE_DUCK )
        {
            local x = Move_GetVelocity( MOVE_X );
            local y = Move_GetVelocity( MOVE_Y );
            Move_SetDuckRetention( GetConVarBool( ""delta_sp_slide_retain_crouch"" )
                && Move_GetIntState( 0 ) != 0 && x * x + y * y > 350.0 * 350.0 );
            if ( Move_GetDuckRequested() && duck == 0 && Move_IsOnGround() )
                SlideEnter( true, now );
            SlideScalars();
            return;
        }

        if ( phase == MOVE_GROUND_CONTACT )
        {
            if ( !Move_HasGroundNormal() ) return;
            local nx = Move_GetGroundNormal( MOVE_X );
            local ny = Move_GetGroundNormal( MOVE_Y );
            local nz = Move_GetGroundNormal( MOVE_Z );
            Move_SetFloatState( 6, nx );
            Move_SetFloatState( 7, ny );
            Move_SetFloatState( 8, nz );
            Move_SetIntState( 9, 1 );
            Move_SetIntState( 15, Move_GetGroundSurface() );
            // This callback precedes publication: IsOnGround is the old contact,
            // and velocity is the incoming native solver value, not a saved Z.
            if ( !Move_IsOnGround() )
            {
                local x = Move_GetVelocity( MOVE_X );
                local y = Move_GetVelocity( MOVE_Y );
                local z = Move_GetVelocity( MOVE_Z );
                local elapsed = now - Move_GetFloatState( 4 );
                if ( elapsed < 0.0 ) elapsed = 0.0;
                if ( elapsed > 1.0 ) elapsed = 1.0;
                local height = (1.0 - elapsed) * Move_GetFloatState( 5 );
                local gravity = Move_GetWorldGravity();
                if ( gravity > 0.0 )
                {
                    local normalSpeed = x * nx + y * ny + z * nz;
                    local impact = normalSpeed * normalSpeed * 0.5 / gravity;
                    if ( impact > height ) height = impact;
                }
                Move_SetFloatState( 4, now );
                Move_SetFloatState( 5, height );
                local scale = SlideLandingScale( now );
                Move_SetMoveScale( scale );
                Move_SetSprintAllowed( scale >= 0.7 );
                Move_SetVelocity( x * scale, y * scale, z );
                if ( duck == 1 || duck == 2 ) SlideEnter( false, now );
            }
            SlideScalars();
            return;
        }

        if ( phase == MOVE_JUMP )
        {
            // Native has already passed jump legality and selected its height.
            // Permission is retained until the paired native return says success.
            if ( Move_GetIntState( 0 ) == 0 && Move_GetIntState( 1 ) == 0 ) return;
            local x = Move_GetVelocity( MOVE_X );
            local y = Move_GetVelocity( MOVE_Y );
            Move_SetFloatState( 12, x );
            Move_SetFloatState( 13, y );
            Move_SetIntState( 11, 1 );
            if ( Move_GetIntState( 0 ) != 0 ) Move_SetSelectedJumpHeight( 50.0 );
            if ( Move_GetIntState( 1 ) != 0 )
            {
                local originalSquared = x * x + y * y;
                if ( originalSquared > 0.0 )
                {
                    local originalSpeed = Move_Math( MOVE_MATH_SQRT, originalSquared, 0.0 );
                    local currentSpeed = originalSpeed;
                    if ( duck != 2 && Move_GetFloatState( 2 ) > now - 0.4 )
                    {
                        currentSpeed -= Move_GetFloatState( 3 );
                        if ( currentSpeed < 0.0 ) currentSpeed = 0.0;
                        local ratio = currentSpeed / originalSpeed;
                        x *= ratio;
                        y *= ratio;
                    }
                    // This is a narrow near-cap lift, not a clamp of legitimate
                    // faster native/grapple velocity. Test the ORIGINAL speed.
                    if ( originalSquared > 297.5 * 297.5 && originalSquared < 350.0 * 350.0
                        && currentSpeed > 0.0 )
                    {
                        local ratio = 350.0 / currentSpeed;
                        x *= ratio;
                        y *= ratio;
                    }
                    Move_SetVelocity( x, y, Move_GetVelocity( MOVE_Z ) );
                }
            }
            return;
        }

        if ( phase == MOVE_JUMP_FINISH )
        {
            if ( Move_GetIntState( 11 ) == 0 ) return;
            if ( Move_DidJump() )
            {
                SlideEnd();
                Move_SetIntState( 1, 0 );
            }
            else
                Move_SetVelocity( Move_GetFloatState( 12 ), Move_GetFloatState( 13 ), Move_GetVelocity( MOVE_Z ) );
            Move_SetIntState( 11, 0 );
            return;
        }

        if ( phase == MOVE_START_GRAVITY || phase == MOVE_FINISH_GRAVITY )
        {
            if ( Move_GetIntState( 0 ) == 0 || Move_GetIntState( 9 ) == 0 || !Move_IsOnGround() ) return;
            local coefficient = Move_GetGravityContribution() * Move_GetFloatState( 8 );
            Move_SetVelocity( Move_GetVelocity( MOVE_X ) + coefficient * Move_GetFloatState( 6 ),
                Move_GetVelocity( MOVE_Y ) + coefficient * Move_GetFloatState( 7 ),
                Move_GetVelocity( MOVE_Z ) );
            return;
        }

        if ( phase == MOVE_WALK )
        {
            if ( Move_GetIntState( 0 ) == 0 ) return;
            local x = Move_GetVelocity( MOVE_X );
            local y = Move_GetVelocity( MOVE_Y );
            if ( x * x + y * y < 125.0 * 125.0 )
                SlideEnd();
            else
                SlideScalars();
            return;
        }

        if ( phase != MOVE_FRICTION || Move_GetIntState( 0 ) == 0 || Move_IsWaterJumping() ) return;
        local vx = Move_GetVelocity( MOVE_X );
        local vy = Move_GetVelocity( MOVE_Y );
        local vz = Move_GetVelocity( MOVE_Z );
        Move_ReplaceFriction( true );
        local dt = Move_GetFrameTime();
        if ( dt <= 0.0 ) return;
        local wx = Move_GetWishDirection( MOVE_X );
        local wy = Move_GetWishDirection( MOVE_Y );
        local wz = Move_GetWishDirection( MOVE_Z );
        local kx = 0.0;
        local ky = 0.0;
        local kz = 0.0;
        local projection = wx * vx + wy * vy + wz * vz;
        if ( projection > 0.0 )
        {
            local protect = projection * Move_GetWishSpeed() / (vx * vx + vy * vy + vz * vz);
            if ( protect > 1.0 ) protect = 1.0;
            local nx = Move_GetWallNormal( MOVE_X );
            local ny = Move_GetWallNormal( MOVE_Y );
            local nz = Move_GetWallNormal( MOVE_Z );
            local intoWall = wx * nx + wy * ny + wz * nz;
            if ( intoWall < 0.0 )
            {
                local bias = 0.0078125 - intoWall;
                wx += nx * bias;
                wy += ny * bias;
                wz += nz * bias;
                local length = Move_Math( MOVE_MATH_SQRT, wx * wx + wy * wy + wz * wz, 0.0 );
                wx /= length;
                wy /= length;
                wz /= length;
                projection = wx * vx + wy * vy + wz * vz;
                if ( projection < 0.0 ) projection = 0.0;
            }
            local kept = projection * protect;
            kx = wx * kept;
            ky = wy * kept;
            kz = wz * kept;
        }
        local rx = vx - kx;
        local ry = vy - ky;
        local rz = vz - kz;
        local speed = Move_Math( MOVE_MATH_SQRT, rx * rx + ry * ry + rz * rz, 0.0 );
        if ( speed <= 0.0 ) return;
        // Native deceleration has already composed its active base override with
        // damage grace and acceleration scales. Surface friction is separate.
        local remaining = speed - Move_GetNativeDeceleration() * Move_GetSurfaceFriction() * dt;
        if ( remaining < 0.0 ) remaining = 0.0;
        remaining *= Move_Math( MOVE_MATH_POW, 0.7,
            dt * GetConVarFloat( ""delta_sp_slide_friction_scale"" ) );
        if ( remaining >= speed ) return;
        local fraction = remaining / speed;
        rx *= fraction;
        ry *= fraction;
        rz *= fraction;
        Move_SetVelocity( kx + rx, ky + ry, kz + rz );
        // Native outWishVel accounting uses the already damped residual.
        Move_SetOutputWishVelocity( Move_GetOutputWishVelocity( MOVE_X ) - (1.0 - fraction) * rx,
            Move_GetOutputWishVelocity( MOVE_Y ) - (1.0 - fraction) * ry,
            Move_GetOutputWishVelocity( MOVE_Z ) - (1.0 - fraction) * rz );
    }
    SlideEvaluate();
}
";
