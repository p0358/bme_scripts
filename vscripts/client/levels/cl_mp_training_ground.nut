const RADAR_A_MODEL = "models/IMC_base/radar_a.mdl"
const RADAR_B_MODEL = "models/IMC_base/radar_b.mdl"
const RADAR_C_MODEL = "models/IMC_base/radar_c.mdl"
const RADAR_D_MODEL = "models/IMC_base/radar_d.mdl"
const RADAR_E_MODEL = "models/IMC_base/radar_e.mdl"
const RADAR_F_MODEL = "models/IMC_base/radar_f.mdl"
const RADAR_G_MODEL = "models/IMC_base/radar_g.mdl"
const RADAR_H_MODEL = "models/IMC_base/radar_h.mdl"
const RADAR_I_MODEL = "models/IMC_base/radar_i.mdl"

const TOWER_LIGHT = "tower_light_red"

function main()
{
	IncludeFile( "client/cl_carrier" ) //Included for skyshow dogfights
	IncludeFileAllowMultipleLoads( "client/objects/cl_ai_turret" )

	PrecacheParticleSystem( TOWER_LIGHT )
	SetFullscreenMinimapParameters( 2.6, 100, 0, 180 )
	if ( GAMETYPE == COOPERATIVE )
		SetCustomMinimapZoom( 1.8 )
}

function EntitiesDidLoad()
{
	TowerInit()
}

function TowerInit()
{
	local radar_lights = [ "light1", "light2", "light3" ]

	local tower_info = {
		tower = GetClientEnt( "prop_dynamic", "prop_tower" ),
		towerID = 0,
		radars = [
			{ model = RADAR_A_MODEL, attachment = "def_radar_a", lights = radar_lights, rotate_time = 120.0, reversed_rotation = false },
			{ model = RADAR_B_MODEL, attachment = "def_radar_b", lights = radar_lights, rotate_time = 84.0, reversed_rotation = false },
			{ model = RADAR_C_MODEL, attachment = "def_radar_c", lights = radar_lights, rotate_time = 48.0, reversed_rotation = true },
			{ model = RADAR_D_MODEL, attachment = "def_radar_d", lights = radar_lights, rotate_time = 86.0, reversed_rotation = false },
			{ model = RADAR_E_MODEL, attachment = "def_radar_e", lights = radar_lights, rotate_time = 72.0, reversed_rotation = true },
			{ model = RADAR_F_MODEL, attachment = "def_radar_f", lights = radar_lights, rotate_time = 54.0, reversed_rotation = false },
			{ model = RADAR_G_MODEL, attachment = "def_radar_g", lights = radar_lights, rotate_time = 51.0, reversed_rotation = true },
			{ model = RADAR_H_MODEL, attachment = "def_radar_h", lights = radar_lights, rotate_time = 96.0, reversed_rotation = true },
			{ model = RADAR_I_MODEL, attachment = "def_radar_i", lights = radar_lights, rotate_time = 84.0, reversed_rotation = false }
		]
	}

	thread TowerSpawnAndRotateRadars( tower_info )
}

function TowerRadarSpawnLight( script_mover, attachment )
{
	local fxID = GetParticleSystemIndex( TOWER_LIGHT )
	local attachID = script_mover.LookupAttachment( attachment )
	local fx = StartParticleEffectOnEntity( script_mover, fxID, FX_PATTACH_POINT_FOLLOW, attachID )
	return fx
}

function TowerSpawnAndRotateRadars( tower_info )
{
	local tower = tower_info.tower
	tower.s.spawnedFX <- []

	// SPAWN
	foreach ( radar in tower_info.radars )
	{
		Assert( radar.rotate_time > 0, "rotate_time must be greater than 0" )

		radar.degrees_per_second <- 360.0 / radar.rotate_time
		if ( radar.reversed_rotation )
			radar.degrees_per_second *= -1.0

		radar.rotation_angles <- Vector( 0.0, 0.0, 0.0 )

		radar.script_mover <- CreateClientsideScriptMover( radar.model, Vector( 0.0, 0.0, 0.0 ), Vector( 0.0, 0.0, 0.0 ) )
		radar.script_mover.NonPhysicsSetRotateModeLocal( true )

		local attachmentID = tower.LookupAttachment( radar.attachment )

		radar.script_mover.SetOrigin( tower.GetAttachmentOrigin( attachmentID ) )
		radar.script_mover.SetParent( tower, radar.attachment, true, 0 )
		radar.script_mover.NonPhysicsRotateTo( radar.rotation_angles, 0.016, 0.0, 0.0 )

		foreach ( light in radar.lights )
			tower.s.spawnedFX.append( TowerRadarSpawnLight( radar.script_mover, light ) )
	}

	wait( 0.0 )

	// IDLE
	while ( true )
	{
		foreach ( radar in tower_info.radars )
		{
			radar.rotation_angles.y = AngleNormalize( radar.rotation_angles.y + radar.degrees_per_second )
			radar.script_mover.NonPhysicsRotateTo( radar.rotation_angles, 1.0, 0.0, 0.0 )
		}
		wait( 1.0 )
	}
}