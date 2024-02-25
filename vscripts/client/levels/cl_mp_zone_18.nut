
const FX_SKYBOX_REDEYE_WARP_IN = "veh_red_warp_in_full_SB"
const FX_SKYBOX_REDEYE_WARP_OUT = "veh_red_warp_out_full_SB"
const FX_SKYBOX_BERMINGHAM_WARP_IN = "veh_birm_warp_in_full_SB"
const FX_SKYBOX_BERMINGHAM_WARP_OUT = "veh_birm_warp_out_full_SB"

level.skyboxCamOrigin <- Vector( -12280.0, -13528.0, -3826.0 )

PrecacheParticleSystem( FX_SKYBOX_REDEYE_WARP_IN )
PrecacheParticleSystem( FX_SKYBOX_REDEYE_WARP_OUT )
PrecacheParticleSystem( FX_SKYBOX_BERMINGHAM_WARP_IN )
PrecacheParticleSystem( FX_SKYBOX_BERMINGHAM_WARP_OUT )

function main()
{
	SetFullscreenMinimapParameters( 2.1, 0, -1050, 180 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 1.5 )
}

function EntitiesDidLoad()
{
	thread SkyboxSlowFlybys()
}

function SkyboxSlowFlybys()
{
	local slowFlybyShips = []

	local spawnOffset = Vector( 5.0, 0.0, -7.0 )

	local skyboxWidth = { min = -300, max = 300 }
	local skyboxLength = { min = -650, max = 300 }
	local skyboxHeight = { min = 75.0, max = 200.0 }
	local moveSpeed = { min = 14.0, max = 9.0 }
	local skyboxTotalLength = fabs( skyboxLength.max - skyboxLength.min )
	local moveDuration = { min = skyboxTotalLength / moveSpeed.min, max = skyboxTotalLength / moveSpeed.max }
	local forwardOffset = { min = 0.0, max = 200.0 }
	local rightOffset = { min = -17.5, max = 17.5 }

	local shipDirection = Vector( -0.580235, 0.813501, -0.039295 )

	local spawnAng = VectorToAngles( shipDirection )
	local right = spawnAng.AnglesToRight()

	local numShipsAcross = 8
	local shipSpacing = abs( skyboxWidth.min - skyboxWidth.max ) / numShipsAcross

	local spawnOrder = [ [ 1, 6, 4, 0, 5, 3, 7, 2 ],
						 [ 0, 4, 2, 1, 6, 3, 7, 5 ],
						 [ 0, 1, 3, 6, 7, 4, 2, 5 ],
						 [ 5, 7, 3, 6, 1, 2, 4, 0 ],
						 [ 2, 7, 3, 5, 0, 4, 6, 1 ],
						 [ 5, 2, 4, 7, 6, 3, 1, 0 ] ]

	local heights = [ [ 0.9, 0.4, 0.6, 0.1, 0.2, 0.7, 1.0, 0.3 ],
					  [ 0.4, 0.9, 0.6, 1.0, 0.9, 0.7, 0.5, 0.6 ],
					  [ 0.8, 0.1, 0.7, 0.2, 0.5, 1.0, 0.4, 0.3 ],
					  [ 0.6, 0.5, 0.7, 0.9, 1.0, 0.6, 0.9, 0.4 ],
					  [ 0.3, 1.0, 0.7, 0.2, 0.1, 0.6, 0.4, 0.9 ],
					  [ 0.3, 0.4, 1.0, 0.5, 0.2, 0.7, 0.1, 0.8 ] ]

	local durations = [ [ 0.6, 0.8, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
						[ 0.4, 0.8, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
					 	[ 0.6, 0.3, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
					 	[ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.8, 0.4 ],
					 	[ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.3, 0.6 ],
					 	[ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.8, 0.6 ] ]

	local forwardOffsets = [ [ 0.0, 0.8, 1.0, 0.0, 0.1, 0.6, 0.2, 0.3 ],
							 [ 0.0, 0.8, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
					 		 [ 0.0, 0.3, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
					 		 [ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.8, 0.6 ],
					 		 [ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.8, 0.4 ],
					 		 [ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.3, 0.6 ] ]

	local rightOffsets = [ [ 0.6, 0.8, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
						   [ 0.4, 0.8, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
					 	   [ 0.6, 0.3, 0.7, 0.5, 0.1, 0.6, 0.2, 0.3 ],
					 	   [ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.8, 0.6 ],
						   [ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.8, 0.4 ],
					 	   [ 0.3, 0.2, 0.6, 0.1, 0.5, 0.7, 0.3, 0.6 ] ]

	local shipModels = [ [ 1, 1, 1, 0, 0, 0, 0, 0 ],
						 [ 0, 0, 1, 0, 0, 0, 0, 0 ],
						 [ 1, 0, 1, 0, 0, 0, 0, 1 ],
						 [ 0, 0, 0, 0, 0, 1, 1, 1 ],
						 [ 0, 0, 0, 0, 0, 1, 0, 0 ],
						 [ 1, 0, 0, 0, 0, 1, 0, 1 ] ]

	while ( GetGameState() <= eGameState.SuddenDeath )
	{
		foreach( i, so in spawnOrder )
		{
			foreach( index, val in so )
			{
				local shipMoveDuration = GraphCapped( durations[ i ][ index ], 0.0, 1.0, moveDuration.min, moveDuration.max )

				local offsetForward = skyboxLength.min
				offsetForward += GraphCapped( forwardOffsets[ i ][ index ], 0.0, 1.0, forwardOffset.min, forwardOffset.max )

				local offsetRight = skyboxWidth.min + ( shipSpacing / 2.0 ) + ( shipSpacing * val )
				offsetRight += GraphCapped( rightOffsets[ i ][ index ], 0.0, 1.0, rightOffset.min, rightOffset.max )

				local offsetHeight = GraphCapped( heights[ i ][ index ], 0.0, 1.0, skyboxHeight.min, skyboxHeight.max )

				local spawnPos = level.skyboxCamOrigin + spawnOffset + ( shipDirection * offsetForward ) + ( right * offsetRight ) + Vector( 0, 0, offsetHeight )
				local moveToPos = spawnPos + ( shipDirection * abs( skyboxLength.min - skyboxLength.max ) )

				local model = shipModels[ i ][ index ] == 0 ? SKYBOX_ARMADA_SHIP_MODEL_REDEYE : SKYBOX_ARMADA_SHIP_MODEL_BERMINGHAM
				local ship = CreateClientsideScriptMover( model, spawnPos, spawnAng )
				slowFlybyShips.append( ship )

				thread SkyboxShipWarpIn( ship )
				ship.NonPhysicsMoveTo( moveToPos, shipMoveDuration, 0, 0 )
				thread WarpOutFlybyShipWithDelay( ship, shipMoveDuration )

				wait( 1.0 )
			}

			wait( 24.0 )
		}
	}

	// Make some of the remaining ships warp out during the epilogue
	foreach( ship in slowFlybyShips )
	{
		if ( IsValid( ship ) && "warpinComplete" in ship.s )
			thread WarpOutFlybyShipWithDelay( ship, RandomFloat( 0.0, 30.0 ) )
	}
}

function SkyboxShipWarpIn( ship )
{
	ship.EndSignal( "OnDestroy" )
	local fxID = null
	switch( ship.GetModelName().tolower() )
	{
		case SKYBOX_ARMADA_SHIP_MODEL_REDEYE.tolower():
			fxID = GetParticleSystemIndex( FX_SKYBOX_REDEYE_WARP_IN )
			break
		case SKYBOX_ARMADA_SHIP_MODEL_BERMINGHAM.tolower():
			fxID = GetParticleSystemIndex( FX_SKYBOX_BERMINGHAM_WARP_IN )
			break
		default:
			Assert( 0, "Invalid model for skybox warp in effect for " + ship.GetModelName() )
	}
	Assert( fxID != null )

	ship.Hide()
	EmitSkyboxSoundAtPosition( ship.GetOrigin(), "largeship_warpin" )
	local fx = StartParticleEffectInWorldWithHandle( fxID, ship.GetOrigin(), ship.GetAngles() )
	wait 0.25
	ship.Show()
	ship.s.warpinComplete <- true
}

function SkyboxShipWarpOut( ship )
{
	local fxID = null
	switch( ship.GetModelName().tolower() )
	{
		case SKYBOX_ARMADA_SHIP_MODEL_REDEYE.tolower():
			fxID = GetParticleSystemIndex( FX_SKYBOX_REDEYE_WARP_OUT )
			break
		case SKYBOX_ARMADA_SHIP_MODEL_BERMINGHAM.tolower():
			fxID = GetParticleSystemIndex( FX_SKYBOX_BERMINGHAM_WARP_OUT )
			break
		default:
			Assert( 0, "Invalid model for skybox warp out effect" )
	}
	Assert( fxID != null )
	local fx = StartParticleEffectInWorldWithHandle( fxID, ship.GetOrigin(), ship.GetAngles() )
}

function WarpOutFlybyShipWithDelay( ship, delay = 0 )
{
	wait delay
	if ( !IsValid( ship ) )
		return

	SkyboxShipWarpOut( ship )
	ship.Kill()
}