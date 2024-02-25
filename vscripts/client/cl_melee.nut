function main()
{
	Globalize( GetHeadAttachOrigin )
	Globalize( ClientCodeCallback_ShowMeleePrompt )
	IncludeFile( "_melee_shared" )

	FlagInit( "HideMeleePrompt" )
}

function GetHeadAttachOrigin( ent )
{
	local index = ent.LookupAttachment( "hatch_head" )
	return ent.GetAttachmentOrigin( index )
}

function ClientCodeCallback_ShowMeleePrompt( player )
{
	if ( !IsValid( player ) )
		return
	Assert( player.PlayerMelee_CanMelee() )

	if ( Flag( "HideMeleePrompt" ) )
		return false

	//Only human for now, eventually want to change this check to trigger for titans as well

	local target = PlayerConeTraceResult( player, "CodeCallback_IsValidMeleeExecutionTarget" )
	if ( !IsValid( target ) )
		return false

	//Special case for spectre: Don't show prompt, but allow melee executio
	if ( target.IsSpectre() )
		return false

	local actions = GetMeleeActions( player, target )
	Assert( actions, "No melee action for " + player + " vs " + target )

	local action = FindBestMeleeAction( player, target, actions )

	if ( !action )
	{
		return false
	}

	if ( ( "meleeThreadServer" in actions ) && actions.meleeThreadServer )
	{
		return true
	}

	return ( "meleeThreadShared" in actions )
}
