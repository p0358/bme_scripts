const PLAYER_LEECH_PROMPT_ACTIVE_DIST = 96  // distance at which player can leech
const PLAYER_LEECH_PROMPT_REQ_DOT = 0.85  // vectordot to target required for player to leech

function main()
{
	Globalize( CodeCallback_IsLeechable )
	Globalize( FindLeechAction )
	Globalize( IsLeechable )

	level.allLeechActions <- []

	local table =
	{
		playerAnimation1pStart = "ptpov_marvin_leech_start"
		playerAnimation1pIdle = "ptpov_marvin_leech_idle"
		playerAnimation1pEnd = "ptpov_marvin_leech_end"

		playerAnimation3pStart = "pt_marvin_leech_start"
		playerAnimation3pIdle = "pt_marvin_leech_idle"
		playerAnimation3pEnd = "pt_marvin_leech_end"

		targetAnimation3pStart = "mv_leech_start"
		targetAnimation3pIdle = "mv_leech_idle"
		targetAnimation3pEnd = "mv_leech_end"

		direction = Vector( -1, 0, 0 )
		targetClass = "marvin"
	}
	level.allLeechActions.append( table )

	table =
	{
/*
		playerAnimation1pStart = "ptpov_marvin_leech_start"
		playerAnimation1pIdle = "ptpov_marvin_leech_idle"
		playerAnimation1pEnd = "ptpov_marvin_leech_end"

		playerAnimation3pStart = "pt_marvin_leech_start"
		playerAnimation3pIdle = "pt_marvin_leech_idle"
		playerAnimation3pEnd = "pt_marvin_leech_end"

		targetAnimation3pStart = "jump_start"
		targetAnimation3pIdle = "CQB_Idle_Casual"
		targetAnimation3pEnd = "jump_holding_land"

*/
		//New anims, need to flip script to make it player relative, not target relative
		playerAnimation1pStart = "ptpov_data_knife_spectre_leech_start"
		playerAnimation1pIdle = "ptpov_data_knife_spectre_leech_idle"
		playerAnimation1pEnd = "ptpov_data_knife_spectre_leech_end"

		playerAnimation3pStart = "pt_data_knife_spectre_leech_start"
		playerAnimation3pIdle = "pt_data_knife_spectre_leech_idle"
		playerAnimation3pEnd = "pt_data_knife_spectre_leech_end"

		targetAnimation3pStart = "sp_data_knife_spectre_leech_start"
		targetAnimation3pIdle = "sp_data_knife_spectre_leech_idle"
		targetAnimation3pEnd = "sp_data_knife_spectre_leech_end"

		direction = Vector( -1, 0, 0 )
		targetClass = "spectre"

//		playerRelative = true
	}
	level.allLeechActions.append( table )
}

function CodeCallback_IsLeechable( player, target )
{
	PerfStart( PerfIndexShared.CB_IsLeechable )

	local rv = true

	if ( rv && !FindLeechAction( player, target ) )
	{
		rv = false;
	}

	if ( rv && !PlayerCanLeechTarget( player, target ) )
	{
		rv = false;
	}

	PerfEnd( PerfIndexShared.CB_IsLeechable )

	return rv
}

function FindLeechAction( player, target )
{
	Assert( IsValid( player ) )

	if ( !IsValid( target ) )
		return null

	if ( !target.IsNPC() || target.GetAIClass() != "marvin" && target.GetAIClass() != "spectre" )
		return null

	local attackerPos = player.GetOrigin()
	local targetPos = target.GetOrigin()

	local absTargetToPlayerDir
	if ( attackerPos == targetPos )
	{
		absTargetToPlayerDir = Vector( 1, 0, 0 )
	}
	else
	{
		absTargetToPlayerDir = ( attackerPos - targetPos )
		absTargetToPlayerDir.Normalize()
	}

	local relTargetToPlayerDir = CalcRelativeVector( Vector( 0, target.GetAngles().y, 0 ), absTargetToPlayerDir )

	local bestAction = null
	local bestDot = -2

	foreach( action in level.allLeechActions )
	{
		if ( action.targetClass != target.GetAIClass() )
			continue

		local dot = relTargetToPlayerDir.Dot( action.direction )
		if ( dot > bestDot )
		{
			bestAction = action
			bestDot = dot
		}
	}

	return bestAction
}

function PlayerCanLeechTarget( player, target )
{
	if ( !IsLeechable( target ) )
	{
//		printt( "target " + target + " is unleechable" )
		return false
	}

	if ( !IsAlive( target ) )
		return false

	//Disable leeching if either entity is not on ground
	if ( !player.IsOnGround() ) //TODO: Long run probably want to do something more sophisticated like if player is in air, play animation relative to spectre.
		return false

	if ( !target.Anim_IsActive() && !target.IsOnGround() )
		return false

	if ( !CheckVerticallyCloseEnough( player, target ) )
		return false

	return true
}

//Also copy pasted from melee scripts
function CheckVerticallyCloseEnough( attacker, target )
{
	local attackerOrigin = attacker.GetOrigin()
	local targetOrigin = target.GetOrigin()

	local verticalDistance = abs( attackerOrigin.z - targetOrigin.z )

	Assert( attacker.IsHuman() )
	local halfHeight = 30

	//printt( "vertical distance: " + verticalDistance )
	return verticalDistance < halfHeight

}

function IsLeechable( ent )
{
	if ( !IsValid_ThisFrame( ent ) )
		return false

	if ( !IsMultiplayer() && !PlayerCanLeech() )
		return false

	if ( ent.ContextAction_IsActive() )
		return false

	return Leech_IsLeechable( ent )
}
