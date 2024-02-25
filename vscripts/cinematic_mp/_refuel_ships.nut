const REFUEL_START_ANIM = "refueling_sequence_start"

FlagInit( "RefuelShipsEnabled", true )

function main()
{
	RegisterSignal( "arriving" )
	RegisterSignal( "FuelingDone" )
	RegisterSignal( "OnTakeDamage" )
	RegisterSignal( "NewRecoveryAnim" )

	AddSpawnCallback( "prop_refuel_pump", AddRefuelPump )

	file.mapList <- { mp_fracture = 1, mp_ra_testOFF = 1, mp_test_refuel = 1 }
	file.pumps <- []
}

function EntitiesDidLoad()
{
	if ( GetMapName() in file.mapList )
		thread CinimaticDropshipThink()
}

function CinimaticDropshipThink()
{
	if ( !file.pumps.len() )
		return

	if ( !level.isTestmap )
		ArrayRandomize( file.pumps )

	FlagWait( "GamePlaying" )

	while( true )
	{
		if ( !Flag( "RefuelShipsEnabled" ) )
			FlagWait( "RefuelShipsEnabled" )

		if ( GetGameState() > eGameState.SuddenDeath )
			break

		local pump = GetFuelPump()
		if ( pump )
			thread DropshipFliesAndRefuels( pump, TEAM_MILITIA )

		if ( !level.isTestmap )
			wait RandomFloat( 10, 20 )
		else
			wait 10
	}
}

function PumpSort( a, b )
{
	if ( a.s.lastUsed > b.s.lastUsed )
		return 1
	if ( a.s.lastUsed < b.s.lastUsed )
		return -1
	return 0
}

function GetFuelPump()
{
	file.pumps.sort( PumpSort )
	foreach( pump in file.pumps )
	{
		if ( !pump.s.inUse )
		{
			pump.s.lastUsed = Time()
			return pump
		}
	}
}

function DropshipFliesAndRefuels( pump, team )
{
	OnThreadEnd(
		function () : ( pump )
		{
			if ( IsValid( pump ) )
			{
				if ( pump.s.raised )
					thread DropRefuelPump( pump )

				pump.s.inUse = false
			}
		}
	)

	pump.s.inUse = true

	local ship = CreateRefuelingDropship( pump, team ) // time passes in this function
	ship.s.pump <- pump // save the pump here for now. I shouldn't need it once the real anim is in.

	ship.EndSignal( "OnDeath" )

	local soundPrefix

	if ( team == TEAM_IMC )
		soundPrefix = "Goblin_"
	else if ( team == TEAM_MILITIA )
		soundPrefix = "Crow_"
	else assert( false, "Team :" + team + " not supported " )

	EmitSoundOnEntity( ship, soundPrefix + "dropship_refuel_engine_approach" )

	thread PlayAnimTeleport( ship, REFUEL_START_ANIM, pump )
	ship.WaitSignal( "arriving" )

	thread RaiseRefuelPump( pump )

	ship.WaittillAnimDone()

	waitthread PumpFuelUntilTimeToGo( pump, ship, RandomFloat( 12, 17 ) )

	local recoveryTime = ship.s.hitTimeout - Time()
	if ( recoveryTime )
		wait recoveryTime * 0.5

	thread DropRefuelPump( pump )
	EmitSoundOnEntity( ship, soundPrefix + "dropship_refuel_engine_depart" )
	waitthread PlayAnim( ship, "refueling_sequence_end", pump, null, 1.0 )
}

function PumpFuelUntilTimeToGo( pump, ship, time )
{
	ship.EndSignal( "OnDeath" )
	ship.EndSignal( "FuelingDone" )

	thread PlayAnim( ship, "refueling_sequence_idle", pump )
	thread PlayAnim( pump, "fp_refueling_sequence_idle", pump )

	thread DropshipPainAnimWithFuelPump( ship, pump )

	thread DropshipSignalOnHealth( ship, 0.75, "FuelingDone" )

	wait time
	ship.Signal( "FuelingDone" )
}

function DropshipSignalOnHealth( ship, healthLimit, signal )
{
	ship.EndSignal( "OnDeath" )

	local maxHealth = ship.GetMaxHealth().tofloat()

	while( true )
	{
		ship.WaitSignal( "OnTakeDamage" )
		if ( ship.GetHealth().tofloat() / maxHealth < healthLimit )
			break
	}

	ship.Signal( signal )
}

function CreateRefuelingDropship( ref, team )
{
	waitthread WarpinEffect( DROPSHIP_MODEL, REFUEL_START_ANIM, ref.GetOrigin(), ref.GetAngles() )

	local ship = SpawnAnimatedDropship( ref.GetOrigin(), team, "militia_refuelship", 6000 )

	return ship
}

function DropshipPainAnimWithFuelPump( ship, pump )
{
	ship.EndSignal( "OnDeath" )
	ship.EndSignal( "FuelingDone" )

	ship.s.hitTimeout <- 0

	while( true )
	{
		local results = ship.WaitSignal( "OnTakeDamage" )
		local hitOrigin = results.position
		waitthread ShipHitFromPosition( ship, pump, hitOrigin )
	}
}

function ShipHitFromPosition( ship, pump, hitOrigin )
{
	WaitEndFrame() // for all damage that happened on this frame

	local damage = GetTotalDamageTakenInTime( ship, 0.25 )

	// no twitch from small arms
	if ( damage < 99 )
		return

	local bigHit = damage > 1000

	local hitAnim
	local hitAnimPump
	local duration
	local waitTime

	if ( bigHit )
	{
		hitAnim = GetHitAnimForDirection( ship, hitOrigin )
		hitAnimPump = "fp_refueling_hit_large"
		duration = ship.GetSequenceDuration( hitAnim )
		waitTime = 1.3	// time to wait before another big hit can happen
	}
	else
	{
		hitAnim = "gd_refueling_hit_small"
		hitAnimPump = "fp_refueling_hit_small"
		duration = ship.GetSequenceDuration( hitAnim )
		waitTime = duration * 0.7	// time to wait before another small hit can happen
	}

	ship.s.hitTimeout = Time() + duration

	thread PlayAnim( ship, hitAnim, pump )
	thread PlayAnim( pump, hitAnimPump, pump )
	thread RecoverFromSmallAnim( ship, pump, duration )

	wait waitTime
}

function RecoverFromSmallAnim( ship, pump, duration )
{
	ship.EndSignal( "OnDeath" )
	ship.EndSignal( "FuelingDone" )

	ship.Signal( "NewRecoveryAnim" )
	ship.EndSignal( "NewRecoveryAnim" )

	// otherwise it will float down to the ground when the anim is done
	wait duration
	thread PlayAnim( ship, "refueling_sequence_idle", pump, null, 0.5 )
	thread PlayAnim( pump, "fp_refueling_sequence_idle", pump, null, 0.5 )
}

function GetHitAnimForDirection( ship, hitOrigin )
{
	local origin = ship.GetCenter()
	local angles = ship.GetAngles()
	local forward = angles.AnglesToForward()
	local right = angles.AnglesToRight()
	local vec = hitOrigin - origin
	vec.Norm()

	local dotForward = forward.Dot( vec )
	local rightSide = right.Dot( vec ) > 0.0

	// should swap the numbers for the real angle numbers
	if ( dotForward > 0.777 )
	{
		return "gd_refueling_hit_large_2"
	}
	else
	if ( dotForward > 0.444 )
	{
		if ( rightSide )
			return "gd_refueling_hit_large_1"
		else
			return "gd_refueling_hit_large_3"
	}
	else
	if ( dotForward > -0.444 )
	{
		if ( rightSide )
			return "gd_refueling_hit_large_4"
		else
			return "gd_refueling_hit_large_6"
	}
	else
	if ( dotForward > -0.777 )
	{
		if ( rightSide )
			return "gd_refueling_hit_large_7"
		else
			return "gd_refueling_hit_large_9"
	}
	else
	{
		return "gd_refueling_hit_large_8"
	}
}

function AddRefuelPump( pump )
{
	file.pumps.append( pump )
	pump.s.inUse <- false
	pump.s.raised <- false
	pump.s.lastUsed <- 0
}

function RaiseRefuelPump( pump )
{
	pump.s.raised = true
	waitthread PlayAnim( pump, "fp_refueling_arm_raise" )

	EmitSoundOnEntity( pump, "dropship_refuel_fuelloop" )
}

function DropRefuelPump( pump )
{
	StopSoundOnEntity( pump, "dropship_refuel_fuelloop" )

	pump.s.raised = false
	waitthread PlayAnim( pump, "fp_refueling_arm_drop", null, null, 1.0 )
}