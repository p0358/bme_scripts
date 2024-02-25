function main()
{
//	Globalize( __PlayerDidSpawn )
	AddSpawnCallback( "player", SP_PlayerPostInit )
}

function SP_PlayerPostInit( self )
{
	if ( !IsValid( GetPlayer() ) )
		return
	if ( !IsValid( self ) )
		return
	level.player <- GetPlayer()
	level.player.s.lostTitanTime <- 0

	level.radioDialogueEnt <- level.player

	InitLeeching( level.player )

	// default lerp time, effects player view cone speed while animating
	level.player.PlayerCone_SetLerpTime( 0.5 )

	CreateViewModel( self )

	player.InitSPClasses()

}


function CreateViewModel( player )
{
	local viewmodel = CreateEntity( "prop_dynamic" )
	viewmodel.kv.model = DEFAULT_VIEW_MODEL
	viewmodel.kv.fadedist = -1
	viewmodel.kv.rendercolor = "255 255 255"
	viewmodel.kv.renderamt = 255
	viewmodel.kv.solid = 0 //not solid
	viewmodel.kv.MinAnimTime = 5
	viewmodel.kv.MaxAnimTime = 10
	viewmodel.kv.VisibilityFlags = 1 // ONLY VISIBLE TO PLAYER
	DispatchSpawn( viewmodel, false )

	viewmodel.Anim_DisableAnimDelta()
	viewmodel.SetOrigin( player.GetOrigin() )
	viewmodel.SetOwner( player )
	viewmodel.Anim_Play( "ptpov_preanim" )
	viewmodel.Hide()
	viewmodel.DisableDraw()

	player.s.viewmodel <- viewmodel
}
