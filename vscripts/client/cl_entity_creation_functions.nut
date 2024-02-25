// Entities never "spawn" on the client; when an entity is created on the client it is a client version of a server entity
// that was spawned an indeterminate amount of time ago.  This entity version of the client may have been seen by script
// and subsequently destroyed before being recreated again (as in the case of a full update).  The "isRecreate" parameter
// can be used to determine if this is the case.
//
// TLDR; The same entity may be "created" and destroyed on the client more than once in a game.

function main()
{
	AddCreateCallback( "npc_titan", ClientCreatedNPCTitan )
	AddCreateCallback( "npc_dropship", CreateCallback_Dropship )
}

function ClientCreatedNPCTitan( self, isRecreate )
{
	if ( isRecreate )
		return

	AddAnimEvent( self, "hide_titan_eye", HideTitanEyeForEmbark )
}
