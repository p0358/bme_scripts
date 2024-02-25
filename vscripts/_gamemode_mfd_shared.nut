const MARKET_ENT_MARKED_NAME = "mfd_marked"
const MARKET_ENT_PENDING_MARKED_NAME = "mfd_pending_marked"
const MARKER_ENT_CLASSNAME = "script_ref"

function main()
{
	// mfd mfdActiveMarkedPlayerEnt are server side entities with a boss player that marks the marked
	level.mfdActiveMarkedPlayerEnt <- {}
	level.mfdActiveMarkedPlayerEnt[ TEAM_IMC ] <- null
	level.mfdActiveMarkedPlayerEnt[ TEAM_MILITIA ] <- null

	level.mfdPendingMarkedPlayerEnt <- {}
	level.mfdPendingMarkedPlayerEnt[ TEAM_IMC ] <- null
	level.mfdPendingMarkedPlayerEnt[ TEAM_MILITIA ] <- null

	if ( IsServer() )
	{
		Minimap_PrecacheMaterial( "vgui/HUD/minimap_mfd_friendly" )
		Minimap_PrecacheMaterial( "vgui/HUD/minimap_mfd_enemy" )
	}
}

function GetMarked( team )
{
	if ( IsValid( level.mfdActiveMarkedPlayerEnt[ team ] ) )
		return level.mfdActiveMarkedPlayerEnt[ team ].GetBossPlayer()
	else
		return null
}
Globalize( GetMarked )

function GetPendingMarked( team )
{
	if ( IsValid( level.mfdPendingMarkedPlayerEnt[ team ] ) )
		return level.mfdPendingMarkedPlayerEnt[ team ].GetBossPlayer()
	else
		return null
}
Globalize( GetPendingMarked )


function FillMFDMarkers( ent ) //Ent used for kill replay related issues...
{
	if ( ent.GetName() == MARKET_ENT_MARKED_NAME )
	{
		Assert( ent.GetTeam() != TEAM_UNASSIGNED )
		level.mfdActiveMarkedPlayerEnt[ ent.GetTeam() ] = ent
	}
	else if ( ent.GetName() == MARKET_ENT_PENDING_MARKED_NAME )
	{
		Assert( ent.GetTeam() != TEAM_UNASSIGNED )
		level.mfdPendingMarkedPlayerEnt[ ent.GetTeam() ] = ent
	}

	return
}
Globalize( FillMFDMarkers )

function TargetsMarkedImmediately()
{
	return IsRoundBased() && IsPilotEliminationBased()
}
Globalize( TargetsMarkedImmediately )