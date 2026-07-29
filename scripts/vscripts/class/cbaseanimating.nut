// function WaittillAnimDone()
function CBaseAnimating::WaittillAnimDone()
{
	waitthread CBaseAnimatingWaittillAnimDone( this )
}

function CBaseAnimatingWaittillAnimDone( self )
{
	if ( self.IsPlayer() )
		self.EndSignal( "Disconnected" )
		
	self.EndSignal( "OnAnimationInterrupted" )
	self.WaitSignal( "OnAnimationDone" )
}
RegisterClassFunctionDesc( CBaseAnimating, "WaittillAnimDone", "Wait until an animation notifies OnAnimationDone or OnAnimationInterrupted" )


CBaseAnimating.__Anim_Stop <- CBaseAnimating.Anim_Stop
function CBaseAnimating::Anim_Stop()
{
	//printt( this, "Anim_Stop" )
	this.Signal( "ScriptAnimStop" )
	this.__Anim_Stop()
}

CBaseAnimating.__SetDoomed <- CBaseAnimating.SetDoomed
function CBaseAnimating::SetDoomed()
{
	local soul = this.GetTitanSoul()
	if ( soul )
		soul.doomedTime = Time()
	this.__SetDoomed()
}


/*
CBaseAnimating.__Anim_PlayWithOriginOnEntity <- CBaseAnimating.Anim_PlayWithOriginOnEntity
function CBaseAnimating::Anim_PlayWithOriginOnEntity( string, handle, string2, float )
{
	printt( this, "Anim_PlayWithOriginOnEntity" )
	this.__Anim_PlayWithOriginOnEntity( string, handle, string2, float )
}

CBaseAnimating.__Anim_Play <- CBaseAnimating.Anim_Play
function CBaseAnimating::Anim_Play( string )
{
	printt( this, "Anim_Play", string )
	
	this.__Anim_Play( string )
}

CBaseAnimating.__Anim_PlayWithRefEntity <- CBaseAnimating.Anim_PlayWithRefEntity
function CBaseAnimating::Anim_PlayWithRefEntity( string, handle, string2, float )
{
	if ( this.GetName() == "heli4" )
		printd( this, "Anim_PlayWithRefEntity" )

	this.__Anim_PlayWithRefEntity( string, handle, string2, float )
}

CBaseAnimating.__Anim_PlayWithRefPoint <- CBaseAnimating.Anim_PlayWithRefPoint
function CBaseAnimating::Anim_PlayWithRefPoint( string, Vector, Vector2, float )
{
	printt( this, "Anim_PlayWithRefPoint", string )
	
	this.__Anim_PlayWithRefPoint( string, Vector, Vector2, float )
}

CBaseAnimating.__Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion <- CBaseAnimating.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion
function CBaseAnimating::Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()
{
	printt( this, "Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion" )
	
	this.__Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()
}

*/