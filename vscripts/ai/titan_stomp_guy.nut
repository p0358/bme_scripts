function got_stomped()
{
	/*
	printl( "DID SOMETHING" )
	printl( "Activator " + activator )
	printl( "Caller " + caller )
	printl( "self " + self )
	*/

	// die at the end of the animation
	EntFireByHandle( self, "sethealth", "0", 0, null, null )
	self.BecomeRagdoll( Vector( 0, 0, 0 ) )						
}

function anim_init( animator )
{
	animator.ConnectOutputTarget( "OnScriptEvent01", "got_stomped", self )
}
