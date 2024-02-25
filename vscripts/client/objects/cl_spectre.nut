const SPECTRE_EYE_GLOW_FRIENDLY = "P_spectre_eye_friend"
const SPECTRE_EYE_GLOW_ENEMY = "P_spectre_eye_foe"

function main()
{
	AddCreateCallback( "npc_spectre", CreateCallback_Spectre )

	Globalize( SpectreGibExplode )

	PrecacheParticleSystem( SPECTRE_EYE_GLOW_FRIENDLY )
	PrecacheParticleSystem( SPECTRE_EYE_GLOW_ENEMY )

	RegisterSignal( "SpectreGlowEYEGLOW" )
}

function CreateCallback_Spectre( spectre, isRecreate )
{
	if ( isRecreate )
		return

	AddAnimEvent( spectre, "create_dataknife", CreateLeechingDataKnife )

	thread SpectreGlow( spectre, "EYEGLOW", SPECTRE_EYE_GLOW_FRIENDLY, SPECTRE_EYE_GLOW_ENEMY )
}

function SpectreGlow( spectre, tag, friendlyFx, enemyFx )
{
	spectre.Signal( "SpectreGlow" + tag )
	spectre.EndSignal( "SpectreGlow" + tag )

	local spectreTeam = spectre.GetTeam()
	local player = GetLocalViewPlayer()

	local fxName
	if ( player.GetTeam() == spectreTeam )
		fxName = friendlyFx
	else
		fxName = enemyFx

	local attachID = spectre.LookupAttachment( tag )
	//Assert( attachID, tag + " not found on " + spectre.GetModelName() )
	if ( !attachID )
		return

	local fxHandle = StartParticleEffectOnEntity( spectre, GetParticleSystemIndex( fxName ), FX_PATTACH_POINT_FOLLOW, attachID )

	OnThreadEnd(
		function() : ( fxHandle )
		{
			if ( !EffectDoesExist( fxHandle ) )
				return

			EffectStop( fxHandle, false, true )
		}
	)

	spectre.EndSignal( "OnDestroy" )
	spectre.EndSignal( "OnDeath" )

	while ( IsAlive( spectre ) )
	{
		if ( spectre.GetTeam() != spectreTeam )
			thread SpectreGlow( spectre, tag, friendlyFx, enemyFx )

		wait 1.0
	}
}


function SpectreGibExplode( victim, modelName, attackDir, onFire )
{
	local minSpec = GetCPULevel() == CPU_LEVEL_MINSPEC

	local gibLegLeft = "models/robots/spectre/spectre_assault_d_gib_leg_l.mdl"
	local gibLegRight = "models/robots/spectre/spectre_assault_d_gib_leg_r.mdl"
   	local gibArmLeft = "models/robots/spectre/spectre_assault_d_gib_arm_l.mdl"
    local gibArmRight = "models/robots/spectre/spectre_assault_d_gib_arm_r.mdl"

    local attachIDchest = victim.LookupAttachment( "chest" )

    local attachIDleftarm = victim.LookupAttachment( "left_arm" )
    local attachIDrightarm = victim.LookupAttachment( "right_arm" )
    local attachIDleftleg = victim.LookupAttachment( "left_leg" )
    local attachIDrightleg = victim.LookupAttachment( "right_leg" )

	local posTorso = victim.GetAttachmentOrigin( attachIDchest )
	local posArmLeft = victim.GetAttachmentOrigin( attachIDleftarm )
	local posArmRight = victim.GetAttachmentOrigin( attachIDrightarm )
	local posLegLeft =  victim.GetAttachmentOrigin( attachIDleftleg )
	local posLegRight = victim.GetAttachmentOrigin( attachIDrightleg )

	local angArmLeft = victim.GetAttachmentAngles( attachIDleftarm )
	local angArmRight = victim.GetAttachmentAngles( attachIDrightarm )
	local angLegLeft =  victim.GetAttachmentAngles( attachIDleftleg )
	local angLegRight = victim.GetAttachmentAngles( attachIDrightleg )

	attackDir.Normalize()

	local angularVel = Vector( 0, 0, 0 )
	local lifeTime = 3.0
	local flingDir = attackDir * RandomInt( 200, 800 )
	local attachID = attachIDchest

	if ( !minSpec )
	{
		//left arm
		CreateClientsideGib( gibArmLeft, posArmLeft, angArmLeft, flingDir, angularVel, lifeTime, 1024, 512 )

		//right arm
		flingDir = attackDir * RandomInt( 200, 800 )
		CreateClientsideGib( gibArmRight, posArmRight, angArmRight, flingDir, angularVel, lifeTime, 1024, 512 )

		//left leg
		flingDir = attackDir * RandomInt( 200, 800 )
		CreateClientsideGib( gibLegLeft, posLegLeft, angLegLeft, flingDir, angularVel, lifeTime, 1024, 512 )

		//right leg
		flingDir = attackDir * RandomInt( 200, 800 )
		CreateClientsideGib( gibLegRight, posLegRight, angLegRight, flingDir, angularVel, lifeTime, 1024, 512 )
	}

	local fxID = StartParticleEffectOnEntity( victim, GetParticleSystemIndex( "P_exp_spectre_death" ), FX_PATTACH_POINT_FOLLOW, attachID )
	EffectSetControlPointVector( fxID, 1, flingDir )

	EmitSoundAtPosition( posTorso, "Explo_Spectre" )
	return true
}


function CreateLeechingDataKnife( spectre )
{
	local spectreParent = spectre.GetParent()
	if ( spectreParent == null )
		return

	local player = GetLocalViewPlayer()
	local parentEnt = player.GetParent()

	// are we parented to this panel?
	if ( spectreParent != parentEnt )
		return

	thread PlayerGetsKnifeUntilLosesParent( player, parentEnt )
}

function PlayerGetsKnifeUntilLosesParent( player, parentEnt )
{

	local viewModel = player.GetFirstPersonProxy()  //JFS: Defensive fix for player not having view models sometimes
	if ( !IsValid( viewModel ) )
		return
	if ( !EntHasModelSet( viewModel ) )
		return

	if ( !( "knife" in player.s ) )
		player.s.knife <- null

	local model = DATA_KNIFE_MODEL
	local knife = CreatePropDynamic( model, Vector(0,0,0), Vector(0,0,0) )
	knife.SetParent( player.GetFirstPersonProxy(), "propgun", false, 0.0 )

	OnThreadEnd(
		function () : ( player, knife )
		{
			if ( ( "knife" in player.s ) && player.s.knife == knife ) //JFS, Defensive check for knife. For some reason sometimes it disappears. See bug 60141
				delete player.s.knife

			// knife can be destroyed first by replay
			if ( IsValid( knife ) )
				knife.Destroy()
		}
	)

	player.s.knife = knife

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	knife.Anim_Play( "data_knife_console_leech_end" )

	for ( ;; )
	{
		if ( player.GetParent() != parentEnt )
			break
		wait 0
	}
}

